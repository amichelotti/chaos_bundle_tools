#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "* init couchbase server $1 db $2"
echo "* testing port $1:8091"
$DIR/wait-for.sh $1:8091
echo "* testing port $2:27017"
$DIR/wait-for.sh $2:27017

curl -u chaos:chaos2015 -v -X POST http://$1:8091/node/controller/setupServices -d 'services=data'
curl -v -X POST http://$1:8091/nodes/self/controller/settings -d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata'

curl -v -X POST http://$1:8091/settings/web -d 'password=chaos2015&username=chaos&port=SAME'

echo "Setting couchbase chaos bucket"
curl -f --silent --output /dev/null --show-error -X POST -u chaos:chaos2015 -d 'name=chaos' -d 'ramQuotaMB=512' -d "bucketType=ephemeral" -d 'authType=sasl' -d 'replicaNumber=0' -d 'saslPassword=chaoschaos' http://$1:8091/pools/default/buckets

#curl -X POST -u Administrator:chaos2015 -d 'name=chaos' -d "bucketType=ephemeral" -d 'ramQuotaMB=512' -d 'authType=sasl'  -d 'replicaNumber=0' -d 'saslPassword=chaos' http://$1:8091/pools/default/buckets
#curl -u Administrator:chaos2015 http://$1:8091/pools/default/buckets

echo "* init DB server $2"
rm -rf /tmp/dbinit
mkdir -p /tmp/dbinit
cd /tmp/dbinit
git clone git@baltig.infn.it:chaos-lnf-control/chaos_mongodb_script.git
mongo --host $2 chaos_mongodb_script/drop_collections.js
mongo --host $2 chaos_mongodb_script/create_users.js
mongo --host $2 chaos_mongodb_script/create_collections.js
mongo --host $2 chaos_mongodb_script/create_index.js

