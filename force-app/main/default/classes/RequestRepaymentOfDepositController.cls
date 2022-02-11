public without sharing  class RequestRepaymentOfDepositController {
    
    @AuraEnabled 
    public static List<Bank_Account__c> getBankDetails(){
        List<Bank_Account__c> bankdetails  = [select id,Account__c,IBAN__c,BIC__c,Bank_Address__c,Swift_Code__c, Contact__c,
                                              Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c,International_Account_Number__c,
                                              International_Bank_Account_Holder_Name__c,International_Bank_Name__c, Sort_Code__c 
                                              from Bank_Account__c  where Contact__c IN (SELECT ContactId from 
                                                                                         User where Id = :UserInfo.getUserId()) limit 1 ];     
        return bankdetails;
        /* User currentUser = [Select ContactIdfrom user where id=: Userinfo.getUserId()];
        if(bankdetail != null ) {
            if(bankdetail[0].id != null) {
                update bankdetail;
            }
            else {
                bankdetail[0].Account__c = currentUser.Contact.AccountId;
                insert bankdetail;
            }
        }
        
        List<Bank_Account__c> bankDetails = [Select International_Bank_Name__c,Bank_Address__c,BIC__c,Swift_Code__c,IBAN__c,International_Bank_Account_Holder_Name__c,Name,Account_Number__c,Bank_Account_Holder_Name__c,Bank_Name__c,Sort_Code__c from Bank_Account__c where Account__c =: currentUser.Contact.AccountId ];
        return  bankDetails; */
    }
    
    @AuraEnabled
    public static string removeInternationalBankDetailsInfo(String contactId){
        String message='';
        List<Bank_Account__c> bankdetails  = [select id,IBAN__c,Swift_Code__c,BIC__c,Bank_Address__c,Account__c, Contact__c, International_Bank_Account_Holder_Name__c, International_Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where Contact__c =: contactId limit 1 ];
        if(bankdetails!=null && !bankdetails.isEmpty()){
            Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
            updatebankdetails.International_Bank_Account_Holder_Name__c= null;
            updatebankdetails.International_Bank_Name__c = null;
            updatebankdetails.IBAN__c=null;
            updatebankdetails.BIC__c= null;
            updatebankdetails.Bank_Address__c = null;
            updatebankdetails.Swift_Code__c = null;
            update updatebankdetails;
            message = 'successMessage';
        }
        else{
            message = 'No internation bank details available.';
        }
        return message;
    }
    
    @AuraEnabled
    public static string updateBankDetailsOfTenant(String accountNumber, String sortCode,String bankAccountName,String bankName){
        
        User currentUser = [Select ContactId,Contact.AccountId from user where id=: Userinfo.getUserId()];
        String message,isCorrect,bankNameInfo;
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
            List<Bank_Account__c> bankdetails  = [select id,Account__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where Contact__c = :currentUser.ContactId limit 1 ];
            if(bankdetails!=null && !bankdetails.isEmpty()){
                Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
                updatebankdetails.Name=bankAccountName;
                updatebankdetails.Account_Number__c= accountNumber;
                updatebankdetails.Sort_Code__c = sortCode;
                updatebankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                updatebankdetails.Bank_Name__c = bankNameInfo;
                update updatebankdetails;
                message = updatebankdetails.Bank_Name__c;
            }
            else{
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
    public static string CheckBankDetailsOfTenant()
    {        
        User currentUser = [Select ContactId,Contact.AccountId from user where id=: Userinfo.getUserId()];
        if(currentUser !=null){
            List<Bank_Account__c> bankdetails  = [select id,Account__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where Contact__c = :currentUser.ContactId limit 1 ];
            if(bankdetails !=null && bankdetails.size()>0)
            {
                return 'BankAccountExist';                
            }
            else
            {                
                return 'BankAccountNotExist'; 
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static string updateIntBankDetailsOfTenant(String bankIntName, String bankIntaddress,String bankIntAccountName,String bankIdentificationCode,String bankSwiftCode,String IBAN){
        User currentUser = [Select ContactId,Contact.AccountId from user where id=: Userinfo.getUserId()];
        String message='';
        List<Bank_Account__c> bankdetails  = [select id,IBAN__c,Swift_Code__c,BIC__c,Bank_Address__c,Account__c, Contact__c, International_Bank_Account_Holder_Name__c, International_Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where Contact__c =: currentUser.ContactId limit 1 ];
        if(bankdetails!=null && !bankdetails.isEmpty()){
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
        else{
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
        system.debug('responseBody---'+responseBody);       
        return responseBody; 
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
    
    @AuraEnabled
    public static Deposit__c getDepositInformation(String depositRecordId) {
        Deposit__c deposit = new Deposit__c();
        deposit = [SELECT Id, Status__c, Customer__r.Name, Customer__c, Customer_Name__c, Protected_Amount__c from Deposit__c where Id =:depositRecordId];
        return deposit;
    }
    
    @AuraEnabled
    public static List<Deposit_Allocation__c> getLoggedInTenantInformation(String depositRecordId) {
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        depositAllocationList = [SELECT Id, Deposit__r.Customer__r.Name, Deposit__r.Protected_Amount__c, Deposit_Holder__c, Deposit_Holder__r.Name, 
                                 Deposit_Holder__r.Salutation,Is_Lead__c from Deposit_Allocation__c where Deposit__c =:depositRecordId AND Role__c='Tenant' 
                                 and Deposit_Holder__c IN (SELECT AccountId from User where Id = :UserInfo.getUserId()) LIMIT 1];
        return depositAllocationList;
    }
    
    @AuraEnabled
    public static List<Deposit_Allocation__c> getTenantsInformation(String depositRecordId) {
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        depositAllocationList = [SELECT Id, Deposit__r.Customer_Name__c, Deposit__r.Customer__r.Name, Deposit__r.Protected_Amount__c, 
                                 Deposit_Holder__r.PersonContactId, Deposit_Holder__c, Deposit_Holder__r.Name, Deposit_Holder__r.Salutation, Is_Lead__c,
                                 Deposit_Holder__r.PersonMailingStreet,Deposit_Holder__r.PersonMailingCity,Deposit_Holder__r.PersonMailingCountry,Deposit_Holder__r.PersonMailingPostalCode,Deposit_Holder__r.PersonEmail
                                 from Deposit_Allocation__c where Deposit__c =:depositRecordId AND Role__c='Tenant' Order By Is_Lead__c desc];
        return depositAllocationList;
    }
    
    /* Tenant raises Repayment Request */
    @AuraEnabled
    public static string insertRepaymentReqTenant(String depositId, String accId, Date tenancyDate, String values, String customerName, 
                                                  Decimal Tenant_Other, Decimal Tenant_Rent_Arrears, Decimal Tenant_Gardening, 
                                                  Decimal Tenant_Redecoration, Decimal Tenant_Dmg_to_Property, Decimal Tenant_Cleaning, 
            									  String Tenant_Other_Reason) 
    {
        System.debug('tenancyDate'+tenancyDate+'Tenant_Other'+Tenant_Other+'Tenant_Rent_Arrears'+Tenant_Rent_Arrears);       
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = caseRecordType, AccountId = accId, Deposit_Account_Number__c = depositId, OwnerId = UserInfo.getUserId(), 
                                Origin = Label.Web, Status = Label.Repayment_Requested_Tenant, Scheme__c = Label.EW_Custodial, 
                                Subject = Label.RepaymentRequestedForAgentLandlord+customerName, 
                                Description = Label.RepaymentRequestedForAgentLandlord+customerName);
        insert newCase;
        System.debug('newCase'+newCase);
        
        // Assgning current login user a lead tenant
        if(depositId!=null || depositId!='') {
            EI_TenantRespondToRepayment.assignLeadTenant(depositId);
        }
        
        List<Repayment_Request_Line__c> rePayLineList = new List<Repayment_Request_Line__c>();  
        Repayment_Request__c rePay = new Repayment_Request__c();
        rePay.Tenant_Repay_Requested__c = true;
        rePay.Deposit__c = depositId;
        rePay.Account__c = accId;
        rePay.Tenant_Other_Reason__c=Tenant_Other_Reason;
        rePay.Case__c = newCase.Id;
        rePay.Status__c = Label.Repayment_Requested_Tenant;
        rePay.Tenancy_End_Date__c = tenancyDate;
        rePay.Tenant_Other__c=Tenant_Other;
        rePay.Tenant_Rent_Arrears__c=Tenant_Rent_Arrears;
        rePay.Tenant_Gardening__c=Tenant_Gardening;
        rePay.Tenant_Redecoration__c=Tenant_Redecoration;
        rePay.Tenant_Dmg_to_Property__c=Tenant_Dmg_to_Property;
        rePay.Tenant_Cleaning__c=Tenant_Cleaning;
        insert rePay;
        System.debug('rePay'+rePay);
        List<Object> results = (List<Object>) JSON.deserializeUntyped(values);
        Map<String, Object> m = new Map<String, Object>();
        Map<String, Decimal> mapTenantIdTenantValue = new Map<String, Decimal>();
        //System.debug('rePay'+rePay);
        if(results!=null && !results.isEmpty()) {
            for (Object obj: results) {
                m = (Map<String, Object>)obj;
                //  mapTenantIdTenantValue.put((String)m.get('key'),(Decimal)m.get('value'));
                mapTenantIdTenantValue.put((String)m.get('key'),Double.valueOf(m.get('value')));
                System.debug('++++++++++++++'+mapTenantIdTenantValue);
                System.debug('++++++++++++++'+(Map<String, Object>)obj);
            }
        }
        
        for(Id idValue: mapTenantIdTenantValue.keyset()) {
            Repayment_Request_Line__c rePayLine = new Repayment_Request_Line__c();
            rePayLine.Repayment_Request__c = rePay.id;
            rePayLine.Account__c = idValue;
            rePayLine.Tenant_ReqAmt__c = mapTenantIdTenantValue.get(idValue);
            rePayLine.Requested_By__c= Label.Tenant;
            rePayLine.Repayment_Requested_Mail_Sent__c = System.today();
            rePayLineList.add(rePayLine);
        }
        
        if(rePayLineList != null && !rePayLineList.isEmpty()) {
            insert rePayLineList;
        }
        System.debug('Line 275 rePayLineList -> '+rePayLineList);
        
		/* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        /* Newly added code for Utility mailjet END */
        
        // emailWrapperList = EmailMailJetService.sendTenantProposalToAgentLandlord(rePay.id,depositId,tenancyDate,emailWrapperList);
        // emailWrapperList = EmailMailJetService.sendTenantProposalToTenants(rePay.id,emailWrapperList);
        emailWrapperList = EmailMailJetService.sendRepReqEmailsTenantInitiated(rePay.id,depositId,tenancyDate,emailWrapperList);
        System.debug('Line 285 emailWrapperList -> '+emailWrapperList);
        /* Newly added code for sending mail through MailJet START */
        EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
        /* Newly added code for sending mail through MailJet END */
        
        return rePay.id;
    }
    
    /* Agent raises Repayment Request */
    @AuraEnabled
    public static string insertRepaymentReq(String depositId, Decimal clnAmt, Decimal dmgAmt, Decimal grdAmt, Decimal redAmt, 
                                            Decimal arrAmt, Decimal othAmt, String othReason, Decimal tenAmt, String accId,
                                            String btnTxt, Integer tenCount, Date tenancyDate, String values, 
                                            String repayRequestId, String AGLLContactId) 
    {
        System.debug('Line 297 -> Finally ');
        system.debug('depositId>>>>'+depositId);
        system.debug('accId>>>>'+accId);
        system.debug('btnTxt>>>>'+btnTxt);
        system.debug('tenCount>>>>'+tenCount);
        system.debug('tenInfo>>>>'+values);
        Repayment_Request__c rePay = new Repayment_Request__c();
        List<Repayment_Request_Line__c> rePayLineList = new List<Repayment_Request_Line__c>();
        List<Repayment_Request_Line__c> deleteRePayLineList = new List<Repayment_Request_Line__c>();
        
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
        Case newCase = new Case(RecordTypeId = caseRecordType, AccountId = accId, Deposit_Account_Number__c = depositId, 
                                OwnerId =  UserInfo.getUserId(), Origin = Label.Web, Status = Label.Repayment_requested_agent_landlord, 
                                Scheme__c = Label.EW_Custodial, Subject = Label.RepaymentRequestedForTenant, 
                                Description = Label.RepaymentRequestedForTenant);
        insert newCase;
        
        if(String.IsBlank(repayRequestId)) {
            rePay = new Repayment_Request__c();
        } else {
            rePay = new Repayment_Request__c(Id=repayRequestId);
        }        
        
        if(clnAmt!=null) {
            rePay.AL_CleaningAmt__c = clnAmt;
        } else {
            rePay.AL_CleaningAmt__c = 0.00;
        }
        
        if(dmgAmt!=null) {
            rePay.AL_DmgPropAmt__c = dmgAmt;
        } else {
            rePay.AL_DmgPropAmt__c = 0.00;
        }
        
        if(grdAmt!=null) {
            rePay.AL_GardeningAmt__c = grdAmt;
        } else {
            rePay.AL_GardeningAmt__c = 0.00;
        }
        
        if(othAmt!=null) {
            rePay.AL_OtherAmt__c = othAmt;
        } else {
            rePay.AL_OtherAmt__c = 0.00;
        }
        
        if(String.IsNotBlank(othReason)) {
            rePay.AL_Other_Reason__c = othReason;
        } else {
            rePay.AL_Other_Reason__c = '';
        }
        
        if(redAmt!=null) {
            rePay.AL_RedecorationAmt__c = redAmt;
        } else {
            rePay.AL_RedecorationAmt__c = 0.00;
        }
        
        if(arrAmt!=null) {
            rePay.AL_Rent_Arrears__c = arrAmt;
        } else {
            rePay.AL_Rent_Arrears__c = 0.00;
        }
        
        rePay.AL_Repay_Requested__c = true;
        rePay.Deposit__c = depositId;
        rePay.Case__c = newCase.Id;
        rePay.Account__c = accId;
        rePay.Status__c = Label.Repayment_requested_agent_landlord;
        rePay.Tenancy_End_Date__c = tenancyDate;
        rePay.Total_Amount_Requested_AL__c = rePay.AL_CleaningAmt__c+rePay.AL_DmgPropAmt__c+rePay.AL_GardeningAmt__c+rePay.AL_OtherAmt__c+rePay.AL_RedecorationAmt__c+rePay.AL_Rent_Arrears__c;
        rePay.Contact__c = AGLLContactId;
        
        if(String.IsBlank(repayRequestId)) {
            insert rePay;
        } else {
            update rePay;
        }
        
        List<Object> results = (List<Object>) JSON.deserializeUntyped(values);
        Map<String, Object> m = new Map<String, Object>();
        Map<String, Decimal> mapTenantIdTenantValue = new Map<String, Decimal>();
        
        if(results!=null && !results.isEmpty()) {
            for (Object obj: results) {
                m = (Map<String, Object>)obj;
                mapTenantIdTenantValue.put((String)m.get('key'),(Decimal)m.get('value'));
                System.debug('++++++++++++++'+mapTenantIdTenantValue);
                System.debug('++++++++++++++'+(Map<String, Object>)obj);
            }
        }
        
        if(String.IsNotBlank(repayRequestId)){
            for(Repayment_Request_Line__c repayLines : [SELECT Id from Repayment_Request_Line__c where Repayment_Request__c =:repayRequestId ]){
                deleteRePayLineList.add(repayLines);
            }           
        }
        
        if(!deleteRePayLineList.isEmpty()){
            delete deleteRePayLineList;
        }
        List<Deposit_Allocation__c> depositAllocations = [SELECT Id,Deposit_Holder__c,Is_Lead__c,Deposit__r.Deposit_Amount__c,
                                                          Deposit__r.Protected_Amount__c, Deposit__r.Customer__r.Name, Deposit__r.Customer__c
                                                          from Deposit_Allocation__c where Deposit__c =:depositId AND Role__c='Tenant' Order By Is_Lead__c desc];
        for(Deposit_Allocation__c depositAll : depositAllocations) {
            Repayment_Request_Line__c rePayLine = new Repayment_Request_Line__c();
            rePayLine.Repayment_Request__c = rePay.id;
            //rePayLine.Tenant_ReqAmt__c = ;
            rePayLine.Account__c = depositAll.Deposit_Holder__c;
            /*if(btnTxt == System.Label.OnlyLead && depositAll.Is_Lead__c){
            rePayLine.AL_ReqAmt__c = depositAll.Deposit__r.Protected_Amount__c;
            }else if(btnTxt == System.Label.OnlyLead && !depositAll.Is_Lead__c){
            rePayLine.AL_ReqAmt__c = 0;
            }else if(btnTxt == System.Label.AllTenantEqual ){
            rePayLine.AL_ReqAmt__c = depositAll.Deposit__r.Protected_Amount__c/tenCount;                
            }else{
            rePayLine.AL_ReqAmt__c = mapTenantIdTenantValue.get(depositAll.Deposit_Holder__c);
            }
            if(depositAll.Is_Lead__c){
            rePayLine.Is_Lead__c = true;
            }*/
            if(btnTxt == 'yes' || btnTxt == 'novvalueafterchange') {
                rePayLine.AL_ReqAmt__c = mapTenantIdTenantValue.get(depositAll.Deposit_Holder__c);
            }
            if(btnTxt == 'no') {
                rePayLine.AL_ReqAmt__c = depositAll.Deposit__r.Protected_Amount__c/tenCount;
            }
            rePayLine.Repayment_Requested_Mail_Sent__c = System.today();
            rePayLine.Requested_By__c = Label.Agent_Landlord;
            rePayLineList.add(rePayLine);           
        }
        if(!depositAllocations.isEmpty()) {
            Repayment_Request_Line__c rePayLine = new Repayment_Request_Line__c();
            rePayLine.Repayment_Request__c = rePay.id;
            rePayLine.Account__c = depositAllocations[0].Deposit__r.Customer__c;
            rePayLine.AL_ReqAmt__c = rePay.Total_Amount_Requested_AL__c;
            rePayLine.Contact__c = AGLLContactId;
            /*if(btnTxt == 'yes' || btnTxt == 'novvalueafterchange'){
            rePayLine.AL_ReqAmt__c = mapTenantIdTenantValue.get(depositAll.Deposit_Holder__c);
            }
            if(btnTxt == 'no'){
            rePayLine.AL_ReqAmt__c = depositAll.Deposit__r.Protected_Amount__c/tenCount;
            }*/
            rePayLine.Repayment_Requested_Mail_Sent__c = System.today();
            rePayLine.Requested_By__c = Label.Agent_Landlord;
            rePayLineList.add(rePayLine);      
        }
        
        if(rePayLineList != null && !rePayLineList.isEmpty()){
            insert rePayLineList;
        }
        
        Deposit__c deposit = new Deposit__c(Id = depositId, Status__c = 'Repayment requested by agent/landlord', End_Date__c = tenancyDate);
        update deposit;
        sendEmailThroughMailJetUtility(rePay.id);
        return rePay.id;
    }
    
    /*@AuraEnabled
    public static Repayment_Request__c getRepaymentRequestDetails(String repaymentRecordId) {
        Repayment_Request__c repaymentRequest = new Repayment_Request__c();
        repaymentRequest = [SELECT id,AL_CleaningAmt__c,AL_DmgPropAmt__c, AL_GardeningAmt__c, AL_Other_Reason__c, 
                            AL_OtherAmt__c, AL_RedecorationAmt__c, AL_Rent_Arrears__c, AL_Repay_Requested__c,Tenancy_End_Date__c, 
                            Total_Amount_Requested_AL__c,Deposit__r.Protected_Amount__c,Deposit__c,Account__r.Name
                            from Repayment_Request__c where Id =:repaymentRecordId];
        return repaymentRequest;
    }*/
    
    @AuraEnabled
    public static List<Repayment_Request_Line__c> getRepaymentRequestLineDetails(String repaymentRecordId) {
        List<Repayment_Request_Line__c> repaymentRequestLine = new List<Repayment_Request_Line__c>();
        repaymentRequestLine = [SELECT id, Account__r.Name,AL_ReqAmt__c,Repayment_Request__c,Tenant_ReqAmt__c
                                from Repayment_Request_Line__c where Repayment_Request__c =:repaymentRecordId and Requested_By__c = :Label.Agent_Landlord 
                                and Account__r.RecordType.Name=:Label.Tenant];
        return repaymentRequestLine;
    }
    
    @AuraEnabled
    public static String deleteDetailsOfRepaymentRequest(String repaymentRecordId) {
        Repayment_Request__c repaymentRequest = new Repayment_Request__c();
        repaymentRequest = [SELECT id,Deposit__c from Repayment_Request__c where Id =:repaymentRecordId];
        Case cs = [Select id from Case where Deposit_Account_Number__c = :repaymentRequest.Deposit__c and Status='Repayment requested - agent/landlord'];
        try{             
            delete repaymentRequest;
            delete cs;
            return 'deleted';
        }
        catch (Exception e) {
            return e.getmessage();
        }
    }
    
    @AuraEnabled
    public static string submitRepaymentRequestDetails(String repaymentRecordId) {
        
        sendEmailThroughMailJetUtility(repaymentRecordId);
        return 'test';
    }
    
    public static string sendEmailThroughMailJetUtility(String repaymentRecordId) {
        
        List<Repayment_Request_Line__c> repaymentRequestLine = new List<Repayment_Request_Line__c>();
        repaymentRequestLine = [SELECT id,Is_Lead__c, Account__r.Name,Account__r.PersonEmail,AL_ReqAmt__c,Repayment_Request__c, 
                                Tenant_ReqAmt__c,Repayment_Request__r.Deposit__r.Name,Repayment_Request__r.Deposit__r.Property_Address__c,
                                Repayment_Request__r.AL_CleaningAmt__c,Repayment_Request__r.AL_DmgPropAmt__c, 
                                Repayment_Request__r.AL_RedecorationAmt__c,Repayment_Request__r.AL_GardeningAmt__c, 
                                Repayment_Request__r.AL_Rent_Arrears__c,Repayment_Request__r.AL_OtherAmt__c,Repayment_Request__r.AL_Other_Reason__c, 
                                Repayment_Requested_Mail_Sent__c, Repayment_Request__r.Deposit__r.Protected_Amount__c, 
                                Repayment_Request__r.Total_Amount_By_Agent_Landlord__c, Account__r.RecordType.Name, 
                                Account__r.Email__c, Repayment_Request__r.Case__c,Contact__c, 
                                Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c,Account__r.personContactId
                                from Repayment_Request_Line__c 
                                where Repayment_Request__c=:repaymentRecordId];
        Decimal amtToAgent=0;
        Decimal amtToTenant=0;
        String agllClaim='';
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        if(!repaymentRequestLine.isEmpty()) {
            amtToAgent=repaymentRequestLine[0].Repayment_Request__r.Total_Amount_By_Agent_Landlord__c;
            
            
            for(Repayment_Request_Line__c repReq:repaymentRequestLine) {
                if(repReq.AL_ReqAmt__c>0 && repReq.AL_ReqAmt__c!=null) {
                    amtToTenant=amtToTenant+repReq.AL_ReqAmt__c;
                }
            }
            amtToTenant=amtToTenant-amtToAgent;
            
            agllClaim+= 'Agent/lanlord\'s claim is for:<br/>';
            agllClaim+= '<table border="1">';
            if(repaymentRequestLine[0].Repayment_Request__r.AL_CleaningAmt__c>0 && repaymentRequestLine[0].Repayment_Request__r.AL_CleaningAmt__c!=null) {
                agllClaim+= '<tr><td>Cleaning</td>'+'<td>'+'£'+repaymentRequestLine[0].Repayment_Request__r.AL_CleaningAmt__c+'</td></tr>';
            }
            if(repaymentRequestLine[0].Repayment_Request__r.AL_DmgPropAmt__c>0 && repaymentRequestLine[0].Repayment_Request__r.AL_DmgPropAmt__c!=null) {
                agllClaim+= '<tr><td>Damage</td>'+'<td>'+'£'+repaymentRequestLine[0].Repayment_Request__r.AL_DmgPropAmt__c+'</td></tr>';
            }
            if(repaymentRequestLine[0].Repayment_Request__r.AL_RedecorationAmt__c>0 && repaymentRequestLine[0].Repayment_Request__r.AL_RedecorationAmt__c!=null) {
                agllClaim+= '<tr><td>Redecoration</td>'+'<td>'+'£'+repaymentRequestLine[0].Repayment_Request__r.AL_RedecorationAmt__c+'</td></tr>';
            }
            if(repaymentRequestLine[0].Repayment_Request__r.AL_GardeningAmt__c>0 && repaymentRequestLine[0].Repayment_Request__r.AL_GardeningAmt__c!=null) {
                agllClaim+= '<tr><td>Gardening</td>'+'<td>'+'£'+repaymentRequestLine[0].Repayment_Request__r.AL_GardeningAmt__c+'</td></tr>';
            }
            if(repaymentRequestLine[0].Repayment_Request__r.AL_Rent_Arrears__c>0 && repaymentRequestLine[0].Repayment_Request__r.AL_Rent_Arrears__c!=null) {
                agllClaim+= '<tr><td>Rent Arrears</td>'+'<td>'+'£'+repaymentRequestLine[0].Repayment_Request__r.AL_Rent_Arrears__c+'</td></tr>';
            }
            if(repaymentRequestLine[0].Repayment_Request__r.AL_OtherAmt__c>0 && repaymentRequestLine[0].Repayment_Request__r.AL_OtherAmt__c!=null) {
                agllClaim+= '<tr><td>Other</td>'+'<td>'+'£'+repaymentRequestLine[0].Repayment_Request__r.AL_OtherAmt__c+'</td></tr>';
                agllClaim+= '<tr><td>Other(reason)</td>'+'<td>'+repaymentRequestLine[0].Repayment_Request__r.AL_Other_Reason__c+'</td></tr>';
            }
            agllClaim+= '</table><br/>';
                
        }
        
        System.debug('Line 658 repaymentRequestLine -> '+repaymentRequestLine);
        string tenantData = '<table>';
        Decimal tenantAmount = 0.00;
        
        // Declaring EmailWrapper in EI_SDS_MailJetUtilityCls class
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        //List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList1 = new List<EI_SDS_MailJetUtilityCls.recipient>();
        
        if(repaymentRequestLine!=null && !repaymentRequestLine.isEmpty()) {
            for(Repayment_Request_Line__c repaymentLine : repaymentRequestLine) {
                if(repaymentLine.Account__r.RecordType.Name=='Tenant')
                {
                    tenantData+= '<tr>';
                    tenantData+= '<td>'+repaymentLine.Account__r.Name+':'+'<td>';
                    tenantData+= '<td>'+'£'+repaymentLine.AL_ReqAmt__c+'<td>';
                    tenantData+= '</tr>';
                }
                if(repaymentLine.AL_ReqAmt__c!=null) {
                    tenantAmount = tenantAmount+repaymentLine.AL_ReqAmt__c;
                }
            }
            tenantData+= '</table><br/><br/>'+agllClaim;
            
            for(Repayment_Request_Line__c repaymentLine : repaymentRequestLine) {
                //if(repaymentLine.Account__r.PersonEmail!=null) 
                if(repaymentLine.Account__r.RecordType.Name=='Tenant') {
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentLine.Account__r.PersonEmail, 
                                                                                  repaymentLine.Account__r.Name, 
                                                                                  repaymentLine.Repayment_Request__r.Case__c, repaymentLine.Account__r.personContactId));
					
                    Map<String, String> variableMap = new Map<String, String>();
                    Date deadlineDate = EI_UtilityClassForPayments.dueDateMethod(repaymentLine.Repayment_Requested_Mail_Sent__c, 30);
                    String deadlineDateStr = deadlineDate.day()+'/'+deadlineDate.month()+'/'+deadlineDate.year();
                    
                    variableMap.put('Date', todayStr);
                    variableMap.put('name', repaymentLine.Account__r.Name);
                    variableMap.put('DAN', repaymentLine.Repayment_Request__r.Deposit__r.Name);
                    variableMap.put('Address', repaymentLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
                    variableMap.put('agentAmount', String.valueOf(amtToAgent.setScale(2)));
                    variableMap.put('TenantAmount', String.valueOf(amtToTenant.setScale(2)));
                    variableMap.put('claimDetails', tenantData);
                    variableMap.put('deadlinedate', deadlineDateStr);
                    variableMap.put('respondToProposalLink', 'https://staging-thedisputeservice.cs122.force.com/Sds/s/login/');
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'RepaymentRequestToTenant', 
                                                                                   'Deposit repayment request - response required '
                                                                                   +repaymentLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                                  ));
                }
                else if(repaymentLine.Account__r.RecordType.Name!='Tenant') {
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    
                    if(repaymentLine.Account__r.PersonEmail!=null) {
                        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentLine.Account__r.PersonEmail, 
                                                                                  repaymentLine.Account__r.Name, 
                                                                                  repaymentLine.Repayment_Request__r.Case__c, repaymentLine.Account__r.personContactId));
                    }
                    else if(repaymentLine.Account__r.Email__c!=null) {
                        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentLine.Account__r.Email__c, 
                                                                                  repaymentLine.Account__r.Name, 
                                                                                  repaymentLine.Repayment_Request__r.Case__c, repaymentLine.Account__r.personContactId));
                    }
                    
                    Map<String, String> variableMap = new Map<String, String>();
                    variableMap.put('Date', todayStr);
                    variableMap.put('name', repaymentLine.Account__r.Name);
                    variableMap.put('DAN', repaymentLine.Repayment_Request__r.Deposit__r.Name);
                    variableMap.put('Address', repaymentLine.Repayment_Request__r.Deposit__r.Property_Address__c);
                    variableMap.put('agentAmount', String.valueOf(amtToAgent.setScale(2)));
                    variableMap.put('TenantAmount', String.valueOf(amtToTenant.setScale(2)));
                    variableMap.put('claimDetails', tenantData);
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'RepaymentRequestToAgentLandlord', 
                                                                                   'Confirmation of repayment request - '
                                                                                   +repaymentLine.Repayment_Request__r.Deposit__r.Property_Address__c
                                                                                  ));
                }
            }
            
        }
        if(!emailWrapperList.isEmpty())
        {
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 
        }
        System.debug('Line 740 emailWrapperList -> '+emailWrapperList);
        
        return '';
    }
    
    @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel() {
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt];
        return allError;
    }  
    
}