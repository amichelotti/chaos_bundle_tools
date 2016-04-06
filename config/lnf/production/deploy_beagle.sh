#!/bin/bash -e
if [ ! -e "$CHAOS_BUNDLE" ];then
    echo "## the source directory must be defined"
    exit 0;
fi
#
echo "* using $CHAOS_BUNDLE"
cd $CHAOS_BUNDLE
BASE=chaos-armhf-static-release
./tools/chaos_build.sh -t armhf -o static -b release
./tools/chaos_remote_command.sh -u root -c "/etc/init.d/chaos-cu stop" tools/config/lnf/production/beagle_list.txt 
chaos_remote_copy.sh -u root -s $BASE/bin/UnitServer ./tools/config/lnf/production/beagle_list.txt
chaos_remote_command.sh -u root -c "/etc/init.d/libera-cu.sh start" ./tools/config/lnf/production/beagle_list.txt 

echo "Beagle successfully installed"

