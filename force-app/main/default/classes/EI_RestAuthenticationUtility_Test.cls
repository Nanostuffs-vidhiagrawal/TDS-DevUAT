@isTest
public class EI_RestAuthenticationUtility_Test {
     
     @isTest static void method1(){
         
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
         
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/disputeapi/';  
        req.httpMethod = 'POST';
        req.addHeader('AccessToken', 'zd_espire-1626283768936-621d26a380f374d95c0ae6580941f48ef73fde84'); 
        
        req.requestBody = Blob.valueOf('{"landlord": {"external_id": "landlordId2012", "email": "test1@test.com", "lastname": "Landlord", "firstname": "jan19", "phone_number": "07401655677","birth_date": "1990-01-13","postcode": "EC3M5DJ","street": "fenchurch","city": "london","country": "UK"},"Tenancy": {"end_date": "2019-12-23","start_date": "2019-12-23","deposit_amount": 2500.00,"country": "UK","city": "London","street": "Faringford Road","postcode": "E15 4DG","customer_id": "landlordId20","reference": "1111333","external_id": "tenancyshhh6j676701","customer_type" :"agent","rent_protection": "false"},"tenant": [{"email": "test8@test8.com","lastname": "Tenant","firstname": "jan18","external_id": "t8","phone_number": "07899855677","birth_date": "1999-08-23"},{"email": "test9@test9.com","lastname": "Tenant","firstname": "Jan18-2","external_id": "t9","phone_number": "07899855677","birth_date": "1999-08-23"},{"email": "test10@test10.com","lastname": "Tenant","firstname": "jan18-3","external_id": "t10","phone_number": "07899855677","birth_date": "1999-08-23"}],"dispute": {"initiated_by": "Landlord","tenancy_id": "tenancy68","lead_landlord_id": "landlordId20","total_claim_amount": 2000.00,"dispute_reasons": "tenant left house in a mess","external_id": "disputedhh6h8112011","deposit_owner_id":"landlordId20"},"agent": {"external_id": "agent20","firstname": "Joe","lastname": "Bloggs Jan18","email": "joe@bloggs.com","mobile": "07501655678","job_title": "CFO"}}');
        //req.requestBody = blob.valueOf('{"landlord": {"external_id": "landlordId2012","email": "test1@test.com","lastname": "Landlord","firstname": "jan19","phone_number": "07401655677","birth_date": "1990-01-13","postcode": "EC3M5DJ","street": "fenchurch","city": "london","country": "UK"}}');
        RestContext.request = req;
        RestContext.response = res;
          
        Test.startTest();
         EI_ZD_DisputeAPI.calculateWorkingDaysBetweenTwoDates(system.today(), 5);
         EI_ZD_DisputeAPI.calculateWorkingDaysBetweenTwoDates1(system.today(), 10);
         
        EI_ZD_DisputeAPI.postMethod();
         RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = '/services/apexrest/disputeapi/';  
        req1.httpMethod = 'POST';
        req1.addHeader('AccessToken', 'fdfdf'); 
        
        //req.requestBody = Blob.valueOf('{"landlord": {"external_id": "landlordId2012", "email": "test1@test.com", "lastname": "Landlord", "firstname": "jan19", "phone_number": "07401655677","birth_date": "1990-01-13","postcode": "EC3M5DJ","street": "fenchurch","city": "london","country": "UK"},"Tenancy": {"end_date": "2019-12-23","start_date": "2019-12-23","deposit_amount": 2500.00,"country": "UK","city": "London","street": "Faringford Road","postcode": "E15 4DG","customer_id": "landlordId20","reference": "1111333","external_id": "tenancyshhh6j676701","customer_type" :"landlord","rent_protection": "false"},"tenant": [{"email": "test8@test8.com","lastname": "Tenant","firstname": "jan18","external_id": "t8","phone_number": "07899855677","birth_date": "1999-08-23"},{"email": "test9@test9.com","lastname": "Tenant","firstname": "Jan18-2","external_id": "t9","phone_number": "07899855677","birth_date": "1999-08-23"},{"email": "test10@test10.com","lastname": "Tenant","firstname": "jan18-3","external_id": "t10","phone_number": "07899855677","birth_date": "1999-08-23"}],"dispute": {"initiated_by": "Landlord","tenancy_id": "tenancy68","lead_landlord_id": "landlordId20","total_claim_amount": 2000.00,"dispute_reasons": "tenant left house in a mess","external_id": "disputedhh6h8112011","deposit_owner_id":"landlordId20"},"agent": {"external_id": "agent20","firstname": "Joe","lastname": "Bloggs Jan18","email": "joe@bloggs.com","mobile": "07501655678","job_title": "CFO"}}');
        req1.requestBody = blob.valueOf('{"landlord": "fddfd"}');
        RestContext.request = req1;
        RestContext.response = res1;
          
        EI_ZD_DisputeAPI.postMethod();
        Test.stopTest();
    }
    
    @isTest static void method2(){
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/disputeapi/';  
        req.httpMethod = 'POST';
        req.addHeader('AccessToken', 'fdfdf'); 
        
        //req.requestBody = Blob.valueOf('{"landlord": {"external_id": "landlordId2012", "email": "test1@test.com", "lastname": "Landlord", "firstname": "jan19", "phone_number": "07401655677","birth_date": "1990-01-13","postcode": "EC3M5DJ","street": "fenchurch","city": "london","country": "UK"},"Tenancy": {"end_date": "2019-12-23","start_date": "2019-12-23","deposit_amount": 2500.00,"country": "UK","city": "London","street": "Faringford Road","postcode": "E15 4DG","customer_id": "landlordId20","reference": "1111333","external_id": "tenancyshhh6j676701","customer_type" :"landlord","rent_protection": "false"},"tenant": [{"email": "test8@test8.com","lastname": "Tenant","firstname": "jan18","external_id": "t8","phone_number": "07899855677","birth_date": "1999-08-23"},{"email": "test9@test9.com","lastname": "Tenant","firstname": "Jan18-2","external_id": "t9","phone_number": "07899855677","birth_date": "1999-08-23"},{"email": "test10@test10.com","lastname": "Tenant","firstname": "jan18-3","external_id": "t10","phone_number": "07899855677","birth_date": "1999-08-23"}],"dispute": {"initiated_by": "Landlord","tenancy_id": "tenancy68","lead_landlord_id": "landlordId20","total_claim_amount": 2000.00,"dispute_reasons": "tenant left house in a mess","external_id": "disputedhh6h8112011","deposit_owner_id":"landlordId20"},"agent": {"external_id": "agent20","firstname": "Joe","lastname": "Bloggs Jan18","email": "joe@bloggs.com","mobile": "07501655678","job_title": "CFO"}}');
        req.requestBody = blob.valueOf('{"landlord": "fddfd"}');
        RestContext.request = req;
        RestContext.response = res;
          
        Test.startTest();
        EI_ZD_DisputeAPI.postMethod();
        Test.stopTest();
    }
}