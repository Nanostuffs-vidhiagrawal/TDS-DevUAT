trigger EI_Trigger_InboundReport on Inbound_Report__c (after update, after insert) {


    if(Trigger.isInsert && Trigger.isAfter){
        //call allocation batch from here
        EI_Trigger_InboundReportHelper.callAllocationBatch(Trigger.newMap.keySet());
    }

    if(Trigger.isUpdate){

        EI_Trigger_InboundReportHelper.createPayments(Trigger.oldMap,Trigger.newMap.keySet()); 

        
    }
}