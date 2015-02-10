tools=$CHAOS_BUNDLE/tools
OS=`uname -s`
ARCH=`uname -m`
SCRIPTNAME=`basename $0`
SCRIPTTESTPATH=$0
KERNEL_VER=$(uname -r)
KERNEL_SHORT_VER=$(uname -r|cut -d\- -f1|tr -d '.'| tr -d '[A-Z][a-z]')
NPROC=$(getconf _NPROCESSORS_ONLN)

if [ -n "$CHAOS_PREFIX" ];then
    PREFIX=$CHAOS_PREFIX
fi

declare -a __testinfo__
for ((cnt=0;cnt<4;cnt++));do
    if [ -z "${__testinfo__[$cnt]}" ];then
	__testinfo__[$cnt]=0
	echo "${__testinfo__[@]}" >/tmp/__chaos_test_info__
    fi
done


  

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
	echo -e "% \x1B[1m$1\x1B[33m$2\x1B[39m\x1B[22m"
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
    cp $PREFIX/chaosframework/ChaosMDSLite/src/main/webapp/META-INF/context_template.xml $PREFIX/chaosframework/ChaosMDSLite/src/main/webapp/META-INF/context.xml
}

get_pid(){
    local execname=`echo $1 | sed 's/\(.\)/[\1]/'`
    ps -fe |grep -v "$SCRIPTNAME" |grep "$execname" | sed 's/\ \+/\ /g'| cut -d ' ' -f 2|tr '\n' ' '
    
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
	    warn_mesg "process $1 ($p) " "not running"
	fi
    done
}


