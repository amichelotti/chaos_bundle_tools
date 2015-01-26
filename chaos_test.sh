#!/bin/bash
cmd=$1
scriptdir=`dirname $0`
source $scriptdir/common_util.sh
scriptdir=$(get_abs_dir $0)
testdir=$scriptdir/test
testlists=()
test_found=0
report_file="/dev/null"
stop_on_error=""
usage(){
    echo -e "Usage :$0 [-t <testlist0> .. -t <testlistN>] [-d <directory of testlists> [$testdir]] [-r csv report_file] [-k]\n-t <testlist>: choose a particular testlist\n-d <dir>: execute all the testlist in a given directory\n-r <report>:create a CSV file with test summary\n-s:stop on error\n"
}
while getopts t:d:r:k opt; do
    case $opt in
	t) 
	if [ -f "$OPTARG" ]; then
	    error_mesg "test list $OPTARG not found"
	    exit 1
	fi
	testlists+=($OPTARG)
	;;
	k)
	    stop_on_error="true"
	    ;;
	r)
	    report_file=$OPTARG
	    echo "test group;test name; status; exec time" > $report_file
	    ;;
	d)
	    if [ -d "$OPTARG" ]; then
		testdir=$OPTARG
	    else
		error_mesg "invalid directory $OPTARG"
		exit 1
	    fi
	    ;;
	*)
	    usage
	    ;;
    esac
done

if [ ${#testlist[@]} -eq 0 ]; then
    if [ ! -d "$testdir" ]; then
	error_mesg "invalid test directory $testdir"
	exit 1
    fi
    lists=`ls $testdir/test_list_*.txt |sort -n`
    for test in $lists; do
	testlist+=($test)
    done
fi

export CHAOS_TOOLS=$scriptdir
test_prefix;

final_test_list=()
for test in ${testlist[@]}; do
   basedir=`dirname $test`
   testdirs=`cat $test | cut -d ' ' -f 1`
   for test_test in $testdirs; do
       test_full_dir=$basedir/$test_test
       if [ ! -d "$test_full_dir" ]; then
	   error_mesg "test dir \"$test_full_dir\" specified in \"$test\" not found"
	   exit 1
       else
	   list=`ls $test_full_dir/test*.sh 2>/dev/null |sort -n`
	   for l in $list;do
	       if [ ! -x "$l" ];then
		   warn_mesg "test $l is not executable please change execution bit"
	       else
		   final_test_list+=($l)
		   ((test_found++))
	       fi
	   done
       fi
   done
done

info_mesg "found $test_found test(s).."
error_list=()
ok_list=()
status=0
for test in ${final_test_list[@]};do
    info_mesg "starting test $test ..."
    group_test=`dirname $test`
    group_test=`basename $group_test`
    start_time=`date $time_format`
    out=`$test`
    res=$?
    status=$(($status + $res))
    end_time=`date $time_format`
    exec_time=$( echo "$end_time - $start_time"|bc)
    if [ $res -eq 0 ]; then
	ok_list+=("$test")
	ok_mesg "test $test ($exec_time s)"
	echo "$group_test;$test;OK;$exec_time" >> $report_file
    else
	error_list+=("$test")
	nok_mesg "test $test ($exec_time s)"
	echo "$group_test;$test;NOK;$exec_time" >> $report_file
	if [ -n "$stop_on_error" ];then
	    exit 1
	fi
    fi
done
return $status

