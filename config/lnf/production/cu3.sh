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


 if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTF/DAQ;then
     ok_mesg "US BTF/DAQ $!"
     procid+=($!)
     cuid+=("BTF/DAQ")
 else
     nok_mesg "US BTF/DAQ"
     exit 1
 fi

 if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer MEA;then
     ok_mesg "MEA $!"
     procid+=($!)
     cuid+=("MEA")
 else
     nok_mesg "US MEA"
     exit 1
 fi

  # if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer DAFNE/TRXLINE;then
  #     ok_mesg "US DAFNE_TRXLINE $!"
  #     procid+=($!)
  #     cuid+=("DAFNE_TRXLINE")
  # else
  #     nok_mesg "US DAFNE_TRXLINE"
  #     exit 1
  # fi


# # if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer TEST_BIS;then
# #     ok_mesg "US TEST_BIS $!"
# #     procid+=($!)
# #     cuid+=("TEST_BIS")
# # else
# #     nok_mesg "TEST_BIS"
# #     exit 1
# # fi
 if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTF/GLUE;then
     procid+=($!)
     cuid+=("BTF/GLUE")
     ok_mesg "US BTF/GLUE $!"

 else
     nok_mesg "US BTF/GLUE"
     exit 1
 fi


 if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTFSCRAPERS;then
     ok_mesg "US BTFSCRAPERS $!"
     procid+=($!)
     cuid+=("BTFSCRAPERS")
 else
     nok_mesg "BTFSCRAPERS"
     exit 1
 fi

### Benchmark

# if launch_us_cu 1 10 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BENCHMARK_UNIT_2;then
#     ok_mesg "US BENCHMARK_UNIT_2 $!"
#     procid+=($!)
#     cuid+=("BENCHMARK_UNIT_2")
# else
#     nok_mesg "US BENCHMARK_UNIT_2"
#     exit 1
# fi


Info_mesg "monitoring cus"

monitor_processes $procid $cuid
