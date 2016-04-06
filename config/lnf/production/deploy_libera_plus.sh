#!/bin/bash -e
if [ ! -e "$CHAOS_BUNDLE" ];then
    echo "## the source directory must be defined"
    exit 0;
fi
#

echo "* using $CHAOS_BUNDLE"
cd $CHAOS_BUNDLE
export PATH=/usr/local/chaos/i686-nptl-linux-gnu/bin:$PATH
BASE=chaos-i686-linux26-static-release
./tools/chaos_build.sh  -o static -b release -t i686-linux26
./tools/chaos_remote_command.sh -u root -c "/etc/init.d/libera-server stop" tools/config/lnf/production/libera_plus_list.txt 
chaos_remote_command.sh -u root -c "/etc/init.d/libera-cu.sh stop" tools/config/lnf/production/libera_plus_list.txt 
chaos_remote_copy.sh -u root -s $BASE/bin/daqLiberaServer ./tools/config/lnf/production/libera_plus_list.txt
chaos_remote_command.sh -u root -c "/etc/init.d/libera-cu.sh start" ./tools/config/lnf/production/libera_plus_list.txt  

echo "libera plus successfully installed"

