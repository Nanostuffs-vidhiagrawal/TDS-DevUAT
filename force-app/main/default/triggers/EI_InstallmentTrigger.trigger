trigger EI_InstallmentTrigger on Installment__c (after insert, after update) {
	
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
        
        EI_InstallmentTriggerHandler.createChequePayments(Trigger.oldMap,Trigger.new);
        
    }

    
}