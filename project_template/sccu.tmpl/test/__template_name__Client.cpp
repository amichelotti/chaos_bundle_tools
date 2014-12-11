
/*
 *
 *	!CHAOS
 *	Created automatically
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

#include <stdio.h>

#include <chaos/ui_toolkit/ChaosUIToolkit.h>
#include <chaos/ui_toolkit/LowLevelApi/LLRpcApi.h>
#include <chaos/ui_toolkit/HighLevelApi/HLDataApi.h>

using namespace chaos;
using namespace chaos::ui;

int sendCmd(DeviceController *controller ,std::string cmd_alias_str,char*param){
  int err;
  uint64_t cmd_id_tmp;
  std::auto_ptr<chaos::common::data::CDataWrapper> data_wrapper;
      
  if(param) {
    data_wrapper.reset(new chaos::common::data::CDataWrapper());
    if(data_wrapper.get())
      data_wrapper->setSerializedJsonData(param);
    else
      return -1001;
  }
			
  err = controller->submitSlowControlCommand(cmd_alias_str,
					     static_cast<chaos::common::batch_command::SubmissionRuleType::SubmissionRule>(0),
					     50,
					     cmd_id_tmp,
					     0,
					     0,
					     0,
					     data_wrapper.get());

  if (err != ErrorCode::EC_NO_ERROR) throw CException(2, "Error", "executing commant");
  chaos_batch::CommandState command_state;
  command_state.command_id = cmd_id_tmp;
  err = controller->getCommandState(command_state);
  std::cout << "Device state start -------------------------------------------------------" << std::endl;
  std::cout << "Command";
  switch (command_state.last_event) {
  case chaos_batch::BatchCommandEventType::EVT_COMPLETED:
    std::cout << " has completed"<< std::endl;;
    break;
  case chaos_batch::BatchCommandEventType::EVT_FAULT:
    std::cout << " has fault";
    std::cout << "Error code		:"<<command_state.fault_description.code<< std::endl;
    std::cout << "Error domain		:"<<command_state.fault_description.domain<< std::endl;
    std::cout << "Error description	:"<<command_state.fault_description.description<< std::endl;
    break;
  case chaos_batch::BatchCommandEventType::EVT_KILLED:
    std::cout << " has been killed"<< std::endl;
    break;
  case chaos_batch::BatchCommandEventType::EVT_PAUSED:
    std::cout << " has been paused"<< std::endl;
    break;
  case chaos_batch::BatchCommandEventType::EVT_QUEUED:
    std::cout << " has been queued"<< std::endl;
    break;
  case chaos_batch::BatchCommandEventType::EVT_RUNNING:
    std::cout << " is running"<< std::endl;
    break;
  case chaos_batch::BatchCommandEventType::EVT_WAITING:
    std::cout << " is waiting"<< std::endl;
    break;
  }
  std::cout << "Device state end ---------------------------------------------------------" << std::endl;


  return err;
}

void print_state(CUStateKey::ControlUnitState state) {
  switch (state) {
    case CUStateKey::INIT:
    std::cout << "Initialized" << std::endl;
    break;
    case CUStateKey::START:
    std::cout << "Started" << std::endl;
    break;
    case CUStateKey::STOP:
    std::cout << "Stopped" << std::endl;
    break;
    case CUStateKey::DEINIT:
    std::cout << "Deinitilized" << std::endl;
    break;
  }
}


int main (int argc, char* argv[] ) {
  int err = 0;
  std::string attribute_value_tmp_str;
  CUStateKey::ControlUnitState device_state;
  try{
    //init UIToolkit client
    ChaosUIToolkit::getInstance()->init(argc, argv);
    if(argc<2){
      printf("%s <CUID>\n",argv[0]);
      return -1;
    }

    DeviceController *controller = HLDataApi::getInstance()->getControllerForDeviceID(argv[1], 40000);
    if(!controller) return -1;

    //init device
    std::cout << "Init the device" << std::endl;
    err = controller->initDevice();
    if(err == ErrorCode::EC_TIMEOUT) return -1;
    print_state(device_state);
    sleep(2);

    //check the state
    err = controller->getState(device_state);
    if(err == ErrorCode::EC_TIMEOUT) return -1;
    print_state(device_state);
    sleep(2);

    //start the device
    std::cout << "Start the device" << std::endl;
    err = controller->startDevice();
    sleep(2);

    //check the state
    err = controller->getState(device_state);
    if(err == ErrorCode::EC_TIMEOUT) return -1;
    print_state(device_state);
    sleep(2);

    //print all dataset
    controller->fetchCurrentDatatasetFromDomain((DatasetDomain)0);
    if(controller->getCurrentDatasetForDomain((DatasetDomain)0) != NULL) {
      std::cout << controller->getCurrentDatasetForDomain((DatasetDomain)0)->getJSONString() <<std::endl;
    }

    controller->fetchCurrentDatatasetFromDomain((DatasetDomain)1);
    if(controller->getCurrentDatasetForDomain((DatasetDomain)1) != NULL) {
      std::cout << controller->getCurrentDatasetForDomain((DatasetDomain)1)->getJSONString() <<std::endl;
    }

    controller->fetchCurrentDatatasetFromDomain((DatasetDomain)2);
    if(controller->getCurrentDatasetForDomain((DatasetDomain)2) != NULL) {
      std::cout << controller->getCurrentDatasetForDomain((DatasetDomain)2)->getJSONString() <<std::endl;
    }

    controller->fetchCurrentDatatasetFromDomain((DatasetDomain)3);
    if(controller->getCurrentDatasetForDomain((DatasetDomain)3) != NULL) {
      std::cout << controller->getCurrentDatasetForDomain((DatasetDomain)3)->getJSONString() <<std::endl;
    }

    //set schedule time to 250 milliseconds
    std::cout << "set run schedule to 250 milliseconds" << std::endl;
    err = controller->setScheduleDelay(250000);
    sleep(2);


    //!update output dataset
    controller->fetchCurrentDatatasetFromDomain((DatasetDomain)0);
    if(controller->getCurrentDatasetForDomain((DatasetDomain)0) != NULL) {
      std::cout << controller->getCurrentDatasetForDomain((DatasetDomain)0)->getJSONString() <<std::endl;
    }
    sleep(2);

    char stringa[256];
    printf("commands: quit, dump, <alias:{json parameters}>\n");
    do{
      printf(">");
      
      gets(stringa);
      if(strstr(stringa,"quit")){
	break;
      } else if(strstr(stringa,"dump")){
	    //!update output dataset
	controller->fetchCurrentDatatasetFromDomain((DatasetDomain)0);
	if(controller->getCurrentDatasetForDomain((DatasetDomain)0) != NULL) {
	  std::cout << controller->getCurrentDatasetForDomain((DatasetDomain)0)->getJSONString() <<std::endl;
    }

      } else {
	char* pnt=0;
	if((pnt=strchr(stringa,':'))){
	  *pnt=0;
	  std::string alias(stringa);
	  sendCmd(controller ,alias,pnt+1);
	  std::cout << "* Sending command:\""<<alias<<"\" param: \""<<(pnt+1)<<"\""<<std::endl;
	  sleep(1);
	}
	printf("\n");
      }
    } while(1);
    //! stop the device
    std::cout << "Stop the device" << std::endl;
    err = controller->stopDevice();
    err = controller->getState(device_state);
    if(err == ErrorCode::EC_TIMEOUT) return -1;
    print_state(device_state);
    sleep(2);

    //! deinit the device
    std::cout << "Deinit the device" << std::endl;
    err = controller->deinitDevice();
    err = controller->getState(device_state);
    if(err == ErrorCode::EC_TIMEOUT) return -1;
    print_state(device_state);
    sleep(2);
    } catch (CException& e) {
        std::cerr << e.errorCode << " - "<< e.errorDomain << " - " << e.errorMessage << std::endl;
    }
    //deinit the toolkit
    try {
        //! [UIToolkit Deinit]
        ChaosUIToolkit::getInstance()->deinit();
        //! [UIToolkit Deinit]
    } catch (CException& e) {
        std::cerr << e.errorCode << " - "<< e.errorDomain << " - " << e.errorMessage << std::endl;
    }

    return 0;
}
