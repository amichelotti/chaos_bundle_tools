//
//  __template_name__.cpp
//  ControlUnitTest
//
//  Created by Claudio Bisegni on 7/20/13.
//  Copyright (c) 2013 INFN. All rights reserved.
//

#include "__template_name__.h"
#include "__template_name__DefaultCommand.h"
#include "__template_name__CommandSample.h"

using namespace chaos::common::data;
using namespace chaos::common::data::cache;

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
    installCommand<__template_name__DefaultCommand>("default_command");
    setDefaultCommand("default_command");

    // TODO
    installCommand<__template_name__CommandSample>(__template_name__CommandSample::command_alias);

    addAttributeToDataSet("out1", // this is the name of the variable that is shown in interfaces and in MDS
			      "a random value",
			      DataType::TYPE_DOUBLE,
			      DataType::Output);
    
    addAttributeToDataSet("out2", // this is the name of the variable that is shown in interfaces and in MDS
                          "out2 changed by 'fire' command",
                          DataType::TYPE_INT32,
                          DataType::Output);
    
    addAttributeToDataSet("rand_max",
						  "random max interval",
						  DataType::TYPE_DOUBLE,
						  DataType::Input);
    addAttributeToDataSet("timeout",
						  "The command timeout",
						  DataType::TYPE_INT32,
						  DataType::Input);
    //////
	
/*
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
    chaos::cu::driver_manager::driver::DriverAccessor * accessor =AbstractControlUnit::getAccessoInstanceByIndex(0);
  if(accessor == NULL){
    throw chaos::CException(-1, "Cannot retrieve the requested driver", __FUNCTION__);
  }

  i_rand_max_p =getAttributeCache()->getROPtr<double>(DOMAIN_INPUT, "rand_max");
  
  if(i_rand_max_p == NULL || (*i_rand_max_p<=0)){
    throw chaos::CException(-1, "BAD rand_max value", __FUNCTION__);
  }
  LAPP_<< " Rand MAX:" << *i_rand_max_p;

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
