//
//  __template_name__.cpp
//  ControlUnitTest
//
//  Created by Claudio Bisegni on 7/20/13.
//  Copyright (c) 2013 INFN. All rights reserved.
//

#include "__template_name__.h"
#include "DefaultCommand.h"

using namespace chaos::common::data;

using namespace chaos::cu::control_manager::slow_command;
using namespace chaos::cu::driver_manager::driver;


/*
 Construct a new CU with an identifier
 */
__template_name__::__template_name__(string &customDeviceID) {
    _deviceID = customDeviceID;
}

__template_name__::~__template_name__() {
	
}

/*
 Return the default configuration
 */
void __template_name__::unitDefineActionAndDataset() throw(CException) {
    //set the base information
    RangeValueInfo rangeInfoTemp;
    //cuSetup.addStringValue(CUDefinitionKey::CS_CM_CU_DESCRIPTION, "This is a beautifull CU");
    
    //add managed device di
    setDeviceID(_deviceID);
    
    //install a command
    installCommand<DefaultCommand>("default_command");
}

void __template_name__::defineSharedVariable() {
}

void __template_name__::unitDefineDriver(std::vector<cu_driver::DrvRequestInfo>& neededDriver) {
	cu_driver::DrvRequestInfo drv1 = {"DummyDriver","1.0.0","url_host:port"};
	neededDriver.push_back(drv1);
}

// Abstract method for the initialization of the control unit
void __template_name__::unitInit() throw(CException) {
	
}

// Abstract method for the start of the control unit
void __template_name__::unitStart() throw(CException) {
	
}

// Abstract method for the stop of the control unit
void __template_name__::unitStop() throw(CException) {
	
}

// Abstract method for the deinit of the control unit
void __template_name__::unitDeinit() throw(CException) {
	
}
