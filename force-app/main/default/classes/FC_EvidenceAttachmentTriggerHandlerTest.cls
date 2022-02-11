/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_EvidenceAttachmentTriggerHandler
 *
 * @when 24/01/2020
 */
@IsTest
private class FC_EvidenceAttachmentTriggerHandlerTest {
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
    }

    @isTest
    static void testUploadAttachmentsOnInsertSuccess() {
        List<Case> disputes = [SELECT Id FROM Case];
        System.assertEquals(1, disputes.size());
        Case newDispute = disputes[0];

        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestMock());
        Test.startTest();
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
        Test.stopTest();

        List<Evidence_Attachment__c> attachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c attachment : attachments) {
            System.assert(attachment.IsUploaded__c);
        }
    }

    @isTest
    static void testUploadAttachmentsOnInsertFailure() {
        List<Case> disputes = [SELECT Id FROM Case];
        System.assertEquals(1, disputes.size());
        Case newDispute = disputes[0];

        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestMock());
        Test.startTest();
        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = newDispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test',
                        File_Type__c = 'test'
                ), numOfAttachments,
                true
        );
        Test.stopTest();

        List<Evidence_Attachment__c> attachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c attachment : attachments) {
            System.assert(!attachment.IsUploaded__c);
        }
    }

    @isTest
    static void testUploadAttachmentsOnUpdateSuccess() {
        List<Case> disputes = [SELECT Id FROM Case];
        System.assertEquals(1, disputes.size());
        Case newDispute = disputes[0];

        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = newDispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test',
                        File_Type__c = 'test'
                ), numOfAttachments,
                true
        );

        List<Evidence_Attachment__c> attachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c attachment : attachments) {
            System.assert(!attachment.IsUploaded__c);
            attachment.Supplier_Location__c = 'test';
        }

        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestMock());
        Test.startTest();
        update attachments;
        Test.stopTest();

        attachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c attachment : attachments) {
            System.assert(attachment.IsUploaded__c);
        }
    }

    @isTest
    static void testUploadAttachmentsOnUpdateFailure() {
        List<Case> disputes = [SELECT Id FROM Case];
        System.assertEquals(1, disputes.size());
        Case newDispute = disputes[0];

        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = newDispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test'
                ), numOfAttachments,
                true
        );

        List<Evidence_Attachment__c> attachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c attachment : attachments) {
            System.assert(!attachment.IsUploaded__c);
            attachment.File_Type__c = 'test';
        }

        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestMock());
        Test.startTest();
        update attachments;
        Test.stopTest();

        attachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c attachment : attachments) {
            System.assert(!attachment.IsUploaded__c);
        }
    }

    @isTest
    static void testDisabledTrigger() {
        List<Case> disputes = [SELECT Id FROM Case];
        System.assertEquals(1, disputes.size());
        Case newDispute = disputes[0];

        Test.setMock(HttpCalloutMock.class, new FC_AzureFunctionFileUploadServiceMock.UploadDocumentRequestMock());
        Test.startTest();
        FC_EvidenceAttachmentTriggerHandler.isDisabled = true;
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
        Test.stopTest();

        List<Evidence_Attachment__c> attachments = [SELECT Id, IsUploaded__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c attachment : attachments) {
            System.assert(!attachment.IsUploaded__c);
        }
    }

    @isTest
    static void testLocationSasAppend_Insert() {
        List<Case> disputes = [SELECT Id FROM Case];
        System.assertEquals(1, disputes.size());
        Case newDispute = disputes[0];

        List<Evidence_Attachment__c> attachments = (List<Evidence_Attachment__c>) FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = newDispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test',
                        Location__c = 'https://test.com'
                ), numOfAttachments,
                false
        );

        Test.startTest();
        insert attachments;
        Test.stopTest();

        Map<Id,Evidence_Attachment__c> oldEvidenceAttachmentsByIds = new Map<Id, Evidence_Attachment__c>(attachments);
        attachments = [SELECT Id, Location__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c newAttachment : attachments) {
            Evidence_Attachment__c oldAttachment = oldEvidenceAttachmentsByIds.get(newAttachment.Id);
            System.assertEquals(true, newAttachment.Location__c.contains('?'));
            System.assertEquals(true, newAttachment.Location__c.contains('&sp=r'));
            System.assertNotEquals(oldAttachment.Location__c, newAttachment.Location__c);
        }
    }

    @isTest
    static void testLocationSasAppend_Update() {
        List<Case> disputes = [SELECT Id FROM Case];
        System.assertEquals(1, disputes.size());
        Case newDispute = disputes[0];

        List<Evidence_Attachment__c> attachments = (List<Evidence_Attachment__c>) FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = newDispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test'
                ), numOfAttachments,
                true
        );

        Test.startTest();
        for(Evidence_Attachment__c attachment : attachments) {
            attachment.Location__c = 'https://test.com';
        }
        update attachments;
        Test.stopTest();

        Map<Id,Evidence_Attachment__c> oldEvidenceAttachmentsByIds = new Map<Id, Evidence_Attachment__c>(attachments);
        List<Evidence_Attachment__c> newAttachments = [SELECT Id, Location__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, newAttachments.size());
        for(Evidence_Attachment__c newAttachment : newAttachments) {
            Evidence_Attachment__c oldAttachment = oldEvidenceAttachmentsByIds.get(newAttachment.Id);
            System.assertEquals(true, newAttachment.Location__c.contains('?'));
            System.assertEquals(true, newAttachment.Location__c.contains('&sp=r'));
            System.assertNotEquals(oldAttachment.Location__c, newAttachment.Location__c);
        }
    }

    @isTest
    static void testLocationSasReplace_Insert() {
        List<Case> disputes = [SELECT Id FROM Case];
        System.assertEquals(1, disputes.size());
        Case newDispute = disputes[0];

        List<Evidence_Attachment__c> attachments = (List<Evidence_Attachment__c>) FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = newDispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test',
                        Location__c = 'https://test.com?token'
                ), numOfAttachments,
                false
        );

        Test.startTest();
        insert attachments;
        Test.stopTest();

        Map<Id,Evidence_Attachment__c> oldEvidenceAttachmentsByIds = new Map<Id, Evidence_Attachment__c>(attachments);
        attachments = [SELECT Id, Location__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c newAttachment : attachments) {
            Evidence_Attachment__c oldAttachment = oldEvidenceAttachmentsByIds.get(newAttachment.Id);
            System.assertEquals(true, newAttachment.Location__c.contains('?'));
            System.assertEquals(true, newAttachment.Location__c.contains('&sp=r'));
            System.assertNotEquals(oldAttachment.Location__c, newAttachment.Location__c);
        }
    }    
    
    @isTest
    static void testLocationSasReplace_Update() {
        List<Case> disputes = [SELECT Id FROM Case];
        System.assertEquals(1, disputes.size());
        Case newDispute = disputes[0];

        List<Evidence_Attachment__c> attachments = (List<Evidence_Attachment__c>) FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = newDispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test',
                        Location__c = 'https://test.com?token'
                ), numOfAttachments,
                true
        );

        Test.startTest();
        for(Evidence_Attachment__c attachment : attachments) {
            attachment.Location__c = 'https://test.com?token1';
        }
        update attachments;
        Test.stopTest();

        Map<Id,Evidence_Attachment__c> oldEvidenceAttachmentsByIds = new Map<Id, Evidence_Attachment__c>(attachments);
        attachments = [SELECT Id, Location__c FROM Evidence_Attachment__c];
        System.assertEquals(numOfAttachments, attachments.size());
        for(Evidence_Attachment__c newAttachment : attachments) {
            Evidence_Attachment__c oldAttachment = oldEvidenceAttachmentsByIds.get(newAttachment.Id);
            System.assertEquals(true, newAttachment.Location__c.contains('?'));
            System.assertEquals(true, newAttachment.Location__c.contains('&sp=r'));
            System.assertNotEquals(oldAttachment.Location__c, newAttachment.Location__c);
        }
    }
}