#!/bin/bash
## must package name, source dir,  version 
VERSION="0.0"
ARCH="i386"
PACKAGE_NAME=""
SOURCE_DIR=""
VER_DIR=""

if [ ! -n "$1" ]; then
    echo "## you must specify a <package name> <source dir> <version>"
    exit 1
else
    PACKAGE_NAME="$1"
fi

if [[ (! -d "$2" ) || ( -h "$2" ) ]]; then
    echo "## you must specify a <source dir> (not a link)"
    exit 1
else
    SOURCE_DIR="$2"
fi

if [ ! -n "$3" ]; then
    echo "## you must specify a <version>"
    exit 1;
else
    VERSION="$3"
fi


if [ "$CHAOS_TARGET" == "armhf" ]; then
    ARCH="armhf"
fi;

PACKAGE_DIR="/tmp/$PACKAGE_NAME-$ARCH-$VERSION"
DEBIAN_DIR="$PACKAGE_DIR/DEBIAN"
if !(mkdir -p "$DEBIAN_DIR"); then
    echo "## cannot create $DEBIAN_DIR"
    exit 1
fi;



echo "copying files.."
if !(cp -rp $SOURCE_DIR $PACKAGE_DIR ); then
    echo "## cannot copy source files from \"$SOURCE_DIR\" to \"$PACKAGE_DIR\""
    exit 1
fi;

# if [ "$ARCH" == "i386" ]; then
#     ## then localize libstdc++
#     libcpp=`locate libstdc++.so.6`
#     cp $libcpp $PACKAGE_DIR/usr/local/lib
#     libcpp=`locate libc.so.6`
#     cp $libcpp $PACKAGE_DIR/usr/local/lib
#     libcpp=`locate ld-linux.so`
#     cp $libcpp $PACKAGE_DIR/usr/local/lib
# fi;

echo "Package: $PACKAGE_NAME" > $DEBIAN_DIR/control
echo "Filename: $PACKAGE_NAME-$ARCH-$VERSION.deb" >> $DEBIAN_DIR/control
echo "Version: $VERSION" >> $DEBIAN_DIR/control
echo "Section: base" >> $DEBIAN_DIR/control
echo "Priority: optional" >> $DEBIAN_DIR/control
echo "Architecture: $ARCH" >> $DEBIAN_DIR/control
echo "Depends: bash (>= 2.05a-11),gcc(>=4.4),g++(>=4.4)" >> $DEBIAN_DIR/control
echo "Maintainer: claudio bisegni claudio.bisegni@lnf.infn.it, Andrea Michelotti andrea.michelotti@lnf.infn.it" >> $DEBIAN_DIR/control
echo "Description: chaos bundle, includes core libraries, binaries and includes for development" >> $DEBIAN_DIR/control

cd $PACKAGE_DIR
find . -name "*" |grep -v DEBIAN|sed -e 's/\./rm -f /' 1> DEBIAN/postrm 
chmod 0555 DEBIAN/postrm
cd - > /dev/null
echo "packaging for architecture $ARCH .."
dpkg-deb -b $PACKAGE_DIR > /dev/null
mv $PACKAGE_DIR.deb .
echo "cleaning..."
rm -rf $PACKAGE_DIR
