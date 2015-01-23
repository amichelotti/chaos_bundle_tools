#!/bin/sh
cmd=$1

if [ -z "$MDS_DIR" ]; then
    if [ -z "$CHAOS_BUNDLE" ]; then
	echo "## CHAOS_BUNDLE environment not set"
	return 1
    fi
    MDS_DIR=$CHAOS_BUNDLE/chaosframework/ChaosMDSLite

    if [ ! -d "$MDS_DIR" ]; then
	echo "## directory $MDS_DIR not found"
	return 1
    fi
fi

MDS_LOG=$MDS_DIR/mds.log

sanity_checks(){
    if ! ps -fe |grep [m]ysqld >/dev/null ;then
	echo "## mysqld not running" ; exit 1
    fi
    
    if ! which mvn > /dev/null ; then
	echo ## mvn not found"
    fi
}
get_pid(){
   ps -fe |grep "$1" | cut -d ' ' -f 3
}
sanity_checks;

case "$1" in
    start)
	pid=`get_pid "[t]omcat:run"`
	if [ -n "$pid" ]; then
	    echo "%% an instance is already running pid $pid, stop before"
	    return 1
	fi
	cd "$MDS_DIR"
	if mvn tomcat:run > $MDS_LOG 2>&1 &  then
	    pid=`get_pid "[t]omcat:run"`
	    if [ $? -eq 0 ]; then
		echo "* successfully launched pid $pid"
		echo "* log in $MDS_LOG"
		cd - > /dev/null
		exit 0
	    fi
	fi   	
	echo "# error lunching MDS"
	cd - > /dev/null
	;;
    stop)
	pid=`get_pid "[t]omcat:run"`
	if [ -z "$pid" ]; then
	    echo "%% mds not running"
	    return 1
	else
	    echo "* killing pid $pid"
	    kill -9 $pid && exit 0
	fi
	;;
	*)
	echo "Usage :$0 {start|stop}"
	exit 1
	;;
esac
	


