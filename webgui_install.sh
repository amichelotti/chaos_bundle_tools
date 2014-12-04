#!/bin/bash
apache="/var/www/html";
dir="";
currdir=`dirname $0`
webdir=$currdir/../service/webgui/w3chaos/public_html/
source $currdir/chaos_bundle_env.sh
echo "* Chaos bundle $CHAOS_BUNDLE"
if [ ! -d "$webdir" ]; then
    echo "## cannot find web source dir: $webdir"
    exit 2;
fi
echo "* using $webdir as source directory"

echo "Please insert web apache directory [$apache]";
read dir;
if [ -n "$dir" ]; then
apache="$dir";
fi
if [ ! -d "$apache" ]; then
    echo "## $apache is not a valid directory"
    exit 1
fi

echo "* using $apache"

function getipport(){
    local url;
    local ip;
    local defip=$1; ## default
    read ip;
if [ ! -n "$ip" ]; then
    url=$defip
else
    if ! [[ $url =~ ^[0-9a-zA-Z]+\.[0-9a-zA-Z]+\.[0-9a-zA-Z]+\.[0-9a-zA-Z]\:[0-9]+$ ]]; then
	echo "## URL: $url malformed"
	exit 1;
    fi;
fi;
echo "$url"

}
defip="127.0.0.1:8081"
echo "Please insert the IP:<port> of the !CHAOS UI server (CUiserver)[$defip] ";
url=$(getipport $defip);

echo "* using $url"
port=""
ip=""

if [[ $url =~ (.+)\:(.+) ]]; then
    ip="${BASH_REMATCH[1]}"
    port="${BASH_REMATCH[2]}"
else
    echo "## internal error, malformed URL"
    exit 2
fi;
metadataserver="127.0.0.1:5000"
echo "Please specify metadataserver [$metadataserver]"
metadataserver=$(getipport $metadataserver);

if ! $(cp -r $webdir/* $apache >& /dev/null); then
    echo "## error copy $webdir/* $apache  CHECK PERMISSIONS"
    exit 3
fi

if ! $(sed s/localhost:8081/$url/ $webdir/webChaos/chaos.js > $apache/webChaos/chaos.js  ); then
    echo "## cannot configure $webdir/webChaos/chaos.js"
    exit 4;
fi

echo "* html/javascript setup ok"

killall -9 CUiserver

echo "* starting server..."

CUIserver --metadata-server $metadataserver --server_port $port --log-on-console &



