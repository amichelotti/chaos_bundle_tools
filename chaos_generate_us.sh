#!/bin/bash

startdir=$1

listcpp=`find $startdir -name "*.cpp"`;
lista_cu=();
lista_cu_h=();
lista_driver=();
listr_driver_h=();
for c in $listacpp; do
    cu=`grep PUBLISHABLE_CONTROL_UNIT_IMPLEMENTATION $c | sed s/PUBLISHABLE_CONTROL_UNIT_IMPLEMENTATION/REGISTER_CU/`
    drv=`grep REGISTER_PLUGIN $c | sed s/REGISTER_PLUGIN/REGISTER_DRIVER/`
    header=`echo $c | sed s/.cpp/.h/`;
    if [ -n "$cu"]; then
	lista_cu+=("$cu");
	lista_cu_h+=("$header");
    fi
    if [ -n "$drv"]; then
	lista_driver+=("$drv");
	lista_driver_h+=("$header");
    fi
done;

listcmake=`find $startdir -name "CMakeLists.txt"`;
