#!/bin/bash
## create_template.sh <name> <type [rtcu|sccu|driver|common]> [output_dir]

pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null

source $SCRIPTPATH/common_util.sh

user_paths=1
execname=$(basename $0)

echo "Template creation tool"
valid_templates="rtcu sccu driver common"
usage(){
    echo -e "usage is $execname [-o outputdir] [-n] <template name> <template type [$valid_templates]>\n-o <output directory>\n-n:skip git\n"
}

while getopts o:n opt; do
    case $opt in
	o) 
	    destination_directory=$OPTARG
	    ;;
	n) skip_git=true
	    ;;
	*) usage;exit 1
	    ;;
    esac
done
shift $(($OPTIND-1))
template_name=$1
template_type=$2

if [ ! -n "$template_name" ]; then
	echo "[FATAL]: the name of the template is mandatory"
	usage;
	echo "Exiting ..."
	exit 1
fi

if [ ! -n "$template_type" ]; then
	echo "[FATAL]: the template type is mandatory -> [$valid_templates]"
	echo "Exiting ..."
	exit 1
fi
found=""
for t in $valid_templates;do

    if [ "$template_type" == "$t" ];then
	found=$t;

    fi
done

if [ -z "$found" ];then
    echo "[FATAL]: bad template type \"$template_type\", valid types are: [$valid_templates]"
    echo "Exiting ..."
    exit 1
fi


echo "Start $template_name [$template_type] creation"

if [ ! -n "$destination_directory" ]; then
    if [ "$template_type" == "rtcu" ] || [ "$template_type" == "sccu" ]; then
	destination_directory="$SCRIPTPATH/../user_control_unit/"
    else
	destination_directory="$SCRIPTPATH/../$template_type/"
    fi
    user_paths=0
fi

if [ -d "$destination_directory/$template_name" ]; then
	echo "[FATAL]: Control unit directory \"$destination_directory/$template_name\" is already present"
	echo "Exiting..."
	exit 1
fi

# rm -rf $destination_directory
mkdir -p $destination_directory

echo "Create project files into $destination_directory/$template_name"
cp -r "$SCRIPTPATH/project_template/$template_type.tmpl"  $destination_directory
cd $destination_directory
mv $template_type.tmpl $template_name

echo "rename project files"
cd $template_name
touch README.md

sed -e "s/__template_name__/$template_name/g" CMakeLists_tmpl.txt | sed -e "s/__template_type__/$template_type/g"> CMakeLists.txt
rm CMakeLists_tmpl.txt

mv __template_name__.xcodeproj "${template_name}.xcodeproj"
if [ "$template_type" == "driver" ]; then
	sed -e "s/__template_name__/$template_name/g" source/__template_name__ControlUnit.cpp | sed -e "s/__template_type__/$template_type/g" > "source/${template_name}ControlUnit.cpp"
	rm source/__template_name__ControlUnit.cpp

	sed -e "s/__template_name__/$template_name/g" source/__template_name__ControlUnit.h | sed -e "s/__template_type__/$template_type/g" > "source/${template_name}ControlUnit.h"
	rm source/__template_name__ControlUnit.h

	sed -e "s/__template_name__/$template_name/g" source/__template_name__Driver.cpp | sed -e "s/__template_type__/$template_type/g" > "source/${template_name}Driver.cpp"
	rm source/__template_name__Driver.cpp

	sed -e "s/__template_name__/$template_name/g" source/__template_name__Driver.h | sed -e "s/__template_type__/$template_type/g" > "source/${template_name}Driver.h"
	rm source/__template_name__Driver.h

	sed -e "s/__template_name__/$template_name/g" source/__template_name__DriverSwitch.cpp | sed -e "s/__template_type__/$template_type/g" > "source/${template_name}DriverSwitch.cpp"
	rm source/__template_name__DriverSwitch.cpp
