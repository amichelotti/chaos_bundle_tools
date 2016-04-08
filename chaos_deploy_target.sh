#!/bin/bash -e

separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

source $dir/common_util.sh
OPT=""
Usage(){
    echo "$0 <configuration of the target>"
}
if [ ! -f "$1" ];then
    error_mesg "you must specify a valid configuration name"
    Usage;
    exit 1
fi
confdir=`dirname $1`
source $1

if [ -z "$CHAOS_BUNDLE" ]; then 
    error_mesg "a CHAOS_BUNDLE source directory must be defined"
    exit 1
fi
if [ -z "$DEPLOY_TARGET_DIR" ];then
    DEPLOY_TARGET_DIR=/root
fi

if [ -z "$TARGET" ]; then 
    error_mesg "a TARGET platform must be defined"
    exit 1
fi
if [ -z "$RELEASE" ]; then 
    error_mesg "a RELEASE (dynamic static) must be defined"
    exit 1
fi
if [ -z "$DEPLOY_TARGET_LIST" ]; then 
    error_mesg "a DEPLOY_TARGET_LIST (list of targets) must be defined"
    exit 1
else
    DEPLOY_TARGET_LIST=$confdir/$DEPLOY_TARGET_LIST
fi

if [ -z "$CONFIGURATION" ]; then 
    CONFIGURATION="release"
fi
if [ "$FORCE_REBUILD" == "YES" ]; then 
    OPT="-f"
fi

if [ -z "$DEPLOY_METHOD" ]; then 
    DEPLOY_METHOD="sysctl"
fi
if [ -z "$USER" ];then
    USER=root
fi
if [ "$USER" == "root" ];then
    PREFIX_CMD=""
else
    PREFIX_CMD="sudo"
fi
case $DEPLOY_METHOD in
    "sysctl") 
	CMD_START="initctl start chaos-us"
	CMD_STOP="initctl stop chaos-us"
	;;
    "upstart")
	CMD_START="$PREFIX_CMD service chaos-us start"
	CMD_STOP="$PREFIX_CMD service chaos-cu stop "
	;;
    *)
	CMD_START="/etc/init.d/$DEPLOY_METHOD start"
	CMD_STOP="/etc/init.d/$DEPLOY_METHOD stop"
	;;
    esac;

echo "* using $CHAOS_BUNDLE"

cd $CHAOS_BUNDLE
if [ -n "$CROSS_TOOL_PATH" ];then
    info_mesg "using cross tool compiler in $CROSS_TOOL_PATH"
    PATH=$CROSS_TOOL_PATH/bin:$PATH
fi
BASE=chaos-$TARGET-$RELEASE-$CONFIGURATION

./tools/chaos_build.sh -t $TARGET -o $RELEASE -b $CONFIGURATION $OPT 
info_mesg "creating tar " "$BASE.tar.gz"
 
if [ "$RELEASE" == "dynamic" ];then
    info_mesg "creating " "$BASE.tar.gz"
    tar cfz $BASE.tar.gz $BASE    
else
    LIST_FILES=""
    for ff in $DEPLOY_FILE_LIST;do
	LIST_FILES="$BASE/bin/$ff $LIST_FILES"
	info_mesg "adding " "$ff"
    done
    tar cfz $BASE.tar.gz $LIST_FILES
fi
info_mesg "deploy list " "$DEPLOY_TARGET_LIST"

./tools/chaos_remote_copy.sh -u $USER -s $BASE.tar.gz -d $DEPLOY_TARGET_DIR $DEPLOY_TARGET_LIST
./tools/chaos_remote_command.sh -u $USER -c "$CMD_STOP" $DEPLOY_TARGET_LIST
./tools/chaos_remote_command.sh -u $USER -c "cd $DEPLOY_TARGET_DIR;tar xvfz $BASE.tar.gz" $DEPLOY_TARGET_LIST
./tools/chaos_remote_command.sh -u root -c "$CMD_START" $DEPLOY_TARGET_LIST 

echo "$confdir successfully installed"

