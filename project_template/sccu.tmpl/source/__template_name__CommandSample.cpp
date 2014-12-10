/*
 *	__template_name__CommandSample.h
 *	!CHOAS
 *	Created by Bisegni Claudio.
 *
 *    	Copyright 2012 INFN, National Institute of Nuclear Physics
 *
 *    	Licensed under the Apache License, Version 2.0 (the "License");
 *    	you may not use this file except in compliance with the License.
 *    	You may obtain a copy of the License at
 *
 *    	http://www.apache.org/licenses/LICENSE-2.0
 *
 *    	Unless required by applicable law or agreed to in writing, software
 *    	distributed under the License is distributed on an "AS IS" BASIS,
 *    	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    	See the License for the specific language governing permissions and
 *    	limitations under the License.
 */
#include "__template_name__CommandSample.h"

#define CMDCU_ LAPP_ << "[__template_name__CommandSample] - "
#define DBG    LDBG_<< "[__template_name__CommandSample] - "

using namespace chaos;

using namespace chaos::common::data;

using namespace chaos::common::batch_command;

using namespace chaos::cu::control_manager::slow_command;
namespace chaos_batch = chaos::common::batch_command;

const char* __template_name__CommandSample::command_alias = "fire";
__template_name__CommandSample::__template_name__CommandSample() {
    //set default scheduler delay
    setFeatures(features::FeaturesFlagTypes::FF_SET_SCHEDULER_DELAY, (uint64_t)1000);
    parm_from_cmd = 0;
    driver =NULL;
    
}

__template_name__CommandSample::~__template_name__CommandSample() {

}

// return the implemented handler
uint8_t __template_name__CommandSample::implementedHandler() {
    return  HandlerType::HT_Set | HandlerType::HT_Acquisition | HandlerType::HT_Correlation;
}

// Called when the command is executed
void __template_name__CommandSample::setHandler(CDataWrapper *data) {
  // TODO
    LDBG_<< " * set handler "<<__FUNCTION__;
  o_out2_p = getAttributeCache()->getRWPtr<double>(AttributeValueSharedCache::SVD_OUTPUT, "out2");
  o_out1_p = getAttributeCache()->getRWPtr<double>(AttributeValueSharedCache::SVD_OUTPUT, "out1");
  i_timeout_p =getAttributeCache()->getROPtr<int>(AttributeValueSharedCache::SVD_INPUT, "timeout");
  chaos::cu::driver_manager::driver::DriverAccessor * accessor = driverAccessorsErogator->getAccessoInstanceByIndex(0);
  if(accessor && (driver == NULL)){
      driver = new __template_name__Interface(accessor);
  }
    
    //check if the command is well formed : {"parm1":<value>}
	if(!data->hasKey("parm1")) {
		throw chaos::CException(0, "command parameter not found", __FUNCTION__);
	}
    if(*i_timeout_p>0){
        setFeatures(chaos_batch::features::FeaturesFlagTypes::FF_SET_COMMAND_TIMEOUT, (uint64_t) *i_timeout_p);
        CMDCU_<< "* setting timeout for command \""<<__template_name__CommandSample::command_alias<<"\":"<<*i_timeout_p<<" ms";
    }
	cnt = 0;
    parm_from_cmd= data->getInt32Value("parm1");
    driver->op1(parm_from_cmd);
    cnt =parm_from_cmd + 1;
    BC_EXEC_RUNNIG_PROPERTY;
}

// Aquire the necessary data for the command
/*!
 The acquire handler has the purpose to get all necessary data need the by CC handler.
 \return the mask for the runnign state
 */
void __template_name__CommandSample::acquireHandler() {
    // TODO: put here your "fire" acquisition code

    LDBG_<< " * acquire handler "<<cnt;
    cnt++;
    
}

// Correlation and commit phase
void __template_name__CommandSample::ccHandler() {
    // TODO: put here yfeedback code
    LDBG_<< " * CC handler "<<cnt;

    *o_out2_p = cnt;
    if(cnt>100){
        // command has finished
        LDBG_<< " * mark as end command"<<cnt;

        BC_END_RUNNIG_PROPERTY;
    }
    getAttributeCache()->setOutputDomainAsChanged();
    
}

bool __template_name__CommandSample::timeoutHandler() {
	//move the state machine on fault
    LDBG_<< " * TIMEOUT "<<cnt;
    BC_FAULT_RUNNIG_PROPERTY;

	return false;
}
