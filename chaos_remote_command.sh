#!/bin/bash


user="root"
cmd=""
dest=""


usage(){

    echo "Usage is $0  [-u <ssh user ($user)> ] -c <remote command> <server lists file >"
    
}


while getopts u:c: opt;do 
    case $opt in
	u) 
	    user=$OPTARG
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
    if ssh -f $user@$s $cmd;then
	echo "* OK"
    else
	echo "# FAIL"
	
    fi
done
