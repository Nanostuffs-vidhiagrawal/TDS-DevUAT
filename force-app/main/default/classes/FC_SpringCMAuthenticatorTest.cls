/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for SpringCM authentication flow
 *
 * @when 19/11/2019
 */
@IsTest
private class FC_SpringCMAuthenticatorTest {
    @TestSetup
    static void setup() {
        FC_TestFactory.createSObject(new SpringCM_Settings__c(), 'FC_TestFactoryDefaults.SpringCMSettingsDefaults', true);
    }
    
    @IsTest
    static void testSuccessRequest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_SpringCMCalloutMock.AuthResponseSuccessMock());
        FC_SpringCMAuthenticator.AuthResponse authResponse = (FC_SpringCMAuthenticator.AuthResponse) new FC_SpringCMAuthenticator().sendRequest();
        Test.stopTest();
        System.assertEquals('access_token', authResponse.access_token);
    }

    @IsTest
    static void testErrorRequest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FC_SpringCMCalloutMock.AuthResponseErrorMock());
        FC_SpringCMAuthenticator.AuthErrorResponse authResponse = (FC_SpringCMAuthenticator.AuthErrorResponse) new FC_SpringCMAuthenticator().sendRequest();
        Test.stopTest();
        System.assertEquals('invalid_client', authResponse.error);
    }
}