/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Batch class - dispatcher 
 *
 * @when 23/01/2020
 */
public without sharing class FC_EvidenceUploadByLocationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    private List<Id> evidenceAttachmentIdsToProcess;
    private List<Evidence_Attachment__c> attachmentsToUpdate;

    public FC_EvidenceUploadByLocationBatch(List<Id> evidenceAttachmentIds) {
        this.evidenceAttachmentIdsToProcess = evidenceAttachmentIds;
        this.attachmentsToUpdate = new List<Evidence_Attachment__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String selectClause = 'SELECT Id, Deposit_Scheme__c, Filename__c, Supplier_Location__c, File_Type__c, Dispute__c';
        String fromClause = ' FROM Evidence_Attachment__c ';
        String whereClause = 'WHERE Id IN :evidenceAttachmentIdsToProcess';
        String query = selectClause + fromClause + whereClause;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Evidence_Attachment__c> scope) {
        FC_ErrorLogger.start();
        try {
            uploadAttachments(scope);
            if(this.attachmentsToUpdate.size() > 0) {
                updateAttachments(this.attachmentsToUpdate);
            }
        }catch(Exception exc) {
            FC_ErrorLogger.error(exc);
        }
        FC_ErrorLogger.stop();
    }


    /**
    * Calls the Azure uploading service (one callout per record)
    * @param evidenceAttachments
    */
    private void uploadAttachments(List<Evidence_Attachment__c> evidenceAttachments) {
        for(Evidence_Attachment__c evidenceAttachment : evidenceAttachments) {
            FC_AzureFunctionFileUploadService uploader = new FC_AzureFunctionFileUploadService(evidenceAttachment);
            HttpResponse res = uploader.uploadDocument();
            if(res != null) {
                processResponse(evidenceAttachment, res);
            }
        }
    }
    /**
     * updates evidenceAttachment records to indicate that these were successfully uploaded
     *
     * @param evidenceAttachments
     */
    private void processResponse(Evidence_Attachment__c evidenceAttachment, HttpResponse response) {
        Integer statusCode = response.getStatusCode();
        if(statusCode == 200) {
            evidenceAttachment = processSuccessResponse(response, evidenceAttachment);
            if(evidenceAttachment != null) {
                this.attachmentsToUpdate.add(evidenceAttachment);
            }
        }
        else if (statusCode == 401 || statusCode == 400) {
            processErrorResponse(response, evidenceAttachment);
        }
        else {
            FC_ErrorLogger.error('Unsupported response code received from server: ' + response.getStatusCode());
        }
    }
    /**
     * Updates Evidence evidenceAttachments and checks the results
     *
     * @param evidenceAttachments
     */
    private void updateAttachments(List<Evidence_Attachment__c> evidenceAttachments) {
        List<Database.SaveResult> results = Database.update(evidenceAttachments, false);
        processSaveResults(results, evidenceAttachments);
    }
    /**
     * processes save results and generates error logs if error occurred
     *
     * @param results
     * @param evidenceAttachments
     */
    private void processSaveResults(List<Database.SaveResult> results, List<Evidence_Attachment__c> evidenceAttachments) {
        for(Integer i=0;i<results.size(); i++) {
            Database.SaveResult result = results[i];
            if(!result.isSuccess()) {
                Evidence_Attachment__c originalRecord = evidenceAttachments[i];
                for(Database.Error err : result.getErrors()) {
                    FC_ErrorLogger.error(err.getMessage());
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
    }

    /**
     * Processing of success response coming from the service
     *
     * @param response
     *
     * @return
     */
    private Evidence_Attachment__c processSuccessResponse(HttpResponse response, Evidence_Attachment__c evidenceAttachment) {
        try {
            UploadDocumentSuccessResponse parsedResponse = (UploadDocumentSuccessResponse) JSON.deserialize(response.getBody(), UploadDocumentSuccessResponse.class);
            evidenceAttachment.Location__c = parsedResponse.resourceURL;
            evidenceAttachment.isUploaded__c = true;
            return evidenceAttachment;
        }catch(Exception exc) {
            FC_ErrorLogger.error(exc);
            return null;
        }
    }
    /**
     * Logs the errors into database for easy debugging
     *
     * @param exc
     */
    private void processErrorResponse(HttpResponse response, Evidence_Attachment__c evidenceAttachment) {
        FC_ErrorLogger.start('FC_EvidenceUploadByLocationBatch', 'processErrorResponse');
        FC_ErrorLogger.error(response, evidenceAttachment.Id);
        FC_ErrorLogger.stop();
    }
    /**
    * Azure Document Upload response
    */
    public class UploadDocumentSuccessResponse {
        public String resourceURL;
        public String fileNameFull;
        public String fileName;
        public String extension;
        public String parentId;
        public String size;
    }
}