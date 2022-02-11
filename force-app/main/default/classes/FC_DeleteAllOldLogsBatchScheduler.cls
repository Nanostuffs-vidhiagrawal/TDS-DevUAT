/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Batch/Scheduler class to run every 6 month that will delete all
 * Error_Log__c, Dispute_API_Error_Log__c, SpringCM_Report_Error_Log__c objects
 * which creation date is older than 6 months
 * @when 10/03/2019
 */

public with sharing class FC_DeleteAllOldLogsBatchScheduler implements Schedulable, Database.Batchable<sObject> {
    final string deleteType;
    final List<string> deleteTypes;
    public static Date sixMonthsBeforeToday = Date.today().addMonths(-6);
    Integer batchSize = 5000;

    public FC_DeleteAllOldLogsBatchScheduler(List<string> deleteTypes) {
        this.deleteType = deleteTypes.remove(0);
        this.deleteTypes = deleteTypes;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id FROM ' + deleteType + ' WHERE CreatedDate < :sixMonthsBeforeToday');
    }

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(this);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        Database.delete(scope, false);
    }

    public void finish(Database.BatchableContext context) {
        if (!deleteTypes.isEmpty()) {
            Database.executeBatch(new FC_DeleteAllOldLogsBatchScheduler(deleteTypes), batchSize);
        }
    }
}