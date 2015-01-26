tools=$CHAOS_BUNDLE/tools
OS=`uname -s`
ARCH=`uname -m`

info_mesg(){
    echo -e "* \e[1m$1\e[22m"
}
error_mesg(){
    echo -e "# \e[31m\e[1m$1\e[22m\e[39m"
}
warn_mesg(){
    echo -e "% \e[33m\e[1m$1\e[22m\e[39m"
}

ok_mesg(){
    echo -e "* $1 \e[32m\e[1mOK\e[22m\e[39m"
}
nok_mesg(){
    echo -e "* $1 \e[31m\e[1mNOK\e[22m\e[39m"
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
check_proc(){
    pid=`get_pid "$1"`
    if [ -n "$pid" ]; then
	ok_mesg "process $1 is running with pid \"$pid\""
	return 0
    fi
    nok_mesg "process $1 is not running"
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



