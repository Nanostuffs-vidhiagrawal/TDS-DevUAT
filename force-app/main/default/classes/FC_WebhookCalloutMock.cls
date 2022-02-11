/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what HttpCalloutMock interface implementation - returns mock responses for the unit test class  
 *
 * @when 16/01/2020
 */
@IsTest
public with sharing class FC_WebhookCalloutMock {
    /**
     * Returns Mock success response for the Webhook request
     */
    public class WebhookSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            /**
             * redirect to Sharelinks mock to allow proper unit testing of webhooks which performs 2 callouts
             * 1. callout to SpringCM to get the public report URL
             * 2. callout to actual webhook
             */
            if(req.getEndpoint().endsWithIgnoreCase('sharelinks')) {
                return new FC_SpringCMCalloutMock.ShareLinksSuccessMock().respond(req);
            }
            HttpResponse res = new HttpResponse();
            res.setHeader(FC_Constant.HEADER_CONTENT_TYPE, FC_Constant.CONTENT_TYPE_APPLICATION_JSON);
            res.setStatusCode(200);
            return res;
        }
    }
    /**
     * Returns Mock error response for the Webhook request
     */
    public class WebhookErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(FC_Constant.HEADER_CONTENT_TYPE, FC_Constant.CONTENT_TYPE_APPLICATION_JSON);
            res.setStatusCode(401);
            return res;
        }
    }
}