get_cpu_stat(){
    local cpu=0
    info=`ps -o pcpu $1| tail -1`
    if [[ "$info" =~ ([0-9\.]+) ]]; then 
	cpu=${BASH_REMATCH[1]}
	read -r -a __testinfo__ </tmp/__chaos_test_info__
	__testinfo__[0]=`echo "(${__testinfo__[0]} + $cpu)"|bc`
	((__testinfo__[1]++))
	echo "${__testinfo__[@]}" >/tmp/__chaos_test_info__
	echo "$cpu"
	return 0
    else
	echo "0"
	return 1
    fi
}
get_mem_stat(){
    local mem=0
    info=`ps -o pmem $1| tail -1`
    if [[ "$info" =~ ([0-9\.]+) ]]; then 
	mem=${BASH_REMATCH[1]}
	read -r -a __testinfo__ </tmp/__chaos_test_info__
	__testinfo__[2]=`echo "(${__testinfo__[2]} + $mem)"|bc`
	((__testinfo__[3]++))

	echo "${__testinfo__[@]}" >/tmp/__chaos_test_info__
	echo "$mem"
	return 0
    else
	echo "0"
	return 1
    fi
}
check_proc(){
    local status=0
    proc_list=()
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

	    proc_list+=($p)
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
	warn_mesg "process $1 is running with pid \"$pid\" " "killing"
	stop_proc $1;
    fi
}
run_proc(){
    command_line="$1"
    process_name="$2"
    proc_pid=0
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
	    proc_pid=$p
	    
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

    if  $tools/chaos_services.sh status ; then
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
    local ncutype=0
    local lista_file=$(find_cu_conf)
    local cuname=$5
    local include="$6"
    for l in $lista_file;do
	if [ -z "$include" ];then
	    ((ncutype++))
	else
	    for ll in $include;do
		if [[ $l =~ $ll ]];then
		    ((ncutype++))
		fi
	    done
	fi
    done
    if [ $ncutype -eq 0 ];then
	error_mesg "at least one configuration file must be provided"
	return 1
    fi

    for l in $lista_file;do
	local n=$((ncu/ncutype))
	if [ -z "$include" ];then
	    lista_conf="$lista_conf -i $l -n $n"
	    info_mesg "generating $n CU from " "$l"
	else
	    for ll in $include;do
		if [[ $l =~ $ll ]];then
		    lista_conf="$lista_conf -i $l -n $n"
		    info_mesg "generating $n CU from " "$l"
		fi 
	    done

	   
	fi
    done
    
    local param="$lista_conf -j $nus -o $out"
    if [ -n "$dataserver" ];then
	param="$param -d $dataserver"
    fi

    if [ -n "$cuname" ];then
	param="$param -c $cuname"
    fi


    if [ -n "$lista_conf" ] && $CHAOS_TOOLS/chaos_build_conf.sh $param >& /dev/null;then
	ok_mesg "MDS configuration generated"
	return 0
    else
	nok_mesg "MDS configuration generated"
	return 1
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
    local timeout=10000
    cli_cmd=""
    if [ "$CHAOS_RUNTYPE" == "callgrind" ]; then
	timeout=$((timeout * 10))
    fi
    cli_cmd=`$CHAOS_PREFIX/bin/ChaosCLI --metadata-server=$meta --deviceid $cuname --timeout $timeout $param 2>&1`
   
    if [ $? -eq 0 ]; then
	return 0
    fi
    error_mesg "Error \"$CHAOS_PREFIX/bin/ChaosCLI --metadata-server=$meta --deviceid $cuname $param \" returned:$cli_cmd"
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
    local pid="$4"
    local cnt=0
    local t1=0
    local cpu=0
    local mem=0
    local oldcpu=0
    local oldmem=0

    for ((cnt=0;cnt<$max;cnt++));do

	oldcpu=$cpu
	oldmem=$mem
	cpu=$(get_cpu_stat $pid)
	mem=$(get_mem_stat $pid)
	info_mesg "loop cu test $cnt on CU $cuname, cpu:$cpu% mem:$mem%"
	if [ $cnt -eq 0 ];then
	    oldcpu=$cpu
	    oldmem=$mem
	fi
	cpudiff=$(echo "($cpu - $oldcpu)" |bc)
	memdiff=$(echo "($mem - $oldmem)" |bc)
	if [ $(echo "($cpudiff > 1)"|bc) -gt 0 ];then
	    warn_mesg "cpu occupation \x1B[1m$cpu%\x1B[22m increased respect previous cycle \x1B[1m$oldcpu%\x1B[22m by " "$cpudiff%"
	fi
	if [ $(echo "($memdiff > 0)"|bc) -gt 0 ];then
	    warn_mesg "mem occupation \x1B[1m$mem%\x1B[22m increased respect previous cycle \x1B[1m$oldmem\x1B[22m by " "$memdiff%"
	fi
	if init_cu $meta $cuname;then
	    ok_mesg "- $cnt init $cuname cpu $cpu% mem $mem%"
	else
	    nok_mesg "- $cnt init $cuname"
	    return 1
	fi
	cpu=$(get_cpu_stat $pid)
	mem=$(get_cpu_stat $pid)
	if start_cu $meta $cuname;then
	    ok_mesg "- $cnt start $cuname $cpu% mem $mem%"
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
		    warn_mesg "cu $cuname " "not progressing"
		fi
	    fi
	    t1=$timestamp_cu	    
	else
	    nok_mesg "- $cnt get timestamp $cuname"
	    return 1
	fi
	cpu=$(get_cpu_stat $pid)
	mem=$(get_cpu_stat $pid)
	if stop_cu $meta $cuname;then
	    ok_mesg "- $cnt stop $cuname $cpu% mem $mem%"
	else
	    nok_mesg "- $cnt stop $cuname"
	    return 1
	fi
	cpu=$(get_cpu_stat $pid)
	mem=$(get_cpu_stat $pid)
	if deinit_cu $meta $cuname;then
	    ok_mesg "- $cnt deinit $cuname $cpu% mem $mem%"
	else
	    nok_mesg "- $cnt deinit $cuname"
	    return 1
	fi
    done
    return 0
}

