#!/bin/bash
dir=`dirname $0`
chaos_bundle=$dir/..

function cleandir(){
    echo "* cleaning $1"
    rm -rf $1
}

cleandir $chaos_bundle/usr
cleandir $chaos_bundle/chaosframework/bin
cleandir $chaos_bundle/chaosframework/build

find $chaos_bundle -name "CMakeFiles" -exec rm -rf \{\} \;
find $chaos_bundle -name "CMakeCache.txt" -exec rm -rf \{\} \;
