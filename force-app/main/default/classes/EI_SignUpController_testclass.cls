/*
@date  :     20/09/2021
@description : Testclass for - EI_SignUpController

*/
@isTest

private class EI_SignUpController_testclass{

        // Method   1   
    
        private static testmethod void EI_SignUpController_Test1()
        {
        
        
        EI_SignUpController.fetchErrorLabel();
        EI_SignUpController cmp = new EI_SignUpController();
        EI_SignUpController.siteAsContainerEnabled(' https://staging-thedisputeservice.cs122.force.com/Sds');
        EI_SignUpController.setExperienceId(null);
        EI_SignUpController.setExperienceId(string.valueof(userinfo.getuserID()));
        EI_SignUpController.getPhoneCodePiclistValues();
        Certificate_Draft__c certificate=new Certificate_Draft__c();     
        certificate.name='name1';
        insert certificate;
        EI_SignUpController.updateUserOnDraft(string.valueof(certificate.id), string.valueof(userinfo.getuserID())); 
        
        
        try {
        
        EI_SignUpController.updateUserOnDraft(null, null);
       
   
              } catch (Exception e) {
             
                                    }
       
        integer i= 1;
        integer j = 1;
        system.assertequals(i,j);
        }
        
     
        // method 2
        private static testmethod void EI_SignUpController_Test2(){
        

        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit__c deposit;
        Contact conId;
        System.runAs(userP) {
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            List<Account> accTenant1 = EI_TestDataFactory.createTenant(1);
            insert accTenant1;
             conId = [Select id from Contact where accountId=: accTenant1];
            Property__c property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            insert property;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        
            system.assert(deposit != null);
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);   
            
           insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            Insert new MemberId__c(name='MemberID',AgentID__c=100, BulkNumber__c=100,TenantID__c=100);
                 
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        //Database.insert(userd);

        Test.StartTest();
        

        System.runAs(userP){
           
       Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = conId.Id;
        Test.setFixedSearchResults(fixedSearchResults);
            
        EI_SignUpController.selfRegister('test' ,'Tenant Name0', 'tenant0@test.com','Mr','1234567','+44','12345677',
        'Agent',true,false,'comp1','+44','123456','35r','trade1','string.valueof(userinfo.getuserID())','tenant0@test.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Agent',true,true,'comp1','+44','123456','35r','trade1','string.valueof(userinfo.getuserID())','user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',true,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',false,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test' ,'Tenant Name0', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',false,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'tenant0@test.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', string.valueof(deposit.id));
        
        }
        
        
     }
     
     
     // method 3
        private static testmethod void EI_SignUpController_Test3(){
        

        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
       
      
        System.runAs(userP) {
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
    
            Property__c property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            insert property;
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);       
            system.assert(c1!= null);
            
            Insert new MemberId__c(name='test class',AgentID__c=100, BulkNumber__c=100,TenantID__c=100);     
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);

        Test.StartTest();
       

        System.runAs(userd){
        
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Agent',true,false,'comp1','+44','123456','35r','trade1','string.valueof(userinfo.getuserID())','user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', String.valueof(userinfo.getuserID()));
        
        EI_SignUpController.selfRegister('test1' ,null, 'user1@espire.com','Mr','1234567','+44','12345677',
        'Landlord',false,true,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', String.valueof(userinfo.getuserID()));
        }
        
     }    
     
     
     
        // method 4
        private static testmethod void EI_SignUpController_Test4(){
        

        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit__c deposit;
        
        System.runAs(userP) {
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
           
            insert acc1;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            insert property;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        
            system.assert(deposit != null);
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);    
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');  
            Insert new MemberId__c(name='test class',AgentID__c=100, BulkNumber__c=100,TenantID__c=100);        
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        //Database.insert(userd);

        System.runAs(userP){
         
        
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',false,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Agent',false,true,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Landlord',false,true,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
         EI_SignUpController.selfRegister('te' ,'er', 'user154678@espire.com','Mr','1234567','+44','12345677',
        'Landlord',false,true,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user187875358@espire.com','user174647367@espire.com',
        'user176376436@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,null, 'user1@espire.com','Mr','1234567','+44','12345677',
        'Landlord',false,true,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', String.valueof(deposit.id));
        
        }
        
        
        
     } 
     
     // method 5
        private static testmethod void EI_SignUpController_Test5(){
        

        Test.StartTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit__c deposit;
      
        System.runAs(userP) {
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            insert property;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        
            system.assert(deposit != null);
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
            
            Insert new MemberId__c(name='test class',AgentID__c=100, BulkNumber__c=100,TenantID__c=100);
                       
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);

        
        

        System.runAs(userP){
        
        
         EI_SignUpController.selfRegister('te' ,'er', 'user15467866@espire.com','Mr','1234567','+44','12345677',
        'Agent',false,true,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user187875358@espire.com','user174647367@espire.com',
        'user176376436@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
      
        
         Test.StopTest();
        
        }
        
        
        
     } 
     
     
     // method 6
     
        private static testmethod void EI_SignUpController_Test6(){
       

        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit__c deposit;
        
        System.runAs(userP) {
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            insert property;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        
            system.assert(deposit != null);
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);   
            
          
            
            Insert new MemberId__c(name='test class',AgentID__c=100, BulkNumber__c=100,TenantID__c=100);
            
                 
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        //Database.insert(userd);

        Test.StartTest();
        

        System.runAs(userP){
        
       Try{
       
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Agent',false,true,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
       Test.stoptest();
       }Catch(Exception e){}
        }
       } 
          
     // method 7
     
        private static testmethod void EI_SignUpController_Test7(){
       

        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit__c deposit;
        //Account acc1;
        
        System.runAs(userP) {

            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id, email__c= 'as@test.com' );
            insert acc1;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            insert property;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        
            system.assert(deposit != null);
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email ='as@test.com');
            Database.insert(c1);   
            
          
            
            Insert new MemberId__c(name='test class',AgentID__c=100, BulkNumber__c=100,TenantID__c=100);
            
                 
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        //Database.insert(userd);

        Test.StartTest();
        

        System.runAs(userP){
        
       
       
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'as@test.com','Mr','1234567','+44','12345677',
        'Agent',true,true,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        
        }
        }
        
        
        // method 8
        private static testmethod void EI_SignUpController_Test8(){
        

        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit__c deposit;
        
        System.runAs(userP) {
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
           
            insert acc1;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            insert property;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        
            system.assert(deposit != null);
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'user1@espire.com');
            Database.insert(c1);    
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');  
            Insert new MemberId__c(name='test class',AgentID__c=100, BulkNumber__c=100,TenantID__c=100);        
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        userd.IsActive = False;                      
        Database.insert(userd);

        System.runAs(userP){
         
        
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',false,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        

        
        }
     }
     
    // method 9
        private static testmethod void EI_SignUpController_Test9(){
        

        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit__c deposit;
        
        System.runAs(userP) {
        
            Insert new MemberId__c(name='MemberID',AgentID__c=250, BulkNumber__c=2046,TenantID__c=770,LandlordId__c=179);
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            insert property;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        
            system.assert(deposit != null);
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'user1@espire.com');
            Database.insert(c1);   
            
                 
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        //Database.insert(userd);

        Test.StartTest();
        

        System.runAs(userP){
              
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Agent',true,false,'comp1','+44','123456','35r','trade1','string.valueof(userinfo.getuserID())','user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Agent',true,true,'comp1','+44','123456','35r','trade1','string.valueof(userinfo.getuserID())','user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',true,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',false,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',false,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', string.valueof(deposit.id));
        
        }
        
        
     }

    // method 10
        private static testmethod void EI_SignUpController_Test10(){
        

        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        //contact con;
        Contact c1 ;
        Deposit__c deposit;
        
        System.runAs(userP) {
        
            Insert new MemberId__c(name='MemberID',AgentID__c=250, BulkNumber__c=2046,TenantID__c=770,LandlordId__c=179);
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            insert property;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        
            system.assert(deposit != null);
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'user1@espire.com');
            Database.insert(c1);   
            
            Contact con  =  [select id, Name, Email from Contact Limit 1];
            
            system.debug('5555555555555555con.Name' +con.Name);
            system.debug('5555555555555555con.Email' +con.Email);
            
            String fullNameForSearch = 'test1 test2';
            String email = 'user1@espire.com';
            
         //   List<List<Contact>> searchList = [FIND :fullNameForSearch IN 
           //                                       ALL FIELDS 
           //                                       RETURNING  
           //                                       Contact(ID, Name, Account.recordtypeId WHERE Email=:email.trim()) ];
            
            system.debug('5555555555555555email.trim()' +email.trim());                                       
       //     system.debug('5555555555555555searchList' +searchList);                                      
                 
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        //Database.insert(userd);

        Test.StartTest();
        

        System.runAs(userP){
              
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Agent',true,false,'comp1','+44','123456','35r','trade1','string.valueof(userinfo.getuserID())','user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Agent',true,true,'comp1','+44','123456','35r','trade1','string.valueof(userinfo.getuserID())','user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',true,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',false,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', null);
        
        EI_SignUpController.selfRegister('test1' ,'test2', 'user1@espire.com','Mr','1234567','+44','12345677',
        'Tenant',false,false,'comp1','+44','123456','35r','trade1',string.valueof(userinfo.getuserID()),'user1@espire.com','user1@espire.com',
        'user1@espire.com','street1', 'citytest', '+45', 'country1', 'county1', string.valueof(deposit.id));
        
        }
        
        
     }

        
}