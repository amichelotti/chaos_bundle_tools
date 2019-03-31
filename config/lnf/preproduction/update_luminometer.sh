#!/bin/sh
if [ -z "$1" ];then
    echo "## please specify update from: 'experimental'/'development'/'master'"
    exit 1
fi
echo "* retriving static i686 binaries"
# wget  http://opensource.lnf.infn.it/binary/chaos/$1/i686/chaos-distrib-$1-build_i686_static_linux26.tar.gz
echo "* open package"
tar xvfz chaos-distrib-$1-build_i686_static_linux26.tar.gz chaos-distrib-$1-build_i686_static_linux26/bin/UnitServer
echo "* stopping services"
ssh root@dante073 'initctl stop chaos-us;rm -f /root/chaos-distrib-*.gz'
echo "* updating.."
scp -r chaos-distrib-$1-build_i686_static_linux26/bin/UnitServer root@dante073:
echo "* relink.."
ssh root@dante073 "rm -f /usr/local/chaos-distrib;ln -s /root/chaos-distrib-$1-build_i686_static_linux26 /usr/local/chaos-distrib"
sleep 5
echo "* restart.."
ssh root@dante073 'initctl start chaos-us'





