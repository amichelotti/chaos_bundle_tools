#!/bin/bash
## arg metadataserver
## loop

if [ -z $CHAOS_PREFIX ];then
    echo "## you should provide CHAOS_PREFIX environment"
    exit 1
fi

loglevel=""
maxsize=10000
maxthread=8
loop=10000
usage(){
    echo -e "Usage is $0 [-m <metadataserver:port>] [-n dataset name] [-l <maxloop>][ -t <maxthreads> ] [ -s <maxsize> ] [-g: enable log debug]"
}
if [ -z $1 ];then
    echo "## you should provide metadataserver:port"
    exit 1
fi

DATE=`date '+%Y-%m-%d-%H-%M-%S'`
metadata_server="localhost:5000"
dataset_name=PERFORMANCE_IO
exit_status=0
while getopts n:m:hl:t:s:g opt; do
    case $opt in
	m)
	    metadata_server=$OPTARG
	    ;;
	l)
	    loop=$OPTARG
	    ;;
	n)
	    dataset_name=$OPTARG
	    ;;	
	t)
	    maxthread=$OPTARG
	    ;;
	s)
	    maxsize=$OPTARG
	    ;;
	g)
	    loglevel="enabled"
	    ;;
	h)
	    usage
	    exit 0
	    ;;
    esac

done




host=`hostname`
mach=`uname -a`
csvprefix="testDataSetIO-$host-$DATE"

echo "set datafile separator \",\"" > $CHAOS_PREFIX/log/$csvprefix.gnuplot  
#set yrange [1:150000]
echo "#set logscale y 2" >>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  
echo "set logscale x 2" >>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  
echo "set xlabel 'Bytes'" >>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  
echo "set terminal png size 2048,4096 enhanced font 'Verdana,10'" >>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  
echo "set output 'testDataSetIOMulti-$host-$DATE.png'">>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  

echo "set multiplot layout 8,1 title '$DATE:$mach on $metadata_server, loops $loop' font ',14'" >>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  

echo "* starting performace test on $metadata_server loop:$loop"

for i in `seq 1 $maxthread`;
do
    echo "Starting test with $i threads"
    echo "set title '$i threads'">>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  
    echo "plot '$CHAOS_PREFIX/log/$csvprefix-$i.csv' using 2:3 lc rgb \"green\" with lines title 'push rate (cycle/s)','$CHAOS_PREFIX/log/$csvprefix-$i.csv' using 2:4 lc rgb \"cyan\" with lines title 'pull rate (cycle/s)', '$CHAOS_PREFIX/log/$csvprefix-$i.csv' using 2:10 lc rgb \"red\" with lines title  'errors'" >>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  
    if [ -n $loglevel ];then
	$CHAOS_PREFIX/bin/testDataSetIO --dsname $dataset_name --points 0 --pointmax $maxsize --metadata-server $metadata_server --nthread $i --pointincr 2 --loop $loop --report $CHAOS_PREFIX/log/$csvprefix-$i.csv --log-on-file 1 --log-file $CHAOS_PREFIX/log/$csvprefix-$i.log --log-level debug
	exit_status=$?
    else
	$CHAOS_PREFIX/bin/testDataSetIO --dsname $dataset_name --points 0 --pointmax $maxsize --metadata-server $metadata_server --nthread $i --pointincr 2 --loop $loop --report $CHAOS_PREFIX/log/$csvprefix-$i.csv
	exit_status=$?
    fi
#    echo "plot '$csvprefix-$i.csv' using 2:3 lc rgb \"green\" with lines title 'push rate (cycle/s)','$csvprefix-$i.csv' using 2:4 lc rgb \"cyan\" with lines title 'pull rate (cycle/s)','$csvprefix-$i.csv' using 2:8 lc rgb \"pink\" with lines title 'bandwith (MB/s)','$csvprefix-$i.csv' using 2:9 lc rgb \"magenta\" with lines title  'prep overhead(us)', '$csvprefix-$i.csv' using 2:10 lc rgb \"red\" with lines title  'errors'" >>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  
    
    if [ $exit_status -gt 0 ];then
	echo "## test interrupted because of errors"
	exit $exit_status
    fi
    sleep 1
done
echo "unset multiplot">>  $CHAOS_PREFIX/log/$csvprefix.gnuplot  
gnuplot < $CHAOS_PREFIX/log/$csvprefix.gnuplot
echo "exit status $exit_status"
exit $exit_status
