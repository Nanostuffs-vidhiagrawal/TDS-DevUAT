/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what HttpCalloutMock interface implementation - returns mock responses for the unit test class  
 *
 * @when 19/11/2019
 */
@IsTest
public with sharing class FC_SpringCMCalloutMock {
    /**
     * Returns Mock success response for the Authentication request
     */
    public class AuthResponseSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(FC_Constant.HEADER_CONTENT_TYPE, FC_Constant.CONTENT_TYPE_APPLICATION_JSON);

            FC_SpringCMAuthenticator.AuthResponse successResponse = new FC_SpringCMAuthenticator.AuthResponse();
            successResponse.access_token = 'access_token';
            successResponse.api_base_url = 'https://authuat.springcm.com/api/v201606/apiuser';
            successResponse.expires_in = '3600';
            successResponse.token_type = 'bearer';

            res.setBody(JSON.serialize(successResponse));
            res.setStatusCode(200);
            return res;
        }
    }
    /**
     * Returns Mock error response for the Authentication request
     */
    public class AuthResponseErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(FC_Constant.HEADER_CONTENT_TYPE, FC_Constant.CONTENT_TYPE_APPLICATION_JSON);

            FC_SpringCMAuthenticator.AuthErrorResponse errorResponse = new FC_SpringCMAuthenticator.AuthErrorResponse();
            errorResponse.error = 'invalid_client';
            errorResponse.errorDescription = 'Invalid Client Id or Client Secret';

            res.setBody(JSON.serialize(errorResponse));
            res.setStatusCode(401);
            return res;
        }
    }
    /**
     * Returns Mock success response for the Document Download request
     */
    public class DocumentDownloadSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(FC_Constant.HEADER_CONTENT_TYPE, 'text/plain');
            res.setHeader('Content-Disposition', 'attachment; filename=test.txt');
            res.setBodyAsBlob(Blob.valueOf('testData'));
            res.setStatusCode(200);
            return res;
        }
    }
    /**
     * Returns Mock error response for the Document Download request
     */
    public class DocumentDownloadErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(FC_Constant.HEADER_CONTENT_TYPE, FC_Constant.CONTENT_TYPE_APPLICATION_JSON);

            FC_SpringCMDownloadDocument.DownloadDocumentErrorResponse errorResponse = new FC_SpringCMDownloadDocument.DownloadDocumentErrorResponse();
            errorResponse.error = new FC_SpringCMDownloadDocument.Error();
            errorResponse.error.DeveloperMessage = 'Could not authenticate';

            res.setBody(JSON.serialize(errorResponse));
            res.setStatusCode(401);
            return res;
        }
    }
    /**
     * Returns Mock success response for the ShareLinks request
     */
    public class ShareLinksSuccessMock implements HttpCalloutMock {
        private String getResponseBody() {
            return  '{"Url":"https://test.com","ExpirationDate":"2020-01-28T15:44:05.743Z","AllowNativeDownload":false,' +
                    '"AllowPdfDownload":true,"PreviewBehavior":"DownloadPdf","CreatedBy":"test@test.com",' +
                    '"UpdatedBy":"test@test.com","CreatedDate":"2020-01-27T11:41:55.213Z",' +
                    '"UpdatedDate":"2020-01-27T11:41:55.213Z",' +
                    '"Document":{"Href":"https://test.com"},"Href":"https://test.com"}';
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(FC_Constant.HEADER_CONTENT_TYPE, 'application/json');
            res.setBodyAsBlob(Blob.valueOf(getResponseBody()));
            res.setStatusCode(200);
            return res;
        }
    }
    /**
     * Returns Mock error response for the ShareLinks request
     */
    public class ShareLinksErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(FC_Constant.HEADER_CONTENT_TYPE, FC_Constant.CONTENT_TYPE_APPLICATION_JSON);

            FC_SpringCMShareLinks.ShareLinksErrorResponse errorResponse = new FC_SpringCMShareLinks.ShareLinksErrorResponse();
            errorResponse.error = new FC_SpringCMShareLinks.Error();
            errorResponse.error.DeveloperMessage = 'Could not authenticate';

            res.setBody(JSON.serialize(errorResponse));
            res.setStatusCode(401);
            return res;
        }
    }
}