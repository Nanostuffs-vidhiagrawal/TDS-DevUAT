global  without sharing class EI_CustomSelfRegisterApx {
        public EI_CustomSelfRegisterApx() {  
        }
        
        @TestVisible 
        private static boolean siteAsContainerEnabled(String communityUrl) {
            Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
            return authConfig.isCommunityUsingSiteAsContainer();
        }
        
        @AuraEnabled
        public static String selfRegister(
            String firstname ,String lastname, String email,string salutation,string Telephone,string phone,
            string userType,Boolean OrgUSer,Boolean HoUser,
            string companyName,string companyPhone,String LAid,string companyEmail,string companyDrmEmail, string companyFinanceEmail,
            string street, string city, string postcode, string country, string county
            
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
                list<user> userlistEmail = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                            from user where profile.UserLicense.Name ='Customer Community Login' 
                                            and email =:email.trim()];
                
                List<List<SObject>> searchList = [FIND :fullNameForSearch IN 
                                ALL FIELDS 
                                RETURNING  
                                Contact(ID WHERE Email=:email.trim()) ];
                
                if(userlistEmail.size() > 0 )
                {
                    UserRecid = userlistEmail[0].id;
                    isUserExist = true;
                    userDetails11= userlistEmail[0];
                }
                else
                {
                     isUserExist = false;
                   /* string fullName  = Firstname.trim()+' '+LastName.trim();
                    list<user> userlistPhone = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                                from user where profile.UserLicense.Name ='Customer Community Login' 
                                                and Phone=:phone.trim() and Name =:fullName ];
                    if(userlistPhone.size() >0 )
                    {
                        isUserExist = true;
                        userDetails11= userlistPhone[0];
                        UserRecid = userlistPhone[0].id;
                    }
                    else
                    {
                        isUserExist = false;
                    }*/
                    
                }
                
                if(isUserExist)
                {
                    if(userDetails11 != null )
                    { 
                       // System.debug('fullNameForSearch '+fullNameForSearch);  
                      //  System.debug('email.trim '+email.trim());
                        
                       /* List<List<SObject>> searchList = [FIND :fullNameForSearch IN 
                                                          ALL FIELDS 
                                                          RETURNING  
                                                          Contact(ID WHERE Email=:email.trim()) ];
						*/
                   //     System.debug(searchList[0]);
                        
                        if(searchList[0].size()>0){
                            List<User> u = [SELECT ID FROM User WHERE ContactId=:searchList[0]];
                            if(u.size()>0){
                                if(userDetails11.IsActive == false && userType == u[0].user_type__c)
                                {   
                                    userDetails11.IsActive = true;
                                    update userDetails11;
                                }
                                site.forgotPassword(userDetails11.userName);
                                return 'User already have an account';
                            }
                        }
                        /*else{
                            List<User> userWithPhone = [SELECT ID, Phone, Name, Email,UserName 
                                                        FROM User 
                                                        WHERE Phone=:phone.trim() 
                                                        AND Name =:fullNameForSearch];
                            if(userWithPhone.size()>0 && userWithPhone.size()<2){
                             site.forgotPassword(userWithPhone[0].userName); 
                                return 'User already have an account';  
                            }
                        }
                        */
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
                            Acc = new Account(name =companyName,Phone =companyPhone,RecordTypeId=AccountRecordTypeId,Letting_Agent_Number__c =LAid,
                                              Email__c =companyEmail,DRM_email__c=companyDrmEmail,Finance_email__c=companyFinanceEmail,
                                              BillingStreet = street,BillingCity = city,BillingPostalCode = postcode,BillingCountry = country,BillingState = county);
                            EmailAccName = companyName;
                            IndividualName = companyName;
                            EmailSalutation = '';
                            insert Acc;
                            con  = new contact (AccountId =Acc.id,Job_role__c='Head office administrator',Salutation=salutation,FirstName =firstname,
                                                lastname =lastname,email =companyEmail,Phone =phone,
                                                MailingStreet = street,MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,MailingState = county);
                            
                        }
                        else
                        {
                            AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                            Acc = new Account(name =companyName,Phone =companyPhone,RecordTypeId=AccountRecordTypeId,Email__c = email,
                                              BillingStreet = street,BillingCity = city,BillingPostalCode = postcode,BillingCountry = country,BillingState = county);
                            EmailAccName = companyName;
                             IndividualName = companyName;
                            EmailSalutation = '';
                            insert Acc;
                            con  = new contact (AccountId =Acc.id,Job_role__c='Account administrator',Salutation=salutation,FirstName =firstname,Account_Status__c ='Active',
                                                lastname =lastname,email =email,Phone =phone,
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
                        else
                        {
                            if(userType =='Tenant')
                            {
                                AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId();
                            }
                            else
                            {
                                AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId();
                            }
                            
                        }
                        EmailSalutation = salutation;
                        Acc = new Account();
                        Acc.FirstName = firstname;
                        if(userType !='Tenant'){
                            Acc.Job_role__pc='Account administrator';}
                        Acc.LastName = lastname;
                        Acc.Salutation =salutation;
                        Acc.PersonEmail=email;
                        Acc.Email__c = email;
                        Acc.PersonHomePhone =phone;
                        if(Telephone != NULL){
                             Acc.PersonOtherPhone = Telephone;
                        }
                       
                        Acc.Phone = phone;
                        Acc.RecordTypeId  = AccountRecordTypeId;
                        Acc.Account_Status__pc ='Active';
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
                        if(BusinessType == 'Head office user')
                        {
                            Acc.Associated_To__c =u.id;
                            update acc;
                        }
                        //---- Trigger Welcome email-------  //  
                        EmailTemplate templateId = [Select id,DeveloperName,Subject, HtmlValue, Body from EmailTemplate where DeveloperName  = 'RegisterationTemplateHTML'];
                       // EmailTemplate templateId = [Select id,DeveloperName,Subject, HtmlValue, Body from EmailTemplate where DeveloperName  = 'welcomeemailforSDS'];
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
                        Date dt = System.today(); //current date
                        DateTime dtime = Datetime.now();
                        Integer day = dt.Day(); //get day
                        String monthName = dtime.format('MMM');
                        Integer year = dt.Year(); //get year
                        htmlBody = htmlBody.replace('{!NOW()}', day +' '+monthName +' '+year);
                        htmlBody = htmlBody.replace('{!Receiving_User.Title2}', EmailSalutation);
                        htmlBody = htmlBody.replace('{!Receiving_User.Title}', salutation);
                        htmlBody = htmlBody.replace('{!Receiving_User.Name}', IndividualName );
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
    
                        htmlBody = htmlBody.replace('{!Receiving_User.Email}', Acc.Email__c);  
                        htmlBody = htmlBody.replace('{!Receiving_User.MemberId__c}', umember.MemberId__c); 
    
                        singlemail.setTargetObjectId(usercontactid);
                        singlemail.setTemplateId(templateId.id);
                        singlemail.setSubject('Your SafeDeposits Scotland registration');
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
                    else{
                        Database.rollback(sp);
                        return string.valueOf(srList.getErrors()[0].message);
                    }
                    
                }
                // return null;
            }catch (Exception ex) {
                Database.rollback(sp);
                
                return ex.getMessage();            
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
        
        
    }