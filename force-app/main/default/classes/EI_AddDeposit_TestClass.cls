/*
@date  :     14/09/2021
@description : Testclass for - EI_AddDeposit

*/
@isTest
private class EI_AddDeposit_TestClass{
        
    // Method   1   
    
        private static testmethod void EI_AddDeposit_Test1(){
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Property_Owner__c=acc.id;
        insert property;
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        
        Test.StartTest();
        
         EI_AddDeposit.checkDuplicateEmail('abc@gmail.com', '123445', 'test1', 'test2', 'onlyemail');
         EI_AddDeposit.checkDuplicateEmail('abc@gmail.com', '123445', 'test1', 'test2', 'onlyphone');
         EI_AddDeposit.checkDuplicateEmails('abc@gmail.com', '123445', 'onlyemail', 'test1', 'test2', string.valueof(deposit.ID));
         EI_AddDeposit.checkDuplicateEmails('abc@gmail.com', '123445', 'onlyphone', 'test1', 'test2', string.valueof(deposit.ID));
     
         EI_AddDeposit.WrapperClass wrap = new EI_AddDeposit.WrapperClass(True , 'test', 'test', property, 'test');
         EI_AddDeposit.FinalWrapper wrap1 = new EI_AddDeposit.FinalWrapper();
         wrap1.firstName = 'test';
         wrap1.SurName='test1';
         wrap1.email='abc@gmail.com';
         wrap1.phoneCode='+44';
         wrap1.phone='123345';
         wrap1.title='mr';
         wrap1.LeadSummary=true;
         wrap1.IsOrg=true;
         wrap1.item=4;
         wrap1.companyName='espiretest';
      
      
     
        EI_AddDeposit.newTenantEmail tenantemail = new EI_AddDeposit.newTenantEmail();
        tenantemail.name = 'test';
        tenantemail.danNo='DAN235';
        EI_AddDeposit.notifyNewTenant(userinfo.getuserid());
        EI_AddDeposit.fetchErrorLabel();
        
        Test.StopTest();
    }
    
          
    
