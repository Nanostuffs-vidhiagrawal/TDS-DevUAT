trigger EI_PaymentsTrigger on Payment__c (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        system.debug('>>>>>Trigger.newMap'+Trigger.newMap);
		EI_PaymentsTriggerHelper.validatePayments(Trigger.new,Trigger.newMap.keySet());
    }

}