#!/bin/bash

separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

source $dir/common_util.sh
err=0

prefix_build=chaos_dev
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

while getopts t:o:w:b:p:hd:rsc:k opt; do
    case $opt in
	t)
	    compile_target=($OPTARG);
	    info_mesg "setting target to " "$compile_target";
	    ;;
	o) 
	    if [[ ${compile_type[@]} =~ $OPTARG ]]; then 
		compile_type=($OPTARG);
		info_mesg "setting type to " "$compile_type";
	    else
		error_mesg "compile type one of: ${compile_type[@]}"
		exit 1
	    fi
	    ;;
	b) 
	    if [[ ${compile_build[@]} =~ $OPTARG ]]; then 
		compile_build=($OPTARG);
		info_mesg "setting build to " "$compile_build";
	    else
		error_mesg "compile build one of ${compile_build[@]}"
		exit 1
	    fi
	    ;;
	r) 
	    remove_working=true;
	    info_mesg "remove working as done";
	    ;;

	w) 
	    if [ -d "$OPTARG" ]; then
		outbase=$OPTARG
		info_mesg "* Using working directory " "$outbase";
	    else
		error_mesg "bad working directory " "$OPTARG"
		exit -1
	    fi
	    ;;
	p)
	    prefix_build="$OPTARG"
	    info_mesg "prefix " "$prefix_build"
	    ;;
	k)
	    perform_test=true
	    info_mesg "execute test after build"
	    ;;
	d)
	    create_deb_ver="$OPTARG"
	    info_mesg "create debian package version" "$create_deb_ver"
	    ;;
	s)
	    switch_env=true
	    info_mesg "switching environment";
	    ;;
	c)
	    config="$OPTARG"
	    if [ ! -d "$config" ]; then
		error_mesg "directory $config in invalid"
		exit 1
	    else
		info_mesg "configuring environment in " "$config";
	    fi
	    ;;


	h)
	    echo -e "Usage is $0 [-w <work directory>] [-k] [-s] [-t <armhf|$ARCH>] [-o <static|dynamic> [-b <debug|release>] [-p <build prefix>] [-d <deb version>] [-r] [-c <directory to configure>]\n-w <work directory>: where directories are generated [$outbase]\n-t <target>: cross compilation target [${compile_target[@]}]\n-o <static|dynamic>: enable static or dynamic compilations [${compile_type[@]}]\n-b <build type> build type [${compile_build[@]}]\n-p <build prefix>: prefix to add to working directory [$prefix_build]\n-d <version>: create a deb package of the specified version\n-r: remove working directory after compilation\n-s:switch environment to precompiled one (skip compilation) [$tgt]\n-c <dir>:configure installation directory (etc,env,tools)\n-k:perform test suite after build\n";
	    exit 0;
	    ;;
    esac
done

type=${compile_type[0]}
target=${compile_target[0]}
build=${compile_build[0]}


init_tgt_vars(){
    tgt="$prefix_build""$separator""$target""$separator""$type""$separator""$build"

    PREFIX=`echo "$outbase/$tgt"|sed 's/\/\{2,\}/\//g' | sed 's/\/\w*\/\.\{2\}//g'`
    log=$outbase/$tgt.log
}


init_tgt_vars;





function compile(){
    $dir/chaos_clean.sh >& /dev/null
    info_mesg "log on " "$log"
    info_mesg "compiling " "$tgt ...."
    echo -e '\n\n' | $dir/init_bundle.sh >& $log;
    
}


if [ -n "$switch_env" ]; then

    setEnv $type $target $build $PREFIX
    exit 0
fi

if [ -n "$config" ]; then
    PREFIX=$config
    setEnv $type $target $build $PREFIX
    chaos_configure
    exit 0
fi



