@isTest
public class EI_LandlordAgentNotificationclassTest {
	
    @isTest
    public static void getLandLordStatus(){
        
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Landlord').getRecordTypeId();
      
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.recordTypeId = RecordTypeId;
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Property__c = property.id;
 		deposit.Customer__c = acc.id;
        insert deposit;
               
        Case c = new Case();
        c.AccountId = acc.Id;
        c.Status ='Review request accepted';
        c.Origin='Phone';
        c.Deposit_Account_Number__c = deposit.id;
        insert c;
        
        EI_LandlordAgentNotificationclass.getLandLordStatus();
    }
    
    @isTest
    public static void getLandLordStatusforFinalList(){
                
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Landlord').getRecordTypeId();
      
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.recordTypeId = RecordTypeId;
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
               
        Case c = new Case();
        c.AccountId = acc.Id;
        c.Deposit_Account_Number__c = deposit.id;
        c.Status ='Awaiting evidence review';
        c.Origin='Phone';       
        insert c;
        
        EI_LandlordAgentNotificationclass.getLandLordStatus();
    }
    
    @isTest
    public static void getLandLordStatusforreviewTransferDepositList(){
      
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
        deposit.Customer__c = acc.id;      
        deposit.Deposit_Transferred__c = true;
        insert deposit;
               
        Case c = new Case();
        c.AccountId = acc.Id;
        c.Deposit_Account_Number__c = deposit.id;
        c.Status ='Awaiting evidence review';
        c.Origin='Phone';       
        insert c;
        
        EI_LandlordAgentNotificationclass.getLandLordStatus();
    }

    
}