/**
 * Created by Hubert Jaskolski on 24.01.2020.
 */
trigger EvidenceAttachmentTrigger on Evidence_Attachment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    FC_TriggerDispatcher.run(new FC_EvidenceAttachmentTriggerHandler());
}