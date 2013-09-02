#!/bin/bash
user_name=$1
repo_name=$2
module_path=$3

if [ ! -n "$user_name" ]; then
	echo "[FATAL]: User name is mandatory!"
	echo "Exiting script"
	exit 1
fi

echo " User password:"
stty -echo
read user_pwd
stty echo
echo $user_pwd
if [ ! -n "$repo_name" ]; then
        echo "[FATAL]: repository name is mandatory!"
        echo "Exiting script"
        exit 1
fi

if [ ! -n "$module_path" ]; then
        echo "[FATAL]: Module path is mandatory!"
        echo "Exiting script"
        exit 1
fi

if [ ! -d "$repo_name" ]; then
	mkdir $repo_name
	cd $repo_name
	git init
	touch README.md
	git add .
	git commit -a -m "Initial commit"
	git checkout -b development

	git_repo_name="$repo_name.git"
	echo $git_repo_name
	echo "Create repo on lnf gerrit server"

	ssh -p 29418 cvs.lnf.infn.it gerrit create-project $repo_name
	if [ $? -gt 0 ]; then
		ssh -p 29418 cvs.lnf.infn.it gerrit set-project-parent --parent chaosframework  $repo_name
		echo "Install lnf remote $repo_name.git"

		git remote add origin https://cvs.lnf.infn.it/$git_repo_name
		git remote add origin_ssh ssh://$user_name@cvs.lnf.infn.it:29418/$git_repo_name

		echo "upload to lnf git"
		git push origin_ssh master development
	
		cd ..
	
		rm -rf $repo_name
	fi
fi

if [  -d "$module_path" ]; then
	echo "[FATAL]: moduel is already installed!"
        echo "Exiting script"
        exit 1

fi

echo "Add the module"
git submodule add -b development https://cvs.lnf.infn.it/$git_repo_name  $module_path

git submodule init
git submodule update --remote

cd $module_path

echo "Create repo on git hub"
curl -u "$user_name:$user_pwd" https://api.github.com/user/repos -d "{\"name\":\"$repo_name\"}"
if [ $? -eq 0 ]; then
	git remote add github_ssh git@github.com:$user_name/$git_repo_name
fi

echo "create repo on bitbucket"
curl -k -X POST --user "$user_name:$user_pwd"  "https://api.bitbucket.org/1.0/repositories" -d "name=$repo_name"
if [ $? -eq 0 ]; then
git remote add bitbucket_ssh git@bitbucket.org:$user_name/$git_repo_name
fi
git remote  add public  git@bitbucket.org:$user_name/$git_repo_name
git remote set-url public --add git@github.com:$user_name/$git_repo_name

echo "pdate public repository"
git push public master development


