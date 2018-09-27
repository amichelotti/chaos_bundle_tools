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
    echo -e "Usage is $0 [-m <metadataserver:port>] [-l <maxloop>][ -t <maxthreads> ] [ -s <maxsize> ] [-g: enable log debug]"
}
if [ -z $1 ];then
    echo "## you should provide metadataserver:port"
    exit 1
fi


metadata_server="localhost:5000"
while getopts m:hl:t:s:g opt; do
    case $opt in
	m)
	    metadata_server=$OPTARG
	    ;;
	l)
	    loop=$OPTARG
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
echo "set datafile separator \",\"" > testioMulti.gnuplot  
#set yrange [1:150000]
echo "#set logscale y 2" >> testioMulti.gnuplot  
echo "set logscale x 2" >> testioMulti.gnuplot  
echo "set xlabel 'Bytes'" >> testioMulti.gnuplot  
echo "set terminal png size 2048,4096 enhanced font 'Verdana,10'" >> testioMulti.gnuplot  
echo "set output 'testDataSetIOMulti-$host.png'">> testioMulti.gnuplot  
mach=`uname -a`

echo "set multiplot layout 8,1 title '$mach on $metadata_server, loops $loop' font ',14'" >> testioMulti.gnuplot  

echo "* starting performace test on $metadata_server loop:$loop"
for i in `seq 1 $maxthread`;
do
    echo "Starting test with $i threads"
    echo "set title '$i threads'">> testioMulti.gnuplot  
    echo "plot 'testDataSetIO-$host-$i.csv' using 2:3 lc rgb \"green\" with lines title 'push rate (cycle/s)','testDataSetIO-$host-$i.csv' using 2:4 lc rgb \"cyan\" with lines title 'pull rate (cycle/s)', 'testDataSetIO-$host-$i.csv' using 2:10 lc rgb \"red\" with lines title  'errors'" >> testioMulti.gnuplot  
    if [ -n $loglevel ];then
	$CHAOS_PREFIX/bin/testDataSetIO --points 0 --pointmax $maxsize --metadata-server $metadata_server --nthread $i --pointincr 2 --loop $loop --report testDataSetIO-$host-$i.csv --log-on-file --log-file testDataSetIO-$host-$i.log --log-level debug
    else
	$CHAOS_PREFIX/bin/testDataSetIO --points 0 --pointmax $maxsize --metadata-server $metadata_server --nthread $i --pointincr 2 --loop $loop --report testDataSetIO-$host-$i.csv 
    fi
#    echo "plot 'testDataSetIO-$host-$i.csv' using 2:3 lc rgb \"green\" with lines title 'push rate (cycle/s)','testDataSetIO-$host-$i.csv' using 2:4 lc rgb \"cyan\" with lines title 'pull rate (cycle/s)','testDataSetIO-$host-$i.csv' using 2:8 lc rgb \"pink\" with lines title 'bandwith (MB/s)','testDataSetIO-$host-$i.csv' using 2:9 lc rgb \"magenta\" with lines title  'prep overhead(us)', 'testDataSetIO-$host-$i.csv' using 2:10 lc rgb \"red\" with lines title  'errors'" >> testioMulti.gnuplot  
    

    sleep 1
done
echo "unset multiplot">> testioMulti.gnuplot  
