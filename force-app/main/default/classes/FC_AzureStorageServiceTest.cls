/**
 * @who  Tiago Lopes <tiago.lopes@weare4c.com>
 * @what Test class for FC_AzureStorageService
 * @when 4/2/2020
 */
@IsTest
private class FC_AzureStorageServiceTest {

    @IsTest
    static void when_schemeNameIsValid_expect_sasTokenToBeReturned() {
        String sasToken;

        Test.startTest();
            sasToken = FC_AzureStorageService.createAccessUrl('Zero Deposit', true, 'c');
        Test.stopTest();

        System.assertNotEquals(null, sasToken);
        System.assertEquals(0, [SELECT Id FROM Error_Log__c].size());
    } 

    @isTest
    static void when_schemeNameIsInvalid_Expect_NullTokenAndErrorLogged() {
        String sasToken;

        Test.startTest();
        try {
            sasToken = FC_AzureStorageService.createAccessUrl('Fake Scheme', true, 'c');
        }
        catch(Exception e){
            System.assert(e instanceof FC_AzureStorageService.CredentialsForSchemeNotFoundException);
        }
        Test.stopTest();

        System.assertEquals(null, sasToken);
        System.assertEquals(1, [SELECT Id FROM Error_Log__c].size());
    }

    @isTest
    static void when_operationIsValid_expect_sasTokenToBeReturned() {
        String sasToken;

        Test.startTest();
        sasToken = FC_AzureStorageService.createAccessUrl('Zero Deposit', true, 'c');
        Test.stopTest();

        System.assertNotEquals(null, sasToken);
        System.assertEquals(0, [SELECT Id FROM Error_Log__c].size());
    }

    @isTest
    static void when_operationIsInvalid_expect_NullTokenAndErrorLogged(){
        String sasToken;

        Test.startTest();
        try{
            sasToken = FC_AzureStorageService.createAccessUrl('Zero Deposit', true, 'd');
        }
        catch(Exception e){
            System.assert(e instanceof FC_AzureStorageService.OperationNotAllowedException);
        }
        Test.stopTest();

        System.assertEquals(null, sasToken);
        System.assertEquals(1, [SELECT Id FROM Error_Log__c].size());
    }
}