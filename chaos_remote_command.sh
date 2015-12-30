#!/bin/bash


user="root"
cmd=""
dest=""
slep=0

usage(){

    echo "Usage is $0  [-u <ssh user ($user)> ] -c <remote command> <server lists file >"
    
}


while getopts s:u:c:h opt;do 
    case $opt in
	u) 
	    user=$OPTARG
	    ;;

	s) 
	    slep=$OPTARG
	    ;;

	h) 
	    usage
	    exit 0
	    ;;

	c)
	    cmd="$OPTARG"
	    ;;

    esac
    
done


shift $((OPTIND -1))

if [ ! -e "$1" ];then
    echo "## you must specify a valid list of servers file"
    exit 1
fi

if [ -z "$cmd" ];then
    echo "## you must specify a remote command"
    exit 1
fi

 
list=`cat $1`
for s in $list;do
    echo "* perform \"$cmd\" in $user@$s ..."
    ssh -f $user@$s $cmd > /dev/null &
    if [ $slep -gt 0 ]; then
	sleep $slep
    fi
done
error=0
for job in `jobs -p`; do
    echo "waiting for command termination command id $job"
    wait $job || let "$error+=1"
    if [ $error != "0" ];then
	echo "# an error occurred in command id $job"
    fi
done

if [ $error == "0" ] ;then
    echo "* successfully"
else
    exit 1
fi

