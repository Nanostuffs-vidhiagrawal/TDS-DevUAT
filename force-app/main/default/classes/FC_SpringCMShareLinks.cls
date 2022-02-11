/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Implementation of Spring CM Share Links service
 *
 * @when 27/01/2020
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class FC_SpringCMShareLinks extends FC_SpringCMCommon {
    public static String PREVIEW_BEHAVIOR_DOWNLOADPDF = 'DownloadPdf';
    /**
     * Constructor containing the request data
     */
    public FC_SpringCMShareLinks(String documentUrl, Id recordId) {
        super(
                new ShareLinksRequest(documentUrl),
                FC_Constant.HTTP_POST_METHOD,
                new Map<String,String>{FC_Constant.HEADER_CONTENT_TYPE => FC_Constant.CONTENT_TYPE_APPLICATION_JSON},
                FC_SpringCMAuthenticator.springCMAPIClientData.Sharelinks_Endpoint__c,
                true
        );
        this.setRecordId(recordId);
    }
    /**
     * SpringCM ShareLinks request
     */
    public class ShareLinksRequest implements ISpringCMRequest {
        public Datetime ExpirationDate;
        public Boolean AllowPdfDownload;
        public String PreviewBehavior;
        public ShareLinksDocument Document;

        public ShareLinksRequest(String documentUrl) {
            this.ExpirationDate = Date.today().addDays(1);
            this.AllowPdfDownload = true;
            this.PreviewBehavior = PREVIEW_BEHAVIOR_DOWNLOADPDF;
            this.Document = new ShareLinksDocument(documentUrl);
        }
    }
    /**
     * SpringCM Document
     */
    public class ShareLinksDocument {
        public String Href;

        public ShareLinksDocument(String documentUrl) {
            this.Href = documentUrl;
        }
    }
    /**
    * SpringCM ShareLinks response
    */
    public class ShareLinksResponse implements ISpringCMResponse {
        public String Url;
        public Datetime ExpirationDate;
        public String AllowNativeDownload;
        public String AllowPdfDownload;
        public String PreviewBehavior;
        public String CreatedBy;
        public String UpdatedBy;
        public Datetime CreatedDate;
        public Datetime UpdatedDate;
        public ShareLinksDocument Document;
        public String Href;
    }
    /**
    * SpringCM authentication error response
    */
    public class ShareLinksErrorResponse implements ISpringCMResponse{
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
        return (ISpringCMResponse) JSON.deserialize(response.getBody(), ShareLinksResponse.class);
    }
    /**
     * Processing of error response coming from the service
     *
     * @param response
     *
     * @return
     */
    protected override ISpringCMResponse processErrorResponse(HttpResponse response) {
        return (ISpringCMResponse) JSON.deserialize(response.getBody(), ShareLinksErrorResponse.class);
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
        ShareLinksErrorResponse errorResponse = (ShareLinksErrorResponse) springCMResponse;
        if(errorResponse.error != null && errorResponse.error.DeveloperMessage != null) {
            errorLog.Message__c = errorResponse.error.DeveloperMessage.left(131072);
        }
        else if(errorResponse.Message != null) {
            errorLog.Message__c = errorResponse.Message.left(131072);
        }
        return errorLog;
    }
}