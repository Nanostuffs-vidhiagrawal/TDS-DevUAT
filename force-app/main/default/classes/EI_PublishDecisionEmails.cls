public class EI_PublishDecisionEmails {
    
    public static List<Holiday> holidayList;
    
    @InvocableMethod
    public static void methodForPublishFlow(List<Id> lstIds) {
        
        List<Adjudication_Report__c> adjReport = new List<Adjudication_Report__c>(
														[Select Id, Dispute__c from Adjudication_Report__c where Id = :lstIds[0]] );
        if(!lstIds.isEmpty() && (adjReport[0].Dispute__c!=null || adjReport[0].Dispute__c!=''))
        {
        	sendEmailsOnPublishDecision(adjReport[0].Dispute__c, lstIds[0]);   
        }
    }
	
	@future(callout = true)
    public static void sendEmailsOnPublishDecision(String caseId, String adjRepId) {
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        List<Case> lstCase = new List<Case> (
            [SELECT Id, Disputed_Amount__c,PreviousStatus__c, Status, Amount_to_tenants__c, Amount_to_agent_landlord__c, Deposit_Account_Number__r.Name, 
             Deposit_Account_Number__c,recordtype.name, Deposit_Account_Number__r.Agreed_amount__c, Tenancy_Property_Address__c, Total_Agreed_by_AG_LL__c, 
             Total_Agreed_by_Tenant__c, Agreed_amount__c, Deposit_Protected_Amount__c, Remaining_protected_amount__c,
             (SELECT Id, Account__c, Contact__c, Case__c, Case__r.Deposit_Account_Number__c, Contact__r.Name, Type__c, Contact__r.Email, 
              Contact__r.FirstName, Contact__r.LastName, Payable_Amount__c, Split_percent__c, Case__r.Deposit_Account_Number__r.Name, 
              Case__r.Tenancy_Property_Address__c FROM Case_Participants__r), 
             (SELECT Id,Disputed_Amount__c, Awarded_to_Agent__c, Awarded_to_Landlord__c, Dispute_Status__c,Awarded_to_Tenant__c, Webhook_Report_Link__c FROM Adjudication_Reports__r 
              where Status__c='Published' and Id = :adjRepId order by createdDate desc limit 1) FROM Case where Id = :caseId and recordtype.name='Dispute SDS Custodial' limit 1]);
   
        list<Adjudication_Report__c> adjrep =  [SELECT Id,Disputed_Amount__c, Awarded_to_Agent__c, Awarded_to_Landlord__c, Dispute_Status__c,Awarded_to_Tenant__c, Webhook_Report_Link__c FROM Adjudication_Report__c 
                                            where Status__c='Published' and Id = :adjRepId order by createdDate desc limit 1  ];
             
        if(!lstCase.isEmpty() && !adjrep.isEmpty()) {
            
            if(lstCase[0].Adjudication_Reports__r[0].Dispute_Status__c=='Review request accepted – assign to adjudicator' || lstCase[0].Adjudication_Reports__r[0].Dispute_Status__c=='On Hold' ){
            for(Case_Participant__c castInst1 : lstCase[0].Case_Participants__r) {
            AdjudicationReviewRequestAcceptedMailAll(castInst1.Contact__r.Email,castInst1.Contact__r.Name,castInst1.Case__r.Tenancy_Property_Address__c,castInst1.Case__r.Deposit_Account_Number__c,adjrep[0].Disputed_Amount__c,castInst1.Case__c,castInst1.Contact__c,castInst1.Account__c);
            emailWrapperList.add(AdjudicationReviewRequestAcceptedMailAll(castInst1.Contact__r.Email,castInst1.Contact__r.Name,castInst1.Case__r.Tenancy_Property_Address__c,castInst1.Case__r.Deposit_Account_Number__c,adjrep[0].Disputed_Amount__c,castInst1.Case__c,castInst1.Contact__c,castInst1.Account__c));  
            }
             if(emailWrapperList.size()>0){
                EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
            }
            }
            else{
             for(Case_Participant__c castInst2 : lstCase[0].Case_Participants__r) {   
             AdjudicationReportPublishMailAll(castInst2.Contact__r.Email,castInst2.Contact__r.Name,castInst2.Case__r.Tenancy_Property_Address__c,castInst2.Case__c,castInst2.Contact__c,adjrep[0].Webhook_Report_Link__c,castInst2.Account__c);    
             emailWrapperList.add(AdjudicationReportPublishMailAll(castInst2.Contact__r.Email,castInst2.Contact__r.Name,castInst2.Case__r.Tenancy_Property_Address__c,castInst2.Case__c,castInst2.Contact__c,adjrep[0].Webhook_Report_Link__c,castInst2.Account__c));
             }
                if(emailWrapperList.size()>0){
                    EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
                } 
            }
            
            System.debug('line-->139'+ lstCase[0].Adjudication_Reports__r[0].Dispute_Status__c);
            if(lstCase[0].Adjudication_Reports__r[0].Dispute_Status__c=='Review request accepted – assign to adjudicator' || 
               (lstCase[0].PreviousStatus__c=='Review request accepted – assign to adjudicator' && 
                lstCase[0].Adjudication_Reports__r[0].Dispute_Status__c=='On Hold' )) 
            {
                Deposit__c depobj = new Deposit__c();
                depobj.Id = lstCase[0].Deposit_Account_Number__c;
                depobj.Status__c = 'Repayment process';
                update depobj;
                System.debug('Line 141 ->' + lstCase[0].Adjudication_Reports__r[0].Dispute_Status__c);
                lstCase[0].Status = 'Deposit to be repaid – decision issued';  
                lstCase[0].Dispute_resolution_status__c = 'Resolved with adjudication'; 		// Using this field for reporting purpose
            }
             if(lstCase[0].Adjudication_Reports__r[0].Dispute_Status__c=='Adjudication' || 
                (lstCase[0].PreviousStatus__c=='Adjudication' && lstCase[0].Adjudication_Reports__r[0].Dispute_Status__c=='On Hold' )) 
             {
                System.debug('Line 145 -> ');
                lstCase[0].Bypass_validation__c=true;
                lstCase[0].Status = 'Decision issued - awaiting request for review';
                lstCase[0].Respond_Date__c = EI_UtilityClassForPayments.dueDateMethod(System.today(), 10);
            }
            update lstCase[0];
        }
    
    }
    
    public static void evidenceGatheringSendEmailsTo(string jsonData) { 
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    // When Review  request accepted and republish adjudication report
    public static EI_SDS_MailJetUtilityCls.EmailWrapper AdjudicationReviewRequestAcceptedMailAll(String useremail, String username, String propaddress, 
		String DAN, Decimal disputedamount, String caseid, String contactid, String accountid) 
    { 
        String message = 'mail send';
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String emailsubject = 'Response to your review request-'+propaddress;
        
        toName = username;
        toAddress = useremail;
        
        if(contactid !=null) {
            CustomerId =contactid;    
        }
        else {
            CustomerId =accountid;   
        }
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('name', username);
        //variableMap.put('dan', DAN);
        variableMap.put('first_line_of_address', propaddress);
        variableMap.put('dispute_amount', string.valueof(disputedamount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'AdjudicationReviewRequestAcceptedMailAll', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
    }
    
    // When published adjudication report by adjudicator mail to all
    public static EI_SDS_MailJetUtilityCls.EmailWrapper AdjudicationReportPublishMailAll(String useremail, String username, String propaddress, String caseid, 
                                                                                         String contactid, String reportlink, String accountid) 
    {
        String message = 'mail send';
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String adjudicationlink;
        String emailsubject = 'Adjudicators decision - '+propaddress;
        
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        Date deadlinedate = EI_UtilityClassForPayments.dueDateMethod(System.today(), 10);
        String deadlineDateStr = deadlinedate.day()+'/'+deadlinedate.month()+'/'+deadlinedate.year();
        
        toName = username;
        toAddress = useremail;
		        
        if(contactid!=null) {
            CustomerId =contactid;   
        }
        else {
            CustomerId =accountid;    
        }
        adjudicationlink='<a href="'+reportlink+'">Adjudication report link</a>';
        system.debug('line-->337' + adjudicationlink );
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('date', todayStr);
        variableMap.put('name', username);
        // variableMap.put('dan', DAN);
        variableMap.put('deadline_date', deadlineDateStr);
        variableMap.put('adjudication_report_link', adjudicationlink);
        // variableMap.put('dispute_amount', string.valueof(disputedamount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'AdjudicationReportPublishMailAll', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
    }
    
}