/**
 * @who   Tiago Lopes @4C <tiago.lopes@weare4c.com>
 * @what  Handler class model for Case
 * @when  7/10/2019
 */
public with sharing class FC_CaseHandler {
    // Static set to control Case trigger recursion
    public static Set<Id> processedCaseIds = new Set<Id>();
    public static Set<Id> massMailerProcessedCaseIds = new Set<Id>();
    public static Set<Id> webhookProcessedCaseIds = new Set<Id>();

    private Case myCase;

    public FC_CaseHandler(Case myCase){
        this.myCase = myCase;
    }

    public void setLeadTenant(Id tenantId){
        this.myCase.Tenant__c = tenantId;
    }

    public Case getCase(){
        return this.myCase;
    }


    
    // bulk handler sub class to handle filtering and dispatch
    public class BulkCaseHandler{

        /**
         * Handles bulk cases coming from onAfterInsert and OnAfterUpdate trigger event
         * @param newMap
         * @param oldMap
         */
        public void handleCaseAssignmentRuleTrigger(Map<Id,Case> newMap, Map<Id,Case> oldMap){
            /*List<Case> casesToFireAR = new List<Case>();
            // filter
            for(Id caseId : newMap.keySet()) {
                if(!FC_CaseHandler.processedCaseIds.contains(caseId)) {
                    Case oldCase = oldMap == null ? null : oldMap.get(caseId);
                    if (isStatusChangedToReviewComplete(newMap.get(caseId), oldCase))
                        casesToFireAR.add(newMap.get(caseId));
                }
                processedCaseIds.add(caseId);
            }
            if(!casesToFireAR.isEmpty()) FC_CaseAssignmentHandler.processCaseAssignmentRuleTrigger(casesToFireAR);*/
        }

        /**
         * Handles bulk cases coming from all trigger after events
         * @param newMap
         * @param oldMap
         */
        public void handleRollupDisputedAmountOnAccounts(Map<Id,Case> newMap, Map<Id,Case> oldMap){
            /*Set<Id> accountIdsToRollup = new Set<Id>();
            // filter
            for(Case newCase : newMap.values()) {
                Case oldCase = oldMap == null ? null : oldMap.get(newCase.Id);
                if(newCase.AccountId != null && requiresRollupRecalculation(newCase, oldCase)) {
                    accountIdsToRollup.add(newCase.AccountId);
                }                 
            }
            if(!accountIdsToRollup.isEmpty()) {
                FC_CaseAccountRollupCalculator.rollupDisputedAmountForAccounts(accountIdsToRollup);
            }*/
        }

        /**
         * Handles bulk cases coming from all trigger after events
         * @param newMap
         * @param oldMap
         */
        //public void handleEntitlementAssignmentBeforeInsert(List<Case> newCases){
            /*List<Case> filteredCases = new List<Case>();
            // filter
            for(Case newCase : newCases) {
                if(isRecordTypeChanged(newCase, null)) {
                    filteredCases.add(newCase);
                }
            }
            if(!filteredCases.isEmpty()) {
                FC_CaseEntitlementSetter.setEntitlementForCase(filteredCases);
            }*/
        //}
        /**
         * Handles bulk cases coming from all trigger after events
         * @param newMap
         * @param oldMap
         */
        //public void handleEntitlementAssignmentBeforeUpdate(Map<Id,Case> newMap, Map<Id,Case> oldMap){
            /*List<Case> filteredCases = new List<Case>();
            // filter
            for(Case newCase : newMap.values()) {
                if(isRecordTypeChanged(newCase, oldMap.get(newCase.Id))) {
                    filteredCases.add(newCase);
                }
            }
            if(!filteredCases.isEmpty()) {
                FC_CaseEntitlementSetter.setEntitlementForCase(filteredCases);
            }*/
        //}   
        
        /**
         * Handles bulk cases coming from before insert and before update trigger events
         * @param newCases
         * @param oldMap
         */
        //public void handleStatusChangeFromReviewCompleteToAdjudicationOnOwnerChange(List<Case> newCases, Map<Id,Case> oldMap){
            /*List<Case> filteredCases = new List<Case>();
            // filter
            for(Case newCase : newCases) {
                Case oldCase = oldMap != null ? oldMap.get(newCase.Id) : null;
                if(isOwnerChangedFromQueueToUserAtReviewComplete(newCase, oldCase)) {
                    filteredCases.add(newCase);
                }
            }
            if(!filteredCases.isEmpty()) {
                FC_CaseHandler.changeStatusForReviewCompleteUserOwner(filteredCases);
            }*/
        //}

        /**
         * Handles bulk cases coming from before insert and before update trigger events
         * @param newCases
         * @param oldMap
         */
        public void handleCaseTeamWhenOwnerChanges(Map<Id,Case>  newCases, Map<Id,Case> oldMap){
            /*List<Case> filteredCases = new List<Case>();
            // filter
            for(Case newCase : newCases.values()) {
                Case oldCase = oldMap != null ? oldMap.get(newCase.Id) : null;
                if(isOwnerChangedForNonClosedCase(newCase, oldCase)) {
                    filteredCases.add(newCase);
                }
            }
            if(!filteredCases.isEmpty()) {
                FC_CaseTeamHandler.setCaseTeamForCase(filteredCases);
            }*/
        }
        /**
         * Handles bulk cases coming from before insert and before update trigger events
         * @param newCases
         * @param oldMap
         */
        //public void handleCaseStatusChange(List<Case> newCases, Map<Id,Case> oldMap){
            /*List<Case> filteredCases = new List<Case>();
            // filter
            for(Case newCase : newCases) {
                Case oldCase = oldMap != null ? oldMap.get(newCase.Id) : null;
                if(isStatusChanged(newCase, oldCase)) {
                    filteredCases.add(newCase);
                }
            }
            if(!filteredCases.isEmpty()) {
                FC_CaseHandler.setStatusEntryDate(filteredCases);
            }*/
        //}
        /**
         * Publishes teh Case Status Update Events to bus after update
         *
         * @param newCases
         * @param oldMap
         */
        public void publishCaseStatusChangeEvent(List<Case> newCases, Map<Id,Case> oldMap){
            List<Case> filteredCases = new List<Case>();
            // filter
            for(Case newCase : newCases) {
                Case oldCase = oldMap != null ? oldMap.get(newCase.Id) : null;
                if(!webhookProcessedCaseIds.contains(newCase.Id) && isStatusChanged(newCase, oldCase)) {
                    filteredCases.add(newCase);
                    webhookProcessedCaseIds.add(newCase.Id);
                }
            }
            if(!filteredCases.isEmpty()) {
                new FC_WebhookEventPublisher.CaseUpdateEventPublisher(filteredCases).publishEvents();
            }
        }
        /**
         * Handles bulk cases coming from before insert and before update trigger events
         * @param newCases
         * @param oldMap
         */
        public void handleMassmailerOrchestration(List<Case> newCases, Map<Id,Case> oldMap){
            /*List<Id> filteredCaseIds = new List<Id>();
            // filter
            for(Case newCase : newCases) {
                if(!FC_CaseHandler.massMailerProcessedCaseIds.contains(newCase.Id)) {
                    Case oldCase = oldMap != null ? oldMap.get(newCase.Id) : null;
                    if(isStatusChanged(newCase, oldCase)) {
                        filteredCaseIds.add(newCase.Id);
                    }
                }
            }
            if(!filteredCaseIds.isEmpty()) {
                FC_CaseHandler.runMassmailerOrchestrationFlow(filteredCaseIds);
            }*/
        }
        /******* filters *******/

        /*private Boolean isStatusChangedToReviewComplete(Case newCase, Case oldCase){
            return oldCase == null ? (newCase.Status == FC_Constant.Case_Status_Review_Complete)
                    : (newCase.Status == FC_Constant.Case_Status_Review_Complete
                            && oldCase.Status != FC_Constant.Case_Status_Review_Complete);
        }*/

        /*private Boolean requiresRollupRecalculation(Case newCase, Case oldCase){
            Boolean isDisputeRecordType = FC_Utils.getDisputeCaseRecordTypeIds().contains(newCase.RecordTypeId);
            Boolean isNewCaseClosed = newCase.IsClosed;
            Boolean isOldCaseClosed = oldCase == null ? false : oldCase.IsClosed;
            Boolean isNewOrOldCaseClosed = isNewCaseClosed || isOldCaseClosed;
            Boolean hasStatusChanged = oldCase == null ? true : oldCase.Status != newCase.Status;
            Boolean hasAmountChanged = oldCase == null ? 
                    newCase.Disputed_Amount__c != null : oldCase.Disputed_Amount__c != newCase.Disputed_Amount__c;
            
            return isDisputeRecordType && ((isNewOrOldCaseClosed && hasStatusChanged) || hasAmountChanged);
        }*/

        /*private Boolean isRecordTypeChanged(Case newCase, Case oldCase){
            return oldCase == null ? true : (newCase.RecordTypeId != oldCase.RecordTypeId);
        }
        
        private Boolean isOwnerChangedFromQueueToUserAtReviewComplete(Case newCase, Case oldCase){
            return oldCase.OwnerId != newCase.OwnerId && newCase.Status == FC_Constant.Case_Status_Review_Complete 
                    && ((String)newCase.OwnerId).startsWith('005') && ((String)oldCase.OwnerId).startsWith('00G');
        }

        private Boolean isOwnerChangedForNonClosedCase(Case newCase, Case oldCase){
            return (oldCase == null || oldCase.OwnerId != newCase.OwnerId) && !newCase.IsClosed
                    //is newCase owner User type
                    && ((String)newCase.OwnerId).startsWith('005');
        }*/

        private Boolean isStatusChanged(Case newCase, Case oldCase){
            
            return oldCase == null ? true : newCase.Status != oldCase.Status;
        } 
    }

    /***** ended filters *****/
    
    /*private static void changeStatusForReviewCompleteUserOwner(List<Case> newCases) {
        for(Case newCase : newCases) {
            newCase.Status = FC_Constant.Case_Status_Adjudication;
        }
    }

    private static void setStatusEntryDate(List<Case> newCases) {
        Datetime datetimenow = Datetime.now();
        for(Case newCase : newCases) {
            newCase.Status_Entry_Date__c = datetimenow;
        }
    }*/

    /**
     * Runs the Massmailer Orchestration flow and catches the exceptions in the log
     *
     * @param newCasesIds
     */
    /*private static void runMassmailerOrchestrationFlow(List<Id> newCasesIds) {
        massMailerProcessedCaseIds.addAll(newCasesIds);
        try {
            Map<String, Object> params = new Map<String, Object>{'caseIds' => newCasesIds};
            Flow.Interview.Flow_MassmailerOrchestration massMailerOrchestrationFlow = new Flow.Interview.Flow_MassmailerOrchestration(params);
            massMailerOrchestrationFlow.start();
        }
        catch(FlowException flowException) {
            FC_ErrorLogger.error('Flow Exception has occured in flow:: Flow_MassmailerOrchestration for caseIds:: ' + newCasesIds);
        }
    }*/
}