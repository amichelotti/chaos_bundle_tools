INSTALL_DIR=/usr/local/chaos/chaos-distrib ;cmake -DCHAOS_ARCHITECTURE_TEST=ON -DOPENCV=$INSTALL_DIR -DENABLE_MEMCACHE=ON -DCERN_ROOT=$INSTALL_DIR -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR -DIDS=ON -DCAEN2527=ON -DBASLER=ON  -DCHAOS_WAN=ON -DENABLE_MEMCACHE=ON -DCMAKE_BUILD_TYPE=Debug .
