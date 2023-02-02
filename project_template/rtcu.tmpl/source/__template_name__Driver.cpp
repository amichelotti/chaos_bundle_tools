/*
 *	DummyDriver.h
 *	!CHOAS
 *	Created by Bisegni Claudio.
 *
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

#include <chaos/cu_toolkit/driver_manager/driver/AbstractDriverPlugin.h>

#include <boost/lexical_cast.hpp>

namespace cu_driver = chaos::cu::driver_manager::driver;

#define __template_name__DriverLAPP_		LAPP_ << "[__template_name__Driver] "
#define __template_name__DriverLDBG_		LDBG_ << "[__template_name__Driver] "
#define __template_name__DriverLERR_		LERR_ << "[__template_name__Driver] "


//GET_PLUGIN_CLASS_DEFINITION
//we need to define the driver with alias version and a class that implement it
OPEN_CU_DRIVER_PLUGIN_CLASS_DEFINITION(__template_name__Driver, 1.0.0, __template_name__Driver)
//we need to describe the driver with a parameter string
REGISTER_CU_DRIVER_PLUGIN_CLASS_INIT_ATTRIBUTE(__template_name__Driver, unsigned 32 bit)
CLOSE_CU_DRIVER_PLUGIN_CLASS_DEFINITION

//default constructor definition
DEFAULT_CU_DRIVER_PLUGIN_CONSTRUCTOR(__template_name__Driver) {

}

//default descrutcor
__template_name__Driver::~__template_name__Driver() {

}

void __template_name__Driver::driverInit(const char *initParameter)  {
	__template_name__DriverLAPP_ << "Init driver";
	try{
		i32_out_1_value = boost::lexical_cast<int32_t>(initParameter);
	} catch(...) {
		throw chaos::CException(-1, "Error on seed value", __PRETTY_FUNCTION__);
	}
	__template_name__DriverLAPP_ << "inizialised driver with seed: " << i32_out_1_value;
}

void __template_name__Driver::driverDeinit()  {
	__template_name__DriverLAPP_ << "Deinit driver";

}

//! Execute a command
cu_driver::MsgManagmentResultType::MsgManagmentResult __template_name__Driver::execOpcode(cu_driver::DrvMsgPtr cmd) {
	cu_driver::MsgManagmentResultType::MsgManagmentResult result = cu_driver::MsgManagmentResultType::MMR_EXECUTED;
	switch(cmd->opcode) {
		case __template_name__DriverOpcode_SET_CH_1:
			if(!cmd->inputData  || (sizeof(int32_t) != cmd->inputDataLength)) break;
			//we can get the value
			i32_out_1_value = *static_cast<int32_t*>(cmd->inputData);
		break;

		case __template_name__DriverOpcode_GET_CH_1:
			*static_cast<int32_t*>(cmd->resultData) = i32_out_1_value;
		break;
	}
	return result;
}
