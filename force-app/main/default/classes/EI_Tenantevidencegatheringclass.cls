public without sharing class EI_Tenantevidencegatheringclass {
    
    @AuraEnabled
    public static boolean getLeadTenant(String depositId){
        
        Boolean isLeadTenant = true;
        try{
            User userObj = [Select Id,ProfileId,Profile.Name,ContactId,AccountId FROM User where Id =: userInfo.getUserId()];
            for(Deposit_Allocation__c eachDA : [select Id, Deposit__c, Role__c, Is_Lead__c, Deposit_Holder__c, Contact__c from Deposit_Allocation__c  where Deposit__c=:depositId]){
                if(eachDA.Contact__c == userObj.ContactId && eachDA.Deposit_Holder__c == userObj.AccountId && (!eachDA.Is_Lead__c && eachDA.Role__c == 'Tenant')){
                    isLeadTenant = false;
                }
            }
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
        return isLeadTenant;
    }
    
    @AuraEnabled
    public static Wrapper getclaimdetailsforevidenceNoConsent(String depositid){
        Wrapper claimDetails =  new Wrapper();
        claimDetails.caseRec = getclaimdetailsforevidence(depositid)[0];
        claimDetails.daysFromNow = calculateWorkingDaysBetweenTwoDates(Date.today(), 30);

        return claimDetails;
    }
    
    @AuraEnabled
    public static list<case> getclaimdetailsforevidence(String depositid)
    { 
        list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,Consent_box_TT__c,
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
                                 from Dispute_Items__r where dispute_amount__c>0),
                                (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                                 Azure_File_Name__c,User_Type__c,File_Size__c
                                 from Evidence_Attachments__r)
                                
                                from case where Deposit_Account_Number__c=:depositid and (status='Evidence Gathering TT' OR (Status = 'On Hold'  AND  PreviousStatus__c ='Evidence Gathering TT')) limit 1];
        return caseparti;
    } 
    
    @AuraEnabled
    public static list<case> getViewOnlyTenantEvidences(String depositid)
    { 
        list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,
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
                                 Is_Tenant_Upload_Evidence__c,Tenant_Disagree_comment__c
                                 from Dispute_Items__r),
                                (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                                 Azure_File_Name__c,User_Type__c,File_Size__c
                                 from Evidence_Attachments__r)
                                from Case where Deposit_Account_Number__c=:depositid limit 1];
        return caseparti;
    }
    
    @AuraEnabled
    public static list<case> getClaimDetails(String claimId)
    {
        list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,Consent_box_TT__c,
                                Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,
                                Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
                                Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                                AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                Claim_exceeds_the_total_level_of_cover__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
                                inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
                                Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
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
                                 from Dispute_Items__r where dispute_amount__c>0),
                                (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                                 Azure_File_Name__c,User_Type__c,File_Size__c
                                 from Evidence_Attachments__r)
                                from case where id=:claimId];
        return caseparti;
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
            case  casetoUpdate=  new case(id=claimId,status='Case closed - agreement reached',Claim_Agreed_By__c='Tenant',Close_Reason__c='Withdrawn without action',Make_Payment_By_Community__c = true);
             //LeadTenantUrl= MakePayment(claimId,'Tenant',amount,scheme,claimExternalId);
            update casetoUpdate;
           
        }
        return LeadTenantUrl;
    }
    
    @AuraEnabled
    public static void AGLLMadeOffers(String claimId, String selectedVal, Decimal offerByAGLL)
    {
        if(selectedVal=='Accepted'){
            case  casetoUpdate=  new case(id=claimId,status='closed',Claim_Agreed_By__c='Agent/Landlord',Close_Reason__c='Agreement Reached',AGLL_Offer_Response__c='Accept');
            update casetoUpdate;
            //PDF generate and send to ZD via API - ZD-8 Sprint
            //send mail once template finalize
        }else if(selectedVal=='Rejected'){
            case  casetoUpdate=  new case(id=claimId,AGLL_Offer_Response__c='Reject',AGLL_Respond_Self_resolution__c =true);
            update casetoUpdate;
            //send mail once template finalize
        }else{
            case  casetoUpdate=  new case(id=claimId,AGLL_Offer_Response__c='Counter Offer',AGLL_made_Offer__c=true,AGLL_Offer_Amount__c=offerByAGLL,AGLL_Respond_Self_resolution__c =true);
            update casetoUpdate;
            //send mail once template finalize
        }      
    }
    
    @AuraEnabled
    public static String getCurrentDate()
    {
        string currentDate = EI_headOfficeUtility.getCurrentDate();
        return currentDate;
    }
    
    @AuraEnabled
    public static String UpdateDisputeItemSelfResolution(string disputeItemRec, string customerType, string claimId)
    {
        List<Dispute_Item__c> updatedisputeList = (list<Dispute_Item__c>)System.JSON.deserialize(disputeItemRec, list<Dispute_Item__c>.class);
        try{
            update updatedisputeList;
            if(customerType=='AGLL'){
                case updatecase = new case(id=claimId,AGLL_Respond_Self_resolution__c =true);
                update updatecase;
                
            }
            else
            {
                case updatecase = new case(id=claimId,TT_respond_Self_resolution__c=true);
                update updatecase;
                //EI_ZD_EmailUtility.sendEmailtoLandlordSelfResolution(claimId,'Invite landlord to respond self resolution');
            }
            //send mail once template finalize
           
            return 'Record successfully updated';
        }
        catch(exception exc)
        {
            return exc.getMessage();
        }
       
       
    }
    
    @AuraEnabled
    public static void TTMadeOffers(String claimId, String selectedVal, Decimal offerByAGLL)
    {
        if(selectedVal=='Accepted'){
            case  casetoUpdate=  new case(id=claimId,status='closed',Claim_Agreed_By__c='Tenant',Close_Reason__c='Agreement Reached',TT_Offer_Response__c='Accept');
            update casetoUpdate;
            //PDF generate and send to ZD via API - ZD-8 Sprint
            //send mail once template finalize
        }else if(selectedVal=='Rejected'){
            case  casetoUpdate=  new case(id=claimId,TT_Offer_Response__c='Reject',TT_respond_Self_resolution__c=true);
            update casetoUpdate;
            //send mail once template finalize
        }else if (selectedVal =='New Offer'){
            case  casetoUpdate=  new case(id=claimId,TT_Made_offer__c=true,TT_Offer_Amount__c=offerByAGLL,TT_respond_Self_resolution__c=true);
            update casetoUpdate;
            //send mail once template finalize
        }
        else
        {
            case  casetoUpdate=  new case(id=claimId,TT_Offer_Response__c='Counter Offer',TT_Made_offer__c=true,TT_Offer_Amount__c=offerByAGLL);
            update casetoUpdate;
        }
    }
    
    @AuraEnabled
    public static list<case> getClaimDetailsByAccessCode(String AccessCode)
    {
        string claimId = [select id,Case__c from Case_Participant__c where Access_Code__c=:AccessCode ]?.Case__c;
        list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,
                                Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,
                                Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
                                Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                                AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                Claim_exceeds_the_total_level_of_cover__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
                                inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
                                Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
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
                                 from Dispute_Items__r where dispute_amount__c>0),
                                (Select id,Dispute_Item__c,Filename__c,Location__c,Evidence_Categories__c,File_Type__c,
                                 Azure_File_Name__c,User_Type__c,File_Size__c
                                 from Evidence_Attachments__r)
                               
                                from case where id=:claimId];
        return caseparti;
    }
    
    @AuraEnabled
    public static void AgreedByAgent(String claimId)
    {
        case  casetoUpdate=  new case(id=claimId,status='Case closed - agreement reached',Claim_Agreed_By__c='Agent/Landlord',Close_Reason__c='Agreement Reached');
        update casetoUpdate;      
    }
    
    @AuraEnabled
    public static void updatekeyDocuments(string caseRecID,string tenantObligation,string inventryChekReport,
                                          string checkOutReport,string rentStatement,string claimExceedsComment)
    {
        case updatecaseList = new case(id=caseRecID,Tenant_obligations__c =tenantObligation,inventorycheck_in_report_AGLL__c=inventryChekReport,
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
        case caseToUpdate = new case(id=caseId,Additional_comments_AGLL__c=additionalComment,Consent_box_AGLL__c=consentBoxValue);
        update caseToUpdate;
    }
    @AuraEnabled
    public static void updateClaimTT(string claimId,boolean consentBox)
    {
        case caseToUpdate = new case(id=claimId,Consent_box_TT__c='Yes');
        update caseToUpdate;
    }
    
    @AuraEnabled
    public static void updateAdditionalCommentsTT(string caseId,string additionalComment)
    {
        case caseToUpdate = new case(id=caseId,Additional_comments_TT__c=additionalComment);
        update caseToUpdate;
    }
    
    @AuraEnabled
    public static void updateClaimItemTT(string disputeItemRec,string claimId,boolean isTenantRespond)
    {
        List<Dispute_Item__c> updatedisputeList = (list<Dispute_Item__c>)System.JSON.deserialize(disputeItemRec, list<Dispute_Item__c>.class);
        update updatedisputeList;
        if(!isTenantRespond)
        {
            case claimToUpdate = new case(Id=claimId,TT_respond_evidence_gathering__c = true);
            update claimToUpdate;
        }
    }
    
    @AuraEnabled
    public static void proceedWithNoConsent(Id caseid)
    {
         List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        try{
            if( ! String.isBlank(caseid)){
                update new Case(Id = caseid, status = 'Deposit to be repaid - court case');
                
                String SDSEmail = 'ADR@safedepositsscotland.com';

                List<Case> caseList = [SELECT Id, Disputed_Amount__c, Status, Respond_Date__c,Amount_to_tenants__c, Amount_to_agent_landlord__c, Deposit_Account_Number__r.Name, 
                                    Tenancy_Property_Address__c, Deposit_Account_Number__c, Total_Agreed_by_AG_LL__c, Total_Agreed_by_Tenant__c, Agreed_amount__c, 
                                    Deposit_Protected_Amount__c, Remaining_protected_amount__c, Deposit_Account_Number__r.Agreed_amount__c,
                                    (SELECT Id, Account__c, Contact__c, Case__c,Case__r.Deposit_Account_Number__r.Name,Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Case__r.Respond_Date__c,Contact__r.Name, Type__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, 
                                    Payable_Amount__c, Split_percent__c,Case__r.Tenancy_Property_Address__c,Case__r.Deposit_Account_Number__c,Is_Lead__c FROM Case_Participants__r) FROM Case where Total_Case_Participants__c > 0 AND Id =: caseid LIMIT 1];
                
                System.debug('caseid - '+ caseid);
                System.debug('case soql - '+ json.serialize(caseList));
                
                if(caseList.isEmpty() == false){
                    Case singCas = caseList[0];
                    Decimal disputedamount = (caseList[0].Total_Agreed_by_AG_LL__c-caseList[0].Total_Agreed_by_Tenant__c);
                    String jsonBody;
                    string leadname;
                    for(Case_Participant__c casPar1 : singCas.Case_Participants__r) {
                        if(casPar1.Type__c=='Tenant' && casPar1.Is_Lead__c ==true){
                            leadname =casPar1.contact__r.Name;
                        }
                    }
                    for(Case_Participant__c casPar : singCas.Case_Participants__r) {
                        if(casPar.Type__c=='Tenant'){
                            if(casPar.Is_Lead__c ==true){
                            EvidenceGatheringTTNotConsentToLeadTT(casPar.Contact__r.Email,casPar.contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,casPar.Case__r.Respond_Date__c,casPar.Case__c,casPar.Contact__c);         
                            emailWrapperList.add(EvidenceGatheringTTNotConsentToLeadTT(casPar.Contact__r.Email,casPar.contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,casPar.Case__r.Respond_Date__c,casPar.Case__c,casPar.Contact__c));    
                            }   
                            else{
                            EvidenceGatheringTTNotConsentToOtherTT(casPar.Contact__r.Email,casPar.contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,leadname,disputedamount,casPar.Case__c,casPar.Contact__c);    
                            emailWrapperList.add(EvidenceGatheringTTNotConsentToOtherTT(casPar.Contact__r.Email,casPar.contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,leadname,disputedamount,casPar.Case__c,casPar.Contact__c));
                            } 
                        }
                        if(casPar.Type__c!='Tenant'){
                        EvidenceGatheringTTNotConsentToAGLL(casPar.Contact__r.Email,casPar.contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,casPar.Case__r.Respond_Date__c,casPar.Case__c,casPar.Contact__c);    
                        emailWrapperList.add(EvidenceGatheringTTNotConsentToAGLL(casPar.Contact__r.Email,casPar.contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,casPar.Case__r.Respond_Date__c,casPar.Case__c,casPar.Contact__c));    
                        }
                       
                        
                      /*  jsonBody = getJSONBODYforTT_SR(casPar,SDSEmail);
                        
                        System.debug('email params - '+ jsonBody);
                        
                        if(String.isNotBlank(jsonBody)) {
                            EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo1(jsonBody);
                        }*/
                    }
                    if(emailWrapperList.size()>0){
                        EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
                    }
                }
                
            }
        }catch(Exception e){
            throw new aurahandledException(e.getMessage());
        }

    }
    
    public static boolean  checkLeadTenant(ID caseID)
    {
        boolean returnvale = true;
        for(Case_Participant__c c: [select id,No_of_Attempt__c,Is_Lead__c
                                    from Case_Participant__c
                                    where Case__c=:caseID ])
        {
            if(c.Is_Lead__c)
            {
                returnvale = false;
            }
        }
       
        return returnvale;
    }

    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }

    public class wrapper{
        @AuraEnabled
        public Case caseRec;
        @AuraEnabled
        public Date daysFromNow;
    }

    public static String getJSONBODYforTT_SR(Case_Participant__c castInst,String SDSEmail){
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
        
        gen.writeNumberField('TemplateID', 3031139);
        gen.writeBooleanField('TemplateLanguage', true);

        String firstLine = castInst.Case__r.Tenancy_Property_Address__c;
        if(String.isNotBlank(firstLine)){
            firstLine = firstLine.split('\n')[0];
        }
        gen.writeStringField('Subject', 'Termination of dispute resolution process -'+firstLine);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  

        if(castInst.Is_Lead__c == false && castInst.Type__c == 'Tenant'){
            User userThatWithdrewConsent = [select contactid from user where id =: userInfo.getUserId()];
            contact userContact = [select Name from contact where id =: userThatWithdrewConsent.contactId];

            gen.writeStringField('tenantName', userContact.Name);
        }
        
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
   // When Tenant not consent during  Evidence gathering email to lead tenant
    public static EI_SDS_MailJetUtilityCls.EmailWrapper EvidenceGatheringTTNotConsentToLeadTT(String useremail, String username, String propaddress, 
                                                                                              Date deadlinedate, String caseid, string contactId) 
    { 
		String message = 'mail send';
        
        String fromAddress;
        String toName;
        String toAddress;
     	//String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Termination of dispute resolution process-'+propaddress;
        toName =username;
        toAddress = useremail;
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, contactId));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        String deadlineDateStr = deadlinedate.day()+'/'+deadlinedate.month()+'/'+deadlinedate.year();
            
        variableMap.put('date', todayStr);
        variableMap.put('name', username);
        variableMap.put('deadline_date', deadlineDateStr);
        // variableMap.put('amounts', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'EvidenceGatheringTTNotConsentToLeadTT', emailsubject);    
        return EmailWrapper;
        
    }
    
    // When Tenant not consent during  Evidence gathering email to other tenants
    public static EI_SDS_MailJetUtilityCls.EmailWrapper EvidenceGatheringTTNotConsentToOtherTT(String useremail, String username, String propaddress, 
		String withdraweename, Decimal disputedamount, String caseid, String contactId) 
    { 
        String message = 'mail send';
        
        String fromAddress;
        String toName;
        String toAddress;
     	// String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Termination of dispute resolution process-'+propaddress;
        toName =username;
        toAddress = useremail;
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, contactId));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('date', todayStr);
        variableMap.put('name', username);
        variableMap.put('Withdrawee_name',withdraweename);
        variableMap.put('amount', string.valueof(disputedamount));
        // variableMap.put('Address', propaddress);
		// variableMap.put('Tenant_changeover_details', changeoverdetails);
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'EvidenceGatheringTTNotConsentToOtherTT', emailsubject);
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
    }
    
    // When Tenant not consent during  Evidence gathering email to AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper EvidenceGatheringTTNotConsentToAGLL(String useremail, String username, String propaddress, 
                                                                                            Date deadlinedate, String caseid, String contactId) 
    { 
     	String message = 'mail send';
        
        String fromAddress;
        String toName;
        String toAddress;
     	//String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Termination of dispute resolution process-'+propaddress;
        toName =username;
        toAddress = useremail;
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, contactId));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        String deadlineDateStr = deadlinedate.day()+'/'+deadlinedate.month()+'/'+deadlinedate.year();
        
        variableMap.put('date', todayStr);
        variableMap.put('name', username);
        variableMap.put('deadline_date', deadlineDateStr);
        // variableMap.put('amounts', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
		// variableMap.put('Tenant_changeover_details', changeoverdetails);
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'EvidenceGatheringTTNotConsentToAGLL', emailsubject);
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
        
    }
    
    @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }

}