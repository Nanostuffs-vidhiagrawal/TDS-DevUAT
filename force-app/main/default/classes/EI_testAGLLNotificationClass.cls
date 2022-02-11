@isTest
public class EI_testAGLLNotificationClass {
    
     @isTest
    public static void getdepositstatus(){
        EI_LandlordAgentNotificationclass.getLandLordStatus();
        
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Landlord').getRecordTypeId();
      
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'Mishra';
        insert a;
        
         Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
        
         Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;
        d.Case_Status__c ='Decision issued - awaiting request for review';
        d.Scheme__c = s.Id;
        insert d;
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.Status ='Review request accepted';
        c.Origin='Phone';
        insert c;
        

    }
    
     @isTest
    public static void LoadAll(){
        EI_LandlordAgentNotificationclass.LoadAll(100);
        
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Landlord').getRecordTypeId();
      
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'Mishra';
        insert a;
        
         Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
        
         Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;
        d.Case_Status__c ='Decision issued - awaiting request for review';
        d.Scheme__c = s.Id;
        insert d;
        
        Case c = new Case();
        c.AccountId = a.Id;
        c.Status ='Review request accepted';
        c.Origin='Phone';
        insert c;
        

    }
}