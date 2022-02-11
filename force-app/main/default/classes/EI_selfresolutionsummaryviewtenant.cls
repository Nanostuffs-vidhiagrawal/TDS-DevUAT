public without sharing class EI_selfresolutionsummaryviewtenant {
    
    public static Boolean AgreedByCasePar = false;
    //This method is used to get Case and related Dispute Item records and profileName
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
    public Static wrapperClassForCaseAndProfileName getCaseAndDisputeItemDetails(String depositId) {
        
        wrapperClassForCaseAndProfileName wrapperObject = new wrapperClassForCaseAndProfileName();
        
        try {
            wrapperObject.caseObject =  [SELECT Id, Total_Claimed_by_Landlord__c, Claimed_by_Tenant__c,
                                         Respond_Date__c,Not_reach_an_agreement_Reason_Tenant__c,
                                         TT_Made_offer__c,TT_Offer_Amount__c,TT_Offer_Response__c,
                                         AGLL_Offer_Amount__c,AGLL_made_Offer__c,AGLL_Offer_Response__c,
                                         Deposit_Account_Number__c,Deposit_Account_Number__r.Protected_Amount__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                         (SELECT Id, Tenant_Response__c, Claimed_by_Landlord__c,
                                          Agreed_by_AGLL__c,Agreed_by_Tenant__c, Other_Reason__c,
                                          Adjustment_Percentage_by_AGLL__c,
                                          Adjustment_Percentage_by_TT__c, 
                                          Tenant_Statement__c, 
                                          Type__c FROM Dispute_Items__r)
                                             FROM Case where Deposit_Account_Number__c =: depositId AND
                                         (Status= 'Repayment disputed - self-resolution' OR (Status = 'On Hold'  AND  PreviousStatus__c ='Repayment disputed - self-resolution')) Limit 1]; 
            
            wrapperObject.profileName = [Select Id,ProfileId,Profile.Name FROM User where Id =: userInfo.getUserId()]?.Profile?.Name;
            
            return wrapperObject;
            
        }catch(Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static void createPaymentAndInstalmentsRecord(Case CaseInst,Decimal protectedamount) {
        
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Map<Id,Case_Participant__c> mapOfCasIdVsCasPart = new Map<Id,Case_Participant__c>([SELECT Id,Contact__r.Name,Case__r.Total_Agreed_by_AG_LL__c,Case__r.Total_Agreed_by_Tenant__c, Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c, Type__c,Case__r.Disputed_Amount__c, Case__r.Status ,Case__r.Deposit_Account_Number__c,Case__r.Deposit_Account_Number__r.Name,Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,  Contact__r.Email,Contact__r.FirstName,Contact__r.LastName,Case__r.Tenancy_Property_Address__c,  Account__c, Contact__c,Payable_Amount__c FROM Case_Participant__c where Case__c =: CaseInst.Id]);
        Set<String> ContactIds = new Set<String>();
        List<Payment__c> paymentToCreate = new List<Payment__c>();
        Map<Id,Installment__c> mapOfContactIdVsInst = new Map<Id,Installment__c>();
        Integer countTT = 0 ,countLL = 0;
        for(Case_Participant__c casePar : mapOfCasIdVsCasPart.values()){
            ContactIds.add(casePar.Contact__c);
            if(casePAr.Type__c == 'Tenant'){
                countTT++;
            }else{
                countLL++;
            }
        }
        
        MAp<String,Bank_Account__c> mapOFContactIdVsBankDet = EI_TenantRespondToRepayment.getBanKDetails(ContactIds);
        String jsonBody;
        String jsonBodyForBD;
        String SDSEmail = 'ashish.singh1@espire.com';
        try{
            
            for(Case_Participant__c casePAr : mapOfCasIdVsCasPart.values()){
                
                Installment__c Installmentrec = new Installment__c();
                Installmentrec.Contact__c =casePAr.Contact__c;
                Installmentrec.Created_at__c= date.today();
                Installmentrec.Credit_note_reference__c =null;
                Installmentrec.Payment_reference__c =null;//paymentReference
                Installmentrec.Deposit__c =CaseInst.Deposit_Account_Number__c;                                                                 
                Installmentrec.Case__c =CaseInst.Id; 
                Installmentrec.Status__c= 'Pending processing';
                Date daysCompletionDate = EI_UtilityClassForPayments.dueDateMethod(casePAr.Case__r.Deposit_Account_Number__r.Payment_Received_By_Scheme__c,30);
                if(daysCompletionDate != null){
                    Installmentrec.X30_Days_Completion_Date__c = daysCompletionDate;
                }
                Installmentrec.Due_Date__c = EI_UtilityClassForPayments.dueDateMethod(date.today(), 5);
                Installmentrec.Installment_Type__c = 'Payable';
                
                // when repayment adjustment agreed by tenant //
                if(CaseInst.Claim_Agreed_By__c =='Tenant'){
                    if(casePAr.Type__c == 'Tenant'){
                        Installmentrec.Amount__c = (protectedamount - CaseInst.Total_Agreed_by_AG_LL__c)/countTT;
                        system.debug('line-->78');
                        //  jsonBody = getJSONBODYofLLOrTT(casePAr,SDSEmail,(CaseInst.Total_Agreed_by_AG_LL__c - CaseInst.Total_Agreed_by_Tenant__c));
                        
                        SelfresRepaymentAgreedbyTTMail( casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c);
                        emailWrapperList.add(SelfresRepaymentAgreedbyTTMail( casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c));
                    }else{
                        system.debug('line-->81');
                        Installmentrec.Amount__c = CaseInst.Total_Agreed_by_AG_LL__c;
                        
                        SelfresRepaymentAgreedbyTTMail(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c);
                        emailWrapperList.add(SelfresRepaymentAgreedbyTTMail( casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c));
                        //jsonBody = getJSONBODYofLLOrTT(casePAr,SDSEmail,(CaseInst.Total_Agreed_by_AG_LL__c - CaseInst.Total_Agreed_by_Tenant__c));
                    }
                }
                
                // When repayment adjustment agreed by agent//
                else if (CaseInst.Claim_Agreed_By__c =='Agent/Landlord'){
                    if(casePAr.Type__c == 'Tenant'){
                        Installmentrec.Amount__c = (protectedamount - CaseInst.Total_Agreed_by_Tenant__c)/countTT;
                        SelfresRepaymentAgreedbyAgll(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c);
                        emailWrapperList.add(SelfresRepaymentAgreedbyAgll(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c));
                        //jsonBody = getJSONBODYofLLOrTT(casePAr,SDSEmail,(CaseInst.Total_Agreed_by_AG_LL__c - CaseInst.Total_Agreed_by_Tenant__c));
                    }else{
                        Installmentrec.Amount__c = CaseInst.Total_Agreed_by_Tenant__c;
                        //jsonBody = getJSONBODYofLLOrTT(casePAr,SDSEmail,(CaseInst.Total_Agreed_by_AG_LL__c - CaseInst.Total_Agreed_by_Tenant__c));
                        SelfresRepaymentAgreedbyAgll(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c);
                        emailWrapperList.add(SelfresRepaymentAgreedbyAgll(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c));
                    }
                }
                
                // when Offer accepted by agent //
                else if(CaseInst.TT_Made_offer__c == true && CaseInst.TT_Offer_Response__c=='Accept'){
                    if(casePAr.Type__c == 'Tenant'){
                        Installmentrec.Amount__c = (protectedamount - CaseInst.AGLL_Offer_Amount__c)/countTT;
                        // jsonBody = getJSONBODYofLLOrTT(casePAr,SDSEmail,(CaseInst.Total_Agreed_by_AG_LL__c - CaseInst.Total_Agreed_by_Tenant__c));
                        SelfresOfferAcceptedbyAGLLMail(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c);
                        emailWrapperList.add(SelfresOfferAcceptedbyAGLLMail(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c));
                    }else{
                        Installmentrec.Amount__c = CaseInst.AGLL_Offer_Amount__c;
                        // jsonBody = getJSONBODYofLLOrTT(casePAr,SDSEmail,(CaseInst.Total_Agreed_by_AG_LL__c - CaseInst.Total_Agreed_by_Tenant__c));
                        SelfresOfferAcceptedbyAGLLMail(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c);
                        emailWrapperList.add(SelfresOfferAcceptedbyAGLLMail(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c));
                    }
                }
                
                // when Offer accepted by Tenant //
                else if(CaseInst.AGLL_made_Offer__c == true && CaseInst.AGLL_Offer_Response__c=='Accept'){
                    if(casePAr.Type__c == 'Tenant'){
                        Installmentrec.Amount__c = (protectedamount - CaseInst.TT_Offer_Amount__c)/countTT;
                        //  jsonBody = getJSONBODYofLLOrTT(casePAr,SDSEmail,(CaseInst.Total_Agreed_by_AG_LL__c - CaseInst.Total_Agreed_by_Tenant__c));
                        SelfresOfferAcceptedbyTTMail(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.TT_Offer_Amount__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c);
                        emailWrapperList.add(SelfresOfferAcceptedbyTTMail(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.TT_Offer_Amount__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c));
                        
                    }else{
                        Installmentrec.Amount__c = CaseInst.TT_Offer_Amount__c;
                        //jsonBody = getJSONBODYofLLOrTT(casePAr,SDSEmail,(CaseInst.Total_Agreed_by_AG_LL__c - CaseInst.Total_Agreed_by_Tenant__c));
                        SelfresOfferAcceptedbyTTMail(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.TT_Offer_Amount__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c);
                        emailWrapperList.add(SelfresOfferAcceptedbyTTMail(casePAr.Contact__r.Email,casePAr.Contact__r.Name,casePAr.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,CaseInst.TT_Offer_Amount__c,CaseInst.Id,casePAr.Contact__c,casePAr.Account__c));
                    }
                }
                
                else{
                    
                    
                }
                
                
                if(mapOFContactIdVsBankDet.containsKey(casePAr.Contact__c)){
                    if(!mapOFContactIdVsBankDet.get(casePAr.Contact__c).ValidInternationBankDetails__c){
                        //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                        Installmentrec.Bank_account_holder_name__c=mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Account_Holder_Name__c;
                        Installmentrec.Bank_account_number__c =mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Account_Number__c;
                        Installmentrec.Bank_name__c =mapOFContactIdVsBankDet.get(casePAr.Contact__c).International_Bank_Name__c;
                        Installmentrec.Custom_Account_Number__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).IBAN__c;
                        Installmentrec.Swift_Code__c = 	mapOFContactIdVsBankDet.get(casePAr.Contact__c).Swift_Code__c; //International bank details (Swift Code)
                        Installmentrec.BIC__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).BIC__c;
                        Installmentrec.International_Payment__c = true;
                    }else{
                        //Installmentrec.Payee_name__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Contact__r.name;
                        Installmentrec.Bank_account_holder_name__c=mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Account_Holder_Name__c;
                        Installmentrec.Bank_account_number__c =mapOFContactIdVsBankDet.get(casePAr.Contact__c).Account_Number__c;
                        Installmentrec.Bank_sort_code__c = mapOFContactIdVsBankDet.get(casePAr.Contact__c).Sort_Code__c;                                                                 
                        Installmentrec.Bank_name__c =mapOFContactIdVsBankDet.get(casePAr.Contact__c).Bank_Name__c;
                        Installmentrec.International_Payment__c = false;
                    }
                }else{
                    if(casePAr.Type__c == 'Tenant'){
                   //     jsonBodyForBD = getJSONBODYforNoBankDetails(casePAr,SDSEmail);  
                    }
                    
                }
                mapOfContactIdVsInst.put(casePAr.Contact__c,Installmentrec);   
                if(String.isNotBlank(jsonBodyForBD)){
                  //  EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo1(jsonBodyForBD); 
                }
               // if(String.isNotBlank(jsonBody))
               //     EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo1(JsonBody);                                                                
            }
            
            if(!mapOfContactIdVsInst.isEmpty()){
                insert mapOfContactIdVsInst.values();
            }
            
            EI_selfresolutionsummaryviewtenant.AgreedByCasePar = true;
            update CaseInst;
            
            if(!mapOfContactIdVsInst.isEmpty()){
                Deposit__c depobj =  new deposit__c ();  
                depobj.Id = CaseInst.Deposit_Account_Number__c;
                depobj.Status__c ='Repayment process';
                update depobj;
            }
            if(emailWrapperList.size()>0){
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
            }
            
        }catch(DmlException exp){
            String msg;
            for (Integer i = 0; i < exp.getNumDml(); i++) {
                msg =+ exp.getDmlMessage(i) +  '\n' ;
            }
            throw new AuraHandledException(msg);
        }
        
    }
    
    @AuraEnabled
    public static void makeAdjustments(Case caseInst, String disputeItems, string profileName) {
        
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();   
        string Updatedtenantfigure ='<table>';
        string UpdatedAGLLfigure ='<table>';
        
        try {
            Type disList = Type.forName('List<Dispute_Item__c>');
            List<Dispute_Item__c> disputeItemss = (List<Dispute_Item__c>) JSON.deserialize(disputeItems, disList);
            update caseInst;
            update disputeItemss;
            MAp<Id,Case_Participant__c> mapOfIdVsCasePAr =  EI_getSObjectData.getCasePart(new set<Id>{caseInst.Id}); 
            list<case> alldatalist = [SELECT Id, Total_Claimed_by_Landlord__c, Claimed_by_Tenant__c,
                                      Respond_Date__c,Not_reach_an_agreement_Reason_Tenant__c,Days_Remaining__c,
                                      TT_Made_offer__c,TT_Offer_Amount__c,TT_Offer_Response__c,
                                      AGLL_Offer_Amount__c,AGLL_made_Offer__c,AGLL_Offer_Response__c,
                                      Deposit_Account_Number__c,Deposit_Account_Number__r.Protected_Amount__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                      (SELECT Id, Tenant_Response__c, Claimed_by_Landlord__c,
                                       Agreed_by_AGLL__c,Agreed_by_Tenant__c, Other_Reason__c,
                                       Adjustment_Percentage_by_AGLL__c,
                                       Adjustment_Percentage_by_TT__c,
                                       Type__c FROM Dispute_Items__r)
                                      FROM Case where id=:caseInst.Id limit 1];
             integer Remainingworkingdays = EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(system.today(),alldatalist[0].Respond_Date__c);
            for(Dispute_Item__c dispitem1 : alldatalist[0].Dispute_Items__r) {
                Updatedtenantfigure+= '<tr>';
                Updatedtenantfigure+= '<td>'+dispitem1.Type__c+':'+'<td>';
                Updatedtenantfigure+= '<td>'+'£'+dispitem1.Agreed_by_Tenant__c+'<td>';
                Updatedtenantfigure+= '</tr>';
            }
            Updatedtenantfigure+= '</table><br/><br/>';
            
            for(Dispute_Item__c dispitem2: alldatalist[0].Dispute_Items__r) {
                UpdatedAGLLfigure+= '<tr>';
                UpdatedAGLLfigure+= '<td>'+dispitem2.Type__c+':'+'<td>';
                UpdatedAGLLfigure+= '<td>'+'£'+dispitem2.Agreed_by_AGLL__c+'<td>';
                UpdatedAGLLfigure+= '</tr>';
            }
            UpdatedAGLLfigure+= '</table><br/><br/>';
            if((profileName =='Tenant')){
                for(Case_Participant__c caspar1 :mapOfIdVsCasePAr.values()){
                    if(caspar1.Type__c =='Tenant'){
                        system.debug('line 243' + alldatalist[0].Days_Remaining__c);
                       
                        SelfresRepaymentUpdateByTTToTT(caspar1.Contact__r.Email,caspar1.Contact__r.Name,caspar1.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Remainingworkingdays,Updatedtenantfigure,caseInst.Id,caspar1.Contact__c,caspar1.Account__c);      
                        emailWrapperList.add(SelfresRepaymentUpdateByTTToTT(caspar1.Contact__r.Email,caspar1.Contact__r.Name,caspar1.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Remainingworkingdays,Updatedtenantfigure,caseInst.Id,caspar1.Contact__c,caspar1.Account__c));     
                    } 
                    if(caspar1.Type__c !='Tenant'){
                        system.debug('line 249' + alldatalist[0].Days_Remaining__c);
                        SelfresRepaymentUpdateByTTToAGLL(caspar1.Contact__r.Email,caspar1.Contact__r.Name,caspar1.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Remainingworkingdays,UpdatedAGLLfigure,caseInst.Id,caspar1.Contact__c,caspar1.Account__c);    
                        emailWrapperList.add(SelfresRepaymentUpdateByTTToAGLL(caspar1.Contact__r.Email,caspar1.Contact__r.Name,caspar1.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Remainingworkingdays,Updatedtenantfigure,caseInst.Id,caspar1.Contact__c,caspar1.Account__c));
                    }
                }   
            }
            else{
                for(Case_Participant__c caspar2 :mapOfIdVsCasePAr.values()){
                    if(caspar2.Type__c =='Tenant'){
                        system.debug('line 243' + alldatalist[0].Days_Remaining__c);
                        SelfresRepaymentUpdateByAGLLToTT(caspar2.Contact__r.Email,caspar2.Contact__r.Name,caspar2.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Remainingworkingdays,UpdatedAGLLfigure,caseInst.Id,caspar2.Contact__c,caspar2.Account__c);
                        emailWrapperList.add(SelfresRepaymentUpdateByAGLLToTT(caspar2.Contact__r.Email,caspar2.Contact__r.Name,caspar2.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Remainingworkingdays,UpdatedAGLLfigure,caspar2.Id,caspar2.Contact__c,caspar2.Account__c));     
                        
                    } 
                    if(caspar2.Type__c !='Tenant'){
                        system.debug('line 249' + alldatalist[0].Days_Remaining__c);
                        SelfresRepaymentUpdateByAGLLToAGLL(caspar2.Contact__r.Email,caspar2.Contact__r.Name,caspar2.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Remainingworkingdays,UpdatedAGLLfigure,caseInst.Id,caspar2.Contact__c,caspar2.Account__c);
                       // emailWrapperList.add(SelfresRepaymentUpdateByAGLLToAGLL(caspar2.Contact__r.Email,caspar2.Contact__r.Name,caspar2.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,alldatalist[0].Days_Remaining__c,Updatedtenantfigure,caseInst.Id,caspar2.Contact__c,caspar2.Account__c));
                        emailWrapperList.add(SelfresRepaymentUpdateByAGLLToAGLL(caspar2.Contact__r.Email,caspar2.Contact__r.Name,caspar2.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Remainingworkingdays,UpdatedAGLLfigure,caseInst.Id,caspar2.Contact__c,caspar2.Account__c));
                    }
                }      
                
            }
            if(emailWrapperList.size()>0){
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
            }     
            
        } catch(DmlException exp) {
            String msg;
            for (Integer i = 0; i < exp.getNumDml(); i++) {
                msg =+ exp.getDmlMessage(i) +  '\n' ;
            }
            throw new AuraHandledException(msg);
        }
    }

    @AuraEnabled
    public static void updateCaseFields(Case caseInst,string profileName,String operation,Decimal offeramount) {
        
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        system.debug('line--188' + caseInst );
        system.debug('line--290' + operation );
        system.debug('line--315' + offeramount );
        user ust = [select id,Profile.Name from user where id=:UserInfo.getUserId()];
        // system.debug('line--291' + operation );
        // system.debug('line--188' + ust.Profile.Name );
        try{
            update caseInst;
            
            Integer countTT = 0;
            Integer countLL = 0;
            MAp<Id,Case_Participant__c> mapOfIdVsCasePAr =  EI_getSObjectData.getCasePart(new set<Id>{caseInst.Id});
            for(Case_Participant__c casPar :mapOfIdVsCasePAr.values()){
                if(casPar.Type__c == 'Tenant'){
                    //  if(ust.Profile.Name == 'Tenant'){
                    countTT++;
                }else{
                    countLL++;
                }
            }
            String SDSEmail = 'ashish.singh1@espire.com';
            for(Case_Participant__c casPar :mapOfIdVsCasePAr.values()){
                String JsonBody = '';
                if(ust.Profile.Name == 'Tenant' /*&& profileName == 'Tenant'*/){
                    system.debug('line--245'  );
                    if(operation=='cancelOffer'){
                        system.debug('line--246'  ); 
                        SelfresSelfOfferCancelbyTTMail(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c);    
                        emailWrapperList.add(SelfresSelfOfferCancelbyTTMail(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));
                    } 
                    
                    
                    if (operation=='OfferMade'){
                        if((casPar.Type__c=='Landlord' ||casPar.Type__c=='Agent')){   
                            SelfresOfferMadeByTTMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c);    
                            emailWrapperList.add(SelfresOfferMadeByTTMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));
                            
                        }
                        if((casPar.Type__c=='Tenant')){  
                            if(casPar.Is_Lead__c==true){
                                SelfresOfferMadeByTTMailToLeadTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c); 
                                emailWrapperList.add(SelfresOfferMadeByTTMailToLeadTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));    
                            }
                            else{
                                SelfresOfferMadeByTTMailToOtherTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c);
                                emailWrapperList.add(SelfresOfferMadeByTTMailToOtherTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));
                                //SelfresOfferMadeByAGLLMailToOtherTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c);   
                                //  emailWrapperList.add(SelfresOfferMadeByAGLLMailToOtherTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c));     
                            }
                        }
                        
                    }
                    
                    if (operation=='OfferRejected'){
                        system.debug('line-->367');
                        if((casPar.Type__c=='Landlord' ||casPar.Type__c=='Agent')){ 
                        SelfresOfferRejectedByTenantMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name, casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount, 
                                                                                                 casPar.Case__c,casPar.Contact__c ,casPar.Account__c); 
                        emailWrapperList.add(SelfresOfferRejectedByTenantMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name, casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount, 
                                                                                                 casPar.Case__c,casPar.Contact__c ,casPar.Account__c));
                        }
                        if((casPar.Type__c=='Tenant')){  
                            
                            if(casPar.Is_Lead__c==true){
                            SelfresOfferRejectedByTenantMailToLeadTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, 
                                                                     offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c);    
                            emailWrapperList.add(SelfresOfferRejectedByTenantMailToLeadTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, 
                                                                     offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));
                            }
                            else{
                            SelfresOfferRejectedByTenantMailToOthrTT(casPar.Contact__r.email,casPar.Contact__r.Name, casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, 
                                                                     offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c); 
                            emailWrapperList.add(SelfresOfferRejectedByTenantMailToOthrTT(casPar.Contact__r.email,casPar.Contact__r.Name, casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c, 
                                                                     offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));
                            }
                        }
                    }
                    //  if(caseInst.AGLL_Offer_Amount__c!=null && countLL > 0 ){
                    //      Decimal amount = countLL != 0 ? caseInst.AGLL_Offer_Amount__c/countLL : 0;}
                    
                    // send mail to landlord
                    /*if(operation == 'OfferMade'){
JsonBody = getJSONBODYforOfferN(casPar,SDSEmail);
}else{
if(operation == 'OfferRejected')
JsonBody = getJSONBODYforOfferR(casPar,SDSEmail);
}*/
                    
                    
                    //   JsonBody = getJSONBODYForOfferRAC(casPar,SDSEmail,operation);
                    
                }else{
                    
                    if(operation=='cancelOffer'){
                        if((casPar.Type__c=='Landlord' ||casPar.Type__c=='Agent')){
                            system.debug('line-->270');
                            SelfresSelfOfferCancelbyAGLLMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c);
                            emailWrapperList.add(SelfresSelfOfferCancelbyAGLLMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c)); 
                        }  
                        
                        if(casPar.Type__c=='Tenant'){
                            system.debug('line-->276');
                            SelfresSelfOfferCancelbyAGLLMailToTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c);     
                            emailWrapperList.add(SelfresSelfOfferCancelbyAGLLMailToTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));    
                        }
                    }
                    if(operation=='OfferRejected'){
                        if((casPar.Type__c=='Landlord' ||casPar.Type__c=='Agent')){
                            system.debug('line-->283');
                            SelfresSelfOfferRejectedByAGLLMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c);
                            emailWrapperList.add(SelfresSelfOfferRejectedByAGLLMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c)); 
                        }
                        if((casPar.Type__c=='Tenant')){
                            string subject;
                            if(casPar.Is_Lead__c==true){
                                subject ='Your offer was declined';
                            }
                            else{
                                subject ='Tenant(s) offer was declined';    
                            }
                            system.debug('line-->295');
                            SelfresSelfOfferRejectedByAGLLMailToTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,subject,casPar.Contact__c,casPar.Account__c);
                            emailWrapperList.add(SelfresSelfOfferRejectedByAGLLMailToTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,subject,casPar.Contact__c,casPar.Account__c)); 
                        }
                        
                    }
                    
                    
                    if (operation=='OfferMade'){
                        if((casPar.Type__c=='Landlord' ||casPar.Type__c=='Agent')){   
                            SelfresOfferMadeByAGLLMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c); 
                            emailWrapperList.add(SelfresOfferMadeByAGLLMailToAGLL(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));
                        }
                        if((casPar.Type__c=='Tenant')){  
                            if(casPar.Is_Lead__c==true){
                                SelfresOfferMadeByAGLLMailToLeadTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c);   
                                emailWrapperList.add(SelfresOfferMadeByAGLLMailToLeadTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));    
                            }
                            else{
                                SelfresOfferMadeByAGLLMailToOtherTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c);   
                                emailWrapperList.add(SelfresOfferMadeByAGLLMailToOtherTT(casPar.Contact__r.email,casPar.Contact__r.Name,casPar.Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,offeramount,casPar.Case__c,casPar.Contact__c,casPar.Account__c));     
                            }
                        }
                        
                    }
                    //   if(caseInst.TT_Offer_Amount__c!=null && countTT > 0 ){
                    //   Decimal amount = countLL != 0 ? caseInst.TT_Offer_Amount__c/countTT : 0;
                    //   }
                    
                    
                    //    else{
                    // caseInst.TT_Offer_Amount__c=0;
                    //   }
                    
                    
                    // send mail to tenant
                    /*if(operation == 'OfferMade'){
JsonBody = getJSONBODYforOfferN(casPar,SDSEmail);
}else{
if(operation == 'OfferRejected')
JsonBody = getJSONBODYforOfferR(casPar,SDSEmail);
}*/
                    //  JsonBody = getJSONBODYForOfferRAC(casPar,SDSEmail,operation);
                    
                }
                // EI_EvidenceGatheringMails.evidenceGatheringSendEmailsTo1(JsonBody);
            }
            if(emailWrapperList.size()>0){
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
            }
            
        }catch(DmlException exp){
            String msg;
            for (Integer i = 0; i < exp.getNumDml(); i++) {
                msg =+ exp.getDmlMessage(i) +  '\n' ;
            }
            throw new AuraHandledException(msg);
        }
    }    
    
    public static String getJSONBODYforOfferN(Case_Participant__c castInst,String SDSEmail) {
        
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
        gen.writeStringField('Subject', 'Confirmation of offer - : '+firstLine);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        /* gen.writeStringField('LandlordName', castInst.Contact__r.Name);
gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__c);
gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
gen.writeStringField('DisputeAmount', String.valueOf(castInst.Case__r.Disputed_Amount__c));
Date DueDateforEvidence = System.today().adddays(10);
gen.writeStringField('DueDateforEvidence',String.valueOf(DueDateforEvidence));*/ 
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    public static String getJSONBODYForOfferRAC(Case_Participant__c castInst,String SDSEmail,String offer) {
        
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
        if(offer == 'OfferRejected'){
            gen.writeStringField('Subject', 'Confirmation - offer rejected - : '+firstLine);
        }
        if(offer == 'OfferMade'){
            gen.writeStringField('Subject', 'Confirmation of offer - : '+firstLine);
        }
        if(offer == 'cancelOffer'){
            gen.writeStringField('Subject', 'offer was declined - : '+firstLine);
        }
        
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
       	gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
        if(String.isNotBlank(String.valueOf(castInst.Case__r.Disputed_Amount__c)))
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
    
    //Wrapper class for return case and profile name 
    public class wrapperClassForCaseAndProfileName {
        
        @AuraEnabled
        public Case caseObject {get;set;}
        @AuraEnabled
        public String profileName {get;set;}
    }
    
    public static String getJSONBODYofLLOrTT(Case_Participant__c castInst,String SDSEmail,Decimal disputedAmount) {
        
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
        gen.writeStringField('Subject', 'Deposit repayment agreed : '+firstLine);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        if(castInst.Case__r.Deposit_Account_Number__c != null)
            gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        if(castInst.Case__r.Tenancy_Property_Address__c != null)    
            gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
        
        gen.writeStringField('DisputeAmount', String.valueOf(disputedAmount));
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
    
    public static String getJSONBODYforNoBankDetails(Case_Participant__c castInst,String SDSEmail) {
        
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
        gen.writeStringField('Subject', 'Deposit repayment - please update your payment details.');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('LandlordName', castInst.Contact__r.Name);
        if(castInst.Case__r.Deposit_Account_Number__c != null)
            gen.writeStringField('DAN_Number', castInst.Case__r.Deposit_Account_Number__r.Name);
        if(castInst.Case__r.Tenancy_Property_Address__c != null)    
            gen.writeStringField('PropertyAddress', castInst.Case__r.Tenancy_Property_Address__c);
        
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        return jsonData;
        
    }
    
    
    // When tenant agreed to repayment of AGLL during self resolution email to Tenants & AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresRepaymentAgreedbyTTMail(string useremail,string username,String propaddress, 
                                                                                       String caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit repayment agreed-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresRepaymentAgreedbyTTMail');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid != null){
        CustomerId = contactid;   
        }
        else{
        CustomerId = accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        /*variableMap.put('DAN', dannumber);
        variableMap.put('Address', propaddress);
        variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresRepaymentAgreedbyTTMail', emailsubject);    
        return EmailWrapper;
    }
    
    // When AGLL agreed to repayment of Tenant during self resolution email to Tenants & AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresRepaymentAgreedbyAgll(string useremail,string username,String propaddress, 
                                                                                     string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit repayment agreed-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresRepaymentAgreedbyAgll');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid!=null){
        CustomerId = contactid;   
        }
        else{
        CustomerId = accountid;     
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        /*  variableMap.put('DAN', dannumber);
        variableMap.put('Address', propaddress);
        variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresRepaymentAgreedbyAgll', emailsubject);    
        return EmailWrapper;
    }
    
    // When Tenant  accept offer of  AGLL during self resolution email to Tenants & AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferAcceptedbyTTMail(string useremail,string username,String propaddress, 
                                                                                     Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit repayment agreed-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferAcceptedbyTTMail');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
         CustomerId = contactid;   
        }
        else{
         CustomerId = accountid;   
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferAcceptedbyTTMail', emailsubject);    
        return EmailWrapper;
    }
    
    // When AGLL  accept offer of  Tenant during self resolution email to Tenants & AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferAcceptedbyAGLLMail(string useremail,string username,String propaddress, 
                                                                                       string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit repayment agreed-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferAcceptedbyAGLLMail');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
        CustomerId = contactid;  
        }
        else{
        CustomerId = accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        //  variableMap.put('amounts', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferAcceptedbyAGLLMail', emailsubject);    
        return EmailWrapper;
    }
    
    // When Tenant cancel  his offer to AGLL during self resolution email to Tenants & AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresSelfOfferCancelbyTTMail(string useremail,string username,String propaddress, 
                                                                                       Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant Offer Cancelled-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresSelfOfferCancelbyTTMail');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
        CustomerId =contactid; 
        }
        else{
        CustomerId =accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresSelfOfferCancelbyTTMail', emailsubject);    
        return EmailWrapper;
    }
    
    // When Agent cancel  his offer to Tenant during self resolution email to  AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresSelfOfferCancelbyAGLLMailToAGLL(string useremail,string username,String propaddress, 
                                                                                               Decimal offeramount,string caseid,string contactid, string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Confirmation of cancellation of your offer-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresSelfOfferCancelbyAGLLMailToAGLL');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
        CustomerId = contactid;    
        }
        else{
        CustomerId = accountid;  
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresSelfOfferCancelbyAGLLMailToAGLL', emailsubject);    
        return EmailWrapper;
    }
    
    // When Agent cancel  his offer to Tenant during self resolution email to  Tenants
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresSelfOfferCancelbyAGLLMailToTT(String useremail,string username,String propaddress, 
                                                                                             Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Agent/ landlord has cancelled their offer-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresSelfOfferCancelbyAGLLMailToTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
        CustomerId = contactid;    
        }
        else{
        CustomerId = accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresSelfOfferCancelbyAGLLMailToTT', emailsubject);    
        return EmailWrapper;
    }
    
    // When AGLL Reject  offer of Tenant during self resolution email to  AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresSelfOfferRejectedByAGLLMailToAGLL(string useremail,string username, 
                                                                                                 String propaddress,Decimal offeramount, 
                                                                                                 string caseid,string contactid ,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Confirmation - offer rejected-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresSelfOfferRejectedByAGLLMailToAGLL');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
        CustomerId = contactid;     
        }
        else{
        CustomerId =accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresSelfOfferRejectedByAGLLMailToAGLL', emailsubject);    
        return EmailWrapper;
    }
    
    // When AGLL Reject  offer of Tenant during self resolution email to  Tenants
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresSelfOfferRejectedByAGLLMailToTT(string useremail,string username, String propaddress, 
                                                                                               Decimal offeramount,string caseid,string mailsubject,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = mailsubject+'-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresSelfOfferRejectedByAGLLMailToTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
         CustomerId = contactid;  
        }
        else{
          CustomerId =  accountid;
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresSelfOfferRejectedByAGLLMailToTT', emailsubject);    
        
        
        Return EmailWrapper;
    }
    
    // When TT update  repayments during self resolution email to  Tenants
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresRepaymentUpdateByTTToTT(string useremail,string username,String propaddress, 
                                                                                       Decimal remainingday,string tenantdata,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Confirmation - repayment request update -'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresRepaymentUpdateByTTToTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
         CustomerId =contactid;
        }
        else{
         CustomerId = accountid;  
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', tenantdata);
        variableMap.put('working_day_remaining', String.valueOf(remainingday));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresRepaymentUpdateByTTToTT', emailsubject);    
        return EmailWrapper;
    }
    
    // When TT update  repayments during self resolution email to  AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresRepaymentUpdateByTTToAGLL(string useremail,string username,String propaddress, 
                                                                                         Decimal remainingday,string tenantdata,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant(s) has updated their repayment request -'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresRepaymentUpdateByTTToAGLL');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
         CustomerId = contactid;   
        }
        else{
         CustomerId = accountid;   
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', tenantdata);
        variableMap.put('working_days_left', String.valueOf(remainingday));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresRepaymentUpdateByTTToAGLL', emailsubject);    
		return EmailWrapper;
        
    }
    
    // When AGLl update  repayments during self resolution email to  AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresRepaymentUpdateByAGLLToAGLL(string useremail,string username,String propaddress, 
                                                                                           Decimal remainingday,string aglldata,string caseid,string contactid,string accountid ) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Confirmation - repayment request update -'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresRepaymentUpdateByAGLLToAGLL');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid!=null){
        CustomerId = contactid;   
        }
        else{
        CustomerId =  accountid;  
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', aglldata);
        variableMap.put('working_days_left', String.valueOf(remainingday));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresRepaymentUpdateByAGLLToAGLL', emailsubject);    
        return EmailWrapper;
        
    }
    
    // When AGLl update  repayments during self resolution email to  TT
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresRepaymentUpdateByAGLLToTT(string useremail,string username,String propaddress, 
                                                                                         Decimal remainingday,string aglldata,string caseid,string contactid,string accountid) 
    { 
        system.debug('line-->1280' + aglldata );
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Agent/landlord has updated their repayment request -'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresRepaymentUpdateByAGLLToTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        
        if(contactid!=null){
        CustomerId = contactid;   
        }
        else{
        CustomerId = accountid;      
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        system.debug('line-->1310' + aglldata );
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('amounts', aglldata);
        variableMap.put('days_remaining', String.valueOf(remainingday));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresRepaymentUpdateByAGLLToTT', emailsubject);    
        return EmailWrapper;
    }
    
    // When AGLL Make  offer of Tenant during self resolution email to  AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferMadeByAGLLMailToAGLL(string useremail,string username,String propaddress, 
                                                                                         Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Confirmation of offer-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferMadeByAGLLMailToAGLL');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid!=null){
         CustomerId = contactid;
        }
        else{
          CustomerId = accountid;   
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('first_line_of_address', propaddress);
        variableMap.put('offer_details', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferMadeByAGLLMailToAGLL', emailsubject);    
        return EmailWrapper;
    }
    
    // When AGLL Make  offer of Tenant during self resolution email to  othertenants
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferMadeByAGLLMailToOtherTT(string useremail,string username,String propaddress, 
                                                                                            Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Agent/landlord has made an offer-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferMadeByAGLLMailToOtherTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        
        if(contactid !=null){
            CustomerId =  contactid;  
        }
        else{
            CustomerId = accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('first_line_of_address', propaddress);
        variableMap.put('offer_details', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferMadeByAGLLMailToOtherTT', emailsubject);    
        return EmailWrapper;
    }
    
    // When AGLL Make  offer of Tenant during self resolution email to  leadtenant
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferMadeByAGLLMailToLeadTT(string useremail, string username, String propaddress, 
                                                                                           Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String responsebutton;
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Agent/landlord has made an offer-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferMadeByAGLLMailToLeadTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        responsebutton ='<a style="background-color: #457cbf;color: #fff;font-size: 1rem;text-transform: initial;padding-top: 0.5rem;padding-bottom: 0.5rem;padding-left: 0.5rem; padding-right: 0.5rem; display: inline-block; outline: 0!important; text-decoration: none!important; text-align: center; width: 220px; border-radius: 3rem;"  href="https://staging-thedisputeservice.cs122.force.com/Sds/s/">Respond to offer</a>';
       
        if(contactid !=null){
        CustomerId =  contactid;  
        }
        else{
        CustomerId = accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('first_line_of_address', propaddress);
        variableMap.put('offer_details', string.valueof(offeramount));
        variableMap.put('respond_to_offer', responsebutton);
        //    variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferMadeByAGLLMailToLeadTT', emailsubject);    
        return EmailWrapper;
    }
    
    // When Tenant Make  offer of AGLL during self resolution email to  Leadtenant
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferMadeByTTMailToLeadTT(string useremail,string username,String propaddress, 
                                                                                         Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Confirmation of offer-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferMadeByTTMailToLeadTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
        CustomerId = contactid;    
        }
        else{
        CustomerId = accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('first_line_of_address', propaddress);
        variableMap.put('offer_details', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferMadeByTTMailToLeadTT', emailsubject);    
        return EmailWrapper;
    }
    
    // When Tenant Make  offer of AGLL during self resolution email to  AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferMadeByTTMailToAGLL(string useremail,string username,String propaddress, 
                                                                                       Decimal offeramount,string caseid, string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String responsebutton;
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Confirmation of offer-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferMadeByTTMailToAGLL');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        responsebutton = '<a style="background-color: #457cbf;color: #fff;font-size: 1rem;text-transform: initial;padding-top: 0.5rem;padding-bottom: 0.5rem;padding-left: 0.5rem; padding-right: 0.5rem; display: inline-block; outline: 0!important; text-decoration: none!important; text-align: center; width: 220px; border-radius: 3rem;"  href="https://staging-thedisputeservice.cs122.force.com/Sds/s/">Respond to offer</a>';
        if(contactid !=null){
         CustomerId = contactid;  
        }
        else{
        CustomerId = accountid;   
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('firsr_line_of_address', propaddress);
        variableMap.put('offer_details', string.valueof(offeramount));
        variableMap.put('respond_to_offer', responsebutton);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferMadeByTTMailToAGLL', emailsubject);    
        return EmailWrapper;
    }
    
    // When Tenant Make  offer of AGLL during self resolution email to  othertenant
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferMadeByTTMailToOtherTT(string useremail,string username,String propaddress, 
                                                                                          Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
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
        if(contactid !=null){   
        CustomerId =  contactid;   
        }
        else{
        CustomerId = accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('first_name_of_address', propaddress);
        variableMap.put('offer_details', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferMadeByTTMailToOtherTT', emailsubject);    
        return EmailWrapper;
        
    }
    
    @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel() {
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }
    public class ChatWrapper{
        @AuraEnabled public  list<Chat_History__c> chatList{get;set;}
        @AuraEnabled public  String  otherPartyName{get;set;}
        @AuraEnabled public  String  selfName{get;set;}
        @AuraEnabled public  String  currentContactId{get;set;}
        @AuraEnabled public  String  otherPartyContactId{get;set;}
        @AuraEnabled public  Decimal  numberOfEvidences{get;set;}
        
        
        

    }
    
    @AuraEnabled
    public static ChatWrapper updateChatFields(String caseId){
        
		Decimal evidenceCount =0;
        String otherPartyContactId = '';
        String otherPartyName = '';
		
        
        list<User> userList = [Select Id,Name,ProfileId,Profile.Name,ContactId from User where Id=:UserInfo.getUserId()];
        String profileName = userList[0].Profile.Name;
        
        
        if(profileName == 'Tenant'){
            
            list<Case_Participant__c> participantsList = [Select Id,Contact__c,Contact__r.Name from Case_Participant__c where Case__c =: caseId AND Type__c != 'Tenant'];
            
            if(!participantsList.isEmpty()){
                otherPartyContactId = participantsList[0].Contact__c;
                otherPartyName = participantsList[0].Contact__r.Name;
                
            }
            
        }else{
            
            list<Case_Participant__c> participantsList = [Select Id,Contact__c,Contact__r.Name from Case_Participant__c where Case__c =: caseId AND  Is_Lead__c = true];
            
            if(!participantsList.isEmpty()){
                otherPartyContactId = participantsList[0].Contact__c;
                otherPartyName = participantsList[0].Contact__r.Name;
                
            }
        }
        
        list<User> userName = [Select Id,Name,ContactId from User where Id =: UserInfo.getUserId()];
            
        list<Chat_History__c> chatList = [Select Id,Azure_File_Name__c,Case__c,Name,Download_File__c,File_Location__c,From__c,Message__c,To__c,To__r.Name,File_Name__c,File_Type__c,Seen_at__c from Chat_History__c where Case__c =: caseId ORDER BY CreatedDate];
        
		for(Chat_History__c chat :chatList){
            if(String.isNotBlank(chat.File_Location__c) && chat.From__c == userList[0].ContactId){
                chat.File_Location__c = chat.File_Location__c.UnescapeHTML4();
                evidenceCount++;
            }else if(String.isNotBlank(chat.File_Location__c)){
                chat.File_Location__c = chat.File_Location__c.UnescapeHTML4();
            }
            
        }
        
        list<Chat_History__c> updateLastSeen = [Select Id,Azure_File_Name__c,Case__c,Name,Download_File__c,File_Location__c,From__c,Message__c,To__c,To__r.Name,File_Name__c,File_Type__c,Seen_at__c from Chat_History__c where Case__c =: caseId AND Seen_at__c = null AND To__c =: userList[0].ContactId ORDER BY CreatedDate];
                                                
        for(Chat_History__c chat : updateLastSeen){
            chat.Seen_at__c = System.now();
        }
        if(updateLastSeen != null && !updateLastSeen.isEmpty()){
            Update updateLastSeen;
        }        
        ChatWrapper wrap = new ChatWrapper();
        wrap.currentContactId = userList[0].ContactId;
        wrap.selfName = userName[0].Name;
        wrap.otherPartyName = otherPartyName;
        wrap.chatList = chatList;
		wrap.otherPartyContactId = otherPartyContactId;
        wrap.numberOfEvidences = evidenceCount;
        
        
        return wrap;
        
        
        
    }
    
    @AuraEnabled
    public static ChatWrapper updateChatHistory(String caseId, String message, String fromId, String toId){
        
        insert new Chat_History__c(Case__c = caseId, From__c = fromId, Message__c = message, To__c =toId);
        
        return updateChatFields(caseId);
        
    }
    @AuraEnabled
    public static String getSecureURI(String scheme){
        System.debug('Line 296 -> '+scheme);
        Azure_Storage_Credentials_per_Scheme__mdt settings = EI_selfresolutionsummaryviewtenant.getAzureMetadata(scheme);
        System.debug('Line 297 -> '+(EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c));
        return EI_SDS_EvidenceUploadToAzure.isRunningOnSandbox() ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c;
        
    }
    
    private static Azure_Storage_Credentials_per_Scheme__mdt getAzureMetadata(String scheme) {
        Azure_Storage_Credentials_per_Scheme__mdt settings;
        try {
            settings = [
                SELECT Account_Name_Production__c,
                Account_Name_Sandbox__c,
                Container_Name_Production__c,
                Container_Name_Sandbox__c,
                Endpoint_Production__c,
                Endpoint_Sandbox__c,
                Secure_URI_Production__c,
                Secure_URI_Sandbox__c,
                Storage_Key_Production__c,
                Storage_Key_Sandbox__c
                FROM Azure_Storage_Credentials_per_Scheme__mdt
                WHERE Label = :scheme
            ];
        }
        catch(QueryException exc) {
            //throw new AzureFunctionFileUploadServiceException('No Azure Upload Function Credentials found for scheme: ');
        }
        return settings;
    }
    @AuraEnabled
    public static ChatWrapper saveFile(String caseId, String fromId, String toId, String fileName, String azureLink, String fileType, String fileSize, String fileLable, String fileNameInAzure, String scheme){
        
        insert new Chat_History__c(Case__c = caseId, 
                                   From__c = fromId, 
                                   Azure_File_Name__c = fileNameInAzure, 
                                   To__c =toId,
                                   File_Name__c = fileName,
                                   File_Location__c = azureLink,
                                   File_Type__c = fileType,
                                   File_Size__c = decimal.valueOf(fileSize),
                                   File_Description__c = fileLable,
                                   Scheme__c = scheme
                                  );
        return updateChatFields(caseId);
     
    }
    
    @AuraEnabled
    public static Integer returnUnreadMessages(String depositId){
        
        Integer unreadMessageCount = 0;

        list<User> userList = [Select Id,Name,ProfileId,Profile.Name,ContactId from User where Id=:UserInfo.getUserId()];
        list<Chat_History__c> unseenMessages = [Select Id,Azure_File_Name__c,Case__c,Name,Download_File__c,File_Location__c,From__c,Message__c,To__c,To__r.Name,File_Name__c,File_Type__c,Seen_at__c from Chat_History__c where Case__r.Deposit_Account_Number__c =: depositId AND Seen_at__c = null AND To__c =: userList[0].ContactId ORDER BY CreatedDate];
        
        if(unseenMessages != null && !unseenMessages.isEmpty()){
            unreadMessageCount = unseenMessages.size();
        }
        
        return unreadMessageCount;
        
     
    }
    
     // When Tenant Reject  offer of AGLL during self resolution email to  AGLL
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferRejectedByTenantMailToAGLL(string useremail,string username, 
                                                                                                 String propaddress,Decimal offeramount, 
                                                                                                 string caseid,string contactid ,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit offer rejected-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferRejectedByTenantMailToAGLL');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
        CustomerId = contactid;     
        }
        else{
        CustomerId =accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('proposal_details', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferRejectedByTenantMailToAGLL', emailsubject);    
        return EmailWrapper;
    }
    
     // When Tenant Reject  offer of AGLL during self resolution email to  LeadTenant
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferRejectedByTenantMailToLeadTT(string useremail,string username, String propaddress, 
                                                                                               Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit offer rejected'+'-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferRejectedByTenantMailToLeadTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
         CustomerId = contactid;  
        }
        else{
          CustomerId =  accountid;
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('proposal_details', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferRejectedByTenantMailToLeadTT', emailsubject);    
        
        
        Return EmailWrapper;
    }
    // When Tenant Reject  offer of AGLL during self resolution email to  othertenants
    public static EI_SDS_MailJetUtilityCls.EmailWrapper SelfresOfferRejectedByTenantMailToOthrTT(string useremail,string username, String propaddress, 
                                                                                               Decimal offeramount,string caseid,string contactid,string accountid) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit offer rejected'+'-'+propaddress;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('SelfresOfferRejectedByTenantMailToOthrTT');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){
         CustomerId = contactid;  
        }
        else{
          CustomerId =  accountid;
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, CustomerId));
        variableMap.put('date', tdstr);
        variableMap.put('name', username);
        variableMap.put('proposal_details', string.valueof(offeramount));
        /*  variableMap.put('Address', propaddress);
		variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SelfresOfferRejectedByTenantMailToOthrTT', emailsubject);    
        
        
        Return EmailWrapper;
    }
}