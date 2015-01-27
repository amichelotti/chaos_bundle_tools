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
	echo -e "* \e[1m$1\e[22m"
    else
	echo -e "* \e[1m$1\e[32m$2\e[39m\e[22m"
    fi
}
error_mesg(){
    if [ -z "$2" ]; then
	echo -e "# \e[31m\e[1m$1\e[22m\e[39m"
    else
	echo -e "# \e[1m$1\e[31m$2\e[39m\e[22m"
    fi
}

warn_mesg(){
    if [ -z "$2" ]; then
	echo -e "% \e[33m\e[1m$1\e[22m\e[39m"
    else
	echo -e "# \e[1m$1\e[33m$2\e[39m\e[22m"
    fi
}

ok_mesg(){
    echo -e "* $1 \e[32m\e[1mOK\e[22m\e[39m"
}
nok_mesg(){
    echo -e "* $1 \e[31m\e[1mNOK\e[22m\e[39m"
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
    ps -fe |grep "$execname" | sed 's/\ \+/\ /g'| cut -d ' ' -f 2
    
}
time_format="+%s.%N"
if [ "$OS" == "Darwin" ]; then
    time_format="+%s"
fi

stop_proc(){
    pid=`get_pid "$1"`
    if [ -n "$pid" ]; then
	if ! kill -9 $pid ; then
	    error_mesg "cannot kill process $pid"
	    exit 1
	else
	    ok_mesg "process $1 killed"
	fi
	
    else
	warn_mesg "process $1 not running"
    fi
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
    pid=`get_pid "$1"`
    if [ -n "$pid" ]; then

	cpu=$(get_cpu_stat $pid)
	mem=$(get_mem_stat $pid)
	if [ $(echo "($cpu - 50)>0" | bc) -gt 0 ]; then
	    cpu="\e[31m$cpu%\e[39m"
	else
	    cpu="\e[1m$cpu%\e[22m"
	fi
	if [ $(echo "($mem - 50)>0" |bc) -gt 0 ]; then
	    mem="\e[31m$mem%\e[39m"
	else
	    mem="\e[1m$mem%\e[22m"
	fi

	ok_mesg "process \e[1m$1\e[22m is running with pid \e[1m$pid\e[22m cpu $cpu, mem $mem"
	return 0
    fi
    nok_mesg "process \e[1m$1\e[22m is not running"
    return 1
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
    eval $command_line
    if [ $? -eq 0 ]; then
	sleep 1
	pid=`get_pid $process_name`
	if [ $? -eq 0 ] && [ -n "$pid" ]; then
	    ok_mesg "process \e[32m\e[1m$process_name\e[21m\e[39m with pid \"$pid\", started" 
	    return 0
	else
	    nok_mesg "process $process_name quitted unexpectly "
	    exit 1
	fi
    else
	error_mesg "error lunching $process_name"
	exit 1
    fi

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
    local lista_conf=""

    for l in $(find_cu_conf);do
	lista_conf="-i $l -n $ncu "
    done
    local param="$lista_conf -j $nus -o $out"
    
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

