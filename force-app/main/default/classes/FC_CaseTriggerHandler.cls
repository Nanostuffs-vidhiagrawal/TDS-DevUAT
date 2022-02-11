/**
* @who  Tiago Lopes @4C <tiago.lopes@weare4c.com>
* @what Case trigger handler class.
*       Implements ITriggerHandler to allow dynamic run via TriggerDispatcher class
* @when 7/10/2019
 */ 
public class FC_CaseTriggerHandler implements FC_ITriggerHandler{
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean isDisabled = false;

    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled(){
        Trigger_Settings__c triggerSettings = Trigger_Settings__c.getOrgDefaults();
        if (triggerSettings != null && triggerSettings.Disabled_Case__c)
                return true;
        else
                return isDisabled;
    }

    public void beforeInsert(List<SObject> newItems){
        //FC_CaseHandler.BulkCaseHandler handler = new FC_CaseHandler.BulkCaseHandler();
        //handler.handleEntitlementAssignmentBeforeInsert(newItems);
        //handler.handleCaseStatusChange(newItems,null);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        FC_CaseHandler.BulkCaseHandler handler = new FC_CaseHandler.BulkCaseHandler();
        //handler.handleEntitlementAssignmentBeforeUpdate((Map<Id,Case>)newItems, (Map<Id,Case>)oldItems);
        //handler.handleStatusChangeFromReviewCompleteToAdjudicationOnOwnerChange((List<Case>)newItems.values(), (Map<Id,Case>)oldItems);
        //handler.handleCaseStatusChange((List<Case>)newItems.values(), (Map<Id,Case>)oldItems);

    }

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems){
        //FC_CaseHandler.BulkCaseHandler handler = new FC_CaseHandler.BulkCaseHandler();
        // fire AR for Case on Status
        //handler.handleCaseAssignmentRuleTrigger((Map<Id,Case>)newItems, null);
        //handler.handleRollupDisputedAmountOnAccounts((Map<Id,Case>)newItems, null);
        //handler.handleCaseTeamWhenOwnerChanges((Map<Id,Case>)newItems, null);
        //handler.handleMassmailerOrchestration(newItems.values(), null);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        FC_CaseHandler.BulkCaseHandler handler = new FC_CaseHandler.BulkCaseHandler();
        // fire AR for Case on Status
        handler.handleCaseAssignmentRuleTrigger((Map<Id,Case>)newItems, (Map<Id,Case>)oldItems);
        handler.handleRollupDisputedAmountOnAccounts((Map<Id,Case>)newItems, (Map<Id,Case>)oldItems);
        handler.handleCaseTeamWhenOwnerChanges((Map<Id,Case>)newItems, (Map<Id,Case>)oldItems);
        handler.handleMassmailerOrchestration(newItems.values(), (Map<Id,Case>)oldItems);
        handler.publishCaseStatusChangeEvent((List<Case>)newItems.values(), (Map<Id,Case>)oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
        FC_CaseHandler.BulkCaseHandler handler = new FC_CaseHandler.BulkCaseHandler();
        //we threat oldItems as newItems in afterDelete context
        handler.handleRollupDisputedAmountOnAccounts((Map<Id,Case>)oldItems, null);
    }

    public void afterUndelete(Map<Id, SObject> newItems) {
        FC_CaseHandler.BulkCaseHandler handler = new FC_CaseHandler.BulkCaseHandler();
        handler.handleRollupDisputedAmountOnAccounts((Map<Id,Case>)newItems, null);
    }
}