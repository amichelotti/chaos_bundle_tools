#!/bin/bash
## arg metadataserver
## loop

if [ -z $1 ];then
    echo "## you should provide metadataserver:port"
    exit 1
fi
if [ -z $CHAOS_PREFIX ];then
    echo "## you should provide CHAOS_PREFIX environment"
    exit 1
fi
loop=10000
if [ -n "$2" ];then
    loop=$2
fi
echo "set datafile separator \",\"" > testioMulti.gnuplot  
#set yrange [1:150000]
echo "#set logscale y 2" >> testioMulti.gnuplot  
echo "set logscale x 2" >> testioMulti.gnuplot  
echo "set xlabel 'Bytes'" >> testioMulti.gnuplot  
echo "set terminal png size 2048,4096 enhanced font 'Verdana,10'" >> testioMulti.gnuplot  
echo "set output 'testDataSetIOMulti.png'">> testioMulti.gnuplot  

echo "set multiplot layout 8,1 title 'Infrastructure Client Test' font ',14'" >> testioMulti.gnuplot  

echo "* starting performace test on $1"
nthreads="1 2 3 4 5 6 7 8"
for i in $nthreads;do
    echo "Starting test with $i threads"
    $CHAOS_PREFIX/bin/testDataSetIO --points 0 --pointmax 10000 --metadata-server $1 --nthread $i --pointincr 2 --loop $loop --report testDataSetIO_$i.csv
    echo "set title '$i threads'">> testioMulti.gnuplot  
#    echo "plot 'testDataSetIO_$i.csv' using 2:3 lc rgb \"green\" with lines title 'push rate (cycle/s)','testDataSetIO_$i.csv' using 2:4 lc rgb \"cyan\" with lines title 'pull rate (cycle/s)','testDataSetIO_$i.csv' using 2:8 lc rgb \"pink\" with lines title 'bandwith (MB/s)','testDataSetIO_$i.csv' using 2:9 lc rgb \"magenta\" with lines title  'prep overhead(us)', 'testDataSetIO_$i.csv' using 2:10 lc rgb \"red\" with lines title  'errors'" >> testioMulti.gnuplot  
    echo "plot 'testDataSetIO_$i.csv' using 2:3 lc rgb \"green\" with lines title 'push rate (cycle/s)','testDataSetIO_$i.csv' using 2:4 lc rgb \"cyan\" with lines title 'pull rate (cycle/s)', 'testDataSetIO_$i.csv' using 2:10 lc rgb \"red\" with lines title  'errors'" >> testioMulti.gnuplot  

    echo "Sleeping 60"
    sleep 60
done
echo "unset multiplot">> testioMulti.gnuplot  
