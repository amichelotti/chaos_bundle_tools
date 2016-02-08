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
check_proc_then_kill BPMSync
check_proc_then_kill UnitServer    
procid=()
cuid=()

if launch_us_cu 1 26 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer AULA_TOUSHECK;then
    ok_mesg "US AULA_TOUSHECK $!"
    procid+=($!)
    cuid+=("AULA_TOUSHECK")
else
    nok_mesg "US AULA_TOUSHECK"
    exit 1
fi

if launch_us_cu 1 10 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BENCHMARK_UNIT_1;then
    ok_mesg "US BENCHMARK_UNIT_1 $!"
    procid+=($!)
    cuid+=("BENCHMARK_UNIT_1")
else
    nok_mesg "US BENCHMARK_UNIT_1"
    exit 1
fi

# if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer TEST_BIS;then
#     ok_mesg "US TEST_BIS $!"
#     procid+=($!)
#     cuid+=("TEST_BIS")
# else
#     nok_mesg "TEST_BIS"
#     exit 1
# fi
if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer BTF/GLUE;then
    procid+=($!)
    cuid+=("BTF/GLUE")
    ok_mesg "US BTF/GLUE $!"

else
    nok_mesg "US BTF/GLUE"
    exit 1
fi


if launch_us_cu 1 1 "--conf-file $CHAOS_PREFIX/etc/cu.cfg" UnitServer TEST_MIKE;then
    ok_mesg "US TEST_MIKE $!"
    procid+=($!)
    cuid+=("TEST_MIKE")
else
    nok_mesg "TEST_MIKE"
    exit 1
fi


info_mesg "monitoring cus"

monitor_processes $procid $cuid