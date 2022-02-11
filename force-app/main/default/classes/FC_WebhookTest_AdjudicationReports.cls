/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit Tests for Webhook service
 *
 * @when 15/01/2020
 */
@IsTest
private class FC_WebhookTest_AdjudicationReports {
    public static Integer NUMBER_OF_RECORDS_TO_TEST = 20;
    
    @TestSetup
    private static void setup() {
        Test.setMock(HttpCalloutMock.class, new FC_WebhookCalloutMock.WebhookSuccessMock());
        API_Account__c apiAccount = (API_Account__c) FC_TestFactory.createSObject(new API_Account__c(), 'FC_TestFactoryDefaults.APIAccountDefaults', true);

        List<Webhook_Mapping__c> mappings = new List<Webhook_Mapping__c>{
                (Webhook_Mapping__c)FC_TestFactory.createSObject(
                        new Webhook_Mapping__c(
                                Webhook_Type__c = FC_Constant.ADJUDICATION_RESULTS_EVENT_WEBHOOK_TYPE,
                                Payload_Parameter_Name__c = 'dispute_id',
                                SObject_Name__c = 'Adjudication_Report__c',
                                Salesforce_Field_API_Name__c = 'Dispute_External_ID__c'
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
    static void testBulkSuccessesAdjudicationReportEventPublisher() {
        Test.setMock(HttpCalloutMock.class, new FC_WebhookCalloutMock.WebhookSuccessMock());

        List<Adjudication_Report__c> adjudicationReports = [SELECT Id, Dispute_External_ID__c FROM Adjudication_Report__c];
        for(Adjudication_Report__c report : adjudicationReports) {
            report.Status__c = FC_Constant.Adjudication_Report_Status_Published;
        }
        update adjudicationReports;

        Test.startTest();
        Test.getEventBus().deliver();
        Test.stopTest();

     //   System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM Webhook_Log__c WHERE HttpStatusCode__c = 200]);
    }
}