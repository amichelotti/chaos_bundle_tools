#!/bin/bash
systemctl stop zookeeper
systemctl stop kafka
rm -rf /tmp/zookeeper/*
rm -rf /tmp/kafka-logs/*
systemctl restart zookeeper
systemctl restart kafka

