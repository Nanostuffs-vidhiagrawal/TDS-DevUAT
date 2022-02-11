/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Evidence Attachment trigger handler class.
 *       Implements ITriggerHandler to allow dynamic run via TriggerDispatcher class
 * @when 24/01/2020
 */
public with sharing class FC_EvidenceAttachmentTriggerHandler implements FC_ITriggerHandler{
    public static Boolean isDisabled = false;

    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled(){
        Trigger_Settings__c triggerSettings = Trigger_Settings__c.getOrgDefaults();
        if (triggerSettings != null && triggerSettings.Disabled_Evidence_Attachments__c)
            return true;
        else
            return isDisabled;
    }

    public void beforeInsert(List<sObject> newItems) {
        FC_EvidenceAttachmentHandler.BulkEvidenceAttachmentHandler handler = new FC_EvidenceAttachmentHandler.BulkEvidenceAttachmentHandler();
        handler.handleAzureDownloadLinks(newItems, null);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        FC_EvidenceAttachmentHandler.BulkEvidenceAttachmentHandler handler = new FC_EvidenceAttachmentHandler.BulkEvidenceAttachmentHandler();
        handler.handleAzureDownloadLinks(newItems.values(), (Map<Id,Evidence_Attachment__c>) oldItems);
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, sObject> newItems){
        FC_EvidenceAttachmentHandler.BulkEvidenceAttachmentHandler handler = new FC_EvidenceAttachmentHandler.BulkEvidenceAttachmentHandler();
        handler.handleEvidenceAttachmentBatchUpload(newItems.values(), null);
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        FC_EvidenceAttachmentHandler.BulkEvidenceAttachmentHandler handler = new FC_EvidenceAttachmentHandler.BulkEvidenceAttachmentHandler();
        handler.handleEvidenceAttachmentBatchUpload(newItems.values(), (Map<Id,Evidence_Attachment__c>) oldItems);
        handler.handleEvidenceAttachmentBatchUpload(newItems.values(), (Map<Id,Evidence_Attachment__c>) oldItems);
    }

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> newItems) {}
}