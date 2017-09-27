#!/bin/sh
echo "* retriving libera ARM binaries"
lista="libera13 libera12 libera10 libera02 libera03 libera05 libera06 libera07 libera08 libera09 libera01"
for i in $lista;do
echo "* stopping $i"
ssh root@$i /etc/init.d/chaos-us.sh stop
done

wget http://opensource.lnf.infn.it/binary/chaos/arm/chaos-distrib-development-build_arm_linux26.tar.gz
tar xvfz chaos-distrib-development-build_arm_linux26.tar.gz chaos-distrib-development-build_arm_linux26/bin/daqLiberaServer 
scp chaos-distrib-development-build_arm_linux26/bin/daqLiberaServer michelo@192.168.143.252:/export/chaos-libera/old
rm -rf chaos-distrib-development-build_arm_linux26*

echo "* retriving libera i686 binaries"
wget http://opensource.lnf.infn.it/binary/chaos/i686/chaos-distrib-development-build_i686_dynamic_linux26.tar.gz
tar xvfz chaos-distrib-development-build_i686_dynamic_linux26.tar.gz chaos-distrib-development-build_i686_dynamic_linux26/bin/daqLiberaServer chaos-distrib-development-build_i686_dynamic_linux26/lib
cp /usr/local/chaos/i686-nptl-linux-gnu/i686-nptl-linux-gnu/sysroot/lib/libstdc++.so.6 chaos-distrib-development-build_i686_dynamic_linux26/lib
scp -r chaos-distrib-development-build_i686_dynamic_linux26/ michelo@192.168.143.252:/export/chaos-libera/new
ssh michelo@192.168.143.252 "rm -rf /export/chaos-libera/new/chaos-distrib"
ssh michelo@192.168.143.252 "cd /export/chaos-libera/new/;ln -sf chaos-distrib-development-build_i686_dynamic_linux26 chaos-distrib"
# rm -rf chaos-distrib-development-build_i686_*
### stopping libera
echo "sleeping 5s"
sleep 6
for i in $lista;do
echo "* starting $i"
ssh root@$i /etc/init.d/chaos-us.sh start
done




