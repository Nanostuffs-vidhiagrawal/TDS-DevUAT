/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Trigger for Dispute API Mapping object
 *
 * @when 06/12/2019
 */
trigger DisputeAPIMappingTrigger on Dispute_API_Mapping__c (before insert, before update) {
    FC_TriggerDispatcher.run(new FC_DisputeAPIMappingTriggerHandler());
}