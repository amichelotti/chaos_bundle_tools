#!/bin/bash
wget https://opensource.lnf.infn.it/binary/chaos/experimental/arm/chaos-distrib-experimental-build_arm_linux26.tar.gz
echo "* extracting"
tar xvfz chaos-distrib-experimental-build_arm_linux26.tar.gz chaos-distrib-experimental-build_arm_linux26/bin/daqLiberaServer
echo "* copying"
scp -v chaos-distrib-experimental-build_arm_linux26/bin/daqLiberaServer michelo@192.168.143.252:/export/chaos-libera/old
echo "* removing tar"
rm -rf chaos-distrib-experimental-build_arm_linux26*
