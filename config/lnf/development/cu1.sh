#!/bin/bash
ulimit -u unlimited
separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

if [ -z "$CHAOS_PREFIX" ];then
    echo "%% NO environment CHAOS_PREFIX defined, setting $prefix_tmp"
    prefix_tmp=$dir/../../../
    export CHAOS_PREFIX=$prefix_tmp
    source $dir/../../common_util.sh
else
    source $CHAOS_PREFIX/tools/common_util.sh
fi






export LD_LIBRARY_PATH=$CHAOS_PREFIX/lib
info_mesg "using prefix " "$CHAOS_PREFIX"
kill_monitor_process

procid=()
cuid=()
for k in LIBERA01 LIBERA02 LIBERA03 LIBERA07 LIBERA08 LIBERA09 LIBERA12 LIBERA13; do
    if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" daqLiberaServer $k;then
	procid+=($!)
	cuid+=($k)
	ok_mesg "daqLiberaServer $k $!"
    else
	nok_mesg "daqLiberaServer $k"
	exit 1
    fi
done

## Transfer line
if launch_us_cu 1 8 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTF/TRXLINE;then
    procid+=($!)
    cuid+=("BTF/TRXLINE")
    ok_mesg "US BTF/TRXLINE $!"

else
    nok_mesg "US BTF/TRXLINE"
    exit 1
fi

## Transfer line
if launch_us_cu 1 4 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTF/CORRECTORS;then
    procid+=($!)
    cuid+=("BTF/CORRECTORS")
    ok_mesg "US BTF/CORRECTORS $!"

else
    nok_mesg "US BTF/CORRECTORS"
    exit 1
fi


## DAQ
if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer DAFNE/IMPORT;then
    ok_mesg "US DAFNE_IMPORT $!"
    procid+=($!)
    cuid+=("DAFNE_IMPORT")
else
    nok_mesg "US DAFNE_IMPORT"
    exit 1
fi

if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" BPMSync ACCUMULATOR/BPM;then
    ok_mesg "US BPMsync $!"
    procid+=($!)
    cuid+=("ACCUMULATOR/BPM")
else
    nok_mesg "US BPMSync"
    exit 1
fi


info_mesg "monitoring cus"

monitor_processes $procid $cuid
