#!/bin/bash

separator='-'
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null

source $dir/common_util.sh
err=0

prefix_build=chaos
outbase=$dir/../
create_deb_ver=""
remove_working="false"
log="$0.log"
exclude_dir=()

git_dirs=$(find . -name ".git" -exec grep -sl opensource \{\}/config \;)


die(){
    error_mesg "$1" " exiting... "
    exit 1
}

git_checkout(){
    dir=$1
    git fetch || die "fetching $dir"
    if git checkout "$2" ; then
	ok_mesg "$dir checkout $2"
	if git pull ;then
	   ok_mesg "synchronize $dir"
	else
	    nok_mesg "synchronize $dir"
	fi
    else
	error_mesg "checking out $2 in " "$dir"
	return 1 
    fi

    return 0
   
}

while getopts c:p:hs opt; do
    case $opt in
	s)
	    for d in $git_dirs; do
		dir=$(dirname $d)
		dir=$(dirname $dir)
		pushd $dir > /dev/null
		info_mesg "directory " "$dir"
		git status 
		popd > /dev/null
	    done
	    ;;

	c)
	    for d in $git_dirs; do
		dir=$(dirname $d)
		dir=$(dirname $dir)
		pushd $dir >& /dev/null
		git_checkout $dir $OPTARG 
		popd > /dev/null
	    done
	    ;;
	p)

	    echo -n "commit/push message for branch $OPTARG:"
	    read mess
	    for d in $git_dirs; do
		dir=$(dirname $d)
		dir=$(dirname $dir)
		pushd $dir > /dev/null
		if git status | grep modified > /dev/null; then
		    info_mesg "committing changes in " "$dir"
		    git commit -m "$mess" .
		fi
		git push > /dev/null
		popd > /dev/null
	    done
	    ;;
	h)
	    echo -e "Usage is $0 [-s] [ -c <checkout branch> ] [ -p <commit and push branch> ]\n-c <branch name>: check out a given branch name in all subdirs\n-p <branch name>:commit and push a given branch\n-s:retrive the branch status"
	    exit 0;
	    ;;
    esac
done
