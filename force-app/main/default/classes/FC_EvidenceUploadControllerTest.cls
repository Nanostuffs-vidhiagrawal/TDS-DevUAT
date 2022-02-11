/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_EvidenceUploadController
 *
 * @when 12/02/2020
 */
@IsTest
private class FC_EvidenceUploadControllerTest {
    @TestSetup
    static void setup() {
        Account landlord = (Account) FC_TestFactory.createSObject(new Account(Name='Elmer Fudd'), true);
        Scheme__c scheme1 = (Scheme__c) FC_TestFactory.createSObject(new Scheme__c(), 'FC_TestFactoryDefaults.SchemeDefaults', true);
        Deposit__c deposit1 = (Deposit__c) FC_TestFactory.createSObject(new Deposit__c(Scheme__c = scheme1.Id, Customer__c=landlord.Id), 'FC_TestFactoryDefaults.DepositDefaults', true);
        Case dispute = (Case) FC_TestFactory.createSObject(
                new Case(
                        Status = FC_Constant.Case_Status_New,
                        RecordTypeId=FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType,FC_Constant.RecordType_Zero_Deposit_Dispute_Dev_Name),
                        Deposit_Account_Number__c = deposit1.Id
                )
                , 'FC_TestFactoryDefaults.CaseDefaults',true);


        List<Dispute_Item__c> disputeItemsToInsert = new List<Dispute_Item__c>();
        List<Dispute_Item__c> disputeItemsLL = (List<Dispute_Item__c>) FC_TestFactory.createSObjectList(
                new Dispute_Item__c(Dispute__c=dispute.Id, Type__c = 'Gardening'),
                1,'FC_TestFactoryDefaults.DisputeItemDefaults',false);

        List<Dispute_Item__c> disputeItemsTT = (List<Dispute_Item__c>) FC_TestFactory.createSObjectList(
                new Dispute_Item__c(Dispute__c=dispute.Id, Type__c = 'Gardening'),
                1,'FC_TestFactoryDefaults.DisputeItemDefaults',false);

