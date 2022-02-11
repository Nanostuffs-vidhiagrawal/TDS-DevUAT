/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_WebhookSubscriptionTriggerHandler
 *
 * @when 14/01/2020
 */
@IsTest
public with sharing class FC_WebhookSubscriptionTriggerHandlerTest {

    @TestSetup
    private static void setup() {
        FC_TestFactory.createSObject(new API_Account__c(), 'FC_TestFactoryDefaults.APIAccountDefaults', true);
    }
    
    @isTest
    static void Insert_webhook_subscription(){
        System.Test.setMock(WebServiceMock.class, new FC_MetadataServiceTest.WebServiceMockImpl());

        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);

        //when
        Test.startTest();
        Webhook_Subscription__c testSubscription = (Webhook_Subscription__c) FC_TestFactory.createSObject(
                new Webhook_Subscription__c(
                        Webhook_Endpoint__c = 'https://test.test.com',
                        API_Account__c = apiAccount.Id,
                        Webhook_Type__c = FC_Constant.CASE_UPDATE_EVENT_WEBHOOK_TYPE
                ), true
        );
        Test.stopTest();
        //then
        System.assertEquals(FC_WebhookSubscriptionHandler.testRemoteSiteSettings.url, 'https://test.test.com');
        System.assertNotEquals(null, [SELECT Shared_Key__c FROM Webhook_Subscription__c WHERE Id = :testSubscription.Id].Shared_Key__c);
    }

    @isTest
    static void Update_webhook_subscription(){
        System.Test.setMock(WebServiceMock.class, new FC_MetadataServiceTest.WebServiceMockImpl());

        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);
        Webhook_Subscription__c testSubscription = (Webhook_Subscription__c) FC_TestFactory.createSObject(
                new Webhook_Subscription__c(
                        Webhook_Endpoint__c = 'https://test.test.com',
                        API_Account__c = apiAccount.Id,
                        Webhook_Type__c = FC_Constant.CASE_UPDATE_EVENT_WEBHOOK_TYPE
                ), true
        );
        //when
        Test.startTest();
        testSubscription.Webhook_Endpoint__c = 'https://test1.test.com';
        update testSubscription;
        Test.stopTest();
        //then
        System.assertEquals(FC_WebhookSubscriptionHandler.testRemoteSiteSettings.url, 'https://test1.test.com');
    }
}