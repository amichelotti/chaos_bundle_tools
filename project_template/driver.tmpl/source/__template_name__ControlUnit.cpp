/*
 *	__template_name__ControlUnit.cpp
 *	!CHAOS
 *	Automatically generated
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

#include "__template_name__ControlUnit.h"

#include <boost/regex.hpp>
#include <boost/lexical_cast.hpp>

using namespace chaos::common::data;
using namespace chaos::cu::driver_manager::driver;
using namespace ::__template_type__::__template_name__;


PUBLISHABLE_CONTROL_UNIT_IMPLEMENTATION(__template_name__ControlUnit)
#define __template_name__CUAPP_ LAPP_ << "[__template_name__ControlUnit] - "


/*
 Construct a new CU with an identifier
 */
__template_name__ControlUnit::__template_name__ControlUnit(const std::string& _control_unit_id, const std::string& _control_unit_param, const ControlUnitDriverList& _control_unit_drivers):
RTAbstractControlUnit(_control_unit_id, _control_unit_param, _control_unit_drivers) {

}



__template_name__ControlUnit::~__template_name__ControlUnit() {
	
}

/*
 Return the default configuration
 */
void __template_name__ControlUnit::unitDefineActionAndDataset() throw(chaos::CException) {
}



// Abstract method for the initialization of the control unit
void __template_name__ControlUnit::unitInit() throw(chaos::CException) {
	__template_name__CUAPP_ "unitInit";
	//plc_s7_accessor = AbstractControlUnit::getAccessoInstanceByIndex(0);
}

// Abstract method for the start of the control unit
void __template_name__ControlUnit::unitStart() throw(chaos::CException) {
	__template_name__CUAPP_ "unitStart";
}


//intervalled scheduled method
void __template_name__ControlUnit::unitRun() throw(chaos::CException) {
	__template_name__CUAPP_ "unitRun";
}

// Abstract method for the stop of the control unit
void __template_name__ControlUnit::unitStop() throw(chaos::CException) {
	__template_name__CUAPP_ "unitStop";
}

// Abstract method for the deinit of the control unit
void __template_name__ControlUnit::unitDeinit() throw(chaos::CException) {
	__template_name__CUAPP_ "unitDeinit";
}
