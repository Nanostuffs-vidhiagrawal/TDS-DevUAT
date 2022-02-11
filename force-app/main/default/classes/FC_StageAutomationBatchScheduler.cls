/**
 * @who  Tiago Lopes <tiago.lopes@weare4c.com>
 * @what Batch/Scheduler class to run daily that will pick up all open Cases and move Status to mirror
 *       'Pending_Stage_Change' field value originated from milestone update to allow Case Status to move on
 *
 * @when 8/10/2019
 */
public with sharing class FC_StageAutomationBatchScheduler implements Schedulable, Database.Batchable<sObject> {
    String query;
    Integer batchSize = 2000;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        // query Open Cases where 'Pending_Status_Change__c' field is populated and its related Open CaseMilestone
        String selectClause = 'SELECT Status, Pending_Status_Change__c, Evidence_Target_Date__c,' +
                ' (SELECT CaseId, CompletionDate FROM CaseMilestones WHERE IsCompleted = FALSE LIMIT 1) ';
        String fromClause = 'FROM Case ';
        String whereClause = 'WHERE IsClosed = FALSE AND Pending_Status_Change__c != NULL';
        this.query = selectClause + fromClause + whereClause;
        return Database.getQueryLocator(this.query);
    }

    // Schedulable execute
    public void execute(SchedulableContext ctx){
        // run batch on given cron
        // Batch size 1234 is used only in Unit Test
        if(System.Test.isRunningTest() && this.batchSize != 1234) {
            throw new FC_ScheduledJobManager.FC_ScheduledJobManagerException('Batch Size is null');
        }
        
        FC_StageAutomationBatchScheduler b = new FC_StageAutomationBatchScheduler();
        Database.executeBatch(b, this.batchSize);
    }

    // Batchable execute
    public void execute(Database.BatchableContext BC, List<Case> scope) {
        FC_ErrorLogger.start('FC_StageAutomationBatchScheduler','execute');
        List<CaseMilestone> caseMilestonesToComplete = new List<CaseMilestone>();
        List<Case> casesToUpdate = new List<Case>();
        for(Case c : scope){
            //if Evidence target date is empty set it to today and make the process update the statuses anyway 
            Date evidenceTargetDate = c.Evidence_Target_Date__c == null ? Date.today() : Date.newInstance(c.Evidence_Target_Date__c.year(), c.Evidence_Target_Date__c.month(), c.Evidence_Target_Date__c.day());
            
            if(evidenceTargetDate <= Date.today() && c.Pending_Status_Change__c != null) {
                // change Status field to mirror Pending_Status_Change__c
                c.Status = c.Pending_Status_Change__c;
                c.Pending_Status_Change__c = null;
            }
            // complete caseMilestone
            if(!c.CaseMilestones.isEmpty()) {
                c.CaseMilestones.get(0).CompletionDate = System.today();
                // add to list to update
                caseMilestonesToComplete.add(c.CaseMilestones.get(0));
            }
            // add to list of cases to update
            casesToUpdate.add(c);
        }

        // update milestones
        try {
            List<Database.Saveresult> msResults = Database.update(caseMilestonesToComplete, false);
            for (Integer i = 0; i < msResults.size(); i++) {
                if (!msResults[i].isSuccess()) {
                    FC_ErrorLogger.error(msResults[i].getErrors(), caseMilestonesToComplete[i].Id);
                }
            }

            try {
                List<Database.Saveresult> caseUpdateResults = Database.update(casesToUpdate, false);
                for (Integer i = 0; i < caseUpdateResults.size(); i++) {
                    if (!caseUpdateResults[i].isSuccess()) {
                        FC_ErrorLogger.error(caseUpdateResults[i].getErrors(), casesToUpdate[i].Id);
                    }
                }
            }
            catch (DmlException dme2) {
                System.debug('### Failed to update Case status from Pending Status on FC_StageAutomationBatchScheduler: ' + dme2.getMessage());
                FC_ErrorLogger.error(dme2);
            }

        }
        catch(DmlException dme1){
            System.debug('### Failed to update CaseMilestone CompletionDate on FC_StageAutomationBatchScheduler: ' + dme1.getMessage());
            FC_ErrorLogger.error(dme1);
        }
        FC_ErrorLogger.stop();
    }

    public void finish(Database.BatchableContext BC) {
    }
}