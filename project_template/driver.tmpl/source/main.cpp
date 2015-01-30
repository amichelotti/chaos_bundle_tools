/*
 *	main.cpp
 *	!CHAOS
 *	Created automatically
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
#include "__template_name__ControlUnit.h"

#include <chaos/common/chaos_constants.h>
#include <chaos/cu_toolkit/ChaosCUToolkit.h>
#include <chaos/common/exception/CException.h>

#include <iostream>
#include <string>

/*! \page page_example_cue ChaosCUToolkit Example
 *  \section page_example_cue_sec An basic usage for the ChaosCUToolkit package
 *
 *  \subsection page_example_cue_sec_sub1 Toolkit usage
 *  ChaosCUToolkit has private constructor so it can be used only using singleton pattern,
 *  the only way to get unique isntance is; ChaosCUToolkit::getInstance(). So the first call of
 *  getInstance method will provide the CUToolkit and Common layer initial setup.
 *  \snippet example/ControlUnitTest/ControlUnitExample.cpp Custom Option
 */
using namespace std;
using namespace chaos;
using namespace chaos::cu;
using namespace __template_type__::__template_name__;


namespace common_plugin = chaos::common::plugin;
namespace common_utility = chaos::common::utility;
namespace cu_driver_manager = chaos::cu::driver_manager;



#define OPT_DEVICE_ID		"device_id"

int main (int argc, char* argv[] )
{
    string tmp_device_id;
	string tmp_definition_param;
	string tmp_address;
    try {
		//! [Custom Option]
		ChaosCUToolkit::getInstance()->getGlobalConfigurationInstance()->addOption(OPT_DEVICE_ID, po::value<string>(&tmp_device_id), "Specify the device id of the siemen s7 plc");
		//! [Custom Option]
		
		//! [CUTOOLKIT Init]
		ChaosCUToolkit::getInstance()->init(argc, argv);
		if(!ChaosCUToolkit::getInstance()->getGlobalConfigurationInstance()->hasOption(OPT_DEVICE_ID)) throw CException(2, "device id option is mandatory", __FUNCTION__);
		//! [CUTOOLKIT Init]
		
		//! [Driver Registration]
		REGISTER_DRIVER(__template_type__::__template_name__, __template_name__Driver);


		//! [Starting the Framework]
		ChaosCUToolkit::getInstance()->start();
		//! [Starting the Framework]
    } catch (CException& e) {
        cerr<<"Exception:"<<endl;
        std::cerr<< "domain	:"<<e.errorDomain << std::endl;
        std::cerr<< "cause	:"<<e.errorMessage << std::endl;
    } catch (program_options::error &e){
        cerr << "Unable to parse command line: " << e.what() << endl;
    } catch (...){
        cerr << "unexpected exception caught.. " << endl;
    }
	
    return 0;
}
