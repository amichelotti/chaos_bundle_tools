/*	
 *	__template_name__.h
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
#ifndef ChaosFramework___template_name___h
#define ChaosFramework___template_name___h

#include <string>
#include <chaos/cu_toolkit/ControlManager/RTAbstractControlUnit.h>

using namespace std;

using namespace chaos;
using namespace chaos::common::data;

class __template_name__ : public chaos::cu::RTAbstractControlUnit {
	std::string _device_id;
public:
    /*
     Construct a new CU with an identifier
     */
    __template_name__(std::string& device_id);
    /*
     Destructor a new CU with an identifier
     */
    ~__template_name__();

protected:
    /*
     Define the Control Unit Dataset and Actions
     */
    void unitDefineActionAndDataset()throw(CException);
    
	void unitDefineDriver(std::vector<chaos::cu::driver_manager::driver::DrvRequestInfo>& neededDriver);
	
    /*(Optional)
     Initialize the Control Unit and all driver, with received param from MetadataServer
     */
    void unitInit() throw(CException);
    /*
     Execute the work, this is called with a determinated delay, it must be as fast as possible
     */
    void unitStart() throw(CException);
    /*
     Execute the work, this is called with a determinated delay, it must be as fast as possible
     */
    void unitRun() throw(CException);
    
    /*
     The Control Unit will be stopped
     */
    void unitStop() throw(CException);
    
    /*(Optional)
     The Control Unit will be deinitialized and disposed
     */
    void unitDeinit() throw(CException);

};

#endif
