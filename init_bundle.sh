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
if [ "$CHAOS_TARGET" == "BBB" ]; then
    echo "* Cross compiling for Beagle Bone"
    export CC=arm-linux-gnueabihf-gcc
    export CXX=arm-linux-gnueabihf-g++
    export LD=arm-linux-gnueabihf-ld
    export CROSS_HOST=arm-linux-gnueabihf
else
    export CC=gcc
    export CXX=g++
    export LD=ld
fi

echo "* Using C-Compiler:   $CC"
echo "* Using C++-Compiler: $CXX"
echo "* Using Linker:       $LD"
echo "* OS: $OS"
echo "* KERNEL VER:$KERNEL_SHORT_VER"

if [ `echo $OS | tr "[:upper:]" "[:lower:]"` = `echo "Darwin" | tr "[:upper:]" "[:lower:]"` ] && [ "$KERNEL_SHORT_VER" -ge 1300 ]; then
    echo "We are on mavericks but we still use the stdlib++, these are the variable setupped:"
    export CC=clang
    export CXX="clang++ -stdlib=libstdc++"
    export LD=clang

    echo "CC = $CC"
    echo "CXX = $CXX"
    echo "LD = $LD"
    export CHAOS_BOOST_VERSION=53 ## TO REMOVE
    export COSXMAKE="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS=-stdlib=libstdc++"
else
    export COSXMAKE=
fi

echo "press any key to continue"
read -n 1 -s


rm -rf $CHAOS_FRAMEWORK/CMakeFiles $CHAOS_FRAMEWORK/CMakeCache.txt
if ! ( $CHAOS_FRAMEWORK/bootstrap.sh ) ; then 
    echo "## error bootstrapping quitting"
    exit 1
fi

ln -sf $CHAOS_FRAMEWORK/usr $CHAOS_BUNDLE/usr

for i in debug serial test modbus powersupply; do
cd $CHAOS_BUNDLE/common/$i
echo "* entering in $CHAOS_BUNDLE/common/$i"
rm -rf CMakeFiles CMakeCache.txt
if ! cmake $COSXMAKE .; then
echo "ERROR unable to create Makefile in $CHAOS_BUNDLE/common/$i"
fi;
if ! make install; then
echo "ERROR compiling in $CHAOS_BUNDLE/common/$i"
exit 1;
fi;
done;

for i in $(ls  $CHAOS_BUNDLE/driver/) ; do
cd $CHAOS_BUNDLE/driver/$i
echo "* entering in $CHAOS_BUNDLE/driver/$i"
rm -rf CMakeFiles CMakeCache.txt
if ! cmake $COSXMAKE .; then
echo "ERROR unable to create Makefile in $CHAOS_BUNDLE/driver/$i"
fi;
if ! make install; then
echo "ERROR compiling in $CHAOS_BUNDLE/driver/$i"
exit 1;
fi;
done;

for i in $(ls  $CHAOS_BUNDLE/example/) ; do
cd $CHAOS_BUNDLE/example/$i
echo "* entering in $CHAOS_BUNDLE/example/$i"
rm -rf CMakeFiles CMakeCache.txt
if ! cmake $COSXMAKE .; then
echo "ERROR unable to create Makefile in $CHAOS_BUNDLE/example/$i"
fi;
if ! make install; then
echo "ERROR compiling in $CHAOS_BUNDLE/example/$i"
exit 1;
fi;
done;

#make the documentation
cd $CHAOS_FRAMEWORK
doxygen Documentation/chaosdocs
cd ..
ln -sf $CHAOS_FRAMEWORK/Documentation/html Documentation


