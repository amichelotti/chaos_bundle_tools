#!/bin/bash
RELEASE=$1
if [ -z "$RELEASE" ];then
    RELEASE="experimental"
fi
echo " Release $RELEASE"
wget https://opensource.lnf.infn.it/binary/chaos/$EXPERIMENTAL/arm/chaos-distrib-$EXPERIMENTAL-build_arm_linux26.tar.gz
echo "* extracting"
tar xvfz chaos-distrib-$EXPERIMENTAL-build_arm_linux26.tar.gz chaos-distrib-$EXPERIMENTAL-build_arm_linux26/bin/daqLiberaServer
echo "* copying"
scp -v chaos-distrib-$EXPERIMENTAL-build_arm_linux26/bin/daqLiberaServer michelo@192.168.143.252:/export/chaos-libera/old
echo "* removing tar"
rm -rf chaos-distrib-$EXPERIMENTAL-build_arm_linux26*
