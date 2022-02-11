public without sharing class EI_EvidenceGatheringMails {
    
    public static String getJBforNotifytentant(String tentEmail,String tentName) {
        String fromAddress;
        String fromName;
        String toAddress;
        String schemeSignatory;
        Integer mailJetTemplateId;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('EmailToActiveTTofNewDeposit'); 
        
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;  
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        schemeSignatory = templateId[0].Scheme_Signatory__c; 
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', fromAddress);
        gen.writeStringField('Name', fromName);
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', tentEmail);
        gen.writeStringField('Name', tentName);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        //    String templateId = API_Service__mdt.getInstance('EmailToActiveTTofNewDeposit').Template_Id__c;
        
        
        gen.writeNumberField('TemplateID', mailJetTemplateId);
        gen.writeBooleanField('TemplateLanguage', true);
        
        gen.writeStringField('Subject', 'New Deposit Protected – Confirm to add to your account ');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        
        gen.writeStringField('name', tentName); 
        gen.writeStringField('Date', string.valueOf(system.today())); 
        gen.writeStringField('schemeSignatory', schemeSignatory); 
        
        
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    @future(callout = true)
    public static void evidenceGatheringSendEmails(string useremail,string userpersonemail,string username,string DAN,String Address){ 
        
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'ashish.singh1@espire.com');
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        if(useremail!=null)
            gen.writeStringField('Email', useremail);
        else{
            gen.writeStringField('Email', userpersonemail);    
        }
        gen.writeStringField('Name', username);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2358560);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Reference: '+DAN+'Acceptance of tenant changeover – action required');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Date', system.today().format());
        gen.writeStringField('name', username);
        gen.writeStringField('DAN', DAN);
        gen.writeStringField('Address', Address);
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    public static void evidenceGatheringSendEmailsTo(string jsonData) {
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    @future(callout = true)
    public static void evidenceGatheringSendEmailsTo1(string jsonData) { 
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    public static String getJSONBODYofLL(Case_Participant__c castInst,String SDSEmail) {
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', SDSEmail);
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', castInst.Contact__r.Email);
        gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateId = API_Service__mdt.getInstance('RequestingAgent_LandlordEvidence').Template_Id__c;
        system.debug('templateId--->>> '+templateId);
        
        gen.writeNumberField('TemplateID', Integer.valueOf(templateId));
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        gen.writeStringField('Subject', 'Please submit your evidence - : '+firstLine);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        if(castInst.Case__r.Deposit_Account_Number__c != null)
            gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        if(castInst.Case__r.Tenancy_Property_Address__c != null)    
            gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
        if(castInst.Case__r.Disputed_Amount__c != null)    
            gen.writeStringField('DisputeAmount', String.valueOf(castInst.Case__r.Disputed_Amount__c));
        Date DueDateforEvidence = System.today().adddays(10);
        gen.writeStringField('DueDateforEvidence',String.valueOf(DueDateforEvidence));
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    public static String getJSONBODYofLLBYTT(Case_Participant__c castInst,String SDSEmail) {
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', SDSEmail);
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', castInst.Contact__r.Email);
        gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateId = API_Service__mdt.getInstance('RequestingAgent_LandlordEvidence').Template_Id__c;
        system.debug('templateId--->>> '+templateId);
        
        gen.writeNumberField('TemplateID', Integer.valueOf(templateId));
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        gen.writeStringField('Subject', 'Please submit your evidence - : '+firstLine);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
      //  gen.writeStringField('DisputeAmount', String.valueOf(castInst.Case__r.Disputed_Amount__c));
        Date DueDateforEvidence = System.today().adddays(10);
        gen.writeStringField('DueDateforEvidence',String.valueOf(DueDateforEvidence));
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    public static String getJSONBODYofTTByLL(Case_Participant__c castInst,String SDSEmail) {
        system.debug('line-->186 ' + castInst);
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', SDSEmail);
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', castInst.Contact__r.Email);
        gen.writeStringField('Name', castInst.Contact__r.Name);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateId = API_Service__mdt.getInstance('RequestingAgent_LandlordEvidence').Template_Id__c;
        system.debug('templateId--->>> '+templateId);
        
        gen.writeNumberField('TemplateID', Integer.valueOf(templateId));
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        if(castInst.Type__c=='Tenant'){
        gen.writeStringField('Subject', 'The agent/landlord has been asked to provide evidence - '+firstLine);
        }
        else{
        gen.writeStringField('Subject', 'The Tenant(s) has been asked to provide evidence - '+firstLine);    
        }
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
     //  gen.writeStringField('DisputeAmount', String.valueOf(castInst.Case__r.Disputed_Amount__c));
        Date DueDateforEvidence = System.today().adddays(10);
        gen.writeStringField('DueDateforEvidence',String.valueOf(DueDateforEvidence));
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    public static String getJSONBODYofTT(Case_Participant__c castInst,String SDSEmail) {
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', SDSEmail);
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', castInst.Contact__r.Email);
        gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateId = API_Service__mdt.getInstance('RequestingAgent_LandlordEvidence').Template_Id__c;
        system.debug('templateId--->>> '+templateId);
        
        gen.writeNumberField('TemplateID', Integer.valueOf(templateId));
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        if(castInst.Type__c=='Tenant' && castInst.Is_Lead__c==true ){
        gen.writeStringField('Subject', 'Please submit your evidence - : '+firstLine);
        }
        else{
         gen.writeStringField('Subject', 'Lead Tenant has been invited to submit evidence - : '+firstLine);   
        }
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
    	// gen.writeStringField('DisputeAmount', String.valueOf(castInst.Case__r.Disputed_Amount__c));
        Date EvidenceDueDate = System.today().adddays(10);
        gen.writeStringField('EvidenceDueDate',String.valueOf(EvidenceDueDate));
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    // Inviting AA/LL or TT for self resolution
    public static void getJSONBODYofinvite(Case_Participant__c castInst,String SDSEmail) {
        
        /* JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', SDSEmail);
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', castInst.Contact__r.Email);
        gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateId = API_Service__mdt.getInstance('RequestingAgent_LandlordEvidence').Template_Id__c;
        system.debug('templateId--->>> '+templateId);
        
        gen.writeNumberField('TemplateID', Integer.valueOf(templateId));
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        gen.writeStringField('Subject', 'Let us help you reach an agreement -'+firstLine);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        if(String.isnotBlank(castInst.Contact__r.Name))
            gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        if(String.isnotBlank(castInst.Case__r.Deposit_Account_Number__c))    
            gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        if(String.isnotBlank(castInst.Case__r.Tenancy_Property_Address__c))       
            gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
        // gen.writeStringField('DisputeAmount', String.valueOf(castInst.Case__r.Disputed_Amount__c));
        Date EvidenceDueDate = System.today().adddays(10);
        gen.writeStringField('EvidenceDueDate',String.valueOf(EvidenceDueDate));
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData; */
        
    }
    
    // Inviting AA/LL or TT for self resolution
    public static String getJSONBODYforTT_SR(Case_Participant__c castInst,String SDSEmail,String CarParType) {
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', SDSEmail);
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', castInst.Contact__r.Email);
        gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        String templateId = API_Service__mdt.getInstance('RequestingAgent_LandlordEvidence').Template_Id__c;
        system.debug('templateId--->>> '+templateId);
        
        gen.writeNumberField('TemplateID', Integer.valueOf(templateId));
        gen.writeBooleanField('TemplateLanguage', true);
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        gen.writeStringField('Subject', 'Let us help you reach an agreement -'+firstLine);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        if(String.isnotBlank(castInst.Contact__r.Name))
            gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        if(String.isnotBlank(castInst.Case__r.Deposit_Account_Number__c))    
            gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        if(String.isnotBlank(castInst.Case__r.Tenancy_Property_Address__c))       
            gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
        // gen.writeStringField('DisputeAmount', String.valueOf(castInst.Case__r.Disputed_Amount__c));
        Date EvidenceDueDate = System.today().adddays(10);
        gen.writeStringField('EvidenceDueDate',String.valueOf(EvidenceDueDate));
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    // NPP-4, NPP-5, //NPP-41 AC6.5 
    //@future(callout = true)
    //public static void notifyLandlordandTenant(Set<Id> caseIds,String stage) 
    public static void notifyLandlordandTenant(List<Case> caseList, Map<Id,Case> newMap, Map<Id,Case> oldMap)
    { 
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        Set<Id> casIdsForLL = new Set<Id>();
        Set<Id> casIdsForTT = new Set<Id>();
        Set<Id> casIdsSet = new Set<Id>();
        List<Deposit__C> newdeposits = new List<Deposit__C>();
        
        for(Case casinst : caseList) {
            if(casinst.RecordtypeId==devRecordTypeId) {
                if(casinst.Status == 'Evidence gathering AA/LL' &&
                   oldMap.get(casinst.Id).Status == 'Repayment disputed - self-resolution') 
                {
                    // Gather evidence from landlord/agent
                    casIdsForLL.add(casinst.Id);
                    casinst.Respond_Date__c = EI_UtilityClassForPayments.dueDateMethod(System.today(),10);
                    Deposit__c dc = new Deposit__c();
                    dc.Id = casinst.Deposit_Account_Number__c;
                    dc.Status__c = 'Repayment not agreed - In dispute resolution'; 
                    newdeposits.add(dc);
                }
                if(casinst.Status == 'Evidence gathering TT' && (oldMAp.get(casinst.Id).Status != 'Evidence gathering TT'
                   && oldMAp.get(casinst.Id).Status != 'On Hold')) 
                {
                    // Gather evidence from tenant
                    casIdsForTT.add(casinst.Id);
                    casinst.Respond_Date__c = EI_UtilityClassForPayments.dueDateMethod(System.today(),10);
                 	casinst.No_Tenant_Evidence__c = false;
                    Deposit__c dc = new Deposit__c();
                    dc.Id = casinst.Deposit_Account_Number__c;
                    dc.Status__c = 'Repayment not agreed - In dispute resolution';
                    newdeposits.add(dc);
                }
                //NPP-41 AC6.5 
                if(oldMap.get(casinst.Id).Status != casinst.Status && oldMap.get(casinst.Id).Status !='Repayment requested - tenant' 
                   && casinst.Status == 'Deposit to be repaid - repayment agreed') 
                { System.debug('Line 553 weird');
                    //call method to send email
                   // casIdsSet.add(casinst.Id);
                    Deposit__c dc = new Deposit__c();
                    dc.Id = casinst.Deposit_Account_Number__c;
                    // changing because of a bug in UAT 603 -- dc.Status__c = 'Repayment not agreed - In dispute resolution';
                    dc.Status__c = 'Repayment process';
                    newdeposits.add(dc);
                }
            } 
        }
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        /* Newly added code for Mailjet Utility Class END */
        
        if(!casIdsForLL.isEmpty()) {
            sendEmailForEvidGathering(casIdsForLL, 'LandlordEvdStage', emailWrapperList);
		}
        
        if(!casIdsForTT.isEmpty()) {
            sendEmailForEvidGathering(casIdsForTT, 'TenantEvdStage', emailWrapperList);
		}
        
    /*    if(!casIdsSet.isEmpty()) {
            sendEmailForEvidGathering(casIdsSet, 'TenantEvdStage', emailWrapperList);
        }*/
        
		if(!newdeposits.isEmpty()) {
        	update newdeposits;
		}
        
        /* Sending Email through MailJet Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
        }
        /* Sending Email through MailJet Utility Class END */
    }
    
    public static void sendEmailForEvidGathering(Set<Id> caseIds,String stage, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) {
        
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        for(Case_Participant__c caspart : 
            [SELECT Id, Name, Case__c, Contact__r.Email, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__c, 
             Case__r.Tenancy_Property_Address__c, Case_Participant__c.Type__c, Is_Lead__c, Case__r.Deposit_Account_Number__c, 
             Case__r.Deposit_Account_Number__r.Name, Case__r.Disputed_Amount__c, Case__r.Remaining_protected_amount__c, 
             Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, Case__r.Respond_Date__c 
             FROM Case_Participant__c WHERE Case__c IN : caseIds]) 
        {
            if((caspart.Type__c == 'Landlord' || caspart.Type__c == 'Agent') && caspart.Contact__r.Email != null) {
                
                // Sending mails to agent/landlord
                if(stage == 'LandlordEvdStage') {
                    
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    Date respondDate = caspart.Case__r.Respond_Date__c;
                    String respondDateStr = respondDate.day()+'/'+respondDate.month()+'/'+respondDate.year();
                    
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name, 
                                                                                  caspart.Case__c, caspart.Contact__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('date',todayStr);
                    variableMap.put('name',caspart.Contact__r.Name);
                    variableMap.put('amount',String.valueOf(caspart.Case__r.Remaining_protected_amount__c));
                    variableMap.put('respondDate',respondDateStr);
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'RequestingAGLLEvidenceAGLL', 
                                                                                   'Please submit your evidence - '
                                                                                   +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c
                                                                                  ));
                    
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                }
                else {
                    
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name, 
                                                                                  caspart.Case__c, caspart.Contact__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('date',todayStr);
                    variableMap.put('name',caspart.Contact__r.Name);
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'RequestingTTEvidenceAGLL', 
                                                                                   'The tenant(s) has been asked to provide evidence - '
                                                                                   +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                                                  ));
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                    
                }
            }
            if(caspart.Type__c == 'Tenant' && caspart.Contact__r.Email != null) {
                
                // Sending mails to tenants
                if(stage == 'LandlordEvdStage') {
                    
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name, 
                                                                                  caspart.Case__c, caspart.Contact__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('date',todayStr);
                    variableMap.put('name',caspart.Contact__r.Name);
                    variableMap.put('amount',String.valueOf(caspart.Case__r.Remaining_protected_amount__c));
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'RequestingAGLLEvidenceTT', 
                                                                                   'The agent/landlord has been asked to provide evidence - '
                                                                                   +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                                                  ));
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                    
                }
                else {
                    
                    Date respondDate = caspart.Case__r.Respond_Date__c;
                    String respondDateStr = respondDate.day()+'/'+respondDate.month()+'/'+respondDate.year();
                    
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name, 
                                                                                  caspart.Case__c, caspart.Contact__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('date',todayStr);
                    variableMap.put('name',caspart.Contact__r.Name);
                    variableMap.put('respondDate',respondDateStr);
                    
                    if(!caspart.Is_Lead__c) {
                        emailWrapperList.add(
                            new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                      'RequestingTTEvidenceTT', 
                                                                      'Lead tenant has been invited to submit evidence - '
                                                                      +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                                     ));
                    } else {
                        emailWrapperList.add(
                            new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                      'RequestingTTEvidenceTT', 
                                                                      'Please submit your evidence - '
                                                                      +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                                     ));
                    }
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                    
                }
            }
        }
    }
    
    @future(callout = true)
    public static void inviteAATTfornegotiate(Set<Id> caseIds){
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Mailjet Utility Class END */
        
        Map<Id, Dispute_Item__c> dipItems = new Map<Id, Dispute_Item__c>();
        
        String SDSEmail = 'ashish.singh1@espire.com';
        for(Case_Participant__c caspart : 
            [Select id,name,Case__c,Contact__r.Email,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Case__r.Tenancy_Property_Address__c,
             Case_Participant__c.Type__c,Case__r.Deposit_Account_Number__c,Case__r.Deposit_Account_Number__r.Name,Case__r.Disputed_Amount__c,
             Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Contact__c
             from Case_Participant__c where Case__c IN : caseIds]) 
        {
            String JsonBody;
            if((caspart.Type__c == 'Landlord' || caspart.Type__c == 'Agent') /* && caspart.Contact__r.Email != null*/) {
                // Send mail to landlord                
                /* JsonBody = getJSONBODYofinvite(caspart,SDSEmail); // getJSONBODYofLLBYTT get template for notify LL
                evidenceGatheringSendEmailsTo(JsonBody); */
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name, 
                                                                              caspart.Case__c, caspart.Contact__c));
                Map<String, String> variableMap = new Map<String, String>();
                
                variableMap.put('date',todayStr);
                variableMap.put('name',caspart.Contact__r.Name);
				//variableMap.put('breakdownOfClaimsAndDisputedAmounts',caspart.Contact__r.Name);               
                emailWrapperList.add(
                    new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                              'CaseEntersSelfRes', 
                                                              'Let us help you reach an agreement - '
                                                              +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                             ));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            }
            if(caspart.Type__c == 'Tenant' /* && caspart.Contact__r.Email != null*/) {
                // Send mail to tenant
                /* JsonBody = getJSONBODYofinvite(caspart,SDSEmail); // getJSONBODYofTTByLLget template for notify TT
                evidenceGatheringSendEmailsTo(JsonBody); */
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name, 
                                                                              caspart.Case__c, caspart.Contact__c));
                Map<String, String> variableMap = new Map<String, String>();
                
                variableMap.put('date',todayStr);
                variableMap.put('name',caspart.Contact__r.Name);
                //variableMap.put('breakdownOfClaimsAndDisputedAmounts',caspart.Contact__r.Name);
                
                emailWrapperList.add(
                    new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                              'CaseEntersSelfRes', 
                                                              'Let us help you reach an agreement - '
                                                              +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                             ));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            }
        }
        
        /* Sending Email through MailJet Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList)); 	  
        }
        /* Sending Email through MailJet Utility Class END */
        
    }
    
    // NPP-41, AC5.3 Case enters Evidence gathering AA/LL (Payments and sending emails)
    public static void createPaymentAndInstalmentsRecord(List<Case> caseList,Map<Id,Case> oldMap,Map<Id,Case> newMap) {
        String SDSEmail = 'ashish.singh1@espire.com';
        Set<String> setOfCaseIds = new Set<String>();
        Set<Id> setOfCaseForAggAmount = new Set<Id>(); // Evidence gathering AA/LL
        Set<Id> setOfCaseForRwAdj = new Set<Id>();  // Deposit to be repaid - resolved without adjudication
        List<Deposit__c> updatedepositdata = new List<Deposit__c>();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Mailjet Utility Class END */
        
        for(Case eachCase : caseList) {
            if(oldMap.get(eachCase.Id).Status != eachCase.Status && (oldMap.get(eachCase.Id).Status == 'Repayment disputed - self-resolution' || 
                oldMap.get(eachCase.Id).Status =='Self-resolution - awaiting review')) 
            {
                if(eachCase.Status == 'Evidence gathering AA/LL' && eachCase.RecordtypeId==devRecordTypeId) {
                    eachCase.Respond_Date__c=EI_UtilityClassForPayments.dueDateMethod(system.today(),10);
                    setOfCaseForAggAmount.add(eachCase.Id);
                    setOfCaseIds.add(eachCase.Id);
                }
              	/* if(eachCase.Status == 'Deposit to be repaid - resolved without adjudication' ) {
                    setOfCaseForRwAdj.add(eachCase.Id);
                    setOfCaseIds.add(eachCase.Id);
                } */
            } 
        }
        
        if(!setOfCaseIds.isEmpty()) {
            
            Map<Id,Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id,Case_Participant__c>
                ([SELECT Id, Type__c, Case__c, Case__r.Status, Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c, 
                  Case__r.Deposit_Account_Number__c, Case__r.Deposit_Account_Number__r.Name, Account__c, Contact__c, 
                  Contact__r.Email, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Case__r.Tenancy_Property_Address__c, 
                  Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, Case__r.Remaining_protected_amount__c, 
                  Case__r.Respond_Date__c
                  FROM Case_Participant__c WHERE Case__c IN : setOfCaseIds]);
            Map<Id,List<Case_Participant__c>> mapOfCaseVsCasPar = new Map<Id,List<Case_Participant__c>>();
            Set<String> ContactIds = new Set<String>();
            //List<cpm__Payment__c> createPaymentList = new List<cpm__Payment__c>();
            //Map<Id,cpm__Installment__c> mapOfContactIdVsInst = new Map<Id,cpm__Installment__c>();
            //List<Inbound_Report__c> createPaymentList = new List<Inbound_Report__c>();
            Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
            
            for(Case_Participant__c casePar : mapOfCasIdVsCasPart.values()) {
                ContactIds.add(casePar.Contact__c);
            }
            
            Map<String,Bank_Account__c> mapOFContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
            
            for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()) {
                if(!mapOfCaseVsCasPar.containsKey(casPar.Case__c))
                    mapOfCaseVsCasPar.put(casPar.Case__c,new List<Case_Participant__c>());
                mapOfCaseVsCasPar.get(casPar.Case__c).add(casPar);
            }
            
            for(Id caseId : mapOfCaseVsCasPar.keyset()) {
                Decimal countTT = 0, countLL = 0;
                Decimal totalAgreedBYTT=0;
                Decimal totalAgreedBYLL = 0;
                Decimal AmountPaidTOLL = 0;
                Decimal AmountPaidTOTT = 0;
                Decimal AmountPaidTOLL1 = 0;
                Decimal AmountPaidTOTT1 = 0;
                Decimal DisputeAmount = 0;
                for(Case_Participant__c casPar : mapOfCaseVsCasPar.get(caseId)) {
                    if(casPar.Type__c == 'Tenant') {
                        countTT++;
                    } else {
                        countLL++;
                    }
                }
                
                Case currentCase = newMap.get(caseId);
                Deposit__c depobj = new Deposit__c();
                depobj.Id = currentCase.Deposit_Account_Number__c;
                totalAgreedBYLL += currentCase.Total_Agreed_by_AG_LL__c >0 ? currentCase.Total_Agreed_by_AG_LL__c : currentCase.Total_Claimed_by_Landlord__c;
                totalAgreedBYTT += currentCase.Total_Agreed_by_Tenant__c >0 ? currentCase.Total_Agreed_by_Tenant__c : currentCase.Claimed_by_Tenant__c;
                AmountPaidTOLL = totalAgreedBYTT/countLL;
                AmountPaidTOTT =  (currentCase.Deposit_Protected_Amount__c - totalAgreedBYLL)/countTT;
                
                AmountPaidTOLL1 += currentCase.Amount_Paid_to_Landlord__c != null ? currentCase.Amount_Paid_to_Landlord__c : 0;
                AmountPaidTOTT1 += currentCase.Amount_Paid_to_Tenant__c != null ? currentCase.Amount_Paid_to_Tenant__c : 0;
                
                DisputeAmount = totalAgreedBYLL - totalAgreedBYTT;
                depobj.Agreed_amount__c = currentCase.Agreed_amount__c + totalAgreedBYTT + (currentCase.Deposit_Protected_Amount__c-totalAgreedBYLL);
                updatedepositdata.add(depobj);
                for(Case_Participant__c casPar : mapOfCaseVsCasPar.get(caseId)) {
                    String jsonBody;
                    // NPP-41, AC5.3 Case enters Evidence gathering AA/LL
                    if(setOfCaseForAggAmount.contains(casPar.Case__c)) {
                        Installment__c inst ;
                        
                        if(casPar.Type__c == 'Tenant') {
                            //getInstallments(casPar,AmountPaidTOTT,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                            if(AmountPaidTOTT>0) {
                                EI_UtilityClassForPayments.getNewInstallments(casPar, AmountPaidTOTT, false, 'Undisputed', 
                                                                              mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                              'Deposit repayment request', null);
                            }
                            // jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                             
                            /* Newly added code for adding recipients, variables, template name, Subject START */
                            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(casPar.Contact__r.Email, casPar.Contact__r.Name, 
                                                                                          casPar.Case__c, casPar.Contact__c));
                            Map<String, String> variableMap = new Map<String, String>();
                            
                            Date respondDate = casPar.Case__r.Respond_Date__c;
                            String respondDateStr = respondDate.day()+'/'+respondDate.month()+'/'+respondDate.year();
                            
                            variableMap.put('date',todayStr);
                            variableMap.put('name',casPar.Contact__r.Name);
                            variableMap.put('amount',String.valueOf(casPar.Case__r.Remaining_protected_amount__c));
                            variableMap.put('respondDate',respondDateStr);
                            
                            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                           'RequestingAGLLEvidenceAGLL', 
                                                                                           'Please submit your evidence - '
                                                                                           +casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c
                                                                                          ));
                            
                            /* Newly added code for adding recipients, variables, template name, Subject END */
                        }
                        else {
                            //getInstallments(casPar,AmountPaidTOLL,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                            if(AmountPaidTOLL>0) {
                                EI_UtilityClassForPayments.getNewInstallments(casPar, AmountPaidTOLL, false, 'Undisputed', 
                                                                              mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                              'Deposit repayment request', null);
                            }
                            // jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                            /* Newly added code for adding recipients, variables, template name, Subject START */
                            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(casPar.Contact__r.Email, casPar.Contact__r.Name, 
                                                                                          casPar.Case__c, casPar.Contact__c));
                            Map<String, String> variableMap = new Map<String, String>();
                            
                            variableMap.put('date',todayStr);
                            variableMap.put('name',casPar.Contact__r.Name);
                            variableMap.put('amount',String.valueOf(casPar.Case__r.Remaining_protected_amount__c));
                            
                            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                           'RequestingAGLLEvidenceTT', 
                                                                                           'The agent/landlord has been asked to provide evidence - '
                                                                                           +casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                                                          ));
                            /* Newly added code for adding recipients, variables, template name, Subject END */
                        }
                    }
                    
                    if(setOfCaseForRwAdj.contains(casPar.Case__c)) {
                        if(casPar.Type__c == 'Tenant') {
                            //getInstallments(casPar,AmountPaidTOTT1,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                            if(AmountPaidTOTT1>0) {
                            	EI_UtilityClassForPayments.getNewInstallments(casPar, AmountPaidTOTT1, false, 'Final Payment', 
                                                                              mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                              'Deposit repayment request', null);
                            }
                            //jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                        }
                        else {
                            //getInstallments(casPar,AmountPaidTOLL1,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                            if(AmountPaidTOLL1>0)
                            {
                                EI_UtilityClassForPayments.getNewInstallments(casPar, AmountPaidTOLL1, false, 'Final Payment', 
                                                                              mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                              'Deposit repayment request', null);
                            }
                            //jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                        }
                    }
                    
                    /*if(String.isNotBlank(jsonBody)) {
                        EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo1(jsonBody);
                    }*/
                    
                    /*if(DisputeAmount > 0) {
						getInstallments(casPar,AmountPaidTOLL1,true,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
					}*/                    
                }
            }
            
            if(!updatedepositdata.isEmpty()) {
                update updatedepositdata;
            }
            if(!mapOfContactIdVsInst.isEmpty()) {
                insert mapOfContactIdVsInst.values();
            }
            
        }
        /* Sending Email through MailJet Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
        }
        /* Sending Email through MailJet Utility Class END */
        
    }
	
}