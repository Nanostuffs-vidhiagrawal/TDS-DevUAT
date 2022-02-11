public without sharing class EI_PaymentsAndEmails implements Queueable,Database.AllowsCallouts {
    
    public Map<String,Set<Id>> mapOfcaseIds;
    public Set<Id> caseIds;
    public Set<Id> depIds;
    public EI_PaymentsAndEmails(Map<String,Set<Id>> mapOfcaseIds) {
        
        this.mapOfcaseIds = mapOfcaseIds;
        this.caseIds = new Set<Id>();
    }
    
    public void execute(QueueableContext QU) {
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Utility mailjet END */
        
        /*for(string MailTy : mapOfcaseIds.keyset()) {
        if(MailTy=='CourtCase') 
            {
            for(Id caseId : mapOfcaseIds.get(MailTy)) {
                	if(!caseIds.contains(caseId)) {
                    	caseIds.add(caseId);    
                    }
                } 
            }
        } */
        
        for(Id caseId : mapOfcaseIds.get('CourtCase')) {
            if(!caseIds.contains(caseId)) {
                caseIds.add(caseId);    
            }
        }
        
        String SDSEmail = 'ashish.singh1@espire.com';
        list<Deposit__c> updatedepositdata = new list<Deposit__c>();
        Set<Id> setOfCaseForRwAdj = new Set<Id>();
        
        for(Case_Participant__c caspart : 
            [Select Id, Name, Type__c, Is_Lead__c, Case__c, Case__r.Status, Contact__r.Email, Contact__r.Name, Contact__r.FirstName, 
             Contact__r.LastName, Case__r.Tenancy_Property_Address__c, Case__r.Deposit_Account_Number__c, Case__r.Disputed_Amount__c, 
             Case__r.Deposit_Account_Number__r.Name, Case__r.Deposit_Account_Number__r.Property_Address_Without_Country__c, 
             Case__r.Remaining_protected_amount__c
             from Case_Participant__c where Case__c IN : caseIds]) 
        {
            String jsonBody;
            
            if( mapOfcaseIds.get('CourtCase').contains(caspart.Case__c)) {
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name, caspart.Case__c, ''));
                system.debug('emailRecipientList 38 -> ' + emailRecipientList);
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', todayStr);
                variableMap.put('name', caspart.Contact__r.Name);
                variableMap.put('DAN', caspart.Case__r.Deposit_Account_Number__c);
                variableMap.put('propertyAddress', caspart.Case__r.Deposit_Account_Number__r.Property_Address_Without_Country__c);
                variableMap.put('disputeAmount', String.valueOf(caspart.Case__r.Remaining_protected_amount__c));
                
                /* Newly added code for adding recipients, variables, template name, Subject END */
                if((caspart.Type__c == 'Landlord'  || caspart.Type__c == 'Agent' )) {
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'EvidenceRevCompleteEmails',
                                                                                   'Termination of dispute resolution process - '
                                                                                   +caspart.Case__r.Deposit_Account_Number__r.Property_Address_Without_Country__c));
                    //jsonBody = getJSONBODYForTTAndLLCourtCase(caspart,SDSEmail,'Agent');
                    
                } 
                if(caspart.Type__c == 'Tenant' ) {
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'EvidenceRevCompleteEmails',
                                                                                   'Termination of dispute resolution process - '
                                                                                   +caspart.Case__r.Deposit_Account_Number__r.Property_Address_Without_Country__c));
                    //jsonBody = getJSONBODYForTTAndLLCourtCase(caspart,SDSEmail,'Tenant');
                }
                
                /*if(String.isNotBlank(JsonBody))
                    EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo(JsonBody);*/
            } 
            else if( mapOfcaseIds.get('EvidRevComp').contains(caspart.Case__c) || mapOfcaseIds.get('Adjudication').contains(caspart.Case__c) ) {
                if((caspart.Type__c == 'Landlord'  || caspart.Type__c == 'Agent' )) {
                    jsonBody = emailOnEvery5thDayForEvidRevCmpAndAdj(caspart,SDSEmail,'Agent');
                } 
                if(caspart.Type__c == 'Tenant' ) {
                    jsonBody = emailOnEvery5thDayForEvidRevCmpAndAdj(caspart,SDSEmail,'Tenant');
                }
                if(String.isNotBlank(JsonBody))
                    EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo(JsonBody);
            }
            
            /*if(caspart.Type__c == 'Tenant' ) {
            	if( mapOfcaseIds.get('CourtCase').contains(caspart.Case__c)) {
            		jsonBody = getJSONBODYForTTAndLLCourtCase(caspart,SDSEmail,'Tenant');
            	}
            }*/
        }
        
        if(!caseIds.isEmpty()) {
            
            Map<Id, Case> mapOfCaseWithCasePar = new Map<Id, Case>
                ([SELECT Id, Disputed_Amount__c, Status, Amount_to_tenants__c, Amount_to_agent_landlord__c, Deposit_Account_Number__r.Name, 
                  Tenancy_Property_Address__c, Deposit_Account_Number__c, Total_Agreed_by_AG_LL__c, Total_Agreed_by_Tenant__c, Agreed_amount__c, 
                  Deposit_Protected_Amount__c, Remaining_protected_amount__c, 
                  (SELECT Id, Account__c, Contact__c, Case__c, Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, 
                   Payable_Amount__c, Split_percent__c, Case__r.Deposit_Account_Number__c, Case__r.Deposit_Account_Number__r.Name, 
                   Case__r.Tenancy_Property_Address__c, Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c 
                   FROM Case_Participants__r) FROM Case where Id In :caseIds
                 ]);
            
            //Map of CASE is not empty START
            if(!mapOfCaseWithCasePar.isEmpty()) {
                
                for(Case singCas : mapOfCaseWithCasePar.values()) {
                    Decimal agreedAmt=0;
                    System.debug('Line 83 -> '+singCas);
                    Map<Id, Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id, Case_Participant__c>();
                    for (Case_Participant__c cp : singCas.Case_Participants__r) // check if working or not
                    {
                        mapOfCasIdVsCasPart.put(cp.Id, cp); //mapIdOpp.get(i).xxx_r[0].Name;
                        agreedAmt=agreedAmt+cp.Payable_Amount__c;
                    }
                    
                    //Map of CASE PARTICIPANTS is not empty START
                    if(!mapOfCasIdVsCasPart.isEmpty()) {
                        
                        Map<Id,List<Case_Participant__c>> mapOfCaseVsCasPar = new Map<Id,List<Case_Participant__c>>();
                        Set<String> ContactIds = new Set<String>();
                        //List<Inbound_Report__c> createPaymentList = new List<Inbound_Report__c>();
                        Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
                        
                        for(Case_Participant__c casePar : mapOfCasIdVsCasPart.values()){
                            ContactIds.add(casePar.Contact__c);
                            if(!mapOfCaseVsCasPar.containsKey(casePar.Case__c))
                                mapOfCaseVsCasPar.put(casePar.Case__c,new List<Case_Participant__c>());
                            mapOfCaseVsCasPar.get(casePar.Case__c).add(casePar);
                        }
                        
                        MAp<String,Bank_Account__c> mapOFContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
                        
                        //for(Id caseId : mapOfCaseVsCasPar.keyset()){
                        
                        //for(Case_Participant__c casPar : mapOfCaseVsCasPar.get(caseId)) {
                        for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()) {
                            String jsonBody;
                            
                            if(casPar.Type__c == 'Tenant') {
                                System.debug('Line 115 -> '+casPar.Payable_Amount__c);
                                if(casPar.Payable_Amount__c>0) {
                                    //getInstallments(casPar,casPar.Payable_Amount__c,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                    EI_UtilityClassForPayments.getNewInstallments(casPar,casPar.Payable_Amount__c, false, 'Final Payment', 
                                                                                  mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                                  'Deposit repayment request', null);
                                   
                                    jsonBody = getJSONBODYForTTAndLLCourtCase(casPar,SDSEmail,'Tenant');
                                }
                            }
                            else {
                                if(casPar.Payable_Amount__c>0) 
                                {System.debug('Line 123 -> '+casPar.Payable_Amount__c);
                                // getInstallments(casPar,casPar.Payable_Amount__c,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                  
                                 EI_UtilityClassForPayments.getNewInstallments(casPar,casPar.Payable_Amount__c, false, 'Final Payment', 
                                                                               mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                               'Deposit repayment request', null);
                                 jsonBody = getJSONBODYForTTAndLLCourtCase(casPar,SDSEmail,'Agent');
                                }
                            }
                            
                            if(String.isNotBlank(jsonBody)) {
                                EI_SdsColleagueChangesCaseStatus.evidenceGatheringSendEmailsTo1(jsonBody);
                            }
                            
                        }
                        //}
                        
                        if(!mapOfContactIdVsInst.isEmpty()){
                            insert mapOfContactIdVsInst.values();
                        }
                        
                        
                    }
                    //Map of CASE PARTICIPANTS is not empty START
                    Deposit__c dep = new Deposit__c(Id=singCas.Deposit_Account_Number__c,Agreed_amount__c=agreedAmt,Status__c='Repayment process');
                    updatedepositdata.add(dep);
                }
            }
            //Map of CASE is not empty END
            
            if(!updatedepositdata.isEmpty()){
                update updatedepositdata;
            }
        }
        
    }
    
    //NPP-29 AC 13
    public static String getJSONBODYForTTAndLLCourtCase(Case_Participant__c castInst, String SDSEmail, String status) {
        
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
        if(String.isNotBlank(castInst.Contact__r.Email))
            gen.writeStringField('Email', castInst.Contact__r.Email);
        
        if(String.isNotBlank(castInst.Contact__r.FirstName))
            gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        
        gen.writeEndObject();      
        gen.writeEndArray();
        
        /*String templateIdForLL = API_Service__mdt.getInstance('Reminder_For_Evidence_LL').Template_Id__c;
        String templateIdForTT = API_Service__mdt.getInstance('Reminder_For_Evidence_TT').Template_Id__c;
        if(status == 'Tenant')
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForTT));
        else
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForLL)); */
        
        gen.writeNumberField('TemplateID', 3012901);
        
        gen.writeBooleanField('TemplateLanguage', true);
        /*String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)) {
            firstLine = firstLine.split('\n')[0];
        }
		if(status == 'Tenant')
            gen.writeStringField('Subject', 'No agreement yet reached - next steps -'+firstLine);
        else
          gen.writeStringField('Subject', 'No agreement yet reached - next steps -: '+firstLine);  */
        
        gen.writeStringField('Subject', 'Termination of dispute resolution process - '+castInst.Case__r.Deposit_Account_Number__r.Name);
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        if(String.isNotBlank(castInst.Contact__r.Name))
            gen.writeStringField('username', castInst.Contact__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Deposit_Account_Number__r.Name))
            gen.writeStringField('dan', castInst.Case__r.Deposit_Account_Number__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Tenancy_Property_Address__c))
            gen.writeStringField('address', castInst.Case__r.Tenancy_Property_Address__c);
        
        
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    // NPP - 6
    public static String emailOnEvery5thDayForEvidRevCmpAndAdj(Case_Participant__c castInst, String SDSEmail, String status) {
        
        String emailSubject;
        if(castInst.Case__r.Status == 'Evidence review complete')
        {
            emailSubject = 'Evidence review complete  - '+castInst.Case__r.Deposit_Account_Number__r.Name;
            
        } else if(castInst.Case__r.Status == 'Adjudication') {
            emailSubject = 'Adjudication  - '+castInst.Case__r.Deposit_Account_Number__r.Name;
        }
        
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
        if(String.isNotBlank(castInst.Contact__r.Email))
            gen.writeStringField('Email', castInst.Contact__r.Email);
        
        if(String.isNotBlank(castInst.Contact__r.FirstName))
            gen.writeStringField('Name', castInst.Contact__r.FirstName + ' ' + castInst.Contact__r.LastName);
        
        gen.writeEndObject();      
        gen.writeEndArray();
        
        /*String templateIdForLL = API_Service__mdt.getInstance('Reminder_For_Evidence_LL').Template_Id__c;
        String templateIdForTT = API_Service__mdt.getInstance('Reminder_For_Evidence_TT').Template_Id__c;
        if(status == 'Tenant')
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForTT));
        else
            gen.writeNumberField('TemplateID', Integer.valueOf(templateIdForLL)); */
        
        gen.writeNumberField('TemplateID', 3029784);
        
        gen.writeBooleanField('TemplateLanguage', true);
        /*String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)) {
            firstLine = firstLine.split('\n')[0];
        }
		if(status == 'Tenant')
            gen.writeStringField('Subject', 'No agreement yet reached - next steps -'+firstLine);
        else
          gen.writeStringField('Subject', 'No agreement yet reached - next steps -: '+firstLine);  */
        
        gen.writeStringField('Subject', emailSubject);
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        
        /*if(String.isNotBlank(castInst.Contact__r.Name))
            gen.writeStringField('username', castInst.Contact__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Deposit_Account_Number__r.Name))
            gen.writeStringField('dan', castInst.Case__r.Deposit_Account_Number__r.Name);
        
        if(String.isNotBlank(castInst.Case__r.Tenancy_Property_Address__c))
            gen.writeStringField('address', castInst.Case__r.Tenancy_Property_Address__c);*/
        
        
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
}