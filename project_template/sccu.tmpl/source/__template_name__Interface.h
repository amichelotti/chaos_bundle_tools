//
//  __template_name__Interface
//  
// automatically generated
//  
// 
//

#ifndef __template_name__Interface__
#define __template_name__Interface__

#include <iostream>
#include <chaos/cu_toolkit/driver_manager/driver/DriverTypes.h>
#include <chaos/cu_toolkit/driver_manager/driver/DriverAccessor.h>

namespace chaos_driver=::chaos::cu::driver_manager::driver;

namespace chaos {
    
    namespace driver {
        
        namespace __template_name__ {
            
            typedef enum {
	      OP_1, // opcode of a driver command
	      OP_2  // opcode of a driver command
            } __template_name__Opcodes;
            
	    // input driver parameters for driver commands
            typedef struct {
                int parm1;
	      
              
            } __template_name___iparams_t;
            
	    // output driver parameters
            typedef struct {
	      double drv_out;
	      int drv_ret;
            } __template_name___oparams_t;
            
            class   __template_name__Interface {
                
            protected:
                chaos_driver::DrvMsg message;
                
            public:
                
                __template_name__Interface(chaos_driver::DriverAccessor*_accessor):accessor(_accessor){};
                
                chaos_driver::DriverAccessor* accessor;
             
		void op1(int val);
		int op2(int parm,double* val);
	    };
            
        };
    };
};


#endif 
