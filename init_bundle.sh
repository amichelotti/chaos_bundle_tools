#!/bin/bash
curr=`dirname $0`
OS=$(uname -s)
ARCH=$(uname -m)
KERNEL_VER=$(uname -r)
KERNEL_SHORT_VER=$(uname -r|cut -d\- -f1|tr -d '.'| tr -d '[A-Z][a-z]')
NPROC=$(getconf _NPROCESSORS_ONLN)
source $curr/chaos_bundle_env.sh


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

echo "* CHAOS BUNDLE SOURCE (CHAOS_BUNDLE) :$CHAOS_BUNDLE"
echo "* INSTALL DIR         (CHAOS_PREFIX):$CHAOS_PREFIX"
echo "* Using C-Compiler    (CC) : $CC"
echo "* Using C++-Compiler  (CXX): $CXX"
echo "* Using Linker        (LD) : $LD"
echo "* Using CMAKE_FLAGS:  $CHAOS_CMAKE_FLAGS"
echo "* OS: $OS"

echo "* KERNEL VER:$KERNEL_SHORT_VER"
echo "* Link with: $CHAOS_LINK_LIBRARY"
if [ -n "$CHAOS_STATIC" ]; then
    echo "* Static distribution"
else
    echo "* Dynamic distribution"
fi
if [ -n "$CHAOS32" ]; then
    echo "* 32 bit distribution"
else
    echo "* default target distribution"
fi

if [ -n "$CHAOS_DEVELOPMENT" ]; then
    echo "* Development (Debug) target"
else
    echo "* Release target"
fi

echo "* !Chaos Target:$CHAOS_TARGET"

echo "press any key to continue"
read -n 1 -s

function cmake_compile(){
    dir=$1;
    cd $dir;
    echo "* entering in $dir"
    if [ ! -f CMakeLists.txt ]; then
	echo "* skipping $dir does not contain CMakeLists.txt"
	return 0;
    fi;
	
    rm -rf CMakeCache.txt
    echo "* cmake flags $CHAOS_CMAKE_FLAGS"
    if ! cmake $CHAOS_CMAKE_FLAGS .; then
	echo "ERROR unable to create Makefile in $dir"
    fi;
    if ! make -j $NPROC; then
	echo "ERROR compiling in $dir"
	exit 1;
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

echo " * linking $CHAOS_PREFIX $CHAOS_FRAMEWORK/usr"
mkdir -p $CHAOS_FRAMEWORK/usr
ln -sf $CHAOS_PREFIX $CHAOS_FRAMEWORK/usr

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

if [ -n "$CHAOS_DEVELOPMENT" ]; then
    echo "* linking $CHAOS_BUNDLE/usr in $CHAOS_FRAMEWORK"
    ln -sf $CHAOS_BUNDLE/usr $CHAOS_FRAMEWORK
fi

#make the documentation
cd $CHAOS_FRAMEWORK
doxygen Documentation/chaosdocs
cd ..
ln -sf $CHAOS_FRAMEWORK/Documentation/html Documentation
