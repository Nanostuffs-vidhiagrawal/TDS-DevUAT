/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Test class for FC_DeleteAllOldLogsBatchScheduler  *
 * @when 10/03/2020
 */
@IsTest
public with sharing class FC_DeleteAllOldLogsBatchSchedulerTest {
    @TestSetup
    static void setup(){
        List<Error_Log__c> errorLogs = FC_TestFactory.createSObjectList(
                new Error_Log__c(Message__c = 'some error'),
                100, true);

        List<Dispute_API_Error_Log__c> disputeApiErrorLogs = FC_TestFactory.createSObjectList(
                new Dispute_API_Error_Log__c(Message__c = 'some error'),
                100, true);

        List<SpringCM_Report_Error_Log__c> springCMReportErrorLogs = FC_TestFactory.createSObjectList(
                new SpringCM_Report_Error_Log__c(Message__c = 'some error'),
                100, true);
    }

    @IsTest
    static void ScheduleOldErrorLogsTest() {
        List<Error_Log__c> errorLogsBeforeBatch = [SELECT Id FROM Error_Log__c];
        Test.startTest();
        FC_DeleteAllOldLogsBatchScheduler.sixMonthsBeforeToday = date.today().addDays(1);
        FC_DeleteAllOldLogsBatchScheduler deleteLogs = new FC_DeleteAllOldLogsBatchScheduler(new List<string>{String.valueOf(Error_Log__c.getSObjectType())});
        Database.executeBatch(deleteLogs, 2000);
        Test.stopTest();
        List<Error_Log__c> errorLogsAfterBatch = [SELECT Id FROM Error_Log__c];
        System.assertEquals(100,errorLogsBeforeBatch.size());
        System.assertEquals(0,errorLogsAfterBatch.size());
    }

    @IsTest
    static void ScheduleOldDisputeApiErrorLogsTest() {
        List<Dispute_API_Error_Log__c> disputeApiErrorLogsBeforeBatch = [SELECT Id FROM Dispute_API_Error_Log__c];
        Test.startTest();
        FC_DeleteAllOldLogsBatchScheduler.sixMonthsBeforeToday = date.today().addDays(1);
        FC_DeleteAllOldLogsBatchScheduler deleteLogs = new FC_DeleteAllOldLogsBatchScheduler(new List<string>{String.valueOf(Dispute_API_Error_Log__c.getSObjectType())});
        Database.executeBatch(deleteLogs, 2000);
        Test.stopTest();
        List<Dispute_API_Error_Log__c> disputeApiErrorLogsAfterBatch = [SELECT Id FROM Dispute_API_Error_Log__c];
        System.assertEquals(100,disputeApiErrorLogsBeforeBatch.size());
        System.assertEquals(0,disputeApiErrorLogsAfterBatch.size());
    }

    @IsTest
    static void ScheduleOldSpringCMReportErrorLogsTest() {
        List<SpringCM_Report_Error_Log__c> springCMReportErrorLogsBeforeBatch = [SELECT Id FROM SpringCM_Report_Error_Log__c];
        Test.startTest();
        FC_DeleteAllOldLogsBatchScheduler.sixMonthsBeforeToday = date.today().addDays(1);
        FC_DeleteAllOldLogsBatchScheduler deleteLogs = new FC_DeleteAllOldLogsBatchScheduler(new List<string>{String.valueOf(SpringCM_Report_Error_Log__c.getSObjectType())});
        Database.executeBatch(deleteLogs, 2000);
        Test.stopTest();
        List<SpringCM_Report_Error_Log__c> springCMReportErrorLogsAfterBatch = [SELECT Id FROM SpringCM_Report_Error_Log__c];
        System.assertEquals(100,springCMReportErrorLogsBeforeBatch.size());
        System.assertEquals(0,springCMReportErrorLogsAfterBatch.size());
    }

    @IsTest
    static void ScheduleForAllOldLogsTest() {
        List<Error_Log__c> errorLogsBeforeBatch = [SELECT Id FROM Error_Log__c];
        List<Dispute_API_Error_Log__c> disputeApiErrorLogsBeforeBatch = [SELECT Id FROM Dispute_API_Error_Log__c];
        List<SpringCM_Report_Error_Log__c> springCMReportErrorLogsBeforeBatch = [SELECT Id FROM SpringCM_Report_Error_Log__c];
        Integer errorLogsBefore = errorLogsBeforeBatch.size() + disputeApiErrorLogsBeforeBatch.size() + springCMReportErrorLogsBeforeBatch.size();
        Test.startTest();
        FC_DeleteAllOldLogsBatchScheduler.sixMonthsBeforeToday = date.today().addDays(1);
        FC_DeleteAllOldLogsBatchScheduler deleteLogs = new FC_DeleteAllOldLogsBatchScheduler(new List<string>{String.valueOf(Error_Log__c.getSObjectType()),String.valueOf(Dispute_API_Error_Log__c.getSObjectType()),String.valueOf(SpringCM_Report_Error_Log__c.getSObjectType())});
        Database.executeBatch(deleteLogs, 2000);
        Test.stopTest();
        List<Error_Log__c> errorLogsAfterBatch = [SELECT Id FROM Error_Log__c];
        List<Dispute_API_Error_Log__c> disputeApiErrorLogsAfterBatch = [SELECT Id FROM Dispute_API_Error_Log__c];
        List<SpringCM_Report_Error_Log__c> springCMReportErrorLogsAfterBatch = [SELECT Id FROM SpringCM_Report_Error_Log__c];
        Integer errorLogsAfter = errorLogsAfterBatch.size() + disputeApiErrorLogsAfterBatch.size() + springCMReportErrorLogsAfterBatch.size();
        System.assertEquals(300,errorLogsBefore);
        System.assertEquals(0,errorLogsAfter);
    }
}