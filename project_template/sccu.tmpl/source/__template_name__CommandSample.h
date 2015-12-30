/*
 *	__template_name__CommandSample.h
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

#ifndef __ControlUnitTest____template_name__CommandSample__
#define __ControlUnitTest____template_name__CommandSample__

#include <chaos/cu_toolkit/control_manager/slow_command/SlowCommand.h>
#include "__template_name__Interface.h"
using namespace chaos;

namespace c_data = chaos::common::data;
namespace ccc_slow_command = chaos::cu::control_manager::slow_command;

using namespace chaos::driver::__template_name__;

class __template_name__CommandSample : public ccc_slow_command::SlowCommand {

  // TODO: PUT HERE YOUR VARIABLES
  double *o_out1_p;
  int *o_out2_p;
  const int *i_timeout_p;
  int parm_from_cmd;
  int cnt;
  
  ///
  // your driver interface
  __template_name__Interface *driver;
  
   protected:
    // return the implemented handler
    uint8_t implementedHandler();
    
    // Start the command execution
    void setHandler(c_data::CDataWrapper *data);
    
    // Aquire the necessary data for the command
    /*!
     The acquire handler has the purpose to get all necessary data need the by CC handler.
     \return the mask for the runnign state
     */
    void acquireHandler();
    
    // Correlation and commit phase
    void ccHandler();
    
    bool timeoutHandler();

    
public:
    static const char* command_alias;
    
    __template_name__CommandSample();
    ~__template_name__CommandSample();
};

#endif /* defined(__ControlUnitTest____template_name__CommandSample__) */
