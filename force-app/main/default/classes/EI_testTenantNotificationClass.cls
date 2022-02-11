@isTest
public class EI_testTenantNotificationClass {
    
    @isTest
    public static void getdepositstatus(){
        
        EI_TenantNotificationClass.getdepositstatus();
        
        
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Tenant').getRecordTypeId();
      
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'Mishra';
        insert a;
        
     /*   contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = 'Test Tenant LastName';
        c.Email = 'testTenant@gmail.com';
        c.Sent_Via_Post__c = true;
        c.Account_Type__c='Agent';
        insert c;*/
        
         Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
        
         Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;
        d.Case_Status__c ='Decision issued - awaiting request for review';
        d.Scheme__c = s.Id;
        insert d;
        
        
        Deposit_Allocation__c da = new Deposit_Allocation__c();
        da.Deposit__c =  d.id;
        da.Deposit_Holder__c = a.Id;                                           //MD to Account
       // da.Contact__c = c.Id;
        insert da;
        
      
    }
    
     @isTest
    public static void loadAll(){
        
        EI_TenantNotificationClass.LoadAll(100);
        
        
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Tenant').getRecordTypeId();
      
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'Mishra';
        insert a;
        
     /*   contact c = new Contact();
        c.AccountId = a.Id;
        c.LastName = 'Test Tenant LastName';
        c.Email = 'testTenant@gmail.com';
        c.Sent_Via_Post__c = true;
        c.Account_Type__c='Agent';
        insert c;*/
        
         Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
        
         Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;
        d.Case_Status__c ='Decision issued - awaiting request for review';
        d.Scheme__c = s.Id;
        insert d;
        
        
        Deposit_Allocation__c da = new Deposit_Allocation__c();
        da.Deposit__c =  d.id;
        da.Deposit_Holder__c = a.Id;                                           //MD to Account
       // da.Contact__c = c.Id;
        insert da;
        
      
    }
    

}