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
    /*

    addAttributeToDataSet("<my_double_variable_name>", // this is the name of the variable that is shown in interfaces and in MDS 
			      "variable Description",
			      DataType::TYPE_DOUBLE,
			      DataType::Output);
	
	
	addAttributeToDataSet("<my_int32_variable>",
			      "variable Description",
			      DataType::TYPE_INT32,
			      DataType::Output);
	
	addAttributeToDataSet("<my_int64_variable>",
			      "variable Description",
			      DataType::TYPE_INT64,
			      DataType::Output);
	
	
	addAttributeToDataSet("<my_string_variable name>",
			      "variable Description",
			      DataType::TYPE_STRING,
			      DataType::Output,256); // max string size
	

	addAttributeToDataSet("< my_buffer name>",
			      "variable Description",
			      DataType::TYPE_BYTEARRAY,
			      DataType::Output,
			      10000000); // max buffer size

	addActionDescritionInstance<__template_name__>(this,
						       &__template_name__::my_custom_action,
						       "customFunctionName,
						       "custom function desctiption");

    */
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

/*
CDataWrapper *__template_name__::my_custom_action(CDataWrapper *actionParam, bool& detachParam) {
	CDataWrapper *result =  new CDataWrapper();
	return result;
}
*/
