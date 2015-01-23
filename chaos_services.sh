#!/bin/bash
cmd=$1


CDS_EXEC=ChaosDataService
CDS_CONF=cds.cfg

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

cds_checks(){
    if [ -z "$CHAOS_PREFIX" ]; then
	error_mesg "CHAOS_PREFIX environment variables not set"
	exit 1
    fi

    if [ -x "$CHAOS_PREFIX/bin/$CDS_EXEC" ]; then
	CDS_BIN=$CHAOS_PREFIX/bin/$CDS_EXEC
    else
	error_mesg "$CDS_EXEC binary not found in $CHAOS_PREFIX/bin"
	exit 1
    fi
    
    if [ ! -f "$CHAOS_PREFIX/etc/$CDS_CONF" ]; then
	error_mesg "CDS configuration file \"$CDS_CONF\" not found in $CHAOS_PREFIX/etc/"
	exit 1
    fi

    if ! ps -fe |grep [m]ongod >/dev/null ;then
	error_mesg "mongod not running" ; exit 1
    else
	ok_msg "mongod check"
    fi
    if ! ps -fe |grep [e]pmd >/dev/null ;then
	error_mesg "epmd (couchbase) not running" ; exit 1
    else
	ok_msg "couchbase check"
    fi

}

mds_checks(){
    if [ -z "$MDS_DIR" ]; then
	if [ -z "$CHAOS_BUNDLE" ]; then
	    error_mesg "CHAOS_BUNDLE and MDS_DIR environment variables not set"
	    exit 1
	fi
	MDS_DIR=$CHAOS_BUNDLE/chaosframework/ChaosMDSLite
	
	if [ ! -d "$MDS_DIR" ]; then
	    error_mesg "directory $MDS_DIR not found"
	    exit 1
	fi
	MDS_LOG=$MDS_DIR/mds.log
    fi

    if ! ps -fe |grep [m]ysqld >/dev/null ;then
	error_mesg "mysqld not running" ; exit 1
    else
	ok_msg "mysqld check"
    fi
    
    if ! which mvn > /dev/null ; then
	error_mesg "mvn not found"
	exit 1
    fi
}

get_pid(){
    local execname=`echo $1 | sed 's/\(.\)/[\1]/'`
    ps -fe |grep "$execname" | sed 's/\ \+/\ /g'| cut -d ' ' -f 2

}



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
	ok_mesg "process $1 is running with pid $pid"
	return 0
    fi
    nok_mesg "process $1 is not running"
    return 1
}

check_proc_then_kill(){
    pid=`get_pid "$1"`
    if [ -n "$pid" ]; then
	warn_mesg "process $1 is running with pid $pid, killing"
	stop_proc $1;
    fi
}
run_proc(){
    command_line="$1"
    process_name="$2"
    eval $command_line
    if [ $? -eq 0 ]; then
	pid=`get_pid $process_name`
	if [ $? -eq 0 ]; then
	    ok_mesg "process \e[32m\e[1m$process_name\e[21m\e[39m with pid $pid, started" 
	    return 0
	fi
    fi
    err_mesg "error lunching $process_name"
    exit 1
}
usage(){
    info_mesg "Usage :$0 {start|stop|status|start mds | start cds | stop mds | stop cds}"
}
start_mds(){
    mds_checks;
    info_mesg "starting MDS..."
    check_proc_then_kill "tomcat:run"
    cd "$MDS_DIR"
    run_proc "mvn tomcat:run > $MDS_LOG 2>&1 &" "tomcat:run"
    cd - > /dev/null
}

start_cds(){
    cds_checks
    info_mesg "starting CDS..."
    check_proc_then_kill "$CDS_EXEC"
    run_proc "$CDS_BIN --conf_file $CHAOS_PREFIX/etc/$CDS_CONF &" "$CDS_EXEC"
}
mds_stop()
{    
    info_mesg "stopping MDS..."
    stop_proc "tomcat:run"
}

cds_stop(){
    info_mesg "stopping CDS..."
    stop_proc "$CDS_EXEC"
}
start_all(){
    local status=0
    info_mesg "start all chaos services..."
    start_mds
    status=$((status + $?))
    start_cds
    status=$((status + $?))
    exit $status
}
stop_all(){
    local status=0
    info_mesg "stopping all chaos services..."
    mds_stop
    status=$((status + $?))
    cds_stop
    status=$((status + $?))
    exit $status
}

status(){
    local status=0
    check_proc "mysqld"
    status=$((status + $?))
    check_proc "mongod"
    status=$((status + $?))

    check_proc "epmd"
    status=$((status + $?))

    check_proc "tomcat:run"
    status=$((status + $?))
    check_proc "$CDS_EXEC"
    status=$((status + $?))
    

    exit $status
}
case "$cmd" in
    status)
	status
	exit 0
	;;
    start)
	if [ -z "$2" ]; then
	    start_all
	else
	    case "$2" in
		mds)
		    start_mds
		    exit 0
		    ;;
		cds)
		    start_cds
		    exit 0
		    ;;
		*) 
		    err_mesg "\"$2\" no such service"
		    usage
		    ;;
	    esac
	    
	fi

	;;
    stop)
	if [ -z "$2" ]; then
	    stop_all
	else
	    case "$2" in
		mds)
		    start_mds
		    exit 0
		    ;;
		cds)
		    start_cds
		    exit 0
		    ;;
		*) 
		    err_mesg "\"$2\" no such service"
		    usage
		    ;;
	    esac
	    
	fi
	;;
    *)
	usage
	exit 1
	;;
esac
	


