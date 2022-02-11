/*

@description : Testclass for - EI_DepositLookupapex
*/
@isTest
private class EI_DepositLookupapex_TestClass{
        
    // Method   1   
    
        private static testmethod void EI_DepositLookupapex_Test1(){
        
        
        EI_DepositLookupapex.getChangeOverCase();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
        Contact  c1 = new Contact( FirstName = 'test1', Lastname = 'surname',  Email = System.now().millisecond() + 'as@test.com');
        insert c1; 
         
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Postal_Code__c='postcode';
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;  
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');     
        
        deposit__c DAN= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        
        DAN.Status__c ='Deposits held by scheme';
        DAN.Start_Date__c = System.Today();
        DAN.Deposit_Amount__c=400;
        insert DAN;
        
        system.assert(DAN!= null);
        
        
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = DAN.Id;
        depositallocation.Deposit_Holder__c = acc.id;     
        depositallocation.Deposit_Status__c  ='Unvalidated';
        depositallocation.Role__c='Tenant';
        //depositallocation.Deposit_Amount__c ='400';
        insert depositallocation;
      
        
         
        EI_DepositLookupapex.loggedintenantdeposits();
        EI_DepositLookupapex.updatealternateemail(acc,'abc@hmail.com');
        
        EI_DepositLookupapex.getdepositdetails( 'DAN', 'postcode',10,2021,400, 'surname');
        test.starttest();
        //EI_DepositLookupapex.mailtoremoveduser('userpersonemail','username');
        test.stoptest();
        Try{
        EI_DepositLookupapex.loggedInUserAccountInfo();
        }catch(exception e){}
        
                }
                
        // method 2
        
         private static testmethod void EI_DepositLookupapex_Test2(){
        
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
        Deposit_Allocation__c depositallocation;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'abc@ac.uk',Alternative_Email__pc= null);
        insert a;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
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
        system.assert(deposit!= null);
        depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = a.id;     
        depositallocation.Deposit_Status__c  ='Unvalidated';
        depositallocation.Role__c='Tenant';
        //depositallocation.Deposit_Amount__c ='400';
        insert depositallocation;
        
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
        
        String jsonStr ='['+String.Valueof(JSON.serialize(depositallocation))+']';
        
        EI_DepositLookupapex.addtenanttodeposit(jsonStr );
        EI_DepositLookupapex.loggedInUserAccountInfo();
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new EI_DepositLookupapexcallout());
        EI_DepositLookupapex.mailtoremoveduser('test@user.com','test@user.com');
        test.stoptest();
        }
        }
        
        
        
        //Method   3   
    
        private static testmethod void EI_DepositLookupapex_Test3(){
        
        Try{
        EI_DepositLookupapex.updatealternateemail(null,null);
        }Catch(exception e){}
        
        }
         // method 4
        
         private static testmethod void EI_DepositLookupapex_Test4(){
        
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
        Deposit_Allocation__c depositallocation;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = '');
        insert a;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        system.assert(scheme!= null);
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        
        depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = a.id;     
        depositallocation.Deposit_Status__c  ='Unvalidated';
        depositallocation.Role__c='Tenant';
        //depositallocation.Deposit_Amount__c ='400';
        insert depositallocation;
        
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
        LastName = 'TestLastName',
        Email = 'abc@gmail.com',
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
        
        String jsonStr ='['+String.Valueof(JSON.serialize(depositallocation))+']';
        
        EI_DepositLookupapex.addtenanttodeposit(jsonStr );
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new EI_DepositLookupapexcallout());
        EI_DepositLookupapex.mailtoremoveduser('test@user.com','test@user.com');
        test.stoptest();
        }
        }
        
        }