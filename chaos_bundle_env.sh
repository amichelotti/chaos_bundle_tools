\
SOURCE="${BASH_SOURCE[0]}"

pushd `dirname $SOURCE` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null
OS=$(uname -s)
ARCH=$(uname -m)
KERNEL_VER=$(uname -r)
KERNEL_SHORT_VER=$(uname -r|cut -d\- -f1|tr -d '.'| tr -d '[A-Z][a-z]')


export CHAOS_BUNDLE="$(dirname "$SCRIPTPATH")"

#boostrap !CHAOS Framework in development mode
export CHAOS_FRAMEWORK=$CHAOS_BUNDLE/chaosframework
export PATH=$CHAOS_BUNDLE/tools:$CHAOS_BUNDLE/usr/local/bin:$PATH
export DYLD_LIBRARY_PATH=$CHAOS_BUNDLE/usr/local/lib
export LD_LIBRARY_PATH=$CHAOS_BUNDLE/usr/local/lib:$LD_LIBRARY_PATH
#set default compile lib
export CHAOS_LINK_LIBRARY="boost_program_options boost_date_time boost_system boost_thread boost_chrono boost_regex boost_log_setup boost_log boost_filesystem memcached zmq uv mongoose dl pthread"
export WEB_UI_SERVICE=$CHAOS_BUNDLE/service/webgui/CUiserver

if [ $(uname -s) == "Linux" ]; then
    export CHAOS_BOOST_VERSION=55
else
    export CHAOS_BOOST_VERSION=56
fi;

if [ -z "$CHAOS_PREFIX" ]; then
    export CHAOS_PREFIX=$CHAOS_BUNDLE/usr/local
else
    if [ "$CHAOS_PREFIX" != "$CHAOS_BUNDLE/usr/local" ]; then
	echo "* WARNING INSTALLATION DIR $CHAOS_PREFIX *****"
    fi
fi

#export MONGO_VERSION=26compat
export MONGO_VERSION=legacy-1.0.0-rc0
export LIB_EVENT_VERSION=release-2.1.4-alpha
export CC=gcc
export CXX=g++
export LD=ld
unset CHAOS_CROSS_HOST
unset CC
unset CXX
unset LD
if [ "$CHAOS_TARGET" == "BBB" ]; then
    echo "* Cross compiling for Beagle Bone"
    export CC=arm-linux-gnueabihf-gcc-4.8
    export CXX=arm-linux-gnueabihf-g++-4.8
    export LD=arm-linux-gnueabihf-ld
    export CHAOS_CROSS_HOST=arm-linux-gnueabihf
else

    export CHAOS_TARGET=$OS
fi;

if [ -n "$CHAOS_DEVELOPMENT" ]; then
	export CHAOS_COMP_TYPE=" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS_DEBUG=-DDEBUG=1 "
else
	export CHAOS_COMP_TYPE=" -DCMAKE_BUILD_TYPE=Release "
fi

export CHAOS_CMAKE_FLAGS=""
export CHAOS_BOOST_FLAGS=""
if [ -n "$CHAOS_STATIC" ]; then
    export CHAOS_BOOST_FLAGS="link=static"
    export CHAOS_CMAKE_FLAGS="-DBUILD_FORCE_STATIC=true"
else
    export CHAOS_BOOST_FLAGS="link=shared"
fi


if [ -n "$CHAOS32" ]; then
    export CHAOS_CMAKE_FLAGS="$CHAOS_CMAKE_FLAGS -DBUILD_FORCE_32=true"
    export CFLAGS="$CFLAGS -m32"
    export CXXFLAGS="$CXXFLAGS -m32"
    echo "Force 32 bit binaries"
    export CHAOS_BOOST_FLAGS="$CHAOS_BOOST_FLAGS cflags=-m32 cxxflags=-m32 address-model=32"
fi


if [ `echo $OS | tr '[:upper:]' '[:lower:]'` = `echo "Darwin" | tr '[:upper:]' '[:lower:]'` ] && [ $KERNEL_SHORT_VER -ge 1300 ] && [ ! -n "$CROSS_HOST" ]; then
    echo "Use standard CLIB with clang"
    export CHAOS_CMAKE_FLAGS="$CHAOS_CMAKE_FLAGS -DCMAKE_CXX_FLAGS=-stdlib=libstdc++ $CHAOS_COMP_TYPE -DCMAKE_INSTALL_PREFIX:PATH=$CHAOS_PREFIX"
    export CC=clang
    export CXX="clang++"
    export CXXFLAGS="-stdlib=libstdc++"
    export LDFLAGS="-stdlib=libstdc++"
    export LD=clang
    ## 18, 16 doesnt compile
    export LMEM_VERSION=1.0.14
    export CHAOS_BOOST_FLAGS="$CHAOS_BOOST_FLAGS toolset=clang cxxflags=-stdlib=libstdc++ linkflags=-stdlib=libstdc++"
fi

export CHAOS_BOOST_FLAGS="$CHAOS_BOOST_FLAGS --prefix=$CHAOS_PREFIX --with-program_options --with-chrono --with-filesystem --with-iostreams --with-log --with-regex --with-random --with-system --with-thread --with-atomic --with-timer install"
export CHAOS_CMAKE_FLAGS="$CHAOS_CMAKE_FLAGS $CHAOS_COMP_TYPE -DCMAKE_INSTALL_PREFIX:PATH=$CHAOS_PREFIX -DCHAOS_CC_COMPILER=$CXX -DCHAOS_C_COMPILER=$CC"
