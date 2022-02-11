public without sharing class EI_AGLLevidencegathering {
     
    public static List<Holiday> holidayList;
    
    @AuraEnabled
    public static list<case> getclaimdetailsforevidence(String depositid)
    { 
        case casedata = [select id,PreviousStatus__c from case where Deposit_Account_Number__c=:depositid and (status=:'Evidence gathering AA/LL' OR (Status = 'On Hold'  AND  PreviousStatus__c ='Evidence gathering AA/LL')) limit 1 ];
        //string claimId = [select id,Case__c from Case_Participant__c where Access_Code__c=:AccessCode ]?.Case__c;
        list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,Total_Claimed_by_Landlord__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,Deposit_Protected_Amount__c,
                                Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,
                                Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
                                Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                                AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                Claim_exceeds_the_total_level_of_cover__c,Claim_exceed__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
                                inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
                                Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
                                Repayment_amount_to_AGLL__c,Repayment_amount_to_tenant__c,Agreed_amount_from_AGLL_to_TT__c,
                                (select id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Name, Contact__r.Phone,Account__r.Tenant_External_ID__c
                                 from Case_Participants__r),
                                (select id,Name,Adjustment_Percentage_by_AGLL__c,Adjustment_Percentage_by_TT__c,
                                 Agreed_by_AGLL__c,Agreed_by_Tenant__c,Claim_breakdown_other_AGLL__c,
                                 Claim_description_for_cleaning_agll__c,Claim_description_for_damage_agll__c,
                                 Claim_description_for_gardening_agll__c,Claim_description_for_redecoration_agll__c,
                                 Claimed_by_Landlord__c,Dispute__c,Evidence_at_tenancy_end_for_cleaning_agl__c,
                                 Evidence_at_tenancy_end_for_damage_agll__c,Evidence_at_tenancyend_gardening_agll__c,
                                 Evidence_at_tenancyend_redecoration_agll__c,Evidence_at_tenancystart_cleaning_agll__c,
                                 Evidence_at_tenancystart_damage_agll__c,Evidence_at_tenancystart_gardening_agll__c,
                                 Evidence_at_tenancystart_redecoration_ag__c,External_ID__c,Landlord_Statement__c,
                                 Other_Reason__c,Rent_arrears_description_agll__c,Supporting_clause_cleaning_agll__c,
                                 Supporting_clause_damage_agll__c,Supporting_clause_gardening_agll__c,Supporting_clause_other_agll__c,
                                 Supporting_clause_redecoration_agll__c,Supporting_clause_rent_agll__c,
                                 Supporting_evidence_for_cleaning_agll__c,Supporting_evidence_for_damage_agll__c,
                                 Supporting_evidence_for_gardening__c,Supporting_evidence_for_other_agll__c,
                                 Supporting_evidence_for_redecoration_agl__c,Supporting_evidence_for_rent_agll__c,
                                 Tenant_Response__c,Tenant_Statement__c,Type__c,Was_the_property_re_let_rent_agll__c,Is_Tenant_Agree__c,
                                 Is_Tenant_Upload_Evidence__c,Tenant_Disagree_comment__c, dispute_amount__c
                                 from Dispute_Items__r where dispute_amount__c >0),
                                (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                                 Azure_File_Name__c,User_Type__c,File_Size__c
                                 from Evidence_Attachments__r)
                                
                                from case where id=:casedata.Id order by lastModifiedDate desc];
        return caseparti;
    }   
    @AuraEnabled
    public static list<case> getclaimdetailsforevidenceForCancel(String depositid)
    { 
        return  [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                 Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,
                 Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,
                 Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
                 Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                 AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                 Claim_exceeds_the_total_level_of_cover__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
                 inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
                 Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
                 Repayment_amount_to_AGLL__c,Repayment_amount_to_tenant__c,Agreed_amount_from_AGLL_to_TT__c,
                 (select id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Name, Contact__r.Phone,Account__r.Tenant_External_ID__c
                  from Case_Participants__r),
                 (select id,Name,Adjustment_Percentage_by_AGLL__c,Adjustment_Percentage_by_TT__c,
                  Agreed_by_AGLL__c,Agreed_by_Tenant__c,Claim_breakdown_other_AGLL__c,
                  Claim_description_for_cleaning_agll__c,Claim_description_for_damage_agll__c,
                  Claim_description_for_gardening_agll__c,Claim_description_for_redecoration_agll__c,
                  Claimed_by_Landlord__c,Dispute__c,Evidence_at_tenancy_end_for_cleaning_agl__c,
                  Evidence_at_tenancy_end_for_damage_agll__c,Evidence_at_tenancyend_gardening_agll__c,
                  Evidence_at_tenancyend_redecoration_agll__c,Evidence_at_tenancystart_cleaning_agll__c,
                  Evidence_at_tenancystart_damage_agll__c,Evidence_at_tenancystart_gardening_agll__c,
                  Evidence_at_tenancystart_redecoration_ag__c,External_ID__c,Landlord_Statement__c,
                  Other_Reason__c,Rent_arrears_description_agll__c,Supporting_clause_cleaning_agll__c,
                  Supporting_clause_damage_agll__c,Supporting_clause_gardening_agll__c,Supporting_clause_other_agll__c,
                  Supporting_clause_redecoration_agll__c,Supporting_clause_rent_agll__c,
                  Supporting_evidence_for_cleaning_agll__c,Supporting_evidence_for_damage_agll__c,
                  Supporting_evidence_for_gardening__c,Supporting_evidence_for_other_agll__c,
                  Supporting_evidence_for_redecoration_agl__c,Supporting_evidence_for_rent_agll__c,
                  Tenant_Response__c,Tenant_Statement__c,Type__c,Was_the_property_re_let_rent_agll__c,Is_Tenant_Agree__c,
                  Is_Tenant_Upload_Evidence__c,Tenant_Disagree_comment__c, dispute_amount__c
                  from Dispute_Items__r where dispute_amount__c >0),
                 (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                  Azure_File_Name__c,User_Type__c,File_Size__c
                  from Evidence_Attachments__r)
                 
                 from case where Deposit_Account_Number__c=:depositid ANd status=:'Evidence gathering TT' limit 1 ];
    }  
    
   @AuraEnabled
    public static void updateClaimAGLL(string claimId,boolean consentBox)
    {
        case caseToUpdate = new case(id=claimId,Consent_box_AGLL__c='Yes');
        update caseToUpdate;
    }
    
    @AuraEnabled
    public static void updatekeyDocuments(string caseRecID,string tenantObligation,string exceedclaim,string inventryChekReport,
                                          string checkOutReport,string rentStatement,string claimExceedsComment)
    {
        case updatecaseList = new case(id=caseRecID,Tenant_obligations__c =tenantObligation,Claim_exceed__c=exceedclaim,inventorycheck_in_report_AGLL__c=inventryChekReport,
                                       check_out_report_AGLL__c=checkOutReport,Rent_statement_AGLL__c =rentStatement,
                                       Claim_exceeds_comment_AGLL__c=claimExceedsComment,AGLL_Respond_Evidance_Gathering__c=true);
        update updatecaseList;
    }
    
    @AuraEnabled
    public static void updateClaimBreakdown(string disputeItemRec)
    {
        List<Dispute_Item__c> updatedisputeList = (list<Dispute_Item__c>)System.JSON.deserialize(disputeItemRec, list<Dispute_Item__c>.class);
        update updatedisputeList;
    }
    
    @AuraEnabled
    public static void updateAdditionalComments(string caseId,string additionalComment,string consentBoxValue)
    {
        case caseToUpdate = new case(id=caseId,Additional_comments_AGLL__c=additionalComment/*,Consent_box_AGLL__c=consentBoxValue*/);
        update caseToUpdate;
    }
    
    @AuraEnabled
    public static string UpdateClaimDetails(String claimId, String customerType,Decimal amount, String scheme, String claimExternalId )
    {
        
        string LeadTenantUrl; 
        if(customerType=='AGLL'){
            case  casetoUpdate=  new case(id=claimId,status='Case cancelled',Close_Reason__c='Case Closed',Claim_Agreed_By__c='Agent/Landlord');
            update casetoUpdate;
            LeadTenantUrl ='AGLL';
        }else if(customerType!='AGLL'){
            case  casetoUpdate=  new case(id=claimId,status='Case closed - agreement reached',Claim_Agreed_By__c='Tenant',Close_Reason__c='Agreement Reached',Make_Payment_By_Community__c = true);
            //   LeadTenantUrl= MakePayment(claimId,'Tenant',amount,scheme,claimExternalId);
            update casetoUpdate;
            
        }
        return LeadTenantUrl;
    }
    
    @AuraEnabled 
    public static string cancelclaim(string caseid, Decimal disptAmount ) {
        string successmessage = 'success';
        calculateWorkingDaysBetweenTwoDates(system.today(), 5);
        case  casetoUpdate=  new case(id=caseid,Dispute_resolution_status__c = 'Resolved without adjudication',status='Deposit to be repaid - resolved without adjudication',Bypass_validation__c=true,Respond_Date__c=calculateWorkingDaysBetweenTwoDates(system.today(), 5));
        paymentForCancelClaim(caseid, disptAmount);   
        update casetoUpdate;   
        
        
        return successmessage;
        
    }
    
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, Integer noOfDays)
    {
        if(startDate == null){
            return null;
        }
        if(holidayList == null || holidayList.isEmpty()){
            holidayList = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        }
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidayList)){
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
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays) {
            if(currentDate.daysBetween(hDay.ActivityDate) == 0) {
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) ==5 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }
    
    public static void paymentForCancelClaim(Id caseId, Decimal disptAmount) {
        system.debug('line');
        String SDSEmail = 'ashish.singh1@espire.com';
        
        list<Deposit__c> updatedepositdata = new list<Deposit__c>();
        User loggedUser = [Select Id, Name, Profile.Name, AccountId, ContactId from User where Id =: UserInfo.getUserId() limit 1];
        
        // NEW START   
        
        Map<Id, Case> mapOfCaseWithCasePar = new Map<Id, Case>
            ([SELECT Id,
              Disputed_Amount__c,
              Status,
              Amount_to_tenants__c,
              Amount_to_agent_landlord__c,
              Deposit_Account_Number__r.Name,
              Tenancy_Property_Address__c,
              Deposit_Account_Number__c,
              Total_Agreed_by_AG_LL__c,
              Total_Agreed_by_Tenant__c,
              Agreed_amount__c,
              Deposit_Protected_Amount__c,
              Remaining_protected_amount__c,
              Deposit_Account_Number__r.Agreed_amount__c,
              (SELECT Id,
               Account__c,
               Contact__c,
               Case__c,
               Case__r.Deposit_Account_Number__r.Name,
               Contact__r.Name,
               Type__c,
               Contact__r.Email,
               Contact__r.FirstName,
               Contact__r.LastName,
               Payable_Amount__c,
               Split_percent__c,
               Case__r.Tenancy_Property_Address__c,
               Case__r.Deposit_Account_Number__c,
               Is_Lead__c, 
               Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c
               FROM Case_Participants__r) 
              FROM Case where Id = :caseId
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
                    
                    Set<String> ContactIds = new Set<String>();
                    //List<cpm__Payment__c> createPaymentList = new List<cpm__Payment__c>();
                    //List<Inbound_Report__c> createPaymentList = new List<Inbound_Report__c>();
                   // Map<Id,cpm__Installment__c> mapOfContactIdVsInst = new Map<Id,cpm__Installment__c>();
                    Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
                    for(Case_Participant__c casePar : mapOfCasIdVsCasPart.values()){
                        ContactIds.add(casePar.Contact__c);
                    }
                    
                    MAp<String,Bank_Account__c> mapOFContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
                    
                    
                    //for(Id caseId : mapOfCaseVsCasPar.keyset()){
                    
                    Decimal AmountPaidTOLL = 0;
                    Decimal AmountPaidTOTT = 0;
                    
                    
                    //Case currentCase = singCas;
                    Deposit__c depobj = new deposit__c();
                    depobj.id = singCas.Deposit_Account_Number__c;
                    depobj.Agreed_amount__c =singCas.Deposit_Account_Number__r.Agreed_amount__c;
                    depobj.Status__c='Repayment process';
                    system.debug('line--> 551' + singCas);
                    system.debug('line-->185' + depobj.Agreed_amount__c );
                    if(loggedUser.Profile.Name == 'Tenant') {
                        AmountPaidTOLL = disptAmount;
                        AmountPaidTOTT = 0;
                        system.debug('line-->275' + depobj.Agreed_amount__c);
                        depobj.Agreed_amount__c = depobj.Agreed_amount__c + AmountPaidTOLL;
                        updatedepositdata.add(depobj);
                        
                        // send emails
                      //  sendTenantCancelledClaimEmail(singCas, disptAmount);
                        
                        
                    } else {
                        AmountPaidTOLL = 0;
                        AmountPaidTOTT = disptAmount;
                        system.debug('line-->196' +  depobj.Agreed_amount__c + AmountPaidTOTT);
                        depobj.Agreed_amount__c = depobj.Agreed_amount__c + AmountPaidTOTT;
                        updatedepositdata.add(depobj);
                    }
                    
                    //for(Case_Participant__c casPar : mapOfCaseVsCasPar.get(caseId)) {
                    for(Case_Participant__c casPar : mapOfCasIdVsCasPart.values()) {
                        String jsonBody;
                        
                        if(casPar.Type__c == 'Tenant' && AmountPaidTOTT>0 ) {
                            system.debug('line--> 296' + AmountPaidTOTT );
                            //jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Tenant');
                            Decimal amtToTen = (AmountPaidTOTT*casPar.Split_percent__c)/100;
                            if(amtToTen>0) {
                                 //getInstallments(casPar,amtToTen,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                    			EI_UtilityClassForPayments.getNewInstallments(casPar, amtToTen, false, 'Final Payment', 
                                                                              mapOFContactIdVsBankDet, mapOfContactIdVsInst, 
                                                                              'Deposit repayment request', null);
                            }
                        }
                        else {
                            system.debug('line--> 305 ' + AmountPaidTOLL );
                            //  jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,'Agent');
                            if( casPar.Type__c != 'Tenant' && AmountPaidTOLL>0) 
                            {
                                //getInstallments(casPar,AmountPaidTOLL,false,mapOFContactIdVsBankDet,mapOfContactIdVsInst);
                            	EI_UtilityClassForPayments.getNewInstallments(casPar, AmountPaidTOLL, false, 'Final Payment',  
                                                                              mapOFContactIdVsBankDet,mapOfContactIdVsInst, 
                                                                              'Deposit repayment request', null);
                            }
                        }
                        
                        /*if(String.isNotBlank(jsonBody)) {
EI_SdsColleagueChangesCaseStatus.evidenceGatheringSendEmailsTo1(jsonBody);
}*/   
                    }
                    //}
                    
                   if(loggedUser.Profile.Name == 'Tenant') { 
                   for(Case_Participant__c casParti : mapOfCasIdVsCasPart.values()) { 
                       
                       
                       
                       
                       
                   }
                   } 
                    
                    if(!updatedepositdata.isEmpty()){
                        update updatedepositdata;
                    }
                    
                    if(!mapOfContactIdVsInst.isEmpty()){
                        insert mapOfContactIdVsInst.values();
                    }
                    
                    
                }
                //Map of CASE PARTICIPANTS is not empty START
            }
            
            
            
        }
        //NEW END  
        
    }
    private static void sendTenantCancelledClaimEmail(Case singCas, Decimal amountPerTenant){
        String SDSEmail = 'ADR@safedepositsscotland.com';
        
        String jsonBody;
        for(Case_Participant__c casPar : singCas.Case_Participants__r) {
            jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail,amountPerTenant);
            
            if(String.isNotBlank(jsonBody)) {
                EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo1(jsonBody);
            }
        }
    }
    
    private static String getJSONBODYforTT_SR(Case_Participant__c castInst,String SDSEmail, Decimal amountPerTenant){
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
        
        //String templateId = API_Service__mdt.getInstance('Resolve_without_consent').Template_Id__c; //@todo
        
        gen.writeNumberField('TemplateID', 3031154);
        gen.writeBooleanField('TemplateLanguage', true);
        
        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        gen.writeStringField('Subject', 'Deposit repayment agreed - '+firstLine);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        
        if(castInst.Is_Lead__c == false && castInst.Type__c == 'Tenant'){
            User userThatWithdrewConsent = [select contactid from user where id =: userInfo.getUserId()];
            contact userContact = [select Name from contact where id =: userThatWithdrewConsent.contactId];
            
            gen.writeStringField('tenantname', userContact.Name);
        }
        gen.writeNumberField('disputeamount', amountPerTenant);
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    public static void getInstallments(Case_Participant__c casePAr,Decimal AmountforInst,Boolean bol,MAp<String,Bank_Account__c> mapOFContactIdVsBankDet,Map<Id,cpm__Installment__c> mapOfContactIdVsInst){
        
        cpm__Installment__c Installmentrec = new cpm__Installment__c();
        Installmentrec.cpm__Contact__c = casePAr.Contact__c;
        Installmentrec.Created_at__c= date.today();
        Installmentrec.Credit_note_reference__c = null;
        Installmentrec.Payment_reference__c = null;//paymentReference
        Installmentrec.DAN__c = casePAr.Case__r.Deposit_Account_Number__c;                                                               
        Installmentrec.Case__c = casePAr.Case__c; 
        Installmentrec.cpm__Status__c = 'Pending processing';  
        /*if(disuptedInst){
Installmentrec.cpm__Amount__c = AmountforInst;
mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);   
}*/
        Installmentrec.cpm__Amount__c = AmountforInst; 
        
        if(mapOFContactIdVsBankDet.containsKey(casePAr.Contact__c)){
            if(!mapOFContactIdVsBankDet.get(casePAr.Contact__c).ValidInternationBankDetails__c){
                Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Account_Number__c;
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Name__c;
                Installmentrec.cpm__Custom_IBAN__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).IBAN__c;
            }else{
                Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                Installmentrec.Bank_account_holder_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                Installmentrec.Bank_account_number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Account_Number__c;
                Installmentrec.Bank_sort_code__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Sort_Code__c;                                                                 
                Installmentrec.Bank_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Name__c;
            }
        }
        mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);   
    }
    
    @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }
    
    // When Tenant Make  offer of AGLL during self resolution email to  othertenant
	/* public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferMadeByTTMailToOtherTT(string useremail,string username,String propaddress,Decimal offeramount,string caseid){ 
    	string message = 'mail send';
        
    	HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Confirmation of offer-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferMadeByTTMailToOtherTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
		
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid));
        variableMap.put('date', String.valueOf(System.today().format()));
        variableMap.put('name', username);
        variableMap.put('first_name_of_address', propaddress);
        variableMap.put('offer_details', string.valueof(offeramount));
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferMadeByTTMailToOtherTT', emailsubject);    
		return EmailWrapper;
    }*/

    
}