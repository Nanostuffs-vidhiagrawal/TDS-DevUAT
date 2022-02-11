/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Error Log Event trigger handler class.
 *       Implements ITriggerHandler to allow dynamic run via TriggerDispatcher class
 *
 * @when 30/01/2020
 */
public with sharing class FC_ErrorLogEventTriggerHandler implements FC_ITriggerHandler {
    /* 
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled() {
        return false;
    }

    public void beforeInsert(List<SObject> newItems) {
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {
    }

    public void afterInsert(Map<Id, SObject> newItems) {
        FC_ErrorLogEventHandler.BulkHandler handler = new FC_ErrorLogEventHandler.BulkHandler();
        handler.dispatchErrorLogs(newItems.values());
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }

    public void afterDelete(Map<Id, SObject> oldItems) {
    }

    public void afterUndelete(Map<Id, SObject> newItems) {
    }
}