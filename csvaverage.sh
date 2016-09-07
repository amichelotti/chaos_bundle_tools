#!/bin/bash

ncsv=$#

if [ $ncsv -le 0 ];then
    echo "## error you must provide at least a CSV"
    exit 1
fi

csv=($@)

nelems=`head -1 $1| grep -o "," | wc -l`
#((nelems++))
lines=`cat $1 | wc -l`

# echo "* there are $ncsv and $nelems"
head -1 $1 > average.csv
for row in `seq 2 $lines`;do
    for col in `seq 0 $nelems`;do
	val[$col]="0"
    done
    for cs in `seq 0 $((ncsv-1))`;do
	line=`head -$row ${csv[$cs]} |tail -1`
#	echo "${csv[$cs]} -> line $line"
	for col in `seq 0 $nelems`;do
	    v=`echo $line|cut -d ',' -f $((col+1))| sed -e 's/[eE]+*/\\*10\\^/'`
#	    echo "$col -> $v + ${val[$col]}"
	    val[$col]=`echo "$v + ${val[$col]}" | bc`
	done
    done
    line=""
    for col in `seq 0 $nelems`;do
	v=`echo "scale=3; ${val[$col]}/($ncsv)" | bc -l|sed s/\.000//g`
	if [ $col -eq "0" ];then
	    line="$v" 
	else
	    line="$line,$v" 
	fi

    done
    echo "$line" |sed 's/,\./,0\./g' >> average.csv
done
