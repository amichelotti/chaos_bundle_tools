export CHAOS_TARGET=armhf
SOURCE="${BASH_SOURCE[0]}"

pushd `dirname $SOURCE` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null
echo "CHAOS_TARGET: $CHAOS_TARGET"
source $SCRIPTPATH/chaos_bundle_env.sh
