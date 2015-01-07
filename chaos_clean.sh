#!/bin/bash
dir=`dirname $0`
chaos_bundle=$dir/..
echo "* cleaning $chaos_bundle/usr"
rm -rf $chaos_bundle/usr
echo "* cleaning $chaos_bundle/chaosframework/bin"
rm -rf $chaos_bundle/chaosframework/bin

find $chaos_bundle -name "CMakeFiles" -exec rm -rf \{\} \;
find $chaos_bundle -name "CMakeCache.txt" -exec rm -rf \{\} \;
