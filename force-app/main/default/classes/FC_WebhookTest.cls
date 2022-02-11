/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit Tests for Webhook service
 *
 * @when 15/01/2020
 */
@IsTest
private class FC_WebhookTest {
    public static Integer NUMBER_OF_RECORDS_TO_TEST = 20;
    
    @TestSetup
    private static void setup() {
        Test.setMock(HttpCalloutMock.class, new FC_WebhookCalloutMock.WebhookSuccessMock());
        API_Account__c apiAccount = (API_Account__c) FC_TestFactory.createSObject(new API_Account__c(), 'FC_TestFactoryDefaults.APIAccountDefaults', true);

        List<Webhook_Mapping__c> mappings = new List<Webhook_Mapping__c>{
                (Webhook_Mapping__c)FC_TestFactory.createSObject(
                        new Webhook_Mapping__c(
                                Webhook_Type__c = FC_Constant.CASE_UPDATE_EVENT_WEBHOOK_TYPE,
                                Payload_Parameter_Name__c = 'id',
                                SObject_Name__c = 'Case',
                                Salesforce_Field_API_Name__c = 'External_Id__c'
                        ),
                        false
                ),
                (Webhook_Mapping__c)FC_TestFactory.createSObject(
                        new Webhook_Mapping__c(
                                Webhook_Type__c = FC_Constant.CASE_UPDATE_EVENT_WEBHOOK_TYPE,
                                Payload_Parameter_Name__c = 'status',
                                SObject_Name__c = 'Case',
                                Salesforce_Field_API_Name__c = 'Status'
                        ),
                        false
                ),
                (Webhook_Mapping__c)FC_TestFactory.createSObject(
                        new Webhook_Mapping__c(
                                Webhook_Type__c = FC_Constant.CASE_UPDATE_EVENT_WEBHOOK_TYPE,
                                Payload_Parameter_Name__c = 'updated_datetime',
                                SObject_Name__c = 'Case',
                                Salesforce_Field_API_Name__c = 'LastmodifiedDate'
                        ),
                        false
                ),
                (Webhook_Mapping__c)FC_TestFactory.createSObject(
                        new Webhook_Mapping__c(
                                Webhook_Type__c = FC_Constant.CASE_UPDATE_EVENT_WEBHOOK_TYPE,
                                Payload_Parameter_Name__c = 'reasons',
                                SObject_Name__c = 'Case',
                                Salesforce_Field_API_Name__c = 'Dispute_Reasons__c'
                        ),
                        false
                )
        };
        insert mappings;

        List<Webhook_Subscription__c> subscriptions = new List<Webhook_Subscription__c>{
                (Webhook_Subscription__c)FC_TestFactory.createSObject(
                        new Webhook_Subscription__c(
                                Webhook_Endpoint__c = 'https://test.test.com',
                                API_Account__c = apiAccount.Id,
                                Webhook_Type__c = FC_Constant.CASE_UPDATE_EVENT_WEBHOOK_TYPE
                        ), 
                        false
                ),
                (Webhook_Subscription__c)FC_TestFactory.createSObject(
                        new Webhook_Subscription__c(
                                Webhook_Endpoint__c = 'https://test.test.com',
                                API_Account__c = apiAccount.Id,
                                Webhook_Type__c = FC_Constant.ADJUDICATION_RESULTS_EVENT_WEBHOOK_TYPE
                        ),
                        false
                )
        };
        insert subscriptions;
        
        List<Case> newDisputes = (List<Case>) FC_TestFactory.createSObjectList(
                new Case(API_Account__c = apiAccount.Id),
                NUMBER_OF_RECORDS_TO_TEST, 'FC_TestFactoryDefaults.CaseDefaults', true);

        List<Adjudication_Report__c> adjudicationReports = new List<Adjudication_Report__c>();
        for(Case dispute : newDisputes) {
            adjudicationReports.add((Adjudication_Report__c)FC_TestFactory.createSObject(
                    new Adjudication_Report__c(Dispute__c = dispute.Id)
            ));
        }
        insert adjudicationReports;
    }
    
    @IsTest
    static void testBulkSuccessesCaseUpdateEventPublisher() {
        Test.setMock(HttpCalloutMock.class, new FC_WebhookCalloutMock.WebhookSuccessMock());
        List<Case> newDisputes = [SELECT Id FROM Case];
        for(Case dispute : newDisputes) {
            dispute.Status = FC_Constant.Case_Status_Evidence_Gathering_LL;
        }
        update newDisputes;

        Test.startTest();
        Test.getEventBus().deliver();
        Test.stopTest();
        
   //     System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM Webhook_Log__c WHERE SObject_ID__c IN :FC_Utils.pluckIds(newDisputes) AND HttpStatusCode__c = 200]);
    }

    @IsTest
    static void testSuccessesData() {
        Test.setMock(HttpCalloutMock.class, new FC_WebhookCalloutMock.WebhookSuccessMock());
        List<Case> newDisputes = [SELECT Id FROM Case LIMIT 1];
        for(Case dispute : newDisputes) {
            dispute.Status = FC_Constant.Case_Status_Adjudication;
            dispute.Dispute_Reasons__c = 'testDisputeReasons';
            dispute.External_Id__c = FC_Constant.TEST_CLIENT_APIACCOUNTID + '-testExternalId';
        }
        update newDisputes;

        Test.startTest();
        Test.getEventBus().deliver();
        Test.stopTest();
        
        //String requestJSON = [SELECT JSON_request__c FROM Webhook_Log__c WHERE SObject_ID__c IN :FC_Utils.pluckIds(newDisputes)].JSON_request__c;
        
//		Map<String,Object> webhookObjectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
/* List<String> requestJSON = [SELECT JSON_request__c FROM Webhook_Log__c WHERE SObject_ID__c IN :FC_Utils.pluckIds(newDisputes)];
	if(!requestJSON.isEmpty()){
		Map<String,Object> webhookObjectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON[0]);
	}
       System.assertEquals('testDisputeReasons', webhookObjectMap.get('reasons'));
        System.assertEquals(FC_Constant.Case_Status_Adjudication, webhookObjectMap.get('status'));
        //notice that api account id is being removed from the value
        System.assertEquals('testExternalId', webhookObjectMap.get('id'));
        System.assertNotEquals(null, webhookObjectMap.get('updated_datetime'));*/
    }

    @IsTest
    static void testBulkErrors() {
        Test.setMock(HttpCalloutMock.class, new FC_WebhookCalloutMock.WebhookErrorMock());
        List<Case> newDisputes = [SELECT Id FROM Case];
        for(Case dispute : newDisputes) {
            dispute.Status = FC_Constant.Case_Status_Evidence_Gathering_LL;
        }
        update newDisputes;

        Test.startTest();
        Test.getEventBus().deliver();
        Test.stopTest();
   //     System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM Webhook_Log__c WHERE SObject_ID__c IN :FC_Utils.pluckIds(newDisputes) AND HttpStatusCode__c = 401]);
    }
}