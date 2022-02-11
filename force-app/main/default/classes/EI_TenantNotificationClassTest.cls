@isTest
public class EI_TenantNotificationClassTest {
    
    @isTest
    public static void method1(){
        
                 
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Property__c = property.id;
        deposit.Deposit_Transferred_to_Account__c = acc.id;      
        insert deposit;
        
        Deposit_Allocation__c da = new Deposit_Allocation__c();
        da.Deposit__c =  deposit.id;
        da.Deposit_Holder__c = acc.Id;                                           //MD to Account
       // da.Contact__c = c.Id;
        insert da;
        
        test.startTest();
        EI_TenantNotificationClass.getdepositstatus();    
        test.stopTest();
    }
    
    @isTest
    public static void methodforalldata(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Property__c = property.id;
        deposit.Deposit_Transferred_to_Account__c = acc.id;      
        deposit.Deposit_Amount_Amend__c = true;
       
        insert deposit;
        
        Deposit_Allocation__c da = new Deposit_Allocation__c();
        da.Deposit__c =  deposit.id;
        da.Deposit_Holder__c = acc.Id;                                           //MD to Account
       // da.Contact__c = c.Id;
        insert da;
        EI_TenantNotificationClass.getdepositstatus();        
    }
    
    @isTest
    public static void updateDeposit(){
         Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Property__c = property.id;
        deposit.Deposit_Transferred_to_Account__c = acc.id;    
        insert deposit;
        
       string message =  EI_TenantNotificationClass.updateDeposit(deposit.id);
        System.assertEquals(message, 'success');
    }

}