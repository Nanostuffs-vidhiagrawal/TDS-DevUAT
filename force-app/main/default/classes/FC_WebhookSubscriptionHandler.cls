/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what 
 *
 * @when 13/01/2020
 */
public with sharing class FC_WebhookSubscriptionHandler {
    @TestVisible
    private static FC_MetadataService.RemoteSiteSetting testRemoteSiteSettings;
    
    // bulk handler sub class to handle filtering and dispatch
    public class BulkHandler {
        /**
         * Handles bulk subscriptions coming from before insert and before update trigger events
         * @param newSubscriptions
         */
        public void createRemoteSiteSettings(List<Webhook_Subscription__c> newSubscriptions) {
            for(Webhook_Subscription__c ws : newSubscriptions) {
                FC_WebhookSubscriptionHandler.createRemoteSiteSettings(ws.API_Account_Name__c, ws.Webhook_Type__c, ws.Webhook_Endpoint__c, ws.isActive__c);
            }
        }        
        
        public void generateSharedKey(List<Webhook_Subscription__c> newSubscriptions) {
            for(Webhook_Subscription__c ws : newSubscriptions) {
                ws.Shared_Key__c = FC_Utils.generateRandomString(255);
            }
        }
    }
    /**
     * Upserts Remote Site Setting for specified endpoint using Metadata API
     *
     * @param apiAccountName
     * @param webhookType
     * @param endpoint
     * @param isActive
     */
    @future(callout=true)
    public static void createRemoteSiteSettings(String apiAccountName, String webhookType, String endpoint, Boolean isActive) {
        FC_MetadataService.MetadataPort service = createService();
        FC_MetadataService.RemoteSiteSetting remoteSiteSettings = new FC_MetadataService.RemoteSiteSetting();
        remoteSiteSettings.fullName = ('WEBKOOK_' + webhookType + '_' + apiAccountName).replaceAll(' ','_');
        remoteSiteSettings.url = endpoint;
        remoteSiteSettings.description = remoteSiteSettings.fullName;
        remoteSiteSettings.isActive = isActive;
        remoteSiteSettings.disableProtocolSecurity = false;
        try {
            FC_MetadataService.UpsertResult[] results = service.upsertMetadata(new List<FC_MetadataService.Metadata>{remoteSiteSettings});
            //for tests we simply indicate that the upsert metadata service has been fired 
            if(Test.isRunningTest()) {
                testRemoteSiteSettings = remoteSiteSettings;
            }
        }
        catch(Exception e) {
            FC_ErrorLogger.error(e);
        }
    }
    /**
     * Creates the Metadata Port service that sends the metadata object through the API
     *
     * @return
     */
    private static FC_MetadataService.MetadataPort createService() {
        FC_MetadataService.MetadataPort service = new FC_MetadataService.MetadataPort();
        service.SessionHeader = new FC_MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }
}