public without sharing class TenantAvailableDeposit {
    
    @AuraEnabled
    public static contact displayLoggedInTenantInfo(){
        Contact con = [SELECT Id,AccountId__c,OneTimeUpdate__c,Salutation, Authorized_Person__c,Title, FirstName, LastName,Email, Phone, Property_Name__c, 
                       MailingStreet, MailingCity,MailingState, Email_Opt_in__c,Post_opt_in__c,SMS_opt_in__c,MailingCountry, 
                       MailingPostalCode, Prescribed_Information_clauses__c, Bank_Name__c,LandLord_Registration_Number__c, 
                       Bank_Account_Name__c, Sort_Code__c,Tenant_Details_Not_Viewable__c, Account_Number__c, Marketing_Agreement__c, Newsletter_Subscription__c,
                       Marketing_Options__c FROM Contact where Id IN (SELECT ContactId from User 
                       where Id = :UserInfo.getUserId()) LIMIT 1];

        return con;
    }
    
    @Auraenabled
    public static List<Deposit_Allocation__c> getLoggedInTenantDeposits() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Property_Address_Without_Postcode__c,Deposit__r.Name,Number_Of_Attempts__c
                                                       from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit_Status__c=:Label.Unvalidated and Deposit__r.Status__c !=null]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
        return depositAllocationList;
    }
    
    @Auraenabled
    public static List<Deposit_Allocation__c> getDepositsByStatus(String status) {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Deposit_Amount__c,Deposit__r.Number_Of_Tenants__c,Deposit__r.Name,
                                                       Deposit__r.Protected_Amount__c, Deposit__r.Start_Date__c,Deposit__r.Property_Address_Without_Postcode__c,Deposit__c,Deposit__r.Start_Date_Text__c,
                                                       Deposit__r.Property_Address__c from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit__r.Status__c=:status and Deposit_Status__c=:Label.Validated]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
        return depositAllocationList;
    }
    
     @Auraenabled
    public static List<Deposit_Allocation__c> getrepaymentbytenant() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Property_Address__c,Deposit__r.Name,Deposit__r.Deposit_Amount__c,
                                                       Deposit__r.Protected_Amount__c, Deposit__r.Start_Date_Text__c  from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit_Status__c=:Label.Validated and (Deposit__r.Status__c=:Label.Repayment_requested_by_tenant)]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
        system.debug(' line 49 repaymentbytenant' + depositAllocationList);
        return depositAllocationList;
    } 
    
     @Auraenabled
    public static List<Deposit_Allocation__c> getrepaymentbyagentlandlord() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Property_Address__c,Deposit__r.Name,Deposit__r.Deposit_Amount__c,
                                                       Deposit__r.Protected_Amount__c, Deposit__r.Start_Date_Text__c  from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit_Status__c=:Label.Validated and (Deposit__r.Status__c=:Label.Repayment_requested_by_agent_landlord)]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
        system.debug(' line 62 repaymentbyagentlandlord' + depositAllocationList);
        return depositAllocationList;
    } 
   
     
     @Auraenabled
    public static List<Deposit_Allocation__c> getselfresolution() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Property_Address__c,Deposit__r.Name,Deposit__r.Deposit_Amount__c,
                                                       Deposit__r.Protected_Amount__c, Deposit__r.Start_Date_Text__c  from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit_Status__c=:Label.Validated and (Deposit__r.Status__c=:Label.Self_resolution)]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
        system.debug(' line 76 selfresolution' + depositAllocationList);
        return depositAllocationList;
    }
    
   
    @Auraenabled
    public static List<Deposit_Allocation__c> getIndisputeresolution() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Property_Address__c,Deposit__r.Name,Deposit__r.Deposit_Amount__c,
                                                       Deposit__r.Protected_Amount__c, Deposit__r.Start_Date_Text__c  from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit_Status__c=:Label.Validated and (Deposit__r.Status__c=:Label.In_dispute_resolution)]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
        return depositAllocationList;
    }
    
    @Auraenabled
    public static List<Deposit_Allocation__c> getRepaymentprocess() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Property_Address__c,Deposit__r.Name,Deposit__r.Deposit_Amount__c,
                                                       Deposit__r.Protected_Amount__c, Deposit__r.Start_Date_Text__c
                                                       from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit_Status__c=:Label.Validated and (Deposit__r.Status__c=:Label.Repayment_process)]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
        return depositAllocationList;
    }
    
    @Auraenabled
    public static List<Deposit_Allocation__c> getDepositsrepaidinthelastyear() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Property_Address__c,Deposit__r.Name,Deposit__r.Deposit_Amount__c,
                                                       Deposit__r.Protected_Amount__c, Deposit__r.Start_Date_Text__c
                                                       from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit_Status__c=:Label.Validated and (Deposit__r.Status__c=:Label.Deposits_repaid_in_the_last_year)]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
        return depositAllocationList;
    }
    
     @Auraenabled
    public static List<Deposit_Allocation__c> getDepositsByPaidOrInDispute() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Property_Address__c,Deposit__r.Name, Deposit__r.Protected_Amount__c
                                                       from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit_Status__c=:Label.Validated and (Deposit__r.Status__c=:Label.Repayment_requested_by_tenant OR Deposit__r.Status__c=:Label.Repayment_requested_by_agent_landlord OR Deposit__r.Status__c=:Label.Self_resolution OR Deposit__r.Status__c=:Label.In_dispute_resolution OR Deposit__r.Status__c=:Label.Repayment_process OR Deposit__r.Status__c=:Label.Deposits_repaid_in_the_last_year)]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
        return depositAllocationList;
    }
    
    
    @Auraenabled
    public static list<Deposit_Allocation__c> getTenantDepositDetails(String depositid , String postcode ,integer month,integer year,/* String tenancyStartDate , */Decimal depositAmount) {
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        Id AccId = [Select id,AccountId From user where id=: UserInfo.getUserId()].AccountId;
       // Integer monthValue = Integer.valueOf(tenancyStartDate.substringAfter('-'));
      //  Integer yearValue = Integer.valueOf(tenancyStartDate.substringBefore('-'));
        Boolean validateInfo = false;
        String message = '';
      //  system.debug('++++monthValue++++++++'+monthValue+'++++++++++++'+yearValue);
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Property__r.Postal_Code__c,Deposit__r.Name,
                                                       Deposit__r.Protected_Amount__c, Deposit__r.Deposit_Amount__c,Deposit__r.Start_Date__c,Answered_Correctly__c,Number_Of_Attempts__c
                                                       from Deposit_Allocation__c where Deposit_Holder__c=:AccId and Deposit__c = :depositid ]){
            if(depositAllocation.Deposit__r.Start_Date__c.Month()==month && 
                depositAllocation.Deposit__r.Start_Date__c.Year()==year 
                && (depositAllocation.Deposit__r.Property__r.Postal_Code__c).trim().toLowercase()==(postcode).trim().toLowercase() && 
                depositAllocation.Deposit__r.Deposit_Amount__c==depositAmount){
                validateInfo = true;
            }

            // update number of attempts and Answered Correctly
            if(!validateInfo && depositAllocation.Number_Of_Attempts__c!=3){
                //depositAllocation.Answered_Correctly__c = Label.NoButton;
                depositAllocation.Answered_Correctly__c = 'No';
                if(depositAllocation.Number_Of_Attempts__c==null){
                    depositAllocation.Number_Of_Attempts__c = 1;
                }
                else{
                    depositAllocation.Number_Of_Attempts__c = depositAllocation.Number_Of_Attempts__c + 1;
                }
                depositAllocationList.add(depositAllocation);
               // message = 'wrongInfo';
            }
            else if(!validateInfo && depositAllocation.Number_Of_Attempts__c==3){
               // message = 'maximum limits';
            }
            else if(validateInfo){
                depositAllocation.Answered_Correctly__c = Label.YesButton;
                depositAllocation.Deposit_Status__c = Label.Validated;
                depositAllocationList.add(depositAllocation);
               // message = 'updated';
            }
        }
        
        if(!depositAllocationList.isEmpty()){
            update depositAllocationList;
        }
        return depositAllocationList;
    }
    
  /*  @Auraenabled
    public static List<Deposit__c> getDepositRecordsBySearchText(String searchText) {
        List<Deposit__c> depositList = new List<Deposit__c>();
        List<Deposit__c> depositListProperty = new List<Deposit__c>();
        Set<Id> setDepositIds = new Set<Id>();
        
        String searchTextValue = '%' + String.escapeSingleQuotes(searchText.trim()) + '%';
        system.debug('++++++++++++searchTextValue++++++++'+searchTextValue);
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__c from Deposit_Allocation__c where 
                                                       Deposit_Holder__c = :accountid  AND Deposit_Status__c=:Label.Validated 
                                                       AND (Deposit__r.Name like:searchTextValue OR Deposit_Holder__r.Name like:searchTextValue
                                                            OR Deposit__r.Property_Address__c like:searchTextValue)]){
                                                                setDepositIds.add(depositAllocation.Deposit__c);                 
                                                            }
        for(Property__c prop : [SELECT Id,(Select id from Deposits__r) FROM Property__c 
                                                        where id in (Select Property__c from Property_Allocation__c  
                                                                     where Contact__r.Name like:searchText)]){
            depositListProperty.addall(prop.Deposits__r);                 
        }
        if(!depositListProperty.isEmpty()){
            for(Deposit__c deposit : depositListProperty){
                setDepositIds.add(deposit.Id);                
            }
        }
        for(Deposit__c deposit : [SELECT Id,Name,Deposit_Account_Number__c,Property_Address__c,Start_Date__c,Start_Date_Text__c,Deposit_Amount__c,Number_of_Tenants_Value__c 
                                  from Deposit__c where ID IN: setDepositIds]){
                                      depositList.add(deposit);                
                                  }
        system.debug('++++++++++++depositList++++++++'+depositList);
        return depositList;
    }  */
    
     @Auraenabled
    public static List<Deposit__c> getDepositRecordsBySearchText(String searchText) {
        	 
        List<Deposit__c> depositList = new List<Deposit__c>();
        List<Deposit__c> depositListProperty = new List<Deposit__c>();
        Set<Id> setDepositIds = new Set<Id>();
        
        String searchTextValue = '%' + String.escapeSingleQuotes(searchText.trim()) + '%';
        system.debug('++++++++++++searchTextValue++++++++'+searchTextValue);
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__c from Deposit_Allocation__c where 
                                                       Deposit_Holder__c = :accountid  AND Deposit_Status__c=:Label.Validated 
                                                       AND (Deposit__r.Name like:searchTextValue OR Deposit_Holder__r.Name like:searchTextValue
                                                            OR Deposit__r.Property_Address__c like:searchTextValue)]){
                                                                setDepositIds.add(depositAllocation.Deposit__c);                 
                                                            }
        for(Property__c prop : [SELECT Id,(Select id from Deposits__r) FROM Property__c 
                                                        where id in (Select Property__c from Property_Allocation__c  
                                                                     where Contact__r.Name like:searchText)]){
            depositListProperty.addall(prop.Deposits__r);                 
        }
        if(!depositListProperty.isEmpty()){
            for(Deposit__c deposit : depositListProperty){
                setDepositIds.add(deposit.Id);                
            }
        }
        for(Deposit__c deposit : [SELECT Id,Name,Deposit_Account_Number__c,Property_Address__c,Start_Date__c,Protected_Amount__c,Deposit_Amount__c,Start_Date_Text__c,Number_of_Tenants_Value__c,Status__c	
                                from Deposit__c where ID IN: setDepositIds]){
                                    depositList.add(deposit);                
                                  }
       /* for(Deposit_Allocation__c depositall :[SELECT Id,Deposit__r.Number_of_Tenants_Value__c,Deposit__r.Deposit_Amount__c,Deposit__r.Number_Of_Tenants__c,Deposit__r.Name,
                                                       Deposit__r.Start_Date__c,Deposit__r.Property_Address_Without_Postcode__c,Deposit__c,Deposit__r.Start_Date_Text__c,
            Deposit__r.Property_Address__c from Deposit_Allocation__c where Deposit__c IN: setDepositIds]){
              depositList.add(depositall);  
            }*/
        system.debug('++++++++++++depositList++++++++'+depositList);
        system.debug('++++++++++++depositListsize++++++++'+depositList.size());
        return depositList;	
    }
    
    @AuraEnabled
    public static Map<String, String> tenentSalutation(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        system.debug('line ---> 180' + options);
        return options;
    }
    
    @Auraenabled
    public static List<Deposit_Allocation__c> getActiveDepositDetails() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit__r.Property_Address_Without_Postcode__c,Deposit__r.Name
                                                       from Deposit_Allocation__c where Deposit_Holder__c = :accountid
                                                       and Deposit__r.Active__c=true and Deposit__r.Status__c!=:Label.Deposit_Closed]){                                                       
                                                           depositAllocationList.add(depositAllocation);                 
                                                       }
           system.debug('++++++++++++depositAllocationList++++++++'+depositAllocationList);                                              
        return depositAllocationList;
    }
    
    @AuraEnabled 
    public static string deActivateTenantAccount(){
        User u = [select Id, contact.name,MemberId__c,contactId,email,accountid,
                  IsActive from User where Id = :UserInfo.getUserId()];  
        if(u.ContactId !=Null || u.accountid !=Null){
            u.IsActive = false;
            update u;
        }
        return 'deactivated';
    }
    
    
    @AuraEnabled
    public static string updateContactTenantDetails(Contact con,String tenantFirstName, String tenantLastName,string title,string street,string town,string county,string country,string postcode ){
        SavePoint sp = Database.setSavePoint();
        try{
            if(con.FirstName != tenantFirstName){
              
               
                if(con.OneTimeUpdate__c != NULL){
                    con.OneTimeUpdate__c =  con.OneTimeUpdate__c + ' FirstName';}
                else{ con.OneTimeUpdate__c =  'FirstName';}
                 system.debug('update2 '+con.OneTimeUpdate__c);
            }
            if(con.LastName != tenantLastName){
                 if(con.OneTimeUpdate__c != NULL){
                     con.OneTimeUpdate__c = con.OneTimeUpdate__c +' LastName';}
                 else{ con.OneTimeUpdate__c =  'LastName';}
            
            }
            if(street!=null){
            con.MailingStreet = street;
            }
            if(town!=null){
            con.MailingCity = town;
            }
            if(county!=null){
            con.MailingState =county;
            }
            if(country!=null){
            con.MailingCountry = country;
            }
            if(postcode!=null){
            con.MailingPostalCode = postcode;
            }
            con.Salutation = title;
            update con;
            system.debug('line-->161' + con);
        }
        catch(Exception e){
            Database.rollback(sp);
        }   
        
        List<User> userlist = new List<User>();
        for(User user : [Select id,firstname,lastname,email,phone,Property_Name__c,Street,City,State,Country,
                        PostalCode from User where ContactId =:con.id limit 1]){
            boolean flag = false;
            if(con.firstname !=user.firstname){
                flag = true;
                user.firstname=con.firstname;
               // con.OneTimeUpdate__c = true;
            }
            if(con.lastname !=user.lastname){
                flag = true;
                user.lastname=con.lastname;
            }
            if(con.email !=user.Email){
                flag = true;
                user.email=con.Email;
            }
            if(con.phone !=user.phone){
                flag = true;
                user.phone=con.phone;
            }
            if(con.Property_Name__c !=user.Property_Name__c){
                flag = true;
                user.Property_Name__c=con.Property_Name__c;
            }
            if(con.MailingCity !=user.City){
                flag = true;
                user.City=con.MailingCity;
            }
            if(con.MailingState !=user.State){
                flag = true;
                user.State=con.MailingState;
            }
            if(con.MailingStreet !=user.Street){
                flag = true;
                user.Street=con.MailingStreet;
            }
            if(con.MailingCountry !=user.Country){
                flag = true;
                user.Country=con.MailingCountry;
            }
            if(con.MailingPostalCode !=user.PostalCode){
                flag = true;
                user.PostalCode=con.MailingPostalCode;
            }
            if(flag){
                userlist.add(user);   
            }
        }
        if(userlist.size()>0){  
            update userlist ;  
            
        } 
        return con.id;
    } 
    
     @AuraEnabled
    public static string changeuserpassword(String newPassword, String verifyNewPassword, String oldPassword){
        
        string message = 'Success'; 
          if(!String.isBlank(newPassword) ){
        list<User> loggedInUser = [SELECT ID, ProfileId,email,profile.name
                                   FROM USER 
                                   WHERE Id = :UserInfo.getUserId() limit 1 ];
        if(!loggedInUser.isEmpty() && loggedInUser!=null){   
            try{
                      Site.changePassword(newPassword, verifyNewPassword,oldPassword);
                return message;     
            }
            catch(Exception e){
                 return e.getMessage();  
            }
        }
              else{
                  return null;
              }
          }
        else{
            return 'Error';
        }
       
    }
    
    @AuraEnabled
    public static string updateBankDetailsOfTenant(String accountNumber, String sortCode,String bankAccountName,String bankName, 
                                                    String accountId,String contactId){
        String message,isCorrect,bankNameInfo;
        String url = Label.Sort_Code_URL+getKey()+'&AccountNumber='+accountNumber+'&SortCode='+sortCode;
        system.debug('url***'+url);
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
            else if(message==''){
                message = message;
            }
            else{
                message = message;
            }
        }else{
            List<Bank_Account__c> bankdetails  = [select id,Account__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where Contact__c = :contactId limit 1 ];
            if(bankdetails!=null && !bankdetails.isEmpty()){
                Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
                updatebankdetails.Name=bankAccountName;
                updatebankdetails.Contact__c=bankdetails[0].Contact__c;
                updatebankdetails.Account_Number__c= accountNumber;
                updatebankdetails.Sort_Code__c = sortCode;
                updatebankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                updatebankdetails.Bank_Name__c = bankNameInfo;
                update updatebankdetails;
                message = 'successMessage';
            }
            else{
                Bank_Account__c insertbankdetails =new Bank_Account__c();
                insertbankdetails.Name=bankAccountName;
                insertbankdetails.Account__c=accountId;
                insertbankdetails.Contact__c=contactId;
                insertbankdetails.Account_Number__c= accountNumber;
                insertbankdetails.Sort_Code__c = sortCode;
                insertbankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                insertbankdetails.Bank_Name__c = bankNameInfo;
                insert insertbankdetails;
                message = 'successMessage';         
            }
        }
        
        return message;
    }
    
    @AuraEnabled
    public static string updateIntBankDetailsOfTenant(String bankIntName,/* String bankIntaddress,*/String bankIntAccountName,String bankIdentificationCode,
                                                    String bankSwiftCode,String IBAN,String accountId,String contactId){
        String message='';
        List<Bank_Account__c> bankdetails  = [select id,IBAN__c,Swift_Code__c,BIC__c,Bank_Address__c,Account__c, Contact__c, International_Bank_Account_Holder_Name__c, International_Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where Contact__c =: contactId limit 1 ];
        if(bankdetails!=null && !bankdetails.isEmpty()){
            Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
            updatebankdetails.Contact__c=bankdetails[0].Contact__c;
            updatebankdetails.International_Bank_Account_Holder_Name__c= bankIntAccountName;
            updatebankdetails.International_Bank_Name__c = bankIntName;
            updatebankdetails.IBAN__c=IBAN;
            updatebankdetails.BIC__c= bankIdentificationCode;
           // updatebankdetails.Bank_Address__c = bankIntaddress;
            updatebankdetails.Swift_Code__c = bankSwiftCode;
            update updatebankdetails;
            message = 'successMessage';
        }
        else{
            Bank_Account__c insertbankdetails =new Bank_Account__c();
            insertbankdetails.Account__c = accountId;
            insertbankdetails.Contact__c = contactId;
            insertbankdetails.International_Bank_Account_Holder_Name__c= bankIntAccountName;
            insertbankdetails.International_Bank_Name__c = bankIntName;
            insertbankdetails.IBAN__c=IBAN;
            insertbankdetails.BIC__c= bankIdentificationCode;
          //  insertbankdetails.Bank_Address__c = bankIntaddress;
            insertbankdetails.Swift_Code__c = bankSwiftCode;
            insert insertbankdetails;
            message = 'successMessage';         
        }
        return message;
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
    
    @Auraenabled
    public static List<Bank_Account__c> displayBankDetails() {
        List<Bank_Account__c> bankdetails  = [select id,Account__c,IBAN__c,BIC__c,Bank_Address__c,Swift_Code__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c,International_Account_Number__c,International_Bank_Account_Holder_Name__c,International_Bank_Name__c, Sort_Code__c from Bank_Account__c  where Contact__c IN (SELECT ContactId from User where Id = :UserInfo.getUserId()) limit 1 ];     
        return bankdetails;
    }
    
    /*@Auraenabled
    public static List<Bank_Account__c> displayInternationalBankDetails() {
        List<Bank_Account__c> bankdetails  = [select id,Account__c,Bank_Address__c,Swift_Code__c, Contact__c, Bank_Account_Holder_Name__c,IBAN__c,BIC__c, Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where Contact__c IN (SELECT ContactId from User where Id = :UserInfo.getUserId()) and IBAN__c!='' limit 1 ];      
        return bankdetails;
    }*/
    
    @Auraenabled
    public static String passwordChangeOfTenant() {
        try{
            List<User> loggedInUser = [SELECT ID, ProfileId,email,profile.name FROM USER 
                                        WHERE Id = :UserInfo.getUserId() and profile.name='Tenant' limit 1 ];
            if(!loggedInUser.isEmpty() && loggedInUser!=null){             
                System.resetPassword(loggedInUser[0].Id, true);
            }
            return 'passwordReset';
        }
        catch(Exception e){
            return e.getmessage();
        }
    }
    
    @Auraenabled
    public static String updateAuthorizedPersonOfTenant(String authorizedPerson, String contactId) {
        try{
            Contact con = new Contact(id=contactId);
            con.Authorized_Person__c = authorizedPerson;
            update con;
            return 'updated';
        }
        catch(Exception e){
            return e.getmessage();
        }
    }
    
    @Auraenabled
    public static String updateMarketingDetails(Boolean market,Boolean news,Boolean checkboxEmail,
                                                Boolean checkboxSMS,Boolean checkboxPost,String optionSelected, String contactId) {
        try{
            Contact con = new Contact(id=contactId);            
            if(news!=null){
                con.Newsletter_Subscription__c = news;
            }
            else{
                con.Newsletter_Subscription__c = false;
            }
            if(market!=null){
                con.Marketing_Agreement__c = market;
                con.Marketing_Options__c = optionSelected;
                con.Post_opt_in__c = checkboxPost;
                con.SMS_opt_in__c = checkboxSMS;
                con.Email_Opt_in__c = checkboxEmail;
            }
            else{
                con.Marketing_Agreement__c = false;
                con.Marketing_Options__c = null;
                con.Post_opt_in__c = false;
                con.SMS_opt_in__c = false;
                con.Email_Opt_in__c = false;
            }
            update con;
            return 'updated';
        }
        catch(Exception e){
            return e.getmessage();
        }
    }
    
    @Auraenabled
    public static String updateTenantViewableDetailsInfo(String veiwableInfo, String contactId) {
        try{
            Contact con = new Contact(id=contactId);            
            if(veiwableInfo=='tenantDetailsViewable'){
                con.Tenant_Details_Viewable__c = true;
                con.Tenant_Details_Not_Viewable__c = false;
            }
            else if(veiwableInfo=='tenantDetailsNotViewable'){
                con.Tenant_Details_Not_Viewable__c = true;
                con.Tenant_Details_Viewable__c = false;
            }
            update con;
            return 'updated';
        }
        catch(Exception e){
            return e.getmessage();
        }
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
}