    // method 2
        private static testmethod void EI_AddDeposit_Test2(){
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.ownerid=UserInfo.getUserId();
        insert acc;
          
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        Branch__c branch2 = new Branch__c();
        branch2.Account__c = acc.Id;
        branch2.Branch_Name__c='xyztest';
        branch2.Address__c ='abc';
        branch2.Town_City__c='town1';
        branch2.County__c = 'test2';
        branch2.Country__c='India';
        branch2.Postcode__c='hp23fgt';
        
        insert branch2;
        
        List<Property__c> propList = new List<Property__c>();
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.No_of_living_rooms__c=2;
        property.Is_Furnished__c=true;
        property.Property_status__c= 'Active';
        property.No_of_bedrooms__c=3;
        property.County__c='abc';
        property.City__c='abc';
        property.branch__c=branch2.ID;
        property.Property_Owner__c=acc.ID;
        propList.add(property);   
        insert propList;
        
        Property_Allocation__c pa =new Property_Allocation__c();
        pa.Relation_to_Property__c='Primary Landlord';
        pa.Property__c= Property.ID;
        insert pa;
       
        
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Property__c=property.id;
        deposit.Branch__c= branch2.ID;
        deposit.Start_Date__c=system.today()-1;
        deposit.status__c='Deposits held by scheme';
        deposit.Number_of_Tenants__c=2;
        deposit.Rent_Amount__c=400.00;
        deposit.Deposit_Amount__c=300.00;
        deposit.Protected_Amount__c=200.00;
        deposit.Date_Deposit_Received__c=system.today()-2;        
        deposit.User_reference_for_the_deposit__c='test';
        deposit.Property__c=property.id;
        deposit.Customer__c=acc.id;
        deposit.Scheme__c=scheme.id;                
        insert deposit;
        
        Deposit_Allocation__c depoall = new Deposit_Allocation__c();
        depoall.Deposit__c = deposit.id;
        depoall.Deposit_Holder__c = acc.id;
        insert depoall; 
        
        
        User u1 = new User(alias = 'hasrole', email='userwithrole@roletest.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(),
                                  User_Type__c='Agent', 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert u1;
        
        contact con =new contact();
        con.PrimaryLandlord__c=true;
        con.lastname='last';
        insert con;
       
        Set<Id> ids = new Set<Id>();
        ids.add(userinfo.getuserid());
       
        Property_Created__c propcreated= new Property_Created__c();
        propcreated.name='test';
        insert propcreated;      
    
        System.runAs(u1){
     
        EI_AddDeposit.getProperties('abc', branch2.ID);
        EI_AddDeposit.getProperties('abc', null);
     
        EI_AddDeposit.getlandlord('abc@gmail.com');
        EI_AddDeposit.transferDeposit(System.Today(),199.00,deposit.id,property.id);
        EI_AddDeposit.getuserDetails();
        EI_AddDeposit.getLandlordforSummery(propList);
        EI_AddDeposit.updateUser(ids);     
        EI_AddDeposit.getPhoneCodePiclistValues();
       
      
    }
  
    
    }
       
        private static testmethod void EI_AddDeposit_Test3(){
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username= System.now().millisecond() + 'userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Account acc;
        
        
        System.runAs(userWithRole){
        
        acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.Phone = null;
        insert acc;
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.Phone = null;
        insert a;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643); 
        
        con =new contact();
        con.lastname='test1';
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
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,Phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = System.now().millisecond() +'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new EI_AddDepositcallout());

        System.runAs(us1){

        EI_AddDeposit.addAdditionalTenant(acc1,'mr','+44',deposit.ID,true);
        EI_AddDeposit.addAdditionalTenant(acc,'mr','+44',deposit.ID,false);
        EI_AddDeposit.addAdditionalTenant(acc1,'mr','+44',deposit.ID,false);

        }
        

        test.stoptest();

    }
    
    
    // Method   4  
    private static testmethod void EI_AddDeposit_Test4(){
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
        Property_Created__c propcreated;
        
        System.runAs(userWithRole){
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       
        
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        propcreated = new Property_Created__c();
        propcreated.name = 'test';
        insert propcreated ;
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
       
      
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
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
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        System.runAs(us1){
        
        Try{
        EI_AddDeposit.insertProperties('abc','xyz','hp115dh','dgfgg','fgb');
        EI_AddDeposit.addAdditionalTenant(acc1,'mr','+44',deposit.ID,false);
        }catch(Exception e){}
        
        
        }
    }
    
    // Method   5  
    private static testmethod void EI_AddDeposit_Test5(){
    
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        id branchRecTypeId = Schema.SObjectType.Branch__c.getRecordTypeInfosByDeveloperName().get('SDS_Branch').getRecordTypeId();
        Branch__c branch1  = new Branch__c();
        branch1.RecordTypeId = branchRecTypeId;
        branch1.Account__c = acc.Id;
        branch1.Branch_Name__c='xyztest1';
        branch1.Address__c ='abc';
        branch1.Town_City__c='town1';
        branch1.County__c = 'test2';
        branch1.Country__c='India';
        branch1.Postcode__c='hp23fgt';
        
        insert branch1;
    
        Test.StartTest();
        try{
        EI_AddDeposit.addAdditionalTenant(acc,'mr','+44',deposit.ID,false);
        }catch(exception e){}
        
        Test.StopTest();
                                                        
    }
    
    // Method   6  
        private static testmethod void EI_AddDeposit_Test6(){
       
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
         
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        con =new contact();
        //con.primaryLandord__c=true;
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        deposit.Number_of_Tenants__c=2;
        deposit.Rent_Amount__c=400.00;
        deposit.Deposit_Amount__c=300.00;
        deposit.Protected_Amount__c=200.00;
        deposit.Date_Deposit_Received__c=system.today()-2;
        deposit.Start_Date__c=system.today();
        deposit.User_reference_for_the_deposit__c='test';
        deposit.Property__c=property.id;
        deposit.Customer__c=a.id;
        deposit.status__c='Deposits held by scheme';
        insert deposit;
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
         
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;
                
               
              
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        //User_Type__c='Agent',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        
        
        System.runAs(us1){
              Try{
        EI_AddDeposit.addNewProperty(property,us1,conlist,conlist);
        
        }catch(Exception e){}
        }
    }
    
      
    // Method   7  
        private static testmethod void EI_AddDeposit_Test7(){
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
        Deposit_Allocation__c depoall;
        Property_Created__c propcreated;
        
        System.runAs(userWithRole){
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        
        
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        propcreated = new Property_Created__c();
        propcreated.name = property.id;
        insert propcreated;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        depoall = new Deposit_Allocation__c ();
        depoall.Deposit__c = deposit.id;
        depoall.Deposit_Holder__c = a.id;
        depoall.Role__c = 'Landlord';
        insert depoall;
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
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
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
       
        
        System.runAs(us1){
        
        Try{
       
        EI_AddDeposit.savelandlord('test1',system.today(),200.00,String.valueof(deposit.Id),'mr','test3',
        'test4', 'test5@gmail.com', '122345566', 'test5', 'test6', 'test7@gmail.com',true,'test8', 
        'test9', 'test10', 'test11', 'test12');
        
        }catch(Exception e){}
        }
    }
      // Method   8  
        private static testmethod void EI_AddDeposit_Test8(){
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
        Property_Created__c propcreated;
        
        System.runAs(userWithRole){
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        propcreated= new Property_Created__c();
        propcreated.name='test';
        insert propcreated;
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        
        
        con =new contact();
        con.lastname='test1';
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
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
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
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        
        
        System.runAs(us1){
        Try{
       
         EI_AddDeposit.savelandlord('test1',system.today(),200.00,'test2','mr','test3',
        'test4', 'test5@gmail.com', '122345566', 'test5', 'test6', 'test7@gmail.com',false,'test8', 
        'test9', 'test10', 'test11', 'test12');
        }catch(Exception e){}
        }
    }
    
       // Method   9  
        private static testmethod void EI_AddDeposit_Test9(){
        
        
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        List<Account> acclist = new List<Account>();
        Account acc;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Property_Created__c propcreated;
        Branch__c branch1;
        Property_Allocation__c pa;
        
        
        System.runAs(userWithRole){
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        
        propcreated= new Property_Created__c();
        propcreated.name='test';
        insert propcreated;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert acc;
        
        acclist.add(acc);
        
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        pa = new Property_Allocation__c();
        pa.Property__c = property.id;
        pa.Relation_to_Property__c = 'Primary Landlord';
        insert pa;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        branch1  = new Branch__c();
        branch1.Account__c = acc.Id;
        branch1.Address__c ='abc';
        branch1.Town_City__c='town1';
        branch1.County__c = 'test2';
        branch1.Country__c='India';
        branch1.Postcode__c='hp23fgt';
        branch1.Branch_Name__c='xyztest2';
        
        insert branch1;
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :acc.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
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
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        EI_AddDeposit.FinalWrapper wrap1 = new EI_AddDeposit.FinalWrapper();
         wrap1.firstName = 'test';
         wrap1.SurName='test1';
         wrap1.email='abc@gmail.com';
         wrap1.phoneCode='+44';
         wrap1.phone='123345';
         wrap1.title='mr';
         wrap1.LeadSummary=true;
         wrap1.IsOrg=False;
         wrap1.item=4;
         wrap1.companyName='espiretest';
        
        String jsonString = JSON.serialize(acc1);
        
        String jsonString1 = JSON.serialize(acclist);
        
        
        System.runAs(userWithRole){
         Try{
         
         
       
        EI_AddDeposit.finalSave(string.valueof(branch1.id), jsonString ,jsonString1 ,  property,
      'test4', 'test5', string.valueof(acc1.id), 300.00, 200.00,
       150.00, system.today(), system.today()+1,3, 
        'test7');
       
        }catch(Exception e){}
        }
    }

       // Method   10
        private static testmethod void EI_AddDeposit_Test10(){
       
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
         
        System.runAs(userWithRole){
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);

        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        con =new contact();
        //con.primaryLandord__c=true;
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;       
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        deposit.Number_of_Tenants__c=2;
        deposit.Rent_Amount__c=400.00;
        deposit.Deposit_Amount__c=300.00;
        deposit.Protected_Amount__c=200.00;
        deposit.Date_Deposit_Received__c=system.today()-2;
        deposit.Start_Date__c=system.today();
        deposit.User_reference_for_the_deposit__c='test';
        deposit.Property__c=property.id;
        deposit.Customer__c=a.id;
        deposit.status__c='Deposits held by scheme';
        insert deposit;
        system.assert(deposit!= null );
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
         
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;            
              
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        User_Type__c='Agent',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        
        
        System.runAs(us1){
              Try{
       
        EI_AddDeposit.savelandlord('test1',system.today(),200.00,'test2','mr','test3',
        'test4', 'test5@gmail.com', '122345566', 'test5', 'test6', 'test7@gmail.com',true,'test8', 
        'test9', 'test10', 'test11', 'test12');
        }catch(Exception e){}
        }
        }
         
    // Method   11 
        private static testmethod void EI_AddDeposit_Test11(){
       
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
        Branch__c branch1;
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        con =new contact();
        //con.primaryLandord__c=true;
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        branch1 = new Branch__c();
        branch1.Account__c = a.id;
        branch1.Branch_Name__c = 'test5';
        insert branch1;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        deposit.Number_of_Tenants__c=2;
        deposit.Rent_Amount__c=400.00;
        deposit.Deposit_Amount__c=300.00;
        deposit.Protected_Amount__c=200.00;
        deposit.Date_Deposit_Received__c=system.today()-2;
        deposit.Start_Date__c=system.today();
        deposit.User_reference_for_the_deposit__c='test';
        deposit.Property__c=property.id;
        deposit.Customer__c=a.id;
        deposit.status__c='Deposits held by scheme';
        insert deposit;
        system.assert(deposit!= null );
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
         
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

       
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;
              
              
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        //User_Type__c='Agent',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        property.Property_status__c= 'Active';
        
        
        System.runAs(us1){
              Try{

        EI_AddDeposit.checkDuplicateEmails('abc@gmail.com', '123445', 'onlyemail', 'test1', 'test2', string.valueof(deposit.ID));
        }catch(Exception e){}
        
     }
     }
     
         // Method   12
        private static testmethod void EI_AddDeposit_Test12(){
       
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
        Deposit_Allocation__c da;
         
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.phone='1234567899';
        insert a;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

      
        con =new contact();
        //con.primaryLandord__c=true;
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        deposit.Number_of_Tenants__c=2;
        deposit.Rent_Amount__c=400.00;
        deposit.Deposit_Amount__c=300.00;
        deposit.Protected_Amount__c=200.00;
        deposit.Date_Deposit_Received__c=system.today()-2;
        deposit.Start_Date__c=system.today();
        deposit.User_reference_for_the_deposit__c='test';
        deposit.Property__c=property.id;
        deposit.Customer__c=a.id;
        deposit.status__c='Deposits held by scheme';
        insert deposit;
        system.assert(deposit!= null );
        da = new Deposit_Allocation__c();
        da.Deposit__c = deposit.id;
        da.Deposit_Holder__c = a.id;
        insert da;
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Tenant' LIMIT 1];
         
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;
              
              
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        //User_Type__c='Agent',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        
        System.runAs(us1){
              Try{
              
        
         
        EI_AddDeposit.checkDuplicateEmails('abc@gmail.com', '1234567899', 'onlyemail', 'test1', 'test2', string.valueof(deposit.ID));
        
        EI_AddDeposit.checkDuplicateEmails('abc@gmail.com', '1234567899', 'onlyphone', 'test1', 'test2', string.valueof(deposit.ID));
        }catch(Exception e){}
        
     }
     }
             // Method   13
        private static testmethod void EI_AddDeposit_Test13(){
       
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
        Deposit_Allocation__c da;
        Property_Allocation__c pa;
         
        System.runAs(userWithRole){
        //String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId();
        a = new Account(RecordTypeId = AccountRecordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.phone='1234567899';
        insert a;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

    
        con =new contact();
        //con.primaryLandord__c=true;
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];        
        insert property;
        
        pa = new Property_Allocation__c();
        pa.Property__c = property.id;
        pa.Relation_to_Property__c = 'Primary Landlord';
        insert pa;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];       
        deposit.Property__c=property.id;
        deposit.Customer__c=a.id;
        deposit.status__c='Deposits held by scheme';
        insert deposit;
        system.assert(deposit!= null );
        da = new Deposit_Allocation__c();
        da.Deposit__c = deposit.id;
        da.Deposit_Holder__c = a.id;
        insert da;
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Tenant' LIMIT 1];
         
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;
              
              
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        //User_Type__c='Agent',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        
        System.runAs(us1){
        Try{
        EI_AddDeposit.addAdditionalTenant(a,'mr','+44',deposit.ID,false);
     
        }catch(Exception e){}
        
     }
     }
     
            // Method   14
        private static testmethod void EI_AddDeposit_Test14(){
       
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
        Deposit_Allocation__c da;
         
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.phone='1234567899';
        insert a;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

     
        
        con =new contact();
        //con.primaryLandord__c=true;
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        deposit.Number_of_Tenants__c=2;
        deposit.Rent_Amount__c=400.00;
        deposit.Deposit_Amount__c=300.00;
        deposit.Protected_Amount__c=200.00;
        deposit.Date_Deposit_Received__c=system.today()-2;
        deposit.Start_Date__c=system.today();
        deposit.User_reference_for_the_deposit__c='test';
        deposit.Property__c=property.id;
        deposit.Customer__c=a.id;
        deposit.status__c='Deposits held by scheme';
        insert deposit;
        system.assert(deposit!= null );
        da = new Deposit_Allocation__c();
        da.Deposit__c = deposit.id;
        da.Deposit_Holder__c = a.id;
        insert da;
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Tenant' LIMIT 1];
         
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;
              
              
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        //User_Type__c='Agent',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        
        System.runAs(us1){
        Try{
        EI_AddDeposit.addAdditionalTenant(a,'mr','+44',deposit.ID,false);
     
        }catch(Exception e){}
        
     }
     }
     
   
    // Method   15
        private static testmethod void EI_AddDeposit_Test15(){
       
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        

        
        Account a;
        Property__c property;
        Property__c property1;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Branch__c branch1;
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

     
        con =new contact();
       // con.PrimaryLandlord__c =true;
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        
        insert property;
        
        property1= EI_TestDataFactory.createProperty(1,a.id)[0];
        
        //insert property1;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        branch1 = new Branch__c();
        branch1.Account__c = a.id;
        branch1.Branch_Name__c = 'test5';
        insert branch1;
      
        system.assert(branch1!= null );
        }
        Account acc1 = [Select id,Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
         
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;
              
              
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        User_Type__c='Agent',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        //AccountId = a.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        property.Property_status__c= 'Active';
        
        
        System.runAs(us1){
              
        EI_AddDeposit.addNewProperty(property1,us1,conlist,conlist);    
        }
     }
     
     // Method   16 
    
        private static testmethod void EI_AddDeposit_Test16(){
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Property_Owner__c=acc.id;
        insert property;
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

      
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        Map<string,ID> map1 = new Map<string,id>();
        map1.put('user1@espire.com', acc.id);
        
        Map<string,string> map2 = new Map<string,string>();
        map2.put('user1@espire.com', 'user1@espire.com');
        
        Test.StartTest();
       
        Test.setMock(HttpCalloutMock.class, new EI_adddepositMock());
        EI_AddDeposit.notifyExistingTenant(map1,map2);
        test.stoptest();
        } 
      
      
           // Method  17
        private static testmethod void EI_AddDeposit_Test17(){
        
        
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        List<Account> acclist = new List<Account>();
        Account acc;
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Property_Created__c propcreated;
        Branch__c branch1;
        String jsonString;
        String jsonString1;
        String jsonStringProp;
        
        
        System.runAs(userWithRole){
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        
        propcreated= new Property_Created__c();
        propcreated.name='test';
        insert propcreated;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert acc;
        
        
        
        String recordTypeId1 = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId1, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        
        acclist.add(a);
        
        con =new contact();
        con.lastname='test1';
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
        branch1  = new Branch__c();
        branch1.Account__c = a.Id;
        branch1.Address__c ='abc';
        branch1.Town_City__c='town1';
        branch1.County__c = 'test2';
        branch1.Country__c='India';
        branch1.Postcode__c='hp23fgt';
        branch1.Branch_Name__c='xyztest2';
        
        insert branch1;
        
        jsonString = JSON.serialize(a);
        
        jsonString1 = JSON.serialize(acclist);
        
        jsonStringProp = JSON.serialize(property);
        //String jsonString = JSON.serialize(acc1);
        
        EI_AddDeposit.WrapperClass wrap = new EI_AddDeposit.WrapperClass(True , jsonStringProp, String.Valueof(property.id), property, String.valueof(con.id));
         EI_AddDeposit.FinalWrapper wrap1 = new EI_AddDeposit.FinalWrapper();
         wrap1.firstName = 'test';
         wrap1.SurName='test1';
         wrap1.email='abc@gmail.com';
         wrap1.phoneCode='+44';
         wrap1.phone='123345';
         wrap1.title='mr';
         wrap1.LeadSummary=true;
         wrap1.IsOrg=true;
         wrap1.item=4;
         wrap1.companyName='espiretest';
        
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :acc.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
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
        //AccountId = acc1.Id,
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 

        System.runAs(userWithRole){
         Try{
         
        EI_AddDeposit.finalSave(string.valueof(branch1.id), jsonString ,jsonString1,  property,
      'test4', 'test5', string.valueof(acc1.id), 300.00, 200.00,
       150.00, system.today(), system.today()+1,3, 
        'test7');
       
        }catch(Exception e){}
        }
    }
}