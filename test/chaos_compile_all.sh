#!/bin/bash

pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null
err=0
OS=`uname -s`
ARCH=`uname -m`
prefix_build=chaos-dev
outbase=$dir/../../
create_deb_ver=""
if [ "$OS" == "Linux" ]; then
    compile_type=( "dynamic" "static" );
    compile_target=( "$ARCH" "armhf" );
    compile_build=("release" "debug")
else
    compile_type=("dynamic");
    compile_target=("host");
    compile_build=("release" "debug")
fi

while getopts t:o:i:b:p:hd: opt; do
    case $opt in
	t)
	    compile_target=($OPTARG);
	    echo "* setting compilation target to $compile_target";
	    ;;
	o) 
	    compile_type=($OPTARG);
	    echo "* setting compilation type to $compile_type";
	    ;;
	b) 
	    compile_build=($OPTARG);
	    echo "* setting compilation build to $compile_build";
	    ;;

	i) 
	    if [ -d "$OPTARG"]; then
		echo "* Using $OPTARG as test base directory";
		outbase=$OPTARG
	    else
		echo "## bad installation directory $OPTARG"
		exit -1
	    fi
	    ;;
	p)
	    prefix_build="$OPTARG"
	    echo "* prefix $prefix_build"
	    ;;
	d)
	    create_deb_ver="$OPTARG"
	    echo "* create debian package"
	    ;;

	h)
	    echo "Usage is $0 [-i <test base directory] [-t <armhf|$ARCH>] [-o <static|dynamic> [-b <debug|release>] [-p <build prefix>] [-d <deb version>]";
	    exit 0;
	    ;;
    esac
done




function unSetEnv(){
    unset CHAOS_BUNDLE
    unset CHAOS_STATIC
    unset CHAOS_TARGET
    unset CHAOS_PREFIX
    unset CHAOS_DEVELOPMENT
}

function setEnvAndCompile(){
    echo "* Starting target $1"
    source $dir/../chaos_bundle_env.sh
    $dir/../chaos_clean.sh >& /dev/null
    echo -e '\n\n' | $dir/../init_bundle.sh >& $outbase/$1.log;
}


echo "* OS:\"$OS\""


for type in ${compile_type[@]} ; do
    for target in ${compile_target[@]} ; do
	for build in ${compile_build[@]} ; do
	    echo "* Compiling for targets:$target"
	    echo "* Compiling type       :$type"
	    echo "* Compiling build      :$build"
	    unSetEnv ;
	    if [ "$type" == "static" ]; then
		export CHAOS_STATIC=true
	    fi
	    if [ "$target" == "arm" ]; then
		export CHAOS_TARGET=BBB
	    fi
	    
	    if [ "$build" == "debug" ]; then
		export CHAOS_DEVELOPMENT=true
	    fi
	    tgt=$prefix_build-$target-$type-$build
	    rm -rf $outbase/$tgt
	    mkdir -p $outbase/$tgt
	    export CHAOS_PREFIX=$outbase/$tgt
	    setEnvAndCompile $tgt;
	    if [ $? -ne 0 ]; then 
		((err++))
		echo "## Error $err compiling $tgt"
	    else
		echo "* OK $tgt"
		if [ -n "$create_deb_ver" ]; then
		    nameok=`echo $tgt | sed s/_/-/g`
		    $dir/../chaos_debianizer.sh $nameok $CHAOS_PREFIX $create_deb_ver
		fi
	    fi
	done
    done
done;

if [ $err -gt 0 ]; then
    echo "## Number of errors $err"
    exit $err
fi 
echo "* OK"
