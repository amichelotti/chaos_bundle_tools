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

title=$2
echo "* looking in $1"
find $1 -name "*.png"
images_png=`find ./$1 -name "*.png"`
images_gif=`find ./$1 -name "*.gif"`
images_jpg=`find ./$1 -name "*.jpg"`
echo "<!DOCTYPE html>" > index.html
echo "<html>" >> index.html
echo "<body>" >> index.html
echo "<h2>$title</h2>" >> index.html
echo "<table>" >> index.html
# echo "<tr><th>Name</th><th>Image</th></tr>" >> index.html
for img in $images_png $images_gif $images_jpg;do
    echo "* processing $img"
    echo "<tr><td>\"$img\"</td><td><img src=\"$img\" alt=\"$img\" style=\"width:50%;height:50%;\"></td>" >> index.html
done
echo "</table>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html
