public without sharing class EI_TenantRespondToRepayment {
      
    @AuraEnabled
    public static List<Deposit_Allocation__c> getActiveDeposit(){
        ID loggedInUser = UserInfo.getUserId();
        System.debug('loggedInUser :' + loggedInUser);
        try{
            List<Deposit_Allocation__c> deplist = [SELECT Deposit__r.Name, Deposit__c, Id
                                                   FROM Deposit_Allocation__c
                                                   Where Contact__c IN (SELECT contactId
                                                                        from User
                                                                        where Id = :loggedInUser)];
            System.debug('deplist :' + deplist);
            return deplist;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean checkRepaymentRequested(String depositId){
        
        try{
            Boolean IsrepaymentRequested = [SELECT AL_Repay_Requested__c
                                            FROM Repayment_Request__c
                                            where Deposit__c = :depositId AND Status__c = 'Repayment requested – agent/landlord' AND AL_Repay_Requested__c = true
                                            ORDER BY CREATEDDATE DESC
                                            LIMIT 1] ?.AL_Repay_Requested__c;
            
            return IsrepaymentRequested;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Repayment_Request__c> fetchRepaymentrecord(String depositId){
        try {
            List<Repayment_Request__c> repayList = 
                [SELECT Total_Amount_Offer_from_AALL_To_Tenant__c,TenantAllRequests__c,Deposit__r.Customer__c,Deposit__r.Customer__r.IspersonAccount, AL_CleaningAmt__c, 
                 AL_DmgPropAmt__c, AL_GardeningAmt__c, AL_OtherAmt__c, AL_Other_Reason__c, AL_RedecorationAmt__c, AL_Rent_Arrears__c, 
                 AL_Repay_Requested__c, Account__c, Account__r.Name, Deposit__r.Protected_Amount__c, Deposit__c, Deposit__r.name, 
                 Tenancy_End_Date__c, Tenant_Cleaning__c, Tenant_Dmg_to_Property__c, Contact__c, Contact__r.Name, Deposit__r.Payment_Received_By_Scheme__c,
                 Tenant_Gardening__c, Tenant_Other_Reason__c, Tenant_Other__c, Tenant_Redecoration__c, Tenant_Rent_Arrears__c, Total_Amount_By_Tenant__c, 
                 Tenant_Repay_Requested__c, Total_Amount_Requested_AL__c, Status__c, Tenancy_End_Date_Agent__c, Total_Amount_By_Agent_Landlord__c, 
                 (SELECT AL_ReqAmt__c, Account__c,Repayment_Request__r.Deposit__r.Customer__r.PersoncontactId, Repayment_Request__r.Deposit__c, 
                  Repayment_Request__r.Deposit__r.Customer__c,Repayment_Request__r.Deposit__r.Customer__r.IspersonAccount, Contact__c, 
                  Repayment_Request__r.Contact__c, Repayment_Request__r.Account__c, Repayment_Request__r.Deposit__r.name, Account__r.PersonContactId, 
                  Account__r.Name, Tenant_ReqAmt__c, Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c, Repayment_Request__r.Case__c 
                  FROM Repayment_Request_Lines__r where Account__r.RecordType.Name IN ('Tenant'))
                 FROM Repayment_Request__c WHERE Deposit__c = :depositId and Status__c IN ('Repayment requested - agent/landlord', 
                 'Repayment requested - tenant','Repayment disputed - self-resolution') limit 1];
            return repayList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static User getLoggedUserAccId() {
        Id userId = UserInfo.getUserId();
        User loggedUser = [SELECT Id, AccountId, ContactId, Name FROM User WHERE Id = :userId limit 1];
        return loggedUser;
    }
    
    @AuraEnabled
    public static Bank_Account__c fetchBankDetails(){
        try{
            Bank_Account__c ba = EI_PendingRepaymentRequest.getBankDetails();
            return ba;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Bank_Account__c> fetchBankDetails1(){
        List<Bank_Account__c> bankdetails  = [select id,Account__c,IBAN__c,BIC__c,Bank_Address__c,Swift_Code__c, Contact__c,
                                 Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c,International_Account_Number__c,
                                 International_Bank_Account_Holder_Name__c,International_Bank_Name__c, Sort_Code__c 
                                 from Bank_Account__c  where Contact__c IN (SELECT ContactId from 
                                 User where Id = :UserInfo.getUserId()) limit 1 ];     
        return bankdetails;
    }
    
    @AuraEnabled
    public static String addBankDetails(String BankDetails){
        String message, isCorrect, bankNameInfo;
        
        User userDetails = [select contactId, AccountId
                            from user
                            where id = :userinfo.getUserId()];
        
        
        Bank_Account__c bankdetailRec = (Bank_Account__c)System.JSON.deserialize(BankDetails, Bank_Account__c.class);
        
        
        String url = Label.Sort_Code_URL + getKey()+'&AccountNumber=' + Integer.valueOf(bankdetailRec.Account_Number__c)+'&SortCode=' + Integer.valueOf(bankdetailRec.Sort_Code__c);
        system.debug('url***' + url);
        
        String response = getResponse(url);
        
        JSONParser parser = JSON.createParser(response);
        while (parser.nextToken() != null){
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if (parser.getCurrentName() == 'IsCorrect'){
                    parser.nextToken();
                    isCorrect = parser.getText();
                } else if (parser.getCurrentName() == 'StatusInformation'){
                    parser.nextToken();
                    message = parser.getText();
                }
                if (parser.getCurrentName() == 'Bank'){
                    parser.nextToken();
                    bankNameInfo = parser.getText();
                }
            }
        }
        
        if (!Boolean.ValueOf(isCorrect)){
            if (message == 'InvalidAccountNumber' || message == 'UnknownSortCode'){
                message = message;
            } else{
                message = message;
            }
        } else{
            try{
                List<Bank_Account__c> bankList = [Select Id, Is_Active__c
                                                  from Bank_Account__c
                                                  where Contact__c = :userDetails.contactId and Is_Active__c = true];
                for (Bank_Account__c ba : bankList){
                    ba.Is_Active__c = false;
                }
                update bankList;
                bankdetailRec.Bank_Name__c = bankNameInfo;
                bankdetailRec.Account__c = userDetails.Accountid;
                bankdetailRec.Contact__c = userDetails.contactId;
                bankdetailRec.Is_Active__c = true;
                upsert bankdetailRec;
                message = 'OK';
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        System.debug('message: ' + message);
        
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
    
    @AuraEnabled
    public static String editBankDetails(String BankDetails){
        System.debug(BankDetails);
        String message, isCorrect, bankNameInfo;
        
        Bank_Account__c bankdetailRec = (Bank_Account__c)System.JSON.deserialize(BankDetails, Bank_Account__c.class);
        
        
        String url = Label.Sort_Code_URL + getKey()+'&AccountNumber=' + Integer.valueOf(bankdetailRec.Account_Number__c)+'&SortCode=' + Integer.valueOf(bankdetailRec.Sort_Code__c);
        system.debug('url***' + url);
        
        String response = getResponse(url);
        
        JSONParser parser = JSON.createParser(response);
        while (parser.nextToken() != null){
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if (parser.getCurrentName() == 'IsCorrect'){
                    parser.nextToken();
                    isCorrect = parser.getText();
                } else if (parser.getCurrentName() == 'StatusInformation'){
                    parser.nextToken();
                    message = parser.getText();
                }
                if (parser.getCurrentName() == 'Bank'){
                    parser.nextToken();
                    bankNameInfo = parser.getText();
                }
            }
        }
        
        if (!Boolean.ValueOf(isCorrect)){
            if (message == 'InvalidAccountNumber' || message == 'UnknownSortCode'){
                message = message;
            } else{
                message = message;
            }
        } else{
            try{
                bankdetailRec.Bank_Name__c = bankNameInfo;
                update bankdetailRec;
                message = 'OK';
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        System.debug('message: ' + message);
        
        return message;
    }
    
    /* @AuraEnabled
    public static void updateRepaymentLine(String RepaymentLineRec, Decimal totalRepayments, Date endDateByTenant){
        list<Repayment_Request_Line__c> RepaymentLineRecord = (list<Repayment_Request_Line__c>)System.JSON.deserialize(RepaymentLineRec, list<Repayment_Request_Line__c>.class);
        update RepaymentLineRecord;
        aggreedToRepayment(RepaymentLineRec, totalRepayments, endDateByTenant);
    } */
    
    public static Map<String, Bank_Account__c> getBanKDetails(Set<String> userContactId) {
        System.debug('userContactId -> '+userContactId);
        Map<String, Bank_Account__c> bankDetail = new Map<String, Bank_Account__c>(); 
        List<Bank_Account__c> baList = 
            [SELECT Account__c, Is_Active__c, BIC__c, Bank_Name__c, IBAN__c, Sort_Code__c, Contact__c, Bank_Account_Holder_Name__c, 
             Account_Number__c, Bank_Address__c, International_Account_Number__c, International_Bank_Account_Holder_Name__c, 
             International_Bank_Name__c, Swift_Code__c, Contact__r.name,ValidInternationBankDetails__c
             FROM Bank_Account__c WHERE Contact__c IN :userContactId AND Contact__c != NULL
             ORDER BY createddate desc //LIMIT 1
            ];
        if(baList.size()>0){
            for(Bank_Account__c ba : baList){
                bankDetail.put(ba.Contact__c,ba);
            }
        }
        System.debug('329bankDetail -> '+bankDetail);
        return bankDetail;
    }
    
    // @future(callout = 'true')
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> aggreedToRepaymentEmailAGLL
        (Id reqId, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) 
    {
        List<Repayment_Request_Line__c> reqLine = 
            [SELECT Id, AL_ReqAmt__c, Repayment_Request__r.Deposit__r.Name, Account__r.PersonEmail, Account__r.Name, Tenant_ReqAmt__c, 
             Repayment_Request__r.Deposit__r.Property_Address__c, Repayment_Request__r.Total_Amount_Offer_from_AALL_To_Tenant__c, 
             Repayment_Request__r.Total_Amount_By_Agent_Landlord__c, Repayment_Request__r.Account__r.name, Repayment_Request__r.Case__c, 
             Repayment_Request__r.Account__r.PersonEmail, Repayment_Request__r.Account__c, Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
             FROM Repayment_Request_Line__c WHERE Repayment_Request__c = :reqId];
        
        System.debug('reqLine : ' + reqLine);
        String jsonData;
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT = 'Tenant agrees to repayment request';
        
        toAddress = reqLine[0].Repayment_Request__r.Account__r.PersonEmail;
        toName = reqLine[0].Repayment_Request__r.Account__r.name;
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, reqLine[0].Repayment_Request__r.Case__c, 
                                                                      reqLine[0].Repayment_Request__r.Account__c));
        
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('name', toName);
        variableMap.put('propertyAddress', reqLine[0].Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
        variableMap.put('danNo', String.valueof(System.today()));
        //variableMap.put('agreedAmounts', String.valueof(0));
        
        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                       'TenantAcceptsRepReqEmailAGLL',
                                                                       'Deposit repayment agreed - '
                                                                       +reqLine[0].Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                      ));
        /* Newly added code for adding recipients, variables, template name, Subject START */
            
        return emailWrapperList;
        
    }
    
    // @future(callout = 'true')
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> aggreedToRepaymentEmailTenant
        (Id reqId, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) 
    {
        String tenantSplit = '';
        List<Repayment_Request_Line__c> reqLine = 
            [SELECT Id, AL_ReqAmt__c, Repayment_Request__r.Deposit__r.Name, Account__r.PersonEmail, Account__r.Name,account__r.personcontactid, Tenant_ReqAmt__c, 
             Repayment_Request__r.Deposit__r.Property_Address__c, Repayment_Request__r.Total_Amount_Offer_from_AALL_To_Tenant__c, 
             Repayment_Request__r.Total_Amount_By_Agent_Landlord__c, Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c, 
             Repayment_Request__r.Case__c FROM Repayment_Request_Line__c WHERE Repayment_Request__c = :reqId];
        for (Repayment_Request_Line__c rl : reqLine) {
            tenantSplit = tenantSplit + rl.Account__r.Name + ' : ' + rl.AL_ReqAmt__c + '<br/>';
        }
        
        System.debug('reqLine : ' + reqLine);
        String jsonData;
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT = 'Thank you for agreeing to the repayment request';
        Decimal amount;
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        for (Repayment_Request_Line__c d : reqLine) {
            
            toAddress = d.Account__r.PersonEmail;
            toName = d.Account__r.Name;
            amount = d.AL_ReqAmt__c;
            
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, d.Repayment_Request__r.Case__c,d.account__r.personcontactid /*d.Account__c*/));
            system.debug('emailRecipientList 38 -> ' + emailRecipientList);
            Map<String, String> variableMap = new Map<String, String>();
            variableMap.put('date', todayStr);
            variableMap.put('name', toName);
            variableMap.put('DAN', String.valueof(System.today()));
            variableMap.put('address', d.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
            //variableMap.put('agreedAmounts', String.valueof(0));
            variableMap.put('passwordResetLink', 'https://staging-thedisputeservice.cs122.force.com/Sds/s/login/ForgotPassword');
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'TenantAcceptsRepReqEmailTT',
                                                                           'Deposit repayment agreed - '
                                                                           +d.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                          ));
            /* Newly added code for adding recipients, variables, template name, Subject START */
            
        }
        
        return emailWrapperList;
        
    }
    
    @future(callout = 'true')
    public static void missingBankDetailEmailAgentAmount(Set<String> recievers){
        List<Repayment_Request_Line__c> reqLine = [SELECT Id, AL_ReqAmt__c, Repayment_Request__r.Deposit__r.Name, Account__r.PersonEmail, Account__r.Name, Tenant_ReqAmt__c
                                                   FROM Repayment_Request_Line__c
                                                   WHERE Id in :recievers];
        System.debug('reqLine : ' + reqLine);
        String jsonData;
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT = 'Please update your payment details';
        Decimal amount;
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('MissingBankDetail');
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName = mailJetSettings[0].From_Name__c;
        mailJetTemplateId = Integer.valueof(templateId[0].Template_Id__c);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        
        for (Repayment_Request_Line__c d : reqLine){
            list<string> flaglist = new list<string>();
            if (flaglist.size() > 0 && !(flaglist.contains(d.id))){
                gen.writeString(',');
            }
            toAddress = d.Account__r.PersonEmail;
            toName = d.Account__r.Name;
            
            amount = d.AL_ReqAmt__c;
            
            gen.writeStartObject();
            gen.writeFieldName('From');
            gen.writeStartObject();
            gen.writeStringField('Email', fromAddress);
            gen.writeStringField('Name', fromName);
            gen.writeEndObject();
            
            gen.writeFieldName('To');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('Email', toAddress);
            gen.writeStringField('Name', toName);
            gen.writeEndObject();
            gen.writeEndArray();
            
            gen.writeNumberField('TemplateID', mailJetTemplateId);
            gen.writeBooleanField('TemplateLanguage', true);
            gen.writeStringField('Subject', subject);
            
            gen.writeFieldName('Variables');
            gen.writeStartObject();
            gen.writeStringField('date', string.valueOf(system.today()));
            gen.writeStringField('tenant_name', toName);
            gen.writeNumberField('recieving_amount', d.AL_ReqAmt__c);
            gen.writeStringField('dan_no', d.Repayment_Request__r.Deposit__r.Name);
            gen.writeEndObject();
            gen.writeEndObject();
            flaglist.add(d.id);
        }
        gen.writeEndArray();
        gen.writeEndObject();
        jsonData = gen.getAsString();
        system.debug('jsonData-->>' + jsonData);
        req.setBody(jsonData);
        Http http = new Http();
        system.debug('req-->>' + req.getBody());
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    // @future(callout = 'true')
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> missingBankDetailEmailTenantAmount
        (Set<String> recievers, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) 
    {
        List<Repayment_Request_Line__c> reqLine = 
            [SELECT Id, AL_ReqAmt__c, Repayment_Request__r.Deposit__r.Name, Account__r.PersonEmail, Account__r.Name, Tenant_ReqAmt__c, 
             Repayment_Request__r.Case__c, Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
             FROM Repayment_Request_Line__c WHERE Id in :recievers];
        System.debug('reqLine : ' + reqLine);
        String jsonData;
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT = 'Please update your payment details';
        Decimal amount;
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        for (Repayment_Request_Line__c d : reqLine) {
            toAddress = d.Account__r.PersonEmail;
            toName = d.Account__r.Name;
            amount = d.AL_ReqAmt__c;
            
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, d.Repayment_Request__r.Case__c, d.Account__c));
            
            Map<String, String> variableMap = new Map<String, String>();
            variableMap.put('date', todayStr);
            variableMap.put('tenant_name', toName);
            variableMap.put('recieving_amount', string.valueOf(d.Tenant_ReqAmt__c));
            variableMap.put('dan_no', d.Repayment_Request__r.Deposit__r.Name);
            variableMap.put('tenantLoginLink', 'https://staging-thedisputeservice.cs122.force.com/Sds/s/login/');
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'MissingBankDetail',
                                                                           'Deposit repayment - please update your payment details - '
                                                                           +d.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                          ));
            /* Newly added code for adding recipients, variables, template name, Subject START */
            
        }
        
        return emailWrapperList;
        
    }
    
    // @future(callout = 'true')
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> aggreedToRepaymentSplitEmailTenant
        (Id reqId, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) {
        String tenantSplit = '';
        List<Repayment_Request_Line__c> reqLine = 
            [SELECT Id, AL_ReqAmt__c, Repayment_Request__r.Deposit__r.Name, Account__r.PersonEmail, Account__r.Name, Tenant_ReqAmt__c, 
             Repayment_Request__r.Deposit__r.Property_Address__c, Repayment_Request__r.Total_Amount_Offer_from_AALL_To_Tenant__c, 
             Repayment_Request__r.Total_Amount_By_Agent_Landlord__c, Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c, 
             Repayment_Request__r.Case__c FROM Repayment_Request_Line__c WHERE Repayment_Request__c = :reqId];
            
        for (Repayment_Request_Line__c rl : reqLine) {
            tenantSplit = tenantSplit + rl.Account__r.Name + ' : ' + rl.Tenant_ReqAmt__c + '<br/>';
        }
        
        System.debug('reqLine : ' + reqLine);
        String jsonData;
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT = 'Thank you for agreeing to the repayment request';
        Decimal amount;
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
		
        for (Repayment_Request_Line__c d : reqLine) {
            toAddress = d.Account__r.PersonEmail;
            toName = d.Account__r.Name;
            
            amount = d.AL_ReqAmt__c;
            
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, d.Repayment_Request__r.Case__c, d.Account__c));
            
            Map<String, String> variableMap = new Map<String, String>();
            variableMap.put('date', todayStr);
            variableMap.put('name', toName);
            variableMap.put('DAN', String.valueof(System.today()));
            variableMap.put('address', d.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
            //variableMap.put('agreedAmounts', String.valueof(0));
            variableMap.put('passwordResetLink', 'https://staging-thedisputeservice.cs122.force.com/Sds/s/login/ForgotPassword');
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'TenantAcceptsRepReqEmailTT',
                                                                           'Deposit repayment agreed - '
                                                                           +d.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                          ));
            /* Newly added code for adding recipients, variables, template name, Subject START */
            
        }
            
        return emailWrapperList;
            
    }
    
    // @future(callout = 'true')
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> sendWithdrawConfirmationEmailTenant
        (Id reqId, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList)
    {
        List<Repayment_Request_Line__c> reqLine = 
            [SELECT Id, AL_ReqAmt__c, Repayment_Request__r.Deposit__r.Name, Account__r.PersonEmail, Account__r.Name, Tenant_ReqAmt__c, 
             Repayment_Request__r.Deposit__r.Property_Address__c, Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c, 
             Repayment_Request__r.Case__c, Is_Lead__c 
             FROM Repayment_Request_Line__c WHERE Repayment_Request__c = :reqId AND Account__r.RecordType.Name IN ('Tenant')];
        System.debug('reqLine : ' + reqLine);
        
        String jsonData;
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        Decimal amount;
        String leadTenant;
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        for (Repayment_Request_Line__c repReqLine : reqLine) {
            if(repReqLine.Is_Lead__c==true) {
                leadTenant=repReqLine.Account__r.Name;
            }
        }
        
        for (Repayment_Request_Line__c d : reqLine) {
            
            toAddress = d.Account__r.PersonEmail;
            toName = d.Account__r.Name;
            String DANno = d.Repayment_Request__r.Deposit__r.name;
            String SUBJECT = DANno + ' The tenant has withdrawn from the dispute';
            amount = d.AL_ReqAmt__c;
            
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, d.Repayment_Request__r.Case__c, d.Account__c));
            
            Map<String, String> variableMap = new Map<String, String>();
            variableMap.put('date', todayStr);
            variableMap.put('name', toName);
            variableMap.put('proposalSubmittedDate', todayStr);
            variableMap.put('firstLineOfAddress', d.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
            variableMap.put('DAN', String.valueof(System.today()));
            variableMap.put('leadTenantName', leadTenant);	 
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'TenantWithdrawConsentJointTT',
                                                                           'Deposit repayment agreed - '
                                                                           +d.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                          ));
            /* Newly added code for adding recipients, variables, template name, Subject START */
            
        }
        
        return emailWrapperList;
        
    }
    
    // @future(callout = 'true')
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> sendWithdrawConfirmationEmailAgentLandlord
        (Id reqId, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList)
    {
        List<Repayment_Request_Line__c> reqLine = 
            [SELECT Id, AL_ReqAmt__c, Repayment_Request__r.Deposit__r.Name, Account__r.PersonEmail, Account__r.Name, Tenant_ReqAmt__c, 
             Repayment_Request__r.Deposit__r.Property_Address__c, Repayment_Request__r.Account__r.personEmail, Account__c, Is_Lead__c, 
             Repayment_Request__r.Case__c, Repayment_Request__r.Account__r.Name, Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c 
             FROM Repayment_Request_Line__c WHERE Repayment_Request__c = :reqId];
        System.debug('reqLine : ' + reqLine);
        
        String jsonData;
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        Decimal amount;
        String leadTenant;
        toAddress = reqLine[0].Repayment_Request__r.Account__r.personEmail;
        toName = reqLine[0].Repayment_Request__r.Account__r.Name;
        String DANno = reqLine[0].Repayment_Request__r.Deposit__r.name;
        String SUBJECT = DANno + ' The tenant has withdrawn from the dispute';
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        for (Repayment_Request_Line__c repReqLine : reqLine) {
            if(repReqLine.Is_Lead__c==true) {
                leadTenant=repReqLine.Account__r.Name;
            }
        }
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, reqLine[0].Repayment_Request__r.Case__c, 
                                                                      reqLine[0].Account__c));
        
        Map<String, String> variableMap = new Map<String, String>();
        variableMap.put('date', todayStr);
        variableMap.put('name', toName);
        variableMap.put('propertyAddress', reqLine[0].Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
        variableMap.put('DAN', reqLine[0].Repayment_Request__r.Deposit__r.Name);
        variableMap.put('leadTenantName', leadTenant);
        
        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                       'TenantWithdrawConsentAGLL',
                                                                       'Deposit repayment agreed - '
                                                                       +reqLine[0].Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                      ));
        /* Newly added code for adding recipients, variables, template name, Subject START */
        
        return emailWrapperList;
        
    }
    
    public static Bank_Account__c getBanckDetail(Id userContactId){
        List<Bank_Account__c> bankDetail = 
            [SELECT Account__c, Is_Active__c, BIC__c, Bank_Name__c, IBAN__c, Sort_Code__c, Contact__c, Bank_Account_Holder_Name__c, 
             Account_Number__c, Bank_Address__c, International_Account_Number__c, International_Bank_Account_Holder_Name__c, 
             International_Bank_Name__c, Swift_Code__c
             FROM Bank_Account__c WHERE Contact__c = :userContactId AND Is_Active__c = true
             ORDER BY createddate desc LIMIT 1];
        if (bankDetail.size() > 0){
            return bankDetail[0];
        } else{
            return null;
        }
    }
    
    @InvocableMethod(label = 'Create Payment After Thirty Days' 
                     description = 'Payment record will be created after thirty days if tenants opts for resolving outside')
    public static void paymentCreationThirtyDays(List<Repayment_Request__c> repaymentRecordList){
        System.debug('repaymentRecordList: ' + repaymentRecordList);
        List<Repayment_Request_Line__c> reqLine = [SELECT Id, Name,Account__r.PersonContactId,Tenant_ReqAmt__c,AL_ReqAmt__c,
                                                   Repayment_Request__r.Deposit__r.name,Repayment_Request__r.Deposit__c, 
                                                   Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c
                                                   FROM Repayment_Request_Line__c
                                                   WHERE Repayment_Request__c = :repaymentRecordList[0].Id];
        
        Set<string> missingbankdetail = new Set<string>();
        Map<string, Bank_Account__c> creditNoteToBeCreated = new map<string, Bank_Account__c>();
        Set<String> personAccountIds = new Set<String>();
        // Fetch all the Person Account Contact Ids
        for (Repayment_Request_Line__c repaymentLineItem : reqLine){
            personAccountIds.add(repaymentLineItem.Account__r.PersonContactId);
        }
        
        //Fetch all the bank details related to fetched Person Account Contact Ids
        Map<String, Bank_Account__c> bankDetailsMap = getBanKDetails(personAccountIds);
        // System.debug(bankDetailsMap);
        
        for (Repayment_Request_Line__c rec : reqLine){
            if (!bankDetailsMap.containsKey(rec.Account__r.PersonContactId)){
                missingbankdetail.add(rec.Id);
            }
            decimal amount;
            if (rec.Tenant_ReqAmt__c != null){
                amount = rec.Tenant_ReqAmt__c;
            } else{
                amount = rec.AL_ReqAmt__c;
            }
            
            string key = rec.Account__r.PersonContactId + '-' + amount;
            creditNoteToBeCreated.put(key, bankDetailsMap.get(rec.Account__r.PersonContactId));
        }
        for (string bank : creditNoteToBeCreated.keyset()){
            decimal amount = decimal.valueOf(bank.split('-')[1]);
            string contactId = bank.split('-')[0];
            createCreditNoteRecord(reqLine[0].Repayment_Request__r.Deposit__r.name,contactid, reqLine[0].Repayment_Request__r.Deposit__r.name, amount, reqLine[0].Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c, reqLine[0].Repayment_Request__r.Deposit__c, null, creditNoteToBeCreated.get(bank));
            
        }
    }
    
    @AuraEnabled
    public static Bank_Account__c addInternationalBankDetail(String BankDetails) {
        
        User userDetails = [select contactId, AccountId
                            from user
                            where id = :userinfo.getUserId()];
        
        Bank_Account__c bankdetailRec = (Bank_Account__c)System.JSON.deserialize(BankDetails, Bank_Account__c.class);
        
        try{
            List<Bank_Account__c> bankList = [SELECT Id, Is_Active__c
                                              FROM Bank_Account__c
                                              WHERE Contact__c = :userDetails.contactId and Is_Active__c = true];
            for (Bank_Account__c ba : bankList){
                ba.Is_Active__c = false;
            }
            update bankList;
            bankdetailRec.Account__c = userDetails.Accountid;
            bankdetailRec.Contact__c = userDetails.contactId;
            bankdetailRec.Is_Active__c = true;
            upsert bankdetailRec;
            
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return bankdetailRec;
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
                                                      String bankIdentificationCode, String bankSwiftCode, String IBAN) {

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
    
    @AuraEnabled
    public static string createCreditNoteRecord(string creditReference,string contactID, string paymentReference,decimal Amount,
                                                Date paymentRecievedByScheme, string DspositId, String CaseIDs, Bank_Account__c bankdetails)
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
    
    public static void assignLeadTenant(String depositId) {
        
        List<Deposit_Allocation__c> depAlloc = [Select Id, Name, Contact__c, Deposit__c, Deposit_Holder__c, Deposit_Status__c, Is_Lead__c, Role__c
                                                from Deposit_Allocation__c where Deposit__c=:depositId];
        List<User> currentUser = [SELECT Id, AccountId, ContactId, Name FROM User WHERE Id = :UserInfo.getUserId() limit 1];
        System.debug('currentUser -> '+currentUser[0]);
        System.debug('depositAll -> '+depAlloc.size());
        List<Deposit_Allocation__c> depAllocSettingLeadTenant = new List<Deposit_Allocation__c>();
        // Making the current user the lead tenant who is responding to the repayment 
        if(!currentUser.isEmpty()) {
            if(!depAlloc.isEmpty()) {
                for(Deposit_Allocation__c depositAll : depAlloc) 
                {
                    if(depositAll.Deposit_Holder__c==currentUser[0].AccountId && depositAll.Is_Lead__c==false) {
                        depositAll.Is_Lead__c = true;
                        depAllocSettingLeadTenant.add(depositAll);
                        
                    } else if(depositAll.Deposit_Holder__c!=currentUser[0].AccountId && depositAll.Is_Lead__c==true) {
                        depositAll.Is_Lead__c = false;
                        depAllocSettingLeadTenant.add(depositAll);
                    }
                }
            }
        }
        
        if(!depAllocSettingLeadTenant.isEmpty()) {
            update depAllocSettingLeadTenant;
        }
    }
    
    // Button-1 Click
    @AuraEnabled
    public static void aggreedToRepayment(String RepaymentLineRec, Decimal totalRepayments, Date endDateByTenant) {
        
        // Local Variables
        Set<string> missingbankdetail = new Set<string>();
        Map<string, Bank_Account__c> creditNoteToBeCreated = new map<string, Bank_Account__c>();
        
        // Deserialization of Paramters from Lightning component
        List<Repayment_Request_Line__c> RepaymentLineRecord = (List<Repayment_Request_Line__c>)System.JSON.deserialize(RepaymentLineRec, List<Repayment_Request_Line__c>.class);
        Set<String> personAccountIds = new Set<String>();
        List<Repayment_Request__c> req = 
            [SELECT Id, Case__c, Status__c, Deposit__c, 
             (Select Id, Type__c, Contact__c, AL_ReqAmt__c FROM Repayment_Request_Lines__r where Type__c!='Tenant' limit 1) 
             FROM Repayment_Request__c where Id = :RepaymentLineRecord[0].Repayment_Request__c];
        
        // Fetch all the Person Account Contact Ids
        for (Repayment_Request_Line__c repaymentLineItem : RepaymentLineRecord){
            personAccountIds.add(repaymentLineItem.Account__r.PersonContactId);
        }
        
        // Adding the contact id of the agent/landlord to get the bank details
        if(!req.isEmpty()) {
            if(req[0].Repayment_Request_Lines__r.size()>0){
                personAccountIds.add(req[0].Repayment_Request_Lines__r[0].Contact__c);
            }
            
        }
        
        //Fetch all the bank details related to fetched Person Account Contact Ids
        Map<String, Bank_Account__c> bankDetailsMap = getBanKDetails(personAccountIds);
        // System.debug(bankDetailsMap);
        
        // Assgning current login user a lead tenant
        if(!RepaymentLineRecord.isEmpty()) {
            assignLeadTenant(RepaymentLineRecord[0].Repayment_Request__r.Deposit__c);
        }
        
        for (Repayment_Request_Line__c rec : RepaymentLineRecord) {
            if (!bankDetailsMap.containsKey(rec.Account__r.PersonContactId)) {
                missingbankdetail.add(rec.Id);
            } 
            
            decimal amount;
            if (rec.AL_ReqAmt__c != null) {
                amount = rec.AL_ReqAmt__c;
            } else {
                amount = rec.Tenant_ReqAmt__c;
            }
            string key = rec.Account__r.PersonContactId + '-' + amount;
            System.debug(bankDetailsMap.get(rec.Account__r.PersonContactId));
            creditNoteToBeCreated.put(key, bankDetailsMap.get(rec.Account__r.PersonContactId));
        }
        // Adding the contact id of the agent/landlord to get the bank details
        if(!req.isEmpty()) {
             if(req[0].Repayment_Request_Lines__r.size()>0){
            String key = req[0].Repayment_Request_Lines__r[0].Contact__c + '-' + req[0].Repayment_Request_Lines__r[0].AL_ReqAmt__c;
            creditNoteToBeCreated.put(key, bankDetailsMap.get(req[0].Repayment_Request_Lines__r[0].Contact__c));
             }
        }
        System.debug(RepaymentLineRecord[0].Repayment_Request__c);
        
        if(!req.isEmpty()) {
            if (req[0].Deposit__c!=null) {
                EI_selfresolutionsummaryviewtenant.AgreedByCasePar = true;
                Deposit__c dep = new Deposit__c(Id=req[0].Deposit__c, Status__c='Repayment process', Tenancy_End_Date_TT__c=endDateByTenant);
                update dep;
            }
            
            req[0].status__c = 'Deposit to be Repaid - Repayment Agreed';
            req[0].Tenancy_End_Date__c = endDateByTenant;
            update req[0];
            
            if (req[0].Case__c!=null) {
                Case cs = new Case(Id=req[0].Case__c, Status='Deposit to be Repaid - Repayment Agreed');
                update cs;
            }
        }
        
        List<String> messages = new List<String>();
        for (String bank : creditNoteToBeCreated.keyset()){
            Decimal amount = decimal.valueOf(bank.split('-')[1]);
            String contactid = bank.split('-')[0];
            messages.add(createCreditNoteRecord(RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.name,contactid, 
                                                RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.name, amount, 
                                                RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c, 
                                                RepaymentLineRecord[0].Repayment_Request__r.Deposit__c, 
                                                RepaymentLineRecord[0].Repayment_Request__r.Case__c, creditNoteToBeCreated.get(bank)));
            
        }
        Boolean  flag = true ;
        for(String s:messages) {
            if(s!='successfully Updated') {
                flag = false; 
            }
        }
        
        // Email send for missing bank details
        if (flag)
        {
            EI_TenantRespondToRepayment.missingBankDetailEmailAgentAmount(missingbankdetail);            
        }
        
        System.debug('RepaymentLineRecord[0].Repayment_Request__r.Id: ' + RepaymentLineRecord[0].Repayment_Request__r.Id);
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        /* Newly added code for Utility mailjet END */
        
        emailWrapperList = aggreedToRepaymentEmailTenant(RepaymentLineRecord[0].Repayment_Request__r.Id, emailWrapperList);
        
        emailWrapperList = aggreedToRepaymentEmailAGLL(RepaymentLineRecord[0].Repayment_Request__r.Id, emailWrapperList);
        
        /* Send Email from Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
        }
        /* Send Email from Utility Class END */
    }
    
    // Button-2 Click
    @AuraEnabled
    public static void aggreedbutsplit(String RepaymentLineRec, Decimal totalRepayments, Date endDateByTenant) {
        
        // Local Variables
        Set<string> missingbankdetail = new Set<string>();
        Map<string, Bank_Account__c> creditNoteToBeCreated = new map<string, Bank_Account__c>();
        
        // Deserialization of Paramters from Lightning component
        List<Repayment_Request_Line__c> RepaymentLineRecord = (List<Repayment_Request_Line__c>)System.JSON.deserialize(RepaymentLineRec, List<Repayment_Request_Line__c>.class);
        Set<String> personAccountIds = new Set<String>();
        
        List<Repayment_Request__c> req = 
            [SELECT Id, Case__c, Status__c, Deposit__c, 
             (SELECT Id, Type__c, Contact__c, AL_ReqAmt__c FROM Repayment_Request_Lines__r WHERE Type__c!='Tenant' LIMIT 1) 
             FROM Repayment_Request__c WHERE Id = :RepaymentLineRecord[0].Repayment_Request__c];
        
        // Fetch all the Person Account Contact Ids
        for (Repayment_Request_Line__c repaymentLineItem : RepaymentLineRecord){
            personAccountIds.add(repaymentLineItem.Account__r.PersonContactId);
        }
        
        // Adding the contact id of the agent/landlord to get the bank details
        if(!req.isEmpty()) {
            personAccountIds.add(req[0].Repayment_Request_Lines__r[0].Contact__c);
        }
        
        //Fetch all the bank details related to fetched Person Account Contact Ids
        Map<String, Bank_Account__c> bankDetailsMap = getBanKDetails(personAccountIds);
        // System.debug(bankDetailsMap);
        
        // Assgning current login user a lead tenant
        if(!RepaymentLineRecord.isEmpty()) {
            assignLeadTenant(RepaymentLineRecord[0].Repayment_Request__r.Deposit__c);
        }
        
        List<Repayment_Request_Line__c> reqLine = new List<Repayment_Request_Line__c>();
        for (Repayment_Request_Line__c rec : RepaymentLineRecord) {
            if (!bankDetailsMap.containsKey(rec.Account__r.PersonContactId)) {
                missingbankdetail.add(rec.Id);
            }
            decimal amount;
            if (rec.Tenant_ReqAmt__c != null) {
                amount = rec.Tenant_ReqAmt__c;
            } else {
                amount = rec.AL_ReqAmt__c;
            }
            
            String key = rec.Account__r.PersonContactId + '-' + amount;
            creditNoteToBeCreated.put(key, bankDetailsMap.get(rec.Account__r.PersonContactId));
            reqLine.add(rec);
        }
        // Adding the contact id of the agent/landlord to get the bank details
        if(!req.isEmpty()) {
            String key = req[0].Repayment_Request_Lines__r[0].Contact__c + '-' + req[0].Repayment_Request_Lines__r[0].AL_ReqAmt__c;
            creditNoteToBeCreated.put(key, bankDetailsMap.get(req[0].Repayment_Request_Lines__r[0].Contact__c));
        }
        update reqLine;
        System.debug(RepaymentLineRecord[0].Repayment_Request__c);
        
        if(!req.isEmpty()) {
            System.debug('Line 1351 => '+req);
            if (req[0].Deposit__c!=null) {
                EI_selfresolutionsummaryviewtenant.AgreedByCasePar = true;
                Deposit__c dep = new Deposit__c(Id=req[0].Deposit__c, Status__c='Repayment process', Tenancy_End_Date_TT__c=endDateByTenant);
                update dep;
            }
            
            req[0].status__c = 'Deposit to be Repaid - Repayment Agreed';
            req[0].Tenancy_End_Date__c = endDateByTenant;
            update req[0];
            
            if (req[0].Case__c!=null) {
                Case cs = new Case(Id=req[0].Case__c, Status='Deposit to be Repaid - Repayment Agreed');
                update cs;
            }
        }
        
        list<String> messages = new list<String>();
        for(String bank : creditNoteToBeCreated.keyset()) {
            Decimal amount = Decimal.valueOf(bank.split('-')[1]);
            String contactId = bank.split('-')[0];
            messages.add(createCreditNoteRecord(RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.name, contactid, 
                                                RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.name, amount, 
                                                RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c, 
                                                RepaymentLineRecord[0].Repayment_Request__r.Deposit__c, 
                                                RepaymentLineRecord[0].Repayment_Request__r.Case__c, creditNoteToBeCreated.get(bank)));
            
        }
        
        if(totalRepayments>0)
        {
            System.debug('800 --===>>'+RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Customer__c);
            List<Bank_Account__c> agentBankDetails  = [SELECT id, Account_Number__c, Bank_Account_Holder_Name__c, 
                                                       Bank_Name__c, Contact__r.name,
                                                       BIC__c,Contact__c,IBAN__c,Sort_Code__c 
                                                       FROM Bank_Account__c WHERE 
                                                       Account__c=: RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Customer__c 
                                                       order BY Createddate DESC ];
            
            System.debug('===>>'+RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Customer__r.IspersonAccount);
            if(RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Customer__r.IspersonAccount)
            {
                System.debug('814'+RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Customer__c);
                
                /*CreateCreditNoteAgent('', RepaymentLineRecord[0].Repayment_Request__r.Deposit__c,totalRepayments,
                                      RepaymentLineRecord[0].Repayment_Request__r.Deposit__c, null ,agentBankDetails[0], 
                                      RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Customer__r.PersoncontactId, 
                                      RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Customer__c);*/
            }
            else
            {
                System.debug('814'+RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Customer__c);
                /*CreateCreditNoteAgent('', RepaymentLineRecord[0].Repayment_Request__r.Deposit__c,totalRepayments,
                                      RepaymentLineRecord[0].Repayment_Request__r.Deposit__c, null ,agentBankDetails[0], 
                                      null,RepaymentLineRecord[0].Repayment_Request__r.Deposit__r.Customer__c);*/
            }
        }
        
        Boolean  flag = true ;
        for(String s:messages) {
            if(s!='successfully Updated') {
                flag = false; 
            }
        }
        
        // Sending email for agreeing the repayment request and for missing bank details
        if (flag)
        { 
            /* Newly added code for Utility mailjet START */
            List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
            /* Newly added code for Utility mailjet END */
            
            emailWrapperList = missingBankDetailEmailTenantAmount(missingbankdetail, emailWrapperList);
            
            emailWrapperList = aggreedToRepaymentSplitEmailTenant(RepaymentLineRecord[0].Repayment_Request__r.Id, emailWrapperList);
            
            emailWrapperList = aggreedToRepaymentEmailAGLL(RepaymentLineRecord[0].Repayment_Request__r.Id, emailWrapperList);
            
            /* Send Email from Utility Class START */
            if(emailWrapperList.size()>0) {
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
            }
            /* Send Email from Utility Class END */   
        }
    }
    
    // Button-3 Click
    @AuraEnabled
    public static void tenantResponseUpdate(String TenantRec, String RepaymentLineRec, Date endDateByTenant) {
        
        Map<String, Object> repMap = (Map<String, Object>)JSON.deserializeUntyped(TenantRec);
        
        System.debug('repMap: ' + repMap.get('Tenant_Gardening__c'));
        Repayment_Request__c req = [SELECT Id, name, Case__c, Deposit__c, 
                                    (SELECT Id, Tenant_ReqAmt__c, Account__c, Account__r.RecordType.Name FROM Repayment_Request_Lines__r 
                                     where Account__r.RecordType.Name NOT IN ('Tenant')) 
                                    FROM Repayment_Request__c WHERE ID = :String.valueOf(repMap.get('Id')) LIMIT 1];
        
        req.Tenant_Cleaning__c = repMap.get('Tenant_Cleaning__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('Tenant_Cleaning__c')));
        req.Tenant_Dmg_to_Property__c = repMap.get('Tenant_Dmg_to_Property__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('Tenant_Dmg_to_Property__c')));
        req.Tenant_Gardening__c = repMap.get('Tenant_Gardening__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('Tenant_Gardening__c')));
        req.Tenant_Redecoration__c = repMap.get('Tenant_Redecoration__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('Tenant_Redecoration__c')));
        req.Tenant_Rent_Arrears__c = repMap.get('Tenant_Rent_Arrears__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('Tenant_Rent_Arrears__c')));
        req.Tenant_Other__c = repMap.get('Tenant_Other__c') == null ? 0:Decimal.valueOf(String.valueOf(repMap.get('Tenant_Other__c')));
        req.Tenant_Other_Reason__c = String.isEmpty(String.valueOf(repMap.get('Tenant_Other_Reason__c'))) ? '' : String.valueOf(repMap.get('Tenant_Other_Reason__c'));        
        Decimal repaymentAmtToAgLL = req.Tenant_Cleaning__c + req.Tenant_Dmg_to_Property__c + req.Tenant_Redecoration__c 
            						 + req.Tenant_Rent_Arrears__c + req.Tenant_Redecoration__c + req.Tenant_Other__c;
        req.status__c = 'Repayment disputed - self-resolution';
        req.Tenancy_End_Date__c = endDateByTenant;
        update req;
        
        //For the split between tenants to be changed
        // Deserialization of Paramters from Lightning component
        List<Repayment_Request_Line__c> RepaymentLineRecord = (List<Repayment_Request_Line__c>)System.JSON.deserialize(RepaymentLineRec, List<Repayment_Request_Line__c>.class);
        Set<String> personAccountIds = new Set<String>();
        
        // Assgning current login user a lead tenant
        if(!RepaymentLineRecord.isEmpty()) {
            assignLeadTenant(RepaymentLineRecord[0].Repayment_Request__r.Deposit__c);
        }
        
        // Fetch all the Person Account Contact Ids
        /* for (Repayment_Request_Line__c repaymentLineItem : RepaymentLineRecord){
            personAccountIds.add(repaymentLineItem.Account__r.PersonContactId);
        }
        
        //Fetch all the bank details related to fetched Person Account Contact Ids
        Map<String, Bank_Account__c> bankDetailsMap = getBanKDetails(personAccountIds);
        // System.debug(bankDetailsMap); */
        
        List<Repayment_Request_Line__c> reqLine = new List<Repayment_Request_Line__c>();
        //RepaymentLineRecord.add(req.Repayment_Request_Lines__r);
        for (Repayment_Request_Line__c rec : RepaymentLineRecord) {
            Decimal amount;
            if (rec.Tenant_ReqAmt__c != null) {
                amount = rec.Tenant_ReqAmt__c;
            } else {
                amount = rec.AL_ReqAmt__c;
            }
            
            //string key = rec.Account__r.PersonContactId + '-' + amount;
            //creditNoteToBeCreated.put(key, bankDetailsMap.get(rec.Account__r.PersonContactId));
            // }
            reqLine.add(rec);
        }
        if(req.Repayment_Request_Lines__r.size()>0){
             reqLine.add(new Repayment_Request_Line__c(Id=req.Repayment_Request_Lines__r[0].Id, Tenant_ReqAmt__c=repaymentAmtToAgLL));
       
        }
        
        if(!reqLine.isEmpty()) 
        	update reqLine;
        
        if(req.Deposit__c != null)
        {
            Deposit__c dep = new Deposit__c(Id=req.Deposit__c, Status__c='Repayment not agreed - In self-resolution', 
                                            Tenancy_End_Date_TT__c=endDateByTenant);
            System.debug('Deposit 111 -> '+dep);
            update dep;
        }
        if (req.Case__c != null) {
            Case cs = new Case(Id = req.Case__c, Status = 'Repayment disputed - self-resolution');
            update cs;
        }
        
    }
    
    // Button-4 Click
    @AuraEnabled
    public static void tenantResolveWithoutScheme(String TenantRec, Date endDateByTenant) {
        
        Map<String, Object> repMap = (Map<String, Object>)JSON.deserializeUntyped(TenantRec);
        
        System.debug('repMap: ' + repMap.get('Tenant_Gardening__c'));
        
        List<Repayment_Request__c> req = [SELECT Id, Case__c, Status__c, Deposit__c FROM Repayment_Request__c 
                                          WHERE Id = :String.valueOf(repMap.get('Id')) LIMIT 1];
        if(!req.isEmpty()) {
            req[0].status__c = 'Deposit To Be Repaid - Court Case';
            req[0].Tenancy_End_Date__c = endDateByTenant;
            update req[0];
            
            if (req[0].Case__c!=null) {
                Case cs = new Case(Id=req[0].Case__c, Status='Deposit To Be Repaid - Court Case');
                update cs;
            }
            if (req[0].Deposit__c!=null) {
                Deposit__c dep = new Deposit__c(Id=req[0].Deposit__c, Status__c='Repayment not agreed - In dispute resolution', 
                                                Tenancy_End_Date_TT__c=endDateByTenant);
                update dep;
            }
            
            // Assgning current login user a lead tenant
            assignLeadTenant(req[0].Deposit__c);
			
            /* Newly added code for Utility mailjet START */
            List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
            /* Newly added code for Utility mailjet END */
            
            emailWrapperList = sendWithdrawConfirmationEmailTenant(req[0].Id, emailWrapperList);
            
            emailWrapperList = sendWithdrawConfirmationEmailAgentLandlord(req[0].Id, emailWrapperList);
            
            /* Send Email from Utility Class START */
            if(emailWrapperList.size()>0) {
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
            }
            /* Send Email from Utility Class END */
        }
    }
    
    @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }
	
}