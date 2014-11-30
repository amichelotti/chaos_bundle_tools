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

PUBLISHABLE_CONTROL_UNIT_IMPLEMENTATION(__template_name__)

/*
 Construct a new CU with an identifier
 */
__template_name__::__template_name__(const std::string& _control_unit_id, const std::string& _control_unit_param, const ControlUnitDriverList& _control_unit_drivers):
SCAbstractControlUnit(_control_unit_id, _control_unit_param, _control_unit_drivers) {
}

__template_name__::~__template_name__() {

}

/*
 Return the default configuration
 */
void __template_name__::unitDefineActionAndDataset() throw(CException) {

    //install a default command
    installCommand<DefaultCommand>("default_command");
}

void __template_name__::defineSharedVariable() {
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
