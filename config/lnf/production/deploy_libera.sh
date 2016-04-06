#!/bin/bash -e
if [ ! -e "$CHAOS_BUNDLE" ];then
    echo "## the source directory must be defined"
    exit 0;
fi
#
echo "* using $CHAOS_BUNDLE"
cd $CHAOS_BUNDLE
export PATH=/usr/local/chaos/gcc-arm-infn-linux26/bin:$PATH
BASE=chaos-arm-linux-2.6-static-release
./tools/chaos_build.sh -t arm-linux-2.6 -o static -b release 

arm-infn-linux-gnueabi-strip $BASE/bin/daqLiberaServer
./tools/chaos_remote_command.sh -u root -c "mount -o remount rw /" tools/config/lnf/production/libera_list.txt
./tools/chaos_remote_command.sh -u root -c "/etc/init.d/libera-server stop" tools/config/lnf/production/libera_list.txt 
chaos_remote_command.sh -u root -c "/etc/init.d/libera-cu.sh stop" tools/config/lnf/production/libera_list.txt 
chaos_remote_copy.sh -u root -s $BASE/bin/daqLiberaServer ./tools/config/lnf/production/libera_list.txt
chaos_remote_command.sh -u root -c "/etc/init.d/libera-cu.sh start" ./tools/config/lnf/production/libera_list.txt  

echo "libera successfully installed"

