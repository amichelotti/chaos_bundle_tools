#!/bin/sh
if [ -z "$1" ];then
    echo "## please specify update from: 'experimental'/'development'/'master'"
    exit 1
fi
mkdir -p /tmp/tmpdeploy/
cd /tmp/tmpdeploy
echo "* retriving infrastructure binaries"
wget http://opensource.lnf.infn.it/binary/chaos/$1/x86_64/ubuntu/14.04/chaos-distrib.tar.gz
tar xfz chaos-distrib.tar.gz
./chaos-distrib/tools/chaos_deploy.sh -c ./chaos-distrib/tools/config/lnf/production/chaos-infrastructure.txt -i chaos-distrib





