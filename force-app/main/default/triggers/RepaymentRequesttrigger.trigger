trigger RepaymentRequesttrigger on Repayment_Request__c (before update,after insert,before insert,after update) {


        if(Trigger.isBefore && Trigger.isInsert){ 
        
        
        }
        if(Trigger.isAfter && Trigger.isInsert){ 
        
            EI_Handler_RepaymentRequest.afterInsertoperation(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
        
        }
        if(Trigger.isBefore && Trigger.isUpdate){ 
        
        
        }
        if(Trigger.isAfter && Trigger.isUpdate){ 
        
            EI_Handler_RepaymentRequest.afterUpdateoperation(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
        
        }



}