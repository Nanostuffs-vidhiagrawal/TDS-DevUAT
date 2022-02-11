/**
 * @who   Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what  Handler class for Webhook Events
 * @when  14/01/2020
 */
public without sharing class FC_WebhookEventHandler {
    private static final String HEADER_TDS_DELIVERY = 'TDS-Delivery';
    private static final String HEADER_TDS_SIGNATURE = 'TDS-Signature';
    /**
     * Event structure to be mapped through process builder
     */
    public class EventStructure {
        @InvocableVariable public String updateJson;
        @InvocableVariable public String apiAccountId;
        @InvocableVariable public String recordId;
    }
    
    private class WebhookProcessingResult {
        public Error_Log_Event__e log;
        public SObject sObjectToUpdate;
        
        public WebhookProcessingResult(Error_Log_Event__e log, SObject sObjectToUpdate) {
            this.log = log;
            this.sObjectToUpdate = sObjectToUpdate;
        }
    }
    /**
     * Handle Case Status Update platform events
     *
     * @param webhookEventObjects
     */
    @InvocableMethod(label='Callout to Webhook endpoint')
    public static void handleWebhookEvents(List<EventStructure> eventsList) {
        FC_ErrorLogger.start();
        List<Error_Log_Event__e> logEvents = new List<Error_Log_Event__e>();
        
        Set<Id> apiAccountIds = new Set<Id>();
        for(EventStructure event : eventsList) {
            apiAccountIds.add(event.apiAccountId);
        }

        Map<Id,API_Account__c> apiAccountsWithActiveSubscriptions = getApiAccountsWithWebhookSubscriptions(apiAccountIds);
        List<SObject> sObjectsToUpdate = new List<SObject>();

        Map<String, List<Webhook_Mapping__c>> mappingsByType = getMappings();

        for(EventStructure event : eventsList) {
            API_Account__c apiAccount = apiAccountsWithActiveSubscriptions.get(event.apiAccountId);
            for (Webhook_Subscription__c webhookSubscription : apiAccount.Webhook_Subscriptions__r) {
                WebhookProcessingResult result = processSingleSubscription(webhookSubscription, event, mappingsByType, apiAccount);
                if(result != null && result.log != null) {
                    logEvents.add(result.log);
                }
                if(result != null && result.sObjectToUpdate != null) {
                    sObjectsToUpdate.add(result.sObjectToUpdate);
                }
            }
        }
        
        if(sObjectsToUpdate.size() > 0) {
            try {
                update sObjectsToUpdate;
            }
            catch(Exception exc) {
                FC_ErrorLogger.error(exc);
            }
        }
        FC_ErrorLogger.publishLogs(logEvents);
        FC_ErrorLogger.stop();
    }
    /**
     * Single Webhook Subscription processing
     *
     * @param webhookSubscription
     * @param event
     * @param mappingsByType
     * @param apiAccount
     *
     * @return
     */
    private static WebhookProcessingResult processSingleSubscription(Webhook_Subscription__c webhookSubscription, EventStructure event, Map<String, List<Webhook_Mapping__c>> mappingsByType, API_Account__c apiAccount) {
        String webhookType = getWebhookType(event.recordId);
        if(webhookType == webhookSubscription.Webhook_Type__c) {
            try {
                List<Webhook_Mapping__c> mappings = mappingsByType.get(webhookType) != null ? mappingsByType.get(webhookType) : new List<Webhook_Mapping__c>();
                SObject sObjectSnapshot = (SObject)JSON.deserialize(event.updateJson,SObject.class);
                String webhookUpdateJSON = getJSONDataForWebhook(sObjectSnapshot,mappings,apiAccount.API_Account_Id__c);
                Error_Log_Event__e log = calloutToWebhook(event.recordId, webhookUpdateJSON, webhookSubscription, apiAccount);
                return new WebhookProcessingResult(log,sObjectSnapshot);
            }
            catch(Exception exc) {
                FC_ErrorLogger.error(exc, event.recordId);
            }
        }
        return null;
    }
    /**
     * Get webhookType for event Record Id
     *
     * @param recordId
     *
     * @return
     */
    private static String getWebhookType(Id recordId) {
        if(recordId.getSobjectType() == Case.SObjectType) {
            return FC_Constant.CASE_UPDATE_EVENT_WEBHOOK_TYPE;
        }
        else if(recordId.getSobjectType() == Adjudication_Report__c.SObjectType) {
            return FC_Constant.ADJUDICATION_RESULTS_EVENT_WEBHOOK_TYPE;
        }
        return null;
    }
    /**
     * Performs the callout to webhook endpoint
     *
     * @param event
     * @param subscription
     *
     * @return
     */
    private static Error_Log_Event__e calloutToWebhook(String recordId, String jsonBody, Webhook_Subscription__c subscription, API_Account__c apiAccount) {
        HttpRequest httpRequest = new HttpRequest();
        HTTPResponse httpResponse;
        Exception exceptionCaught;
        try {
            httpRequest.setEndpoint(subscription.Webhook_Endpoint__c);
            httpRequest.setBody(jsonBody);
            httpRequest.setMethod(FC_Constant.HTTP_POST_METHOD);
            httpRequest.setHeader(FC_Constant.HEADER_CONTENT_TYPE, FC_Constant.CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_TDS_DELIVERY, recordId + Datetime.now().getTime());
            httpRequest.setHeader(HEADER_TDS_SIGNATURE, FC_Utils.generateHMACKey(
                    FC_Constant.HMAC_SHA1_MAC_ENCRYPTION, jsonBody,
                    subscription.Shared_Key__c)
            );
            httpResponse = new Http().send(httpRequest);
        }
        catch(Exception exc) {
            exceptionCaught = exc;
        }
        finally {
            return logWebhookCall(httpRequest,httpResponse,exceptionCaught,apiAccount.Id,recordId,subscription.Id);
        }
        return null;
    }
    /**
     * Get API accounts and their active subscriptions 
     *
     * @param apiAccountIds
     *
     * @return
     */
    private static Map<Id,API_Account__c> getApiAccountsWithWebhookSubscriptions(Set<Id> apiAccountIds) {
        Map<Id,API_Account__c> apiAccountsWithWebhookSubscriptions = new Map<Id, API_Account__c>([
                SELECT Id, API_Account_Id__c,
                (
                        SELECT Webhook_Endpoint__c, Shared_Key__c, Webhook_Type__c
                        FROM Webhook_Subscriptions__r
                        WHERE isActive__c = true
                )
                FROM API_Account__c
                WHERE Id IN :apiAccountIds
        ]);
        return apiAccountsWithWebhookSubscriptions;
    }
    /**
     * Log Request data and any exception that could occur
     *
     * @param httpRequest
     * @param httpResponse
     * @param exc
     * @param apiAccountId
     * @param recordId
     * @param webhookSubscriptionId
     *
     * @return
     */
    @SuppressWarnings('PMD')
    private static Error_Log_Event__e logWebhookCall(HttpRequest httpRequest, HTTPResponse httpResponse, Exception exc, String apiAccountId, String recordId, String webhookSubscriptionId) {
        Error_Log_Event__e log = new Error_Log_Event__e(
                Log_Type__c = FC_Constant.LOG_TYPE_WEBHOOKLOG,
                SObject_ID__c = recordId,
                API_Account__c = apiAccountId,
                JSON_request__c = httpRequest.getBody(),
                Endpoint__c = httpRequest.getEndpoint(),
                Delivery_Id__c = httpRequest.getHeader(HEADER_TDS_DELIVERY)
        );
        if(exc != null) {
            log = processException(log,exc);    
        }
        else {
            log = processHttpResponse(log,httpResponse);
        }
        return log;
    }
    /**
     * Enrich log with response data
     *
     * @param log
     * @param httpResponse
     *
     * @return
     */
    private static Error_Log_Event__e processHttpResponse(Error_Log_Event__e log, HTTPResponse httpResponse) {
        log.JSON_response__c = httpResponse.getBody();
        log.HttpStatusCode__c = httpResponse.getStatusCode();
        return log;
    }
    /**
     * Enrich log with exception data
     *
     * @param log
     * @param exc
     *
     * @return
     */
    private static Error_Log_Event__e processException(Error_Log_Event__e log, Exception exc) {
        log.put('Message__c',exc.getMessage().left(131072));
        log.put('StackTrace__c',exc.getStackTraceString().left(131072));
        log.put('LineNumber__c',exc.getLineNumber());
        return log;
    }
    /**
     * Processes the sObject by mappings and returns a result as JSON
     *
     * @param sObjectWithData
     * @param mappings
     * @param apiAccount
     *
     * @return
     */
    private static String getJSONDataForWebhook(SObject sObjectWithData, List<Webhook_Mapping__c> mappings, String apiAccountId) {
        JSONGenerator jsonGenerator = JSON.createGenerator(true);
        jsonGenerator.writeStartObject();
        for(Webhook_Mapping__c mapping : mappings) {
            if(sObjectWithData.getSObjectType().getDescribe().getName() != mapping.SObject_Name__c) {
                //error should be put into log already in the preprocessing in publisher
                continue;
            }
            Object value = sObjectWithData.get(mapping.Salesforce_Field_API_Name__c);

            //remove api Account prefix for external id fields
            if(value instanceof String && String.valueOf(value).startsWith(apiAccountId)) {
                value = String.valueOf(value).removeStart(apiAccountId + '-');
            }

            if(value != null) {
                if(value instanceof Datetime) {
                    Datetime dt = (Datetime) value;
                    jsonGenerator.writeStringField(mapping.Payload_Parameter_Name__c, dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
                }
                else {
                    jsonGenerator.writeObjectField(mapping.Payload_Parameter_Name__c, value);
                }
            }
            else {
                jsonGenerator.writeNullField(mapping.Payload_Parameter_Name__c);
            }
        }
        //????
        jsonGenerator.writeObjectField('hash', '');
        jsonGenerator.writeEndObject();
        return jsonGenerator.getAsString();
    }

    public static Map<String,List<Webhook_Mapping__c>> getMappings() {
        Map<String,List<Webhook_Mapping__c>> webhookMappingsByType = new Map<String, List<Webhook_Mapping__c>>();
        List<Webhook_Mapping__c> mappings = [
                SELECT Payload_Parameter_Name__c, Salesforce_Field_API_Name__c, SObject_Name__c, Webhook_Type__c
                FROM Webhook_Mapping__c
                WHERE isActive__c = true
        ];

        for(Webhook_Mapping__c mapping : mappings) {
            List<Webhook_Mapping__c> mappingsForType = webhookMappingsByType.get(mapping.Webhook_Type__c) != null
                    ? webhookMappingsByType.get(mapping.Webhook_Type__c) : new List<Webhook_Mapping__c>();
            mappingsForType.add(mapping);
            webhookMappingsByType.put(mapping.Webhook_Type__c,mappingsForType);
        }
        return webhookMappingsByType;
    }
}