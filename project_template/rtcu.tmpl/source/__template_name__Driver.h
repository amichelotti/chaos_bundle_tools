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
#ifndef ChaosControlUnitDriver___template_name___h
#define ChaosControlUnitDriver___template_name___h

#include <chaos/cu_toolkit/driver_manager/driver/AbstractDriverPlugin.h>

namespace cu_driver = chaos::cu::driver_manager::driver;

DEFINE_CU_DRIVER_DEFINITION_PROTOTYPE(__template_name__Driver)

typedef enum __template_name__DriverOpcode{
	__template_name__DriverOpcode_SET_CH_1 = cu_driver::OpcodeType::OP_USER,
	__template_name__DriverOpcode_GET_CH_1
} __template_name__DriverOpcode;


/*
 driver definition
 */
class __template_name__Driver: ADD_CU_DRIVER_PLUGIN_SUPERCLASS {
	int32_t i32_out_1_value;
	void driverInit(const char *initParameter) throw(chaos::CException);
	void driverDeinit() throw(chaos::CException);
public:
	__template_name__Driver();
	~__template_name__Driver();
    //! Execute a command
	cu_driver::MsgManagmentResultType::MsgManagmentResult execOpcode(cu_driver::DrvMsgPtr cmd);
};

#endif /* defined(__ControlUnitTest__DummyDriver__) */
