#!/bin/sh
if [ -z "$1" ];then
    echo "## please specify update from: 'experimental'/'development'/'master'"
    exit 1
fi
echo "* retriving static i686 binaries"
wget -q http://opensource.lnf.infn.it/binary/chaos/$1/i686/chaos-distrib-$1-build_i686_static_linux26.tar.gz
scp chaos-distrib-$1-build_i686_static_linux26.tar.gz root@dante073:
ssh root@dante073 'initctl stop chaos-us;rm -f /root/chaos-distrib-*.gz'
ssh root@dante073 "tar xfz chaos-distrib-$1-build_i686_static_linux26.tar.gz chaos-distrib-$1-build_i686_static_linux26/bin/UnitServer"
ssh root@dante073 "rm -f /usr/local/chaos-distrib;ln -s /root/chaos-distrib-$1-build_i686_static_linux26 /usr/local/chaos-distrib"
sleep 5
ssh root@dante073 'initctl start chaos-us'





