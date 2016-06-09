#!/bin/bash -e

separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

source $dir/common_util.sh
TMPDIR="/tmp/$USER/chaos_deploy"
dest_prefix=chaos-x86_64-distrib

Usage(){
    echo "$0 <deploy configuration>"
}

if [ ! -e "$1" ]; then
    nok_mesg "You must specify a valid file for deployment"
    exit 1
fi
if [ -z "$CHAOS_PREFIX" ];then
    echo "## NO environment CHAOS_PREFIX defined"
    exit 1
fi
source $1

rm -rf $TMPDIR
mkdir -p $TMPDIR
cudir=`dirname $1`
cuconfig=`basename $cudir`

## MDS ##
if [ -z "$MDS_SERVER" ]; then
    info_mesg "MDS_SERVER " "not specified"
else
    if [ ! -f $cudir/mds.cfg ];then
	error_mesg "missing configuration  " "$cudir/mds.cfg"
	exit 1
    else
	info_mesg "using configuration " "$cudir/mds.cfg"
    fi

    mds="$MDS_SERVER"
#    cat $CHAOS_PREFIX/etc/cu-localhost.cfg | sed "s/localhost/$mds/g" > $CHAOS_PREFIX/etc/cu-$mds.cfg
 #   cat $CHAOS_PREFIX/etc/cuiserver-localhost.cfg | sed "s/localhost/$mds/g" > $CHAOS_PREFIX/etc/cuiserver-$mds.cfg
  #  pushd $CHAOS_PREFIX/etc > /dev/null
  #  ln -sf cu-$mds.cfg cu.cfg
  #  ln -sf cuiserver-$mds.cfg cuiserver.cfg
  #  popd > /dev/null
    echo "$MDS_SERVER" >> $TMPDIR/deployTargets
fi

## WEBUI ##
if [ -z "$WEBUI_SERVER" ]; then
    info_mesg "WEBUI_SERVER " "not specified"
else
    webui="$WEBUI_SERVER"

    pushd $CHAOS_PREFIX/
    cp -r $CHAOS_PREFIX/www $CHAOS_PREFIX/www-$webui
    find $CHAOS_PREFIX/www-$webui -name "*" -exec  sed -i s/__template__webuiulr__/$webui/g \{\} >& /dev/null \; 
    if [ ! -f $cudir/webui.cfg ];then
	error_mesg "missing configuration " "$cudir/webui.cfg"
	exit 1
    else
	info_mesg "using configuration " "$cudir/webui.cfg"
    fi

    popd > /dev/null
    if [ "$MDS_SERVER" != "$WEBUI_SERVER" ]; then
	echo "$WEBUI_SERVER" >> $TMPDIR/deployTargets
	
     
    fi
fi



info_mesg "working on " "$cuconfig"

## CDS ##
if [ -z "$CDS_SERVERS" ]; then
    info_mesg "CDS_SERVERS " "not specified"
else
    if [ ! -f $cudir/cds.cfg ];then
	error_mesg "missing configuration " "$cudir/cds.cfg"
	exit 1
    else
	info_mesg "using configuration " "$cudir/cds.cfg"
    fi

    if [ "$CDS_SERVERS" != "$WEBUI_SERVER" ]; then
	for i in "$CDS_SERVERS";do
	    echo "$i" >> $TMPDIR/deployTargets
	done
    fi
fi






name=`basename $CHAOS_PREFIX`
info_mesg "generating tarball $name.tgz"
if tar cfz $TMPDIR/$name.tgz -C $CHAOS_PREFIX/.. $name ;then
    ok_mesg "$name created"
else 
    nok_mesg "$name created"
    exit 1
fi


if [ -n "$CU_SERVERS" ]; then
    if [ ! -f $cudir/cu.cfg ];then
	error_mesg "missing configuration " "$cudir/cu.cfg"
	exit 1
    else
	info_mesg "using configuration " "$cudir/cu.cfg"
    fi
    if [ "$CU_SERVERS" != "$MDS_SERVER" ]; then
	for i in "$CU_SERVERS";do
	    echo "$i" >> $TMPDIR/deployTargets
	done
    fi
fi
servers=`cat $TMPDIR/deployTargets`
info_mesg "copy on the destination servers: " "$servers"




if $dir/chaos_remote_copy.sh -u chaos -s $TMPDIR/$name.tgz $TMPDIR/deployTargets;then
    ok_mesg "copy done"
else
    nok_mesg "copy done"
    exit 1
fi



deploy_install(){
    host=$1
    type=$2
    subtype=""
    if [[ "$type" =~ -([a-zA-Z]+)([0-9]+) ]];then
	type=${BASH_REMATCH[1]}
	subtype=${BASH_REMATCH[2]}
	
    fi
    info_mesg "installing $type$subtype in " "$host"
    ## STOP
    if ssh chaos@$host "sudo service chaos-service stop NODE=$type" ;then
	ok_mesg "stopping chaos-service NODE=$type on $host "
    else
	nok_mesg "stopping chaos-service NODE=$type on $host "
    fi

    if ssh chaos@$host "tar xfz $name.tgz;ln -sf $name $dest_prefix "; then
	ok_mesg "extracting $name in $host"
    else
	nok_mesg "extracting $name in $host"
    fi


    if ssh chaos@$host "cd $dest_prefix;ln -sf \$PWD/tools/config/lnf/$cuconfig/$type.cfg etc/";then
	ok_mesg "$type configuration"
    else
	ok_mesg "$type configuration"
    fi    
    

    if [ "$type" == "cu" ];then
	if ssh chaos@$host "cd $dest_prefix/;ln -sf tools/config/lnf/$cuconfig/cu$subtype.sh bin/cu";then
	    ok_mesg "linking $dest_prefix/tools/config/lnf/$cuconfig/cu$subtype.sh in $dest_prefix/bin/cu"
	else
	    nok_mesg "linking $dest_prefix/tools/config/lnf/$cuconfig/cu$subtype.sh in $dest_prefix/bin/cu"
	    
	fi
    fi

    

    if ssh chaos@$host "sudo service chaos-service start NODE=$type" ;then
	ok_mesg "starting chaos-service NODE=$type on $host "
    else
	nok_mesg "starting chaos-service NODE=$type on $host "
    fi


}

if [ -n "$MDS_SERVER" ]; then
    deploy_install "$MDS_SERVER" mds
fi

for i in $CDS_SERVERS;do
    deploy_install "$i" cds
done

if [ -n "$WEBUI_SERVER" ]; then
    deploy_install "$WEBUI_SERVER" webui
fi

k=0

for i in $CU_SERVERS;do
    deploy_install "$i" cu$k
    ((k++))
done





