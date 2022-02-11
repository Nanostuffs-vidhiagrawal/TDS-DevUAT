/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what On a nightly schedule, set Adjudication_Target_Date__c on the cases containing open milestone Adjudication 
 * with the target date  of that milestone
 *
 * @when 07/11/2019
 */
public with sharing class FC_CaseAdjudicationTargetDateScheduler implements Schedulable, Database.Batchable<sObject> {
    Integer batchSize = 2000;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, Adjudication_Target_Date__c,
                    (SELECT Id, TargetDate FROM CaseMilestones WHERE IsCompleted = false
                    AND MilestoneType.Name = :FC_Constant.CaseMilestone_Type_Adjudication)
                FROM Case
                WHERE IsClosed = false
                    AND RecordTypeId IN :FC_Utils.getDisputeCaseRecordTypeIds()]);
    }

    public void execute(SchedulableContext ctx) {
        FC_CaseAdjudicationTargetDateScheduler b = new FC_CaseAdjudicationTargetDateScheduler();
        Database.executeBatch(b, this.batchSize);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Case> casesToUpdate = new List<Case>();
        for(Case theCase : scope) {
            for(CaseMilestone milestone : theCase.CaseMilestones) {
                if(theCase.Adjudication_Target_Date__c != milestone.TargetDate) {
                    theCase.Adjudication_Target_Date__c = milestone.TargetDate;
                    casesToUpdate.add(theCase);
                }
            }
        }

        Savepoint sp = Database.setSavepoint();

        try {
            update casesToUpdate;
        } catch (DmlException dme) {
            FC_ErrorLogger.error(dme);
            System.debug('### Failed to update Case Adjudication Target Date in  FC_CaseAdjudicationTargetDateScheduler: ' + dme.getMessage());
            // rolling back
            Database.rollback(sp);
        }
    }

    public void finish(Database.BatchableContext BC) {
    }

}