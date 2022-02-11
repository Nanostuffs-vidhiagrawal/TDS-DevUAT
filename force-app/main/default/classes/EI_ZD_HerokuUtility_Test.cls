@isTest
public class EI_ZD_HerokuUtility_Test {
	
    @isTest static void myUnitTest() {
         
         API_Account__c ApAcc = EI_ZD_TestDataFactory.createAPIAccount();
         ApAcc.Name = 'ZeroDeposit';
         insert ApAcc;
        
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse();
		 
         req.httpMethod = 'POST';
         
         req.requestUri = '/services/apexrest/setVars/';       
         String postData = '{"ASD":"12322323232","DATABASE_URL":"postgres://nhhzeopdnhsgxu:f7a850d547785b90fd8e73937969cc6a4b1e974a73dc1ec25729d52ef7eac75c@ec2-54-74-35-87.eu-west-1.compute.amazonaws.com:5432/dai25p4a8579lh"}';
         String JsonMsg=JSON.serialize(postData);
         req.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = req; 
         RestContext.response= res;
         Test.startTest();
         	EI_ZD_HerokuUtility.getConfigVars();
         Test.stopTest();
   }
}