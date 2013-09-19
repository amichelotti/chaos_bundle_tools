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

/*
 Construct a new CU with an identifier
 */
__template_name__::__template_name__(std::string& device_id):_device_id(device_id) {
	
}

/*
 Destructor a new CU with an identifier
 */
__template_name__::~__template_name__() {
    
}

/*
 Return the default configuration
 */
void __template_name__::unitDefineActionAndDataset() throw(CException) {

    
    //add managed device di
    setDeviceID(_device_id);
    
    //insert your definition code here
}

void __template_name__::unitDefineDriver(std::vector<chaos::cu::driver_manager::driver::DrvRequestInfo>& neededDriver) {
	
}

/*
 Initialize the Custom Contro Unit and return the configuration
 */
void __template_name__::unitInit() throw(CException) {
	
}

/*
 Execute the work, this is called with a determinated delay, it must be as fast as possible
 */
void __template_name__::unitStart() throw(CException) {

}

/*
 Execute the Control Unit work
 */
void __template_name__::unitRun() throw(CException) {
 
}

/*
 Execute the Control Unit work
 */
void __template_name__::unitStop() throw(CException) {
}

/*
 Deinit the Control Unit
 */
void __template_name__::unitDeinit() throw(CException) {
}
