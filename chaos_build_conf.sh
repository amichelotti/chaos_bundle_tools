#!/bin/bash
if [ -f "$1" ]; then
    confile=$1
else
    echo "## cannot open $1"
    exit 1
fi

randoms=()
variables=`cat $confile | grep -o '\$r[0-9]*'|sort -n |uniq`
expressions=`cat $confile | grep -o '\$r[0-9]*([0-9\.,]*)'`


for r in $variables;do
rand=$RANDOM
if [[ "$r" =~ r([0-9]+) ]]; then
    randoms[${BASH_REMATCH[1]}]=$rand;
#    echo "r${BASH_REMATCH[1]}=$rand"
fi
#randoms+=($rand)
done
expression_value=()
replace=""
for r in $expressions;do
    val=`echo $r|tr ',' ' '`
    if [[ "$val" =~ r([0-9]+)\((.+)\) ]]; then
	curr_arr=(${BASH_REMATCH[2]})
	sel=$((${randoms[${BASH_REMATCH[1]}]}%${#curr_arr[@]}));
	expression_value+=(${curr_arr[$sel]})
	r_escape=`echo $r | sed 's/(/\\(/g' |sed 's/)/\\)/g'`
#	echo "-$sel $r =${curr_arr[$sel]}"
	if [ -z "$replace" ];then
	    replace="cat $confile| sed 's/$r_escape/${curr_arr[$sel]}/g'";
	else
	    replace="$replace | sed 's/$r_escape/${curr_arr[$sel]}/g'";
	fi
    fi
done

eval $replace


