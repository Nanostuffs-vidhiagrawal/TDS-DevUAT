/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what REST method to be exposed on public site for Dispute API
 *
 * @when 26/02/2019
 */
@RestResource(urlMapping='/webhooktrigger/v1/dispute_status_update')
global without sharing class FC_DisputeAPI_StatusUpdate {
    private static String DISPUTE_ID_PARAM = 'tds_dispute_id';
    private static String STATUS_PARAM = 'status';
    /**
     * Exposed http POST method to post disputes. Utilizes version 1 of the interface
     */
    @HttpPost
    global static void postStatusUpdate() {
        RestResponse res = RestContext.response;
        res.addHeader(FC_Constant.HEADER_CONTENT_TYPE,FC_Constant.CONTENT_TYPE_APPLICATION_JSON);
        
        try {
            StatusUpdate_V1 instance = new StatusUpdate_V1(RestContext.request.headers, RestContext.request.requestBody.toString());
            FC_DisputeAPI_Base.Response response = instance.execute();
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
        }
        catch(FC_DisputeAPI_Exception exc) {
            res.responseBody = Blob.valueOf(JSON.serialize(new StatusUpdateResponse(exc.getMessage())));
            res.statusCode = exc.statusCode;
        }
    }
    
    private class StatusUpdate_V1 extends FC_DisputeAPI_Base {
        public StatusUpdate_V1(Map<String,String> headers, String requestBody) {
            this.headersMap = headers;
            this.payload = requestBody;
        }

        public override Response createSuccessResponse() {
            return new StatusUpdateResponse(true);
        }

        public override Response createErrorResponse(String error) {
            return new StatusUpdateResponse(error);
        }
        
        public override Response execute() {
            FC_ErrorLogger.start();
            List<Error_Log_Event__e> logs = new List<Error_Log_Event__e>();
            try {
                if(!FC_Utils.isRunningOnSandbox()) {
                    throw new FC_DisputeAPI_Exception.ForbiddenException('Forbidden');
                }
                this.headersMap = headerValidation();
                this.apiAccount = authenticate();
                Map<String,Object> deserializedPayload = validatePayload();
                
                Id disputeId = (Id)deserializedPayload.get(DISPUTE_ID_PARAM); 
                String status = (String)deserializedPayload.get(STATUS_PARAM);
                
                update new Case(Id = disputeId, Status = status);
                
                Response response = createSuccessResponse();
                logs.add(getSuccessLogEvent(response, disputeId));
                return response;
            }
            catch(FC_DisputeAPI_Exception disputeAPIException) {
                logs.add(getErrorLogEvent(disputeAPIException));
                throw disputeAPIException;
            }
            catch(Exception exc) {
                logs.add(getErrorLogEvent(exc));
                throw new FC_DisputeAPI_Exception.InternalException(FC_Constant.Internal_Error_Message);
            }
            finally {
                FC_ErrorLogger.publishLogs(logs);
                FC_ErrorLogger.stop();
            }
        }
        /**
         * Validates the payload
         *
         * @return
         */
        protected override Map<String, Object> validatePayload() {
            Map<String, Object> deserializedPayload;
            try {
                deserializedPayload = (Map<String, Object>) JSON.deserializeUntyped(payload);
            }
            catch(Exception exc) {
                throw new FC_DisputeAPI_Exception.JSONException('Could not deserialize payload');
            }
            
            if(!deserializedPayload.containsKey(STATUS_PARAM)) {
                throw new FC_DisputeAPI_Exception.MissingParamException('status not provided');
            }
            else {
                Boolean validStatus = false;
                for(PicklistEntry picklistEntry : Case.Status.getDescribe().getPicklistValues()) {
                    if(picklistEntry.getValue() == deserializedPayload.get(STATUS_PARAM)) {
                        validStatus = true;
                    }
                }
                if(!validStatus) {
                    throw new FC_DisputeAPI_Exception.InvalidStatusException('Invalid case status');
                }
            }
            
            if(!deserializedPayload.containsKey(DISPUTE_ID_PARAM)) {
                throw new FC_DisputeAPI_Exception.MissingParamException('tds_dispute_id not provided');
            }
            else {
                List<Case> dispute = [SELECT Id FROM Case WHERE Id = :(Id)deserializedPayload.get(DISPUTE_ID_PARAM) LIMIT 1];  
                if(dispute.size() == 0) {
                    throw new FC_DisputeAPI_Exception.CaseNotFoundException('Case not found');
                }
            }
            return deserializedPayload;
        }
    }
    /**
     * Response class
     */
    public class StatusUpdateResponse extends FC_DisputeAPI_Base.Response {
        public Boolean success;
        public String errors;

        public StatusUpdateResponse(Boolean success) {
            this.success = success;
        }
        
        public StatusUpdateResponse(String errors) {
            this.success = false;
            this.errors = errors;
        }
    }
}