tools=$CHAOS_BUNDLE/tools
OS=`uname -s`
ARCH=`uname -m`
KERNEL_VER=$(uname -r)
KERNEL_SHORT_VER=$(uname -r|cut -d\- -f1|tr -d '.'| tr -d '[A-Z][a-z]')
NPROC=$(getconf _NPROCESSORS_ONLN)

if [ -n "$CHAOS_PREFIX" ];then
    PREFIX=$CHAOS_PREFIX
fi


info_mesg(){
    if [ -z "$2" ]; then
	echo -e "* \x1B[1m$1\x1B[22m"
    else
	echo -e "* \x1B[1m$1\x1B[32m$2\x1B[39m\x1B[22m"
    fi
}
error_mesg(){
    if [ -z "$2" ]; then
	echo -e "# \x1B[31m\x1B[1m$1\x1B[22m\x1B[39m"
    else
	echo -e "# \x1B[1m$1\x1B[31m$2\x1B[39m\x1B[22m"
    fi
}

warn_mesg(){
    if [ -z "$2" ]; then
	echo -e "% \x1B[33m\x1B[1m$1\x1B[22m\x1B[39m"
    else
	echo -e "# \x1B[1m$1\x1B[33m$2\x1B[39m\x1B[22m"
    fi
}

ok_mesg(){
    echo -e "* $1 \x1B[32m\x1B[1mOK\x1B[22m\x1B[39m"
}
nok_mesg(){
    echo -e "* $1 \x1B[31m\x1B[1mNOK\x1B[22m\x1B[39m"
}

function unSetEnv(){
    unset CHAOS_STATIC
    unset CHAOS_TARGET
    unset CHAOS_DEVELOPMENT
}

# type target build
function setEnv(){
    local type=$1
    local target=$2
    local build=$3
    local prefix=$4

    if [ "$type" == "static" ]; then
	export CHAOS_STATIC=true
    fi
    if [ "$target" == "armhf" ]; then
	export CHAOS_TARGET=armhf
    fi
	    
    if [ "$build" == "debug" ]; then
	export CHAOS_DEVELOPMENT=true
    fi
    if [ -d "$prefix" ]; then
	export CHAOS_PREFIX=$prefix
	PREFIX=$prefix
    else
	echo "## directory $prefix is invalid"
	exit 1
    fi
    info_mesg "CHAOS_BUNDLE  :" "$CHAOS_BUNDLE"
    info_mesg "Target        :" "$target"
    info_mesg "Type          :" "$type"
    info_mesg "Configuration :" "$build"
    info_mesg "Prefix        :" "$prefix"
    info_mesg "OS            :" "$OS"
    source $dir/chaos_bundle_env.sh >& $log
    rm -rf $CHAOS_BUNDLE/usr $CHAOS_FRAMEWORK/usr $CHAOS_FRAMEWORK/usr/local
    mkdir -p $CHAOS_BUNDLE/usr
    mkdir -p $CHAOS_FRAMEWORK/usr
    ln -sf $PREFIX $CHAOS_FRAMEWORK/usr/local
    
}

