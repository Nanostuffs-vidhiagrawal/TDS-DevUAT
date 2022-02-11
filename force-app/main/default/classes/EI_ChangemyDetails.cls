public without sharing class EI_ChangemyDetails {
    
    @AuraEnabled
    public static User checkProfile(){
        
        try{
            User loggedInUser = [SELECT ID, ProfileId,profile.name,User_Type__c, Contact.Account.IsPersonAccount
                                 FROM USER
                                 WHERE Id = :UserInfo.getUserId()];
           
            return loggedInUser;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> getSalutation(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
          
        }
        return options;
    }
    
    @AuraEnabled
    public static contact displayLoggedInUserContactInfo(){
        Contact con = [SELECT Id,Salutation, Email, Phone, Phone_Code__c, Person_Enabled__c,AddressFormula__c,FirstName,LastName,HomePhone, MailingStreet, MailingCity, MailingState, 
                       MailingCountry, MailingPostalCode, Prescribed_Information_clauses__c,Prescribed_Clause_Reference__c, Marketing_Agreement__c,
                       Newsletter_Subscription__c,Job_role__c,Additional_Permission__c,
                       Account_Name__c,
                       Registered_Company_Name__c,
                       Trading_Name__c,
                       Company_Registration_Number__c,
                       Telephone_Number__c,Address__c
                       FROM Contact where Id IN (SELECT ContactId from User where Id = :UserInfo.getUserId()) LIMIT 1];
        System.debug('Line 32 con'+con);
        return con;
    }
    
    @AuraEnabled
    public static string updatemarkertingpreferences(Contact con){
        SavePoint sp = Database.setSavePoint();
        try{
            update con;
        }
        catch(Exception e){
            Database.rollback(sp);
        } 
        return con.id;
    }
    
   /* @AuraEnabled
    public static Bank_Account__c getbankaccountdetails(){
        User use = [select id,email,accountid,Contactid from user where id = : UserInfo.getUserId() LIMIT 1];
        Bank_Account__c accountdetails  = [select id,Account__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where contact__c=:use.contactid limit 1 ]; 
        return accountdetails;
    }*/
    
    @AuraEnabled
    public static Bank_Account__c getbankaccountdetails(string branchId){
        List<Bank_Account__c> bankList;
        if(branchId != null){
            bankList = [SELECT Id, Account__c, Contact__c,  Bank_Account_Holder_Name__c,
                                            Sort_Code__c,Account_Number__c,Bank_Name__c,Branch__c FROM Bank_Account__c
                                          WHERE Branch__c=: branchId LIMIT 1
                                         ];
        }else{
              bankList = [SELECT Id, Account__c, Contact__c,  Bank_Account_Holder_Name__c,
                                            Sort_Code__c,Account_Number__c,Bank_Name__c FROM Bank_Account__c
                                          WHERE  Contact__c IN (SELECT contactId FROM User where Id=: UserInfo.getUserId()) 
                                          LIMIT 1
                                         ];
        }
       
        if(bankList.size()>0){
            return bankList[0];
        } 
        return null;
    }
    
/*
    @AuraEnabled
    public static Contact getAccountDetails(){
        
        List<Contact> conList = [SELECT 
                                    Account_Name__c,
                                    Registered_Company_Name__c,
                                    Trading_Name__c,
                                    Company_Registration_Number__c,
                                    Telephone_Number__c,
                                    Address__c
                            FROM Contact
                            WHERE ID IN (SELECT ContactId FROM User WHERE Id=: UserInfo.getUserId())
                            ];       
        if(conList.size()>0){
            return conList[0];
        }
        else{
            return null;
        }
    }

*/
    
    @AuraEnabled
    public static List<Contact> updtOrgDetails(String accName, String regCompName, String tradName, String regCompNo, String telNum, String add, Contact con)
    {
        System.debug(accName+' accName');
        System.debug('regCompName '+regCompName);
        System.debug('tradName '+tradName); 
        System.debug('regCompNo '+regCompNo);
        System.debug('telNum '+telNum);
        System.debug('add '+add);
        System.debug('Con '+con);
        
        try
        {
            List<Contact> conList = [SELECT Id,
                                    Account_Name__c,
                                    Registered_Company_Name__c,
                                    Trading_Name__c,
                                    Company_Registration_Number__c,
                                    Telephone_Number__c,
                                    Address__c
                            FROM Contact
                            WHERE ID IN (SELECT ContactId FROM User WHERE Id=: UserInfo.getUserId()) ];       
            if(conList.size()>0)
            {
                
                conList[0].Account_Name__c = accName;
                conList[0].Registered_Company_Name__c = regCompName;
                conList[0].Trading_Name__c = tradName;
                conList[0].Company_Registration_Number__c = regCompNo;
                conList[0].Telephone_Number__c = telNum;
                conList[0].Address__c = add;
                
                conlist[0].MailingCountry = con.MailingCountry;
                conlist[0].MailingPostalCode = con.MailingPostalCode;
                conlist[0].MailingCity = con.MailingCity;
                conlist[0].MailingState = con.MailingState;
                conlist[0].MailingStreet = con.MailingStreet;
                update conList;
            }
            return conList;
        }
        catch(Exception e) {
            //get exception message
            throw new AuraHandledException(e.getMessage());
        }
        
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
    public static Account getCorrespondenceEmail(){
        User loggedInUserId = [SELECT Id, 
                                    Contact.AccountId, 
                                    Contact.Account.IsPersonAccount, 
                                    Profile.Name
                              FROM USER
                              WHERE ID =: UserInfo.getUserId()];
         System.debug('::LoggedInUser='+loggedInUserId);
        if(!loggedInUserId.Contact.Account.IsPersonAccount){
            List<Account> acc = [SELECT 
                                    DRM_email__c, 
                                    Finance_email__c, 
                                    Email__c
                                 FROM Account 
                                 WHERE Id=:loggedInUserId.Contact.AccountId];
            return acc[0];
        }
        else{
            return null;
        }
    }
    
     @AuraEnabled
    public static Contact updatePrescribedInfo(String prescribedInfo,String prescribedRefer){
        Contact con = [SELECT Id, Prescribed_Information_Clauses__c,Prescribed_Clause_Reference__c
                      FROM Contact 
                       WHERE ID IN (SELECT ContactId FROM USER WHERE Id=:UserInfo.getUserId())
                      ];
        con.Prescribed_Information_Clauses__c = prescribedInfo;
           con.Prescribed_clause_reference__c = prescribedRefer;
        UPDATE con;
        return con;
    }
  
   /* 
     @AuraEnabled
    public static string correspondEmailUpdate(Contact con){
        if(con != NULL){
            List<Account> aclist = new List<Account>();
            for(Account ac: [Select id,Email__c,DRM_email__c,Finance_email__c from Account where id=: con.AccountId]){
                    ac.Email__c = con.Account.Email__c;
                    ac.DRM_email__c = con.Account.DRM_email__c;
                    ac.Finance_email__c = con.Account.Finance_email__c;
                aclist.add(ac);
            }
            update aclist;
              return con.id;
        }
        else{
            return null;
        }
         
    } */
    
    @AuraEnabled
    public static string correspondEmailUpdate(Account acc){
        String message = '';
        if(acc != NULL){
            User loggedInUserId = [SELECT Id, Contact.AccountId, 
                                   Contact.Account.IsPersonAccount, Profile.Name 
                                   FROM USER
                                   WHERE ID =: UserInfo.getUserId()];
            if(!loggedInUserId.Contact.Account.IsPersonAccount){
                List<Account> accToUpdate = [SELECT Id,Name,DRM_email__c,
                                             Finance_email__c,Email__c
                                             FROM Account 
                                             WHERE Id=:loggedInUserId.Contact.AccountId
                                            ];
                if(accToUpdate.size()>0){
                    accToUpdate[0].DRM_email__c = acc.DRM_email__c;
                    accToUpdate[0].Finance_email__c = acc.Finance_email__c;
                    accToUpdate[0].Email__c = acc.Email__c;
                    update accToUpdate[0];
                    message = 'Updated';
                }else{
                    message = 'NotAllowed';
                }
            }else{
                message = 'NotAllowed';
            }
        }
        else{
            message = 'NothingToUpdate';
        }
        return message;
    }
    
        @AuraEnabled
    public static string contactInformationUpdate(Contact con,Boolean market,Boolean news, String contactSalutation, String contactPhoneCode){
        SavePoint sp = Database.setSavePoint();
        
        try{
          Boolean flag = false;
            con.Salutation = contactSalutation;
            if(market == true || news == true || market == false || news == false){
            flag= true;
            }
           // con.Marketing_Agreement__c = market;
          //  con.Newsletter_Subscription__c = news;
        
         //   update con;
            List<User> userlist = new List<User>();
        for(User user : [Select id,Title,username,firstname,lastname,email,phone from User where ContactId =:con.id limit 1]){
          
            //Boolean flagUsername = false;
            if(con.Salutation !=user.Title){
                flag = true;
                user.Title=con.Salutation;
            }
            if(con.firstname !=user.firstname){
                flag = true;
                user.firstname=con.firstname;
            }
            if(con.lastname !=user.lastname){
                flag = true;
                user.lastname=con.lastname;
            }
            if(con.email.trim() != user.Email){
                
                List<User> listUsers = [Select Id, Title, Username, Firstname, Lastname, Email, Phone from User 
                           where Email =: con.email.trim() OR Username =: con.email.trim()];
                
                String fullNameForSearch = con.firstname.trim() +' '+ con.lastname.trim();
                List<List<SObject>> searchList = [FIND :fullNameForSearch IN ALL FIELDS 
                                                  RETURNING Contact(ID WHERE Email=:con.email.trim()) ];

                if(listUsers.size()>=1)
                {
                    return 'Invalid';
                }
                else if(searchList[0].size() > 1 ){
                    return 'Invalid';
                }
                else
                {
                    flag = true;
                    user.email=con.Email;
                    user.username=con.Email;
                }
            } 
            
            if(con.phone !=user.phone){
                flag = true;
                user.phone=con.phone;
            }
            if(flag){
                userlist.add(user);   
            }
        }
        if(userlist.size()>0){  
            Database.SaveResult[] SR = Database.update(userlist, true);
            if(SR[0].isSuccess())
            {
                updateChangeDetailsOfContact(con.FirstName, con.LastName, con.Email, contactPhoneCode, con.Phone,con.HomePhone, contactSalutation, market, news, con.Id);    
            }
        }
            
            system.debug('line-->40' + con);
        }
        catch(Exception e){
            //throw all other exception message
            throw new AuraHandledException(e.getMessage());
        }
        
        return con.id;
    }  
   
    @Future
    public static void updateChangeDetailsOfContact(String contactFirstName, String contactLastName, String contactEmail, String contactPhoneCode, String contactPhone, String contactHomePhone,
                                                    String contactSalutation, Boolean market, Boolean news, String contactId)
    {
        Contact con = [Select Id, Name, Email, Phone_Code__c, Phone, Salutation, Marketing_Agreement__c, Newsletter_Subscription__c from Contact 
                        where Id =: contactId];
        con.FirstName = contactFirstName;
        con.LastName = contactLastName;
        con.Email = contactEmail;
        con.Phone = contactPhone;
        con.Phone_Code__c = contactPhoneCode;
        con.HomePhone = contactHomePhone;
        con.Salutation = contactSalutation;
        con.Marketing_Agreement__c = market;
        con.Newsletter_Subscription__c = news;
        
        update con;
    }
    /*
    @AuraEnabled
    public static string updateBankDetailsOfContact(String accountNumber, String sortCode,String bankAccountName,String bankName){
        User user = [select id, email, name,accountid, Contactid
                     from user
                     where id = :UserInfo.getUserId()
                     LIMIT 1];
        list<Bank_Account__c> bankdetails  = [select id,Account__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c, Sort_Code__c 
                                              from Bank_Account__c  where contact__c=:user.contactid limit 1 ]; 
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
            else{
                message = message;
            }
        }
        else{
            if(bankdetails.size()>0){
                Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
                updatebankdetails.Name=bankAccountName;
                updatebankdetails.Account__c=bankdetails[0].Account__c;
                updatebankdetails.Contact__c=bankdetails[0].Contact__c;
                updatebankdetails.Account_Number__c= Integer.ValueOf(accountNumber);
                updatebankdetails.Sort_Code__c = Integer.ValueOf(sortCode);
                updatebankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                updatebankdetails.Bank_Name__c = bankNameInfo;
                update updatebankdetails;
                message = 'successMessage';
                EI_AgentLandlordPostloginemails.updatebankdetails(user.Email,user.name);
                //ChangemyDetails.bankdetailchangeemail(user.contactId,user.accountid,user.Email);
                //  EI_MailsUsingMailjet.updatebankdetails(user.Email,user.name);
            }
            else {
                Bank_Account__c insertbankdetails =new Bank_Account__c();
                list<Bank_Account__c> newbankdetails = new list<Bank_Account__c>();
                insertbankdetails.Name=bankAccountName;
                insertbankdetails.Account__c=user.AccountId;
                insertbankdetails.Contact__c=user.ContactId;
                insertbankdetails.Account_Number__c= Integer.ValueOf(accountNumber);
                insertbankdetails.Sort_Code__c = Integer.ValueOf(sortCode);
                insertbankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                insertbankdetails.Bank_Name__c = bankNameInfo;
                newbankdetails.add(insertbankdetails);
                insert newbankdetails;  
                message = 'successMessage';
                EI_AgentLandlordPostloginemails.updatebankdetails(user.Email,user.name);
                // ChangemyDetails.bankdetailchangeemail(user.contactId,user.accountid,user.Email);    
                //  EI_MailsUsingMailjet.updatebankdetails(user.Email,user.name);     
            }
            
        }
        
        return message;
    } 
*/
 
/*@What : Validate Bank Detail from API and Save
 * 
 */    
     @AuraEnabled
    public static string updateBankDetailsOfContact(String accountNumber, String sortCode,String bankAccountName,String bankName, String branchId){
        //Variables
        String message,isCorrect,bankNameInfo;
        
        User user = [SELECT Id, Email, Name, AccountId, ContactId
                     FROM User
                     WHERE Id = :UserInfo.getUserId()
                    ];
        List<Bank_Account__c> bankdetails;
         if(branchId != null){
            bankdetails = [SELECT Id, Account__c, Contact__c,  Bank_Account_Holder_Name__c,
                                            Sort_Code__c,Account_Number__c,Bank_Name__c,Branch__c,Contact__r.Email,
                                              Contact__r.Name FROM Bank_Account__c
                                          WHERE Branch__c=: branchId LIMIT 1
                                         ];
         }else{
              bankdetails  = [SELECT Id,Account__c, Contact__c, Bank_Account_Holder_Name__c, 
                                              Bank_Name__c,Contact__r.Email,
                                              Contact__r.Name
                                              FROM Bank_Account__c  
                                              WHERE contact__c IN (SELECT ContactId FROM User where Id=:UserInfo.getUserId()) 
                                             LIMIT 1
                                             ]; 
         }
        
        
        
        String url = Label.Sort_Code_URL+getKey()+'&AccountNumber='+accountNumber+'&SortCode='+sortCode;
        
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
            if(bankdetails.size()>0){              
                
                Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
                updatebankdetails.Name=bankAccountName;
                updatebankdetails.Account_Number__c= accountNumber;
                updatebankdetails.Sort_Code__c = sortCode;
                updatebankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                updatebankdetails.Bank_Name__c = bankNameInfo;
                UPDATE updatebankdetails;
                message = updatebankdetails.Bank_Name__c;
                
                /* Newly added code for Utility mailjet START */
                List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(bankdetails[0].Contact__r.Email, bankdetails[0].Contact__r.Name, 
                                                                              '', bankdetails[0].Contact__c,bankdetails[0].Contact__c));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', System.today().format());
                variableMap.put('agentname', bankdetails[0].Contact__r.Name);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'ChangeOfPaymentDetails', 'Confirmation of change of payment details'));
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
                /* Newly added code for Utility mailjet END */
                
                //EI_AgentLandlordPostloginemails.updatebankdetails(bankdetails[0].Contact__r.Email,bankdetails[0].Contact__r.Name);              
            }
            else {
                Bank_Account__c insertbankdetails =new Bank_Account__c();
                insertbankdetails.Name=bankAccountName;
                insertbankdetails.Branch__c = branchId;
                insertbankdetails.Account__c=User.AccountId;
                insertbankdetails.Contact__c=User.ContactId;
                insertbankdetails.Account_Number__c= accountNumber;
                insertbankdetails.Sort_Code__c = sortCode;
                insertbankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                insertbankdetails.Bank_Name__c = bankNameInfo;
                insert insertbankdetails;  
                message = insertbankdetails.Bank_Name__c;
              //  EI_AgentLandlordPostloginemails.updatebankdetails(user.Email,user.name);
            }
            
        }
        
        return message;
    } 
    
    
    @AuraEnabled
    Public static void changeBankDetailSendEmailToContact(String conid,string accid,String st){
        List<string> stlist = new List<string>();
        stlist.add(st);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(conid); 
        message.setSenderDisplayName('Company Support'); 
        message.setReplyTo('no-reply@company.com');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false);
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Change of payment details'];
        message.setTemplateID(emailTemplate.Id);
        message.setWhatId(accid); //This is important for the merge fields in template to work
        message.toAddresses = (stlist);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success){
            System.debug('The email was sent successfully');
        } else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
    }   
    
    @AuraEnabled
    public static string changeAccountTypeAgentLandlord(){
        try{
            User userRecord = [Select id,Contact.AccountId,ProfileId,User_Type__c,ContactId,
                               MemberId__c,Old_Member_ID__c from User where id=:Userinfo.getUserId()];
            if(String.IsBlank(userRecord.Old_Member_ID__c)){
                system.debug('userRecord.User_Type__c '+userRecord.User_Type__c);
                if(userRecord.User_Type__c == 'Landlord'){
                    userRecord.Old_Member_ID__c = userRecord.MemberId__c;        
                    userRecord.MemberId__c = generateMemberId(userRecord.User_Type__c);
                    userRecord.User_Type__c = 'Agent';
                }else if(userRecord.User_Type__c == 'Agent'){
                    userRecord.Old_Member_ID__c = userRecord.MemberId__c;        
                    userRecord.MemberId__c = generateMemberId(userRecord.User_Type__c);
                    userRecord.User_Type__c = 'Landlord';
                }
            }
            else{
                String getMemberIdValue = userRecord.MemberId__c;
                if(userRecord.User_Type__c == 'Landlord'){
                    userRecord.MemberId__c = userRecord.Old_Member_ID__c;
                    userRecord.Old_Member_ID__c = getMemberIdValue;
                    userRecord.User_Type__c = 'Agent';
                }else if(userRecord.User_Type__c == 'Agent'){
                    userRecord.MemberId__c = userRecord.Old_Member_ID__c;
                    userRecord.Old_Member_ID__c = getMemberIdValue;
                    userRecord.User_Type__c = 'Landlord';
                }
            }
            //update userRecord;
            updateProfileId(userRecord.User_Type__c,userRecord.Old_Member_ID__c,userRecord.MemberId__c);    
            return 'Success';
        }
        catch(Exception e){
            return e.getmessage();
        }
    }
    
    /**
    * @description : Common Utility method generating Member Id
    * @param : String
    * @return : string
    **/    
    public static string generateMemberId(String userType){
        String fin='';  
        Integer abc;
        String MemID ='';
        MemberId__c  memberID = [Select Landlordid__c,AgentID__c,TenantID__c from MemberId__c limit 1];
        if(userType == 'Agent'){
            fin = String.valueOf(memberID.Landlordid__c);
            abc = Integer.valueOf(fin); 
            fin = 'L';
        }else if(userType == 'Landlord'){
            fin = String.valueOf(memberID.AgentID__c);
            abc = Integer.valueOf(fin); 
            fin = 'A';
        } 
        
        if(abc<10){
            fin = fin+'0000'+String.valueOf(abc+1); 
            MemID = '0000'+String.valueOf(abc+1);
        }else if(abc>10 && abc<100){
            fin = fin+'000'+String.valueOf(abc+1); 
            MemID = '000'+String.valueOf(abc+1);
        }
        else if(abc>100 && abc<1000){
            fin = fin+'00'+String.valueOf(abc+1);
            MemID = '00'+String.valueOf(abc+1);
        }
        else if(abc>1000 && abc<10000){
            fin = fin+'0'+String.valueOf(abc+1);  
            MemID = '0'+String.valueOf(abc+1);
        }
        else{
            fin = fin+String.valueOf(abc+1);  
            MemID = String.valueOf(abc+1);
        }
        
        system.debug('abcc '+fin);     
        fin = fin+'SC';
        updateMemberId(userType,MemID);
        return fin; 
    }
    
    /**
    * @description : Update User Profile Id
    * @param : String
    * @return : string
    **/
    @future(callout=true)
    public static void updateProfileId(String userType,String userOldMemberId,String userMemberId){
        Id agentProfileid = [Select id from profile where name =:Label.Agent_Profile_Name].id;
        Id landlordProfileid = [Select id from profile where name =:Label.Landlord_Profile_Name].id;
        String remoteURL ='';
        if(userType == 'Landlord'){
            remoteURL = Label.SiteURL + userInfo.getUserId()+'&profileId='+landlordProfileid+'&userType='+userType+'&userOldMemberId='+userOldMemberId+'&userMemberId='+userMemberId;
        }else if(userType == 'Agent'){
            remoteURL = Label.SiteURL + userInfo.getUserId()+'&profileId='+agentProfileid+'&userType='+userType+'&userOldMemberId='+userOldMemberId+'&userMemberId='+userMemberId;
        }
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setEndpoint(remoteURL);
        HttpResponse httpResponse = new Http().send(httpRequest);   
        
        system.debug('@@response '+httpResponse);
    }
    
    /**
* @description : Common Utility method generating Member Id
* @param : String
* @return : string
**/
    @future  
    public static void updateMemberId(String userType , String memberIdValue){
        MemberId__c  memberID = [Select Landlordid__c,AgentID__c,TenantID__c from MemberId__c limit 1];
        if(userType == 'Agent'){
            memberID.Landlordid__c = Decimal.valueof(memberIdValue);
        }else if(userType == 'Landlord'){
            memberID.AgentID__c = Decimal.valueof(memberIdValue);
        } 
        update memberID;
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
    public static List<string> getPhoneCodePiclistValues(){
        try {
            Schema.DescribeFieldResult fieldDescription = Contact.Phone_Code__c.getDescribe();
            List<String> countryCodes = new List<String>();
            for (Schema.PicklistEntry cc : fieldDescription.getPicklistValues()) {
            
                if(cc.isActive()){
                    countryCodes.add(cc.getValue());
                }    
            }
            return countryCodes;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }

}