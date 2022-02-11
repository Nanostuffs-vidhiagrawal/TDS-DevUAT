/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Tests for Adjudication Report Trigger handled in FC_AdjudicationReportTriggerHandler
 * 1. Update Report and assigned Case on Published Status Change
 *
 * @when 09/11/2019
 */
@IsTest
private class FC_AdjudicationReportTriggerHandlerTest {
    public static Integer NUMBER_OF_RECORDS_TO_TEST = 200;
    @TestSetup
    static void setup() {
        Account dummyAccount = (Account) FC_TestFactory.createSObject(new Account(), true);
        SlaProcess slaProcess = [SELECT Id FROM SlaProcess WHERE Name = 'EW Disputes' AND IsVersionDefault = true LIMIT 1];
        Entitlement entitlement = (Entitlement) FC_TestFactory.createSObject(
                new Entitlement(AccountId = dummyAccount.Id, SlaProcessId = slaProcess.Id),
                'FC_TestFactoryDefaults.EntitlementDefaults', true);
        List<Case> disputes = FC_TestFactory.createSObjectList(
                new Case(Status = FC_Constant.Case_Status_Review_Complete),
                NUMBER_OF_RECORDS_TO_TEST, 'FC_TestFactoryDefaults.CaseDefaults', true);
    }

    @IsTest
    static void testAdjudicationReportPublished_Insert_Published() {
        List<Adjudication_Report__c> adjudicationReports = new List<Adjudication_Report__c>();
        for(Case dispute : [SELECT Id FROM Case]) {
            Adjudication_Report__c report = (Adjudication_Report__c)FC_TestFactory.createSObject(
                    new Adjudication_Report__c(Dispute__c = dispute.Id, Status__c = FC_Constant.Adjudication_Report_Status_Published));
            adjudicationReports.add(report);
        }

        Test.startTest();
        insert adjudicationReports;
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM Adjudication_Report__c WHERE Published_Date__c = TODAY]);
        System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM Case
                WHERE Status = :FC_Constant.Case_Status_Closed
                AND Close_Reason__c = :FC_Constant.Case_Close_Reason_Adjudication_Decision_Reached]);
        System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM CaseMilestone
                WHERE MilestoneType.Name = :FC_Constant.CaseMilestone_Type_Adjudication AND IsCompleted = true]);
    }

    @IsTest
    static void testAdjudicationReportPublished_Update_Published() {
        List<Adjudication_Report__c> adjudicationReports = new List<Adjudication_Report__c>();
        for(Case dispute : [SELECT Id FROM Case]) {
            Adjudication_Report__c report = (Adjudication_Report__c)FC_TestFactory.createSObject(
                    new Adjudication_Report__c(Dispute__c = dispute.Id));
            adjudicationReports.add(report);
        }
        insert adjudicationReports;

        Test.startTest();
        for(Adjudication_Report__c report : adjudicationReports) {
            report.Status__c = FC_Constant.Adjudication_Report_Status_Published;
        }
        update adjudicationReports;
        Test.stopTest();

        System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [SELECT count() FROM Adjudication_Report__c WHERE Published_Date__c = TODAY]);
        System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [
                SELECT count() FROM Case
                WHERE Status = :FC_Constant.Case_Status_Closed
                    AND Close_Reason__c = :FC_Constant.Case_Close_Reason_Adjudication_Decision_Reached]);
        System.assertEquals(NUMBER_OF_RECORDS_TO_TEST, [
                SELECT count() FROM CaseMilestone
                WHERE MilestoneType.Name = :FC_Constant.CaseMilestone_Type_Adjudication AND IsCompleted = true]);
    }
}