function saveEnv(){
    
    echo "echo \"* Environment $tgt\"" > $PREFIX/chaos_env.sh
    if [ -n "$CHAOS_DEVELOPMENT" ];then
	echo "export CHAOS_DEVELOPMENT=true" >> $PREFIX/chaos_env.sh
    fi
    if [ -n "$CHAOS_TARGET" ];then
	echo "export CHAOS_TARGET=$CHAOS_TARGET" >> $PREFIX/chaos_env.sh
    fi
    echo "export CHAOS_PREFIX=\$PWD" >> $PREFIX/chaos_env.sh
    echo "if [ -z \"\$CHAOS_BUNDLE\" ];then" >> $PREFIX/chaos_env.sh
    echo -e "\texport CHAOS_BUNDLE=\$CHAOS_PREFIX" >> $PREFIX/chaos_env.sh
    echo "fi" >> $PREFIX/chaos_env.sh
    if [ -n "$CHAOS_STATIC" ];then
	echo "export CHAOS_STATIC=true" >> $PREFIX/chaos_env.sh
    else
	if [ "$CHAOS_TARGET" == "Linux" ];then
	    echo "export LD_LIBRARY_PATH=\$CHAOS_PREFIX/lib" >> $PREFIX/chaos_env.sh
	else
	    echo "export LD_LIBRARY_PATH=\$CHAOS_PREFIX/lib" >> $PREFIX/chaos_env.sh
	    echo "export DYLD_LIBRARY_PATH=\$CHAOS_PREFIX/lib" >> $PREFIX/chaos_env.sh
	fi

    fi
    echo "source \$PWD/tools/chaos_bundle_env.sh" >> $PREFIX/chaos_env.sh

    echo "export PATH=\$PATH:\$CHAOS_PREFIX/bin:\$CHAOS_PREFIX/tools" >> $PREFIX/chaos_env.sh

    
}


function chaos_configure(){

    if [ -z "$CHAOS_BUNDLE" ] || [ -z "$CHAOS_PREFIX" ]; then
	error_mesg "CHAOS_BUNDLE (sources) and CHAOS_PREFIX (install dir) environments must be set"
	exit 1
    fi

    saveEnv
    
    cp -a $CHAOS_BUNDLE/tools $PREFIX
    mkdir -p $PREFIX/etc
    mkdir -p $PREFIX/vfs
    mkdir -p $PREFIX/log
    mkdir -p $PREFIX/chaosframework
    
    path=`echo $PREFIX/vfs|sed 's/\//\\\\\//g'`
    logpath=`echo $PREFIX/log/cds.log|sed 's/\//\\\\\//g'`
    cat $CHAOS_BUNDLE/chaosframework/ChaosDataService/__template__cds.conf | sed s/_CACHESERVER_/localhost/|sed s/_DOMAIN_/$tgt/|sed s/_VFSPATH_/$path/g |sed s/_CDSLOG_/$logpath/g > $PREFIX/etc/cds_local.cfg
    ln -sf $PREFIX/etc/cds_local.cfg $PREFIX/etc/cds.cfg
    ln -sf $CHAOS_BUNDLE/chaosframework/ChaosMDSLite $PREFIX/chaosframework
}

get_pid(){
    local execname=`echo $1 | sed 's/\(.\)/[\1]/'`
    ps -fe |grep "$execname" | sed 's/\ \+/\ /g'| cut -d ' ' -f 2|tr '\n' ' '
    
}
time_format="+%s.%N"
if [ "$OS" == "Darwin" ]; then
    time_format="+%s"
fi

stop_proc(){
    pid=`get_pid "$1"`
    for p in $pid;do
	if [ -n "$p" ]; then
	    if ! kill -9 $p ; then
		error_mesg "cannot kill process $p"
		exit 1
	    else
		ok_mesg "process $1 ($p) killed"
	    fi
	
	else
	    warn_mesg "process $1 ($p) not running"
	fi
    done
}
get_cpu_stat(){
    info=`ps -o pcpu,pmem $1| tail -1 |sed 's/\s\+/\ /g'`
    echo "$info" | cut -d ' ' -f 2
}
get_mem_stat(){
    info=`ps -o pcpu,pmem $1| tail -1 |sed 's/\s\+/\ /g'`
    echo "$info" | cut -d ' ' -f 3
}

