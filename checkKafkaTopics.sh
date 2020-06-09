#!/bin/sh
if [ $# -ne 2 ];then
    echo "# must provide <topic> <server:port i.e localhost:9092>"
    exit 1
fi
kafka-run-class.sh kafka.tools.GetOffsetShell --topic $1 --time -1 --offsets 1 --broker-list $2