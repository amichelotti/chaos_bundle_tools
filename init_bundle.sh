#!/bin/bash
curr=`dirname $0`
source $curr/chaos_bundle_env.sh
source $curr/common_util.sh

if [ ! -d "$CHAOS_FRAMEWORK" ] ; then
    error_mesg "please set CHAOS_FRAMEWORK [=$CHAOS_FRAMEWORK] environment to a valid directory, use \"source $curr/chaos_bundle_env.sh\""
    exit 1;
fi

if [ ! -d "$CHAOS_BUNDLE" ] ; then
    error_mesg "please set CHAOS_BUNDLE [=$CHAOS_BUNDLE] environment to a valid directory, use  \"source $curr/chaos_bundle_env.sh\""
    exit 1;
fi

if [ -z "$CHAOS_PREFIX" ] ; then
    error_mesg "please set CHAOS_PREFIX environment to a valid destination directory, use  \"source $curr/chaos_bundle_env.sh\""
    exit 1;
fi

if [ ! -n "$CHAOS_LINK_LIBRARY" ] ; then
    error_mesg "CHAOS_LINK_LIBRARY not set, please use  \"source $curr/chaos_bundle_env.sh\""
    exit 1;
fi

if [ ! -x $CHAOS_FRAMEWORK/bootstrap.sh ];then
    error_mesg "not found \"$CHAOS_FRAMEWORK/bootstrap.sh\", please unset CHAOS_BUNDLE"
    exit 1;
fi
info_mesg "!CHAOS initialization script"


info_mesg "CHAOS BUNDLE SOURCE (CHAOS_BUNDLE) :" "$CHAOS_BUNDLE"
info_mesg "INSTALL DIR         (CHAOS_PREFIX):" "$CHAOS_PREFIX"
info_mesg "Using C-Compiler    (CC) :" "$CC"
info_mesg "Using C-Flags   (CFLAGS) :" "$CFLAGS"
info_mesg "Using C++-Compiler  (CXX):" "$CXX"
info_mesg "Using C++-Flags(CXXFLAGS):" "$CXXFLAGS"
info_mesg "Using Linker        (LD) :" "$LD"
info_mesg "Using CMAKE_FLAGS        :" "$CHAOS_CMAKE_FLAGS"
info_mesg "OS                       :" "$OS"

info_mesg "KERNEL VER               :" "$KERNEL_SHORT_VER"
info_mesg "Link with                :" "$CHAOS_LINK_LIBRARY"
info_mesg "Compiling using          :" "$NPROC processors"
if [ -n "$CHAOS_STATIC" ]; then
    info_mesg "binary                   :" "Static"
else
    info_mesg "binary                   :" "Dynamic"
fi
if [ -n "$CHAOS32" ]; then
    info_mesg "32 bit                   :" "enabled"
fi

if [ -n "$CHAOS_DEVELOPMENT" ]; then
    info_mesg "build                    :" "Development (Debug) target"
else
    info_mesg "build                    :" "Release target"
fi

if [ -n "$CHAOS_EXCLUDE_DIR" ]; then
    info_mesg "excluding from build     :" "$CHAOS_EXCLUDE_DIR"
fi

info_mesg "!Chaos Target            :" "$CHAOS_TARGET"

info_mesg "press any key to continue"
read -n 1 -s

function cmake_compile(){
    dir=$1;
    cd $dir;
    bdir=`basename $dir`
    
    if chaos_exclude "$bdir";then
	echo "* skipping $i, because is in CHAOS_EXCLUDE_DIR"
	return 0
    fi

    if [ ! -f CMakeLists.txt ]; then
	warn_mesg "skipping $dir does not contain CMakeLists.txt"
	return 0;
    fi;
    echo "* entering in $dir"

    echo "* cmake flags $CHAOS_CMAKE_FLAGS"
    if ! cmake $CHAOS_CMAKE_FLAGS .; then
	error_mesg "unable to create Makefile in $dir"
	return 1
    fi;
    if ! make -j $NPROC; then
	error_mesg "compiling in $dir"
	return 1
    fi;

    if ! make install; then
	error_mesg "compiling in $dir"
	return 1
    fi;
}



# rm -rf $CHAOS_FRAMEWORK/CMakeFiles $CHAOS_FRAMEWORK/CMakeCache.txt
if ! ( $CHAOS_FRAMEWORK/bootstrap.sh ) ; then
    error_mesg "error bootstrapping quitting"
    exit 1
fi
if [ "$CHAOS_DEVELOPMENT" == "profile" ];then
	export CXXFLAGS="$CXXFLAGS -pg"
fi

if [ -n "$CHAOS_DEVELOPMENT" ]; then
    info_mesg "linking" "$CHAOS_BUNDLE/usr/local/include/chaos in $CHAOS_FRAMEWORK/chaos"
    rm -rf $CHAOS_BUNDLE/usr/local/include/chaos
    ln -sf  $CHAOS_FRAMEWORK/chaos $CHAOS_BUNDLE/usr/local/include/chaos
fi

for i in crest debug vme serial test modbus powersupply misc actuators; do
cmake_compile $CHAOS_BUNDLE/common/$i;
done;

## used in other drivers
cmake_compile $CHAOS_BUNDLE/driver/misc;

for i in $(ls  $CHAOS_BUNDLE/driver/) ; do
cmake_compile $CHAOS_BUNDLE/driver/$i;
done;

for i in $(ls  $CHAOS_BUNDLE/examples/) ; do
cmake_compile $CHAOS_BUNDLE/examples/$i;
done;


cmake_compile $WEB_UI_SERVICE;

if [ -n "$CHAOS_DEVELOPMENT" ]; then
    info_mesg "linking" "$CHAOS_BUNDLE/usr in $CHAOS_FRAMEWORK"
    ln -sf $CHAOS_BUNDLE/usr $CHAOS_FRAMEWORK
fi

#make the documentation
cd $CHAOS_FRAMEWORK
#doxygen Documentation/chaosdocs
cd ..
ln -sf $CHAOS_FRAMEWORK/Documentation/html Documentation
chaos_configure
