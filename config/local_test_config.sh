#!/bin/bash

separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

source $dir/../common_util.sh

mds="localhost:5000"

Usage(){
    echo "$0 <MDS configuration file> [mds:port [localhost:5000]]"
}
if [ ! -f "$1" ]; then
    nok_mesg "you should provide a valid MDS configuration file"
    Usage
    exit 1
fi

if [ -n "$2" ];then
    mds="$2"
fi
info_mesg "metadata server " "$mds"
if [ -z "$CHAOS_PREFIX" ];then
    echo "## NO environment CHAOS_PREFIX defined"
    exit 1
fi
export LD_LIBRARY_PATH=$CHAOS_PREFIX/lib
info_mesg "initializing MDS with configuration " "$1"

if [[ "$mds" =~ "localhost:5000" ]];then
    chaos_services.sh stop
    info_mesg "starting local mds"
    if chaos_services.sh start mds;then
	ok_mesg "starting mds "
    else
	error_mesg "starting mds "
    fi
    if chaos_services.sh start cds;then
	ok_mesg "starting cds "
    else
	error_mesg "starting cds "
    fi
    if chaos_services.sh start uis;then
	ok_mesg "starting ui server "
    else
	error_mesg "starting ui server "
    fi

fi
if $CHAOS_PREFIX/bin/ChaosMDSCmd --mds-conf "$1" --metadata-server $mds;then
    ok_mesg "initilization"
else
    error_mesg "initilization"
    exit 2
fi
check_proc_then_kill daqLiberaServer
check_proc_then_kill BPMSync
for k in LIBERA01 LIBERA02 LIBERA03 LIBERA07 LIBERA08 LIBERA09; do
    if launch_us_cu 1 2 $mds daqLiberaServer $k;then
	ok_mesg "US $k"
    else
	nok_mesg "US $k"
	exit 1
    fi
done
if launch_us_cu 1 1 $mds BPMSync ACCUMULATOR/BPM;then
    ok_mesg "US BPMsync"
else
    nok_mesg "US BPMSync"
    exit 1
fi

if launch_us_cu 1 1 $mds BPMSync ACCUMULATOR/BPM;then
    ok_mesg "US BPMsync"
else
    nok_mesg "US BPMSync"
    exit 1
fi


