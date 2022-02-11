/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Test class for FC_StageAutomationBatchScheduler  *
 * @when 29/10/2019
 */
@IsTest
private class FC_StageAutomationBatchSchedulerTest {

    @TestSetup
    static void setup() {
        Account dummyAccount = (Account) FC_TestFactory.createSObject(new Account(), true);
        SlaProcess slaProcess = [SELECT Id FROM SlaProcess WHERE Name = 'EW Disputes' AND IsVersionDefault = true LIMIT 1];
        Entitlement entitlement = (Entitlement) FC_TestFactory.createSObject(
                new Entitlement(AccountId = dummyAccount.Id, SlaProcessId = slaProcess.Id),
                'FC_TestFactoryDefaults.EntitlementDefaults', true);
        List<Case> evidenceGatheringLLDisputes = FC_TestFactory.createSObjectList(
                new Case(EntitlementId = entitlement.Id,
                        Status = FC_Constant.Case_Status_Evidence_Gathering_LL,
                        SlaStartDate = System.now(),
                        Evidence_Target_Date__c = Date.today(),
                        Pending_Status_Change__c = FC_Constant.Case_Status_Review_Complete),
                100, 'FC_TestFactoryDefaults.CaseDefaults', true);
        List<Case> newDisputes = FC_TestFactory.createSObjectList(
                new Case(EntitlementId = entitlement.Id,
                        SlaStartDate = System.now(),
                        Evidence_Target_Date__c = Date.today(),
                        Pending_Status_Change__c = FC_Constant.Case_Status_Evidence_Gathering_LL),
                100, 'FC_TestFactoryDefaults.CaseDefaults', true);
    }

    @IsTest
    static void testBatchable() {
        Test.startTest();

        SchedulableContext sc = null;
        FC_StageAutomationBatchScheduler scheduler = new FC_StageAutomationBatchScheduler();
        Database.executeBatch(scheduler, 2000);

        System.assertEquals(100, [SELECT count() FROM Case WHERE Status = :FC_Constant.Case_Status_New]);
        System.assertEquals(100, [SELECT count() FROM Case WHERE Status = :FC_Constant.Case_Status_Evidence_Gathering_LL]);

        Test.stopTest();

        System.assertEquals(100, [SELECT count() FROM Case WHERE Status = :FC_Constant.Case_Status_Evidence_Gathering_LL]);
        System.assertEquals(100, [SELECT count() FROM Case WHERE Status = :FC_Constant.Case_Status_Review_Complete]);

        System.assertEquals(100, [SELECT count() FROM CaseMilestone
                                WHERE IsCompleted = true AND Case.Status = :FC_Constant.Case_Status_Review_Complete]);
    }

    @IsTest
    static void testPendingStatusChangeIsEmpty() {
        List<Case> cases = [SELECT Id, Pending_Status_Change__c FROM Case];
        for(Case cs : cases) {
            System.assertNotEquals(null, cs.Pending_Status_Change__c);
            cs.Evidence_Target_Date__c = Date.today().addDays(20);
        }
        update cases;

        Test.startTest();

        SchedulableContext sc = null;
        FC_StageAutomationBatchScheduler scheduler = new FC_StageAutomationBatchScheduler();
        Database.executeBatch(scheduler, 2000);

        Test.stopTest();

        cases = [SELECT Id, Pending_Status_Change__c FROM Case];
        for(Case cs : cases) {
            System.assertNotEquals(null, cs.Pending_Status_Change__c);
        }
    }
    @IsTest
    static void testPendingStatusChangeToday() {
        List<Case> cases = [
                SELECT Id, Pending_Status_Change__c 
                FROM Case 
                WHERE Status = :FC_Constant.Case_Status_Evidence_Gathering_LL 
                    AND Pending_Status_Change__c = :FC_Constant.Case_Status_Review_Complete
        ];
        
        for(Case cs : cases) {
            cs.Evidence_Target_Date__c = Date.today();
        }
        update cases;

        Test.startTest();

        SchedulableContext sc = null;
        FC_StageAutomationBatchScheduler scheduler = new FC_StageAutomationBatchScheduler();
        Database.executeBatch(scheduler, 2000);

        Test.stopTest();

        System.assertEquals(cases.size(), [SELECT count() FROM Case WHERE Status = :FC_Constant.Case_Status_Review_Complete]);
    }

    @IsTest
    static void testPendingStatusChangeWithEmptyEvidenceTargetDate() {
        List<Case> cases = [
                SELECT Id, Pending_Status_Change__c
                FROM Case
                WHERE Status = :FC_Constant.Case_Status_Evidence_Gathering_LL
                AND Pending_Status_Change__c = :FC_Constant.Case_Status_Review_Complete
        ];

        for(Case cs : cases) {
            cs.Evidence_Target_Date__c = null;
        }
        update cases;

        Test.startTest();

        SchedulableContext sc = null;
        FC_StageAutomationBatchScheduler scheduler = new FC_StageAutomationBatchScheduler();
        Database.executeBatch(scheduler, 2000);

        Test.stopTest();

        System.assertEquals(cases.size(), [SELECT count() FROM Case WHERE Status = :FC_Constant.Case_Status_Review_Complete]);
    }
    

}