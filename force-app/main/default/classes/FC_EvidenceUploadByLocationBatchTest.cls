/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for the batch class
 *
 * @when 24/01/2020
 */
@IsTest
private class FC_EvidenceUploadByLocationBatchTest {
    private static final Integer numOfAttachments = 10;
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

        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = newDispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test',
                        File_Type__c = 'test',
                        Supplier_Location__c = 'test'
                ), numOfAttachments,
                true
        );
    }

    @isTest
    static void testSuccessBatch() {
        List<Evidence_Attachment__c> evidenceAttachments = [
                SELECT Id, Deposit_Scheme__c, Filename__c, Supplier_Location__c, File_Type__c, Dispute__c, IsUploaded__c
                FROM Evidence_Attachment__c
        ];
        System.assertEquals(numOfAttachments, evidenceAttachments.size());
        List<Id> evidenceIds = new List<Id>();
        for(Evidence_Attachment__c attachment : evidenceAttachments) {
            System.assert(!attachment.IsUploaded__c);
            evidenceIds.add(attachment.Id);
        }

        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestMock());
        Test.startTest();
        FC_EvidenceUploadByLocationBatch batch = new FC_EvidenceUploadByLocationBatch(evidenceIds);
        Database.executeBatch(batch);
        Test.stopTest();

        evidenceAttachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        for(Evidence_Attachment__c attachment : evidenceAttachments) {
            System.assert(attachment.IsUploaded__c);
        }
    }

    @isTest
    static void testFailureBatch() {
        List<Evidence_Attachment__c> evidenceAttachments = [
                SELECT Id, Deposit_Scheme__c, Filename__c, Supplier_Location__c, File_Type__c, Dispute__c, IsUploaded__c
                FROM Evidence_Attachment__c
        ];
        System.assertEquals(numOfAttachments, evidenceAttachments.size());
        List<Id> evidenceIds = new List<Id>();
        for(Evidence_Attachment__c attachment : evidenceAttachments) {
            System.assert(!attachment.IsUploaded__c);
            evidenceIds.add(attachment.Id);
            attachment.Filename__c = null;
        }

        update evidenceAttachments;

        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestMock());
        Test.startTest();
        FC_EvidenceUploadByLocationBatch batch = new FC_EvidenceUploadByLocationBatch(evidenceIds);
        Database.executeBatch(batch);
        Test.stopTest();

        evidenceAttachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        for(Evidence_Attachment__c attachment : evidenceAttachments) {
            System.assert(!attachment.IsUploaded__c);
        }
    }

    @isTest
    static void testAuthFailureBatch() {
        List<Evidence_Attachment__c> evidenceAttachments = [
                SELECT Id, Deposit_Scheme__c, Filename__c, Supplier_Location__c, File_Type__c, Dispute__c, IsUploaded__c
                FROM Evidence_Attachment__c
        ];
        System.assertEquals(numOfAttachments, evidenceAttachments.size());
        List<Id> evidenceIds = new List<Id>();
        for(Evidence_Attachment__c attachment : evidenceAttachments) {
            System.assert(!attachment.IsUploaded__c);
            evidenceIds.add(attachment.Id);
        }

        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestAuthorizationErrorMock());
        Test.startTest();
        FC_EvidenceUploadByLocationBatch batch = new FC_EvidenceUploadByLocationBatch(evidenceIds);
        Database.executeBatch(batch);
        Test.stopTest();

        evidenceAttachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        for(Evidence_Attachment__c attachment : evidenceAttachments) {
            System.assert(!attachment.IsUploaded__c);
        }
    }
}