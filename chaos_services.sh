#!/bin/bash
cmd=$1
scriptdir=`dirname $0`
source $scriptdir/common_util.sh

CDS_EXEC=ChaosDataService
CDS_CONF=cds.cfg

UI_EXEC=CUIserver
US_EXEC=UnitServer
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
	ok_mesg "mongod check"
    fi
    if ! ps -fe |grep [e]pmd >/dev/null ;then
	error_mesg "epmd (couchbase) not running" ; exit 1
    else
	ok_mesg "couchbase check"
    fi

}

mds_checks(){
    if [ -z "$MDS_DIR" ]; then
	if [ -z "$CHAOS_BUNDLE" ]; then
	    error_mesg "CHAOS_BUNDLE and MDS_DIR environment variables not set, please set one of them"
	    exit 1
	fi
	MDS_DIR=$CHAOS_BUNDLE/chaosframework/ChaosMDSLite
	
	if [ ! -d "$MDS_DIR" ]; then
	    error_mesg "directory $MDS_DIR not found"
	    exit 1
	fi
	MDS_LOG=$CHAOS_PREFIX/log/mds.log
    fi

    if ! ps -fe |grep [m]ysqld >/dev/null ;then
	error_mesg "mysqld not running" ; exit 1
    else
	ok_mesg "mysqld check"
    fi
    
    if ! which mvn > /dev/null ; then
	error_mesg "mvn not found"
	exit 1
    fi
}


usage(){
    info_mesg "Usage :$0 {start|stop|status|start mds | start uis| start cds | stop uis|stop mds | stop cds}"
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
    run_proc "$CDS_BIN --conf_file $CHAOS_PREFIX/etc/$CDS_CONF > $CHAOS_PREFIX/log/$CDS_EXEC.std.out 2>&1 &" "$CDS_EXEC"
}
start_ui(){
    
    info_mesg "starting UI Server..."
    check_proc_then_kill "$UI_EXEC"
    run_proc "$CHAOS_PREFIX/bin/$UI_EXEC --server_port 8081 > $CHAOS_PREFIX/log/$UI_EXEC.std.out 2>&1 &" "$UI_EXEC"
}

ui_stop()
{    
    info_mesg "stopping UI Server..."
    stop_proc "$UI_EXEC"
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
    start_ui
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
    ui_stop
    status=$((status + $?))
    if [ -n "$(get_pid $US_EXEC)" ];then
	stop_proc "$US_EXEC"
	status=$((status + $?))
    fi

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
    check_proc "$UI_EXEC"
    status=$((status + $?))

    if [ -n "$(get_pid $US_EXEC)" ];then
	check_proc "$US_EXEC"
    fi

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
	       uis)
		    start_ui
		    exit 0
		    ;;
		*) 
		    error_mesg "\"$2\" no such service"
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
		    mds_stop
		    exit 0
		    ;;
		cds)
		    cds_stop
		    exit 0
		    ;;
		uis)
		    ui_stop
		    exit 0
		    ;;
		*) 
		    error_mesg "\"$2\" no such service"
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
	


