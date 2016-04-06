#!/bin/bash -e
if [ ! -e "$CHAOS_BUNDLE" ];then
    echo "## the source directory must be defined"
    exit 0;
fi
#
echo "* using $CHAOS_BUNDLE"
cd $CHAOS_BUNDLE
BASE=chaos-i686-linux26-dynamic-release
./tools/chaos_build.sh -t i686-linux26 -o dynamic -b release 
tar cvfz $BASE.tar.gz $BASE 
./tools/chaos_remote_command.sh -u root -c "initctl stop chaos-us" tools/config/lnf/production/i686_dynamic_list.txt 
./tools/chaos_remote_copy.sh -u root -s $BASE.tar.gz ./tools/config/lnf/production/i686_dynamic_list.txt
./tools/chaos_remote_command.sh -u root -c "tar xvfz $BASE.tar.gz" tools/config/lnf/production/i686_dynamic_list.txt 
./tools/chaos_remote_command.sh -u root -c "initctl start chaos-us" ./tools/config/lnf/production/i686_dynamic_list.txt 

echo "i686 dynamic successfully installed"