check_proc(){
    local status=0
    pid=`get_pid "$1"`
    for p in $pid;do
	if [ -n "$p" ]; then

	    cpu=$(get_cpu_stat $p)
	    mem=$(get_mem_stat $p)
	    if [ $(echo "($cpu - 50)>0" | bc) -gt 0 ]; then
		cpu="\x1B[31m$cpu%\x1B[39m"
	    else
		cpu="\x1B[1m$cpu%\x1B[22m"
	    fi
	    if [ $(echo "($mem - 50)>0" |bc) -gt 0 ]; then
		mem="\x1B[31m$mem%\x1B[39m"
	    else
		mem="\x1B[1m$mem%\x1B[22m"
	    fi
	    
	    ok_mesg "process \x1B[1m$1\x1B[22m is running with pid \x1B[1m$p\x1B[22m cpu $cpu, mem $mem"
	else
	    nok_mesg "process \x1B[1m$1\x1B[22m is not running"
	    ((status++))
	fi
    done
	return $status
}

check_proc_then_kill(){
    pid=`get_pid "$1"`
    if [ -n "$pid" ]; then
	warn_mesg "process $1 is running with pid \"$pid\", killing"
	stop_proc $1;
    fi
}
run_proc(){
    command_line="$1"
    process_name="$2"
    local run_prefix="$CHAOS_RUNPREFIX"
    local oldpid=`get_pid $process_name`
    local oldpidl=()
    if [ $? -eq 0 ] && [ -n "$oldpid" ]; then
	oldpidl=($oldpid)
    fi
	
    if [ -z "$run_prefix" ];then
	eval $command_line
    else
	if [ -n "$CHAOS_RUNOUTPREFIX" ];then

	    run_prefix="$run_prefix $CHAOS_RUNOUTPREFIX$CHAOS_PREFIX/log/data_$process_name.log"
	fi
	eval "$run_prefix $command_line"
    fi

    if [ $? -eq 0 ]; then
	sleep 1
	local pidl=()
	pid=`get_pid $process_name`
	if [ $? -eq 0 ] && [ -n "$pid" ]; then
	    pidl=($pid)
	fi

	if [ ${#pidl[@]} -gt ${#oldpidl[@]} ];then
	    local p=${pidl[$((${#pidl[@]} -1))]}
	    ok_mesg "process \x1B[32m\x1B[1m$process_name\x1B[21m\x1B[39m with pid \"$p\", started" 
	    return 0
	else
	    nok_mesg "process $process_name quitted unexpectly "
	    exit 1
	fi
	
    else
	error_mesg "error lunching $process_name"
	exit 1
    fi
    return 0
}

test_services(){
    if $tools/chaos_services.sh status ; then
	ok_mesg "chaos services"
	return 0
    else
	nok_mesg "chaos services"
	return 1
    fi
}
start_services(){

    if $tools/chaos_services.sh start ; then
	ok_mesg "chaos start services"
	return 0
    else
	nok_mesg "chaos start services"
	return 1
    fi
}
start_mds(){
    if $tools/chaos_services.sh start mds; then
	ok_mesg "chaos start mds"
	return 0
    else
	nok_mesg "chaos start mds"
	return 1
    fi
}

test_prefix(){
    if [ -z "$CHAOS_PREFIX" ];then
	error_mesg "environment CHAOS_PREFIX not set, please set it"
	exit 1
    else
	info_mesg "Prefix $CHAOS_PREFIX"
    fi
}

get_abs_filename() {
 
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

get_abs_dir() {
 
  echo "$(cd "$(dirname "$1")" && pwd)"
}

find_cu_conf(){
    find $CHAOS_PREFIX/etc -name "*.conf"
}

build_mds_conf(){
    local ncu=$1
    local nus=$2
    local out=$3
    local dataserver="$4"
    local lista_conf=""

    for l in $(find_cu_conf);do
	lista_conf="-i $l -n $ncu "
    done
    
    local param="$lista_conf -j $nus -o $out"
    if [ -n "$dataserver" ];then
	param="$param -d $dataserver"
    fi

    if [ -n "$lista_conf" ] && $CHAOS_TOOLS/chaos_build_conf.sh $param;then
	ok_mesg "MDS configuration generated"
	return 0
    else
	nok_mesg "MDS configuration generated"
    fi
}

_start_profile_time=0
_end_profile_time=0
function start_profile_time(){
    _start_profile_time=`date $time_format`
}

function end_profile_time(){
    _end_profile_time=`date $time_format`
    echo "$_end_profile_time - $_start_profile_time"|bc
}

execute_command_until_ok(){
    local command="$1"
    local _cnt_=$2
    local _ok_=0

    while (((_cnt_ > 0) && (_ok_==0) ));do
	execute_command=`eval $command`
	if [ $? -eq 0 ] ;then
	    _ok_=1
	else
	    echo -n "."
	    ((_cnt_--))
	    sleep 1
	fi

    done
   if [ $_cnt_ -lt $2 ]; then
       echo
   fi
   if [ $_ok_ -eq 0 ]; then 
       return 1
   
   fi

   return 0

}

chaos_cli_cmd(){
    local meta="$1"
    local cuname="$2"
    local param="$3"
    local timeout=5000
    cli_cmd=""
    if [ "$CHAOS_RUNTYPE" == "callgrind" ]; then
	timeout=$((timeout * 10))
    fi
    cli_cmd=`ChaosCLI --metadata-server=$meta --deviceid $cuname --timeout $timeout $param 2>&1`
   
    if [ $? -eq 0 ]; then
	return 0
    fi
    error_mesg "Error \"ChaosCLI --metadata-server=$meta --deviceid $cuname $param \" returned:$out"
    return 1

}
# meta cuname
init_cu(){
    chaos_cli_cmd $1 $2 "--op 1"
}
start_cu(){
    chaos_cli_cmd $1 $2 "--op 2"
}
deinit_cu(){
    chaos_cli_cmd $1 $2 "--op 4"
}
stop_cu(){
    chaos_cli_cmd $1 $2 "--op 3"
}

get_timestamp_cu(){
    local meta="$1"
    local cuname="$2"

    timestamp_cu=0
    if ! chaos_cli_cmd $meta $cuname "--print-dataset 0";then
	return 1
    fi

    if [[ "$cli_cmd" =~ \"dpck_ts\"\ \:\ \{\ \"\$[a-zA-Z]+\"\ \:\ \"([0-9]+)\" ]];then
	timestamp_cu=${BASH_REMATCH[1]}
	return 0
    fi
    
    return 1
}


loop_cu_test(){
    local meta="$1"
    local cuname="$2"
    local max="$3"
    local cnt=0
    local t1=0
    for ((cnt=0;cnt<$max;cnt++));do
	info_mesg "loop cu test $cnt on CU $cuname"
	if init_cu $meta $cuname;then
	    ok_mesg "- $cnt init $cuname"
	else
	    nok_mesg "- $cnt init $cuname"
	    return 1
	fi

	if start_cu $meta $cuname;then
	    ok_mesg "- $cnt start $cuname"
	else
	    nok_mesg "- $cnt start $cuname"
	    return 1
	fi
	sleep 1
	if get_timestamp_cu $meta $cuname;then
	    ok_mesg "- $cnt get timestamp $timestamp_cu"
	    
	    if [ $t1 -gt 0 ];then
		res=$((timestamp_cu -t1)) 
		if [ $res -gt 0 ]; then
		    info_mesg "cu $cuname is living loop time" " $res ms"
		else
		    warn_mesg "cu $cuname not progressing"
		fi
	    fi
	    t1=$timestamp_cu	    
	else
	    nok_mesg "- $cnt get timestamp $cuname"
	    return 1
	fi
	
	if stop_cu $meta $cuname;then
	    ok_mesg "- $cnt stop $cuname"
	else
	    nok_mesg "- $cnt stop $cuname"
	    return 1
	fi

	if deinit_cu $meta $cuname;then
	    ok_mesg "- $cnt deinit $cuname"
	else
	    nok_mesg "- $cnt deinit $cuname"
	    return 1
	fi
    done
    return 0
}
