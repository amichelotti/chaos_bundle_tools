
SOURCE="${BASH_SOURCE[0]}"

pushd `dirname $SOURCE` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

export CHAOS_BUNDLE="$(dirname "$SCRIPTPATH")"

#boostrap !CHAOS Framework in development mode
export CHAOS_DEVELOPMENT="YES"
export CHAOS_FRAMEWORK=$CHAOS_BUNDLE/chaosframework
export PATH=$PATH:$CHAOS_BUNDLE/tools:$CHAOS_BUNDLE/usr/local/bin
export DYLD_LIBRARY_PATH=$CHAOS_BUNDLE/usr/local/lib
export LD_LIBRARY_PATH=$CHAOS_BUNDLE/usr/local/lib
