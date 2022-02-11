/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for the service class
 *
 * @when 24/01/2020
 */
@IsTest
private class FC_AzureFunctionFileUploadServiceTest {
    @TestSetup 
    static void setup() {
        Account landlord = (Account) FC_TestFactory.createSObject(new Account(Name='Elmer Fudd'), true);
        Scheme__c scheme1 = (Scheme__c) FC_TestFactory.createSObject(new Scheme__c(), 'FC_TestFactoryDefaults.SchemeDefaults', true);
        Deposit__c deposit1 = (Deposit__c) FC_TestFactory.createSObject(new Deposit__c(Scheme__c = scheme1.Id, Customer__c=landlord.Id), 'FC_TestFactoryDefaults.DepositDefaults', true);
        Case newDispute = (Case) FC_TestFactory.createSObject(
                new Case(
                        Status = FC_Constant.Case_Status_New, 
                        RecordTypeId=FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType,FC_Constant.RecordType_Zero_Deposit_Dispute_Dev_Name),
                        Deposit_Account_Number__c = deposit1.Id
                )
                , 'FC_TestFactoryDefaults.CaseDefaults',true);
        
        FC_TestFactory.createSObject(
                new Evidence_Attachment__c(
                        Dispute__c = newDispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test',
                        File_Type__c = 'test',
                        Supplier_Location__c = 'test'
                ),
                true);
    }

    @IsTest
    static void testSuccessRequest() {
        Evidence_Attachment__c evidenceAttachment = [
                SELECT Id, Deposit_Scheme__c, Filename__c, Supplier_Location__c, File_Type__c, Dispute__c
                FROM Evidence_Attachment__c
        ];
        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestMock());

        Test.startTest();
        FC_AzureFunctionFileUploadService service = new FC_AzureFunctionFileUploadService(evidenceAttachment);
        HTTPResponse httpResponse = service.uploadDocument();
        Test.stopTest();

        System.assertEquals(200, httpResponse.getStatusCode());
    }

    @IsTest
    static void testBadRequest() {
        Evidence_Attachment__c evidenceAttachment = [
                SELECT Id, Deposit_Scheme__c, Filename__c, Supplier_Location__c, File_Type__c, Dispute__c 
                FROM Evidence_Attachment__c
        ];
        //send the empty value to generate bad request
        evidenceAttachment.Filename__c = null;
        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestMock());
        
        Test.startTest();
        FC_AzureFunctionFileUploadService service = new FC_AzureFunctionFileUploadService(evidenceAttachment);
        HTTPResponse httpResponse = service.uploadDocument();
        Test.stopTest();
        
        System.assertEquals(400, httpResponse.getStatusCode());
    }    
    
    @IsTest
    static void testAuthorizationException() {
        Evidence_Attachment__c evidenceAttachment = [
                SELECT Id, Deposit_Scheme__c, Filename__c, Supplier_Location__c, File_Type__c, Dispute__c 
                FROM Evidence_Attachment__c
        ];
        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestAuthorizationErrorMock());
        
        Test.startTest();
        FC_AzureFunctionFileUploadService service = new FC_AzureFunctionFileUploadService(evidenceAttachment);
        HTTPResponse httpResponse = service.uploadDocument();
        Test.stopTest();
        
        System.assertEquals(401, httpResponse.getStatusCode());
    }
}