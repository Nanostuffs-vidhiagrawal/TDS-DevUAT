public without sharing class EI_PendingRepaymentRequest {
    
    @AuraEnabled
    public static string fetchRequestedPaymentByTenant() {
        try{
            return null;
        } catch (Exception e){
            
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getLoggedInUserDetail(){
        string userDetails= EI_headOfficeUtility.getLoggedInUserDetail();
        return userDetails;
    }
    
    @AuraEnabled
    public static String getCurrentDate(){
        string currentDate= EI_headOfficeUtility.getCurrentDate();
        return currentDate;
    }
    
    @AuraEnabled
    public static void cancelRequest(){
                 
    }
    
    @AuraEnabled
    public static Repayment_Request__c getRequestRepayment(String  depositId) {
        List<Repayment_Request__c> reqList = 
            [Select Account__c, AL_CleaningAmt__c, AL_DmgPropAmt__c, AL_GardeningAmt__c, AL_OtherAmt__c,
             AL_Other_Reason__c, AL_RedecorationAmt__c, AL_Rent_Arrears__c, AL_Repay_Requested__c, CreatedById,
             CreatedDate, Deposit__c, Id, IsDeleted, LastActivityDate, LastModifiedById, LastModifiedDate,
             Name, OwnerId, Status__c, SystemModstamp, Tenancy_End_Date__c, Tenant_Cleaning__c, 
             Tenant_Dmg_to_Property__c, Tenant_Gardening__c, Tenant_Other_Reason__c, Tenant_Other__c, 
             Tenant_Redecoration__c, Tenant_Rent_Arrears__c, Tenant_Repay_Requested__c, Total_Amount_Requested_AL__c, 
             Total_Amount_Offer_from_AALL_To_Tenant__c, Total_Amount_By_Agent_Landlord__c, Total_Amount_By_Tenant__c,
             Deposit__r.Protected_Amount__c, Deposit__r.Payment_Received_By_Scheme__c,
             (SELECT AL_ReqAmt__c, Tenant_ReqAmt__c, Repayment_Request__r.Deposit__r.Customer__r.PersoncontactId, 
              Repayment_Request__r.Deposit__c, Repayment_Request__r.Deposit__r.name, 
              Repayment_Request__r.Deposit__r.Customer__c, Repayment_Request__r.Deposit__r.Customer__r.IspersonAccount, 
              Account__r.PersonContactId, Account__c, Account__r.Name, Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c
              FROM Repayment_Request_Lines__r where Account__r.RecordType.Name IN ('Tenant')) 
             from Repayment_Request__c where Deposit__c=:depositId order by createdDate desc limit 1
             //and Status__c = 'Repayment requested - tenant'
            ];
        if(reqList.size()>0) {
            return reqList[0];
        } else {
            return null;
        }    
    }
    
    @AuraEnabled
    public static List<Bank_Account__c> fetchBankDetails(){
        List<Bank_Account__c> bankdetails  = [select id,Account__c,IBAN__c,BIC__c,Bank_Address__c,Swift_Code__c, Contact__c,
                                 Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c,International_Account_Number__c,
                                 International_Bank_Account_Holder_Name__c,International_Bank_Name__c, Sort_Code__c 
                                 from Bank_Account__c  where Contact__c IN (SELECT ContactId from 
                                 User where Id = :UserInfo.getUserId()) limit 1 ];     
        return bankdetails;
    }
    
    @AuraEnabled
    public static string updateBankDetailsOfTenant(String accountNumber, String sortCode, String bankAccountName, String bankName) {
        
        User currentUser = [Select ContactId,Contact.AccountId from user where Id =: Userinfo.getUserId()];
        String message, isCorrect, bankNameInfo;
        String url = Label.Sort_Code_URL+getKey()+'&AccountNumber='+accountNumber+'&SortCode='+sortCode;
        system.debug('url***'+url);
        system.debug('accountNumber-->'+accountNumber+' --sortCode-->'+sortCode+'bankAccountName-->'+bankAccountName+'bankName-->'+bankName);
        String response = getResponse(url);
        JSONParser parser = JSON.createParser(response);
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                if(parser.getCurrentName() == 'IsCorrect') {
                    parser.nextToken();
                    isCorrect = parser.getText();
                }
                else if (parser.getCurrentName() == 'StatusInformation') {
                    parser.nextToken();
                    message = parser.getText();
                }
                if (parser.getCurrentName() == 'Bank') {
                    parser.nextToken();
                    bankNameInfo = parser.getText();
                }
            }
        }
        if(!Boolean.ValueOf(isCorrect)){
            if(message=='InvalidAccountNumber' || message=='UnknownSortCode'){
                message = message;
            }
            else{
                message = message;
            }
        }
        else{        
            List<Bank_Account__c> bankdetails  = [Select Id, Account__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, 
                                                  Account_Number__c, Sort_Code__c from Bank_Account__c  where 
                                                  Contact__c =: currentUser.ContactId limit 1 ];
            if(bankdetails!=null && !bankdetails.isEmpty()) {
                Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
                updatebankdetails.Name=bankAccountName;
                updatebankdetails.Account_Number__c= accountNumber;
                updatebankdetails.Sort_Code__c = sortCode;
                updatebankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                updatebankdetails.Bank_Name__c = bankNameInfo;
                update updatebankdetails;
                message = updatebankdetails.Bank_Name__c;
            }
            else {
                Bank_Account__c insertbankdetails =new Bank_Account__c();
                insertbankdetails.Name=bankAccountName;
                insertbankdetails.Account__c=currentUser.Contact.AccountId;
                insertbankdetails.Contact__c=currentUser.ContactId;
                insertbankdetails.Account_Number__c= accountNumber;
                insertbankdetails.Sort_Code__c = sortCode;
                insertbankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                insertbankdetails.Bank_Name__c = bankNameInfo;
                insert insertbankdetails;
                message = insertbankdetails.Bank_Name__c;         
            }
        }
        return message;
    }
    
    @AuraEnabled
    public static string updateIntBankDetailsOfTenant(String bankIntName, String bankIntaddress, String bankIntAccountName, 
                                                      String bankIdentificationCode, String bankSwiftCode, String IBAN) 
    {
        
        User currentUser = [Select ContactId,Contact.AccountId from user where id=: Userinfo.getUserId()];
        String message='';
        List<Bank_Account__c> bankdetails  = [Select Id, IBAN__c, Swift_Code__c,BIC__c, Bank_Address__c, Account__c, Contact__c, 
                                              International_Bank_Account_Holder_Name__c, International_Bank_Name__c, Account_Number__c, 
                                              Sort_Code__c from Bank_Account__c where Contact__c =: currentUser.ContactId limit 1 ];
        if(bankdetails!=null && !bankdetails.isEmpty()) {
            Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
            updatebankdetails.International_Bank_Account_Holder_Name__c= bankIntAccountName;
            updatebankdetails.International_Bank_Name__c = bankIntName;
            updatebankdetails.IBAN__c=IBAN;
            updatebankdetails.BIC__c= bankIdentificationCode;
            updatebankdetails.Bank_Address__c = bankIntaddress;
            updatebankdetails.Swift_Code__c = bankSwiftCode;
            update updatebankdetails;
            message = 'successMessage';
        }
        else {
            Bank_Account__c insertbankdetails =new Bank_Account__c();
            insertbankdetails.Account__c = currentUser.Contact.AccountId;
            insertbankdetails.Contact__c = currentUser.ContactId;
            insertbankdetails.International_Bank_Account_Holder_Name__c= bankIntAccountName;
            insertbankdetails.International_Bank_Name__c = bankIntName;
            insertbankdetails.IBAN__c=IBAN;
            insertbankdetails.BIC__c= bankIdentificationCode;
            insertbankdetails.Bank_Address__c = bankIntaddress;
            insertbankdetails.Swift_Code__c = bankSwiftCode;
            insert insertbankdetails;
            message = 'successMessage';         
        }
        return message;
    }
    
    
    /**
    * @description : To get the Sort Code Api key from custom label
    * @param :
    * @return : string
    **/
    public static string getKey(){
        /*Enter your API key here*/
        string key = Label.Sort_Code_API;
        string output = 'Key=' + key;
        return output;
    }
    
    /**
    * @description : Common Utility method for making call out
    * @param : String
    * @return : string
    **/
    public static string getResponse(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        String responseBody = res.getBody();
        system.debug('responseBody---' + responseBody);
        return responseBody;
    }
    
   /* @AuraEnabled
    public static Bank_Account__c getBankDetails(){
        string contactid = [select contactId from user where id=:userinfo.getUserId()]?.contactId;
        List<Bank_Account__c> bankDetail = [select id,Account_Number__c,Bank_Account_Holder_Name__c,Bank_Name__c,
                                            BIC__c,Contact__c,IBAN__c,Sort_Code__c
                                            from Bank_Account__c where Contact__c =:contactid LIMIT 1];
        if(bankDetail.size() > 0){
            return bankDetail[0];
        }else{
            return null;
        }       
    }*/
    
    @AuraEnabled
    public static Bank_Account__c getBankDetails(){
        string contactid = [select contactId
                            from user
                            where id = :userinfo.getUserId()] ?.contactId;
        List<Bank_Account__c> bankDetail = [SELECT Account__c, Is_Active__c, BIC__c, Bank_Name__c, IBAN__c, Sort_Code__c, Contact__c, 
                                            Bank_Account_Holder_Name__c, Account_Number__c, Bank_Address__c, International_Account_Number__c, 
                                            International_Bank_Account_Holder_Name__c, International_Bank_Name__c, Swift_Code__c
                                            FROM Bank_Account__c
                                            where Contact__c = :contactid AND Is_Active__c = true
                                            ORDER BY createddate desc
                                            LIMIT 1];
        if (bankDetail.size() > 0){
            return bankDetail[0];
        } else{
            return null;
        }
    }
    
    @AuraEnabled
    public static string addBankDetail(String BankDetails,string  RequsetRec) {
        try{
           // Bank_Account__c bankdetails1 = getBankDetails();
            Repayment_Request__c requestRepayment = (Repayment_Request__c) System.JSON.deserialize(RequsetRec, Repayment_Request__c.class);
            /*EI_RespondToRepaymentEmails emailClass = new EI_RespondToRepaymentEmails();
            emailClass.sendEmail(requestRepayment);*/
            
           /* if(bankdetails1 == null)
            {
                user userDetails = [select contactId,Accountid from user where id=:userinfo.getUserId()];
                Bank_Account__c bankdetailRec = (Bank_Account__c) System.JSON.deserialize(BankDetails, Bank_Account__c.class); 
                bankdetailRec.Account__c = userDetails.Accountid;
                bankdetailRec.Contact__c= userDetails.contactId;
                insert bankdetailRec;
                bankdetails1 =bankdetailRec; 
                
            }*/
            System.debug('requestRepayment-->'+requestRepayment.Id);
            update requestRepayment;
            return requestRepayment.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* Agreeing to Repayment Request initiated by Tenant */
    @AuraEnabled
    public static List<Repayment_Request_Line__c> AgreedTorequest(String RecId, decimal Amount, Date TenancyEndDate, Boolean saveBankDetForLater) {
        Repayment_Request__c req = [SELECT Id, Deposit__c, Deposit__r.Name, Case__c, Status__c, Deposit__r.Payment_Received_By_Scheme__c,
                                    (SELECT AL_ReqAmt__c, Tenant_ReqAmt__c, Repayment_Request__r.Deposit__r.Customer__r.PersoncontactId, 
                                            Repayment_Request__r.Deposit__c, Repayment_Request__r.Deposit__r.Name, 
                                            Repayment_Request__r.Deposit__r.Customer__c, Repayment_Request__r.Deposit__r.Customer__r.IspersonAccount, 
                                            Account__r.PersonContactId, Account__c, Account__r.Name, Account__r.IsPersonAccount, 
                                            Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c
                                     FROM Repayment_Request_Lines__r) 
                                    FROM Repayment_Request__c WHERE Id=:recId Limit 1];
        
        List<Repayment_Request_Line__c> repReqLines = new List<Repayment_Request_Line__c>();
        repReqLines = req.Repayment_Request_Lines__r;
        System.debug('Line 264 repReqLines -> '+repReqLines);
        System.debug('Line 265 saveBankDetForLater -> '+saveBankDetForLater+' TenancyEndDate -> '+TenancyEndDate);
        
        Set<String> personAccountIds = new Set<String>();
        Set<string> missingbankdetail = new Set<string>();
        Map<string, Bank_Account__c> creditNoteToBeCreated = new map<string, Bank_Account__c>();
        
        Id userId = UserInfo.getUserId();
        User loggedUser = [SELECT Id, AccountId, ContactId, Name FROM User WHERE Id = :userId limit 1];
        
        // Fetch all the Person Account Contact Ids
        for (Repayment_Request_Line__c repaymentLineItem : repReqLines) {
            if(repaymentLineItem.Account__r.IsPersonAccount) 
            {
                personAccountIds.add(repaymentLineItem.Account__r.PersonContactId);
                
            } else {
                personAccountIds.add(loggedUser.ContactId);
            }
        }
        System.debug('Line 284 personAccountIds -> '+personAccountIds);
        
        //Fetch all the bank details related to fetched Person Account Contact Ids
        Map<String, Bank_Account__c> bankDetailsMap = getBanKDetails(personAccountIds);
        // System.debug(bankDetailsMap);
        
        List<Repayment_Request_Line__c> reqLine = new List<Repayment_Request_Line__c>();
        for (Repayment_Request_Line__c rec : repReqLines) {
            if(rec.Account__r.IsPersonAccount) 
            {
                if (!bankDetailsMap.containsKey(rec.Account__r.PersonContactId)) {
                    missingbankdetail.add(rec.Id);
                }
            } else {
                if (!bankDetailsMap.containsKey(loggedUser.ContactId)) {
                    missingbankdetail.add(rec.Id);
                }
            }
            
            Decimal tenReqAmount;
            if (rec.Account__c==loggedUser.AccountId) {
                tenReqAmount = rec.Tenant_ReqAmt__c;
                string key = loggedUser.ContactId + '-' + tenReqAmount;
                creditNoteToBeCreated.put(key, bankDetailsMap.get(loggedUser.ContactId));
                
            } else {
                tenReqAmount = rec.Tenant_ReqAmt__c;
                string key = rec.Account__r.PersonContactId + '-' + tenReqAmount;
                creditNoteToBeCreated.put(key, bankDetailsMap.get(rec.Account__r.PersonContactId));
            }
            reqLine.add(rec);
        }
        
        req.status__c = 'Deposit to be Repaid - Repayment Agreed'; // to be changed in future
        req.Tenancy_End_Date_Agent__c  = TenancyEndDate;
        update req;
        
        System.debug('req case' + req.Case__c);
        
        List<Case> cs = [Select Id from Case where Id = :req.Case__c LIMIT 1];
        System.debug('Line 335 cs' + cs);
        if (cs.size() > 0) {
            cs[0].Status = 'Deposit to be Repaid - Repayment Agreed';
            update cs[0];
        }
        
        list<string> messages = new list<String>();
        for (string bank : creditNoteToBeCreated.keyset()){
            decimal amtForCreditNote = decimal.valueOf(bank.split('-')[1]);
            string contactId = bank.split('-')[0];
            messages.add(createCreditNoteRecord(repReqLines[0].Repayment_Request__r.Deposit__r.name,contactid, 
                                                repReqLines[0].Repayment_Request__r.Deposit__r.name, amtForCreditNote, 
                                                req.Deposit__r.Payment_Received_By_Scheme__c,
                                                repReqLines[0].Repayment_Request__r.Deposit__c, req.Case__c, creditNoteToBeCreated.get(bank)));
            
        }
        System.debug('Line 355 saveBankDetForLater =-> '+saveBankDetForLater);
        if(saveBankDetForLater == false)
        {
            Bank_Account__c ba = [Select Id, Name from Bank_Account__c where Contact__c =: loggedUser.ContactId limit 1];
            System.debug('Line 355 ba =-> '+ba);
            delete ba;
        }
        
        List<Bank_Account__c> Tenantbankdetails = new List<Bank_Account__c>();
        if(req.Repayment_Request_Lines__r[0]!=null)
        {
            string accountid =req.Repayment_Request_Lines__r[0].Account__c;
            
            Tenantbankdetails  = [select id,Account_Number__c,Bank_Account_Holder_Name__c,Bank_Name__c,Contact__r.name,
                                                        BIC__c,Contact__c,IBAN__c,Sort_Code__c from Bank_Account__c where 
                                                        Account__c=: accountid order by Createddate desc ];
            System.debug('Line 425');
        }
        
        System.debug('isAccessible - '+Schema.sObjectType.Case.fields.Status.isAccessible());
        
        Deposit__c d = new Deposit__c(Id=req.Deposit__c, Status__c='Repayment process', End_Date__c=TenancyEndDate);
        update d;
        System.debug('Line 431');
        req.Status__c = 'Approved By Agent/Landlord';
        update req;  
        System.debug('Line 436');
        System.debug('Line 438 '+req.Deposit__c + 'Repayment requested - tenant');
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        /* Newly added code for Mailjet Utility Class END */
        
        //String response = EI_DepositSummaryApx.CreateCreditNote('test',req.Deposit__r.Name,Amount,req.Deposit__c,null,Tenantbankdetails[0]);   
        
        //EI_RespondToRepaymentEmails emials = new  EI_RespondToRepaymentEmails();
        emailWrapperList = EI_RespondToRepaymentEmails.ConfirmationWithBankdetailssendEmail(req.Deposit__c, TenancyEndDate, emailWrapperList);
        
        /* Newly added code for sending mail through MailJet START */
        EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
        /* Newly added code for sending mail through MailJet END */
        
        return reqLine;
    }
    
    /* Disagreeing to Repayment Request initiated by Tenant */
    @AuraEnabled
    public static String DisagreedTorequest(/*String BankDetails,*/ String  RequsetRec, String RepaymentLineRec, Date TenancyEndDate) {
        try{
            // Bank_Account__c bankdetails1 = getBankDetails();
            System.debug('LINE 457 RequsetRec -->> '+RequsetRec);
            Id userId = UserInfo.getUserId();
            User loggedUser = [SELECT Id, AccountId, ContactId, Name FROM User WHERE Id = :userId limit 1];
            Map<String, Object> repMap = (Map<String, Object>)JSON.deserializeUntyped(RequsetRec);
            
            System.debug('Line 461 RepaymentLineRecord -->> '+repMap);
            
            //Repayment_Request__c requestRepayment = (Repayment_Request__c) System.JSON.deserialize(RequsetRec, Repayment_Request__c.class);
            List<Repayment_Request_Line__c> RepaymentLineRecord = 
                (List<Repayment_Request_Line__c>)System.JSON.deserialize(RepaymentLineRec, List<Repayment_Request_Line__c>.class);
            //List<Repayment_Request_Line__c> RepaymentLineRecord = (List<Repayment_Request_Line__c>)System.JSON.deserialize(RepaymentLineRec, List<Repayment_Request_Line__c>.class);
        
            System.debug('Line 466 RepaymentLineRecord -->> '+RepaymentLineRecord);
            
            Repayment_Request__c req = [SELECT Id, Name, Case__c, Deposit__c, Total_Amount_Requested_AL__c, AL_CleaningAmt__c, AL_DmgPropAmt__c, 
                                        AL_RedecorationAmt__c, AL_GardeningAmt__c, AL_Rent_Arrears__c, AL_OtherAmt__c, AL_Other_Reason__c, 
                                        Deposit__r.End_Date__c, Tenancy_End_Date_Agent__c, 
                                        (SELECT Id, AL_ReqAmt__c, Account__c, Account__r.RecordType.Name FROM Repayment_Request_Lines__r 
                                         where Account__r.RecordType.Name NOT IN ('Tenant')) 
                                        FROM Repayment_Request__c WHERE ID = :String.valueOf(repMap.get('Id')) 
                                       ];
            
            req.AL_CleaningAmt__c = repMap.get('AL_CleaningAmt__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('AL_CleaningAmt__c')));
            req.AL_DmgPropAmt__c = repMap.get('AL_DmgPropAmt__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('AL_DmgPropAmt__c')));
            req.AL_GardeningAmt__c = repMap.get('AL_GardeningAmt__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('AL_GardeningAmt__c')));
            req.AL_OtherAmt__c = repMap.get('AL_OtherAmt__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('AL_OtherAmt__c')));
            req.AL_Other_Reason__c = String.isEmpty(String.valueOf(repMap.get('AL_Other_Reason__c'))) ? '' : String.valueOf(repMap.get('AL_Other_Reason__c'));
            req.AL_RedecorationAmt__c = repMap.get('AL_RedecorationAmt__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('AL_RedecorationAmt__c')));
            req.AL_Rent_Arrears__c = repMap.get('AL_Rent_Arrears__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('AL_Rent_Arrears__c')));
            req.Account__c = loggedUser.AccountId;
            Decimal repaymentAmtToAgLL = req.AL_CleaningAmt__c + req.AL_DmgPropAmt__c + req.AL_GardeningAmt__c + req.AL_OtherAmt__c + 
                                         req.AL_RedecorationAmt__c + req.AL_Rent_Arrears__c;
            req.Total_Amount_Requested_AL__c = repaymentAmtToAgLL;
            //req.status__c = 'Repayment disputed - self-resolution';
            req.Tenancy_End_Date_Agent__c = TenancyEndDate;
            
            //req.Deposit__r.End_Date__c = endDate;
            
            // Emails not to be send as per story on disagreeing tenant initiated rep req
            /*EI_RespondToRepaymentEmails emailClass = new EI_RespondToRepaymentEmails();
            emailClass.sendEmail(req);*/
            System.debug('Line 434');
            EI_RespondToRepaymentEmails.sendDisagreementEmails(req);
            
            update req;

        
            System.debug('Line 440');
            //List<Repayment_Request_Line__c> reqLine = new List<Repayment_Request_Line__c>();
               if(req.Repayment_Request_Lines__r.size()>0){
                 RepaymentLineRecord.add(req.Repayment_Request_Lines__r);
            }
            for (Repayment_Request_Line__c rec : RepaymentLineRecord) {
                if(rec.Account__c == loggedUser.AccountId)
                {
                    rec.AL_ReqAmt__c = repaymentAmtToAgLL;
                }
            }
            update RepaymentLineRecord;
            System.debug('Line 513');
            
            if(req!= null)
            {
                if(req.Deposit__c!=null || req.Deposit__c!='')
                {
                    Deposit__c depToUpdate = new Deposit__c(Id = req.Deposit__c, Status__c='Repayment requested by agent/landlord', End_Date__c=TenancyEndDate);
                    update depToUpdate;
                }
                
                if(req.Case__c!=null || req.Case__c!='')
                {
                    Case caseToUpdate = new Case (Id=req.Case__c, Status='Repayment requested - agent/landlord'); 
                    update caseToUpdate;
                }
            }
            
            /* if(bankdetails1 == null)
            {
                user userDetails = [select contactId,Accountid from user where id=:userinfo.getUserId()];
                Bank_Account__c bankdetailRec = (Bank_Account__c) System.JSON.deserialize(BankDetails, Bank_Account__c.class); 
                bankdetailRec.Account__c = userDetails.Accountid;
                bankdetailRec.Contact__c= userDetails.contactId;
                insert bankdetailRec;
                bankdetails1 =bankdetailRec;  
            } */
            
            /* System.debug('requestRepayment-->'+requestRepayment.Id);
            update requestRepayment;
            return requestRepayment.Id; */
            
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static Map<String, Bank_Account__c> getBanKDetails(Set<String> userContactId) {
        
        Map<String, Bank_Account__c> bankDetail = new Map<String, Bank_Account__c>(); 
        List<Bank_Account__c> baList = [SELECT Account__c, Is_Active__c, BIC__c, Bank_Name__c, 
                                        IBAN__c, Sort_Code__c, Contact__c, Bank_Account_Holder_Name__c, 
                                        Account_Number__c, Bank_Address__c, International_Account_Number__c, 
                                        International_Bank_Account_Holder_Name__c, International_Bank_Name__c, 
                                        Swift_Code__c, Contact__r.name,ValidInternationBankDetails__c
                                        FROM Bank_Account__c
                                        WHERE Contact__c IN :userContactId //AND Is_Active__c = true
                                        ORDER BY createddate desc //LIMIT 1
                                        ];
        if(baList.size()>0){
            for(Bank_Account__c ba : baList){
                bankDetail.put(ba.Contact__c,ba);
            }
        }
        System.debug('571 userContactId -> '+userContactId);
        System.debug('572 bankDetail -> '+bankDetail+', bankDetail size -> '+bankDetail.size());
        return bankDetail;
    }
    
    /*@What
    *Close case immediately once agent click that tenancy has not ended and send notification emails
    */
    @AuraEnabled
    public static String closeCase(String depositId, String repaymentRec) {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String schemeSignatory;
        String jsonData;
        String jsonData2;
        String subject;
        String subject2;
        
        try{
            List<Repayment_Request__c> reqList = [Select Id, (Select Account__r.PersonEmail, Account__r.Name, Contact__r.Name, Account__c, Contact__c 
                                                              from Repayment_Request_Lines__r where Requested_By__c = 'Tenant'), 
                                                  Status__c, Deposit__r.Name, Deposit__c, Case__c, Deposit__r.Property_Address__c, 
                                                  Tenant_Repay_Requested__c from Repayment_Request__c where Id=:repaymentRec];
            if(reqList.size()>0) {
                reqList[0].Status__c = 'Rejected By Agent/Landlord';
                reqList[0].Tenant_Repay_Requested__c = false;
                
                System.debug('reqList'+reqList);
                
                /* Newly added code for Utility mailjet START */
                List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
                Date todayDate = System.today();
                String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
                /* Newly added code for Utility mailjet END */
                
                for(Repayment_Request_Line__c repReqLine : reqList[0].Repayment_Request_Lines__r) {
                    /* Newly added code for adding recipients, variables, template name, Subject START */
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(reqList[0].Repayment_Request_Lines__r[0].Account__r.PersonEmail, 
                                                                                  reqList[0].Repayment_Request_Lines__r[0].Account__r.Name,
                                                                                  reqList[0].Case__c, reqList[0].Repayment_Request_Lines__r[0].Contact__c));
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('date', todayStr);
                    variableMap.put('tenant_name', reqList[0].Repayment_Request_Lines__r[0].Account__r.Name); 
                    variableMap.put('dan_no', reqList[0].Deposit__r.name); 
                    variableMap.put('property_address', reqList[0].Deposit__r.Property_Address__c); 
                    //variableMap.put('scheme_signatory', schemeSignatory);
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'TenancyNotEndedToTenant', 
                                                                                   'Reference: '+reqList[0].Deposit__r.name+
                                                                                   ' Agent/landlord advises tenancy has not yet ended'
                                                                                  ));    
                    /* Newly added code for adding recipients, variables, template name, Subject END */
                }
                
                /*
                * Send Disagreement emails to tenant stating tenancy has not ended.
                */
                // EI_EmailResponseRequest.caseClosureNotificationTenant(reqList[0].Deposit__r.name, reqList[0].Deposit__r.Property_Address__c, reqList[0].Repayment_Request_Lines__r[0].Account__r.PersonEmail);
                
                //      EI_EmailResponseRequest.caseClosureNotificationLandlord(reqList[0].Deposit__r.name, reqList[0].Deposit__r.Property_Address__c);
                /*
                * Send Disagreement emails to Agent/Landlord stating tenancy has not ended.
                */
                
                User userDetails = [select email, contactId, Accountid, Name from user where Id=:userinfo.getUserId()];
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList1 = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList1.add(new EI_SDS_MailJetUtilityCls.recipient(userDetails.Email, userDetails.Name,
                                                                               reqList[0].Case__c, userDetails.contactId));
                Map<String, String> variableMap1 = new Map<String, String>();
                
                variableMap1.put('date', todayStr);
                variableMap1.put('tenant_name', reqList[0].Repayment_Request_Lines__r[0].Account__r.Name); 
                variableMap1.put('dan_no', reqList[0].Deposit__r.name); 
                variableMap1.put('property_address', reqList[0].Deposit__r.Property_Address__c); 
                //variableMap1.put('scheme_signatory', schemeSignatory);
                
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList1), variableMap1, 
                                                                               'TenancyNotEndedToAgentLandlord', 
                                                                               'Reference: '+reqList[0].Deposit__r.Name+
                                                                               ' Confirmation that tenancy has not yet ended'
                                                                              ));    
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
                /* Send Email from MailJet Utility Class START */
                if(!emailWrapperList.isEmpty()) {
                    EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));  
                }
                /* Send Email from MailJet Utility Class END */	
                
                //Update Data
                update reqList[0];
                Case getCaseDetails = [Select id,Status,Deposit_Account_Number__c,AccountId from Case where Deposit_Account_Number__c=: depositId AND 
                                       Status=: 'Repayment requested - tenant' limit 1];
                if(getCaseDetails.Id !=null) {
                    getCaseDetails.Status='Case closed - tenancy not ended';
                    getCaseDetails.Close_Reason__c = 'Rejected';
                    update getCaseDetails;
                    Deposit__c d = new Deposit__c(Id=reqList[0].Deposit__c, Status__c='Deposits held by scheme');
                    update d;
                }
                return reqList[0].Id;
                
            } else {
                return 'Record not found';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string createCreditNoteRecord(string creditReference,string contactID, string paymentReference, decimal Amount, 
                                                Date paymentRecievedByScheme, String DspositId, String CaseIDs,Bank_Account__c bankdetails)
    {
        if(Amount>0) {
            String returnedStr = EI_UtilityClassForPayments.createCreditNoteRecord(creditReference, contactID, paymentReference, Amount,
                                                                                   paymentRecievedByScheme, DspositId, CaseIDs, bankdetails, 
                                                                                   'Final Payment', 'Deposit repayment request', null);
            return returnedStr;
        } else {
            return 'Amount should be greater than 0';
        }
    }
    @AuraEnabled
    public static List<Deposit_Allocation__c> getTenantsInformation(String depositRecordId) {
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        depositAllocationList = [SELECT Id, Deposit__r.Customer_Name__c, Deposit__r.Customer__r.Name, Deposit__r.Protected_Amount__c, 
                                 Deposit_Holder__r.PersonContactId, Deposit_Holder__c, Deposit_Holder__r.Name, Deposit_Holder__r.Salutation, Is_Lead__c,
                                 Deposit_Holder__r.PersonMailingStreet,Deposit_Holder__r.PersonMailingCity,Deposit_Holder__r.PersonMailingCountry,Deposit_Holder__r.PersonMailingPostalCode,Deposit_Holder__r.PersonEmail
                                 from Deposit_Allocation__c where Deposit__c =:depositRecordId AND Role__c='Tenant' 
                                 AND Deposit_Holder__r.PersonMailingStreet = '' 
                                 AND Deposit_Holder__r.PersonMailingCity = ''
                                 AND Deposit_Holder__r.PersonMailingCountry = ''
                                 AND Deposit_Holder__r.PersonMailingPostalCode = ''
                                 AND Deposit_Holder__r.PersonEmail = ''
                                 Order By Is_Lead__c desc];
        return depositAllocationList;
    }

}