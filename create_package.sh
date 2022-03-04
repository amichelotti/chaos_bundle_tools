#/bin/bash
find /usr/local/chaos/chaos-distrib -name "*.txt" -exec rm \{\} \;
echo "* strip symbols"
strip --strip-unneeded `find /usr/local/chaos/chaos-distrib/lib -name "*" -type f` >& /dev/null
strip --strip-unneeded `find /usr/local/chaos/chaos-distrib/lib64 -name "*" -type f` >& /dev/null
strip --strip-unneeded `find /usr/local/chaos/chaos-distrib/bin -name "*" -type f` >& /dev/null
echo "* creating chaos-distrib.tgz..."
tar cfz chaos-distrib.tgz -C /usr/local/chaos/ chaos-distrib
