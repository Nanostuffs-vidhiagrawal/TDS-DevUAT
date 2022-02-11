@istest public class EI_clientAccountreportcontroller_test{

        // method 1 
        Public static testmethod void EI_clientAccountreportcontroller_method1(){
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        account acc;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        Property_Created__c propcreated;
        
        System.runAs(userWithRole){
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       
        acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
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
        deposit.Customer__c = a.id;
        deposit.Protection_Start_Date__c = system.today() - 10;
        insert deposit;
        
        deposit.Protection_Start_Date__c = system.today() + 1;
        update deposit;
        
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
        
        System.runAs(us1 ){
        EI_clientAccountreportcontroller.fetchdeposit(string.valueof(system.today()) ,null);
        EI_clientAccountreportcontroller.fetchdeposit(string.valueof(system.today()) ,string.valueof(system.today()+10));
        }    
        
        System.runAs(userWithRole){
        deposit.Protection_Start_Date__c = system.today() + 1;
        update deposit;
        }
        
        System.runAs(us1 ){
        EI_clientAccountreportcontroller.fetchdeposit(null ,string.valueof(system.today()));
        } 
        
        System.runAs(userWithRole){
        deposit.Protection_Start_Date__c = system.today() - 1;
        update deposit;
        }
        
        System.runAs(us1 ){
        EI_clientAccountreportcontroller.fetchdeposit(string.valueof(system.today()) , null);
        EI_clientAccountreportcontroller.fetchdeposit(null , null);
        } 
        
        system.assert(deposit!= null );
}
}