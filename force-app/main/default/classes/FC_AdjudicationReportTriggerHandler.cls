/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Adjudication Report trigger handler class.
 *       Implements ITriggerHandler to allow dynamic run via TriggerDispatcher class
 * @when 09/11/2019
 */
public with sharing class FC_AdjudicationReportTriggerHandler implements FC_ITriggerHandler{
    public static Boolean isDisabled = false;

    /*
        Checks to see if the trigger has been disabled either by custom setting or by running code
    */
    public Boolean IsDisabled(){
        Trigger_Settings__c triggerSettings = Trigger_Settings__c.getOrgDefaults();
        if (triggerSettings != null && triggerSettings.Disabled_Adjudication_Report__c)
            return true;
        else
            return isDisabled;
    }

    public void beforeInsert(List<SObject> newItems){
        FC_AdjudicationReportHandler.BulkCaseHandler handler = new FC_AdjudicationReportHandler.BulkCaseHandler();
      //  handler.handleAdjudicationReportPublishedStatus(newItems, null);
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        FC_AdjudicationReportHandler.BulkCaseHandler handler = new FC_AdjudicationReportHandler.BulkCaseHandler();
       // handler.handleAdjudicationReportURLFromMergeDoc(newItems.values(), (Map<Id,Adjudication_Report__c>)oldItems);
       // handler.handleAdjudicationReportPublishedStatus(newItems.values(), (Map<Id,Adjudication_Report__c>)oldItems);
        handler.handleAdjudicationReportWebhookEvents(newItems.values(), (Map<Id,Adjudication_Report__c>)oldItems);
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems){}

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> newItems) {}
}