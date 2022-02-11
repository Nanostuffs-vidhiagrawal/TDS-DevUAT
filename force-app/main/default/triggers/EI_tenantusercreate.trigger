trigger EI_tenantusercreate on Deposit__c (before insert,after insert, before update,after update) {
  // putting a check in trigger 24 June 2021 by Tajinder
    QueryLimits__c querylimit = QueryLimits__c.getValues('All Limits'); 
    if(querylimit.CheckOn__c) {
        List<Deposit__c> updateddepositlist = new  List<deposit__c> ();
        List<Deposit__c> depositList = new  List<deposit__c> ();
        Integer noOfDeposit = 0;
        
        if(Trigger.isBefore && Trigger.isInsert) {             
            EI_repaidreasonhandler.repaidReasonStatus1(trigger.new); 
        }
        
        if(Trigger.isAfter && Trigger.isInsert) {
            // To track the Deposit Status History
            EI_SdsColleagueChangesCaseStatus.depositStatusHistoryOnInsert(trigger.new, trigger.newMap); 
        }
        
        if(Trigger.isBefore && Trigger.isupdate) {           
            EI_repaidreasonhandler.repaidReasonStatus(trigger.new); 
            EI_repaidreasonhandler.repaidReasonStatus2(trigger.new, trigger.oldMap);
            
            // To track the Deposit Status History
            EI_SdsColleagueChangesCaseStatus.depositStatusHistoryOnUpdate(trigger.new, trigger.newMap, trigger.oldMap); 
        }
        
        if (Trigger.isAfter && Trigger.isUpdate) {
            
            for (Deposit__c dep : trigger.new) {      
                depositList.add(dep);  
                if((dep.Status__c=='Deposits held by scheme') && (Trigger.oldMap.get(dep.Id).Status__c !=dep.Status__c ) /*&& (dep.User_Activated__c==false)*/) {
                    updateddepositlist.add(dep);
                    EI_tenantusercreatehandler.createuserNew(updateddepositlist,Trigger.newMap.keySet());  
                     EI_DPCCertificate.saveDpcCertificate(dep.id);
                }
                else{              
                    
                }
                System.debug(dep.Active__c);
            }
            if(depositList.size()>0) {
                UpdateNumberOfDeposit.updateProperty(depositList);
            }
            EI_tenantusercreatehandler.deactivateProperty(trigger.new, trigger.newMap, trigger.oldMap);
            
        }
        
         if(Trigger.isAfter && Trigger.isInsert){
            for (Deposit__c dep : trigger.new){  
                if(!(System.isBatch() || System.isFuture())){
                    EI_PICertificateToAzure.savePICertificate(dep.id);
                }
            }
        }
        
    }
}