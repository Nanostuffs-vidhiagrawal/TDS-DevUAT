/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Event publisherImpl for events that trigger webhook updates 
 * Base class is abstract - use on of the implementation subclasses
 *
 * @when 12/01/2020
 */
public abstract without sharing class FC_WebhookEventPublisher {
    private String webhookType;
    private Set<Id> apiAccountIds;
    private Map<Id,API_Account__c> apiAccountsWithWebhookSubscriptions;
    private List<SObject> sObjectsEligibleForWebhook;
    protected IEventPublisher publisherImpl;
    /**
     * Private constructor used by implementing subclasses.
     * Gathers the neccesary data and performs filtering by active subscriptions for API Accounts
     */
    private FC_WebhookEventPublisher(List<SObject> inputSObjects, String webhookType) {
        this.publisherImpl = (FC_WebhookEventPublisher.IEventPublisher)this;
        this.webhookType = webhookType;
        this.sObjectsEligibleForWebhook = inputSObjects;
        this.apiAccountIds = getApiAccountIds(inputSObjects);
        this.apiAccountsWithWebhookSubscriptions = getApiAccountsWithWebhookSubscriptions(apiAccountIds, webhookType);
    }
    /**
     * Creates the events and publishes the events to bus 
     */
    public void publishEvents() {
        if(sObjectsEligibleForWebhook.isEmpty()) {
            return;
        }
        List<SObject> eventsToPublish = createEventsToPublish(sObjectsEligibleForWebhook, apiAccountsWithWebhookSubscriptions);
        if(!eventsToPublish.isEmpty()) {
            EventBus.publish(eventsToPublish);
        }
    }
    /**
     * Get API accounts and their active subscriptions for specified webhook types
     *
     * @param apiAccountIds
     * @param webhookType
     *
     * @return
     */
    private static Map<Id,API_Account__c> getApiAccountsWithWebhookSubscriptions(Set<Id> apiAccountIds, String webhookType) {
        Map<Id,API_Account__c> apiAccountsWithWebhookSubscriptions = new Map<Id, API_Account__c>([
                SELECT Id, API_Account_Id__c,
                    (
                            SELECT Webhook_Endpoint__c, Shared_Key__c
                            FROM Webhook_Subscriptions__r
                            WHERE Webhook_Type__c = :webhookType AND isActive__c = true
                    )
                FROM API_Account__c
                WHERE Id IN :apiAccountIds
        ]);
        return apiAccountsWithWebhookSubscriptions;
    }
    /**
     * Get Webhook mappings
     *
     * @param webhookType
     *
     * @return
     */
    private List<Webhook_Mapping__c> getMappings(String webhookType) {
        return [
                SELECT Payload_Parameter_Name__c, Salesforce_Field_API_Name__c, SObject_Name__c
                FROM Webhook_Mapping__c
                WHERE isActive__c = true
                AND Webhook_Type__c = :webhookType
        ];
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
    private String getJSONObjectSnapshot(SObject sObjectWithData, List<Webhook_Mapping__c> mappings) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        Map<String,Object> sObjectSnapshotMap = new Map<String, Object> {
                'attributes' => new Map<String,Object>{'type' => sObjectWithData.getSObjectType().getDescribe().getName()},
                'id' => sObjectWithData.Id
        };
        if(webhookType == FC_Constant.ADJUDICATION_RESULTS_EVENT_WEBHOOK_TYPE) {
            sObjectSnapshotMap.put('Adjudication_Report_URL__c', sObjectWithData.get('Adjudication_Report_URL__c'));
        }
        
        for(Webhook_Mapping__c mapping : mappings) {
            if(sObjectWithData.getSObjectType().getDescribe().getName() != mapping.SObject_Name__c) {
                FC_ErrorLogger.error('The Webhook mapping SObject ' + mapping.SObject_Name__c + ' can not be used by webhook '+ webhookType, mapping.Id);
                continue;
            }
            sObjectSnapshotMap.put(mapping.Salesforce_Field_API_Name__c, sObjectWithData.get(mapping.Salesforce_Field_API_Name__c));
        }
        return JSON.serialize(sObjectSnapshotMap);
    }
    /**
     * Maps the data to  the event records to be published
     *
     * @param sObjects
     * @param apiAccountsWithSubscriptions
     *
     * @return
     */
    private List<SObject> createEventsToPublish(List<SObject> sObjects, Map<Id,API_Account__c> apiAccountsWithSubscriptions) {
        List<SObject> events = new List<SObject>();
        List<Webhook_Mapping__c> mappings = getMappings(webhookType);

        for(SObject sObj : sObjects) {
            API_Account__c apiAccount = apiAccountsWithSubscriptions.get(getApiAccountId(sObj));
            SObject event = publisherImpl.getPlatformEventType().newSObject();
            event.put('api_account_id__c',getApiAccountId(sObj));
            event.put('record_id__c',(String)sObj.get('Id'));
            if(apiAccount != null) {
                String eventJSON = getJSONObjectSnapshot(sObj, mappings);
                event.put('update_json__c', eventJSON);
            }
            events.add(event);
        }
        return events;
    }
    /**
     * Get API Account Id for current implementation
     *
     * @param sObj
     *
     * @return
     */
    public Id getApiAccountId(SObject sObj) {
        return (Id) sObj.get(publisherImpl.getApiAccountIdFieldName());
    }
    /**
     * Get API Account Ids related to current implementation object type
     *
     * @param sObjects
     *
     * @return
     */
    public Set<Id> getApiAccountIds(List<SObject> sObjects) {
        return FC_Utils.pluckIdFieldsSet(sObjects,publisherImpl.getApiAccountIdFieldName());
    }
    /**
     * Interface for Event publisher - allows to easily create another instance for other webhook types if needed
     */
    private interface IEventPublisher {
        String getApiAccountIdFieldName();
        SObjectType getPlatformEventType();
    }
    /**
     * IEventPublisher implementation - handles publishing of Case Status Update events
     */
    public class CaseUpdateEventPublisher extends FC_WebhookEventPublisher implements IEventPublisher {
        public CaseUpdateEventPublisher(List<Case> disputes) {
            super(disputes, FC_Constant.CASE_UPDATE_EVENT_WEBHOOK_TYPE);
        }

        public String getApiAccountIdFieldName() {
            return Case.API_Account__c.getDescribe().getName();
        }

        public SObjectType getPlatformEventType() {
            return Case_Status_Update_Event__e.SObjectType;
        }
    }
    /**
     * IEventPublisher implementation - handles publishing of Adjudication Results events
     */
    public class AdjudicationReportEventPublisher extends FC_WebhookEventPublisher implements IEventPublisher {
        public AdjudicationReportEventPublisher(List<Adjudication_Report__c> adjudicationReports) {
            super(adjudicationReports, FC_Constant.ADJUDICATION_RESULTS_EVENT_WEBHOOK_TYPE);
        }
        
        public String getApiAccountIdFieldName() {
            return Adjudication_Report__c.Dispute_API_Account_Id__c.getDescribe().getName();
        }

        public SObjectType getPlatformEventType() {
            return Adjudication_Report_Results_Event__e.SObjectType;
        }
    }
}