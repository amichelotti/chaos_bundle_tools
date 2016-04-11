#!/bin/bash -e
## deploy libera
chaos_deploy_target.sh deploy_libera.conf
## deploy luminometer
chaos_deploy_target.sh deploy_i686_static.conf
## deploy libera plus
chaos_deploy_target.sh deploy_i686_static_custom.conf
## deploy astra 
chaos_deploy_target.sh deploy_i686_dynamic.conf
## deploy touschek
chaos_deploy_target.sh deploy_armhf.conf
