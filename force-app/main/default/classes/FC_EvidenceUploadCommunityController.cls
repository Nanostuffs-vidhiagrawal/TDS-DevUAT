/**
 * @who  Michal Romanowski <michal.romanowski@weare4c.com>
 * @what Evidence Gathering Community Controller class
 * @when 31/01/2020
 */

@SuppressWarnings('PMD.ExcessivePublicCount')
public without sharing class FC_EvidenceUploadCommunityController {

    @AuraEnabled
    public static FC_AuthorizationResponseDataWrapper getCaseParticipant(FC_AuthorizationDataWrapper dataWrapper) {
        String standardizedPostalCode = '';
        if(dataWrapper.postCode != null){
            standardizedPostalCode = dataWrapper.postCode.replaceAll(' ', '');
        }
        List<Case_Participant__c> caseParticipants = [
                SELECT
                    Id,
                    Case__c,
                    Is_Lead__c,
                    Case__r.Status
                FROM
                    Case_Participant__c
                WHERE
                    Access_Code__c = :dataWrapper.accessCode AND
                    Account__r.PersonEmail = :dataWrapper.emailAddress AND
                    Case__r.Deposit_Account_Number__r.Property__r.Standardized_Postal_Code__c = : standardizedPostalCode AND
                    Case__r.Status != 'Closed'
        ];

        if (caseParticipants.size() == 1) {
            return new FC_AuthorizationResponseDataWrapper(caseParticipants.get(0));
        } else {
            return new FC_AuthorizationResponseDataWrapper();
        }
    }

    public virtual class FC_ResultDataWrapper {
        @AuraEnabled
        public Boolean isSuccess { get; set; }

        FC_ResultDataWrapper(){}

        FC_ResultDataWrapper(Boolean result){
            this.isSuccess = result;
        }
    }

    public class FC_AuthorizationDataWrapper {
        @AuraEnabled
        public String accessCode { get; set; }
        @AuraEnabled
        public String postCode { get; set; }
        @AuraEnabled
        public String emailAddress { get; set; }
    }

    public class FC_AuthorizationResponseDataWrapper extends FC_ResultDataWrapper {
        @AuraEnabled
        public Id caseId { get; set; }
        @AuraEnabled
        public Id caseParticipantId { get; set; }

        @AuraEnabled
        public Boolean isLead { get; set; }

        @AuraEnabled
        public Boolean editAllowed {get;set;}

        public FC_AuthorizationResponseDataWrapper(Case_Participant__c cp) {
            caseId = cp.Case__c;
            caseParticipantId = cp.Id;
            isLead = cp.Is_Lead__c;
            isSuccess = true;
            if(cp.Case__r.Status == 'Evidence Gathering - TT' ){
                editAllowed = true;
            }else{
                editAllowed = false;
            }
        }

        public FC_AuthorizationResponseDataWrapper() {
            caseId = null;
            isSuccess = false;
            editAllowed = false;
        }
    }

    @AuraEnabled
    public static Boolean isLeadTenant(FC_IsLeadTenantDataWrapper dataWrapper) {
        AggregateResult res = (AggregateResult) [
                SELECT
                    COUNT(Id) noOfLeadTenants
                FROM
                    Case_Participant__c
                WHERE
                    Case__c = :dataWrapper.caseId AND
                    Is_Lead__c = true
        ];

        if ((Integer) res.get('noOfLeadTenants') == 1) {
            return false;
        } else {
            try {
                Case_Participant__c cp = new Case_Participant__c(
                        Id = dataWrapper.caseParticipantId,
                        Is_Lead__c = true
                );

                update cp;
            } catch (DmlException dmlException) {
                FC_ErrorLogger.error(dmlException);
            }
            return true;
        }
    }

    public class FC_IsLeadTenantDataWrapper {
        @AuraEnabled
        public Id caseParticipantId { get; set; }

        @AuraEnabled
        public Id caseId { get; set; }
    }

    @AuraEnabled
    public static FC_GetContextResultDataWrapper getContext(FC_GetContextRequestDataWrapper dataWrapper) {
        Case c = [
                SELECT
                    Id,
                    Dispute_Reference__c,
                    Disputed_Amount__c,
                    Total_Deposit__c,
                    Tenant__r.Name,
                    Landlord__r.Name,
                    Branch__r.Name,
                    Agent_Contact__r.Name,
                    Evidence_Target_Date__c,
                (SELECT
                        Id,
                        Account__r.Name,
                        Account__r.PersonEmail,
                        Account__r.PersonHomePhone,
                        Account__r.PersonContactId
                    FROM
                        Case_Participants__r
                    WHERE
                        Type__c = 'Tenant'
                        //TODO: finalize this condition
                        AND Account__c != null
                        AND Account__r.IsPersonAccount = true
                ),
                (SELECT
                        Id,
                        Filename__c,
                        Location__c,
                        User_Type__c
                FROM
                        Evidence_Attachments__r
                WHERE
                        Dispute_Item__c = null
                )
                FROM
                    Case
                WHERE
                    Id = :dataWrapper.caseId
        ];

        List<Dispute_Item__c> disputeItems = [
                SELECT
                        Id,
                        Claimed_by_Landlord__c,
                        Landlord_Statement__c,
                        Tenant_Statement__c,
                        Type__c,
                        Dispute__c,
                        (SELECT
                                Id,
                                Filename__c,
                                Location__c,
                                User_Type__c
                        FROM
                                Evidence_Attachments__r
                        )
                FROM
                        Dispute_Item__c
                WHERE
                        Dispute__c = :dataWrapper.caseId
        ];

        return new FC_GetContextResultDataWrapper(c, disputeItems);
    }

    public class FC_GetContextRequestDataWrapper {
        @AuraEnabled
        public String caseId { get; set; }
    }

    public class FC_GetContextResultDataWrapper {
        @AuraEnabled
        public String claimReference;
        @AuraEnabled
        public String caseId;

        @AuraEnabled
        public Double totalClaimAmount;

        @AuraEnabled
        public Double guaranteeValue;

        @AuraEnabled
        public String leadTenant;

        @AuraEnabled
        public String landlord;

        @AuraEnabled
        public String agent;

        @AuraEnabled
        public String agentContact;

        @AuraEnabled
        public String evidenceGatheringTargetDate;

        @AuraEnabled
        public List<FC_TenantDataWrapper> tenantList;

        @AuraEnabled
        public List<FC_DisputeItemWrapper> claimItems;

        @AuraEnabled
        public List<Evidence_Attachment__c> attachments;

        public FC_GetContextResultDataWrapper(Case c, List<Dispute_Item__c> di) {
            this.caseId = c.Id;
            this.claimReference = c.Dispute_Reference__c;
            this.totalClaimAmount = c.Disputed_Amount__c;
            this.guaranteeValue = c.Total_Deposit__c;
            this.leadTenant = c.Tenant__r.Name;
            this.landlord = c.Landlord__r.Name;
            this.agent = c.Branch__r.Name;
            this.agentContact = c.Agent_Contact__r.Name;

            this.attachments = c.Evidence_Attachments__r;

            if(c.Evidence_Target_Date__c != null){
                this.evidenceGatheringTargetDate = c.Evidence_Target_Date__c.format('dd MMMM yyyy');
            }

            this.tenantList = new List<FC_TenantDataWrapper>();
            for(Case_Participant__c cp : c.Case_Participants__r){
                tenantList.add(new FC_TenantDataWrapper(cp));
            }
            this.claimItems = new List<FC_DisputeItemWrapper>();
            for(Dispute_Item__c disputeItem : di){
                this.claimItems.add(new FC_DisputeItemWrapper(disputeItem));
            }

        }

    }

    public class FC_TenantDataWrapper{
        @AuraEnabled
        public String name {get; set;}

        @AuraEnabled
        public String email {get; set;}

        @AuraEnabled
        public String phone {get; set;}

        @AuraEnabled
        public Id id {get; set;}

        @AuraEnabled
        public Id contactId {get;set;}

        public FC_TenantDataWrapper(){}

        FC_TenantDataWrapper(Case_Participant__c cp){
            this.name = cp.Account__r.Name;
            this.id = cp.Account__c;
            this.email = cp.Account__r.PersonEmail;
            this.phone = cp.Account__r.PersonHomePhone;
            this.contactId = cp.Account__r.PersonContactId;
        }

        public Account toAccountRecord() {
            return new Account(
                    Id = this.id,
                    PersonEmail = this.email,
                    PersonHomePhone = this.phone);
        }

        public Contact toContactRecord() {
            return new Contact(
                    Id = this.contactId,
                    Phone = this.phone,
                    Email = this.email

            );
        }
    }

    public class FC_DisputeItemWrapper {
        @AuraEnabled
        public String disputeItemType {get; set;}

        @AuraEnabled
        public String landlordStatement {get; set;}

        @AuraEnabled
        public String tenantStatement {get; set;}

        @AuraEnabled
        public Double claimedByLandlord {get; set;}

        @AuraEnabled
        public Id id {get; set;}

        @AuraEnabled
        public Id caseId {get; set;}

        @AuraEnabled
        public List<Evidence_Attachment__c> attachments;

        public FC_DisputeItemWrapper(){}

        FC_DisputeItemWrapper(Dispute_Item__c di){
            this.disputeItemType = di.Type__c;
            this.id = di.Id;
            this.caseId = di.Dispute__c;
            this.landlordStatement = di.Landlord_Statement__c;
            this.tenantStatement = di.Tenant_Statement__c;
            this.claimedByLandlord = di.Claimed_by_Landlord__c;

            this.attachments = di.Evidence_Attachments__r;

        }
    }

    public class FC_UpdateTenantResultDataWrapper extends FC_ResultDataWrapper {
        FC_UpdateTenantResultDataWrapper(Boolean result){
            super(result);
        }
    }

    @AuraEnabled
    public static FC_UpdateTenantResultDataWrapper updateTenantData(FC_TenantDataWrapper dataWrapper){
        Account acc = dataWrapper.toAccountRecord();
        Contact con = dataWrapper.toContactRecord();
        try{
            update acc;
            update con;
            return new FC_UpdateTenantResultDataWrapper(true);
        }catch (Exception e){
            FC_ErrorLogger.error(e, acc.Id);
            return new FC_UpdateTenantResultDataWrapper(false);
        }

    }

    @AuraEnabled
    public static void logError(Object error){
        FC_ErrorLogger.error(error);
    }

    @AuraEnabled
    public static FC_ResultDataWrapper updateTenantClaimStatement(FC_DisputeItemWrapper dataWrapper){
        Dispute_Item__c di = new Dispute_Item__c();
        di.id = dataWrapper.id;
        di.Tenant_Statement__c = dataWrapper.tenantStatement;
        update di;

        FC_ResultDataWrapper resultDataWrapper = new FC_ResultDataWrapper();
        resultDataWrapper.isSuccess = true;
        return resultDataWrapper;
    }

    @AuraEnabled(cacheable = true)
    public static Map<String,String> getEvidenceUploadBannerTexts(){
        Map<String,String> bannerTextsMap = new Map<String, String>();
        List<Evidence_Upload_Community_Banner_Text__mdt> bannerTexts = [SELECT Id, DeveloperName, Text__c FROM Evidence_Upload_Community_Banner_Text__mdt];
        for(Evidence_Upload_Community_Banner_Text__mdt bannerTextMtd : bannerTexts){
            bannerTextsMap.put(bannerTextMtd.DeveloperName, bannerTextMtd.Text__c);
        }
        return bannerTextsMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getEvidenceUploadCommunityLabels(){
        Map<String,String> labelsMap = new Map<String, String>();
        List<Evidence_Upload_Community_Label__mdt> labels = [SELECT DeveloperName, Text__c FROM Evidence_Upload_Community_Label__mdt];
        for(Evidence_Upload_Community_Label__mdt label: labels){
            labelsMap.put(label.DeveloperName, label.Text__c);
        }
        return labelsMap;
    }

    @AuraEnabled
    public static FC_ResultDataWrapper deleteEvidenceAttachment(Id attachmentId){
        FC_ResultDataWrapper resultDataWrapper = new FC_ResultDataWrapper();
        try{
            delete new Evidence_Attachment__c(Id = attachmentId);
            resultDataWrapper.isSuccess = true;
        }catch (DmlException dmlException){
            resultDataWrapper.isSuccess = false;
        }
        return resultDataWrapper;
    }
}