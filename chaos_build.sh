#!/bin/bash

pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null
err=0
OS=`uname -s`
ARCH=`uname -m`
prefix_build=chaos-dev
outbase=$dir/../
create_deb_ver=""
remove_working="false"
log="$0.log"

if [ "$OS" == "Linux" ]; then
    compile_type=( "dynamic" "static" );
    compile_target=( "$ARCH" "armhf" );
    compile_build=("release" "debug")
else
    compile_type=("dynamic");
    compile_target=("$ARCH");
    compile_build=("release" "debug")
fi

type=${compile_type[0]}
target=${compile_target[0]}
build=${compile_build[0]}
tgt=$prefix_build-$target-$type-$build
prefix=$outbase/$tgt
log=$outbase/$tgt.log
while getopts t:o:w:b:p:hd:rs opt; do
    case $opt in
	t)
	    compile_target=($OPTARG);
	    echo "* setting target to $compile_target";
	    ;;
	o) 
	    compile_type=($OPTARG);
	    echo "* setting type to $compile_type";
	    ;;
	b) 
	    compile_build=($OPTARG);
	    echo "* setting build to $compile_build";
	    ;;
	r) 
	    remove_working=true;
	    echo "* remove working as done";
	    ;;

	w) 
	    if [ -d "$OPTARG"]; then
		echo "* Using $OPTARG as working directory";
		outbase=$OPTARG
	    else
		echo "## bad working directory $OPTARG"
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
	s)
	    switch_env=true
	    echo "* switching environment";
	    ;;


	h)
	    echo -e "Usage is $0 [-w <work directory>] [-s] [-t <armhf|$ARCH>] [-o <static|dynamic> [-b <debug|release>] [-p <build prefix>] [-d <deb version>] [-r]\n-w <work directory>: where directories are generated [$outbase]\n-t <target>: cross compilation target [${compile_target[@]}]\n-o <static|dynamic>: enable static or dynamic compilations [${compile_type[@]}]\n-b <build type> build type [${compile_build[@]}]\n-p <build prefix>: prefix to add to working directory [$prefix_build]\n-d <version>: create a deb package of the specified version\n-r: remove working directory after compilation\n-s:switch environment to precompiled one (skip compilation) [$tgt]\n";
	    exit 0;
	    ;;
    esac
done

type=${compile_type[0]}
target=${compile_target[0]}
build=${compile_build[0]}
tgt=$prefix_build-$target-$type-$build
prefix=$outbase/$tgt
log=$outbase/$tgt.log


function unSetEnv(){
    unset CHAOS_BUNDLE
    unset CHAOS_STATIC
    unset CHAOS_TARGET
    unset CHAOS_PREFIX
    unset CHAOS_DEVELOPMENT
}
# type target build
function setEnv(){
    local type=$1
    local target=$2
    local build=$3
    local prefix=$4
    unSetEnv ;
    if [ "$type" == "static" ]; then
	export CHAOS_STATIC=true
    fi
    if [ "$target" == "armhf" ]; then
	export CHAOS_TARGET=armhf
    fi
	    
    if [ "$build" == "debug" ]; then
	export CHAOS_DEVELOPMENT=true
    fi
    if [ -d "$prefix" ]; then
	export CHAOS_PREFIX=$prefix
    else
	echo "## directory $prefix is invalid"
	exit 1
    fi
    echo "* Target        :$target"
    echo "* Type          :$type"
    echo "* Configuration :$build"
    echo "* Prefix        :$prefix"
    source $dir/chaos_bundle_env.sh >& $log
    rm -rf $CHAOS_BUNDLE/usr $CHAOS_FRAMEWORK/usr $CHAOS_FRAMEWORK/usr/local
    mkdir -p $CHAOS_BUNDLE/usr
    mkdir -p $CHAOS_FRAMEWORK/usr
    ln -sf $prefix $CHAOS_FRAMEWORK/usr/local
    

}
function compile(){
    $dir/chaos_clean.sh >& /dev/null
    echo "* compiling $tgt ...."
    echo -e '\n\n' | $dir/init_bundle.sh >& $log;
    
}
function saveEnv(){
    
    echo "echo \"* Environment $tgt\"" > $prefix/chaos_env.sh
    if [ -n "$CHAOS_STATIC" ];then
	echo "export CHAOS_STATIC=true" >> $prefix/chaos_env.sh
    fi
    if [ -n "$CHAOS_DEVELOPMENT" ];then
	echo "export CHAOS_DEVELOPMENT=true" >> $prefix/chaos_env.sh
    fi
    if [ -n "$CHAOS_TARGET" ];then
	echo "export CHAOS_TARGET=$CHAOS_TARGET" >> $prefix/chaos_env.sh
    fi
    echo "export CHAOS_PREFIX=\$PWD" >> $prefix/chaos_env.sh
    echo "export CHAOS_BUNDLE=\$CHAOS_PREFIX" >> $prefix/chaos_env.sh
    echo "export PATH=\$PATH:\$CHAOS_BUNDLE/bin:\$CHAOS_BUNDLE/tools" >> $prefix/chaos_env.sh
    
}

echo "* OS:\"$OS\""

if [ -n "$switch_env" ]; then

    setEnv $type $target $build $prefix
    exit 0
fi

for type in ${compile_type[@]} ; do
    for target in ${compile_target[@]} ; do
	for build in ${compile_build[@]} ; do
	    error=0
	    tgt=$prefix_build-$target-$type-$build
	    log=$outbase/$tgt.log
	    prefix=$outbase/$tgt
	    rm -rf $prefix
	    mkdir -p $prefix
	    setEnv $type $target $build $prefix
	    compile $tgt;
	    if [ $? -ne 0 ]; then 
		((err++))
		echo "## Error $err compiling $tgt"
		error=1
	    else
		echo "* generating Unit Server"
		if $dir/chaos_generate_us.sh -i $dir/../driver -o $prefix -n UnitServer >> $log 2>&1 ; then
		    pushd $prefix/UnitServer > /dev/null
		    if cmake . >> $log ; then
			
			if  make install >> $log 2>&1 ; then
			    echo "* UnitServer successfully installed"
			else
			    echo "## error compiling UnitServer \"$log\" for details" 
			    ((err++))
			    error=1
			fi
		    else
			echo "## error during Unit Server makefile generation"
			((err++))
			error=1
		    fi
		    popd > /dev/null
		else
		    echo "## error during generation of Unit Server"
		    ((err++))
		    error=1
		fi
	    fi

	    if (($error == 0)); then
		echo -e "* OK compilation $tgt"
		saveEnv
		cp -r $CHAOS_BUNDLE/tools $prefix
		if [ -n "$create_deb_ver" ]; then
		    nameok=`echo $tgt | sed s/_/-/g`
		    $dir/chaos_debianizer.sh $nameok $prefix $create_deb_ver
		fi
	    fi
	
	    if [ "$remove_working" == "true" ]; then
		echo "* removing $nameok"
		rm -rf $prefix
	    fi
	    echo 
	done
    done
done;

if [ $err -gt 0 ]; then
    echo "## Number of errors $err"
    exit $err
fi 
echo "* OK"
