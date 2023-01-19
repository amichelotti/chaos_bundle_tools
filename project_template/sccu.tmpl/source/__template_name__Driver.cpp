/*
 *  __template_name__Driver.cpp 
 *      created automatically 

 *    	Copyright 2013 INFN, National Institute of Nuclear Physics
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
#include "__template_name__Driver.h"

#include <string>
#include <stdlib.h>
#include <chaos/cu_toolkit/driver_manager/driver/AbstractDriverPlugin.h>
#include <boost/regex.hpp>

#define __template_name__LAPP_		LAPP_ << "[__template_name__Driver] "
#define __template_name__LDBG_		LDBG_ << "[__template_name__Driver] "
#define __template_name__LERR_		LERR_ << "[__template_name__Driver] "



//GET_PLUGIN_CLASS_DEFINITION
//we need only to define the driver because we don't are makeing a plugin
OPEN_CU_DRIVER_PLUGIN_CLASS_DEFINITION(__template_name__Driver, 1.0.0, chaos::driver::__template_name__::__template_name__Driver)
REGISTER_CU_DRIVER_PLUGIN_CLASS_INIT_ATTRIBUTE(__template_name__Driver, http_address/dnsname:port)
CLOSE_CU_DRIVER_PLUGIN_CLASS_DEFINITION

//register the two plugin
OPEN_REGISTER_PLUGIN
REGISTER_PLUGIN(driver::driver::__template_name__:__template_name__Driver)
CLOSE_REGISTER_PLUGIN

  using namespace chaos::driver::__template_name__;;

//default constructor definition
DEFAULT_CU_DRIVER_PLUGIN_CONSTRUCTOR_WITH_NS(chaos::driver::__template_name__, __template_name__Driver) {
  
}

__template_name__Driver::~__template_name__Driver() {
	
}

void __template_name__Driver::driverInit(const char *initParameter)  {
  __template_name__LAPP_<<" Initialized" << (initParameter)?initParameter:"";
}

void __template_name__Driver::driverDeinit()  {
    
}

// write here the code of your driver
cu_driver::MsgManagmentResultType::MsgManagmentResult  __template_name__Driver::execOpcode(cu_driver::DrvMsgPtr cmd){
    cu_driver::MsgManagmentResultType::MsgManagmentResult result = cu_driver::MsgManagmentResultType::MMR_EXECUTED;
    chaos::driver::__template_name__::__template_name___iparams_t * in= (chaos::driver::__template_name__::__template_name___iparams_t *) cmd->inputData;
    chaos::driver::__template_name__::__template_name___oparams_t * out =(chaos::driver::__template_name__::__template_name___oparams_t *) cmd->resultData;
    /// TODO: YOUR driver code wrapped here
    switch(cmd->opcode){
        case OP_1:
	  __template_name__LDBG_<< "OPCODE 1:"<<in->parm1;
	  srand(time(NULL));
	  break;
        
        case OP_2:
            __template_name__LDBG_<< "OPCODE 2:"<<in->parm1;
            out->drv_out=((1.0*rand())/RAND_MAX)*in->parm1;
            out->drv_ret = in->parm1;

	  break;
    
    }
    ////
    return result;

}
