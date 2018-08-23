source $CHAOS_TOOLS/common_util.sh
start_test
### <> 1 1 localhost:5000 524288 UnitServer BENCHMARK_UNIT_0
USNAME=UnitServer
NUS=5
NCU=10
META="localhost:5000"
MAXBUFFER=262144
if [ -n "$1" ];then
    NUS=$1
fi
if [ -n "$2" ];then
    NCU=$2
fi
if [ -n "$3" ];then
    META="$3"
fi
if [ -n "$4" ];then
    MAXBUFFER="$4"
fi

if [ -n "$5" ];then
    USNAME="$5"
fi
US_TEST=BENCHMARK_UNIT_0


info_mesg "Test \"$0\" with:" "NUS:$NUS,NCU:$NCU,METADATASERVER:$META"
ADDITIONAL_FLAGS=""
if [ -z $CHAOS_EXTERNAL_MDS ];then 
    if ! check_proc mds;then
	nok_mesg "MDS is unexpectly dead!!"
	end_test 1 "MDS is unexpectly dead!!"
    fi
fi

if launch_us_cu 1 1 "--metadata-server $META $ADDITIONAL_FLAGS" $USNAME $US_TEST 1;then
    if ! check_proc $USNAME;then
	error_mesg "$USNAME quitted"
	end_test 1 "$USNAME quitted"
    fi
else
    
    error_mesg "registration failed"
    stop_proc $USNAME
    end_test 1 "registration failed"
fi

sched=1000
# for ((sched=10000;sched>=0;sched-=1000));do
rm -f $CHAOS_PREFIX/log/*.csv
rm -f $CHAOS_PREFIX/log/*.png
nerr=0
info_mesg "waiting 20s ..."
sleep 20
if [ -z $CHAOS_EXTERNAL_MDS ];then 
    if ! check_proc mds;then
	nok_mesg "MDS is unexpectly dead!!"
	end_test 1 "MDS is unexpectly dead!!"
    fi
fi


while ((sched>0));do
    info_mesg "${#us_proc[@]} Unit(s) running correctly " "performing bandwidth test sched $sched us"
    cmd="$CHAOS_PREFIX/bin/MessClient --max $MAXBUFFER --mess_device_id $US_TEST/TEST_CU_0 --log-on-file --log-file $CHAOS_PREFIX/log/MessClient-$sched.$MYPID.log $CHAOS_OVERALL_OPT --scheduler_delay $sched --bandwidth_test --test_repetition 1000 --report $CHAOS_PREFIX/log/report-$US_TEST-bd-$sched >& $CHAOS_PREFIX/log/MessClient-$US_TEST-$sched.$MYPID.stdout" 
    if run_proc "$cmd" "MessClient";then
	    ok_mesg "MessClient process with $sched"
    else
	((nerr+=1))
	nok_mesg "MessClient process with $sched"
    fi
	if which gnuplot >& /dev/null ;then
	    info_mesg "generating benchmark plots..."
	    pushd $CHAOS_PREFIX/log > /dev/null
	    cat  $CHAOS_PREFIX/etc/benchmark.gnuplot | sed s/__report_bp__/"report-$US_TEST-bd-$sched"_bandwidth_test\.csv/g > benchmark.gnuplot

	    if gnuplot < ./benchmark.gnuplot ;then
		info_mesg "generated " " $CHAOS_PREFIX/log/bandwidth_report-$US_TEST-bd-$sched""_bandwidth_test.csv.png"
	    fi
	    popd > /dev/null
	fi
	
	if ! check_proc $USNAME;then
	    nok_mesg "$USNAME is unexpectly dead!!"
	    end_test 1 "$USNAME is unexpectly dead!!"
	fi

	if [ -z $CHAOS_EXTERNAL_MDS ];then 
	    if ! check_proc mds;then
		nok_mesg "MDS is unexpectly dead!!"
		end_test 1 "MDS is unexpectly dead!!"
	    fi
	fi

	if((sched<=1000));then
	    ((sched-=200))
	    if((sched==0));then
		sched=1
	    fi
	else
	    ((sched-=1000))
	fi
done
pushd $CHAOS_PREFIX/log > /dev/null
cat /proc/cpuinfo /proc/meminfo > benchmark-`hostname`-info.txt
tar cfz benchmark-`hostname`.tar.gz benchmark-`hostname`-info.txt *.csv
$CHAOS_PREFIX/tools/images2html.sh . Benchmark > benchmark.hmtl
popd >& /dev/null

# for ((us=0;us<$NUS;us++));do
#     for ((cu=0;cu<$NCU;cu++));do

# 	if run_proc "$CHAOS_PREFIX/bin/MessClient --max_buffer $MAXBUFFER --mess_device_id TEST_UNIT_$us/TEST_CU_$cu --log-on-file --log-file $CHAOS_PREFIX/log/MessClient-$NUS-$NCU-$us-$cu.log --bandwidth_test --report $CHAOS_PREFIX/log/report-$NUS-$NCU-$us-$cu > $CHAOS_PREFIX/log/MessClient-$NUS-$NCU-$us-$cu.stdout 2>&1 &" "MessClient" ;then
# 	    MESSPID=$proc_pid
# 	    ok_mesg "MessClient process created with pid $MESSPID"
# 	else
# 	    nok_mesg "MessClient process creation"
# 	    end_test 1 "MessClient process creation"
# 	fi
# 	if execute_command_until_ok "grep -o \"Wrote\" $CHAOS_PREFIX/log/MessClient-$NUS-$NCU-$us-$cu.log >& /dev/null" 600; then
# 	    ok_mesg "test TEST_UNIT_$us/TEST_CU_$cu "
# 	    if [ -x /usr/bin/gnuplot ];then
# 		info_mesg "generating benchmark plots..."
# 		pushd $CHAOS_PREFIX/log > /dev/null
# 		cat  $CHAOS_PREFIX/etc/chaos-mess/benchmark.gnuplot | sed s/__report_bp__/"report-$NUS-$NCU-$us-$cu"_bandwidth_test\.csv/g > benchmark.gnuplot
# 		chmod a+x benchmark.gnuplot
# 		if ./benchmark.gnuplot ;then
# 		    info_mesg "generated " " $CHAOS_PREFIX/log/bandwidth_report-$NUS-$NCU-$us-$cu.png"
# 		fi
# 		popd > /dev/null
# 	    fi
# 	else
# 	    nok_mesg "test TEST_UNIT_$us/TEST_CU_$cu "
# 	    return 1

# 	fi

#     done
# done

stop_proc $USNAME

end_test $nerr

