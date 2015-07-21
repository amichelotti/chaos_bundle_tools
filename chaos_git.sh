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

mesg=""
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

while getopts t:c:p:hs opt; do
    case $opt in
	t) 
	    echo -n "provide a tag message:"
	    read mesg
	    ;;
    esac

    for d in $git_dirs; do
	dir=$(dirname $d)
	dir=$(dirname $dir)
	pushd $dir > /dev/null
	case $opt in
	    s)
		info_mesg "directory " "$dir"
		git status 
		;;

	    c)
		git_checkout $dir $OPTARG 
		;;
	    t)
		git tag -f -m "$mesg" $OPTARG
		git push
		;;
	    p)
		if git status | grep modified > /dev/null; then
		    echo -n "modification found on \"$dir\" [branch:$OPTARG], empty comment to skip:"
		    read mesg
		    if [ -n "$mesg" ]; then
			info_mesg "committing changes in " "$dir"
			git commit -m "$mesg" .
			git push > /dev/null
		    fi
		fi
		
		;;
	    h)
		echo -e "Usage is $0 [-s] [-t <tag name>][ -c <checkout branch> ] [ -p <branch name> ]\n-c <branch name>: check out a given branch name in all subdirs\n-p <branch>:commit and push modifications of a given branch\n-s:retrive the branch status\n-t <tag name>:make an annotated tag to all"
		exit 0;
		;;
	esac
	popd > /dev/null
    done
done
