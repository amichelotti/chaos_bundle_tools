#!/bin/bash
# 1 dir to look
# 2 title
if [ -z "$1" ]; then
    echo "# you must provide start directory"
    exit 1
fi

if [ -z "$2" ]; then
    echo "# you must provide a title"
    exit 1
fi
resize=100
if [ -n "$3" ]; then
    resize=$3
fi

title=$2


images_png=`find ./$1 -name "*.png"`
images_gif=`find ./$1 -name "*.gif"`
images_jpg=`find ./$1 -name "*.jpg"`
echo "<!DOCTYPE html>"
echo "<html>" 
echo "<body>" 
echo "<h2>$title</h2>" 
echo "<table>" 
# echo "<tr><th>Name</th><th>Image</th></tr>" >> index.html
for img in $images_png $images_gif $images_jpg;do
    echo "<tr><td>\"$img\"</td><td><img href=\"$img\" alt=\"$img\" style=\"width:$resize%;height:$resize%;\"></td>" 
done
echo "</table>" 
echo "</body>" 
echo "</html>"
