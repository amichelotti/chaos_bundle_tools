
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

#set default compile lib
if [ $(uname -s) == "Darwin" ]; then
    export CHAOS_LINK_LIBRARY="boost_program_options boost_date_time boost_system boost_thread boost_chrono boost_regex boost_log_setup boost_log boost_filesystem memcached zmq mongoose jsoncpp dl pthread"
else
    export CHAOS_LINK_LIBRARY="boost_program_options boost_date_time boost_system  boost_chrono boost_regex boost_log_setup boost_log boost_filesystem boost_thread boost_atomic memcached zmq mongoose jsoncpp dl pthread rt"
fi;

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
	echo "* INSTALLATION DIR $CHAOS_PREFIX"
    fi
fi

export DYLD_LIBRARY_PATH=$CHAOS_PREFIX/lib
export LD_LIBRARY_PATH=$CHAOS_PREFIX/lib:$LD_LIBRARY_PATH

#export MONGO_VERSION=26compat
export MONGO_VERSION=legacy-1.0.0-rc0
export LIB_EVENT_VERSION=release-2.1.4-alpha

unset CHAOS_CROSS_HOST
export CHAOS_CMAKE_FLAGS=""
export CHAOS_BOOST_FLAGS=""

if [ "$CHAOS_TARGET" == "armhf" ]; then
    echo "* Cross compiling for ARMHF platforms (Beagle Bone,PI)"
    export CC=arm-linux-gnueabihf-gcc-4.8
    export CXX=arm-linux-gnueabihf-g++-4.8
    export LD=arm-linux-gnueabihf-ld
    export CHAOS_CROSS_HOST=arm-linux-gnueabihf
    export CHAOS_BOOST_VERSION=55
    export CFLAGS="$CFLAGS -D__BSON_USEMEMCPY__"
    export CXXFLAGS="$CXXFLAGS -D__BSON_USEMEMCPY__"
    #    export CHAOS_CMAKE_FLAGS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"