else
    
    sed -e "s/__template_name__/$template_name/g" source/__template_name__.cpp | sed -e "s/__template_type__/$template_type/g" > "source/${template_name}.cpp"
    rm source/__template_name__.cpp

    sed -e "s/__template_name__/$template_name/g" source/__template_name__.h | sed -e "s/__template_type__/$template_type/g" > "source/${template_name}.h"
    rm source/__template_name__.h
    for j in source test; do
	for i in Driver Interface Client CommandSample DefaultCommand SampleCommand; do
	    if [ -f "$j/__template_name__$i.h" ]; then
		echo "* generating $j/${template_name}$i.h"
	    	sed -e "s/__template_name__/$template_name/g" $j/__template_name__$i.h | sed -e "s/__template_type__/$template_type/g" > "$j/${template_name}$i.h"
		rm $j/__template_name__$i.h
	    fi
	    if [ -f "$j/__template_name__$i.cpp" ]; then
		echo "* generating $j/${template_name}$i.cpp"
		sed -e "s/__template_name__/$template_name/g" $j/__template_name__$i.cpp | sed -e "s/__template_type__/$template_type/g" > "$j/${template_name}$i.cpp"
		rm $j/__template_name__$i.cpp
	fi
	    
	done;
    done;
fi

sed -e "s/__template_name__/$template_name/g" source/main.cpp | sed -e "s/__template_type__/$template_type/g" > source/main_mod.cpp
rm source/main.cpp
mv source/main_mod.cpp source/main.cpp

echo "Patching xcode project"
cd "${template_name}.xcodeproj"
## patch schemes
find . -name "*.xcscheme" -exec bash -c 'a=${0/__template_name__/$1};b=${a/__template_type__/$2}; if [ "$0" != "$b" ]; then sed -e s/__template_name__/$1/g $0 | sed -e "s/__template_type__/$2/g" > $b; echo "generating $b"; rm $0;fi' {} $template_name $template_type \;

if [[ -d "$CHAOS_FRAMEWORK" && $user_paths -eq 1 ]] ; then
tmpstr=`echo "$CHAOS_FRAMEWORK" | sed -e 's/\//\\\\\//g'`

sed -e "s/__template_name__/$template_name/g" project_tmpl.pbxproj| sed "s/\$(SRCROOT)\/..\/../$tmpstr/g"  | sed -e "s/__template_type__/$template_type/g" >project.pbxproj

else
sed -e "s/__template_name__/$template_name/g" project_tmpl.pbxproj | sed -e "s/__template_type__/$template_type/g" > project.pbxproj
fi

rm project_tmpl.pbxproj

# cd project.xcworkspace
## patch workspace data
for i in '*'.xcworkspacedata '*'.plist ; do
find . -name "$i" -exec bash -c 'a=${0/_tmpl./.}; sed -e s/__template_name__/$1/g $0 | sed -e "s/__template_type__/$2/g" > $a; echo "generating $a";if  [ "$0" != "$a" ];then echo "removing $0"; rm $0;fi' {} $template_name $template_type \;
done
if [ -z "$skip_git" ];then

    echo -e "\033[38;5;148mPress any key to initialize git on $template_name or CTRL+C to exit\033[39m"
    read -n 1 -s

    cd $destination_directory/$template_name

    git init
    echo "copy ignore default file"
    cp $SCRIPTPATH/gitignore_tmpl .gitignore
    
    git add .
    git commit -a -m "Initial commit"
    git checkout -b development
    
    echo "Generate script for default gerrit lnf server and github"
    sed -e "s/__chaos_project_type__/$template_type/g" $SCRIPTPATH/.ChaosCreateOfficialRepository_tmpl > ChaosCreateOfficialRepository.sh
    sed -e "s/__chaos_project_type__/$template_type/g" $SCRIPTPATH/.ChaosCreateGitHubRepository_tmpl > ChaosCreateGitHubRepository.sh
fi
