/**
 * Created by tiagolopes on 2019-10-07.
 */

trigger CaseTrigger on Case(before insert, before update, after insert, after update, after delete, after undelete){
 // Adding flag for this trigger TJ 22/07/2021
  QueryLimits__c querylimit = QueryLimits__c.getValues('All Limits'); 
    if(querylimit.CheckOn__c){
    FC_TriggerDispatcher.run(new FC_CaseTriggerHandler());
    }
}