#!/bin/bash 

if [ ! -f /etc/default/chaos ];then 
    echo "missing !CHAOS CONFIGURATION FILE /etc/default/chaos"
    exit 1
fi

. /etc/default/chaos

if [ -z "$UNITSERVER" ];then
    UNITSERVER=/usr/bin/UnitServer
fi

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

EXTRAARGS=""
VPNIP=`ifconfig tun0 |grep -oP 'inet addr:\K\S+'`

if [ -n "$PUBLISHIP" ];then
    EXTRAARGS="--publishing-ip $PUBLISHIP"
else
    if [ -n "$VPNIP" ];then
	EXTRAARGS="--publishing-ip $VPNIP"
    fi
fi
case "$1" in
start)
	killall -9 $UNITSERVER >& /dev/null
	CMD="$UNITSERVER --metadata-server $METADATASERVER --unit_server_alias $USNAME --unit_server_enable true --log-on-console $EXTRAARGS > $UNITSERVER_LOG 2>&1 &"
	if eval $CMD;then
	    echo "started ..."

	else
	    echo "## error starting"
	    exit 1
	fi
	;;
stop)
	killall -9 $UNITSERVER 
	;;
esac
