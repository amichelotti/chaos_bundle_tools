/*
 *	SiemensS7TcpDriver.h
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


#define __template_name__LAPP_		LAPP_ << "[__template_name__Driver] "
#define __template_name__LDBG_		LDBG_ << "[__template_name__Driver] "
#define __template_name__LERR_		LERR_ << "[__template_name__Driver] "


//GET_PLUGIN_CLASS_DEFINITION
//we need only to define the driver because we don't are makeing a plugin
OPEN_CU_DRIVER_PLUGIN_CLASS_DEFINITION(__template_name__Driver, 1.0.0, ::__template_type__::__template_name__::__template_name__Driver)
REGISTER_CU_DRIVER_PLUGIN_CLASS_INIT_ATTRIBUTE(__template_name__Driver, http_address/dnsname:port)
CLOSE_CU_DRIVER_PLUGIN_CLASS_DEFINITION

//register the two plugin
OPEN_REGISTER_PLUGIN
REGISTER_PLUGIN(::__template_type__::__template_name__::__template_name__Driver)
CLOSE_REGISTER_PLUGIN

  using namespace ::__template_type__::__template_name__;

//default constructor definition
DEFAULT_CU_DRIVER_PLUGIN_CONSTRUCTOR_WITH_NS(__template_type__::__template_name__, __template_name__Driver) {
	
}

//default descrutcor
__template_name__Driver::~__template_name__Driver() {
	
}

void __template_name__Driver::driverInit(const char *initParameter)  {
	__template_name__LAPP_ << "Init __template_name__ driver";
}

void __template_name__Driver::driverDeinit()  {
	__template_name__LAPP_ << "Deinit __template_name__ driver";
}
