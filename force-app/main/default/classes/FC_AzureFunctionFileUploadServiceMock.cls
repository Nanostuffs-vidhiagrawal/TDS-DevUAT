/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what HttpCalloutMock interface implementation - returns mock response for the unit test class  
 *
 * @when 23/01/2020
 */
@IsTest
public with sharing class FC_AzureFunctionFileUploadServiceMock {
    /**
     * Mocks the interface for Azure Upload Document service
     */
    public class UploadDocumentRequestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest httpRequest) {
            FC_AzureFunctionFileUploadService.UploadDocumentRequest requestBody;

            HttpResponse httpResponse = new HttpResponse();
            if(httpRequest.getHeader('x-functions-key') == null) {
                httpResponse.setStatusCode(401);
            }
            else if(httpRequest.getBody() == null) {
                httpResponse.setStatusCode(400);
                httpResponse.setBody('Invalid request');
            }
            else {
                try {
                    requestBody = (FC_AzureFunctionFileUploadService.UploadDocumentRequest)
                            JSON.deserialize(httpRequest.getBody(), FC_AzureFunctionFileUploadService.UploadDocumentRequest.class);

                    if(requestBody.fileName == null || requestBody.sourceContentURL == null || requestBody.extension == null || requestBody.parentId == null
                            || requestBody.accountName == null || requestBody.containerName == null || requestBody.sasToken == null) {
                        httpResponse.setStatusCode(400);
                        httpResponse.setBody('Invalid request');
                    }
                    else {
                        httpResponse.setHeader(FC_Constant.HEADER_CONTENT_TYPE, FC_Constant.CONTENT_TYPE_APPLICATION_JSON);
                        httpResponse.setBody('{ "resourceURL": "https://zerodepositsstorage.blob.core.windows.net/evidence/001_c8021c90-3c60-11ea-b996-cfbc06f6200b_evidence1.txt", "fileNameFull": "001_c8021c90-3c60-11ea-b996-cfbc06f6200b_evidence1.txt", "fileName": "evidence1", "extension": "txt", "parentId": "5008E00000GtLMu", "size": 2308798 }');
                        httpResponse.setStatusCode(200);
                    }
                }
                catch(Exception exc) {
                    httpResponse.setStatusCode(400);
                    httpResponse.setBody('Invalid request');
                }
            }

            return httpResponse;
        }
    }
    /**
     * Mock authorization exception since we are not allowing to call if the authorization header is not found in Salesforce
     */
    public class UploadDocumentRequestAuthorizationErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest httpRequest) {
            HttpResponse httpResponse = new HttpResponse();
            httpResponse.setStatusCode(401);
            return httpResponse;
        }
    }
}