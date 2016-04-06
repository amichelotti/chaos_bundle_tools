#!/bin/bash
if [ -z "$CHAOS_PREFIX" ] || [ ! -d "$CHAOS_PREFIX" ]; then
    echo "# you must set the CHAOS_PREFIX to a valid chaos-arm-linux-2.6-static-xx distribution"
    exit 1
fi
if echo "$CHAOS_PREFIX" | grep "arm-linux-2.6-static"; then 
    chaos_remote_command.sh -u root -c "mount -o remount rw /" $CHAOS_PREFIX/tools/config/lnf/production/libera_old_list.txt 
    arm-infn-linux-gnueabi-strip $CHAOS_PREFIX/bin/*
    chaos_remote_command.sh -u root -c "/etc/init.d/libera-server stop" $CHAOS_PREFIX/tools/config/lnf/production/libera_old_list.txt 
    chaos_remote_command.sh -u root -c "/etc/init.d/libera-cu.sh stop" $CHAOS_PREFIX/tools/config/lnf/production/libera_old_list.txt 
    chaos_remote_copy.sh -u root -s $CHAOS_PREFIX/bin/daqLiberaServer $CHAOS_PREFIX/tools/config/lnf/production/libera_old_list.txt
    chaos_remote_command.sh -u root -c "/etc/init.d/libera-cu.sh start" $CHAOS_PREFIX/tools/config/lnf/production/libera_old_list.txt  
else
    echo "# you must set the CHAOS_PREFIX extension seems not match arm-linux-2.6-static target, please check!"
fi
