/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_DisputeAPI_Authenticator
 *
 * @when 05/12/2019
 */
@IsTest
public with sharing class FC_DisputeAPI_AuthenticatorTest {
    static String accountId = 'ZeroDeposit';
    static String timestamp = String.valueOf(Datetime.now().getTime());
    static String hmac = FC_DisputeAPI_Authenticator.generateHMACKey(FC_Constant.TEST_CLIENT_ID, FC_Constant.TEST_CLIENT_SECRET, timestamp);

    @TestSetup
    private static void setup() {
        FC_TestFactory.createSObject(new API_Account__c(), 'FC_TestFactoryDefaults.APIAccountDefaults', true);
    }
    
    @IsTest
    private static void test_authorized() {         
        String accessToken = accountId + '-' + timestamp + '-' + hmac;

        new FC_DisputeAPI_Authenticator(accessToken).authenticate();
        System.assert(true, 'Successfully authenticated');
    }
    
    @IsTest
    private static void test_invalidToken() {
        String accessToken = accountId + '-' + timestamp + '-' + hmac + '-' + 'randomData';
        
        try {
            new FC_DisputeAPI_Authenticator(accessToken).authenticate();
            System.assert(false, 'This should never be reached');
        }
        catch(Exception exc) {
            System.assertEquals('Invalid access token format.', exc.getMessage());
        }
    }

    @IsTest
    private static void test_invalidHmac() {
        hmac = hmac + 'randomData';
        String accessToken = accountId + '-' + timestamp + '-' + hmac;

        try {
            new FC_DisputeAPI_Authenticator(accessToken).authenticate();
            System.assert(false, 'This should never be reached');
        }
        catch(Exception exc) {
            System.assertEquals('Invalid access token.', exc.getMessage());
        }
    }

    @IsTest
    private static void test_apiAccountNotFound() {
        accountId = accountId + 'randomData';
        String accessToken = accountId + '-' + timestamp + '-' + hmac;

        try {
            new FC_DisputeAPI_Authenticator(accessToken).authenticate();
            System.assert(false, 'This should never be reached');
        }
        catch(Exception exc) {
            System.assertEquals('AccountID not authorized.', exc.getMessage());
        }
    }

    @IsTest
    private static void test_timestampTooOld() {
        timestamp = String.valueOf(Datetime.now().addHours(-1).getTime());
        String accessToken = accountId + '-' + timestamp + '-' + hmac;

        try {
            new FC_DisputeAPI_Authenticator(accessToken).authenticate();
            System.assert(false, 'This should never be reached');
        }
        catch(Exception exc) {
            System.assertEquals('Timestamp is too old.', exc.getMessage());
        }
    }
}