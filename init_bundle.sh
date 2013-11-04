#!/bin/bash
curr=`dirname $0`
OS=$(uname -s)
ARCH=$(uname -m)
KERNEL_VER=$(uname -r)
KERNEL_SHORT_VER=$(uname -r|cut -d\- -f1|tr -d '.'| tr -d '[A-Z][a-z]')

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

if [ `echo $OS | tr [:upper:] [:lower:]` = `echo "Darwin" | tr [:upper:] [:lower:]` ] && [ $KERNEL_SHORT_VER -ge 1300 ]; then
    echo "We are on mavericks but we still use the stdlib++, these are the variable setupped:"
    export CC=clang
    export CXX="clang++ -stdlib=libstdc++"
    export LD=clang

    echo "CC = $CC"
    echo "CXX = $CXX"
    echo "LD = $LD"
fi

echo "press any key to continue"
read -n 1 -s


rm -rf $CHAOS_FRAMEWORK/CMakeFiles $CHAOS_FRAMEWORK/CMakeCache.txt
$CHAOS_FRAMEWORK/bootstrap.sh

ln -sf $CHAOS_FRAMEWORK/usr $CHAOS_BUNDLE/usr
for j in common drivers ; do
for i in $(ls  $CHAOS_BUNDLE/$j) ; do
cd $CHAOS_BUNDLE/$j/$i
echo "* entering in $CHAOS_BUNDLE/$j/$i"
rm -rf CMakeFiles CMakeCache.txt
if ! cmake .; then
echo "ERROR unable to create Makefile in $CHAOS_BUNDLE/$j/$i"
fi;
if ! make install; then
echo "ERROR compiling in $CHAOS_BUNDLE/$j/$i"
exit 1;
fi;

done;
done;

#make the documentation
cd $CHAOS_FRAMEWORK
doxygen Documentation/chaosdocs
cd ..
ln -sf $CHAOS_FRAMEWORK/Documentation/html Documentation


