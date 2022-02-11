/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Controller for Add Evidence action on the Dispute / Dispute Item
 *
 * @when 10/02/2020
 */
public without sharing class FC_EvidenceUploadController {
    public static final Decimal DEFAULT_LIMIT_IF_NO_SCHEME = 5;

    @AuraEnabled(cacheable=true)
    public static List<Dispute_Item__c> getDisputeItems(String recordId){
        return [SELECT Id, Type__c FROM Dispute_Item__c WHERE Dispute__c = :recordId];
    }

    @AuraEnabled
    public static void createEvidenceAttachments(List<EvidenceAttachmentWrapper> files){
        List<Evidence_Attachment__c> evidenceAttachmentsToCreate = new List<Evidence_Attachment__c>();
        for(EvidenceAttachmentWrapper fileWrapper : files) {
            Evidence_Attachment__c attachment = new Evidence_Attachment__c(
                    Filename__c = fileWrapper.file_name,
                    File_Type__c = fileWrapper.file_type,
                    File_Size__c = fileWrapper.file_size != null ? Decimal.valueOf(fileWrapper.file_size) : null,
                    User_Type__c = fileWrapper.user_type,
                    Dispute__c = fileWrapper.dispute_id,
                    Dispute_Item__c = fileWrapper.dispute_item_id,
                    Source__c = fileWrapper.source,
                    Location__c = fileWrapper.url,
                    isUploaded__c = true                    
            );
            evidenceAttachmentsToCreate.add(attachment);
        }
        try {
            insert evidenceAttachmentsToCreate;
        }
        catch(DmlException exc) {
            FC_ErrorLogger.error(exc, files[0].dispute_id);
            throw exc;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,LimitWrapper> getLimitsForScheme(String schemeName, String recordId){
        File_Upload_Limits_per_Scheme__mdt[] limits = [
                SELECT Id, DeveloperName, Agent__c, Tenant__c, Landlord__c 
                FROM File_Upload_Limits_per_Scheme__mdt 
                WHERE Label = :schemeName 
        ];
        List<AggregateResult> aggregateResults = [
                SELECT count(Id), User_Type__c
                FROM Evidence_Attachment__c
                WHERE (Dispute__c = :recordId AND Dispute_Item__c = null) OR Dispute_Item__c = :recordId
                GROUP BY User_Type__c
        ];
        Map<String,Decimal> evidenceCountByUserType = getEvidenceCountByUserTypeMap(aggregateResults);

        Decimal landlordLimit = limits.isEmpty() ? DEFAULT_LIMIT_IF_NO_SCHEME : limits[0].Landlord__c;
        Decimal agentLimit = limits.isEmpty() ? DEFAULT_LIMIT_IF_NO_SCHEME : limits[0].Agent__c;
        Decimal tenantLimit = limits.isEmpty() ? DEFAULT_LIMIT_IF_NO_SCHEME : limits[0].Tenant__c;

        Decimal landlordResult = evidenceCountByUserType.get(FC_Constant.Evidence_Attachment_User_Type_Landlord) == null ? 0 : evidenceCountByUserType.get(FC_Constant.Evidence_Attachment_User_Type_Landlord);
        Decimal agentResult = evidenceCountByUserType.get(FC_Constant.Evidence_Attachment_User_Type_Agent) == null ? 0 : evidenceCountByUserType.get(FC_Constant.Evidence_Attachment_User_Type_Agent);
        Decimal tenantResult = evidenceCountByUserType.get(FC_Constant.Evidence_Attachment_User_Type_Tenant) == null ? 0 : evidenceCountByUserType.get(FC_Constant.Evidence_Attachment_User_Type_Tenant);

        Map<String,LimitWrapper> limitsPerScheme = new Map<String, LimitWrapper>();
        limitsPerScheme.put(FC_Constant.Evidence_Attachment_User_Type_Landlord, new LimitWrapper(landlordLimit, landlordResult));
        limitsPerScheme.put(FC_Constant.Evidence_Attachment_User_Type_Agent, new LimitWrapper(agentLimit, agentResult));
        limitsPerScheme.put(FC_Constant.Evidence_Attachment_User_Type_Tenant, new LimitWrapper(tenantLimit, tenantResult));
        return limitsPerScheme;
    }

    @AuraEnabled(cacheable=true)
    public static String getSchemeName(String caseId){
        try {
            return [SELECT Deposit_Account_Number__r.Scheme__r.Name FROM Case WHERE Id = :caseId LIMIT 1].Deposit_Account_Number__r.Scheme__r.Name;
        }
        catch(QueryException exc) {
            FC_ErrorLogger.error(exc, caseId);
            throw exc;
        }
    }

    private static Map<String,Decimal> getEvidenceCountByUserTypeMap(List<AggregateResult> aggregateResults) {
        Map<String,Decimal> evidenceCountByUserType = new Map<String, Decimal>();
        for(AggregateResult ar : aggregateResults) {
            evidenceCountByUserType.put((String)ar.get('User_Type__c'), (Decimal) ar.get('expr0'));
        }
        return evidenceCountByUserType;
    }
    
    public class EvidenceAttachmentWrapper {
        @AuraEnabled public String file_name {get;set;}
        @AuraEnabled public String user_type {get;set;}
        @AuraEnabled public String dispute_id {get;set;}
        @AuraEnabled public String dispute_item_id {get;set;}
        @AuraEnabled public String file_type {get;set;}
        @AuraEnabled public String file_size {get;set;}
        @AuraEnabled public String source {get;set;}
        @AuraEnabled public String url {get;set;}
    }

    public class LimitWrapper {
        @AuraEnabled public Decimal userTypeLimit {get;set;}
        @AuraEnabled public Decimal userTypeResult {get;set;}

        public LimitWrapper(Decimal userTypeLimit, Decimal userTypeResult) {
            this.userTypeLimit = userTypeLimit;
            this.userTypeResult = userTypeResult;
        }
    }
}