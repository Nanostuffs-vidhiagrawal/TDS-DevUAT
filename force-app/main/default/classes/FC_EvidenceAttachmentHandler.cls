/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Handler class model for Evidence Attachment
 *
 * @when 24/01/2020
 */
public with sharing class FC_EvidenceAttachmentHandler {
    public class BulkEvidenceAttachmentHandler {
        /**
         * Handles bulk Evidence Attachments coming from onAfterInsert OnAfterUpdate trigger event
         * Records that meet criteria are sent to batch in order to be uploaded
         * @param newList
         * @param oldMap
         */
        public void handleEvidenceAttachmentBatchUpload(List<Evidence_Attachment__c> newList, Map<Id, Evidence_Attachment__c> oldMap) {
            List<Id> evidenceAttachmentsToUpload = new List<Id>();
            for(Evidence_Attachment__c attachment : newList) {
                if(isEligibleToUpload(attachment)) {
                    evidenceAttachmentsToUpload.add(attachment.Id);
                }
            }

            if(evidenceAttachmentsToUpload.size() > 0) {
                FC_EvidenceUploadByLocationBatch batch = new FC_EvidenceUploadByLocationBatch(evidenceAttachmentsToUpload);
                Database.executeBatch(batch, 10);
            }
        }
        /**
         * Azure Storage file urls should be stored in Evidence_Attachment__c.Location__c field including a read-only Shared Access Signature.
         * The method appends the token signature.
         *
         * @param newList
         * @param oldMap
         */
        public void handleAzureDownloadLinks(List<Evidence_Attachment__c> newList, Map<Id, Evidence_Attachment__c> oldMap) {
            for(Evidence_Attachment__c newAttachment : newList) {
                Evidence_Attachment__c oldAttachment = oldMap != null ? oldMap.get(newAttachment.Id) : null;
                if(isLocationChanged(newAttachment, oldAttachment)) {
                    String sasToken = FC_AzureStorageService.createSASToken(newAttachment.Deposit_Scheme__c, true, 'r');
                    if(newAttachment.Location__c.contains('?')) {
                        newAttachment.Location__c = newAttachment.Location__c.substringBefore('?') + '?' + sasToken;
                    }
                    else {
                        newAttachment.Location__c = newAttachment.Location__c + '?' + sasToken; 
                    }
                }
            }
        }

        /**
        * Checks whether Evidence Attachment meets criteria to be uploaded
        *
        * @param attachment
        *
        * @return
        */
        private Boolean isEligibleToUpload(Evidence_Attachment__c attachment) {
            return attachment.Supplier_Location__c != null &&
                    attachment.Location__c == null &&
                    !attachment.IsUploaded__c;
        }
        
        private Boolean isLocationChanged(Evidence_Attachment__c newAttachment, Evidence_Attachment__c oldAttachment) {
            return (oldAttachment == null || oldAttachment.Location__c != newAttachment.Location__c) 
                    && newAttachment.Location__c != null;
        }
    }
}