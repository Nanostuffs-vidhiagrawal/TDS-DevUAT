@isTest
public class EI_ZD_updateStatusEvidencegathLL_Test {
    @TestSetup
    Public static void dataSetup(){
        QueryLimits__c ql = new QueryLimits__c();
        ql.CheckOn__c=true;
        ql.Name = 'All Limits';
        insert ql;
        List<Case> caseList = new List<case>(); 
        Scheme__c scheme= EI_ZD_TestDataFactory.createScheme();
        insert scheme;
        QueryLimits__c queryLimits = EI_ZD_TestDataFactory.createQueryLimit();
        insert queryLimits;
        ZD_Payment_API__c payment=EI_ZD_TestDataFactory.createPaymentCustomSetting();
        insert payment;
        account Landlord = EI_ZD_TestDataFactory.createLandlord(1)[0];
        insert Landlord;
        account Tenant = EI_ZD_TestDataFactory.createTenant(1)[0];
        insert Tenant;
        Property__c property= EI_ZD_TestDataFactory.createProperty(1,Landlord.id)[0];
        insert property;
        Deposit__c deposit= EI_ZD_TestDataFactory.createDeposite(1,scheme.id,Landlord.id,property.id)[0];
        insert deposit;
        case dispute = EI_ZD_TestDataFactory.createDispute(1,deposit.id)[0];
        dispute.Status='Invitation to view the claim';
        dispute.Respond_Date__c=system.today();
        insert dispute;
        Case_Participant__c casetenant = EI_ZD_TestDataFactory.createCaseParticipant(1,dispute.id,Tenant.id,'Tenant')[0];
        insert casetenant;
        Case_Participant__c caselandlord = EI_ZD_TestDataFactory.createCaseParticipant(1,dispute.id,Landlord.id,'Landlord')[0];
        insert caselandlord;

        Dispute_item__c di = new Dispute_item__c(type__c='cleaning',Dispute__c=dispute.id);
        insert di;
        
    }
    @isTest
    public static void test1(){
        database.executeBatch(new EI_ZD_updateStatusEvidencegatheringLL());        
    }
}