launch_us_cu(){
    local USNAME=UnitServer
    local NUS=2
    local NCU=5
    local META="localhost:5000"
    if [ -n "$1" ];then
	NUS=$1
    fi
    if [ -n "$2" ];then
	NCU=$2
    fi
    if [ -n "$3" ];then
	META="$3"
    fi
    if [ -n "$4" ];then
	USNAME="$4"
    fi
    check_proc_then_kill "$USNAME"
    if [ ! -x $CHAOS_PREFIX/bin/$USNAME ]; then
	nok_mesg "Unit Server $USNAME not found, in $CHAOS_PREFIX/bin/$USNAME"
	exit 1
    fi

    us_proc=()
    info_mesg "launching " "$NUS $USNAME with $NCU CU"

    for ((us=0;us<$NUS;us++));do
	rm $CHAOS_PREFIX/log/$USNAME-$us.log >& /dev/null
	if run_proc "$CHAOS_PREFIX/bin/$USNAME --log-on-file $CHAOS_TEST_DEBUG --log-file $CHAOS_PREFIX/log/$USNAME-$us.log --unit_server_alias TEST_UNIT_$us --metadata-server $META --unit_server_enable true > $CHAOS_PREFIX/log/$USNAME-$us.stdout 2>&1 &" "$USNAME"; then
	    ok_mesg "UnitServer $USNAME \"TEST_UNIT_$us\" ($proc_pid) started"
	    us_proc+=($proc_pid)
	else
	    nok_mesg "UnitServer $USNAME \"TEST_UNIT_$us\" started"
            return 1
	fi
	
	for ((cu=0;cu<$NCU;cu++));do
	    info_mesg "checking for CU TEST_UNIT_$us/TEST_CU_$cu registration"
	    if execute_command_until_ok "grep -o \"TEST_UNIT_$us\/TEST_CU_$cu .\+ successfully registered\" $CHAOS_PREFIX/log/$USNAME-$us.log >& /dev/null" 30; then
		ok_mesg "CU \"TEST_UNIT_$us/TEST_CU_$cu\" registered"
	    else
		nok_mesg "CU \"TEST_UNIT_$us/TEST_CU_$cu\" registered"
		return 1
	    fi
	done
    done
}
start_test(){
    for ((cnt=0;cnt<4;cnt++));do
	if [ -z "$__testinfo__[$cnt]" ];then
	    __testinfo__[$cnt]=0
	fi
    done
    echo "${__testinfo__[@]}" >/tmp/__chaos_test_info__
    __start_test_time__=`date $time_format`

}
end_test(){
    local status=$1
    local desc="--"
    local pcpu="--"
    local pmem="--"
    local __end_test_time__=`date $time_format`
    local __start_test_name__=$SCRIPTNAME
    local __start_test_group__=$(get_abs_dir $SCRIPTTESTPATH)
    local __start_test_group__=`basename $__start_test_group__`
    local exec_time=`echo "scale=3;($__end_test_time__ - $__start_test_time__ )" |bc`
    read -r -a __testinfo__ </tmp/__chaos_test_info__

    if [ ${__testinfo__[1]} -gt 0 ];then
	pcpu=`echo "scale=2;${__testinfo__[0]} / ${__testinfo__[1]}" |bc -l`

    fi
    if [ ${__testinfo__[3]} -gt 0 ];then
	pmem=`echo "scale=2;${__testinfo__[2]} / ${__testinfo__[3]}" |bc -l`

    fi

    if [ -n "$2" ];then
	desc=$2
    fi

    if [ -f "$CHAOS_TEST_REPORT" ];then
	local stat="FAILED"
	if [ $status -eq 0 ];then
	    stat="OK"
	fi
	echo "$__start_test_group__;$SCRIPTNAME;$stat;$exec_time;$pcpu;$pmem;$desc" >> $CHAOS_TEST_REPORT
    fi
    exit $status
}
