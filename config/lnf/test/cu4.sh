#!/bin/bash
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


 #if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTFSCRAPERS;then
 #    ok_mesg "US BTFSCRAPERS $!"
 #    procid+=($!)
 #    cuid+=("BTFSCRAPERS")
 #else
 #    nok_mesg "BTFSCRAPERS"
 #    exit 1
 #fi


info_mesg "monitoring cus"

monitor_processes $procid $cuid
