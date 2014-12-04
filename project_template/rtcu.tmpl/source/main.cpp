//
//  main.m
//  cocos2d-mac
//
//  Created by Ricardo Quesada on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#include "__template_name__.h"
#include "__template_name__Driver.h"

#include <string>

#include <chaos/cu_toolkit/ChaosCUToolkit.h>


using namespace chaos;
using namespace chaos::cu;
using namespace chaos::cu::driver_manager;

#define OPT_CUSTOM_DEVICE_ID "device_id"

int main(int argc, char *argv[])
{
	string tmp_device_id;
	control_manager::AbstractControlUnit::ControlUnitDriverList driver_list;
	try {
		// allocate the instance and inspector for driver
		MATERIALIZE_INSTANCE_AND_INSPECTOR(__template_name__Driver)

		// register the thriver within cu-toolkit
		DriverManager::getInstance()->registerDriver(__template_name__DriverInstancer, __template_name__DriverInspector);

		// initialize the control unit toolkit
		ChaosCUToolkit::getInstance()->init(argc, argv);

		// register the control unit class
		ChaosCUToolkit::getInstance()->registerControlUnit<__template_name__>();

		// start control unit toolkit until someone will close it
		ChaosCUToolkit::getInstance()->start();
	} catch (CException& ex) {
		DECODE_CHAOS_EXCEPTION(ex)
	} catch (program_options::error &e){
		cerr << "Unable to parse command line: " << e.what() << endl;
	} catch (...){
		cerr << "unexpected exception caught.. " << endl;
	}
	return 0;
}
