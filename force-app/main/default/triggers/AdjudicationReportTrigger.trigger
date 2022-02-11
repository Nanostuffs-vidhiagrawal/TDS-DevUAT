/**
 * Created by Hubert Jaskolski on 09.11.2019.
 */
trigger AdjudicationReportTrigger on Adjudication_Report__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    FC_TriggerDispatcher.run(new FC_AdjudicationReportTriggerHandler());
}