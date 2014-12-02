/*
 *	__template_name__.cpp
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

#include "__template_name__.h"

using namespace chaos;
PUBLISHABLE_CONTROL_UNIT_IMPLEMENTATION(__template_name__)

/*
 Construct
 */
__template_name__::__template_name__(const string& _control_unit_id, const string& _control_unit_param, const ControlUnitDriverList& _control_unit_drivers):
RTAbstractControlUnit(_control_unit_id, _control_unit_param, _control_unit_drivers) {

}

/*
 Destructor
 */
__template_name__::~__template_name__() {

}

//!Return the default configuration
void __template_name__::unitDefineActionAndDataset() throw(chaos::CException) {
    //insert your definition code here
}


//!Define custom control unit attribute
void __template_name__::unitDefineCustomAttribute() {

}


//!Initialize the Custom Control Unit
void __template_name__::unitInit() throw(chaos::CException) {

}


//!Execute the work, this is called with a determinated delay, it must be as fast as possible
void __template_name__::unitStart() throw(chaos::CException) {

}


//!Execute the Control Unit work
void __template_name__::unitRun() throw(chaos::CException) {

}


//!Execute the Control Unit work
void __template_name__::unitStop() throw(chaos::CException) {

}


//!Deinit the Control Unit
void __template_name__::unitDeinit() throw(chaos::CException) {

}

//! pre imput attribute change
void __template_name__::unitInputAttributePreChangeHandler() throw(chaos::CException) {

}

//! attribute changed handler
void __template_name__::unitInputAttributeChangedHandler() throw(chaos::CException) {

}
