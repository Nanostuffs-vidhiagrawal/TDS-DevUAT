public without sharing class EI_ReminderForEvidenceMails1 implements Queueable,Database.AllowsCallouts {
    
    public Map<String,Set<Id>> mapOfcaseIds;
    public Set<Id> caseIds;
    /* Newly added code for Mailjet Utility Class START */
    public List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList;
    /* Newly added code for Mailjet Utility Class END */
    
    public EI_ReminderForEvidenceMails1(Map<String,Set<Id>> mapOfcaseIds) {
        
        this.mapOfcaseIds = mapOfcaseIds;
        this.caseIds = new Set<Id>();
    }
    
    public void execute(QueueableContext QU) {
        
        for(string MailTy : mapOfcaseIds.keyset()) {
            for(Id caseId : mapOfcaseIds.get(MailTy)) {
            	if(!caseIds.contains(caseId))  caseIds.add(caseId); 
            }
        }
        
        // String SDSEmail = 'ashish.singh1@espire.com';
        
        for(Case_Participant__c caspart : 
            [Select id,name,Type__c,Is_Lead__c,Case__c,Case__r.Status,Contact__r.Email,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,
             Case__r.Tenancy_Property_Address__c,Case__r.Deposit_Account_Number__c,Case__r.Disputed_Amount__c,Case__r.Deposit_Account_Number__r.Name,
             Contact__c, Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, Case__r.Respond_Date__c  
             from Case_Participant__c where Case__c IN : caseIds]) 
        {
            String jsonBody;
            
            if((caspart.Type__c == 'Landlord'  || caspart.Type__c == 'Agent' )) {
                if( mapOfcaseIds.get('EvidenceGLL').contains(caspart.Case__c)) {
                    // For agent and landlord
                    getJSONBODYForTTAndLL(caspart, 'Agent', emailWrapperList);
                } else {
                    if(mapOfcaseIds.get('SelfRes').contains(caspart.Case__c)) {
                        // For tenant
                        getJSONBODYForTTLLSelf(caspart, 'Agent', emailWrapperList); 
                    }
                    else
                        if(mapOfcaseIds.get('SelfRes10DayR').contains(caspart.Case__c)) {
                            // json for informing 10 addition days for self resolution
                            getJSONBODYForTTLLSelf10(caspart, 'Agent', emailWrapperList); 
                        }
                }
            }
            if(caspart.Type__c == 'Tenant' ) {
                if(mapOfcaseIds.get('EvidenceGTT').contains(caspart.Case__c)) {
                    //jsonBody = getJSONBODYForTTAndLL(caspart,SDSEmail,'Tenant');
                    getJSONBODYForTTAndLL(caspart, 'Tenant', emailWrapperList);
                } else {
                    if(mapOfcaseIds.get('SelfRes').contains(caspart.Case__c)) {
                        // json for sending reminder for self resolution
                        getJSONBODYForTTLLSelf(caspart, 'Tenant', emailWrapperList); 
                    }
                    else {
                        if(mapOfcaseIds.get('SelfRes10DayR').contains(caspart.Case__c)) {
                            // json for informing 10 addition days for self resolution
                            getJSONBODYForTTLLSelf10(caspart, 'Tenant', emailWrapperList); 
                        }
                    }
                }
            } 
            
            if(String.isNotBlank(JsonBody))
                EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo(JsonBody);
        }
        
        /* Sending Email through MailJet Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList)); 	  
        }
        /* Sending Email through MailJet Utility Class END */
        
    }
    
    public static void getJSONBODYForTTAndLL(Case_Participant__c castInst, String status, 
                                             List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) 
    {
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        Date respondDate = castInst.Case__r.Respond_Date__c;
        String respondDateStr = respondDate.day()+'/'+respondDate.month()+'/'+respondDate.year();
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(castInst.Contact__r.Email, castInst.Contact__r.name, 
                                                                      '', castInst.Case__c,castInst.Contact__c));
        Map<String, String> variableMap = new Map<String, String>();
        
        if(status == 'Tenant') {
            variableMap.put('date',todayStr);
            variableMap.put('name',castInst.Contact__r.Name);
            variableMap.put('respondDate',respondDateStr);
        } else {
            variableMap.put('date',todayStr);
            variableMap.put('name',castInst.Contact__r.Name);
            variableMap.put('respondDate',respondDateStr);
        }
        
        if(status == 'Tenant') {
            if(!castInst.Is_Lead__c) {
                emailWrapperList.add(
                    new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                              'RemainderToTTInEvidenceTT',
                                                              'Reminder of your evidence deadline - '
                                                              +castInst.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c));
            } else {
                emailWrapperList.add(
                    new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                              'RemainderToTTInEvidenceTT',
                                                              'Reminder to submit your evidence - '
                                                              +castInst.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c));
            }
        }
            
        else {
            emailWrapperList.add(
                new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                          'RemainderToAGLLInEvidenceAGLL',
                                                          'Reminder to submit your evidence - '
                                                          +castInst.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c));
        }
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
    }
    
    public static void getJSONBODYForTTLLSelf(Case_Participant__c castInst, String status, 
                                                List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) 
    {   
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(castInst.Contact__r.Email, castInst.Contact__r.name, 
                                                                      '', castInst.Case__c,castInst.Contact__c));
        Map<String, String> variableMap = new Map<String, String>();
        
        variableMap.put('date',todayStr);
        variableMap.put('name',castInst.Contact__r.Name);
        
        if(status == 'Tenant')
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'ReminderSelfRes5Days',
                                                                           'Reminder - Let us help you reach an agreement - '
                                                                           +castInst.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c
                                                                          ));
		else
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'ReminderSelfRes5Days',
                                                                           'Reminder - Let us help you reach an agreement - '
                                                                           +castInst.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c	
                                                                          ));
        
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
    }
    
    public static void getJSONBODYForTTLLSelf10(Case_Participant__c castInst, String status, 
                                                  List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) 
    {
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(castInst.Contact__r.Email, castInst.Contact__r.name, 
                                                                      '', castInst.Case__c, castInst.Contact__c));
        Map<String, String> variableMap = new Map<String, String>();
        
        variableMap.put('date',todayStr);
        variableMap.put('name',castInst.Contact__r.Name);
        
        if(status == 'Tenant')
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'ReminderSelfRes10Days',
                                                                           'No agreement yet reached - next steps - '
                                                                           +castInst.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c
                                                                          ));
		else
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'ReminderSelfRes10Days',
                                                                           'No agreement yet reached - next steps - '
                                                                           +castInst.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c
                                                                          ));
        
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
    }
    
}