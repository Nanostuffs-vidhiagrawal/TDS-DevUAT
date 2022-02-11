/**
 * @who   Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what  Service class - handles logic related to upload function
 * @when  23/01/2020
 */
public inherited sharing class FC_AzureFunctionFileUploadService {
    private final static String API_KEY_HEADER = 'x-functions-key';
    private Evidence_Attachment__c evidenceAttachment;
    /**
     * Constructor containing the request data
     */
    public FC_AzureFunctionFileUploadService(Evidence_Attachment__c evidenceAttachment) {
        this.evidenceAttachment = evidenceAttachment;
    }
    /**
     * Uploads document to Azure cloud storage
     *
     * @return
     */
    public HTTPResponse uploadDocument() {
        HTTPResponse res;
        try {
            AzureUploadFunctionCredentialsPerScheme__mdt settings = getSettings(evidenceAttachment);
            UploadDocumentRequest uploadDocumentRequest = new UploadDocumentRequest(evidenceAttachment, settings);

            HttpRequest req = new HttpRequest();
            req.setMethod(FC_Constant.HTTP_POST_METHOD);
            req.setEndpoint(FC_Utils.isRunningOnSandbox() ? settings.Endpoint_Sandbox__c : settings.Endpoint_Production__c);
            req.setHeader(API_KEY_HEADER, FC_Utils.isRunningOnSandbox() ? settings.API_Key_Sandbox__c : settings.API_Key_Production__c);
            req.setBody(JSON.serialize(uploadDocumentRequest));
            res = new Http().send(req);
        }
        catch(Exception exc) {
            FC_ErrorLogger.error(exc);
        }
        return res;
    }
    /**
     * Get Custom Metadata for the scheme related to evidence attachment
     *
     * @param evidenceAttachment
     *
     * @return
     */
    private AzureUploadFunctionCredentialsPerScheme__mdt getSettings(Evidence_Attachment__c evidenceAttachment) {
        AzureUploadFunctionCredentialsPerScheme__mdt settings;
        try {
            settings = [
                    SELECT API_Key_Production__c,
                            API_Key_Sandbox__c,
                            Endpoint_Production__c,
                            Endpoint_Sandbox__c,
                            Account_Name_Sandbox__c,
                            Account_Name_Production__c,
                            Container_Name_Sandbox__c,
                            Container_Name_Production__c
                    FROM AzureUploadFunctionCredentialsPerScheme__mdt
                    WHERE Label = :evidenceAttachment.Deposit_Scheme__c
            ];
        }
        catch(QueryException exc) {
            throw new AzureFunctionFileUploadServiceException('No Azure Upload Function Credentials found for scheme: ' + evidenceAttachment.Deposit_Scheme__c);
        }
        return settings;
    }
    /**
    * Azure Document Upload request
    */
    public class UploadDocumentRequest {
        public String fileName;
        public String sourceContentURL;
        public String extension;
        public String parentId;
        public String accountName;
        public String containerName;
        public String sasToken;

        public UploadDocumentRequest(Evidence_Attachment__c evidenceAttachment, AzureUploadFunctionCredentialsPerScheme__mdt settings) {
            this.fileName = evidenceAttachment.Filename__c;
            this.sourceContentURL = evidenceAttachment.Supplier_Location__c;
            this.extension = evidenceAttachment.File_Type__c;
            this.parentId = evidenceAttachment.Dispute__c;
            this.accountName = FC_Utils.isRunningOnSandbox() ? settings.Account_Name_Sandbox__c : settings.Account_Name_Production__c;
            this.containerName = FC_Utils.isRunningOnSandbox() ? settings.Container_Name_Sandbox__c : settings.Container_Name_Production__c;
            this.sasToken = FC_AzureStorageService.createSASToken(evidenceAttachment.Deposit_Scheme__c, true, 'w');
        }
    }

    public class AzureFunctionFileUploadServiceException extends Exception{}
}