for type in ${compile_type[@]} ; do
    for target in ${compile_target[@]} ; do
	for build in ${compile_build[@]} ; do
	    error=0
	    init_tgt_vars;
	    rm -rf $PREFIX
	    mkdir -p $PREFIX
	    unSetEnv
	    setEnv $type $target $build $PREFIX
	    start_profile_time
	    compile $tgt;
	    if [ $? -ne 0 ]; then 
		((err++))
		error_mesg "Error $err compiling $tgt"
		error=1
	    else
		if [ "$OS" == "Linux" ]; then
		info_mesg "generating " "Unit Server.."
		echo "==== GENERATING UNIT SERVER ====" >> $log 2>&1 
		if $dir/chaos_generate_us.sh -i $dir/../driver -o $PREFIX -n UnitServer >> $log 2>&1 ; then
		    pushd $PREFIX/UnitServer > /dev/null
		    if cmake . >> $log ; then
			
			if  make install >> $log 2>&1 ; then
			    info_mesg "UnitServer " "successfully installed"
			else
			    error_mesg "error compiling UnitServer \"$log\" for details" 
			    ((err++))
			    error=1
			fi
		    else
			error_mesg "error during Unit Server makefile generation"
			((err++))
			error=1
		    fi
		    popd > /dev/null
		else
		    error_mesg "error during generation of Unit Server"
		    ((err++))
		    error=1
		fi
		else
		    info_mesg "skipping UnitServer on $OS"
		fi

		for i in sccu rtcu common driver;do
		    info_mesg "testing template " "$i"
		    rm -rf /tmp/_prova_"$i"_
		    echo "==== TESTING TEMPLATE $i ====" >> $log 2>&1 
		    if  $dir/chaos_create_template.sh -o /tmp -n _prova_"$i"_ $i >> $log 2>&1 ;then
			mkdir -p /tmp/_prova_"$i"_
			pushd /tmp/_prova_"$i"_ >/dev/null
			if cmake .  >> $log 2>&1 ; then
			    if ! make -j $NPROC >> $log 2>&1 ;then 
				error_mesg "error during compiling $i template"
				((err++))
				error=1
			    else
				ok_mesg "template $i"

			    fi
			else
			    error_mesg "error  generating makefile for $i"
			    ((err++))
			    error=1
			fi
			popd >/dev/null
			rm -rf /tmp/_prova_"$i"_
		    else
			error_mesg "error during generation of $i template"
			((err++))
			error=1
			
		    fi

		done
	    fi

	    if (($error == 0)); then
		tt=$(end_profile_time)
		info_mesg "compilation ($tt s) " "$tgt OK"
		chaos_configure
		if [ -n "$perform_test" ];then
		    if [ "$ARCH" == "$target" ];then
			info_mesg "Starting chaos testsuite (it takes some time), test report file" "test-$tgt.csv"
			start_profile_time
			echo "===== TESTING ====" >> $log 2>&1 
			if [ "$build" == "debug" ];then
			      $PREFIX/tools/chaos_test.sh -g -r test-$tgt.csv >> $log 2>&1 
			else
			    $PREFIX/tools/chaos_test.sh -r test-$tgt.csv >> $log 2>&1 
			fi
			status=$?
			tt=$(end_profile_time)
			if [ $status -eq 0 ];then
			    ok_mesg "TEST RUN ($tt s)"
			else
			    nok_mesg "TEST RUN ($tt s)"
			fi
		    else
			info_mesg "test skipped on cross compilation"
		    fi
		fi
		if [ -n "$create_deb_ver" ]; then
		    nameok=`echo $tgt | sed s/_/-/g`
		    if $dir/chaos_debianizer.sh $nameok $PREFIX $create_deb_ver >> $log 2>&1; then
			ok_mesg "debian package generated"
		    fi
		fi
	    fi
	
	    if [ "$remove_working" == "true" ]; then
		info_mesg "removing " "$nameok"
		rm -rf $PREFIX
	    fi
	    echo 
	done
    done
done;

if [ $err -gt 0 ]; then
    error_mesg "Number of errors $err"
    exit $err
fi 
ok_mesg "building"
