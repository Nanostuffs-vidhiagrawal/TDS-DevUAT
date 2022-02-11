/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Error Log Event trigger handler class.
 *       Implements ITriggerHandler to allow dynamic run via TriggerDispatcher class
 *
 * @when 30/01/2020
 */
public with sharing class FC_ErrorLogEventHandler {
    // bulk handler sub class to handle filtering and dispatch
    public class BulkHandler {
        /**
         * Handles bulk Error Log Events coming from AfterInsert trigger event
         * @param newList
         * @param oldMap
         */
        public void dispatchErrorLogs(List<Error_Log_Event__e> logEvents) {
            List<SObject> logsToInsert = new List<SObject>();
            for(Error_Log_Event__e logEvent : logEvents) {
                SObject log;
                if(logEvent.Log_Type__c == FC_Constant.LOG_TYPE_SPRINGCM) {
                    log = mapLogEventFieldsToLog(logEvent, new SpringCM_Report_Error_Log__c());
                }    
                else if(logEvent.Log_Type__c == FC_Constant.LOG_TYPE_WEBHOOKLOG) {
                    log = mapLogEventFieldsToLog(logEvent, new Webhook_Log__c());
                }
                else if(logEvent.Log_Type__c == FC_Constant.LOG_TYPE_DISPUTEAPILOG) {
                    log = mapLogEventFieldsToLog(logEvent, new Dispute_API_Error_Log__c());
                }
                else {
                    log = mapLogEventFieldsToLog(logEvent, new Error_Log__c());
                }
                logsToInsert.add(log);
            }
            insert logsToInsert;
        }
    }
    
    private static SObject mapLogEventFieldsToLog(Error_Log_Event__e logEvent, SObject log) {
        for(String fieldName : logEvent.getPopulatedFieldsAsMap().keySet()) {
            if(hasCreatableSObjectField(fieldName,log)) {
                log.put(fieldName, logEvent.get(fieldName));
            }
        }
        return log;
    }

    private static Boolean hasCreatableSObjectField(String fieldName, SObject so){
        SObjectField fieldResult = getDescribeSObjectResults(so.getSobjectType()).fields.getMap().get(fieldName);
        return fieldResult != null && fieldResult.getDescribe().isCreateable();
    }
    
    private static Map<SObjectType,Schema.DescribeSObjectResult> describeSObjectResultMapResultMap = new Map<SObjectType,Schema.DescribeSObjectResult>();
    
    private static Schema.DescribeSObjectResult getDescribeSObjectResults(SObjectType sObjectType) {
        if(describeSObjectResultMapResultMap.get(sObjectType) == null) {
            describeSObjectResultMapResultMap.put(sObjectType, sObjectType.getDescribe());
        }
        return describeSObjectResultMapResultMap.get(sObjectType);
    }
}