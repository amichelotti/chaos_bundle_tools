#!/bin/bash

#script for initialize the bundle create with google repo utility
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

PARENT_SCRIPTPATH="$(dirname "$SCRIPTPATH")"

echo -e "\033[38;5;148m!CHAOS initialization script\033[39m"
echo -e "\033[38;5;148m!CHOAS bundle directory -> $PARENT_SCRIPTPATH\033[39m"
echo "press any key to continue"
read -n 1 -s

#boostrap !CHAOS Framework in development mode
export CHAOS_DEVELOPMENT="YES"

$SCRIPTPATH/../chaosframework/bootstrap.sh
ln -s $SCRIPTPATH/../chaosframework/usr $SCRIPTPATH/../usr

#make the documentation
cd $SCRIPTPATH/../chaosframework
doxygen Documentation/chaosdocs
cd ..
ln -s chaosframework/Documentation/html Documentation

#chomod +x /$PWD/ChaosMakeNewRTCU
export PATH=$PATH:$PWD/tools
