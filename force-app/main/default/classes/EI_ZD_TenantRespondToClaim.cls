public without sharing class EI_ZD_TenantRespondToClaim {
    
    @AuraEnabled
    public static list<case> getClaimDetails(String claimId)
    { 
        list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,
                                Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c,Final_Amount_paid__c,
                                Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,External_ID__c,
                                Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                                AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                Claim_exceeds_the_total_level_of_cover__c,Claim_exceeds_comment_AGLL__c,Tenant_obligations__c,
                                inventorycheck_in_report_AGLL__c,check_out_report_AGLL__c,Rent_statement_AGLL__c,Consent_box_AGLL__c,
                                Additional_comments_AGLL__c,Additional_comments_TT__c,Dispute_Initiated_By__c,TT_respond_evidence_gathering__c,
                                AGLL_Respond_Evidance_Gathering__c,Not_reach_an_agreement_Reason_Tenant__c,
                                (select id,Name,Type__c,Contact_Email__c,CheckResponse__c,Is_Lead__c,Contact__r.Name, Contact__r.Phone,Account__r.Tenant_External_ID__c
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
                                 Azure_File_Name__c,User_Type__c,File_Size__c,File_Description__c
                                 from Evidence_Attachments__r) 
                                from case where id=:claimId];
        return caseparti;
    }
    @AuraEnabled
    public static string UpdateClaimDetails(String claimId, String customerType,Decimal amount, String scheme,String claimExternalId )
    {
        string LeadTenantUrl; 
        if(customerType =='AGLL'){
            case  casetoUpdate=  new case(id=claimId,status='Case cancelled',Close_Reason__c='Case Closed',Claim_Agreed_By__c='Agent/Landlord');
            update casetoUpdate;
            LeadTenantUrl ='AGLL';
        }else if(customerType!='AGLL'){
            case currentStatus= [select id,status,TT_Respond_Invitation_to_view_the_claim__c,isclosed from case where id=:claimId limit 1];
            if((currentStatus.TT_Respond_Invitation_to_view_the_claim__c && currentStatus.status=='Invitation to view the claim')|| currentStatus.isclosed)
            {
              LeadTenantUrl= 'Someone has already respond to this claim';  
            }
            else
            {
                case  casetoUpdate=  new case(id=claimId,status='Case closed - agreement reached',Claim_Agreed_By__c='Tenant',Close_Reason__c='Agreement Reached',Make_Payment_By_Community__c = true);
                
                LeadTenantUrl= MakePayment(claimId,'Tenant',amount,scheme,claimExternalId);
                update casetoUpdate; 
            }
        }
        return LeadTenantUrl;
    }
    @AuraEnabled
    public static string MakePayment(string claimId, String customerType, Decimal amount, String scheme, String claimExternalId)
    {
        String tenantExternalId = [select account.Tenant_External_ID__c  from user where id=:UserInfo.getUserId()].account.Tenant_External_ID__c;
        
        //EI_ZD_PaymentAPI.getperformcallout(claimExternalId, 'Tenant',amount, scheme,UserInfo.getUserId());
        string url = EI_ZD_PaymentAPI.getperformcallout(claimId,claimExternalId, 'Tenant',amount, scheme,tenantExternalId);
        //case  casetoUpdate=  new case(id=claimId,Make_Payment_By_Community__c=true);
        // update casetoUpdate;   
        return url;
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
        try{
            Date dToday = Date.today();
            String dateStr = Date.today().format();
            DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String dateStr1 = dt.format('yyyy-MM-dd');
            return dateStr1;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String UpdateDisputeItem(string disputeItemRec,string depositId, date brwsDate, string CaseparticipantId)
    {
        
        List<Dispute_Item__c> updatedisputeList = (list<Dispute_Item__c>)System.JSON.deserialize(disputeItemRec, list<Dispute_Item__c>.class);
        case currentStatus= [select id,TT_Respond_Invitation_to_view_the_claim__c,isclosed from case where id=:updatedisputeList[0].Dispute__c limit 1]; 
        Savepoint sp = null;
        try{
            sp = Database.setSavepoint();
            if(currentStatus.TT_Respond_Invitation_to_view_the_claim__c || currentStatus.isclosed)
            {
              return 'Someone has already respond to this claim';  
            }
            else
            {
                for (Dispute_Item__c ut:updatedisputeList )
                {
                    ut.Tenant_Response__c= (ut.Agreed_by_Tenant__c==null) ? 0 : ut.Agreed_by_Tenant__c;
                    ut.Adjustment_Percentage_by_TT__c = (ut.Agreed_by_Tenant__c==null) ? 0 : (ut.Agreed_by_Tenant__c *100)/ut.Claimed_by_Landlord__c;
                }
                update updatedisputeList;
                Deposit__c depositrec = new Deposit__c(id=depositId,Tenancy_End_Date_TT__c =brwsDate);
                update depositrec;
                // Date datetoupdate =EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
                case updatecase = new case(id=updatedisputeList[0].Dispute__c,TT_Respond_Invitation_to_view_the_claim__c=true,Status='Self-Resolution', Counter__c=1/*,Respond_Date__c=datetoupdate,IIIrd_Working_Day_SR__c =EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 3)*/);
                EI_ZDCaseTriggerHandler.IsMailExecuted = false;
                update updatecase;
                
                Case_Participant__c cp = new Case_Participant__c(id=CaseparticipantId, Is_Lead__c=checkLeadTenant(updatedisputeList[0].Dispute__c,CaseparticipantId));
                update cp;
                return 'Record successfully updated';
            }
        }
        catch(exception exc)
        {
            Database.rollback(sp);
            return exc.getMessage();
        }
        
        
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
                Map<STring,Case> casePartMap = new  Map<String,Case> ([select id,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,respond_date__c,
                                                                       Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,
                                                                       (select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), 
                                                                       (select id,Contact__r.Email,Contact__r.FirstName,Type__c,Access_Code__c from case_participants__r)
                                                                       from case where id =: claimId]);
                //     Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
                
                case cs = casePartMap.get(claimId);
                String floa ='';
                String sloa ='';
                String postcode='';
                list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
                list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
                if(casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.City__c != null){
                    sloa=casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.City__c;
                    
                }
                if(casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.Street__c != null){
                    floa=casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.Street__c;                    
                }
                if(casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.Street__c != null){
                    postcode=casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.Postal_Code__c;                    
                }
                Map<String,String> var = new Map<String,String>();
                var.put('floa',floa);
                var.put('sloa',sloa);
                var.put('postcode',postcode);
                
                if(cs.Respond_Date__c != null){
                    String  todaysDateStr = cs.Respond_Date__c.Day() + '/' + cs.Respond_Date__c.month() + '/' + cs.Respond_Date__c.year();
                    var.put('date',todaysDateStr);
                    
                }
                list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
                
                for(case_participant__c cp : cs.case_participants__r){
                    
                    if(cp.type__c == 'Tenant'){
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,cs.id,null,label.EI_ZD_LoginURL,'Claim Account');
                        tenantList.add(rec);
                    }
                }
                
                system.debug('agentList'+agentList);
                if(tenantList.size()>0)
                    EI_ZD_EmailUtility.sendEmail('Landlord Response - Review Now - '+floa +', '+sloa, JSON.Serialize(tenantList),var,'ZP13AC5TT','mailJetZD');
                
                // EI_ZD_EmailUtility.sendEmailtoTenantSelfResolution(claimId,'Invite tenant to respond self resolution');
                //send mail once template finalize
                //
                ///**********
            }
            else
            {
                case updatecase = new case(id=claimId,TT_respond_Self_resolution__c=true);
                update updatecase;
                Map<STring,Case> casePartMap = new  Map<String,Case> ([select id,owner.name,Deposit_Account_Number__r.Property__r.Postal_Code__c,respond_date__c,
                                                                       Deposit_Account_Number__r.Property__r.City__c,Deposit_Account_Number__r.Property__r.Street__c,
                                                                       (select id,Claimed_by_Landlord__c,Type__c from Dispute_Items__r), 
                                                                       (select id,Contact__r.Email,Contact__r.FirstName,Type__c,Access_Code__c from case_participants__r)
                                                                       from case where id =: claimId]);
                //     Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
                
                case cs = casePartMap.get(claimId);
                String floa ='';
                String sloa ='';
                String postcode='';
                list<EI_ZD_EmailUtility.recipient> tenantList = new list<EI_ZD_EmailUtility.recipient>();
                list<EI_ZD_EmailUtility.recipient> agentList = new list<EI_ZD_EmailUtility.recipient>();
                if(casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.City__c != null){
                    sloa=casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.City__c;
                    
                }
                if(casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.Street__c != null){
                    floa=casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.Street__c;
                    
                }
                if(casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.Street__c != null){
                  postcode=casePartMap.get(claimId).Deposit_Account_Number__r.Property__r.Postal_Code__c;
                    
                }
                Map<String,String> var = new Map<String,String>();
                var.put('floa',floa);
                var.put('sloa',sloa);
                var.put('postcode',postcode);
                
                if(cs.Respond_Date__c != null){
                    String  todaysDateStr = cs.Respond_Date__c.Day() + '/' + cs.Respond_Date__c.month() + '/' + cs.Respond_Date__c.year();
                    var.put('date',todaysDateStr);
                    
                }
                list<EI_ZD_EmailUtility.recipient> recipientList = new list<EI_ZD_EmailUtility.recipient>();
                
                for(case_participant__c cp : cs.case_participants__r){
                    
                    if(cp.type__c == 'Tenant'){
                        //  EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,newCase.Id,null,label.EI_ZD_LoginURL,'Claim Account');
                        //   tenantList.add(rec);
                    }
                    else {
                        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient(cp.Contact__r.Email,cp.Contact__r.FirstName,claimId,null,label.EI_ZD_AGLLLoginURL+cp.Access_Code__c,'Your Claim');
                        agentList.add(rec);
                    }
                    
                }
                
                system.debug('agentList'+agentList);
                // if(tenantList.size()>0)
                //                    EI_ZD_EmailUtility.sendEmail('Thank You for Responding - Your Agent/Landlord will now Review', JSON.Serialize(tenantList),var,'ZP2AC2TT','mailJetZD');
                if(agentList.size()>0)  
                    EI_ZD_EmailUtility.sendEmail('Your Decision is Needed - Tenant has Responded to Claim on '+floa +', '+sloa, JSON.Serialize(agentList),var,'ZP3AC5AGLL','mailJetZD');
                
                
            }
            
            //EI_ZD_EmailUtility.sendEmailtoLandlordSelfResolution(claimId,'Invite landlord to respond self resolution');
            
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
                                AGLL_Respond_Evidance_Gathering__c,
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
                                 Azure_File_Name__c,User_Type__c,File_Size__c,File_Description__c
                                 from Evidence_Attachments__r)
                                
                                from case where id=:claimId];
        return caseparti;
    }
    @AuraEnabled
    public static string UpdateDisputeItemSelfResolutionAgreement(string cmnts, string claimId)
    {
        case updatecase = new case(id=claimId,Not_reach_an_agreement_Reason_AG_LL__c=cmnts,AGLL_Respond_Self_resolution__c =true);
        update updatecase;
        //  EI_ZD_EmailUtility.sendEmailtoTenantSelfResolution(claimId,'Invite tenant to respond self resolution');
        return 'Record successfully updated';
    }
    @AuraEnabled
    public static string UpdateDisputeItemSelfResolutionAgreementTT(string cmnts, string claimId)
    {
        case updatecase = new case(id=claimId,Not_reach_an_agreement_Reason_Tenant__c=cmnts,TT_respond_Self_resolution__c =true);
        update updatecase;
        // EI_ZD_EmailUtility.sendEmailtoLandlordSelfResolution(claimId,'Invite landlord to respond self resolution');
        return 'Record successfully updated';
    }
    @AuraEnabled
    public static void AgreedByAgent(String claimId)
    {
        case  casetoUpdate=  new case(id=claimId,status='Case closed - agreement reached',Claim_Agreed_By__c='Agent/Landlord',Close_Reason__c='Agreement Reached');
EI_ZDCaseTriggerHandler.IsMailExecuted = false;
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
        case caseToUpdate = new case(id=claimId,Consent_box_TT__c=(consentBox==true) ?'Yes' :'No');
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
    public static boolean  checkLeadTenant(ID caseID,ID Casepartid)
    {
        boolean returnvale = true;
        for(Case_Participant__c c: [select id,No_of_Attempt__c,Is_Active__c,Is_Lead__c 
                                    from Case_Participant__c 
                                    where Case__c=:caseID  ])
        {
            if(c.Is_Lead__c)
            {
                if(c.id ==Casepartid)
                {
                    returnvale = true;
                }
                else
                {
                    returnvale = false;
                }
                
            }
        }
        
        return returnvale;
    }
    
}