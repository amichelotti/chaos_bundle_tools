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

 if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer DAFNE/IMPORT;then
     ok_mesg "US DAFNE_IMPORT $!"
     procid+=($!)
     cuid+=("DAFNE_IMPORT")
 else
     nok_mesg "US DAFNE_IMPORT"
     exit 1
 fi

# ## Transfer line
#  if launch_us_cu 1 8 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTF/TRXLINE;then
#      procid+=($!)
#      cuid+=("BTF/TRXLINE")
#      ok_mesg "US BTF/TRXLINE $!"

#  else
#      nok_mesg "US BTF/TRXLINE"
#      exit 1
#  fi

# # ## Transfer line
#  if launch_us_cu 1 4 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTF/CORRECTORS;then
#      procid+=($!)
#      cuid+=("BTF/CORRECTORS")
#      ok_mesg "US BTF/CORRECTORS $!"

#  else
#      nok_mesg "US BTF/CORRECTORS"
#      exit 1
#  fi


## BENCHMARK
# if launch_us_cu 1 10 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BENCHMARK_UNIT_0;then
#     ok_mesg "US Benchmark Unit $!"
#     procid+=($!)
#     cuid+=("BENCHMARK_UNIT_0")
# else
#     nok_mesg "BENCHMARK_UNIT_0"
#     exit 1
# fi

## DAQ


info_mesg "monitoring cus"

monitor_processes $procid $cuid
