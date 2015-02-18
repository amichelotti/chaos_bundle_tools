#!/bin/sh 

if [ ! -f /etc/default/chaos ];then 
    echo "missing !CHAOS CONFIGURATION FILE /etc/default/chaos"
    exit 1
fi

. /etc/default/chaos

if [ ! -x "$UNITSERVER" ];then
    echo "no binary found \"$UNITSERVER\""
    exit 1
fi
if [ -z "$LOG" ];then
    LOG=/dev/null
fi
if [ -z "$USNAME" ];then
    if cat /sys/class/net/eth0/address >& /dev/null;then
	USNAME=`cat /sys/class/net/eth0/address`
    else
	USNAME=`localhost`
    fi
fi
case "$1" in
start)
	killall -9 $UNITSERVER >& /dev/null
	if $UNITSERVER --metadata-server $METADATASERVER --unit_server_alias $USNAME --unit_server_enable true > $LOG 2>&1 &;then
	    echo "started"
	else
	    echo "## error starting"
	    exit 1
	fi
	;;
stop)
	killall -9 $UNITSERVER 
	;;
esac
