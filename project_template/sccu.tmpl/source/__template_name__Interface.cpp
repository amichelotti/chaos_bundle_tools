//
//  __template_name__Interface.h
//  
// automatically generated
//  
// 
//


//  Copyright (c) 2014 andrea michelotti. All rights reserved.
//

#include "__template_name__Interface.h"
#include <chaos/common/exception/CException.h>




using namespace chaos::driver::__template_name__;

void __template_name__Interface::op1(int val){
  __template_name___iparams_t *idata =  (__template_name___iparams_t *)malloc(sizeof(__template_name___iparams_t)); 
  if(idata==NULL) {throw chaos::CException(1, "cannot allocate memory for driver", "__template_name__Interface::op1");} 

  idata->parm1 = val;
  message.opcode = OP_1;
  message.inputData=(void*)idata;				       
  message.inputDataLength=sizeof(__template_name___iparams_t); 
  message.resultDataLength=0;
  accessor->send(&message);						
  free(idata);

}

int __template_name__Interface::op2(int parm,double* val){
  int ret;
  __template_name___iparams_t *idata= (__template_name___iparams_t *)malloc(sizeof(__template_name___iparams_t)); 
  if(idata==NULL) {throw chaos::CException(1, "cannot allocate memory for driver", "input data __template_name__Interface::op2");}
  __template_name___oparams_t *odata= (__template_name___oparams_t *)malloc(sizeof(__template_name___oparams_t)); 
  if(odata==NULL) {throw chaos::CException(1, "cannot allocate memory for driver", "output data __template_name__Interface::op2");}
   
  idata->parm1 = parm;
  
  message.opcode = OP_2;	
  message.inputData=(void*)idata;				   
  message.inputDataLength=sizeof(__template_name___iparams_t); 
  message.resultDataLength=sizeof(__template_name___oparams_t);
  message.resultData = (void*)odata;	    
  accessor->send(&message);						
  ret= odata->drv_ret;
  *val = odata->drv_out;
  free(idata);
  free(odata);
  return ret;
}
