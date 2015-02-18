#!/bin/bash
## must package name, source dir,  version 
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null
source $dir/common_util.sh

VERSION="0.0"
ARCH="i386"
PACKAGE_NAME=""
SOURCE_DIR=""
VER_DIR=""


copy(){
    if ! cp -a $1 $2 >&/dev/null;then
	error_mesg "cannot copy from $1 to $2"
	exit 1
    fi

}

if [ ! -n "$1" ]; then
    echo "## you must specify a <package name> <source dir> <version> [-u]"
    echo "-u:generate a simplified distribution for unit server deploy"
    exit 1
else
    PACKAGE_NAME="$1"
fi

if [[ (! -d "$2" ) || ( -h "$2" ) ]]; then
    error_mesg "you must specify a <source dir> (not a link)"
    exit 1
else
    SOURCE_DIR="$2"
fi

if [ ! -n "$3" ]; then
    error_mesg "you must specify a <version>"
    exit 1;
else
    VERSION="$3"
fi


if [ "$CHAOS_TARGET" == "armhf" ]; then
    ARCH="armhf"
fi;

NAME=$PACKAGE_NAME-$VERSION
PACKAGE_DIR="/tmp/$PACKAGE_NAME-$ARCH-$VERSION"
PACKAGE_DEST="$PACKAGE_DIR/usr/local/$NAME"
DEBIAN_DIR="$PACKAGE_DIR/DEBIAN"
if !(mkdir -p "$DEBIAN_DIR"); then
    echo "## cannot create $DEBIAN_DIR"
    exit 1
fi;


if [ "$4" == "-u" ];then
   if mkdir -p $PACKAGE_DEST/bin;then
       copy $SOURCE_DIR/bin/UnitServer $PACKAGE_DEST/bin

   else
       error_mesg "cannot create directory " "$PACKAGE_DEST/bin"
       exit 1
   fi
else

    copy $SOURCE_DIR/* $PACKAGE_DEST
fi

copy $SOURCE_DIR/tools/package_template/etc $PACKAGE_DIR
if [ -z "$CHAOS_STATIC" ]; then
    copy $SOURCE_DIR/lib $PACKAGE_DEST/
    mkdir -p $PACKAGE_DIR/etc/ld.so.conf.d/
    echo "/usr/local/$NAME/lib" > $PACKAGE_DIR/etc/ld.so.conf.d/$PACKAGE_NAME.conf
fi

# if [ "$ARCH" == "i386" ]; then
#     ## then localize libstdc++
#     libcpp=`locate libstdc++.so.6`
#     cp $libcpp $PACKAGE_DEST/usr/local/lib
#     libcpp=`locate libc.so.6`
#     cp $libcpp $PACKAGE_DEST/usr/local/lib
#     libcpp=`locate ld-linux.so`
#     cp $libcpp $PACKAGE_DEST/usr/local/lib
# fi;

echo "Package: $PACKAGE_NAME" > $DEBIAN_DIR/control
echo "Filename: $PACKAGE_NAME-$ARCH-$VERSION.deb" >> $DEBIAN_DIR/control
echo "Version: $VERSION" >> $DEBIAN_DIR/control
echo "Section: base" >> $DEBIAN_DIR/control
echo "Priority: optional" >> $DEBIAN_DIR/control
echo "Architecture: $ARCH" >> $DEBIAN_DIR/control
echo "Depends: bash (>= 2.05a-11),gcc(>=4.4),g++(>=4.4)" >> $DEBIAN_DIR/control
echo "Maintainer: claudio bisegni claudio.bisegni@lnf.infn.it, Andrea Michelotti andrea.michelotti@lnf.infn.it" >> $DEBIAN_DIR/control
if [ "$4" == "-u" ];then
    echo "Description: lite dristribution" >> $DEBIAN_DIR/control
else
    echo "Description: chaos bundle, includes core libraries, binaries and includes for development" >> $DEBIAN_DIR/control
fi

cd $PACKAGE_DIR
copy "$CHAOS_TOOLS/package_template/DEBIAN/postrm" DEBIAN/
copy "$CHAOS_TOOLS/package_template/DEBIAN/postinst" DEBIAN/

listabin=`ls $PACKAGE_DEST/bin`
for i in $listabin;do
    name=`basename $i`
    echo "ln -sf /usr/local/$NAME/bin/$name /usr/bin" >> DEBIAN/postinst
    echo "rm /usr/bin/$name" >> DEBIAN/postrm 
done
if [ -z "$CHAOS_STATIC" ]; then
    echo "rm -f /etc/ld.so.conf.d/$PACKAGE_NAME.conf" >> DEBIAN/postrm
    echo "ldconfig" >> DEBIAN/postinst
fi
echo "echo \"removing /usr/local/$NAME\"" >>DEBIAN/postrm
echo "rm -rf /usr/local/$NAME" >>DEBIAN/postrm
chmod 0555 DEBIAN/postrm
chmod 0555 DEBIAN/postinst
cd - > /dev/null
info_mesg "packaging $PACKAGE_NAME-$ARCH-$VERSION for architecture " "$ARCH .."
dpkg-deb -b $PACKAGE_DIR > /dev/null
mv $PACKAGE_DIR.deb .
info_mesg "created " "$PACKAGE_NAME-$ARCH-$VERSION.deb"

rm -rf $PACKAGE_DIR