else
    if [ "$CHAOS_TARGET" == "arm-linux-2.6" ]; then
	if [ -x /usr/local/gcc46-arm-infn-linux26/bin/arm-infn-linux-gnueabi-gcc ]; then

	    echo "* Cross compiling for ARM(soft float) platforms on linux 2.6"
	    export PATH=/usr/local/gcc46-arm-infn-linux26/bin:$PATH
	     export CC=arm-infn-linux-gnueabi-gcc
	     export CXX=arm-infn-linux-gnueabi-g++
	     export LD=arm-infn-linux-gnueabi-ld
	     export CHAOS_CROSS_HOST=arm-infn-linux-gnueabi
	    # export PATH=$HOME/libera-arm-2.6.20/bin:$PATH
	    #  export CC=arm-unknown-linux-gnueabi-gcc
	    #  export CXX=arm-unknown-linux-gnueabi-g++
	    #  export LD=arm-unknown-linux-gnueabi-ld
	    #  export CHAOS_CROSS_HOST=arm-unknown-linux-gnueabi

	else
	    echo "## cannot find /usr/local/gcc46-arm-infn-linux26/bin/arm-infn-linux-gnueabi-gcc"
	    return 1
	fi
	if [ -z "$CHAOS_EXCLUDE_DIR" ];then

	    export CHAOS_EXCLUDE_DIR="oscilloscopes mongo chaos_services"
	fi
	export CHAOS_DISABLE_EVENTFD=true
	export CFLAGS="$CFLAGS -march=armv5te -msoft-float -D__BSON_USEMEMCPY__ -DBOOST_ASIO_DISABLE_EVENTFD"
	export CXXFLAGS="$CXXFLAGS -march=armv5te -msoft-float -D__BSON_USEMEMCPY__ -DBOOST_ASIO_DISABLE_EVENTFD"
	export CHAOS_BOOST_VERSION=55
	#
	export CHAOS_BOOST_FLAGS="toolset=gcc-arm target-os=linux cxxflags=-DBOOST_ASIO_DISABLE_EVENTFD"
    else
	if [ "$CHAOS_TARGET" == "linux-old" ] ; then
	    echo "* Cross compiling for i686 platforms on linux <=2.6"
	    export CHAOS_BOOST_VERSION=56
	    export CC=i686-infn-linux-gnu-gcc
	    export CXX=i686-infn-linux-gnu-g++
	    export LD=i686-infn-linux-gnu-ld
	    export CHAOS_CROSS_HOST=i686-infn-linux-gnu
	    if [ -z "$CHAOS_EXCLUDE_DIR" ];then

		export CHAOS_EXCLUDE_DIR="oscilloscopes mongo chaos_services"
	    fi
	    export CHAOS_DISABLE_EVENTFD=true
	    export CFLAGS="$CFLAGS -DBOOST_ASIO_DISABLE_EVENTFD -Wcast-align"
	    export CXXFLAGS="$CXXFLAGS -DBOOST_ASIO_DISABLE_EVENTFD -Wcast-align"
	    export CHAOS_BOOST_VERSION=55
	    #
	    export CHAOS_BOOST_FLAGS="target-os=linux cxxflags=-DBOOST_ASIO_DISABLE_EVENTFD"

	else
	    if [ "$CHAOS_TARGET" == "crio90xx" ] && [ "$ARCH" != "armv7l" ]; then
		if [ "$TARGET_PREFIX" != "arm-nilrt-linux-gnueabi-" ];then
		    #echo "## you should source the CRIO SDK setup \"environment-setup-armv7a-vfp-neon-nilrt-linux-gnueabi\" look in default installation directory \"/usr/local/oecore-x86_64/\""
		    #return 1
		    source /usr/local/oecore-x86_64/environment-setup-armv7a-vfp-neon-nilrt-linux-gnueabi
		fi
		export CHAOS_EXCLUDE_DIR="oscilloscopes mongo chaos_services"
		export CC="arm-nilrt-linux-gnueabi-gcc"
		export CFLAGS="-march=armv7-a -mthumb-interwork -mfloat-abi=softfp -mfpu=neon --sysroot=/usr/local/oecore-x86_64/sysroots/armv7a-vfp-neon-nilrt-linux-gnueabi -L/usr/local/oecore-x86_64/sysroots/armv7a-vfp-neon-nilrt-linux-gnueabi/lib"

		export CXX="arm-nilrt-linux-gnueabi-g++"
		export CXXFLAGS="-march=armv7-a -mthumb-interwork -mfloat-abi=softfp -mfpu=neon --sysroot=/usr/local/oecore-x86_64/sysroots/armv7a-vfp-neon-nilrt-linux-gnueabi -L/usr/local/oecore-x86_64/sysroots/armv7a-vfp-neon-nilrt-linux-gnueabi/lib"

		export LD="arm-nilrt-linux-gnueabi-ld --sysroot=/usr/local/oecore-x86_64/sysroots/armv7a-vfp-neon-nilrt-linux-gnueabi"
		export LDFLAGS="--sysroot=/usr/local/oecore-x86_64/sysroots/armv7a-vfp-neon-nilrt-linux-gnueabi -L/usr/local/oecore-x86_64/sysroots/armv7a-vfp-neon-nilrt-linux-gnueabi"
		export CHAOS_BOOST_FLAGS="toolset=gcc-arm target-os=linux"
		export CHAOS_CROSS_HOST="arm-nilrt-linux-gnueabi"
		export CHAOS_CMAKE_FLAGS="$CHAOS_CMAKE_FLAGS -DCMAKE_EXE_LINKER_FLAGS=-L/usr/local/oecore-x86_64/sysroots/armv7a-vfp-neon-nilrt-linux-gnueabi/lib"
	    else
		export CHAOS_TARGET=$OS
	    fi
	fi
    fi;
fi

export CXXFLAGS="$CXXFLAGS -DCHAOS"
export CFLAGS="$CFLAGS -DCHAOS"
if [ -n "$CHAOS_DEVELOPMENT" ]; then
    export CHAOS_COMP_TYPE=" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS_DEBUG=-DDEBUG=1 "
    export CXXFLAGS="$CXXFLAGS -g" ## force debug everywhere
    export CFLAGS="$CFLAGS -g"
    #	export CXXFLAGS="$CXXFLAGS -fPIC -fsanitize=thread"
    #	export CFLAGS="$CFLAGS -fPIC -fsanitize=thread"
    #	export LDFLAGS="-pie -ltsan"
else
    export CHAOS_COMP_TYPE=" -DCMAKE_BUILD_TYPE=Release "
fi



if [ -n "$CHAOS_STATIC" ]; then
    export CHAOS_BOOST_FLAGS="$CHAOS_BOOST_FLAGS link=static"
    export CHAOS_CMAKE_FLAGS="$CHAOS_CMAKE_FLAGS -DBUILD_FORCE_STATIC=true"
else
    export CHAOS_BOOST_FLAGS="$CHAOS_BOOST_FLAGS link=shared"
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
export CHAOS_CMAKE_FLAGS="$CHAOS_CMAKE_FLAGS $CHAOS_COMP_TYPE -DCMAKE_INSTALL_PREFIX:PATH=$CHAOS_PREFIX"
