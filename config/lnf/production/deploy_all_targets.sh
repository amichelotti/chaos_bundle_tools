#!/bin/bash -e
## deploy touschek
chaos_deploy_target.sh deploy_armhf.conf
## deploy luminometer
chaos_deploy_target.sh deploy_i686_static.conf
## deploy libera
chaos_deploy_target.sh deploy_i686_static_custom.conf
## deploy astra 
chaos_deploy_target.sh deploy_i686_dynamic.conf
