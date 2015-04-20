#!/bin/bash
if [ ! -e $CHAOS_PREFIX/log/mds.log ]; then
    echo "## cannot find mds log file in $CHAOS_PREFIX/log/mds.log"
    exit 1
fi
cnt=0
while true;do
    if grep "SQL" $CHAOS_PREFIX/log/mds.log ;then
	((cnt++))
	echo "%% grr restarting $cnt MDS..."
	$CHAOS_PREFIX/tools/chaos_services.sh stop mds
	$CHAOS_PREFIX/tools/chaos_services.sh start mds
    fi
    sleep 2
done