        disputeItemsToInsert.addAll(disputeItemsLL);
        disputeItemsToInsert.addAll(disputeItemsTT);
        insert disputeItemsToInsert;
    }
    
    @IsTest
    static void testGetDisputeItems() {
        Case dispute = [SELECT Id FROM Case LIMIT 1];
        
        List<Dispute_Item__c> items = FC_EvidenceUploadController.getDisputeItems(dispute.Id);
        for(Dispute_Item__c di : items) {
            System.assertEquals('Gardening',di.Type__c); 
        }
        System.assertEquals(2, items.size());
    }    
    
    @IsTest
    static void testCreateEvidenceAttachments() {
        Case dispute = [SELECT Id FROM Case LIMIT 1];
        
        List<FC_EvidenceUploadController.EvidenceAttachmentWrapper> files = new List<FC_EvidenceUploadController.EvidenceAttachmentWrapper>();
        FC_EvidenceUploadController.EvidenceAttachmentWrapper fileWrapper = new FC_EvidenceUploadController.EvidenceAttachmentWrapper();
        fileWrapper.file_name = 'test';
        fileWrapper.user_type = 'Tenant';
        fileWrapper.dispute_id = dispute.Id;
        fileWrapper.dispute_item_id = null;
        fileWrapper.file_type = 'jpg';
        fileWrapper.file_size = '123';
        fileWrapper.source = 'Admin';
        fileWrapper.url = 'https://test.com';

        files.add(fileWrapper);
        files.add(fileWrapper);
        
        FC_EvidenceUploadController.createEvidenceAttachments(files);
        System.assertEquals(2, [SELECT count() FROM Evidence_Attachment__c WHERE Dispute__c = :dispute.Id]);
    }

    @IsTest
    static void testGetLimitsForSchemeDisputeNoEvidence() {
        Case dispute = [SELECT Id, Scheme__c FROM Case LIMIT 1];

        Map<String,FC_EvidenceUploadController.LimitWrapper> limitsMap = FC_EvidenceUploadController.getLimitsForScheme(dispute.Scheme__c, dispute.Id);

        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeLimit);
        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeLimit);
        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeLimit);

        System.assertEquals(0, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeResult);
        System.assertEquals(0, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeResult);
        System.assertEquals(0, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeResult);
    }

    @IsTest
    static void testGetLimitsForSchemeDisputeEvidences() {
        Case dispute = [SELECT Id, Scheme__c FROM Case LIMIT 1];
        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = dispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test'
                ), 2,
                true
        );
        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = dispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Tenant,
                        Filename__c = 'test'
                ), 3,
                true
        );

        Map<String,FC_EvidenceUploadController.LimitWrapper> limitsMap = FC_EvidenceUploadController.getLimitsForScheme(dispute.Scheme__c, dispute.Id);

        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeLimit);
        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeLimit);
        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeLimit);

        System.assertEquals(2, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeResult);
        System.assertEquals(0, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeResult);
        System.assertEquals(3, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeResult);
    }

    @IsTest
    static void testGetLimitsForSchemeDisputeItemsEvidences() {
        Dispute_Item__c disputeItem = [SELECT Id, Dispute__c, Dispute__r.Scheme__c FROM Dispute_Item__c LIMIT 1];
        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = disputeItem.Dispute__c,
                        Dispute_Item__c = disputeItem.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test'
                ), 2,
                true
        );
        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = disputeItem.Dispute__c,
                        Dispute_Item__c = disputeItem.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Tenant,
                        Filename__c = 'test'
                ), 3,
                true
        );

        Map<String,FC_EvidenceUploadController.LimitWrapper> limitsMap = FC_EvidenceUploadController.getLimitsForScheme(disputeItem.Dispute__r.Scheme__c, disputeItem.Id);

        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeLimit);
        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeLimit);
        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeLimit);

        System.assertEquals(2, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeResult);
        System.assertEquals(0, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeResult);
        System.assertEquals(3, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeResult);
    }

    @IsTest
    static void testGetLimitsForSchemeDisputeAndDIEvidences() {
        Case dispute = [SELECT Id, Scheme__c FROM Case LIMIT 1];
        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = dispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test'
                ), 2,
                true
        );

        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = dispute.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Tenant,
                        Filename__c = 'test'
                ), 3,
                true
        );

        Dispute_Item__c disputeItem = [SELECT Id, Dispute__c, Dispute__r.Scheme__c FROM Dispute_Item__c LIMIT 1];
        FC_TestFactory.createSObjectList(
                new Evidence_Attachment__c(
                        Dispute__c = disputeItem.Dispute__c,
                        Dispute_Item__c = disputeItem.Id,
                        User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord,
                        Filename__c = 'test'
                ), 2,
                true
        );

        Map<String,FC_EvidenceUploadController.LimitWrapper> limitsMap = FC_EvidenceUploadController.getLimitsForScheme(dispute.Scheme__c, dispute.Id);

        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeLimit);
        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeLimit);
        System.assertEquals(5, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeLimit);

        System.assertEquals(2, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeResult);
        System.assertEquals(0, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeResult);
        System.assertEquals(3, limitsMap.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeResult);

        Map<String,FC_EvidenceUploadController.LimitWrapper> limitsMapDI = FC_EvidenceUploadController.getLimitsForScheme(dispute.Scheme__c, disputeItem.Id);
        System.assertEquals(5, limitsMapDI.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeLimit);
        System.assertEquals(5, limitsMapDI.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeLimit);
        System.assertEquals(5, limitsMapDI.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeLimit);

        System.assertEquals(2, limitsMapDI.get(FC_Constant.Evidence_Attachment_User_Type_Landlord).userTypeResult);
        System.assertEquals(0, limitsMapDI.get(FC_Constant.Evidence_Attachment_User_Type_Agent).userTypeResult);
        System.assertEquals(0, limitsMapDI.get(FC_Constant.Evidence_Attachment_User_Type_Tenant).userTypeResult);

    }

    @IsTest
    public static void testGetSchemeName(){
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

        System.assertEquals(FC_Constant.Despoit_Scheme_England_And_Wales_Insured, FC_EvidenceUploadController.getSchemeName(newDispute.Id));
    }
}