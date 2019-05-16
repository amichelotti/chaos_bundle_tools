#!/bin/sh
ssh root@dante073 'initctl stop chaos-us'
sleep 2
ssh root@dante073 'initctl start chaos-us'





