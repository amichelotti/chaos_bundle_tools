#!/bin/bash
## must package name, source dir,  version 
pushd `dirname $0` > /dev/null
dir=`pwd -P`
popd > /dev/null
source $dir/common_util.sh

SOURCE_DIR=""


copy(){
    if ! cp -af $1 $2 >&/dev/null;then
	error_mesg "cannot copy from $1 to $2"
	exit 1
    fi

}
VERSION="0.1"
PACKAGE_NAME="chaos"
SOURCE_DIR=""
if [ -n "$CHAOS_PREFIX" ];then
    SOURCE_DIR=$CHAOS_PREFIX
fi

CLIENT="true"

Usage(){
    echo -e "Usage is $0 [ -i <source dir> ] [-p <package name > ] [-v <version> ] [-c] [-s] [-d] [-a]\n-i <source dir>: a valid source chaos distribution [$SOURCE_DIR]\n-p <package name>: is the package name prefix [$PACKAGE_NAME]\n-v <version>:a version of the package distribution [$VERSION]\n-c: client distribution (i.e US) [$CLIENT]\n-s: server distribution (CDS,MDS..)\n-a: development with all (client, server and includes)\n-d: dynamic distribution\n-t <i386|x86_64|armhf> [$ARCH]\n"
    exit 1
}
while getopts p:i:v:dt:sac opt; do
    case $opt in
	p) PACKAGE_NAME=$OPTARG
	    ;;
	i) SOURCE_DIR=$OPTARG
	    ;;
	v) VERSION=$OPTARG
	    ;;
	c) CLIENT="true"
	    SERVER=""
	    ;;
	s) SERVER="true"
	    CLIENT=""
	    ;;
	a) ALL="true"
	    ;;
        d) DYNAMIC="true"
	    ;;
        t) ARCH=$OPTARG
	    ;;
	*)
	    Usage
    esac
	
done


SOURCE_DIR=$(get_abs_dir $SOURCE_DIR)


if [ ! -d "$SOURCE_DIR" ];then
    error_mesg "missing a valid source directory"
    Usage
fi

if [ "$ARCH" != "i386" ] && [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "armhf" ];then
    error_mesg " you must specify a valid architecture"
    Usage;
fi

if [ "$ARCH" == "x86_64" ];then
    ARCH="amd64"
fi
	  
EXT=""
if [ -n "$CLIENT" ];then
    EXT="client"
    desc="Client !CHAOS package include libraries and binaries"
fi

if [ -n "$SERVER" ];then
    EXT="server"
    desc="Server !CHAOS package include libraries and binaries"
fi

if [ -n "$ALL" ];then
    EXT="devel"
    desc="Development package include libraries, includes and tools"
fi

if [ -n "$DYNAMIC" ];then
    EXT="dyn-$EXT"
else
    EXT="static-$EXT"
fi

NAME=$PACKAGE_NAME-$EXT-$VERSION\_$ARCH
PACKAGE_DIR="/tmp/$NAME"
PACKAGE_DEST="$PACKAGE_DIR/usr/local/$NAME"
DEBIAN_DIR="$PACKAGE_DIR/DEBIAN"
rm -rf $PACKAGE_DIR >& /dev/null
info_mesg "taking distribution $SOURCE_DIR, building " "$NAME"
if !(mkdir -p "$DEBIAN_DIR"); then
    echo "## cannot create $DEBIAN_DIR"
    exit 1
fi;


if [ -n "$CLIENT" ];then
   if mkdir -p $PACKAGE_DEST/bin;then
       copy $SOURCE_DIR/bin/UnitServer $PACKAGE_DEST/bin

   else
       error_mesg "cannot create directory " "$PACKAGE_DEST/bin"
       exit 1
   fi
fi

if [ -n "$SERVER" ];then
   if mkdir -p $PACKAGE_DEST/bin;then
       copy $SOURCE_DIR/bin $PACKAGE_DEST
   else
       error_mesg "cannot create directory " "$PACKAGE_DEST/bin"
       exit 1
   fi


fi

if [ -n "$ALL" ];then
    copy $SOURCE_DIR $PACKAGE_DEST
fi

copy $SOURCE_DIR/tools/package_template/etc $PACKAGE_DIR

if [ -n "$DYNAMIC" ]; then
    copy $SOURCE_DIR/lib $PACKAGE_DEST/
    mkdir -p $PACKAGE_DIR/etc/ld.so.conf.d/
    echo "/usr/local/$NAME/lib" > $PACKAGE_DIR/etc/ld.so.conf.d/$PACKAGE_NAME.conf
fi


echo "Package: $PACKAGE_NAME-$EXT" > $DEBIAN_DIR/control
echo "Filename: $NAME.deb" >> $DEBIAN_DIR/control
echo "Version: $VERSION" >> $DEBIAN_DIR/control
echo "Section: base" >> $DEBIAN_DIR/control
echo "Priority: optional" >> $DEBIAN_DIR/control
echo "Architecture: $ARCH" >> $DEBIAN_DIR/control
if [ "$ALL" ];then
    echo "Depends: bash (>= 3),gcc(>=4.8),g++(>=4.8), cmake(>=2.6)" >> $DEBIAN_DIR/control
else
    echo "Depends: bash (>= 3)" >> $DEBIAN_DIR/control
fi
echo "Maintainer: claudio bisegni claudio.bisegni@lnf.infn.it, Andrea Michelotti andrea.michelotti@lnf.infn.it" >> $DEBIAN_DIR/control
echo "Description: $desc" >> $DEBIAN_DIR/control

cd $PACKAGE_DIR
echo "#!/bin/sh" > DEBIAN/postrm
echo "#!/bin/sh" > DEBIAN/postinst
echo "INSTDIR=/usr/local/$NAME" >> DEBIAN/postrm
echo "INSTDIR=/usr/local/$NAME" >> DEBIAN/postinst

cat "$SOURCE_DIR/tools/package_template/DEBIAN/postrm" >> DEBIAN/postrm
cat "$SOURCE_DIR/tools/package_template/DEBIAN/postinst" >> DEBIAN/postinst

listabin=`ls $PACKAGE_DEST/bin`
for i in $listabin;do
    name=`basename $i`
    echo "ln -sf /usr/local/$NAME/bin/$name /usr/bin" >> DEBIAN/postinst
    echo "rm -rf /usr/bin/$name" >> DEBIAN/postrm 
done
if [ -n "$DYNAMIC" ]; then
    echo "rm -f /etc/ld.so.conf.d/$PACKAGE_NAME.conf" >> DEBIAN/postrm
    echo "ldconfig" >> DEBIAN/postinst
fi

chmod 0555 DEBIAN/postrm
chmod 0555 DEBIAN/postinst
cd - > /dev/null
info_mesg "packaging $NAME for architecture " "$ARCH .."
dpkg-deb -b $PACKAGE_DIR > /dev/null
mv $PACKAGE_DIR.deb .
info_mesg "created " "$NAME.deb"

rm -rf $PACKAGE_DIR
