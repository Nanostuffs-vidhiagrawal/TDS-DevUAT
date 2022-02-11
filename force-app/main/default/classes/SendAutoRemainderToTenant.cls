/*
* Class Name: SendAutoRemainderToTenant
* Description: Batch class to send the auotoreminder to tenant
* Test Class: TestSendAutoRemainderToTenant
* Date : 12th Jan 2021
*/
global class SendAutoRemainderToTenant implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public Integer reminderFirstMailSend = Integer.valueOf(System.Label.FirstReminderMail);
    public Integer reminderSecondMailSend = Integer.valueOf(System.Label.SecondReminderMail);
    public Integer reminderThirdMailSend = Integer.valueOf(System.Label.ThirdReminderMail);
    public String fromAddress;
    public String fromName;
    public Integer mailJetTemplateId;
    public String schemeSignatory;
    public Integer thirtyMailJetTemplateId;
    public String thirtySchemeSignatory;
    
    /*
    * Method Name: start
    * Description: to query all the records
    * Parameters : Database.BatchableContext BC
    * Return Type: Database.QueryLocator
    * Date : 12th Jan 2021
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {            
        String query = 'Select id,Repayment_Request__c,CreatedDate,Repayment_Request__r.Case__c,Repayment_Request__r.Deposit__c, Is_Lead__c, '
            +'Repayment_Requested_Mail_Sent__c,Repayment_Request__r.Deposit__r.Property_Address__c, Account__r.Name, Account__r.PersonEmail, '
            +'Contact__c, Contact__r.Email, Contact__r.Name, '
            +'AL_ReqAmt__c,Repayment_Request__r.Deposit__r.Name,Tenant_ReqAmt__c,Repayment_Request__r.Deposit__r.Scheme_Name__c, '
            +'Repayment_Request__r.Status__c,Repayment_Request__r.Case__r.Status, Account__c, Account__r.personContactId, '
            +'Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c, Account__r.RecordType.Name, Type__c, '
            +'Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c from Repayment_Request_Line__c '
            +'WHERE Repayment_Request__r.AL_Repay_Requested__c=true AND (Repayment_Requested_Mail_Sent__c<=LAST_N_DAYS:'
            +reminderFirstMailSend+' OR Repayment_Requested_Mail_Sent__c<=LAST_N_DAYS:'
            +reminderSecondMailSend+' OR Repayment_Requested_Mail_Sent__c<=LAST_N_DAYS:'+reminderThirdMailSend+') '
			+'AND Repayment_Request__c=\'a1B3H000000ZKLnUAO\' limit 50000';
        
        system.debug('Line 35 -> '+query);
        return Database.getQueryLocator(query); 
    }
    
    /*
    * Method Name: execute.
    * Description: to process all the records
    * Parameters : Database.BatchableContext BC, List<Repayment_Request_Line__c> repaymentRequestLineList
    * Return Type: void
    * Date : 12th Jan 2021
    */
    global void execute(Database.BatchableContext BC, List<Repayment_Request_Line__c> repaymentRequestLineList) {
        system.debug('++++++repaymentRequestLineList+++++++++'+repaymentRequestLineList);
        Map<Id,String> mapCaseIdCaseStatus = new Map<Id,String>();
        List<Case> listCaseRecords = new List<Case>();
        List<Repayment_Request__c> listRepayRecords = new List<Repayment_Request__c>();
        Map<Id,String> mapRepayIdRepayStatus = new Map<Id,String>();
        Date firstMailDaysDate = System.today().addDays(-reminderFirstMailSend);
        Date secondMailDaysDate = System.today().addDays(-reminderSecondMailSend);
        Date lastMailDaysDate = System.today().addDays(-reminderThirdMailSend);
        
        String jsonData;
        String TDate = String.valueOf(System.today());
        
        Map<Id,Repayment_Request_Line__c> mapRepayLineItem = new Map<Id,Repayment_Request_Line__c>();
        Map<String,Bank_Account__c> mapOfContactIdVsBankDet = new Map<String,Bank_Account__c>(); //EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
        Set<String> setOfContactId = new Set<String>();
        //Map<String, String> mapOfContactIdVsRepReqLineId = new Map<String, String>();
        Map<Id,Installment__c> mapOfRepReqIdVsInst = new Map<Id,Installment__c>();
                
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        Date untilDate = EI_UtilityClassForPayments.dueDateMethod(System.today(), 30);
        String untilDateStr = untilDate.day()+'/'+untilDate.month()+'/'+untilDate.year();
        /* Newly added code for Mailjet Utility Class END */
        
        for(Repayment_Request_Line__c repaymentRequestLine : repaymentRequestLineList) {
            
            if(repaymentRequestLine.Repayment_Request__r.Case__c!=null && repaymentRequestLine.Type__c=='Tenant' && 
               (repaymentRequestLine.Repayment_Request__r.Case__r.Status.equals(Label.Repayment_requested_agent_landlord) || 
                repaymentRequestLine.Repayment_Request__r.Case__r.Status=='Repayment requested - no response from tenant'))
            {
                System.debug('Line 80 -> '+repaymentRequestLine.Id);
                System.debug('Line 81 -> '+repaymentRequestLine.Repayment_Requested_Mail_Sent__c);
                //15 and 25 days reminder date
                /*if(repaymentRequestLine.Repayment_Requested_Mail_Sent__c==firstMailDaysDate ||
                   repaymentRequestLine.Repayment_Requested_Mail_Sent__c==secondMailDaysDate) */
                if(System.today()==EI_UtilityClassForPayments.dueDateMethod(repaymentRequestLine.Repayment_Requested_Mail_Sent__c,15) ||
                   System.today()==EI_UtilityClassForPayments.dueDateMethod(repaymentRequestLine.Repayment_Requested_Mail_Sent__c,25))
                {
                    System.debug('Line 85 -> '+repaymentRequestLine.Id);
                    //if(String.IsNotBlank(repaymentRequestLine.Account__r.PersonEmail)) {     
                    if(System.today()==EI_UtilityClassForPayments.dueDateMethod(repaymentRequestLine.Repayment_Requested_Mail_Sent__c,15)) {
                        System.debug('Line 91 -> First email reminder on 15 days');
                        mapCaseIdCaseStatus.put(repaymentRequestLine.Repayment_Request__r.Case__c,Label.No_Response_from_Tenant);
                        mapRepayIdRepayStatus.put(repaymentRequestLine.Repayment_Request__c,Label.No_Response_from_Tenant);
                        System.debug('Line 91 -> '+mapCaseIdCaseStatus);
                        System.debug('Line 94 -> '+mapRepayIdRepayStatus);
                    }
                    
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentRequestLine.Account__r.PersonEmail, 
                                                                                  repaymentRequestLine.Account__r.Name, 
                                                                                  repaymentRequestLine.Repayment_Request__r.Case__c, repaymentRequestLine.Account__r.personContactId));
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('Date', todayStr);
                    variableMap.put('name', repaymentRequestLine.Account__r.Name);
                    variableMap.put('DAN', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
                    variableMap.put('Address', repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
                    variableMap.put('untildate', untilDateStr);
                    /*if(repaymentRequestLine.Repayment_Requested_Mail_Sent__c==firstMailDaysDate) {
                        variableMap.put('untildate', repaymentRequestLine.Repayment_Requested_Mail_Sent__c.addDays(reminderFirstMailSend).format());
                    }
                    else {
                        variableMap.put('untildate', repaymentRequestLine.Repayment_Requested_Mail_Sent__c.addDays(5).format());
                    }*/
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'ReminderToTenant1525', 
                                                                                   'Reminder to respond to deposit repayment request '
                                                                                   +repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c));
                    
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                    
                    //}
                }
                
            }
            
            if(repaymentRequestLine.Repayment_Request__r.Case__c!=null 
               /*&& repaymentRequestLine.Repayment_Request__r.Case__r.Status.equals(Label.No_Response_from_Tenant)*/) 
            {
                //30 days reminder date
                //if(repaymentRequestLine.Repayment_Requested_Mail_Sent__c==lastMailDaysDate)
                if(System.today()==EI_UtilityClassForPayments.dueDateMethod(repaymentRequestLine.Repayment_Requested_Mail_Sent__c,30)) 
                {
                    //if(String.IsNotBlank(repaymentRequestLine.Account__r.PersonEmail)) {                        
                    mapCaseIdCaseStatus.put(repaymentRequestLine.Repayment_Request__r.Case__c,Label.NoDispute_Repaid);
                    mapRepayIdRepayStatus.put(repaymentRequestLine.Repayment_Request__c,Label.NoDispute_Repaid);
                    mapRepayLineItem.put(repaymentRequestLine.Id, repaymentRequestLine);
                    //setOfContactId.add(repaymentRequestLine.Account__c);
                    
                    system.debug('Line 50');
                    
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    if(repaymentRequestLine.Type__c=='Tenant') {
                        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentRequestLine.Account__r.PersonEmail, 
                                                                                      repaymentRequestLine.Account__r.Name, 
                                                                                      repaymentRequestLine.Repayment_Request__r.Case__c, repaymentRequestLine.Account__r.personContactId));
                        setOfContactId.add(repaymentRequestLine.Account__r.personContactId);
                        Map<String, String> variableMap = new Map<String, String>();
                        variableMap.put('Date', todayStr);
                        variableMap.put('name', repaymentRequestLine.Account__r.Name);
                        variableMap.put('DAN', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
                        variableMap.put('Address', repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
                        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                       'ReminderToTenant30', 
                                                                                       'No response from tenant - Deposit to be repaid '
                                                                                       +repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c));
                        
                    } 
                    else {
                        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentRequestLine.Contact__r.Email, 
                                                                                      repaymentRequestLine.Contact__r.Name, 
                                                                                      repaymentRequestLine.Repayment_Request__r.Case__c, repaymentRequestLine.Contact__c));
                        setOfContactId.add(repaymentRequestLine.Contact__c);
                        Map<String, String> variableMap = new Map<String, String>();
                        
                        variableMap.put('date', todayStr);
                        variableMap.put('name', repaymentRequestLine.Account__r.Name);
                        variableMap.put('Address', repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
                        variableMap.put('DAN', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
                        variableMap.put('untildate', untilDateStr);
                        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                       'ReminderToAgent30', 
                                                                                       'No response from tenant - Deposit to be repaid '
                                                                                       +repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c));
                    }
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                    
                    //}
                }
            }
        }
        
        /* Sending Email through MailJet Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList)); 	  
        }
        /* Sending Email through MailJet Utility Class END */
        
        /* Newly Added Code for Payment START */
        if(!mapRepayLineItem.isEmpty()) {
            mapOfContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(setOfContactId);
            for(Repayment_Request_Line__c repReqLine : mapRepayLineItem.values()) {
                System.debug('Line 206 -> '+repReqLine.Id);
                if(repReqLine.AL_ReqAmt__c>0)
                    EI_UtilityClassForPayments.getInstallmentsForNoResponse(repReqLine, repReqLine.AL_ReqAmt__c, false, 'Final Payment', 
                                                                            mapOfContactIdVsBankDet, mapOfRepReqIdVsInst);
            }
            System.debug('Line 211 -> '+mapRepayLineItem.size());
            System.debug('Line 212 -> '+mapOfRepReqIdVsInst.size());
            if(!mapOfRepReqIdVsInst.isEmpty()) {
                System.debug('Line 201 -> '+mapOfRepReqIdVsInst);
                try {
                    insert mapOfRepReqIdVsInst.values();
                }
                catch(exception e) {
                    system.debug('Line 219 exception -> '+e.getmessage());
                }   
            }
        }
        /* Newly Added Code for Payment END */
        
        try{
            
            for(Id caseId : mapCaseIdCaseStatus.keyset()){
                Case caseRec = new Case(id=caseId);
                caseRec.Status = mapCaseIdCaseStatus.get(caseId);
                listCaseRecords.add(caseRec);
            }
            
            for(Id repayId : mapRepayIdRepayStatus.keyset()){
                Repayment_Request__c repay = new Repayment_Request__c(id=repayId);
                repay.Status__c = mapRepayIdRepayStatus.get(repayId);
                listRepayRecords.add(repay);
            }
            
            if(!listCaseRecords.isEmpty()){
                update listCaseRecords;
            }
            
            if(!listRepayRecords.isEmpty()){
                update listRepayRecords;
            }
        }
        catch(exception e){
            system.debug('++++++++++e.getlinenumber()+++++'+e.getlinenumber());
            system.debug('++++++++++e.getmessage()+++++'+e.getmessage());
        }       
        
    }
    
    /*
    * Method Name: finish
    * Description: 
    * Parameters : Database.BatchableContext BC
    * Return Type: void
    * Date : 12th Jan 2021
    */
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('Job'+job);
    }
    
}