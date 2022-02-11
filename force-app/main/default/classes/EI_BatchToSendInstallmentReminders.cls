public class EI_BatchToSendInstallmentReminders implements Database.Batchable<sObject>,Database.AllowsCallouts,schedulable{
	
    public static Boolean isTopup = false; 
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new EI_BatchToSendInstallmentReminders(), 1);
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
		Date todayDate = System.today();
        String query = 'Select Id, Is_Topup__c, Deposit__c, Deposit__r.Customer_email__c, Deposit__r.Customer__c, Deposit__r.Date_Deposit_Received__c, '
            +'Deposit__r.Property_Address_WO_Country__c, Deposit__r.Status__c, X30_Days_Reminder__c, X60_Days_Reminder__c, Deposit__r.Customer__r.Name, '
            +'Deposit__r.Customer__r.PersonEmail from Installment__c where Status__c = \'Pending\' AND (X30_Days_Reminder__c =: todayDate '
            +'OR X60_Days_Reminder__c =: todayDate)';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Installment__c inst = (Installment__c)scope[0];
        
        if(inst.X30_Days_Reminder__c == System.today() && inst.Deposit__r.Status__c != 'Registered (not paid)' && inst.Deposit__r.Status__c != 'Deposit registration deleted'){
            
            //Send30DaysEmail 
			sendEmail(inst,true);
            
        }else if(inst.Deposit__r.Status__c != 'Registered (not paid)' && inst.Deposit__r.Status__c != 'Deposit registration deleted'){
            
            sendEmail(inst,false);
			if(inst.Deposit__r.Status__c == 'Awaiting payment'){
                
                Update new Deposit__c(Id= inst.Deposit__c,Status__c = 'Deposit registration deleted');
            }
            Delete inst;
        }
    
    }
    public void finish(Database.BatchableContext BC){
   
    }

    public static void sendEmail(Installment__c installment, Boolean is30Days) {
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        String toEmail = installment.Deposit__r.Customer_email__c;
        String toName = installment.Deposit__r.Customer__r.Name;
        
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toEmail, toName, installment.Deposit__c, installment.Deposit__r.Customer__c));
        variableMap.put('date',todayStr);
        variableMap.put('name',toName);
        variableMap.put('date_deposit_registered',String.valueOf(installment.Deposit__r.Date_Deposit_Received__c));
        variableMap.put('property_address',installment.Deposit__r.Property_Address_WO_Country__c);
        if(is30Days){
            if(installment.Is_Topup__c){
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositNotReceivedReminder30Days',
                                                                               'Reminder - Deposit not yet received - ('+installment.deposit__r.Property_Address_WO_Country__c+')'
                                                                              ));
            }else{
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositNotReceivedReminder30Days',
                                                                               'Reminder - Deposit not yet received - ('+installment.deposit__r.Property_Address_WO_Country__c+')'
                                                                              ));
            }
        }else{
            if(installment.Is_Topup__c){
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                       'DepositNotReceivedReminder60Days',
                                                                       'Reminder - Deposit not yet received - ('+installment.deposit__r.Property_Address_WO_Country__c+')'
                                                                      ));
            }else{
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                       'DepositNotReceivedReminder60Days',
                                                                       'Reminder - Deposit not yet received - ('+installment.deposit__r.Property_Address_WO_Country__c+')'
                                                                      ));
            }
        }
        
        /* Newly added code for adding recipients, variables, template name, Subject END */
        try{
            /* Newly added code for adding recipients, variables, template name, Subject START */
            if(emailWrapperList.size()>0) {
                EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList)); 	  
            }
            /* Newly added code for adding recipients, variables, template name, Subject END */
            
        }
        catch(exception e){   
            //saveMessageDetails(resBody,recMap,Subject );
            system.debug(e);
            //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
        }
        //sendEmail( subject,  recList, variables, 'ZP7',  'mailJetZD');
        // recipient(String Email,String to,String recId);
        //Sent Mail by MailJet
    }
    
    @InvocableMethod(label='Send Topup' description='')
    public static void sendTopupEmails(List<ID> ids) {
        system.debug('>>>>>>'+ids.size());
        set<String> depositIds = new set<String>();
        list<Installment__c> installmentList = [Select Id,Deposit__c,Amount__c from Installment__c where Id IN: ids];
        map<string,Decimal> depositIdVsAmount = new map<string,Decimal>();
        map<string,list<Deposit_Allocation__c>> depositIdVsAllocations = new map<string,list<Deposit_Allocation__c>>();
        for(Installment__c inst : installmentList){
            depositIds.add(inst.Deposit__c);
            depositIdVsAmount.put(inst.Deposit__c,inst.Amount__c);
        }
        if(!depositIds.isEmpty()){

            list<Deposit_Allocation__c> allocationList = [Select Id,Deposit__c,Deposit__r.Customer__c,Deposit__r.Customer_Email__c,Deposit__r.Customer_Name__c,Deposit_Holder__c,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Name, 
                                                                    Deposit__r.Property_Address__c, Role__c, Deposit_Holder__r.personContactId,
                                                                    Deposit__r.Deposit_Account_Number__c  from Deposit_Allocation__c where Deposit__c IN : depositIds AND Role__c = 'Tenant'];
            
            for(Deposit_Allocation__c allocation : allocationList){
                
                if(depositIdVsAllocations.containsKey(allocation.Deposit__c)){
                    list<Deposit_Allocation__c> all =  depositIdVsAllocations.get(allocation.Deposit__c);
                    all.add(allocation);
                    depositIdVsAllocations.put(allocation.Deposit__c,all);
                }else{
                    depositIdVsAllocations.put(allocation.Deposit__c,new list<Deposit_Allocation__c>{allocation});
                }
            }
            for(String depositId : depositIdVsAllocations.keySet()){
                
                list<Deposit_Allocation__c> allList = depositIdVsAllocations.get(depositId);
                
                sendEmailTopup(JSON.serialize(allList),depositIdVsAmount.get(depositId),allList[0].Deposit__r.Customer_Email__c,allList[0].Deposit__r.Customer_Name__c);
                
            }

        }
        
  	}
    
    @future(callout=true)
    public static void sendEmailHold(String depoIds,string allocationIds) {
        
        set<Id> depositIds = (set<Id>)System.JSON.deserialize(depoIds, set<Id>.class);
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Utility mailjet END */
        
        for(Deposit__c dep : [Select Id, Customer__c, Customer_Name__c,Customer_Email__c,Property_Address__c,Deposit_Account_Number__c,(Select Id,Deposit_Holder__c,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Name, Deposit_Holder__r.personContactId from Deposit_Allocations__r where Flag_Email__c = false) from Deposit__c where Id In: depositIds]){
            for(Deposit_Allocation__c allocation: dep.Deposit_Allocations__r)
            {
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                Map<String, String> variableMap = new Map<String, String>();
                
                String toEMail = String.isNotBlank(allocation.Deposit_Holder__r.personEmail)?allocation.Deposit_Holder__r.personEmail:'';
                String toName = String.isNotBlank(allocation.Deposit_Holder__r.Name)?allocation.Deposit_Holder__r.Name:'';
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toEMail, toName, dep.Id, allocation.Deposit_Holder__r.personContactId));
                variableMap.put('date',todayStr);
                variableMap.put('name',toName);
                variableMap.put('property_address',dep.Property_Address__c);
                
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositProtected',
                                                                               'Deposit Protected - ('+dep.Deposit_Account_Number__c+', '+dep.Property_Address__c+')'
                                                                              ));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            } 
            //??????????????? for Agent 
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            Map<String, String> variableMap = new Map<String, String>();
            
            String toEMail = String.isNotBlank(dep.Customer_email__c)?dep.Customer_email__c:'';
            String toName = String.isNotBlank(dep.Customer_Name__c)?dep.Customer_Name__c:'';
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toEMail, toName, dep.Id, dep.Customer__c));
            variableMap.put('date',todayStr);
            variableMap.put('name',toName);
            variableMap.put('property_address',dep.Property_Address__c);
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'DepositProtected',
                                                                           'Deposit Protected - ('+dep.Deposit_Account_Number__c+', '+dep.Property_Address__c+')'
                                                                          ));
            /* Newly added code for adding recipients, variables, template name, Subject END */
            
        }
        
        try{
            /* Newly added code for adding recipients, variables, template name, Subject START */
            if(emailWrapperList.size()>0) {
                EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList)); 	  
            }
            /* Newly added code for adding recipients, variables, template name, Subject END */
            
        }
        catch(exception e){   
            //saveMessageDetails(resBody,recMap,Subject );
            system.debug(e);
            //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
        }
        //sendEmail( subject,  recList, variables, 'ZP7',  'mailJetZD');
        // recipient(String Email,String to,String recId);
        //Sent Mail by MailJet
    }
    
    @future(callout=true)
    public static void sendEmailTopup(String all,Decimal amount, String agentEmail, String agentName){

        list<Deposit_Allocation__c> allocationList = (list<Deposit_Allocation__c>)System.JSON.deserialize(all, list<Deposit_Allocation__c>.class);
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Utility mailjet END */
        
        for(Deposit_Allocation__c allocation: allocationList)
        {
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            Map<String, String> variableMap = new Map<String, String>();
            
            String toEMail = String.isNotBlank(allocation.Deposit_Holder__r.personEmail)?allocation.Deposit_Holder__r.personEmail:'';
            String toName = String.isNotBlank(allocation.Deposit_Holder__r.Name)?allocation.Deposit_Holder__r.Name:'';
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toEMail, toName, allocation.Deposit__c, allocation.Deposit_Holder__r.personContactId));
            variableMap.put('date',todayStr);
            variableMap.put('name',toName);
            variableMap.put('DAN',allocation.Deposit__r.Deposit_Account_Number__c);
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'DepositAmountUpdated',
                                                                           'Deposit Amount Updated - ('+allocation.Deposit__r.Deposit_Account_Number__c+', '+allocation.Deposit__r.Property_Address_WO_Country__c+')'
                                                                          ));
            /* Newly added code for adding recipients, variables, template name, Subject END */
            
        } 
        //??????????????? for Agent 
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        
        String toEMail = String.isNotBlank(agentEmail)?agentEmail:'';
        String toName = String.isNotBlank(agentName)?agentName:'';
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toEMail, toName, allocationList[0].Deposit__c, allocationList[0].Deposit__r.Customer__c));
        variableMap.put('date',todayStr);
        variableMap.put('name',toName);
        variableMap.put('DAN',allocationList[0].Deposit__r.Deposit_Account_Number__c);
        
        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                       'DepositAmountUpdated',
                                                                       'Deposit Amount Updated - ('+allocationList[0].Deposit__r.Deposit_Account_Number__c+', '+allocationList[0].Deposit__r.Property_Address_WO_Country__c+')'
                                                                      ));
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        try{
            if(emailWrapperList.size()>0) {
                EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList)); 	  
            }
            
        }
        catch(exception e){   
            //saveMessageDetails(resBody,recMap,Subject );
            system.debug(e + ' => ' +e.getLineNumber());
            //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
        }
        //sendEmail( subject,  recList, variables, 'ZP7',  'mailJetZD');
        // recipient(String Email,String to,String recId);
        //Sent Mail by MailJet
    }
    
}