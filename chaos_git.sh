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
    if git fetch; then
	error_mesg "[$dir] cannot fetch"
	return 1
    fi

    if git checkout "$2" ; then
	ok_mesg "$dir checkout $2"
	if git pull ;then
	    ok_mesg "synchronize $dir"
	else
	    nok_mesg "synchronize $dir"
	    return 1
	fi
    else
	error_mesg "checking out $2 in " "$dir"
	return 1 
    fi

    return 0
   
}
git_arg=()
git_cmd=""

usage(){
    echo -e "Usage is $0 [-s] [-t <tag name>][ -c <checkout branch> ] [ -p <branch name> ] [-d <directory0>] [-d <directory1>] \n-c <branch name>: check out a given branch name in all subdirs\n-p <branch>:commit and push modifications of a given branch\n-s:retrive the branch status\n-t <tag name>:make an annotated tag to all\n-d <directory>: apply just to the specified directory\n-m <src branch> <dst branch>: merge src into dst branch\n"
}
while getopts t:c:p:hsd:m opt; do
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
	m)  git_cmd=m
	    
	    ;;
	h)
	    usage
	    exit 0
	    ;;
    esac

done
shift $(( OPTIND - 1 ))

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
	m)  
	    
	    if [ -z "$1" ] || [ -z "$2" ];then
		echo "## expected source branch and destination branch"
		usage
		exit 1
	    fi
	    echo -n "[$dir] merging branch:\"$1\" in branch:\"$2\", empty comment to skip:"
	    read mesg
	    if [ -n "$mesg" ]; then
		if git_checkout $dir $2; then
		    if git merge -m "$mesg" --no-ff $1;then
			info_mesg "[$dir] merge " "done"
		    else
			error_mesg "[$dir] error merging $1 -> $2, skipping merge"
		    fi
		fi
	    fi
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
		echo -n "[$dir] modification found on [branch:$git_arg], empty comment to skip:"
		read mesg
		if [ -n "$mesg" ]; then
			if git commit -m "$mesg" .;then
			    info_mesg "[$dir] commit " "done"
			    if git push > /dev/null; then
				info_mesg "[$dir] push " "done"
			    else
				error_mesg "[$dir] cannot push"
			    fi
			else
			    error_mesg "[$dir] cannot commit"
			fi

		fi
	    fi
	    
	    ;;
    esac

    popd > /dev/null
done

