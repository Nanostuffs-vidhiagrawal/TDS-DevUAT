global  without sharing class EI_SignUpController {
    public EI_SignUpController() {  
    }
    
    @TestVisible 
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @AuraEnabled
    public static String selfRegister(
        String firstname ,String lastname, String email,string salutation,string Telephone,string phoneCode,string phone,
        string userType,Boolean OrgUSer,Boolean HoUser,
        string companyName,string companyPhoneCode,string companyPhone,string companyreg,string tradename,String LAid,string companyEmail,string companyDrmEmail, string companyFinanceEmail,
        string street, string city, string postcode, string country, string county, String draftId
        
    ) {
        Savepoint sp = null;
        try{
            sp = Database.setSavepoint();
            String fullNameForSearch = firstName.trim() +' '+ lastName.trim();
            String emailForSearch = email.trim();
            string BusinessType ;
            String password;
            id profileid;
            string usercontactid;
            Id AccountRecordTypeId;
            Account Acc;
            contact con;
            String EmailAccName;
            String IndividualName;
            String EmailSalutation;
            Boolean isUserExist = false;
            Id UserRecid =null;
            user userDetails11;
            List<user> userlistEmail = new List<user>();
            userlistEmail  =  [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive, user_type__c 
                                        from user where profile.UserLicense.Name ='Customer Community Login' 
                                        and email =:email.trim()];  
            
            
            if( userlistEmail.size() > 0 ) 
            {
                UserRecid = userlistEmail[0].id;
                isUserExist = true;
                userDetails11= userlistEmail[0];
            }
            else {
                if(HoUser){
                    BusinessType = 'Head office user';
                }else{
                    if(OrgUSer){
                        BusinessType='Organization';
                    }else{
                        BusinessType='Self';
                    }
                }
                if(userType =='Agent'){
                    if(HoUser){
                        profileid = [select id from profile where name ='Head Office User'].id;
                    }
                    else{
                        profileid = [select id from profile where name ='Agent'].id;
                    }
                    
                    if(OrgUSer){
                        AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
                    }else{
                        AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Letting_Agent').getRecordTypeId();
                    }
                }
                else{
                    if(userType =='Tenant'){
                        profileid = [select id from profile where name ='Tenant'].id; 
                        AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId();
                    }
                    else{
                        profileid = [select id from profile where name ='Landlord'].id; 
                        
                        if(OrgUSer){
                            AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                        }else{
                            AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId();
                        }
                    }
                }
             //   List<Contact> conlistTest = [Select id,name,email from Contact];
            //    system.debug('@@a '+conlistTest);
                system.debug(AccountRecordTypeId+' @AccountRecordTypeId');
                List<List<Contact>> searchList = [FIND :fullNameForSearch IN 
                                                  ALL FIELDS 
                                                  RETURNING  
                                                  Contact(ID, Name, Account.recordtypeId WHERE Email=:email.trim()) ];
                
                if(searchList[0].size() > 0){ 
                    List<Contact> conList = searchList[0];
                    Contact duplicateContact = conList[0];
                    if(duplicateContact.Account.recordtypeId == AccountRecordTypeId){
                    	isUserExist = false;
                        System.debug('searchList => ' + duplicateContact);
                        
                        List<Account> duplicateAccountList = [Select Id, PersonContactId, name, Associated_To__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, Phone, Email__c, PersonEmail
                                                              From Account Where PersonContactId =:usercontactid ];
                        
                        Account duplicateAccount = new Account();
                        if(duplicateAccountList.size() > 0){ 
                            duplicateAccount = duplicateAccountList[0];
                        }
                        
                        usercontactid = duplicateContact.Id;
                        EmailSalutation = salutation;
                        EmailAccName = 'n/a';
                        IndividualName = firstname +' '+lastname;
                        
                       
                        if (lastname == null || String.isEmpty(lastname)) {
                            return Label.Site.lastname_is_required;
                        }
                        if (email == null || String.isEmpty(email)) {
                            return Label.Site.email_is_required;
                        }
                        
                       
                        
                        User u = new User();
                        if(HoUser && userType =='Agent'){
                            u.User_Role__c = 'Head office administrator';
                        }
                        else if((userType =='Agent' || userType =='Landlord' || userType =='Tenant') && !HoUser){
                            u.User_Role__c = 'Account Administrator';
                        }
                        u.Title = salutation;
                        u.Username = email;
                        u.contactid =usercontactid;
                        u.put('Email',email);
                        u.ProfileId= AccountRecordTypeId;
                        u.FirstName = firstname;
                        u.LastName = lastname;
                        u.User_Type__c = userType;
                        u.Business_Type__c =BusinessType;
                        u.Phone =phone;
                        u.Street = street;
                        u.City = city;
                        u.PostalCode = postcode;
                        u.Country = country;
                        u.State = county;
                        String fullName = FirstName +LastName;
                        if(fullName.length()>=5){
                            u.alias = fullName.substring(0, 4);
                        }else{
                            u.alias = fullName;
                        }
                        u.TimeZoneSidKey = 'Europe/London'; 
                        u.LocaleSidKey = 'en_US'; 
                        u.EmailEncodingKey = 'ISO-8859-1';
                        u.LanguageLocaleKey = 'en_US'; 
                        u.UserPreferencesHideSelfInfluenceGetStarted = true;
                        String networkId = Network.getNetworkId();
                        if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                            u.put('UserPreferencesHideS1BrowserUI',true);
                        }
                        
                        String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
                        nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
                        u.put('CommunityNickname', nickname);
                       
                        if(String.isBlank(draftId) == false){
                            u.Move_To_Certificate_Payment__c = true;
                            Deposit__c dep = new Deposit__c(id=draftId, Customer__c = duplicateAccount.Id); 
                            update dep;
                        }
                        
                        Database.DMLOptions Dlo = new Database.DMLOptions();
                        
                        dlo.EmailHeader.TriggerUserEmail = true;
                        Database.SaveResult srList =database.insert(u,dlo);
                        
                        if(srList.getErrors().size() > 0){
                            for(Database.Error err : srList.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                                return String.valueOf(srList.getErrors());
                            }
                        }
                        
                        password = null;
                        String userId =u.id;
                        
                        if (userId != null) {
                            User umember = [select MemberId__c from user where id = : u.id];
                            
                            if(BusinessType == 'Head office user')
                            {
                                duplicateAccount.Associated_To__c =u.id;
                                update duplicateAccount;
                            }
                            
                            EmailTemplate templateId = [Select id,DeveloperName,Subject, HtmlValue, Body from EmailTemplate where DeveloperName  = 'welcomeemailforSDS'];
                            
                            Messaging.SingleEmailMessage singlemail =new Messaging.SingleEmailMessage();  
                            List<Attachment> files = [SELECT Name, Body, ContentType FROM Attachment WHERE ParentId =: templateId.Id];
                            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                            for (Attachment file: files) {
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                                efa.setFileName(file.Name);
                                efa.setBody(file.Body);
                                efa.setContentType(file.ContentType);
                                attachments.add(efa);
                            }
                            singlemail.setFileAttachments(attachments);
                            String htmlBody = templateId.HtmlValue;
                            
                            Date dtTodayDate = System.Today();
                            Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
                            string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                            
                            htmlBody = htmlBody.replace('{!Today}', strDate);
                            htmlBody = htmlBody.replace('{!Receiving_User.Title2}', EmailSalutation);
                            htmlBody = htmlBody.replace('{!Receiving_User.Title}', salutation);
                            
                            htmlBody = htmlBody.replace('{!User.Name}', IndividualName );
                            htmlBody = htmlBody.replace('{!Receiving_User.User_Company_Name__c}', EmailAccName);
                            htmlBody = htmlBody.replace('{!Receiving_User.Contact}', firstname +' '+lastname);
                            System.debug('postacode 318 '+duplicateAccount.BillingPostalCode);  
                            if(duplicateAccount.BillingPostalCode != null ){
                                htmlBody = htmlBody.replace('{!Receiving_User.StreetCustom__c}', duplicateAccount.BillingStreet);
                                htmlBody = htmlBody.replace('{!Receiving_User.City}', duplicateAccount.BillingCity);                
                                htmlBody = htmlBody.replace('{!Receiving_User.PostalCode}', duplicateAccount.BillingPostalCode); 
                                htmlBody = htmlBody.replace('{!Receiving_User.Country}', duplicateAccount.BillingCountry);
                            }
                            
                            htmlBody = htmlBody.replace('{!Receiving_User.Phone}', duplicateAccount.Phone); 
                            
                            htmlBody = htmlBody.replace('{!User.Username}', duplicateAccount.PersonEmail != null ? duplicateAccount.PersonEmail : duplicateAccount.Email__c);  
                            if(umember != null && umember.MemberId__c != null){
                                htmlBody = htmlBody.replace('{!Receiving_User.MemberId__c}', umember.MemberId__c); 
                                 //return 'umember not null  => '+umember;
                            }
                            
                            singlemail.setTargetObjectId(usercontactid);
                            singlemail.setTemplateId(templateId.id);
                            singlemail.setSubject('Welcome to SafeDeposits');
                            singlemail.setHtmlBody(htmlBody);
                            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singlemail});
                            
                            Contact contUpdate = new Contact(id =usercontactid,email = email );
                            update contUpdate;
                            
                            if(userType != 'Tenant'){
                                ApexPages.PageReference lgn = new PageReference('/Sds/s/welcomepage?uid='+umember.MemberId__c);
                                aura.redirect(lgn);
                            }
                            return 'User Create successfully';
                        }
                    } 
                }
            }
            
            
            if(isUserExist)
            {
                if(userDetails11 != null )
                { 
                    if(userDetails11.IsActive == false) {
                        if( userType == 'Tenant' && userType == userDetails11.user_type__c) {
                            userDetails11.isActive = true;
                            update userDetails11;
                            //site.forgotPassword(userDetails11.userName);
                            return 'User already have an account';
                        } 
                        else if((userType=='Agent'||userType=='Landlord')&&(userDetails11.user_type__c=='Agent'||userDetails11.user_type__c=='Landlord') )
                        {
                            userDetails11.IsActive = true;
                            update userDetails11;  
                            //site.forgotPassword(userDetails11.userName);
                            return 'User already have an account';
                        }
                    }
                }
                return 'Email is already registered';
            }
            else
            {
                if(HoUser)
                {
                    BusinessType = 'Head office user';
                }
                else
                {
                    if(OrgUSer)
                    {
                        BusinessType='Organization';
                    }
                    else
                    {
                        BusinessType='Self';
                    }
                }
                if(userType =='Agent')
                {
                    if(HoUser)
                    {
                        profileid = [select id from profile where name ='Head Office User'].id;
                    }
                    else
                    {
                        profileid = [select id from profile where name ='Agent'].id;
                    }
                    
                }
                else
                {
                    if(userType =='Tenant')
                    {
                        profileid = [select id from profile where name ='Tenant'].id; 
                    }
                    else
                    {
                        profileid = [select id from profile where name ='Landlord'].id; 
                    }
                    
                }
                
                if (lastname == null || String.isEmpty(lastname)) {
                    return Label.Site.lastname_is_required;
                }
                if (email == null || String.isEmpty(email)) {
                    return Label.Site.email_is_required;
                }
                if(OrgUSer)
                {
                    if(userType =='Agent')
                    {
                        AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
                        Acc = new Account(name =companyName,Phone_Code__c = companyPhoneCode,Phone =companyPhone,RecordTypeId=AccountRecordTypeId,Letting_Agent_Number__c =LAid,
                                          Email__c =companyEmail,DRM_email__c=companyDrmEmail,Finance_email__c=companyFinanceEmail,
                                          BillingStreet = street,BillingCity = city,BillingPostalCode = postcode,BillingCountry = country,BillingState = county);
                        EmailAccName = companyName;
                        IndividualName = companyName;
                        EmailSalutation = '';
                        insert Acc;
                        con  = new contact (Job_role__c='Head office administrator',AccountId =Acc.id,Salutation=salutation,FirstName =firstname,
                                            lastname =lastname,email =companyEmail,Phone_Code__c = phoneCode,Phone =phone,
                                            MailingStreet = street,MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,MailingState = county);
                        
                    }
                    else
                    {
                        AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                        Acc = new Account(name =companyName,Phone_Code__c = companyPhoneCode,Phone =companyPhone,RecordTypeId=AccountRecordTypeId,Email__c = email,
                                          BillingStreet = street,BillingCity = city,BillingPostalCode = postcode,BillingCountry = country,BillingState = county);
                        EmailAccName = companyName;
                        IndividualName = companyName;
                        EmailSalutation = '';
                        insert Acc;
                        con  = new contact (Job_role__c='Account administrator',AccountId =Acc.id,Salutation=salutation,FirstName =firstname,Company_Registration_Number__c=companyreg,Account_Status__c ='Active',
                                            Trading_Name__c=tradename,	
                                            lastname =lastname,email =email,Phone_Code__c = phoneCode,Phone =phone,
                                            MailingStreet = street,MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,MailingState = county);
                        
                    }
                    
                    
                    
                    insert con ;
                    usercontactid= con.id;
                }
                else
                {
                    if(userType =='Agent')
                    {
                        AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Letting_Agent').getRecordTypeId();
                    }
                    else if(userType =='Tenant')
                    {
                        AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId();
                    }
                    else
                    {
                        AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId();
                    }
                    
                    EmailSalutation = salutation;
                    Acc = new Account();
                    Acc.FirstName = firstname;
                    Acc.LastName = lastname;
                    Acc.Salutation =salutation;
                    Acc.PersonEmail=email;
                    Acc.Email__c = email;
                    Acc.PersonHomePhone =phone;
                    if(Telephone != NULL){
                        Acc.PersonOtherPhone = Telephone;
                    }
                      if(userType !='Tenant'){
                            Acc.Job_role__pc='Account administrator';}
                    Acc.Phone_Code__pc =phoneCode;
                    Acc.Phone = phone;
                    Acc.Account_Status__pc ='Active';
                    Acc.RecordTypeId  = AccountRecordTypeId;
                    acc.BillingStreet = street;
                    acc.BillingCity = city;
                    acc.BillingPostalCode = postcode;
                    acc.BillingCountry = country; 
                    acc.BillingState = county;
                    insert Acc; 
                    
                    usercontactid =[select id,PersonContactId from Account where id =:Acc.id].PersonContactId;
                    EmailAccName = 'n/a';
                    IndividualName = firstname +' '+lastname;
                    
                    con  = new contact (id =usercontactid,MailingStreet = street,MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,MailingState = county);
                    update con;
                }
                
                User u = new User();
                if(HoUser && userType =='Agent'){
                    u.User_Role__c = 'Head office administrator';
                }
                else if((userType =='Agent' || userType =='Landlord' || userType =='Tenant') && !HoUser){
                    u.User_Role__c = 'Account Administrator';
                }
                u.Title = salutation;
                u.Username = email;
                u.contactid =usercontactid;
                u.put('Email',email);
                u.ProfileId= profileid;
                u.FirstName = firstname;
                u.LastName = lastname;
                u.User_Type__c = userType;
                u.Business_Type__c =BusinessType;
                u.Phone =phone;
                u.Street = street;
                u.City = city;
                u.PostalCode = postcode;
                u.Country = country;
                u.State = county;
                String fullName = FirstName +LastName;
                if(fullName.length()>=5){
                    u.alias = fullName.substring(0, 4);
                }else{
                    u.alias = fullName;
                }
                u.TimeZoneSidKey = 'Europe/London'; 
                u.LocaleSidKey = 'en_US'; 
                u.EmailEncodingKey = 'ISO-8859-1';
                u.LanguageLocaleKey = 'en_US'; 
                u.UserPreferencesHideSelfInfluenceGetStarted = true;
                String networkId = Network.getNetworkId();
                if(networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                    u.put('UserPreferencesHideS1BrowserUI',true);
                }
                
                String nickname = ((firstname != null && firstname.length() > 0) ? firstname.substring(0,1) : '' ) + lastname.substring(0,1);
                nickname += String.valueOf(Crypto.getRandomInteger()).substring(1,7);
                u.put('CommunityNickname', nickname);
                
                // for certificate builder sign up flow
              /*  if(String.isBlank(draftId ) == false)
                    u.Move_To_Certificate_Payment__c = true;*/
               if(!String.isBlank(draftId)){
                    u.Move_To_Certificate_Payment__c = true;
                   // Deposit__c dep = [Select id,Customer__c from Deposit__c where id=: draftId];
                   Deposit__c dep = new Deposit__c(id=draftId, Customer__c = Acc.Id); 
                   // dep.Customer__c = Acc.Id;
                    update dep;
                }
                
                Database.DMLOptions Dlo = new Database.DMLOptions();
                dlo.EmailHeader.TriggerUserEmail = true;
                Database.SaveResult srList =database.insert(u,dlo);
                
                for(Database.Error err : srList.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
                
                password = null;
                String userId =u.id;
                User umember = [select MemberId__c from user where id = : u.id];
                if (userId != null) {
                    
                    // for cerificate builder signup flow
                   // if(String.isBlank(draftId) == false)
                     //   updateUserOnDraft(draftId, userId);
                    
                    if(BusinessType == 'Head office user')
                    {
                        Acc.Associated_To__c =u.id;
                        update acc;
                    }
                      if(userType != 'Tenant'){
                    //---- Trigger Welcome email-------  //  
                  //  EmailTemplate templateId = [Select id,DeveloperName,Subject, HtmlValue, Body from EmailTemplate where DeveloperName  = 'RegisterationTemplateHTML'];
                    EmailTemplate templateId = [Select id,DeveloperName,Subject, HtmlValue, Body from EmailTemplate where DeveloperName  = 'welcomeemailforSDS'];
                    Messaging.SingleEmailMessage singlemail =new Messaging.SingleEmailMessage();  
                    List<Attachment> files = [SELECT Name, Body, ContentType FROM Attachment WHERE ParentId =: templateId.Id];
                    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                    for (Attachment file: files) {
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(file.Name);
                        efa.setBody(file.Body);
                        efa.setContentType(file.ContentType);
                        attachments.add(efa);
                    }
                    singlemail.setFileAttachments(attachments);
                    String htmlBody = templateId.HtmlValue;
                   /* Date dt = System.today(); //current date
                    DateTime dtime = Datetime.now();
                    Integer day = dt.Day(); //get day
                    String monthName = dtime.format('MMM');
                    Integer year = dt.Year(); //get year */
                    Date dtTodayDate = System.Today();
                    Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
                    string strDate = dtTodayDateTime.format('dd/MM/yyyy');
                    //htmlBody = htmlBody.replace('{!NOW()}', day +' '+monthName +' '+year);
                    htmlBody = htmlBody.replace('{!Today}', strDate);
                    htmlBody = htmlBody.replace('{!Receiving_User.Title2}', EmailSalutation);
                    htmlBody = htmlBody.replace('{!Receiving_User.Title}', salutation);
                   // htmlBody = htmlBody.replace('{!Receiving_User.Name}', IndividualName );
                    htmlBody = htmlBody.replace('{!User.Name}', IndividualName );
                    htmlBody = htmlBody.replace('{!Receiving_User.User_Company_Name__c}', EmailAccName);
                    htmlBody = htmlBody.replace('{!Receiving_User.Contact}', firstname +' '+lastname);
                    System.debug('postacode 318 '+Acc.BillingPostalCode);
                    if(Acc.BillingPostalCode != null ){
                        htmlBody = htmlBody.replace('{!Receiving_User.StreetCustom__c}', Acc.BillingStreet);
                        htmlBody = htmlBody.replace('{!Receiving_User.City}', Acc.BillingCity);                
                        htmlBody = htmlBody.replace('{!Receiving_User.PostalCode}', Acc.BillingPostalCode); 
                        htmlBody = htmlBody.replace('{!Receiving_User.Country}', Acc.BillingCountry);
                    }
                    
                    htmlBody = htmlBody.replace('{!Receiving_User.Phone}', Acc.Phone); 
                    
                   // htmlBody = htmlBody.replace('{!Receiving_User.Email}', Acc.Email__c);
                     htmlBody = htmlBody.replace('{!User.Username}', Acc.Email__c);  
                    htmlBody = htmlBody.replace('{!Receiving_User.MemberId__c}', umember.MemberId__c); 
                    
                    singlemail.setTargetObjectId(usercontactid);
                    singlemail.setTemplateId(templateId.id);
                    singlemail.setSubject('Welcome to SafeDeposits');
                    singlemail.setHtmlBody(htmlBody);
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singlemail});
                      }
                    Contact contUpdate = new Contact(id =usercontactid,email = email );
                    update contUpdate;
                    
                    if(userType != 'Tenant'){
                        ApexPages.PageReference lgn = new PageReference('/Sds/s/welcomepage?uid='+umember.MemberId__c);
                        aura.redirect(lgn);
                    }
                    return 'User Create successfully';
                }
                else{
                    Database.rollback(sp);
                    return string.valueOf(srList.getErrors()[0].message);
                }
                
            }
            // return null;
        }catch (Exception ex) {
            Database.rollback(sp);
            System.debug('EXC@@ '+ex.getMessage()+' ** '+ex.getLineNumber());
            return ex.getMessage() + '=> ' + ex.getLineNumber();            
        }
        
    }
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);   
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }        
    }
    
    @TestVisible
    private static void updateUserOnDraft(String draftId, String userId){
        try{
            update new Certificate_Draft__c(Id = draftId, user__c = userId);
        }catch(Exception e){
            throw new AuraHandledException('Something Went Wrong!');
        }
    }
    
    @AuraEnabled
    global static List<String> getPhoneCodePiclistValues(){
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