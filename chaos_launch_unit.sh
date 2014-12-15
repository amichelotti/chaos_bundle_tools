#!/bin/sh
execname=$(basename $0)
dirname=$(dirname $0)
# source $dirname/chaos_bundle_env.sh
usage(){
    echo "usage is $execname <unitserver executable> <unit server name> [metadataserver=localhost:5000]"
}
unitexec="$1"
unitserver="$CHAOS_BUNDLE/usr/local/bin/$unitexec"
if [ ! -x "$unitserver" ]; then
    echo "## unit server \"$unitserver\" not a valid executable"
    usage;
    exit 1;
fi

if [ -z "$2" ]; then
    echo "## you have to specify a valid unit server name"
    usage;
    exit 1;
fi
unitname=$2

metadata="localhost:5000"
if [ ! -z "$3" ];then
    metadata=$3;
fi


if [ -z "$1" ]; then
echo " missing metadata server"
echo "usage is $0 <metadataserver> <unitserver name>"
exit 1
fi

pidfile="/tmp/$unitexec-$unitname.pid"
logfile="/tmp/$unitexec-$unitname.log"


if [ -f "$pidfile" ]; then
    ptokill=`cat $pidfile`
    echo "* killing process $ptokill"
    rm $pidfile
    rm $logfile
    kill -9 $ptokill > /dev/null 2>&1
fi

echo "* unit executable \"$unitserver\" name \"$unitname\" metadataserver \"$metadata\" log on /tmp/$unitexec-$unitname.log"
$unitserver --metadata-server $metadata --unit_server_alias $unitname --log-on-file --log-file $logfile --unit_server_enable true > /dev/null&
ppid=$!;

if [ ! -z "$ppid" ]; then
echo "$ppid" > $pidfile
chmod 666 $pidfile
sleep 1
chmod 666 $logfile
echo "* launched successfully, pid $ppid"

else
echo "## error launching"
fi





