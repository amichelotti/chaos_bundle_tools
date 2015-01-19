#!/bin/bash
if [ -f "$1" ]; then
    confile=$1
else
    echo "## cannot open $1"
    exit 1
fi

randoms=()
variables=`cat $confile | grep -o '\$r[0-9]*'|sort -n |uniq`
expressions=`cat $confile | grep -o '\$r([0-9\.,]*)'`

for r in $variables;do
rand=$RANDOM
randoms+=($rand)
done
arr=()
for r in $expressions;do
    arr=`echo $r|tr ',' ' '` 
    echo "$r => ${arr[0]} ${arr[1]} size: ${#arr[@]}"
done
if [[ "$var" =~ r(\d+)\((.+)\) ]]; then
    echo "found r${BASH_REMATCH[1]} = ${BASH_REMATCH2}"
fi
