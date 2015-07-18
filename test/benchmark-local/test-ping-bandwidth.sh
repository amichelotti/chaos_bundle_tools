source $CHAOS_TOOLS/common_util.sh
start_test
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


info_mesg "Test \"$0\" with:" "NUS:$NUS,NCU:$NCU,METADATASERVER:$META"


if launch_us_cu $NUS $NCU $META $USNAME;then
    if ! check_proc $USNAME;then
	error_mesg "$USNAME quitted"
	end_test 1 "$USNAME quitted"
    fi
else
    	error_mesg "registration failed"
	stop_proc $USNAME
	end_test 1 "registration failed"
fi

sched=5000
# for ((sched=10000;sched>=0;sched-=1000));do
while ((sched>=0));do
info_mesg "${#us_proc[@]} Unit(s) running correctly " "performing bandwidth test sched $sched us"
	if $CHAOS_PREFIX/bin/MessClient --max $MAXBUFFER --mess_device_id TEST_UNIT_0/TEST_CU_0 --log-on-file --log-file $CHAOS_PREFIX/log/MessClient-$sched.log --scheduler_delay $sched --bandwidth_test --test_repetition 1000 --report $CHAOS_PREFIX/log/report-bd-$sched > $CHAOS_PREFIX/log/MessClient-$sched.stdout 2>&1 ;then
	    if [ -x /usr/bin/gnuplot ];then
		info_mesg "generating benchmark plots..."
		pushd $CHAOS_PREFIX/log > /dev/null
		cat  $CHAOS_PREFIX/etc/chaos-mess/benchmark.gnuplot | sed s/__report_bp__/"report-bd-$sched"_bandwidth_test\.csv/g > benchmark.gnuplot
		chmod a+x benchmark.gnuplot
		if ./benchmark.gnuplot >& /dev/null ;then
		    info_mesg "generated " " $CHAOS_PREFIX/log/bandwidth_report-bd-$sched""_bandwidth_test.csv.png"
		fi
		popd > /dev/null
	    fi

	else
	    nok_mesg "MessClient process with $sched"
	fi
	sleep 1
	if ! check_proc ChaosDataService;then
	    nok_mesg "Chaos DataService is unexpectly dead!!"
	    end_test 1 "Chaos DataService is unexpectly dead!!"
	fi
	if((sched<=1000));then
	    ((sched-=200))
	else
	    ((sched-=1000))
	fi
done
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

end_test 0
