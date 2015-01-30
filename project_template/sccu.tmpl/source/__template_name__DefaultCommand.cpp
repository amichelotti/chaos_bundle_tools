/*
 *	__template_name__DefaultCommand.h
 *	!CHAOS
 *	Created automatically
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
#include "__template_name__DefaultCommand.h"

#define CMDCU_ LAPP_ << "[__template_name__DefaultCommand] - "


using namespace chaos;

using namespace chaos::common::data;
using namespace chaos::common::data::cache;
using namespace chaos::common::batch_command;

using namespace chaos::cu::control_manager::slow_command;

__template_name__DefaultCommand::__template_name__DefaultCommand() {
  driver=NULL;

}

__template_name__DefaultCommand::~__template_name__DefaultCommand() {

}

// return the implemented handler
uint8_t __template_name__DefaultCommand::implementedHandler() {
    return  HandlerType::HT_Set | HandlerType::HT_Acquisition | HandlerType::HT_Correlation;
}

// Called when the command is executed
void __template_name__DefaultCommand::setHandler(CDataWrapper *data) {
  // TODO
    //set default scheduler delay
  setFeatures(features::FeaturesFlagTypes::FF_SET_SCHEDULER_DELAY, (uint64_t)1000000);
  o_out1_p = getAttributeCache()->getRWPtr<double>(DOMAIN_OUTPUT, "out1");
  i_rand_max_p =getAttributeCache()->getROPtr<double>(DOMAIN_INPUT, "rand_max");
  chaos::cu::driver_manager::driver::DriverAccessor * accessor = driverAccessorsErogator->getAccessoInstanceByIndex(0);
  if(accessor && (driver == NULL)){
      driver = new __template_name__Interface(accessor);
  }

}

// Aquire the necessary data for the command
/*!
 The acquire handler has the purpose to get all necessary data need the by CC handler.
 \return the mask for the runnign state
 */
void __template_name__DefaultCommand::acquireHandler() {
      LDBG_<< "acquire ";
    // TODO: put here your "Default" acquisition code
    if(driver){
        double var;
        
        driver->op2(*i_rand_max_p,&var);
        *o_out1_p = var;
	CMDCU_<< "acquire: "<<var;        
        getAttributeCache()->setOutputDomainAsChanged();
    }
    
}

// Correlation and commit phase
void __template_name__DefaultCommand::ccHandler() {
    // TODO: put here your "Default" feedback code
    
}
