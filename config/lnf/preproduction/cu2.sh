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



 if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer ACCUMULATOR/BPM;then
     ok_mesg "US BPMsync $!"
     procid+=($!)
     cuid+=("ACCUMULATOR/BPM")
 else
     nok_mesg "US BPMSync"
     exit 1
 fi



# ## BENCHMARK
# if launch_us_cu 1 10 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BENCHMARK_UNIT_1;then
#     ok_mesg "US Benchmark Unit $!"
#     procid+=($!)
#     cuid+=("BENCHMARK_UNIT_1")
# else
#     nok_mesg "BENCHMARK_UNIT_1"
#     exit 1
# fi


info_mesg "monitoring cus"
monitor_processes $procid $cuid
