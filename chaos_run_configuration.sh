#!/bin/bash
scriptdir=`dirname $0`
source $scriptdir/common_util.sh
scriptdir=$(get_abs_parent_dir $0)
Usage(){
    echo "$0 <test configuration directory>"
}

confdir="$1"
if [ ! -d "$confdir" ]; then
    error_mesg "you must provide a valid configuration directory"
    Usage
    exit -1
fi
if [ -z "$CHAOS_PREFIX" ];then
    error_mesg "missing CHAOS_PREFIX environment, probably you miss source the appropiate source chaos_env.sh"
    exit -3
fi

if [ ! -f "$confdir/MDSConfig.txt" ]; then
    error_mesg "missing MDS configuration file \"$confdir/MDSConfig.txt\""
    exit -2
fi
echo "$confdir/cu*.sh"
cuscripts=`ls $confdir/cu*.sh`
if [ -z "$cuscripts" ];then
    info_mesg "nothing to do $cuscripts" "exit"
    exit 0
fi
if ChaosMDSCmd -r 1 --mds-conf "$confdir/MDSConfig.txt" >& /dev/null; then
    ok_mesg "Transfer test configuration \"$confdir/MDSConfig.txt\" to MDS"
else
    nok_mesg "Transfer test configuration \"$confdir/MDSConfig.txt\" to MDS"
    exit -5
fi
for cu in $cuscripts;do
    n=`basename $cu`
    log=`echo $n|sed s/\.sh$/\.log/`
    command="$cu >& $log &"
    eval $command
    procid+=($!)
    cuid+=($cu)
    info_mesg "starting $cu id " "$!"
done

monitor_processes $procid $cuid

