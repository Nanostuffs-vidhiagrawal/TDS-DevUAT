/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Implementation of Spring CM Content API download document method  
 *
 * @when 19/11/2019
 */
public with sharing class FC_SpringCMDownloadDocument extends FC_SpringCMCommon {
    /**
     * Constructor with documentUrl and recordsId
     *
     * @param documentUrl
     * @param recordId
     */
    public FC_SpringCMDownloadDocument(String documentUrl, Id recordId) {
        this(documentUrl,recordId,new Map<String,String>());
    }
    /**
     * Constructor with documentUrl and recordsId and headers
     *
     * @param documentUrl
     * @param recordId
     * @param headers
     */
    public FC_SpringCMDownloadDocument(String documentUrl, Id recordId, Map<String,String> headers) {
        super(
                null,
                FC_Constant.HTTP_GET_METHOD,
                headers,
                documentUrl,
                true
        );
        this.setRecordId(recordId);
    }
    /**
    * SpringCM Document Download response
    */
    public class DownloadDocumentResponse implements ISpringCMResponse {
        @AuraEnabled public String encodedDocumentBlob;
        @AuraEnabled public String fileName;
        @AuraEnabled public String contentType;
    }
    /**
    * SpringCM authentication error response
    */
    public class DownloadDocumentErrorResponse implements ISpringCMResponse{
        public Error error;
        public String Message;
    }
    /**
     * DownloadDocument error details
     */
    public class Error {
        public Integer HttpStatusCode;
        public String UserMessage;
        public String DeveloperMessage;
        public Integer ErrorCode;
        public String ReferenceId;
    }
    /**
     * Processing of success response coming from the service
     *
     * @param response
     *
     * @return
     */
    protected override ISpringCMResponse processSuccessResponse(HttpResponse response) {
        DownloadDocumentResponse springCMResponse = new DownloadDocumentResponse();
        springCMResponse.encodedDocumentBlob = EncodingUtil.base64Encode(response.getBodyAsBlob());
        String contentDisposition = response.getHeader('Content-Disposition');
        if(contentDisposition != null) {
            springCMResponse.fileName = contentDisposition.substringAfter('attachment; filename=');
        }
        springCMResponse.contentType = response.getHeader(FC_Constant.HEADER_CONTENT_TYPE);
        return springCMResponse;
    }
    /**
     * Processing of error response coming from the service
     *
     * @param response
     *
     * @return
     */
    protected override ISpringCMResponse processErrorResponse(HttpResponse response) {
        return (ISpringCMResponse) JSON.deserialize(response.getBody(), DownloadDocumentErrorResponse.class);
    }
    /**
     * Parsing the error response coming from the service into SpringCM Error Log object
     *
     * @param errorLog
     * @param springCMResponse
     *
     * @return
     */
    protected override Error_Log_Event__e parseHttpErrorResponseToLog(Error_Log_Event__e errorLog, ISpringCMResponse springCMResponse) {
        DownloadDocumentErrorResponse errorResponse = (DownloadDocumentErrorResponse) springCMResponse;
        if(errorResponse.error != null && errorResponse.error.DeveloperMessage != null) {
            errorLog.put('Message__c',errorResponse.error.DeveloperMessage.left(131072));
        }
        else if(errorResponse.Message != null) {
            errorLog.put('Message__c',errorResponse.Message.left(131072));
        }
        return errorLog;
    }
}