#!/bin/bash 
### BEGIN INIT INFO
# Provides:          chaos
# Required-Start:    $network $remote_fs $all ssh openvpn
# Required-Stop:     $network $remote_fs $syslog
# Should-Start:      network-manager
# Should-Stop:       network-manager
# X-Start-Before:    $x-display-manager gdm kdm xdm wdm ldm sdm nodm
# X-Interactive:     true
# Default-Start:     5
# Default-Stop:      0 1 6
# Short-Description: chaos services
# Description: This script will start chaos services
### END INIT INFO

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
if ifconfig tun0 >& /dev/null;then
    VPNIP=`ifconfig tun0 |grep -oP 'inet addr:\K\S+'`
fi

if [ -n "$PUBLISHIP" ];then
    EXTRAARGS="--publishing-ip $PUBLISHIP"
else
    if [ -n "$VPNIP" ];then
	EXTRAARGS="--publishing-ip $VPNIP"
    fi
fi
case "$1" in
start)
	cnt=0
	ok=0
	tot=5
	killall -9 $UNITSERVER >& /dev/null
	while (((cnt<tot) && (ok==0)));do
	    echo "checking MDS $METADATASERVER availability trial $cnt/$tot"
	    if ping $METADATASERVER -c 1 >/dev/null;then
		ok=1
	    fi
	    ((cnt++))
	done
	CMD="$UNITSERVER --metadata-server $METADATASERVER:5000 --unit_server_alias $USNAME --unit_server_enable true --log-on-console $EXTRAARGS > $UNITSERVER_LOG 2>&1 &"
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
status)
	var=`echo $UNITSERVER | sed 's/\(.\)/[\1]/'`
	pid=`ps -fe |grep $var`
	[ -n "$pid" ]
	;;
run)
	$UNITSERVER --metadata-server $METADATASERVER --unit_server_alias $USNAME --unit_server_enable true --log-on-console $EXTRAARGS > $UNITSERVER_LOG 2>&1
	;;

esac
