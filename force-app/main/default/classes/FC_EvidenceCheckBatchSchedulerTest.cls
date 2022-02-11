/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Test class for FC_EvidenceCheckBatchScheduler  *
 * @when 31/10/2019
 */
@IsTest
private class FC_EvidenceCheckBatchSchedulerTest {

    @TestSetup
    static void setup() {
        List<Case> evidenceGatheringLLDisputes = FC_TestFactory.createSObjectList(
                new Case(Pending_Status_Change__c = FC_Constant.Case_Status_Evidence_Gathering_LL),
                100, 'FC_TestFactoryDefaults.CaseDefaults', true);

        List<Case> evidenceGatheringTTDisputes = FC_TestFactory.createSObjectList(
                new Case(Pending_Status_Change__c = FC_Constant.Case_Status_Evidence_Gathering_TT),
                100, 'FC_TestFactoryDefaults.CaseDefaults', true);

        List<Dispute_Item__c> disputeItemsToInsert = new List<Dispute_Item__c>();
        for(Integer i=0; i < evidenceGatheringLLDisputes.size(); i++) {
            List<Dispute_Item__c> disputeItemsLL = (List<Dispute_Item__c>) FC_TestFactory.createSObjectList(
                    new Dispute_Item__c(Dispute__c=evidenceGatheringLLDisputes[i].Id),
                    1,'FC_TestFactoryDefaults.DisputeItemDefaults',false);
            
            List<Dispute_Item__c> disputeItemsTT = (List<Dispute_Item__c>) FC_TestFactory.createSObjectList(
                    new Dispute_Item__c(Dispute__c=evidenceGatheringTTDisputes[i].Id),
                    1,'FC_TestFactoryDefaults.DisputeItemDefaults',false);

            disputeItemsToInsert.addAll(disputeItemsLL);
            disputeItemsToInsert.addAll(disputeItemsTT);
        }
        insert disputeItemsToInsert;
    }

    @IsTest
    static void allDisputesToChangeStatus() {
        SchedulableContext sc = null;
        FC_EvidenceCheckBatchScheduler scheduler = new FC_EvidenceCheckBatchScheduler();
        
        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();
        
        System.assertEquals(200, [SELECT count() FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Awaiting_Review]);
        System.assertEquals(100, [SELECT count() FROM Case WHERE No_Landlord_Evidence__c = true]);
        System.assertEquals(100, [SELECT count() FROM Case WHERE No_Tenant_Evidence__c = true]);
    }
    
    @IsTest
    static void addLLEvidencesToAllDisputes() {
        SchedulableContext sc = null;
        FC_EvidenceCheckBatchScheduler scheduler = new FC_EvidenceCheckBatchScheduler();

        List<Evidence_Attachment__c> evidenceAttachmentsToInsert = new List<Evidence_Attachment__c>();
        for(Case dispute : [SELECT Id FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Evidence_Gathering_LL]) {
            List<Evidence_Attachment__c> evidenceAttachments = FC_TestFactory.createSObjectList(
                    new Evidence_Attachment__c(Dispute__c = dispute.Id,
                            User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord),
                    1, false);
            evidenceAttachmentsToInsert.addAll(evidenceAttachments);
        }
        insert evidenceAttachmentsToInsert;

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();
        
        System.assertEquals(0, [SELECT count() FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Awaiting_Review
            AND No_Landlord_Evidence__c = true]);
    }

    @IsTest
    static void addLLEvidencesTo50Disputes() {
        SchedulableContext sc = null;
        FC_EvidenceCheckBatchScheduler scheduler = new FC_EvidenceCheckBatchScheduler();

        List<Evidence_Attachment__c> evidenceAttachmentsToInsert = new List<Evidence_Attachment__c>();
        for(Case dispute : [SELECT Id FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Evidence_Gathering_LL LIMIT 50]) {
            List<Evidence_Attachment__c> evidenceAttachments = FC_TestFactory.createSObjectList(
                    new Evidence_Attachment__c(Dispute__c = dispute.Id,
                            User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord),
                    1, false);
            evidenceAttachmentsToInsert.addAll(evidenceAttachments);
        }
        insert evidenceAttachmentsToInsert;

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();

        System.assertEquals(50, [SELECT count() FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Awaiting_Review
            AND No_Landlord_Evidence__c = true]);
    }

