#!/bin/bash


user="root"
source=""
dest=""


usage(){

    echo "Usage is $0  [-u <ssh user ($user)> ] -s <local source> [-d <remote destination>] <server lists file >"
    
}


while getopts u:d:s:h opt;do 
    case $opt in
	u) 
	    user=$OPTARG
	    ;;
	d)
	    dest=$OPTARG
	    ;;
	h)
	    usage
	    exit 0
	    ;;
	s)
	    source=$OPTARG
	    ;;
    esac
    
done


shift $((OPTIND -1))

if [ ! -e "$1" ];then
    echo "## you must specify a valid list of servers file"
    exit 1
fi

if [ ! -e "$source" ];then
    echo "## you must specify an existing binary, \"$source\" doesn't exists"
    exit 1
fi

 
list=`cat $1`
for s in $list;do
    scp $source $user@$s:$dest >& /dev/null &
    echo "* copying $source in $user@$s:$dest id $! ..."

done
error=0
for job in `jobs -p`;do
    echo "* waiting finishing id $job"
    wait $job || let "error+=1"
    if [ $error != "0" ] ;then
	echo "## error copying $error"
	
    fi
done

if [ $error == "0" ] ;then
    echo "* successfully copied"
else
    exit 1
fi

