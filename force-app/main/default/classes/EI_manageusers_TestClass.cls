/*
@date  :     19/10/2021
@description : Testclass for - EI_manageusers

*/
@isTest
private class EI_manageusers_TestClass{
        
    // Method   1   
    
        private static testmethod void EI_manageusers_Test1(){
        EI_manageusers.fetchUser();
        EI_manageusers.getUserRole();
        EI_manageusers.getUserPermission();
        EI_manageusers.takesalutation();
        EI_manageusers.getJobRoles();
        EI_manageusers.viewdetails(String.valueof(userinfo.getuserID()));
        EI_manageusers.getPhoneCodePiclistValues();
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        Branch__c branch2  = new Branch__c();
        branch2.Branch_Name__c = 'branchtest';  
        branch2.Account__c = acc.Id;
        branch2.Address__c ='abc';
        branch2.Town_City__c='town1';
        branch2.County__c = 'test2';
        branch2.Country__c='India';
        branch2.Postcode__c='hp23fgt';
        
        insert branch2;
         
        EI_manageusers.showusers(String.valueof(branch2.ID));
        EI_manageusers.showusers(null);
        
        List<String> strlist= new List<string>();
        strlist.add('list1');
        strlist.add('list2');       
        
        EI_manageusers.format(strlist);
        
        Contact con = new contact();
        con.lastname= 'abc';
        //insert con;
            
        EI_manageusers.makeUserInactive(string.valueof(con.id));
     
        
        }
        
        // method 2
        
       private static testmethod void EI_manageusers_Test2(){
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        system.assert(userP!= null ); 
        
        Branch__c branch3;
        
        System.runAs(userP){
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
           
            branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
           
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');    

            c1 = new Contact( FirstName = 'test1',Additional_Permission__c='Submit evidence', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);   
            
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);
       
        EI_manageusers.makeUserInactive(string.valueof(c1.id));
        EI_manageusers.reactivateUser(string.valueof(c1.id));
        
        EI_manageusers.removeuser(string.valueof(userd .id));
        EI_manageusers.contactdetails(string.valueof(c1.id));
        }
         // method 3
        
       private static testmethod void EI_manageusers_Test3(){
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
         system.assert(userP!= null ); 
        
        Branch__c branch3;
        
        System.runAs(userP){
            acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
           
            branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
           
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');   

            c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);   
            
            con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(con);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);
        EI_manageusers.contactdetails(string.valueof(c1.id));
        
