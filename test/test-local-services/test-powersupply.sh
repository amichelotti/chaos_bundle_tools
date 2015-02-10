#!/bin/bash
source $CHAOS_TOOLS/common_util.sh
USNAME=UnitServer
TESTEXE=powersupply_test
NUS=2
NCU=10
META="localhost:5000"
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
    USNAME="$4"
fi
info_mesg "Test \"$0\" with:" "NUS:$NUS,NCU:$NCU,METADATASERVER:$META"

if launch_us_cu $NUS $NCU $META $USNAME;then
    if ! check_proc $USNAME;then
	error_mesg "$USNAME quitted"
	end_test 1 "$USNAME quitted"
    fi
else
    error_mesg "error launching US"
    end_test 1 "error launching US"
fi

info_mesg "${#us_proc[@]} Unit(s) running correctly " "performing test..."
stop_proc $TESTEXE
for ((us=0;us<$NUS;us++));do
    for ((cu=0;cu<$NCU;cu++));do      
	info_mesg "starting \"TEST_UNIT_$us/TEST_CU_$cu\" powersupply test"
	rm -rf $CHAOS_PREFIX/log/$TESTEXE-$us-$cu.* >/dev/null
	if run_proc "$CHAOS_PREFIX/bin/$TESTEXE --log-on-file --log-file $CHAOS_PREFIX/log/$TESTEXE-$us-$cu.log --metadata-server $META -s TEST_UNIT_$us/TEST_CU_$cu -l 1 > /dev/null 2>&1 &" "$TESTEXE"; then
	    ok_mesg "Test $TESTEXE started on \"TEST_UNIT_$us/TEST_CU_$cu\""
	else
	    nok_mesg "Test $TESTEXE started on \"TEST_UNIT_$us/TEST_CU_$cu\""
	    end_test 1 "Test $TESTEXE starting \"TEST_UNIT_$us/TEST_CU_$cu\""
	fi
    done
done

success=0
errors=0
tot=0
total=$((NUS*NCU))
while ((tot<total));do
    clear
    info_mesg "Test $TESTEXE in progress " "$tot/$total done"
    if ! check_proc $USNAME;then
	error_mesg "Unit Server $USNAME quitted unexpectly"
	end_test 1 "Unit Server $USNAME quitted unexpectly"
    fi
    info_mesg "errors " "$errors/$tot"
    info_mesg "success " "$success/$tot"
    for ((us=0;us<$NUS;us++));do
	for ((cu=0;cu<$NCU;cu++));do
	    if grep -o "Test powersupply OK" $CHAOS_PREFIX/log/$TESTEXE-$us-$cu.log >& /dev/null;then
		((success++))
		((tot++))
		ok_mesg "-$tot $TESTEXE-$us-$cu on \"TEST_UNIT_$us/TEST_CU_$cu\""
		mv $CHAOS_PREFIX/log/$TESTEXE-$us-$cu.log $CHAOS_PREFIX/log/$TESTEXE-$us-$cu.ok.log
	    fi
	    if grep -o "Test powersupply FAILED" $CHAOS_PREFIX/log/$TESTEXE-$us-$cu.log >& /dev/null;then
		((errors++))
		((tot++))
		nok_mesg "-$tot $TESTEXE-$us-$cu on \"TEST_UNIT_$us/TEST_CU_$cu\""
		mv $CHAOS_PREFIX/log/$TESTEXE-$us-$cu.log $CHAOS_PREFIX/log/$TESTEXE-$us-$cu.fail.log
		end_test 1 "-$tot $TESTEXE-$us-$cu on \"TEST_UNIT_$us/TEST_CU_$cu\""
	    fi
	done
    done
    
    if [ $tot -eq $total ];then
	stop_proc $TESTEXE >& /dev/null
	stop_proc $USNAME >& /dev/null
	end_test $errors
    fi

    if ! check_proc $TESTEXE>/dev/null;then
	
	res=$(( ((total-tot)!=0) || (errors!=0) ))
	end_test $res
    fi

    
    # if [ ${#proc_list[@]} -lt $NUS ];then
    # 	error_mesg "Unit Server $USNAME running (${#proc_list[@]}) less than expected ($NUS)"
    # 	end_test 1 "Unit Server $USNAME running (${#proc_list[@]}) less than expected ($NUS)"
    # fi


    
    sleep 5

done
stop_proc $TESTEXE >& /dev/null
stop_proc $USNAME >& /dev/null
end_test $errors
