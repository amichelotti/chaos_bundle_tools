/*
 *	__template_name__ControlUnit.h
 *	!CHAOS
 *	Automatically generated
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

#ifndef ____template_type_____template_name__ControlUnit_h__
#define ____template_type_____template_name__ControlUnit_h__

#include <chaos/cu_toolkit/control_manager/RTAbstractControlUnit.h>

namespace __template_type__ {
	namespace __template_name__ {
		
		class __template_name__ControlUnit : public chaos::cu::control_manager::RTAbstractControlUnit {
		  PUBLISHABLE_CONTROL_UNIT_INTERFACE(__template_name__ControlUnit)
			// init paramter
			std::string device_id;
			
		protected:
			//define dataset
			void unitDefineActionAndDataset();
			
			
			// init contorl unit
			void unitInit() ;
			
			//start contor unit
			void unitStart() ;
			
			//intervalled scheduled method
			void unitRun() ;
			
			//stop contor unit
			void unitStop() ;
			
			//deinit
			void unitDeinit() ;
		public:


			__template_name__ControlUnit(const std::string& _control_unit_id, const std::string& _control_unit_param, const ControlUnitDriverList& _control_unit_drivers);
    /*!
      Destructor a new CU
     */
			~__template_name__ControlUnit();

		};
	}
}

#endif /* defined(__ControlUnitTest__S7ControlUnit__) */
