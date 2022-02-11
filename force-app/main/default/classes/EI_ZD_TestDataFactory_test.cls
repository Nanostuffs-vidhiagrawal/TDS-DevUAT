@isTest
public class EI_ZD_TestDataFactory_test {
    @istest
    public static void testMethod1(){
        Test.startTest();
        QueryLimits__c quryLimit = EI_ZD_TestDataFactory.createQueryLimit();
         quryLimit.CheckOn__c=false;
         insert quryLimit;
             
        Scheme__c scm =  EI_ZD_TestDataFactory.createScheme();
         insert scm;
        API_Account__c ApAcc = EI_ZD_TestDataFactory.createAPIAccount();
        insert ApAcc; 
        
         Dispute_API_Object__c dispApiObj = EI_ZD_TestDataFactory.createDisputeAPIObject();
        insert dispApiObj; 
        list<Dispute_API_Mapping__c> dispApiMapp = EI_ZD_TestDataFactory.createDisputeAPIMappings(dispApiObj.id);
        insert dispApiMapp;  
         
         Dispute_API_Object__c agentApiObjj = EI_ZD_TestDataFactory.createAgentAPIObject();
        insert agentApiObjj; 
        list<Dispute_API_Mapping__c> agentApiMapp = EI_ZD_TestDataFactory.createAgentAPIMappings(agentApiObjj.id);
        insert agentApiMapp; 
         
         Dispute_API_Object__c landlordApiObjj = EI_ZD_TestDataFactory.createLandlordAPIObject();
        insert landlordApiObjj; 
        list<Dispute_API_Mapping__c> landlordApiMapp = EI_ZD_TestDataFactory.createLandloarAPIMappings(landlordApiObjj.id);
        insert landlordApiMapp; 
         
         Dispute_API_Object__c tenancyApiObjj = EI_ZD_TestDataFactory.createTenancyAPIObject();
        insert tenancyApiObjj; 
        list<Dispute_API_Mapping__c> tenancyApiMapp = EI_ZD_TestDataFactory.createTenancyAPIMappings(tenancyApiObjj.id);
        insert tenancyApiMapp; 
         
         Dispute_API_Object__c tenantApiObjj = EI_ZD_TestDataFactory.createTenantAPIObject();
        insert tenantApiObjj; 
        list<Dispute_API_Mapping__c> tenantApiMapp = EI_ZD_TestDataFactory.createTenantAPIMappings(tenantApiObjj.id);
        insert tenantApiMapp; 
        
        
        Test.stopTest();
        
    }

}