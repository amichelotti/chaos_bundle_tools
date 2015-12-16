#!/bin/bash
ulimit -u unlimited
separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

prefix_tmp=$dir/../../../
source $dir/../../common_util.sh


if [ -z "$CHAOS_PREFIX" ];then
    echo "%% NO environment CHAOS_PREFIX defined, setting $prefix_tmp"
    export CHAOS_PREFIX=$prefix_tmp
fi

export LD_LIBRARY_PATH=$CHAOS_PREFIX/lib
info_mesg "using prefix " "$CHAOS_PREFIX"
check_proc_then_kill daqLiberaServer
check_proc_then_kill UnitServer    
procid=()
cuid=()
for k in LIBERA01 LIBERA02 LIBERA03 LIBERA07 LIBERA08 LIBERA09 LIBERA12 LIBERA13; do
    if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" daqLiberaServer $k;then
	ok_mesg "daqLiberaServer $k $!"
	procid+=($!)
	cuid+=($k)
    else
	nok_mesg "daqLiberaServer $k"
	exit 1
    fi
done


if launch_us_cu 1 8 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTF;then
    ok_mesg "US BTF $!"
    procid+=($!)
    cuid+=("BTF")
else
    nok_mesg "US BTF"
    exit 1
fi

info_mesg "monitoring cus"

while true ;do
    cnt=0
    for i in ${procid[@]};do
	info_mesg "monitoring " "${cuid[$cnt]}"
	if ! check_proc $i; then
	    nok_mesg "process $i [ ${cuid[$cnt]} ]"
	    info_mesg "exiting..."
	    exit 1
	fi
	((cnt++))
    done
    sleep 60
done