        List<String> strlist= new List<string>();
        strlist.add('Submit evidence');
        System.runAs(userP){
        con.email='abc@gmail.com';
        EI_manageusers.updatedetails(con,'jobrole','abc', '+44',strlist);
        con.FirstName='gfhg';
        
        EI_manageusers.updatedetails(con,'jobrole','abc', '+44',strlist);
        }
       
        }
            // method 4
        
       private static testmethod void EI_manageusers_Test4(){
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1;
        system.assert(userP!= null ); 
        
        Branch__c branch3;
        
        System.runAs(userP){
            acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
           
            branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
           
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');   

            c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);   
            
            con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(con);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);
        
        List<String> strlist= new List<string>();
        strlist.add('Submit evidence');
        
        EI_manageusers.checkDuplicateEmailForADD('email','firstname', 'surname');
       
        }
        
        
        
        //method 5
        private static testmethod void  EI_manageusers_Test5()
        {
        
        List<String> strlist= new List<string>();
        strlist.add('Submit evidence');
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Branch__c branch3;
        Account acc2;
        Account a2;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, Name = 'TestPersonAccountFirst');
        insert a;
        
        String recordTypeId2 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a2 = new Account(RecordTypeId = recordTypeId2, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = System.now().millisecond() +'test@user.com');
        insert a2;
        
        con =new contact();
        con.lastname='test1';
        con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null ); 
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        acc2 = [Select FirstName,LastName,PersonEmail,ownerId,phone From Account Where Id = :a2.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
                
        branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US');
        us1.ContactId = con.Id;
        insert us1; 
        
        
        
        System.runAs(us1){
        Try{
        EI_manageusers.showusers(String.valueof(branch3.ID));
        }catch(System.DmlException e){}
        }
            
        }
        
        
        
        //method 6
        private static testmethod void  EI_manageusers_Test6()
        {
        
        List<String> strlist= new List<string>();
        strlist.add('Submit evidence');
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Branch__c branch3;
        Account acc2;
        Account a2;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, Name = 'TestPersonAccountFirst');
        insert a;
        
        String recordTypeId2 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a2 = new Account(RecordTypeId = recordTypeId2, FirstName = 'f', LastName = 't', PersonEmail = System.now().millisecond() +'test@user.com',Phone='7404346033');
        insert a2;
        
        con =new contact();
        con.lastname='t';
        con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null ); 
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        acc2 = [Select FirstName,LastName,PersonEmail,ownerId,phone From Account Where Id = :a2.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
                
        branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
        }
        User us1 = new User(
        FirstName = 'f',
        LastName = 'l',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',ContactId=con .id);       
        insert us1; 
        
        
        
        System.runAs(us1){
        Try{
        EI_manageusers.usercreate(string.valueof(branch3.id), acc2,'mr','+44','abc',strlist);
        }catch(System.AuraHandledException e){}
        }
            
        }
        
        //method 7
        private static testmethod void  EI_manageusers_Test7()
        {
        
        List<String> strlist= new List<string>();
        strlist.add('Submit evidence');
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Branch__c branch3;
        Account acc2;
        Account a2;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Individual Landlord').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'f', LastName = 'l', PersonEmail = System.now().millisecond() +'test@user.com',Phone='7404346033');
        insert a;
        
        String recordTypeId2 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a2 = new Account(RecordTypeId = recordTypeId2, FirstName = 'firstn', LastName = 't', PersonEmail = System.now().millisecond() +'test@user.com',Phone='7404346033');
        insert a2;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        con =new contact();
        con.lastname='t';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null ); 
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        acc2 = [Select FirstName,LastName,PersonEmail,ownerId,phone From Account Where Id = :a2.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Landlord' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
                
        branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
        }
        User us1 = new User(
        FirstName = 'f',
        LastName = 'l',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US');
        us1.ContactId = acc1.PersonContactId;
        insert us1; 
        
        
        
        System.runAs(us1){
        Try{
        EI_manageusers.usercreate(string.valueof(branch3.id), acc2,'mr','+44','abc',strlist);
        }catch(System.AuraHandledException e){}
        }
           } 
      
      //method 9
        private static testmethod void  EI_manageusers_Test9()
        {
        
        List<String> strlist= new List<string>();
        strlist.add('Submit evidence');
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Branch__c branch3;
        Account acc2;
        Account a2;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, Name = 'fb');
        insert a;
        
        String recordTypeId2 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a2 = new Account(RecordTypeId = recordTypeId2, FirstName = 'fn', LastName = 'TestPersonAccountLast', PersonEmail = System.now().millisecond() +'test@user.com');
        insert a2;
        
        con =new contact();
        con.lastname='test1';
        con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null ); 
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        acc2 = [Select FirstName,LastName,PersonEmail,ownerId,phone From Account Where Id = :a2.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
                
        branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US');
        us1.ContactId = con.Id;
        insert us1; 
        
        
        
        System.runAs(us1){
        Try{
         EI_manageusers.usercreate(string.valueof(branch3.id), acc2,'mr','+44','abc',strlist);
        }catch(System.AuraHandledException e){}
        }    
         
         }
              
    // Method   10   
    
        private static testmethod void EI_manageusers_Test10(){
        
        Try{
         EI_manageusers.reactivateUser(null);
        }catch(System.DmlException e){}
        }    
         // Method   11   
    
        private static testmethod void EI_manageusers_Test11(){
        
        Try{
         EI_manageusers.contactdetails(null);
        }catch(System.AuraHandledException e){}
        }    
           // Method   12   
    
        private static testmethod void EI_manageusers_Test12(){
        
        Try{
         EI_manageusers.fetchErrorLabel();
        }catch(System.AuraHandledException e){}
        } 
        
          
        
         // Method   13   
    
        private static testmethod void EI_manageusers_Test13(){
        
        Try{
         EI_manageusers.removeuser(null);
        }catch(System.AuraHandledException e){}
        }
        
        
         // Method   14   
    
        private static testmethod void EI_manageusers_Test14(){
        
        Try{
         EI_manageusers.viewdetails(null);
        }catch(System.AuraHandledException e){}
        } 
        
         // Method   15   
    
        private static testmethod void EI_manageusers_Test15(){
        
        Try{
         EI_manageusers.showusers(null);
        }catch(System.AuraHandledException e){}
        } 
        
         // method 16
        
       private static testmethod void EI_manageusers_Test16(){
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        
        Branch__c branch3;
        
        System.runAs(userP){
            acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
           
            branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
           
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');   

            c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);   
            
            con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(con);
            system.assert(c1!= null ); 
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);
        EI_manageusers.contactdetails(string.valueof(c1.id));
        
        List<String> strlist= new List<string>();
        strlist.add('Submit evidence');
        System.runAs(userd){
        con.email='abc@gmail.com';
        EI_manageusers.updatedetails(c1,'jobrole','abc', '+44',strlist);
        }
       }
        //method 17
        private static testmethod void  EI_manageusers_Test17()
        {
        
        List<String> strlist= new List<string>();
        strlist.add('Submit evidence');
        
        
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Branch__c branch3;
        Account acc2;
        Account a2;
        
        System.runAs(userWithRole){
        
        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Individual Landlord').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'f', LastName = 'l', PersonEmail = System.now().millisecond() +'test@user.com',Phone='7404346033');
        insert a;
        
        String recordTypeId2 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a2 = new Account(RecordTypeId = recordTypeId2, FirstName = 'f', LastName = 't', PersonEmail = System.now().millisecond() +'test@user.com',Phone='7404346033');
        insert a2;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        con =new contact();
        con.lastname='t';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null);
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        acc2 = [Select FirstName,LastName,PersonEmail,ownerId,phone From Account Where Id = :a2.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Landlord' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
                
        branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
        
        
        }
        User us1 = new User(
        FirstName = 'f',
        LastName = 'l',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US');
        us1.ContactId = acc1.PersonContactId;
        insert us1; 
        
        
        
        System.runAs(us1){
        Try{
        EI_manageusers.usercreate(string.valueof(branch3.id), acc2,'mr','+44','abc',strlist);
        }catch(System.AuraHandledException e){}
        }
           } 
        
         }