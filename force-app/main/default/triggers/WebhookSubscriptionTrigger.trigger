/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what 
 *
 * @when 13/01/2020
 */
trigger WebhookSubscriptionTrigger on Webhook_Subscription__c (before insert, after insert, after update) {
    FC_TriggerDispatcher.run(new FC_WebhookSubscriptionTriggerHandler());
}