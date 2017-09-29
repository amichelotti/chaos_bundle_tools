#!/bin/bash
echo "* init couchbase server $1 db $2"
curl -u Administrator:chaos2015 -v -X POST http://$1:8091/node/controller/setupServices -d 'services=data'
curl -v -X POST http://$1:8091/nodes/self/controller/settings -d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata'

curl -v -X POST http://$1:8091/settings/web -d 'password=chaos2015&username=Administrator&port=SAME'
curl -X POST -u Administrator:chaos2015 -d 'name=chaos' -d 'bucketType=memcached' -d 'ramQuotaMB=512' -d 'authType=sasl'  -d 'replicaNumber=0' -d 'saslPassword=chaos' http://$1:8091/pools/default/buckets
curl -u Administrator:chaos2015 http://$1:8091/pools/default/buckets

echo "* init DB server $2"
mongo $2/chaos --eval 'db.dropUser("chaos")'
mongo --host $2 admin --eval 'var schema = db.system.version.findOne({"_id" : "authSchema"}); schema.currentVersion = 3 ; db.system.version.save(schema)'
mongo $2/chaos --eval 'db.createUser({user:"chaos", pwd:"chaos", roles:[ { role: "readWrite", db: "chaos" } ]})'
mongo $2/chaos --eval 'db.daq.createIndex({"ndk_uid" : 1, "dpck_ats":1,"data.dpck_seq_id":1}, {name:"paged_daq_search_index",unique:1})'
mongo --host $2 admin --eval 'db.system.users.find().pretty();'
