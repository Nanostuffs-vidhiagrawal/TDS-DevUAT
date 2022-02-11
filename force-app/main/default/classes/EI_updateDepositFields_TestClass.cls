/*
@date  :     06/09/2021
@description : Testclass for -updateDepositFields

*/
@isTest
public class EI_updateDepositFields_TestClass {
      @TestSetup 
    public static void testmethodSetup(){
         Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        QueryLimits__c queryLimits = EI_TestDataFactory.createQueryLimit();
        insert queryLimits;
        account Landlord = EI_TestDataFactory.createLandlord(1)[0];
        insert Landlord;
        account Tenant = EI_TestDataFactory.createTenant(1)[0];
        insert Tenant;
        Property__c property= EI_TestDataFactory.createProperty(1,Landlord.id)[0];
        insert property;
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,Landlord.id,property.id)[0];
        insert deposit;
        case dispute = EI_TestDataFactory.createDispute(1,deposit.id)[0];
        insert dispute;

    }
    public static testmethod void test1(){
        Test.startTest();
           Case objCase = [Select id,Amount_Paid_to_Tenant__c,Amount_Paid_to_Landlord__c,Total_Claim_Amount__c,Status from Case Limit 1];
        objCase.Status = 'Repayment disputed - self-resolution';
        update objCase;
        objCase.Status = 'Evidence gathering AA/LL';
        update objCase;
        Test.stopTest();
    }
}