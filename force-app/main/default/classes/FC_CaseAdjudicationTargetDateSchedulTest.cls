/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what On a nightly schedule, retrieve uncompleted milestones of type Adjudication from all open disputes where 
 *      the milestone target_date is different than Case.Adjudication_Target_Date__c 
 *      and update Case.Adjudication_Target_Date to reflect the milestone
 *
 * @when 08/11/2019
 */
@IsTest
public with sharing class FC_CaseAdjudicationTargetDateSchedulTest {
    @TestSetup
    static void setup() {
        Account dummyAccount = (Account) FC_TestFactory.createSObject(new Account(), true);
        SlaProcess slaProcess = [SELECT Id FROM SlaProcess WHERE Name = 'EW Disputes' AND IsVersionDefault = true LIMIT 1];
        Entitlement entitlement = (Entitlement) FC_TestFactory.createSObject(
                new Entitlement(AccountId = dummyAccount.Id, SlaProcessId = slaProcess.Id),
                'FC_TestFactoryDefaults.EntitlementDefaults', true);
    }

    @IsTest
    static void testMilestoneChangeAdjudication() {
        List<Case> disputes = FC_TestFactory.createSObjectList(
                new Case(Status = FC_Constant.Case_Status_Review_Complete,
                        Adjudication_Target_Date__c = Date.today()),
                200, 'FC_TestFactoryDefaults.CaseDefaults', true);

        System.assertEquals(200, [SELECT count() FROM Case WHERE Adjudication_Target_Date__c = :Date.today()]);

        SchedulableContext sc = null;
        FC_CaseAdjudicationTargetDateScheduler scheduler = new FC_CaseAdjudicationTargetDateScheduler();

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();

        CaseMilestone milestone = [SELECT TargetDate FROM CaseMilestone WHERE MilestoneType.Name = :FC_Constant.CaseMilestone_Type_Adjudication LIMIT 1];
        System.assertEquals(200, [SELECT count() FROM Case WHERE Adjudication_Target_Date__c = :milestone.TargetDate]);
    }

    @IsTest
    static void testMilestoneChangeEvidenceGatheringTT() {
        List<Case> disputes = FC_TestFactory.createSObjectList(
                new Case(Status = FC_Constant.Case_Status_Evidence_Gathering_TT,
                        Adjudication_Target_Date__c = Date.today()),
                200, 'FC_TestFactoryDefaults.CaseDefaults', true);

        System.assertEquals(200, [SELECT count() FROM Case WHERE Adjudication_Target_Date__c = :Date.today()]);

        SchedulableContext sc = null;
        FC_CaseAdjudicationTargetDateScheduler scheduler = new FC_CaseAdjudicationTargetDateScheduler();

        Test.startTest();
        scheduler.execute(sc);
        Test.stopTest();

        CaseMilestone milestone = [SELECT TargetDate FROM CaseMilestone WHERE MilestoneType.Name = :FC_Constant.CaseMilestone_Type_Evidence_Gathering_TT LIMIT 1];
        System.assertEquals(0, [SELECT count() FROM Case WHERE Adjudication_Target_Date__c = :milestone.TargetDate]);
    }
}