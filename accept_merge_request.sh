#!/bin/bash
if [ -z "$1" ];then
    echo "## you must specify a valid branch name"
    exit 1
fi
projects="chaosframework chaos-driver-actuator chaos-webgui chaos-driver-misc chaos-example-control-unit chaos_bundle_tools  chaos-common-misc chaos-common-debug chaos-common-modbus chaos-common-crest  chaos-common-vme chaos-common-serial chaos-common-powersupply chaos-common-actuators chaos-driver-sensors  chaos-common-test  chaos-driver-daq chaos-driver-data_import chaos-driver-modbus chaos-driver-powersupply DCS common_windows chaos-examples chaos-driver-siemens-s7 chaos-driver-plc chaos-driver-generators chaos-driver-crio chaos-common-labview chaos-driver-chaos-mess"

for p in $projects;do
    SRC=""
    ID=""
    DESC=""
    echo "[$p] checking merge requests for branch '$1'..."
    
    
    if curl -s --header "PRIVATE-TOKEN:L-qCxMRRVFsedntAJyRL" https://baltig.infn.it/api/v4/projects/chaos-lnf-control%2F$p/merge_requests?state=opened > request.json; then
	if grep source_branch request.json >&/dev/null;then
	    SRC=`cat request.json |python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["source_branch"]'`
	    ID=`cat request.json |python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["iid"]'`
	    DESC=`cat request.json |python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["milestone"]'`
	    if [ -n $SRC ]; then
		echo "[$p] a merge  request '$ID' found for '$SRC' milestone:$DESC"
		if [ "$SRC" == "$1" ];then
		    echo "[$p] accepting merge request '$ID'"
		    if curl --request PUT --header "PRIVATE-TOKEN:L-qCxMRRVFsedntAJyRL" https://baltig.infn.it/api/v4/projects/chaos-lnf-control%2F$p/merge_requests/$ID/merge;then
		echo "[$p] OK deleting merge request"
		curl --request DELETE --header "PRIVATE-TOKEN:L-qCxMRRVFsedntAJyRL" https://baltig.infn.it/api/v4/projects/chaos-lnf-control%2F$p/merge_requests/$ID
		    fi  
		fi  
	    fi
	fi
    fi
done
