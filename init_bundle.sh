#!/bin/bash
curr=`dirname $0`
OS=$(uname -s)
ARCH=$(uname -m)
KERNEL_VER=$(uname -r)
KERNEL_SHORT_VER=$(uname -r|cut -d\- -f1|tr -d '.'| tr -d '[A-Z][a-z]')

source $curr/chaos_bundle_env.sh
WEB_UI_SERVICE=$CHAOS_BUNDLE/service/webgui/CUiserver

if [ ! -d "$CHAOS_FRAMEWORK" ] ; then
echo "please set CHAOS_FRAMEWORK [=$CHAOS_FRAMEWORK] environment to a valid directory, use \"source $curr/chaos_bundle_env.sh\""
exit 1;
fi

if [ ! -d "$CHAOS_BUNDLE" ] ; then
echo "please set CHAOS_BUNDLE [=$CHAOS_BUNDLE] environment to a valid directory, use  \"source $curr/chaos_bundle_env.sh\""
exit 1;
fi

if [ ! -n "$CHAOS_LINK_LIBRARY" ] ; then
echo "CHAOS_LINK_LIBRARY not set, please use  \"source $curr/chaos_bundle_env.sh\""
exit 1;
fi

echo -e "\033[38;5;148m!CHAOS initialization script\033[39m"
echo -e "\033[38;5;148m!CHOAS bundle directory -> $CHAOS_BUNDLE\033[39m"
if [ "$CHAOS_TARGET" == "BBB" ]; then
    echo "* Cross compiling for Beagle Bone"
    export CC=arm-linux-gnueabihf-gcc-4.8
    export CXX=arm-linux-gnueabihf-g++-4.8
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
echo "* Link with: $CHAOS_LINK_LIBRARY"

if [ `echo $OS | tr "[:upper:]" "[:lower:]"` = `echo "Darwin" | tr "[:upper:]" "[:lower:]"` ] && [ "$KERNEL_SHORT_VER" -ge 1300 ]; then
    echo "We are on mavericks but we still use the stdlib++, these are the variable setupped:"
    export CC=clang
    export CXX="clang++ -stdlib=libstdc++"
    export LD=clang

    echo "CC = $CC"
    echo "CXX = $CXX"
    echo "LD = $LD"
    export COSXMAKE="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS=-stdlib=libstdc++"
else
    export COSXMAKE=
fi

echo "press any key to continue"
read -n 1 -s

function cmake_compile(){
    dir=$1;
    cd $dir;
    echo "* entering in $dir"
    if [ ! -f CMakeLists.txt ]; then
	echo "* skipping $dir does not contain CMakeLists.txt"
    fi;
	
    rm -rf CMakeFiles CMakeCache.txt
    if ! cmake $COSXMAKE .; then
	echo "ERROR unable to create Makefile in $dir"
    fi;
    if ! make install; then
	echo "ERROR compiling in $dir"
	exit 1;
    fi;
}




rm -rf $CHAOS_FRAMEWORK/CMakeFiles $CHAOS_FRAMEWORK/CMakeCache.txt
if ! ( $CHAOS_FRAMEWORK/bootstrap.sh ) ; then
    echo "## error bootstrapping quitting"
    exit 1
fi

ln -sf $CHAOS_FRAMEWORK/usr $CHAOS_BUNDLE/usr

for i in debug serial test modbus powersupply; do
cmake_compile $CHAOS_BUNDLE/common/$i;
done;

for i in $(ls  $CHAOS_BUNDLE/driver/) ; do
cmake_compile $CHAOS_BUNDLE/driver/$i;
done;

for i in $(ls  $CHAOS_BUNDLE/example/) ; do
cmake_compile $CHAOS_BUNDLE/example/$i;
done;


cmake_compile $WEB_UI_SERVICE;


#make the documentation
cd $CHAOS_FRAMEWORK
doxygen Documentation/chaosdocs
cd ..
ln -sf $CHAOS_FRAMEWORK/Documentation/html Documentation
