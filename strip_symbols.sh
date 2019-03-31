#!/bin/bash
strip --strip-unneeded `find $1 -name "*" -type f` >& /dev/null
echo "* strip $1 ok"