    @IsTest
    static void addLLEvidencesToAllDisputeItems() {
        SchedulableContext sc = null;
        FC_EvidenceCheckBatchScheduler scheduler = new FC_EvidenceCheckBatchScheduler();

        List<Evidence_Attachment__c> evidenceAttachmentsToInsert = new List<Evidence_Attachment__c>();
        for(Dispute_Item__c disputeItem : [SELECT Id, Dispute__c FROM Dispute_Item__c WHERE Dispute__r.Pending_Status_Change__c = :FC_Constant.Case_Status_Evidence_Gathering_LL]) {
            List<Evidence_Attachment__c> evidenceAttachments = FC_TestFactory.createSObjectList(
                    new Evidence_Attachment__c(Dispute__c = disputeItem.Dispute__c, Dispute_Item__c = disputeItem.Id,
                            User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord),
                    1, false);
            evidenceAttachmentsToInsert.addAll(evidenceAttachments);
        }
        insert evidenceAttachmentsToInsert;

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Awaiting_Review
            AND No_Landlord_Evidence__c = true]);
    }

    @IsTest
    static void addLLEvidencesTo50DisputeItems() {
        SchedulableContext sc = null;
        FC_EvidenceCheckBatchScheduler scheduler = new FC_EvidenceCheckBatchScheduler();

        List<Evidence_Attachment__c> evidenceAttachmentsToInsert = new List<Evidence_Attachment__c>();
        for(Dispute_Item__c disputeItem : [SELECT Id, Dispute__c FROM Dispute_Item__c WHERE Dispute__r.Pending_Status_Change__c = :FC_Constant.Case_Status_Evidence_Gathering_LL LIMIT 50]) {
            List<Evidence_Attachment__c> evidenceAttachments = FC_TestFactory.createSObjectList(
                    new Evidence_Attachment__c(Dispute__c = disputeItem.Dispute__c, Dispute_Item__c = disputeItem.Id,
                            User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Landlord),
                    1, false);
            evidenceAttachmentsToInsert.addAll(evidenceAttachments);
        }
        insert evidenceAttachmentsToInsert;

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();

        System.assertEquals(50, [SELECT count() FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Awaiting_Review
            AND No_Landlord_Evidence__c = true]);
    }

    @IsTest
    static void addTTEvidencesToAllDisputes() {
        SchedulableContext sc = null;
        FC_EvidenceCheckBatchScheduler scheduler = new FC_EvidenceCheckBatchScheduler();

        List<Evidence_Attachment__c> evidenceAttachmentsToInsert = new List<Evidence_Attachment__c>();
        for(Case dispute : [SELECT Id FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Evidence_Gathering_TT]) {
            List<Evidence_Attachment__c> evidenceAttachments = FC_TestFactory.createSObjectList(
                    new Evidence_Attachment__c(Dispute__c = dispute.Id,
                            User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Tenant),
                    1, false);
            evidenceAttachmentsToInsert.addAll(evidenceAttachments);
        }
        insert evidenceAttachmentsToInsert;

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Awaiting_Review
            AND No_Tenant_Evidence__c = true]);
    }

    @IsTest
    static void addTTEvidencesTo50Disputes() {
        SchedulableContext sc = null;
        FC_EvidenceCheckBatchScheduler scheduler = new FC_EvidenceCheckBatchScheduler();

        List<Evidence_Attachment__c> evidenceAttachmentsToInsert = new List<Evidence_Attachment__c>();
        for(Case dispute : [SELECT Id FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Evidence_Gathering_TT LIMIT 50]) {
            List<Evidence_Attachment__c> evidenceAttachments = FC_TestFactory.createSObjectList(
                    new Evidence_Attachment__c(Dispute__c = dispute.Id,
                            User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Tenant),
                    1, false);
            evidenceAttachmentsToInsert.addAll(evidenceAttachments);
        }
        insert evidenceAttachmentsToInsert;

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();

        System.assertEquals(50, [SELECT count() FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Awaiting_Review
            AND No_Tenant_Evidence__c = true]);
    }

    @IsTest
    static void addTTEvidencesToAllDisputeItems() {
        SchedulableContext sc = null;
        FC_EvidenceCheckBatchScheduler scheduler = new FC_EvidenceCheckBatchScheduler();

        List<Evidence_Attachment__c> evidenceAttachmentsToInsert = new List<Evidence_Attachment__c>();
        for(Dispute_Item__c disputeItem : [SELECT Id, Dispute__c FROM Dispute_Item__c WHERE Dispute__r.Pending_Status_Change__c = :FC_Constant.Case_Status_Evidence_Gathering_TT]) {
            List<Evidence_Attachment__c> evidenceAttachments = FC_TestFactory.createSObjectList(
                    new Evidence_Attachment__c(Dispute__c = disputeItem.Dispute__c, Dispute_Item__c = disputeItem.Id,
                            User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Tenant),
                    1, false);
            evidenceAttachmentsToInsert.addAll(evidenceAttachments);
        }
        insert evidenceAttachmentsToInsert;

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Awaiting_Review
            AND No_Tenant_Evidence__c = true]);
    }
    @IsTest
    static void addTTEvidencesTo50DisputeItems() {
        SchedulableContext sc = null;
        FC_EvidenceCheckBatchScheduler scheduler = new FC_EvidenceCheckBatchScheduler();

        List<Evidence_Attachment__c> evidenceAttachmentsToInsert = new List<Evidence_Attachment__c>();
        for(Dispute_Item__c disputeItem : [SELECT Id, Dispute__c FROM Dispute_Item__c WHERE Dispute__r.Pending_Status_Change__c = :FC_Constant.Case_Status_Evidence_Gathering_TT LIMIT 50]) {
            List<Evidence_Attachment__c> evidenceAttachments = FC_TestFactory.createSObjectList(
                    new Evidence_Attachment__c(Dispute__c = disputeItem.Dispute__c, Dispute_Item__c = disputeItem.Id,
                            User_Type__c = FC_Constant.Evidence_Attachment_User_Type_Tenant),
                    1, false);
            evidenceAttachmentsToInsert.addAll(evidenceAttachments);
        }
        insert evidenceAttachmentsToInsert;

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();

        System.assertEquals(50, [SELECT count() FROM Case WHERE Pending_Status_Change__c = :FC_Constant.Case_Status_Awaiting_Review
            AND No_Tenant_Evidence__c = true]);
    }

}