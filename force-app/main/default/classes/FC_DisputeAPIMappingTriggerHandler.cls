/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Dispute API Mapping trigger handler class.
 * Implements ITriggerHandler to allow dynamic run via TriggerDispatcher class
 *
 * @when 06/12/2019
 */
public class FC_DisputeAPIMappingTriggerHandler implements FC_ITriggerHandler {
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean isDisabled = false;

    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled(){
        Trigger_Settings__c triggerSettings = Trigger_Settings__c.getOrgDefaults();
        if (triggerSettings != null && triggerSettings.Disabled_DisputeAPIMapping__c)
            return true;
        else
                return isDisabled;
    }
    
    public void beforeInsert(List<SObject> newItems){
        FC_DisputeAPIMappingHandler.BulkDisputeAPIMappingHandler handler = new FC_DisputeAPIMappingHandler.BulkDisputeAPIMappingHandler();
        handler.handleFieldMetadata((List<Dispute_API_Mapping__c>)newItems, null);
    }

    public void beforeUpdate(Map<Id,SObject> newItems, Map<Id, SObject> oldItems) {
        FC_DisputeAPIMappingHandler.BulkDisputeAPIMappingHandler handler = new FC_DisputeAPIMappingHandler.BulkDisputeAPIMappingHandler();
        handler.handleFieldMetadata((List<Dispute_API_Mapping__c>)newItems.values(), (Map<Id,Dispute_API_Mapping__c>)oldItems);
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems){}

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> newItems) {}
}