public without sharing class EI_SdsColleagueChangesCaseStatus {
    
    public static List<Holiday> holidayList;
    
    public static void handleCaseAssignmentRuleforselfresolution(Map<Id,Case> newMap, Map<Id,Case> oldMap) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        List<Case> casesToFireAR = new List<Case>();
        for(Id caseId : newMap.keySet()) {
            if(oldMap.get(caseId).status != newMap.get(caseId).status && newMap.get(caseId).status =='Self-resolution - awaiting review' 
               && newMap.get(caseId).RecordTypeId == devRecordTypeId )
            {
                casesToFireAR.add(newMap.get(caseId));
            }   
        }
        List<Case> cases = new List<Case>();
        for(Case c : [Select Id from Case where Id in :casesToFireAR])  {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            c.setOptions(dmo);
            cases.add(c);
        }
        Database.update(cases); 
    }  
    
    /* NPP-265 -> set kpi of 5 working days for finance team after adjudication decision issued */
    public static void paymentkpiforfinance(List<Case> caseList, Map<Id,Case> oldMap) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        
        for(Case eachCase : caseList) {
            
            if(oldMap.get(eachCase.Id).Status != eachCase.Status) {
                if((eachCase.Status == 'Deposit to be repaid – decision issued' ||eachCase.Status =='Deposit to be Repaid - Repayment Agreed'
                    || eachCase.Status =='Deposit to be repaid - resolved without adjudication' || eachCase.Status =='Deposit to be repaid - court case')
                   && eachCase.RecordTypeId == devRecordTypeId)
                {
                    //casesToUpdate.add(eachCase.Id);
                    //setOfCaseIds.add(eachCase.Id);
                    eachCase.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 5);
                }
            } 
        }
    }
    
    /* NPP-540 -> Case enters evidence gathering stages again START */
    public static void caseMovesBackToEvidenceStages(List<Case> caseList, Map<Id,Case> newMap, Map<Id,Case> oldMap) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        Set<Id> casesInEvidGathAALL = new Set<Id>();
        Set<Id> casesInEvidGathTenant = new Set<Id>();
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Utility mailjet END */
        
        for(Case eachCase : caseList) {
            if(oldMap.get(eachCase.Id).Status != eachCase.Status && eachCase.RecordTypeId == devRecordTypeId && 
               oldMap.get(eachCase.Id).Status == 'Awaiting evidence review') 
            {
                if(eachCase.Status == 'Evidence gathering AA/LL' && eachCase.AGLL_Respond_Evidance_Gathering__c==false) {
                    eachCase.Respond_Date__c = EI_UtilityClassForPayments.dueDateMethod(System.today(), 10);
                    eachCase.No_Landlord_Evidence__c = false;
                    casesInEvidGathAALL.add(eachCase.Id);
                    
                } /* else if(eachCase.Status == 'Evidence gathering TT' && eachCase.TT_respond_evidence_gathering__c==false) {
                    //eachCase.Respond_Date__c = EI_UtilityClassForPayments.dueDateMethod(System.today(), 5);
                    casesInEvidGathTenant.add(eachCase.Id);
                } */
            } 
        }
        
        /* Case moves to 'Evidence gathering AA/LL' from 'Awaiting evidence review' status START */
        if(!casesInEvidGathAALL.isEmpty()) {
            for(Case_Participant__c caspart : 
                [SELECT Id, Name, Case__c, Contact__r.Email, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__c, 
                 Case__r.Tenancy_Property_Address__c, Case_Participant__c.Type__c, Is_Lead__c, Case__r.Deposit_Account_Number__c, 
                 Case__r.Deposit_Account_Number__r.Name, Case__r.Disputed_Amount__c, Case__r.Remaining_protected_amount__c, 
                 Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, Case__r.Respond_Date__c 
                 FROM Case_Participant__c WHERE Case__c IN : casesInEvidGathAALL]) 
            {
                
                if((caspart.Type__c == 'Landlord' || caspart.Type__c == 'Agent') && caspart.Contact__r.Email != null) {
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name,
                                                                                  caspart.Case__c, caspart.Contact__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    Date respondDate = caspart.Case__r.Respond_Date__c;
                    String respondDateStr = respondDate.day()+'/'+respondDate.month()+'/'+respondDate.year();
                    
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
                else if(caspart.Type__c == 'Tenant' && caspart.Contact__r.Email != null) {                    
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
                
            }
        }
        /* Case moves to 'Evidence gathering AA/LL' from 'Awaiting evidence review' status END */
        
        /* Case moves to 'Evidence gathering TT' from 'Awaiting evidence review' status START */
        if(!casesInEvidGathTenant.isEmpty()) {
            for(Case_Participant__c caspart : 
                [SELECT Id, Name, Case__c, Contact__r.Email, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Contact__c, 
                 Case__r.Tenancy_Property_Address__c, Case_Participant__c.Type__c, Is_Lead__c, Case__r.Deposit_Account_Number__c, 
                 Case__r.Deposit_Account_Number__r.Name, Case__r.Disputed_Amount__c, Case__r.Respond_Date__c, 
                 Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                 FROM Case_Participant__c WHERE Case__c IN : casesInEvidGathTenant]) 
            {
                
                String JsonBody;
                if((caspart.Type__c == 'Landlord' || caspart.Type__c == 'Agent') && caspart.Contact__r.Email != null) {
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name,
                                                                                  caspart.Case__c, caspart.Contact__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('date',todayStr);
                    variableMap.put('name',caspart.Contact__r.Name);
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'RequestingTTEvidenceAGLL', 
                                                                                   'Thank you for submitting your evidence - '
                                                                                   +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c 
                                                                                  ));
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                }
                else if(caspart.Type__c == 'Tenant' && caspart.Contact__r.Email != null) {
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name,
                                                                                  caspart.Case__c, caspart.Contact__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    Date respondDate = caspart.Case__r.Respond_Date__c;
                    String respondDateStr = respondDate.day()+'/'+respondDate.month()+'/'+respondDate.year();
                    
                    variableMap.put('date',todayStr);
                    variableMap.put('name',caspart.Contact__r.Name);
                    variableMap.put('respondDate',respondDateStr);
                    
                    if(!caspart.Is_Lead__c) {
                        emailWrapperList.add(
                            new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                      'RequestingTTEvidenceTT', 
                                                                      'The tenant(s) has been asked to provide evidence - '
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
        /* Case moves to 'Evidence gathering TT' from 'Awaiting evidence review' status END */
        
        /* Send Email from MailJet Utility Class START */
        if(!emailWrapperList.isEmpty()) {
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));  
        }
        /* Send Email from MailJet Utility Class END */
        
    }
    /* NPP-540 -> Case enters evidence gathering stages again END */    
        
    /* NPP-540 -> Case enters 'Deposit to be repaid - no evidence' status START */
    public static void caseEntersDepositToBeRepaidNoEvidence(List<Case> caseList, Map<Id,Case> newMap, Map<Id,Case> oldMap) {
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        Set<Id> casesInEvidGathAALL = new Set<Id>();
        Set<Id> casesInEvidGathTenant = new Set<Id>();
        List<Deposit__c> updatedepositdata = new List<Deposit__c>();
        Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Utility mailjet END */
        
        for(Case eachCase : caseList) {
            if(oldMap.get(eachCase.Id).Status != eachCase.Status && eachCase.RecordTypeId == devRecordTypeId && 
               eachCase.Status == 'Deposit to be repaid - no evidence') 
            {
                if(oldMap.get(eachCase.Id).Status == 'Awaiting Evidence Review' && 
                   eachCase.No_Landlord_Evidence__c==true) 
                {
                    eachCase.Respond_Date__c = EI_UtilityClassForPayments.dueDateMethod(System.today(), 5);
                    casesInEvidGathAALL.add(eachCase.Id);  
                } else if(oldMap.get(eachCase.Id).Status == 'Awaiting Evidence Review' && 
                          eachCase.No_Tenant_Evidence__c==true) 
                {
                    eachCase.Respond_Date__c = EI_UtilityClassForPayments.dueDateMethod(System.today(), 5);
                    casesInEvidGathTenant.add(eachCase.Id);
                }
            } 
        }
        
        /* Case moves to 'Deposit to be repaid - no evidence' from 'Awaiting Evidence review(Evidence gathering AA/LL)' status START */
        if(!casesInEvidGathAALL.isEmpty()) {
            
            Map<Id, List<Case_Participant__c>> mapOfCaseVsCasPar = new Map<Id, List<Case_Participant__c>>();
            
            Map<Id,Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id,Case_Participant__c>
                ([SELECT Id, Type__c, Case__c, Case__r.Status, Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c, 
                  Case__r.Deposit_Account_Number__c, Case__r.Deposit_Account_Number__r.Name, Account__c, Contact__c, 
                  Contact__r.Email, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Case__r.Tenancy_Property_Address__c, 
                  Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, Split_percent__c, Case__r.Respond_Date__c, 
                  Case__r.Deposit_Account_Number__r.Remaining_Deposit_Amount__c, Case__r.Remaining_protected_amount__c
                  FROM Case_Participant__c WHERE Case__c IN : casesInEvidGathAALL]);
            
            Set<String> ContactIds = new Set<String>();
            //List<Inbound_Report__c> createPaymentList = new List<Inbound_Report__c>();
            
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
                
                Decimal remDisputedAmt = 0;
                Case currentCase = newMap.get(caseId);
                Deposit__c depobj = new Deposit__c();
                depobj.Id = currentCase.Deposit_Account_Number__c;
                remDisputedAmt=currentCase.Remaining_protected_amount__c;                
                depobj.Agreed_amount__c = 0;
                updatedepositdata.add(depobj);
                
                /* Creating installment and sending emails to the Case Participants START */
                for(Case_Participant__c casPar : mapOfCaseVsCasPar.get(caseId)) {
                    
                    if(casesInEvidGathAALL.contains(casPar.Case__c)) {
                        Installment__c inst ;
                        
                        if(casPar.Type__c == 'Tenant') {
                            Decimal amtToTenant = (remDisputedAmt*casPar.Split_percent__c)/100;
                            if(amtToTenant>0) {
                                EI_UtilityClassForPayments.getNewInstallments(casPar, amtToTenant, false, 'Final Payment', 
                                                                              mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                              'Deposit repayment request', null);
                            }
                            
                            /* Newly added code for adding recipients, variables, template name, Subject START */
                            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(casPar.Contact__r.Email, casPar.Contact__r.Name,
                                                                                          casPar.Case__c, casPar.Contact__c));
                            Map<String, String> variableMap = new Map<String, String>();
                            
                            /*variableMap.put('date',todayStr);
                            variableMap.put('name',casPar.Contact__r.Name);
                            variableMap.put('amount',String.valueOf(casPar.Case__r.Remaining_protected_amount__c));
                            variableMap.put('respondDate',casPar.Case__r.Respond_Date__c.format());*/
                            
                            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                           'NoResponseFromAALLEvidGath', 
                                                                                           'No response from the agent/landlord'));
                            
                            /* Newly added code for adding recipients, variables, template name, Subject END */
                        }
                        else {
                            /* Newly added code for adding recipients, variables, template name, Subject START */
                            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(casPar.Contact__r.Email, casPar.Contact__r.Name,
                                                                                          casPar.Case__c, casPar.Contact__c));
                            Map<String, String> variableMap = new Map<String, String>();
                            
                            /*variableMap.put('date',todayStr);
                            variableMap.put('name',casPar.Contact__r.Name);
                            variableMap.put('amount',String.valueOf(casPar.Case__r.Remaining_protected_amount__c));*/
                            
                            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                           'NoResponseFromAALLEvidGath', 
                                                                                           'No response from the agent/landlord'));
                            /* Newly added code for adding recipients, variables, template name, Subject END */
                        }
                    }              
                }
                /* Creating installment and sending emails to the Case Participants END */
                
            }
        }
        /* Case moves to 'Deposit to be repaid - no evidence' from 'Awaiting Evidence review(Evidence gathering AA/LL)' status END */
        
        /* Case moves to 'Deposit to be repaid - no evidence' from 'Awaiting Evidence review(Evidence gathering TT)' status START */
        if(!casesInEvidGathTenant.isEmpty()) {
            
            Map<Id, List<Case_Participant__c>> mapOfCaseVsCasPar = new Map<Id, List<Case_Participant__c>>();
            
            Map<Id,Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id,Case_Participant__c>
                ([SELECT Id, Type__c, Case__c, Case__r.Status, Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c, 
                  Case__r.Deposit_Account_Number__c, Case__r.Deposit_Account_Number__r.Name, Account__c, Contact__c, 
                  Contact__r.Email, Contact__r.Name, Contact__r.FirstName, Contact__r.LastName, Case__r.Tenancy_Property_Address__c, 
                  Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, Case__r.Remaining_protected_amount__c, Split_percent__c
                  FROM Case_Participant__c WHERE Case__c IN : casesInEvidGathTenant]);
            
            System.debug('Line 342 weird -> '+casesInEvidGathTenant);
            Set<String> ContactIds = new Set<String>();
            //List<Inbound_Report__c> createPaymentList = new List<Inbound_Report__c>();
            
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
                
                Decimal remDisputedAmt = 0;
                Case currentCase = newMap.get(caseId);
                Deposit__c depobj = new Deposit__c();
                depobj.Id = currentCase.Deposit_Account_Number__c;
                remDisputedAmt=currentCase.Remaining_protected_amount__c;
                depobj.Agreed_amount__c = 0;
                
                //depobj.Agreed_amount__c = currentCase.Agreed_amount__c + totalAgreedBYTT + (currentCase.Deposit_Protected_Amount__c-totalAgreedBYLL);
                updatedepositdata.add(depobj);
                
                /* Creating installment and sending emails to the Case Participants START */
                for(Case_Participant__c casPar : mapOfCaseVsCasPar.get(caseId)) {
                    if(casesInEvidGathTenant.contains(casPar.Case__c)) {
                        Installment__c inst ;
                        if(casPar.Type__c == 'Tenant') { System.debug('Line 375 weird agent -> ');
                            /* Newly added code for adding recipients, variables, template name, Subject START */
                            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(casPar.Contact__r.Email, casPar.Contact__r.Name,
                                                                                          casPar.Case__c, casPar.Contact__c));
                            Map<String, String> variableMap = new Map<String, String>();
                            
                            /*variableMap.put('date',todayStr);
                            variableMap.put('name',casPar.Contact__r.Name);
                            variableMap.put('DAN',casPar.Case__r.Deposit_Account_Number__c);
                            variableMap.put('depositAddress',casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c);
                            variableMap.put('disputedAmount',String.valueOf(casPar.Case__r.Remaining_protected_amount__c));*/
                            
                            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                           'NoResponseFromTTEvidGath', 
                                                                                           'No response from the tenant(s)'
                                                                                          ));
                            /* Newly added code for adding recipients, variables, template name, Subject END */
                        }
                        else {
                            Decimal amtToAGLL = remDisputedAmt;
                            if(amtToAGLL>0) { System.debug('Line 396 weird amount to agent -> ');
                                             EI_UtilityClassForPayments.getNewInstallments(casPar, amtToAGLL, false, 'Final Payment', 
                                                                                           mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                                           'Deposit repayment request', null);
                             }
                              
                            /* Newly added code for adding recipients, variables, template name, Subject START */
                            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(casPar.Contact__r.Email, casPar.Contact__r.Name,
                                                                                          casPar.Case__c, casPar.Contact__c));
                            Map<String, String> variableMap = new Map<String, String>();
                            
                            /*variableMap.put('date',todayStr);
                            variableMap.put('name',casPar.Contact__r.Name);
                            variableMap.put('DAN',casPar.Case__r.Deposit_Account_Number__c);
                            variableMap.put('depositAddress',casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c);
                            variableMap.put('disputedAmount',String.valueOf(casPar.Case__r.Remaining_protected_amount__c));*/
                            
                            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                           'NoResponseFromTTEvidGath', 
                                                                                           'No response from the tenant(s)' 
                                                                                          ));
                            /* Newly added code for adding recipients, variables, template name, Subject END */
                        }
                    }                  
                }
                /* Creating installment and sending emails to the Case Participants END */
                
            }
            
        }
        /* Case moves to 'Deposit to be repaid - no evidence' from 'Awaiting Evidence review(Evidence gathering TT)' status END */
        
        if(!updatedepositdata.isEmpty()) {
            update updatedepositdata;
        }
        
        if(!mapOfContactIdVsInst.isEmpty()) {
            insert mapOfContactIdVsInst.values();
        }
        
        /* Send Email from MailJet Utility Class START */
        if(!emailWrapperList.isEmpty()) {
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));  
        }
        /* Send Email from MailJet Utility Class END */
        
    }
    /* NPP-540 -> Case enters 'Deposit to be repaid - no evidence' status END -*/
    
    /* For capturing time duration of Deposit Status on INSERT START */
    public static void depositStatusHistoryOnInsert(List<Deposit__c> depoList, Map<Id,Deposit__c> newMap) {
        Id devRecordTypeId = Schema.SObjectType.Deposit__c.getRecordTypeInfosByName().get('SDS Deposit').getRecordTypeId();
        Set<Id> depoStatusChanged = new Set<Id>();
        
        for(Deposit__c depo : depoList) {
            if((depo.Status__c != '' || depo.Status__c != null) && depo.RecordTypeId == devRecordTypeId) 
            {
                depoStatusChanged.add(depo.Id);
            }
        }
        
        if(!depoStatusChanged.isEmpty()) {
            List<History_of_Deposit__c> lstDepHistory = new List<History_of_Deposit__c>();
            for(String depoId : depoStatusChanged) {
                    History_of_Deposit__c histDep = new History_of_Deposit__c(Deposit__c=depoId, Deposit_Status__c=newMap.get(depoId).Status__c, 
                                                                              Moved_In_Date__c=System.today(), Moved_In_DateTime__c=System.now());
                    lstDepHistory.add(histDep);
            }
            
            if(!lstDepHistory.isEmpty()) {
                insert lstDepHistory;
            }
            
        }
        
    }
    /* For capturing time duration of Deposit Status on INSERT END */
    
    /* For capturing time duration of Deposit Status on UPDATE START */
    public static void depositStatusHistoryOnUpdate(List<Deposit__c> depoList, Map<Id,Deposit__c> newMap, Map<Id,Deposit__c> oldMap) {
        Id devRecordTypeId = Schema.SObjectType.Deposit__c.getRecordTypeInfosByName().get('SDS Deposit').getRecordTypeId();
        Set<Id> depoStatusChanged = new Set<Id>();
        
        for(Deposit__c depo : depoList) {
            System.debug('Line 497 -> '+oldMap.get(depo.Id).Status__c);
            System.debug('Line 498 -> '+depo.Status__c);
            if((oldMap.get(depo.Id).Status__c!=depo.Status__c || (oldMap.get(depo.Id).Status__c=='' && depo.Status__c!='')) 
               /*&& depo.RecordTypeId == devRecordTypeId*/) 
            {
                depoStatusChanged.add(depo.Id);
                //depo.Agreed_amount__c=102;
                System.debug('Line 504');
            }
        }
        System.debug('Line 504 -> '+depoStatusChanged);
        if(!depoStatusChanged.isEmpty()) {
            
            List<Deposit__c> depoWithDepHist = [SELECT Id, Status__c, 
                                                (SELECT Id, Deposit_Status__c, Deposit__c, Previous_Deposit_Status__c, Moved_In_Date__c, 
                                                 Moved_Out_Date__c, Total_No_of_Days__c, Number_of_days__c FROM History_of_Deposit__r) 
                                                FROM Deposit__c WHERE Id IN : depoStatusChanged];
            
            Map<Id, Map<String,History_of_Deposit__c>> mapOfDepHistoryToDepo = new Map<Id, Map<String,History_of_Deposit__c>>();
            List<History_of_Deposit__c> lstDepHistory = new List<History_of_Deposit__c>();
            
            for(Deposit__c dep:depoWithDepHist) {
                Map<String, History_of_Deposit__c> depHistoriesMap = new Map<String, History_of_Deposit__c>();
                for(History_of_Deposit__c depHist:dep.History_of_Deposit__r) {
                    if(depHist.Deposit_Status__c==newMap.get(dep.Id).Status__c) {
                        depHistoriesMap.put('newStatus',depHist);
                        
                    } else if(depHist.Deposit_Status__c==oldMap.get(dep.Id).Status__c) {
                        depHistoriesMap.put('oldStatus',depHist);
                    }
                }
                mapOfDepHistoryToDepo.put(dep.Id,depHistoriesMap);
            }
            
            for(String depoId : mapOfDepHistoryToDepo.keySet()) {
                Map<String, History_of_Deposit__c> mapOfDepHist = mapOfDepHistoryToDepo.get(depoId);
                
                if(mapOfDepHist.get('oldStatus')!=null) {
                    History_of_Deposit__c histDep = mapOfDepHist.get('oldStatus');
                    System.debug('Line 547 -> '+histDep.Moved_In_Date__c);
                    System.debug('Line 548 -> '+histDep.Moved_Out_Date__c);
                    if(histDep.Moved_In_Date__c.daysBetween(System.today())<1) 
                    {
                        histDep.Number_of_days__c=1+mapOfDepHist.get('oldStatus').Total_No_of_Days__c;
                    } else {
                        histDep.Number_of_days__c = mapOfDepHist.get('oldStatus').Total_No_of_Days__c;
                    }
                    
                    histDep.Moved_Out_Date__c = System.today();
                    histDep.Moved_Out_DateTime__c = System.now();
                    lstDepHistory.add(histDep);
                } else {
                    History_of_Deposit__c histDep = new History_of_Deposit__c(Deposit__c=depoId, Deposit_Status__c=oldMap.get(depoId).Status__c, 
                                                                              Moved_Out_Date__c=System.today(), Moved_Out_DateTime__c=System.now());
                    lstDepHistory.add(histDep);
                }
                
                if(mapOfDepHist.get('newStatus')!=null) {
                    History_of_Deposit__c histDep = mapOfDepHist.get('newStatus');
                    histDep.Deposit_Status__c = newMap.get(depoId).Status__c;
                    histDep.Moved_In_Date__c = System.today();
                    histDep.Moved_In_DateTime__c = System.now();
                    histDep.Moved_Out_Date__c = null;
                    histDep.Moved_Out_DateTime__c = null;
                    lstDepHistory.add(histDep);
                } else {
                    History_of_Deposit__c histDep = new History_of_Deposit__c(Deposit__c=depoId, Deposit_Status__c=newMap.get(depoId).Status__c, 
                                                                              Moved_In_Date__c=System.today(), Moved_In_DateTime__c=System.now());
                    lstDepHistory.add(histDep);
                }
            }
            
            if(!lstDepHistory.isEmpty()) {
                upsert lstDepHistory;
            }
            
        }
        
    }
    /* For capturing time duration of Deposit Status on UPDATE END */
    
    public class caseHistoryWrapper {
        public  Map<String, History_of_Case__c> historyOfCases{get;set;}
        public  Boolean hasNewCaseHistory{get;set;}
        public  Boolean hasOldCaseHistory{get;set;}
        public  Id caseId{get;set;}
        
        public caseHistoryWrapper(Map<String, History_of_Case__c> historyOfCases, Boolean hasNewCaseHistory, Boolean hasOldCaseHistory, Id caseId) {
            this.historyOfCases = historyOfCases;
            this.hasOldCaseHistory = hasOldCaseHistory;
            this.hasOldCaseHistory = hasOldCaseHistory;
            this.caseId = caseId;
        }
    } 
    
    public static void resolvedWithoutAdjudication(List<Case> caseList, Map<Id,Case> oldMap, Map<Id,Case> newMap) {
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        
        system.debug('line');
        String SDSEmail = 'ashish.singh1@espire.com';
        Set<String> setOfCaseIds = new Set<String>();
        Set<Id> setOfCaseForAggAmount = new Set<Id>(); // Evidence gathering AA/LL
        Set<Id> setOfCaseForRwAdj = new Set<Id>();  // Deposit to be repaid - resolved without adjudication
        list<Deposit__c> updatedepositdata = new list<Deposit__c>();
        for(Case eachCase : caseList) {
            
            if(eachCase.Status == 'Deposit to be repaid - resolved without adjudication' && eachCase.Bypass_validation__c == false 
               && oldMap.get(eachCase.Id).Status != eachCase.Status) 
            {
                if(eachCase.Amount_to_tenants__c==null && eachCase.Amount_to_agent_landlord__c==null) {
                    System.debug('Line 198');
                    eachCase.addError('Sum of amount to tenants and agent/landlord is not equal to the remaining protected amount of deposit.');
                } 
                if(eachCase.Amount_to_tenants__c!=null && eachCase.Amount_to_agent_landlord__c!=null) {
                    if(eachCase.Amount_to_tenants__c+eachCase.Amount_to_agent_landlord__c!=eachCase.Remaining_protected_amount__c) 
                        eachCase.addError('Sum of amount to tenants and agent/landlord is not equal to the remaining protected amount of deposit.');
                }
                if((eachCase.Amount_to_tenants__c!=null && eachCase.Amount_to_agent_landlord__c==null)) 
                {
                    eachCase.Amount_to_agent_landlord__c=0;
                    System.debug('Line 202');
                    if(eachCase.Amount_to_tenants__c+eachCase.Amount_to_agent_landlord__c!=eachCase.Remaining_protected_amount__c) 
                        eachCase.addError('Sum of amount to tenants and agent/landlord is not equal to the remaining protected amount of deposit.');
                }
                if((eachCase.Amount_to_tenants__c==null && eachCase.Amount_to_agent_landlord__c!=null)) 
                {
                    eachCase.Amount_to_tenants__c=0;
                    System.debug('Line 202');
                    if(eachCase.Amount_to_tenants__c+eachCase.Amount_to_agent_landlord__c!=eachCase.Remaining_protected_amount__c) 
                        eachCase.addError('Sum of amount to tenants and agent/landlord is not equal to the remaining protected amount of deposit.');
                }
            }
            if(oldMap.get(eachCase.Id).Status != eachCase.Status) {
                if(eachCase.Status == 'Deposit to be repaid - resolved without adjudication' && eachCase.Bypass_validation__c == false 
                   && newMap.get(eachCase.Id).RecordTypeId == devRecordTypeId ) 
                {
                    setOfCaseForRwAdj.add(eachCase.Id);
                    setOfCaseIds.add(eachCase.Id);
                    eachCase.Dispute_resolution_status__c = 'Resolved without adjudication';		// Using this field for reporting purpose
                }
            }
        }
        
        if(!setOfCaseIds.isEmpty()) {
            
            Map<Id, Case> mapOfCaseWithCasePar = new Map<Id, Case>
                ([SELECT Id, Disputed_Amount__c, Status, Amount_to_tenants__c, Amount_to_agent_landlord__c, Deposit_Account_Number__r.Name, 
                  Tenancy_Property_Address__c, Deposit_Account_Number__c, Total_Agreed_by_AG_LL__c, Total_Agreed_by_Tenant__c, Agreed_amount__c, 
                  Deposit_Protected_Amount__c, Remaining_protected_amount__c, Deposit_Account_Number__r.Agreed_amount__c,
                  (SELECT Id, Account__c, Contact__c, Case__c, Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, 
                   Payable_Amount__c, Split_percent__c, Case__r.Deposit_Account_Number__c, Case__r.Tenancy_Property_Address__c, 
                   Case__r.Deposit_Account_Number__r.Name, Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c 
                   FROM Case_Participants__r) FROM Case where Id In :setOfCaseIds
                 ]);
            
            //Map of CASE is not empty START
            if(!mapOfCaseWithCasePar.isEmpty()) {
                
                for(Case singCas : mapOfCaseWithCasePar.values()) {
                    
                    Map<Id, Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id, Case_Participant__c>();
                    for (Case_Participant__c cp : singCas.Case_Participants__r) // check if working or not
                    {
                        mapOfCasIdVsCasPart.put(cp.Id, cp); //mapIdOpp.get(i).xxx_r[0].Name;   
                    }
                    
                    //Map of CASE PARTICIPANTS is not empty START
                    if(!mapOfCasIdVsCasPart.isEmpty()) {
                        
                        Map<Id,List<Case_Participant__c>> mapOfCaseVsCasPar = new Map<Id,List<Case_Participant__c>>();
                        Set<String> ContactIds = new Set<String>();
                        //List<Inbound_Report__c> createPaymentList = new List<Inbound_Report__c>();
                        Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
                        
                        for(Case_Participant__c casePar : mapOfCasIdVsCasPart.values()){
                            ContactIds.add(casePar.Contact__c);
                        }
                        
                        MAp<String,Bank_Account__c> mapOFContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
                        
                        for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()){
                            if(!mapOfCaseVsCasPar.containsKey(casPar.Case__c))
                                mapOfCaseVsCasPar.put(casPar.Case__c,new List<Case_Participant__c>());
                            mapOfCaseVsCasPar.get(casPar.Case__c).add(casPar);
                        }
                        
                        //for(Id caseId : mapOfCaseVsCasPar.keyset()){
                        Decimal countTT = 0, countLL = 0;
                        Decimal totalAgreedBYTT=0;
                        Decimal totalAgreedBYLL =0;
                        Decimal AmountPaidTOLL = 0;
                        Decimal AmountPaidTOTT = 0;
                        Decimal AmountPaidTOLL1 = 0;
                        Decimal AmountPaidTOTT1 = 0;
                        Decimal DisputeAmount = 0;
                        for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()) {
                            if(casPar.Type__c == 'Tenant'){
                                countTT++;
                            }else{
                                countLL++;
                            }
                        }
                        
                        Case currentCase = newMap.get(singCas.Id);
                        Deposit__c depobj = new deposit__c();
                        depobj.id = currentCase.Deposit_Account_Number__c;
                        system.debug('line--> 551' + currentCase);
                        if((currentCase.Amount_to_agent_landlord__c > 0 || currentCase.Amount_to_tenants__c > 0) && 
                           currentCase.Remaining_protected_amount__c > 0 ) 
                        {
                            if(currentCase.Amount_to_agent_landlord__c==null) {
                                currentCase.Amount_to_agent_landlord__c=0;  
                            }
                            if(currentCase.Amount_to_tenants__c==null) {
                                currentCase.Amount_to_tenants__c=0; 
                            }
                            AmountPaidTOLL1 = currentCase.Amount_to_agent_landlord__c;
                            AmountPaidTOTT1 = currentCase.Amount_to_tenants__c;
                            if(singCas.Deposit_Account_Number__r.Agreed_amount__c == null) {
                                depobj.Agreed_amount__c = AmountPaidTOLL1 + AmountPaidTOTT1;
                            } else {
                                depobj.Agreed_amount__c = singCas.Deposit_Account_Number__r.Agreed_amount__c + AmountPaidTOLL1 + AmountPaidTOTT1;   
                            }
                            updatedepositdata.add(depobj);
                        }
                        
                        //for(Case_Participant__c casPar : mapOfCaseVsCasPar.get(caseId)) {
                        for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()) {
                            String jsonBody;
                            if(setOfCaseForRwAdj.contains(casPar.Case__c)) {
                                if(casPar.Type__c == 'Tenant') {
                                    Decimal amtToTen = (AmountPaidTOTT1*casPar.Split_percent__c)/100;
                                    if(amtToTen>0) {
                                        //getInstallments(casPar,amtToTen,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                        EI_UtilityClassForPayments.getNewInstallments(casPar, amtToTen, false, 'Final Payment', 
                                                                                      mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                                      'Tenant changeover', null);
                                        
                                        System.debug('Line 322 mapOfContactIdVsInst -> '+mapOfContactIdVsInst);
                                        jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                                    }
                                }
                                else {
                                    if(AmountPaidTOLL1>0) 
                                    {
                                        // getInstallments(casPar,AmountPaidTOLL1,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                        EI_UtilityClassForPayments.getNewInstallments(casPar,AmountPaidTOLL1, false, 'Final Payment', 
                                                                                      mapOFContactIdVsBankDet, mapOfContactIdVsInst,  
                                                                                      'Tenant changeover', null);
                                        
                                        jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                                    }
                                }
                            }
                            
                            if(String.isNotBlank(jsonBody)) {
                                evidenceGatheringSendEmailsTo1(jsonBody);
                            }
                            /*if(DisputeAmount > 0)
getInstallments(casPar,AmountPaidTOLL1,true,mapOFContactIdVsBankDet,mapOfContactIdVsInst);  
}*/ 
                        }
                        if(!updatedepositdata.isEmpty()){
                            update updatedepositdata;
                        }
                        
                        if(!mapOfContactIdVsInst.isEmpty()){
                            insert mapOfContactIdVsInst.values();
                        }
                        
                        
                        singCas.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 5);
                    }
                    //Map of CASE PARTICIPANTS is not empty START
                }
                
            }
            //Map of CASE is not empty END
            
        }
        
    }
    
    public static void createPaymentAndInstalmentsRecord(List<Case> caseList,Map<Id,Case> oldMap,Map<Id,Case> newMap) {
        system.debug('line');
        String SDSEmail = 'ashish.singh1@espire.com';
        Set<String> setOfCaseIds = new Set<String>();
        Set<Id> setOfCaseForAggAmount = new Set<Id>(); // Evidence gathering AA/LL
        Set<Id> setOfCaseForRwAdj = new Set<Id>();  // Deposit to be repaid - resolved without adjudication
        list<Deposit__c> updatedepositdata = new list<Deposit__c>();
        for(Case eachCase : caseList){
            
            if(oldMap.get(eachCase.Id).Status != eachCase.Status){
                if(eachCase.Status == 'Evidence gathering AA/LL' ){
                    setOfCaseForAggAmount.add(eachCase.Id);
                    setOfCaseIds.add(eachCase.Id);
                }
                
                /*if(eachCase.Status == 'Deposit to be repaid - resolved without adjudication' ){
setOfCaseForRwAdj.add(eachCase.Id);
setOfCaseIds.add(eachCase.Id);
}*/
                
                
            } 
        }
        
        if(!setOfCaseIds.isEmpty()){
            
            Map<Id,Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id,Case_Participant__c>([SELECT Id,Contact__r.Name, Type__c, Case__c ,Case__r.Status ,Case__r.Deposit_Account_Number__c,Case__r.Deposit_Account_Number__r.Name, Account__c, Contact__c,Contact__r.Email,Contact__r.FirstName,Contact__r.LastName,Case__r.Tenancy_Property_Address__c FROM Case_Participant__c where Case__c In : setOfCaseIds]);
            Map<Id,List<Case_Participant__c>> mapOfCaseVsCasPar = new Map<Id,List<Case_Participant__c>>();
            Set<String> ContactIds = new Set<String>();
            //List<cpm__Payment__c> createPaymentList = new List<cpm__Payment__c>();
            //Map<Id,cpm__Installment__c> mapOfContactIdVsInst = new Map<Id,cpm__Installment__c>();
            //List<Inbound_Report__c> createPaymentList = new List<Inbound_Report__c>();
            Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
            
            for(Case_Participant__c casePar : mapOfCasIdVsCasPart.values()){
                ContactIds.add(casePar.Contact__c);
            }
            
            MAp<String,Bank_Account__c> mapOFContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
            
            for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()){
                if(!mapOfCaseVsCasPar.containsKey(casPar.Case__c))
                    mapOfCaseVsCasPar.put(casPar.Case__c,new List<Case_Participant__c>());
                mapOfCaseVsCasPar.get(casPar.Case__c).add(casPar);
            }
            
            for(Id caseId : mapOfCaseVsCasPar.keyset()){
                Decimal countTT = 0, countLL = 0;
                Decimal totalAgreedBYTT=0;
                Decimal totalAgreedBYLL =0;
                Decimal AmountPaidTOLL = 0;
                Decimal AmountPaidTOTT = 0;
                Decimal AmountPaidTOLL1 = 0;
                Decimal AmountPaidTOTT1 = 0;
                Decimal DisputeAmount = 0;
                for(Case_Participant__c casPar : mapOfCaseVsCasPar.get(caseId)){
                    if(casPar.Type__c == 'Tenant'){
                        countTT++;
                    }else{
                        countLL++;
                    }
                }
                
                Case currentCase = newMap.get(caseId);
                Deposit__c depobj = new deposit__c();
                depobj.id = currentCase.Deposit_Account_Number__c;
                system.debug('line--> 551' + currentCase);
                totalAgreedBYLL += currentCase.Total_Agreed_by_AG_LL__c >0 ? currentCase.Total_Agreed_by_AG_LL__c : currentCase.Total_Claimed_by_Landlord__c;
                totalAgreedBYTT += currentCase.Total_Agreed_by_Tenant__c >0 ? currentCase.Total_Agreed_by_Tenant__c : currentCase.Claimed_by_Tenant__c;
                AmountPaidTOLL = totalAgreedBYTT/countLL;
                AmountPaidTOTT =  (currentCase.Total_Deposit__c - totalAgreedBYLL)/countTT;
                
                AmountPaidTOLL1 += currentCase.Amount_Paid_to_Landlord__c != null ? currentCase.Amount_Paid_to_Landlord__c : 0;
                AmountPaidTOTT1 += currentCase.Amount_Paid_to_Tenant__c != null ? currentCase.Amount_Paid_to_Tenant__c : 0;
                
                DisputeAmount = totalAgreedBYLL - totalAgreedBYTT;
                depobj.Agreed_amount__c = totalAgreedBYTT+(currentCase.Deposit_Protected_Amount__c-totalAgreedBYLL);
                updatedepositdata.add(depobj);
                for(Case_Participant__c casPar : mapOfCaseVsCasPar.get(caseId)) {
                    String jsonBody;
                    if(setOfCaseForAggAmount.contains(casPar.Case__c)){
                        //cpm__Installment__c inst ;
                        Installment__c inst ;
                        
                        if(casPar.Type__c == 'Tenant'){
                            //getInstallments(casPar,AmountPaidTOTT,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                            EI_UtilityClassForPayments.getNewInstallments(casPar, AmountPaidTOTT, false, 'Final Payment', 
                                                                          mapOFContactIdVsBankDet,mapOfContactIdVsInst, 
                                                                          'Tenant changeover', null);
                            jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                        }
                        else{
                            //getInstallments(casPar,AmountPaidTOLL,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                            EI_UtilityClassForPayments.getNewInstallments(casPar, AmountPaidTOLL, false, 'Final Payment', 
                                                                          mapOFContactIdVsBankDet,mapOfContactIdVsInst, 
                                                                          'Tenant changeover', null);
                            jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                        }
                    }
                    if(setOfCaseForRwAdj.contains(casPar.Case__c)){
                        if(casPar.Type__c == 'Tenant'){
                            //getInstallments(casPar,AmountPaidTOTT1,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                            EI_UtilityClassForPayments.getNewInstallments(casPar, AmountPaidTOTT1, false, 'Final Payment', 
                                                                          mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                          'Tenant changeover', null);
                            jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                        }
                        else{
                            //getInstallments(casPar,AmountPaidTOLL1,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                            EI_UtilityClassForPayments.getNewInstallments(casPar, AmountPaidTOLL1, false, 'Final Payment', 
                                                                          mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                          'Tenant changeover', null);
                            jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                        }
                    }
                    
                    if(String.isNotBlank(jsonBody)) {
                        evidenceGatheringSendEmailsTo1(jsonBody);
                    }
                    /*if(DisputeAmount > 0)
getInstallments(casPar,AmountPaidTOLL1,true,mapOFContactIdVsBankDet,mapOfContactIdVsInst);*/   
                }
            }
            update updatedepositdata;
            
            if(!mapOfContactIdVsInst.isEmpty()){
                insert mapOfContactIdVsInst.values();
            }
            //for(cpm__Installment__c inst : mapOfContactIdVsInst.values()){
            
            
        }
    }
    
    // NPP - 27, 29
    public static void depositToBeRepaidCourtCase(List<Case> lstOfCourtCases) {
        Id CaseparId = Schema.SObjectType.Case_Participant__c.getRecordTypeInfosByName().get('SDS Case Participant').getRecordTypeId();
        List<Case> toUpdtCases = new List<Case>();
        Set<Id> setOfCaseIds = new Set<Id>();
        set<Id> depositid = new set<Id>();
        list<Case_Participant__c> caseparticipantlist = new list<Case_Participant__c>();
        System.debug('Line line 469');
        for(Case eachCase : lstOfCourtCases) {
            setOfCaseIds.add(eachCase.Id);
            if(eachCase.Deposit_Account_Number__c !=null){
                depositid.add(eachCase.Deposit_Account_Number__c);
            }
        }
        
        if(!setOfCaseIds.isEmpty()) {
            //repaymentlist
            Map<Id, Repayment_Request__c> mapOfRepReq = new Map<Id, Repayment_Request__c>
                ([select id,Account__c,AL_CleaningAmt__c,AL_DmgPropAmt__c, AL_GardeningAmt__c,AL_OtherAmt__c,AL_Other_Reason__c,AL_RedecorationAmt__c,
                  AL_Rent_Arrears__c, AL_Repay_Requested__c, Case__c, Deposit__c, Status__c, Deposit__r.Customer__r.RecordType.Name,
                  Tenancy_End_Date__c,Tenancy_End_Date_Agent__c,Tenant_Cleaning__c,Tenant_Dmg_to_Property__c, Tenant_Gardening__c, Tenant_Other__c,
                  Tenant_Other_Reason__c, Tenant_Redecoration__c, Tenant_Rent_Arrears__c,Tenant_Repay_Requested__c, Account__r.personcontactId,
                  Total_Amount_By_Agent_Landlord__c, Total_Amount_Offer_from_AALL_To_Tenant__c,Total_Amount_Requested_AL__c, 
                  Total_Amount_By_Tenant__c, Account__r.RecordType.Name, Deposit__r.Customer__c,
                  (Select Id,Account__c,Repayment_Request__r.Account__r.RecordType.Name, Repayment_Request__r.Account__r.personcontactId, 
                   CalculatePercent__c, Repayment_Request__r.Total_Amount_By_Tenant__c,Account__r.RecordType.Name,Account__r.PersonContactId,
                   AL_ReqAmt__c,Is_Lead__c,Repayment_Request__c,Repayment_Requested_Mail_Sent__c,Requested_By__c, Tenant_ReqAmt__c, 
                   Repayment_Request__r.Case__c, Repayment_Request__r.Deposit__r.Customer__c from Repayment_Request_Lines__r) 
                  from Repayment_Request__c where Status__c='Deposit to be repaid - court case' and Case__c IN :setOfCaseIds 
                  /*and Deposit__c IN:depositid*/ ]); 
            /*Map<Id, deposit_allocation__c > depall = Map<Id, deposit_allocation__c >
([select id,Deposit_Holder__c,Is_Lead__c, Role__c,Deposit__c from  Deposit_allocation__c  
where Deposit__c IN :depositid  and Role__c='Tenant'  and Is_Lead__c=true limit 1 ]);*/
            
            // Case participants creation start
            for(Repayment_Request__c repReq : mapOfRepReq.values()) {
                
                list<deposit_allocation__c > depall = [select id,Deposit_Holder__c,Is_Lead__c, Role__c,Deposit__c from  Deposit_allocation__c  
                                                       where Deposit__c IN :depositid  and Role__c='Tenant'  and Is_Lead__c=true limit 1  ];
                
                for(Repayment_Request_Line__c requestline : mapOfRepReq.get(repReq.Id).Repayment_Request_Lines__r ) {
                    if(requestline.Account__c != requestline.Repayment_Request__r.Deposit__r.Customer__c) {
                        Case_Participant__c newparticipant = new  Case_Participant__c(); 
                        newparticipant.RecordTypeId =CaseparId;
                        newparticipant.Account__c =requestline.Account__c;
                        newparticipant.Contact__c=requestline.Account__r.PersonContactId;
                        newparticipant.Case__c=requestline.Repayment_Request__r.Case__c;
                        newparticipant.Payable_Amount__c=requestline.Tenant_ReqAmt__c;
                        newparticipant.Split_percent__c=requestline.CalculatePercent__c;
                        if(!depall.isempty() && requestline.Account__r.RecordType.Name=='Tenant' && 
                           requestline.Account__c == depall[0].Deposit_Holder__c ){
                               newparticipant.Type__c='Tenant';
                               newparticipant.Is_Lead__c=true;
                               newparticipant.Payable_Amount__c = requestline.AL_ReqAmt__c;
                           }
                        else{
                            newparticipant.Type__c='Tenant';
                            newparticipant.Payable_Amount__c = requestline.AL_ReqAmt__c;
                        } 
                        caseparticipantlist.add(newparticipant);
                    }
                }
                
                Case_Participant__c newcse = new  Case_Participant__c();
                newcse.RecordTypeId = CaseparId;
                if(repReq.Account__r.RecordType.Name == 'Corporate Landlord'){
                    newcse.Account__c = repReq.Account__c;    
                    newcse.Type__c='Landlord';
                    newcse.Case__c= repReq.Case__c;
                    newcse.Payable_Amount__c = repReq.Total_Amount_By_Agent_Landlord__c;
                }
                else if(repReq.Account__r.RecordType.Name == 'Individual Landlord'){
                    newcse.Account__c = repReq.Account__c;   
                    newcse.Contact__c = repReq.Account__r.personcontactId;
                    newcse.Type__c = 'Landlord'; 
                    newcse.Case__c = repReq.Case__c;
                    newcse.Payable_Amount__c = repReq.Total_Amount_By_Agent_Landlord__c;
                }
                else if(repReq.Account__r.RecordType.Name == 'Letting Agent'){
                    newcse.Account__c = repReq.Account__c;
                    newcse.Contact__c = repReq.Account__r.personcontactId;
                    newcse.Type__c = 'Agent';   
                    newcse.Case__c = repReq.Case__c;
                    newcse.Payable_Amount__c = repReq.Total_Amount_By_Agent_Landlord__c;
                }
                else if(repReq.Account__r.RecordType.Name == 'Organization'){
                    newcse.Account__c = repReq.Account__c;
                    newcse.Type__c = 'Agent'; 
                    newcse.Case__c = repReq.Case__c;
                    newcse.Payable_Amount__c = repReq.Total_Amount_By_Agent_Landlord__c;
                }
                
                caseparticipantlist.add(newcse);
            }
            // Case participants creation end
            
            /*list<Repayment_Request_Line__c> requestlinelist = 
[select Id,Account__c,Repayment_Request__r.Account__r.RecordType.Name, Repayment_Request__r.Account__r.personcontactId, 
CalculatePercent__c, Repayment_Request__r.Total_Amount_By_Tenant__c,Account__r.RecordType.Name,Account__r.PersonContactId,
AL_ReqAmt__c,Is_Lead__c,Repayment_Request__c,Repayment_Requested_Mail_Sent__c,Requested_By__c, Tenant_ReqAmt__c, 
Repayment_Request__r.Case__c from Repayment_Request_Line__c 
where Repayment_Request__r.Case__r.status='Repayment disputed - self-resolution' and Repayment_Request__c IN :repaymentid 
and Account__r.RecordType.Name='Tenant'];*/
            //system.debug('line--> 124 ' + requestlinelist);
            if(!mapOfRepReq.isempty()) {
                system.debug('line--> 169 ' + caseparticipantlist);
                if(!caseparticipantlist.isempty()) {
                    insert caseparticipantlist;
                } 
            }
            
        }
        
        for(Case eachCase : lstOfCourtCases) {
            Case c=new Case();
            c.Id = eachCase.Id;
            //System.debug(calculateWorkingDaysBetweenTwoDates(System.today(), 30));
            c.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 30);
            toUpdtCases.add(c);
        }
        
        if(!toUpdtCases.isEmpty())
        {
            update toUpdtCases;
        }
        
    }
    
    // NPP-29, AC-16
    public static void evidenceReviewComplete(List<Case> lstOfEvidGathCases) {
        
        Set<Id> caseIds = new Set<Id>();
        List<Case> toUpdtCases = new List<Case>();
        list<Deposit__c> updatedepositdata = new list<Deposit__c>();
        Set<Id> setOfCaseForRwAdj = new Set<Id>();
        String SDSEmail = 'ashish.singh1@espire.com';
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Utility mailjet END */
        
        for(Case evidRevCase : lstOfEvidGathCases) {
            caseIds.add(evidRevCase.Id);
        }
        System.debug('Line 595');
        
        for(Case_Participant__c caspart : 
            [Select Id, Name, Type__c, Is_Lead__c, Case__c, Case__r.Status, Contact__r.Email, Contact__r.Name, Contact__r.FirstName, 
             Contact__r.LastName, Case__r.Tenancy_Property_Address__c, Contact__c, Case__r.Deposit_Account_Number__c,Case__r.Disputed_Amount__c, 
             Case__r.Deposit_Account_Number__r.Name, Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, 
             Case__r.Remaining_protected_amount__c 
             from Case_Participant__c where Case__c IN : caseIds]) 
        {
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(caspart.Contact__r.Email, caspart.Contact__r.Name, 
                                                                          caspart.Case__c, caspart.Contact__c));
            system.debug('emailRecipientList 38 -> ' + emailRecipientList);
            Map<String, String> variableMap = new Map<String, String>();
            variableMap.put('date', todayStr);
            variableMap.put('name', caspart.Contact__r.Name);
            variableMap.put('DAN', caspart.Case__r.Deposit_Account_Number__r.Name);
            variableMap.put('propertyAddress', caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c);
            variableMap.put('disputeAmount', String.valueOf(caspart.Case__r.Remaining_protected_amount__c));
            /* Newly added code for adding recipients, variables, template name, Subject END */
            
            System.debug('Line 605 '+caspart.Name);
            String jsonBody;
            
            if((caspart.Type__c == 'Landlord'  || caspart.Type__c == 'Agent' )) {
                if(caspart.Case__r.Status == 'Evidence review complete') {
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'EvidenceRevCompleteEmails',
                                                                                   'Evidence gathering complete - next steps - '
                                                                                   +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c));
                    //jsonBody = getJSONBODYForEvidGathEmails(caspart,SDSEmail);
                }
            }
            if(caspart.Type__c == 'Tenant' ) {
                if(caspart.Case__r.Status == 'Evidence review complete') {
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'EvidenceRevCompleteEmails',
                                                                                   'Evidence gathering complete - next steps - '
                                                                                   +caspart.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c));
                    //jsonBody = getJSONBODYForEvidGathEmails(caspart,SDSEmail);
                }
            }
            
            if(String.isNotBlank(JsonBody))
                evidenceGatheringSendEmailsTo1(JsonBody);
        }
        
        for(Case eachCase : lstOfEvidGathCases) {
            Case c=new Case();
            c.Id = eachCase.Id;
            //System.debug(calculateWorkingDaysBetweenTwoDates(System.today(), 30));
            c.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 20);
            c.IIIrd_Working_Day_SR__c = calculateWorkingDaysBetweenTwoDates(System.today(), 5);
            toUpdtCases.add(c);
        }
        
        if(!toUpdtCases.isEmpty())
        {
            update toUpdtCases;
        }
        
        /* Send Email from Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
        }
        /* Send Email from Utility Class END */
        
    }
    
    public static void adjReviewReqAcceptance(List<Case> caseList, Map<Id,Case> oldMap) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        //Set<String> setOfCaseIds = new Set<String>();
        //Set<Id> setOfCaseForRwAdj = new Set<Id>();
        //List<Case> casesToUpdate = new List<Case>();
        
        for(Case eachCase : caseList) {
            
            if(oldMap.get(eachCase.Id).Status != eachCase.Status) {
                if(eachCase.Status == 'Review request accepted' 
                   && oldMap.get(eachCase.Id).Status == 'Review of decision requested' && eachCase.RecordTypeId == devRecordTypeId ) {
                       //casesToUpdate.add(eachCase.Id);
                       //setOfCaseIds.add(eachCase.Id);
                       eachCase.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 10);
                   }
            } 
        }
    }
    
    public static void adjDecisionIssued(List<Case> caseList, Map<Id,Case> oldMap) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        Set<String> setOfCaseIds = new Set<String>();
        Set<Id> setOfCaseForRwAdj = new Set<Id>();
        list<Deposit__c> updatedepositdata = new list<Deposit__c>();
        for(Case eachCase : caseList) {
            
            if(oldMap.get(eachCase.Id).Status != eachCase.Status) {
                if(eachCase.RecordTypeId == devRecordTypeId && eachCase.Status == 'Deposit to be repaid – decision issued' 
                   && oldMap.get(eachCase.Id).Status == 'Review request accepted – assign to adjudicator' ) {
                       setOfCaseForRwAdj.add(eachCase.Id);
                       setOfCaseIds.add(eachCase.Id);
                   }
            } 
        }
        
        Map<Id, Case> mapOfCaseWithCasePar = new Map<Id, Case>
            ([SELECT Id, Disputed_Amount__c, Status, Amount_to_tenants__c, Amount_to_agent_landlord__c, Deposit_Account_Number__r.Name, 
              Deposit_Account_Number__c, Deposit_Account_Number__r.Agreed_amount__c, Tenancy_Property_Address__c, Total_Agreed_by_AG_LL__c, 
              Total_Agreed_by_Tenant__c, Agreed_amount__c, Deposit_Protected_Amount__c, Remaining_protected_amount__c, 
              (SELECT Id, Account__c, Contact__c, Case__c, Case__r.Deposit_Account_Number__c,Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c, Contact__r.Name, Type__c, Contact__r.Email, 
               Contact__r.FirstName, Contact__r.LastName, Payable_Amount__c, Split_percent__c FROM Case_Participants__r), 
              (SELECT Id,Awarded_to_Agent__c,Awarded_to_Landlord__c, Awarded_to_Tenant__c FROM Adjudication_Reports__r 
               where Status__c='Published' order by createddate desc limit 1) FROM Case where Id In :setOfCaseIds limit 1]);
        
        //Map of CASE is not empty START
        if(!mapOfCaseWithCasePar.isEmpty()) {
            
            for(Case singCas : mapOfCaseWithCasePar.values()) {
                
                Decimal amtToAGLL=0;   
                Decimal amtToTenant=0;
                Decimal awardToAgent=0;
                Decimal awardToLandlord=0;
                if(!mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r.isEmpty()) {
                    
                    Map<Id, Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id, Case_Participant__c>();
                    for (Case_Participant__c cp : singCas.Case_Participants__r) // check if working or not
                    {     
                        mapOfCasIdVsCasPart.put(cp.Id, cp); //mapIdOpp.get(i).xxx_r[0].Name;   
                    }
                    //(singCas.Adjudication_Reports__c).Awarded_to_Tenant__c = ((singCas.Amount_to_tenants__c)*(singCas.Case_Participants__r).Split_percent__c)/100);
                    
                    if(mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Tenant__c!=null)
                        amtToTenant = (mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Tenant__c );
                    
                    system.debug('line-->747' + mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Agent__c );
                    if(mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Agent__c!=null)
                        awardToAgent=mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Agent__c;
                    
                    system.debug('line-->750' + amtToAGLL);
                    if(mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Landlord__c!=null)
                        awardToLandlord=mapOfCaseWithCasePar.get(singCas.Id).Adjudication_Reports__r[0].Awarded_to_Landlord__c;
                    
                    system.debug('line-->754' + amtToAGLL );
                    amtToAGLL = awardToAgent+awardToLandlord;
                    //Map of CASE PARTICIPANTS is not empty START
                    if(!mapOfCasIdVsCasPart.isEmpty()) {
                        
                        Set<String> ContactIds = new Set<String>();
                        //List<cpm__Payment__c> createPaymentList = new List<cpm__Payment__c>();
                        //Map<Id,cpm__Installment__c> mapOfContactIdVsInst = new Map<Id,cpm__Installment__c>();
                        //List<Inbound_Report__c> createPaymentList = new List<Inbound_Report__c>();
                        Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
                        
                        for(Case_Participant__c casePar : mapOfCasIdVsCasPart.values()){
                            ContactIds.add(casePar.Contact__c);
                        }
                        
                        MAp<String,Bank_Account__c> mapOFContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
                        System.debug('casPar => ' + mapOfCasIdVsCasPart.values());
                        //System.debug('payableAmount => ' + payableAmount);
                        System.debug('mapOFContactIdVsBankDet => ' + mapOFContactIdVsBankDet);
                        System.debug('mapOfContactIdVsInst Before => ' + mapOfContactIdVsInst);
                        for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()) {
                            
                            //   if(setOfCaseForRwAdj.contains(casPar.Case__c)) {
                            if(casPar.Type__c == 'Tenant') {
                                Decimal tenantamount= (amtToTenant*casPar.Split_percent__c)/100 ;
                                if(tenantamount>0) {
                                    //getInstallments(casPar,tenantamount,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                    EI_UtilityClassForPayments.getNewInstallments(casPar, tenantamount, false, 'Final Payment', 
                                                                                  mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                                  'Tenant changeover', null);
                                }
                            }
                            else {
                                if(amtToAGLL>0) 
                                {
                                    //getInstallments(casPar,amtToAGLL,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                                    EI_UtilityClassForPayments.getNewInstallments(casPar, amtToAGLL, false, 'Final Payment', 
                                                                                  mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                                  'Tenant changeover', null);
                                }
                            }
                            //  }
                        }
                        
                        System.debug('mapOfContactIdVsInst After => ' + mapOfContactIdVsInst);
                        
                        if(!mapOfContactIdVsInst.isEmpty()){
                            system.debug(' line 202' + mapOfContactIdVsInst);
                            insert mapOfContactIdVsInst.values();
                        }
                        //System.debug('createPaymentList before => ' + createPaymentList);
                        //for(cpm__Installment__c inst : mapOfContactIdVsInst.values()){
                        
                        
                        Deposit__c depo = new Deposit__c();
                        depo.Id = singCas.Deposit_Account_Number__c;
                        depo.Agreed_amount__c = amtToAGLL + amtToTenant;
                        updatedepositdata.add(depo);
                        System.debug('updatedepositdata => ' + updatedepositdata);
                    }
                    //Map of CASE PARTICIPANTS is not empty START
                }
            }
            
        }
        //Map of CASE is not empty END}
        
        if(updatedepositdata.size()>0){
            update updatedepositdata;
        }
        
    }
    
    @future(callout = true)
    public static void evidenceGatheringSendEmails(string useremail,string userpersonemail,string username,string DAN,String Address) { 
        
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
        //    gen.writeStringField('DisputeAmount', String.valueOf(castInst.Case__r.Disputed_Amount__c));
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
    public static String getJSONBODYofinvite(Case_Participant__c castInst,String SDSEmail) {
        
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
    
    @future(callout = true)
    public static void notifyLandlordandTenant(Set<Id> caseIds,String stage) {
        
        String SDSEmail = 'ashish.singh1@espire.com';
        for(Case_Participant__c caspart : 
            [Select id,name,Case__c,Contact__r.Email,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,
             Case__r.Tenancy_Property_Address__c,Case_Participant__c.Type__c,Is_Lead__c,Case__r.Deposit_Account_Number__c,
             Case__r.Deposit_Account_Number__r.Name,Case__r.Disputed_Amount__c from Case_Participant__c where Case__c IN : caseIds]) 
        {
            
            String JsonBody;
            if((caspart.Type__c == 'Landlord' || caspart.Type__c == 'Agent') && caspart.Contact__r.Email != null){
                // Send mail to landlord
                
                if(stage == 'LandlordEvdStage')
                    JsonBody = getJSONBODYofLL(caspart,SDSEmail); // get template for asking evidence by LL
                else
                    // JsonBody = getJSONBODYofLL(caspart,SDSEmail); // getJSONBODYofLLBYTT get template for notify LL
                    JsonBody = getJSONBODYofTTByLL(caspart,SDSEmail);
                evidenceGatheringSendEmailsTo(JsonBody);
            }
            if(caspart.Type__c == 'Tenant' && caspart.Contact__r.Email != null){
                // Send mail to tenant
                if(stage == 'LandlordEvdStage'){
                    // JsonBody = getJSONBODYofLL(caspart,SDSEmail); // getJSONBODYofTTByLLget template for notify TT
                    JsonBody =   getJSONBODYofTTByLL(caspart,SDSEmail);// getJSONBODYofTTByLLget template for notify TT
                }
                
                else{
                    //  JsonBody = getJSONBODYofLL(caspart,SDSEmail); // getJSONBODYofTTget template for asking evidence by TT
                    JsonBody = getJSONBODYofTT(caspart,SDSEmail); // getJSONBODYofTTget template for asking evidence by TT
                }
                
                evidenceGatheringSendEmailsTo(JsonBody);
            }
            
        }
        
        list<case> caselist = [select id,Deposit_Account_Number__c from case where Id IN : caseIds];
        if(!caselist.isempty()){
            for(case cst : caselist){
                deposit__c dc = new deposit__c();
                dc.Id = cst.Deposit_Account_Number__c;
                dc.Status__c ='Repayment not agreed - In dispute resolution';  
                update dc;
            }   
        }
        
    }
    
    @future(callout = true)
    public static void inviteAATTfornegotiate(Set<Id> caseIds) {
        
        String SDSEmail = 'ashish.singh1@espire.com';
        for(Case_Participant__c caspart : 
            [Select id,name,Case__c,Contact__r.Email,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,
             Case__r.Tenancy_Property_Address__c,Case_Participant__c.Type__c,Case__r.Deposit_Account_Number__c,
             Case__r.Deposit_Account_Number__r.Name,Case__r.Disputed_Amount__c from Case_Participant__c 
             where Case__c IN : caseIds]) 
        {
            
            String JsonBody;
            if((caspart.Type__c == 'Landlord' || caspart.Type__c == 'Agent') && caspart.Contact__r.Email != null){
                // Send mail to landlord
                
                JsonBody = getJSONBODYofinvite(caspart,SDSEmail); // getJSONBODYofLLBYTT get template for notify LL
                evidenceGatheringSendEmailsTo(JsonBody);
            }
            if(caspart.Type__c == 'Tenant' && caspart.Contact__r.Email != null){
                // Send mail to tenant
                JsonBody = getJSONBODYofinvite(caspart,SDSEmail); // getJSONBODYofTTByLLget template for notify TT
                evidenceGatheringSendEmailsTo(JsonBody);
            }
            
        }
        
    }
    
    public static void getInstallments(Case_Participant__c casePAr,Decimal AmountforInst,Boolean bol, 
                                       Map<String,Bank_Account__c> mapOFContactIdVsBankDet,Map<Id,Installment__c> mapOfContactIdVsInst) {
        
        Installment__c Installmentrec = new Installment__c();
        Installmentrec.Contact__c = casePAr.Contact__c;
        Installmentrec.Created_at__c= date.today();
        Installmentrec.Credit_note_reference__c = null;
        Installmentrec.Payment_reference__c = null;//paymentReference
        Installmentrec.Deposit__c = casePAr.Case__r.Deposit_Account_Number__c;                                                               
        Installmentrec.Case__c = casePAr.Case__c; 
        Installmentrec.Status__c ='Pending processing'; 
        
        /*if(disuptedInst) {
            Installmentrec.cpm__Amount__c = AmountforInst;
            mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);   
        }*/
        Installmentrec.Amount__c = AmountforInst; 
        
        if(mapOFContactIdVsBankDet.containsKey(casePAr.Contact__c)) {
            if(!mapOFContactIdVsBankDet.get(casePAr.Contact__c).ValidInternationBankDetails__c) {
                //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Account_Number__c;
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Name__c;
                // Installmentrec.cpm__Custom_IBAN__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).IBAN__c;
            } else {
                //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Account_Number__c;
                Installmentrec.Bank_sort_code__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Sort_Code__c;                                                                 
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Name__c;
            }
        }
        mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);   
    }
    
    public static String getJSONBODYForEvidGathEmails(Case_Participant__c castInst, String SDSEmail) {
        System.debug('Line 1226');
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
        
        gen.writeStringField('Subject', 'Case moving to \'Evidence review complete\' ');
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
    
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, Integer noOfDays) {
        if(startDate == null) {
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()) {
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays) {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)) {
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidayList)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays) {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays) {
            if(currentDate.daysBetween(hDay.ActivityDate) == 0) {
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) == 5 || weekStart.daysBetween(currentDate) == 6) {
            return false;
        } else {
            return true;    
        }
    }
    
}