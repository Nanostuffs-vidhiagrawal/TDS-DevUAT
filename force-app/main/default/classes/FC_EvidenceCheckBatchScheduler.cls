/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Batch/Scheduler class to run daily that will pick up all Cases with 'Pending Status Change'
 *       in either 'Evidence Gathering - LL' or 'Evidence Gathering - TT' and related 'Evidence_Attachment__c' records
 *       and run the following logic:
 *        - If in Evidence Gathering - LL If no landlord evidence -> check No_Landlord_Evidence__c + set Pending_Status_Change__c = 'Awaiting Review'.
 *        - If in Evidence Gathering - TT If no tenant evidence-> check No_Tenant_Evidence__c + set Pending_Status_Change__c = 'Awaiting Review'
 * @when 31/10/2019
 */
public with sharing class FC_EvidenceCheckBatchScheduler implements Schedulable, Database.Batchable<sObject> {
    String query;
    Integer batchSize = 2000;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String selectClause = 'SELECT Id, Pending_Status_Change__c ';
        String fromClause = 'FROM Case ';
        String whereClause = 'WHERE Pending_Status_Change__c =\'Evidence Gathering - LL\' or Pending_Status_Change__c = \'Evidence Gathering - TT\'';
        this.query = selectClause + fromClause + whereClause;
        return Database.getQueryLocator(this.query);
    }

    public void execute(SchedulableContext ctx) {
        FC_EvidenceCheckBatchScheduler b = new FC_EvidenceCheckBatchScheduler();
        Database.executeBatch(b, this.batchSize);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope) {
        Map<Id, Case> casesByIds = new Map<Id, Case>(scope);

        Map<Id, List<Evidence_Attachment__c>> evidenceByCase = new Map<Id, List<Evidence_Attachment__c>>();
        for (Evidence_Attachment__c evidenceAttachment : [
                SELECT Id, User_Type__c, Dispute_Item__r.Dispute__c, Dispute__c
                FROM Evidence_Attachment__c
                WHERE Dispute__c IN :casesByIds.keySet() OR Dispute_Item__r.Dispute__c IN :casesByIds.keySet()
        ]) {
            if (evidenceAttachment.Dispute__c != null) {
                if (evidenceByCase.containsKey(evidenceAttachment.Dispute__c)) {
                    evidenceByCase.get(evidenceAttachment.Dispute__c).add(evidenceAttachment);
                } else {
                    evidenceByCase.put(evidenceAttachment.Dispute__c, new List<Evidence_Attachment__c>{
                            evidenceAttachment
                    });
                }
            } else if (evidenceAttachment.Dispute_Item__r != null && evidenceAttachment.Dispute_Item__r.Dispute__c != null) {
                if (evidenceByCase.containsKey(evidenceAttachment.Dispute_Item__r.Dispute__c)) {
                    evidenceByCase.get(evidenceAttachment.Dispute_Item__r.Dispute__c).add(evidenceAttachment);
                } else {
                    evidenceByCase.put(evidenceAttachment.Dispute_Item__r.Dispute__c, new List<Evidence_Attachment__c>{
                            evidenceAttachment
                    });
                }
            }
        }

        for (Id caseId : casesByIds.keySet()) {
            if (evidenceByCase.containsKey(caseId)) {
                for (Evidence_Attachment__c evidenceAttachment : evidenceByCase.get(caseId)) {
                    if (casesByIds.get(caseId).Pending_Status_Change__c == FC_Constant.Case_Status_Evidence_Gathering_LL
                            && evidenceAttachment.User_Type__c == FC_Constant.Evidence_Attachment_User_Type_Landlord
                            || casesByIds.get(caseId).Pending_Status_Change__c == FC_Constant.Case_Status_Evidence_Gathering_TT
                            && evidenceAttachment.User_Type__c == FC_Constant.Evidence_Attachment_User_Type_Tenant) {
                        casesByIds.remove(caseId);
                        break;
                    }
                }
            }
            if (casesByIds.containsKey(caseId)) {
                if (casesByIds.get(caseId).Pending_Status_Change__c == FC_Constant.Case_Status_Evidence_Gathering_LL)
                    casesByIds.get(caseId).No_Landlord_Evidence__c = true;
                if (casesByIds.get(caseId).Pending_Status_Change__c == FC_Constant.Case_Status_Evidence_Gathering_TT)
                    casesByIds.get(caseId).No_Tenant_Evidence__c = true;
                casesByIds.get(caseId).Pending_Status_Change__c = FC_Constant.Case_Status_Awaiting_Review;
            }
        }

        Savepoint sp = Database.setSavepoint();

        try {
            update casesByIds.values();
        } catch (DmlException dme) {
            System.debug('### Failed to update Case status from Pending Status on FC_EvidenceCheckBatchScheduler: ' + dme.getMessage());
            // rolling back
            Database.rollback(sp);
        }
    }

    public void finish(Database.BatchableContext BC) {
    }

}