/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Trigger handler imlementation for Webhook_Subscription__c object
 *
 * @when 13/01/2020
 */
public with sharing class FC_WebhookSubscriptionTriggerHandler implements FC_ITriggerHandler {
    // Allows unit tests (or other code) to disable this trigger for the transaction
    public static Boolean isDisabled = false;

    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled() {
        return isDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
        FC_WebhookSubscriptionHandler.BulkHandler handler = new FC_WebhookSubscriptionHandler.BulkHandler();
        handler.generateSharedKey(newItems);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems) {
        FC_WebhookSubscriptionHandler.BulkHandler handler = new FC_WebhookSubscriptionHandler.BulkHandler();
        handler.createRemoteSiteSettings(newItems.values());
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        FC_WebhookSubscriptionHandler.BulkHandler handler = new FC_WebhookSubscriptionHandler.BulkHandler();
        handler.createRemoteSiteSettings((List<Webhook_Subscription__c>) newItems.values());
    }

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> newItems) {}
}