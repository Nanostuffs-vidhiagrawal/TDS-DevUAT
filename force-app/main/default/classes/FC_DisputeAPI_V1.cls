/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what REST method to be exposed on public site for Dispute API
 *
 * @when 10/12/2019
 */
@RestResource(urlMapping='/v1/disputes')
global class FC_DisputeAPI_V1 {
    /**
     * Exposed http POST method to post disputes. Utilizes version 1 of the interface
     */
    @HttpPost
    global static void postDispute() {
        RestResponse res = RestContext.response;
        res.addHeader(FC_Constant.HEADER_CONTENT_TYPE,FC_Constant.CONTENT_TYPE_APPLICATION_JSON);
        
        try {
            DisputeAPI_V1 instance = new DisputeAPI_V1(RestContext.request.headers, RestContext.request.requestBody.toString());
            FC_DisputeAPI_Base.Response response = instance.execute();
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
        }
        catch(FC_DisputeAPI_Exception exc) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponse(exc.getMessage())));
            res.statusCode = exc.statusCode;
        }
    }
    /**
     * V1 Implementation of the interface. Uses all the defaults methods set in the FC_DisputeAPI_Base abstract class.
     * New versions can overrides methods of FC_DisputeAPI_Base to extend the functionality.
     */
    private class DisputeAPI_V1 extends FC_DisputeAPI_Base {
        public DisputeAPI_V1(Map<String,String> headers, String requestBody) {
            this.headersMap = headers;
            this.payload = requestBody;
        }

        public override Response createSuccessResponse() {
            return new SuccessResponse(this.disputes);  
        }

        public override Response createErrorResponse(String error) {
            return new ErrorResponse(error);
        }
    }
    /**
     * Success response class
     */
    public class SuccessResponse extends FC_DisputeAPI_Base.Response {
        public Boolean success;
        public Id tds_dispute_id;

        public SuccessResponse(List<Case> disputes) {
            this.success = true;
            this.tds_dispute_id = disputes[0].Id;
        }
    }
    /**
     * Error response class
     */
    public class ErrorResponse extends FC_DisputeAPI_Base.Response {
        public Boolean success;
        public String errors;

        public ErrorResponse(String errors) {
            this.success = false;
            this.errors = errors;
        }
    }
}