#!/bin/bash

separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

source $dir/../common_util.sh

Usage(){
    echo "$0 <file with servers>"
}

if [ ! -e "$1" ]; then
    nok_mesg "You must specify a valid file for deployment"
    exit 1
fi
if [ -z "$CHAOS_PREFIX" ];then
    echo "## NO environment CHAOS_PREFIX defined"
    exit 1
fi
name=`basename $CHAOS_PREFIX`
info_mesg "generating tarball $name.tgz"
rm -f /tmp/$name.tgz > /dev/null
if tar cfz /tmp/$name.tgz -C $CHAOS_PREFIX/.. $name ;then
    ok_mesg "$name created"
else 
    nok_mesg "$name created"
    exit 1
fi
servers=`cat $1`
info_mesg "copy on the destination servers: " "$servers"
if $dir/../chaos_deploy.sh -u chaos -s /tmp/$name.tgz $1;then
    ok_mesg "copy done"
else
    nok_mesg "copy done"
    exit 1
fi



for i in $servers;do
    info_mesg "installing in " "$i"
    if [[ "$i" =~ -([a-zA-Z]+)[0-9]+ ]];then
	j=${BASH_REMATCH[1]}
	if ssh chaos@$i "sudo service chaos-$j stop" ;then
	    ok_mesg "stopping chaos-$j services on $i"
	else
	    nok_mesg "stopping chaos-$j services on $i"
	fi
	
	if ssh chaos@$i "tar xfz $name.tgz;ln -sf chaos-x86_64-distrib $name"; then
	    ok_mesg "extracting $name in $i"
	else
	    nok_mesg "extracting $name in $i"
	    exit 1
	fi
	
	
	if ssh chaos@$i "sudo service chaos-$j start" ;then
	    ok_mesg "starting chaos-$j services on $i"
	else
	    nok_mesg "starting chaos-$j services on $i"
	    exit 1
	fi
    fi
	
    
done

