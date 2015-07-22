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
on_dir=()



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
git_arg=()
git_cmd=""

while getopts t:c:p:hsd: opt; do
    case $opt in
	t) 
	    echo -n "provide a tag message:"
	    read mesg
	    git_cmd=t
	    ;;
	d) 
	    on_dir+=($OPTARG)
	    ;;
	s) 
	    git_cmd=s
	    ;;
	c) 
	    git_cmd=c
	    git_arg=$OPTARG
	    ;;
	p) 
	    git_cmd=p
	    git_arg=$OPTARG
	    ;;
	h)
	    echo -e "Usage is $0 [-s] [-t <tag name>][ -c <checkout branch> ] [ -p <branch name> ] [-d <directory0>] [-d <directory1>] \n-c <branch name>: check out a given branch name in all subdirs\n-p <branch>:commit and push modifications of a given branch\n-s:retrive the branch status\n-t <tag name>:make an annotated tag to all\n-d <directory>: apply just to the specified directory"
	    exit 0;
	    ;;
    esac

done

if [ ${#on_dir[@]} -eq 0 ]; then
    dirs=$(find . -name ".git" -exec grep -sl opensource \{\}/config \;)
    for d in $dirs;do
	dir=$(dirname $d)
	dir=$(dirname $dir)
	on_dir+=($dir)

    done
fi

if [ ${#on_dir[@]} -eq 0 ]; then
    nok_mesg "no git dirs specified/found"
    exit 1
fi

for dir in ${on_dir[@]}; do
    pushd $dir > /dev/null
    case $git_cmd in
	s)
	    git fetch
	    info_mesg "directory " "$dir"
	    git status 
	    ;;
	
	c)
	    git_checkout $dir $git_arg
	    ;;
	t)
	    git fetch
	    git pull
	    tagname=$(echo "$git_arg" | tr ' ' '-')
	    git tag -f -m "$mesg" $tagname
	    git push
	    ;;
	p)
	    if git status | grep modified > /dev/null; then
		echo -n "modification found on \"$dir\" [branch:$git_arg], empty comment to skip:"
		read mesg
		if [ -n "$mesg" ]; then
			info_mesg "committing changes in " "$dir"
			git commit -m "$mesg" .
			git push > /dev/null
		fi
	    fi
	    
	    ;;
    esac

    popd > /dev/null
done

