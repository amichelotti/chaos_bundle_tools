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
#include "__template_name__Driver.h"

using namespace chaos;
using namespace chaos::cu::driver_manager::driver;

PUBLISHABLE_CONTROL_UNIT_IMPLEMENTATION(__template_name__)

#define __template_name__LAPP_		LAPP_ << "[__template_name__] "
#define __template_name__LDBG_		LDBG_ << "[__template_name__] " << __PRETTY_FUNCTION__ << " "
#define __template_name__LERR_		LERR_ << "[__template_name__] " << __PRETTY_FUNCTION__ << "("<<__LINE__<<") "

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

//!Return the definition of the control unit
/*!
The api that can be called withi this method are listed into
"Control Unit Definition Public API" module into html documentation
(chaosframework/Documentation/html/group___control___unit___definition___api.html)
*/
void __template_name__::unitDefineActionAndDataset() throw(chaos::CException) {
    //insert your definition code here
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

    //add two int32_t channel for example

    //output channel
    addAttributeToDataSet("out_1",
                          "Int32 output channel",
                          DataType::TYPE_INT32,
                          DataType::Output);

    //input channel
    /*
    addAttributeToDataSet("in_1",
                          "Int32 output channel",
                          DataType::TYPE_INT32,
                          DataType::Input);
    */
}


//!Define custom control unit attribute
void __template_name__::unitDefineCustomAttribute() {

}

//!Initialize the Custom Control Unit
void __template_name__::unitInit() throw(chaos::CException) {

  //check the value set on MDS for in_1 channel
  //int32_t in_1 = getAttributeCache()->getValue<int32_t>(chaos::common::data::cache::AttributeValueSharedCache::SVD_INPUT, "in_1");

}

//!Execute the work, this is called with a determinated delay, it must be as fast as possible
void __template_name__::unitStart() throw(chaos::CException) {

}

//!Execute the Control Unit work
void __template_name__::unitRun() throw(chaos::CException) {
  //get the output attribute pointer form the internal cache
  int32_t *out_1_ptr = getAttributeCache()->getRWPtr<int32_t>(chaos::common::data::cache::AttributeValueSharedCache::SVD_OUTPUT, "out_1");

  //construct the drivesr message
  auto_ptr<DrvMsg> driver_message((DrvMsg*)std::calloc(sizeof(DrvMsg), 1));

  //set the opcode for get value from the driver
  driver_message->opcode = __template_name__DriverOpcode_GET_CH_1;

  //associate the driver message input data to output attribute pointer
  driver_message->inputData = out_1_ptr;

  //send message to the driver, at index 0, in async
  getAccessoInstanceByIndex(0)->send(driver_message.get());

  //! set output dataset as changed
  getAttributeCache()->setOutputDomainAsChanged();
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
  /*
  //array to managed the changed attribute list
  std::vector<chaos::cu::control_manager::VariableIndexType> changed_input_attribute;

  //check what attribute has changed
  getAttributeCache()->getChangedInputAttributeIndex(changed_input_attribute);

  if(changed_input_attribute.size()) {
    //scsan the changed index
    for (std::vector<chaos::cu::control_manager::VariableIndexType>::iterator it = changed_input_attribute.begin();
      it != changed_input_attribute.end();
      it++) {
        switch(*it) {
          case 0: {//int_1 attribute
            const int32_t *in_1 = getAttributeCache()->getROPtr<int32_t>(chaos::common::data::cache::AttributeValueSharedCache::SVD_INPUT, "in_1");

            //construct the drivesr message
            auto_ptr<DrvMsg> driver_message((DrvMsg*)std::calloc(sizeof(DrvMsg), 1));

            //set the opcode for get value from the driver
            driver_message->opcode = TutorialRTDriverOpcode_SET_CH_1;

            //associate the driver message input data to output attribute pointer
            driver_message->inputData = (int32_t*)in_1;
            driver_message->inputDataLength = sizeof(int32_t);
            //send message to the driver, at index 0, in async
            getAccessoInstanceByIndex(0)->send(driver_message.get());

            break;
          }
          default:
          break;
        }
      }
      //reset the chagned index
      getAttributeCache()->resetChangedInputIndex();
      */
}

/*
CDataWrapper *__template_name__::my_custom_action(CDataWrapper *actionParam, bool& detachParam) {
	CDataWrapper *result =  new CDataWrapper();
	return result;
}
*/
