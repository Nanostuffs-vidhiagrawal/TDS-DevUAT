/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_DisputeAPI_PublishReport
 *
 * @when 04/03/2019
 */
@IsTest
public with sharing class FC_DisputeAPI_PublishReport_Test {
    static String accountId = 'ZeroDeposit';
    static String timestamp = String.valueOf(Datetime.now().getTime());
    static String hmac = FC_DisputeAPI_Authenticator.generateHMACKey(FC_Constant.TEST_CLIENT_ID, FC_Constant.TEST_CLIENT_SECRET, timestamp);

    @TestSetup
    public static void setup() {
        FC_TestFactory.createSObject(new API_Account__c(), 'FC_TestFactoryDefaults.APIAccountDefaults', true);
        FC_TestFactory.createSObject(new Case(), 'FC_TestFactoryDefaults.CaseDefaults', true);
    }

    @IsTest
    static void testSuccess() {
        Case dispute = [SELECT Id FROM Case LIMIT 1];
        Map<String,Object> payloadObject = new Map<String, Object>();
        payloadObject.put('tds_dispute_id', dispute.Id);

        setRequest(JSON.serialize(payloadObject));

        Test.startTest();
        FC_DisputeAPI_PublishReport.postPublishReport();
        Test.stopTest();

        FC_DisputeAPI_StatusUpdate.StatusUpdateResponse response = (FC_DisputeAPI_StatusUpdate.StatusUpdateResponse) JSON.deserializeStrict(RestContext.response.responseBody.toString(), FC_DisputeAPI_StatusUpdate.StatusUpdateResponse.class);

     //   System.assertEquals(true, response.success);
      //  System.assertEquals(200, RestContext.response.statusCode);
    }
    
    @IsTest
    static void testWrongDisputeId() {
        Case dispute = [SELECT Id FROM Case LIMIT 1];
        delete dispute;
        Map<String,Object> payloadObject = new Map<String, Object>();
        payloadObject.put('tds_dispute_id', dispute.Id);

        setRequest(JSON.serialize(payloadObject));
        
        Test.startTest();
        FC_DisputeAPI_PublishReport.postPublishReport();
        Test.stopTest();

        FC_DisputeAPI_StatusUpdate.StatusUpdateResponse response = (FC_DisputeAPI_StatusUpdate.StatusUpdateResponse) JSON.deserializeStrict(RestContext.response.responseBody.toString(), FC_DisputeAPI_StatusUpdate.StatusUpdateResponse.class);

     //   System.assertEquals(404, RestContext.response.statusCode);
     //   System.assertEquals('Case not found', response.errors);
        System.assertEquals(false, response.success);
    }
    
    private static void setRequest(String jsonString) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(jsonString);
        req.requestURI = 'https://disputeApiTest';
        req.httpMethod = FC_Constant.HTTP_POST_METHOD;

        String accessToken = accountId + '-' + timestamp + '-' + hmac;
        req.headers.put('accessToken',accessToken);

        RestContext.request = req;
        RestContext.response = res;
    }
}