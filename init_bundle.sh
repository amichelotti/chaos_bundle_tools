#!/bin/bash
curr=`dirname $0`

source $curr/chaos_bundle_env.sh

if [ ! -d "$CHAOS_FRAMEWORK" ] ; then
echo "please set CHAOS_FRAMEWORK [=$CHAOS_FRAMEWORK] environment to a valid directory, use \"source $curr/chaos_bundle_env.sh\""
exit 1;
fi

if [ ! -d "$CHAOS_BUNDLE" ] ; then
echo "please set CHAOS_BUNDLE [=$CHAOS_BUNDLE] environment to a valid directory, use  \"source $curr/chaos_bundle_env.sh\""
exit 1;
fi

 
echo -e "\033[38;5;148m!CHAOS initialization script\033[39m"
echo -e "\033[38;5;148m!CHOAS bundle directory -> $CHAOS_BUNDLE\033[39m"
echo "press any key to continue"
read -n 1 -s

$CHAOS_FRAMEWORK/bootstrap.sh
ln -sf $CHAOS_FRAMEWORK/usr $CHAOS_BUNDLE/usr

#make the documentation
cd $CHAOS_FRAMEWORK
doxygen Documentation/chaosdocs
cd ..
ln -sf $CHAOS_FRAMEWORK/Documentation/html Documentation


