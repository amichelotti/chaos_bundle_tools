
SOURCE="${BASH_SOURCE[0]}"

pushd `dirname $SOURCE` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

export CHAOS_BUNDLE="$(dirname "$SCRIPTPATH")"

#boostrap !CHAOS Framework in development mode
export CHAOS_DEVELOPMENT="YES"
export CHAOS_FRAMEWORK=$CHAOS_BUNDLE/chaosframework
export PATH=$CHAOS_BUNDLE/tools:$CHAOS_BUNDLE/usr/local/bin:$PATH
export DYLD_LIBRARY_PATH=$CHAOS_BUNDLE/usr/local/lib
export LD_LIBRARY_PATH=$CHAOS_BUNDLE/usr/local/lib:$LD_LIBRARY_PATH
#set default compile lib
export CHAOS_LINK_LIBRARY="boost_program_options boost_system boost_thread boost_chrono boost_regex boost_log boost_log_setup boost_filesystem memcached zmq uv dl"

if [ $(uname -s) == "Linux" ]; then
    export CHAOS_BOOST_VERSION=55
else
    export CHAOS_BOOST_VERSION=53
fi;

#export MONGO_VERSION=r2.6.1
export MONGO_VERSION=26compat
export LIB_EVENT_VERSION=release-2.1.4-alpha

if [ "$CHAOS_TARGET" == "BBB" ]; then
    export LMEM_VERSION=1.0.18
     echo "* using libmemcached version $LMEM_VERSION"

fi;
