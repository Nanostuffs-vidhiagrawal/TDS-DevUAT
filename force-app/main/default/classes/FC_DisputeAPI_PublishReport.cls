/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what REST method to be exposed on public site for Dispute API
 *
 * @when 04/03/2019
 */
@RestResource(urlMapping='/webhooktrigger/v1/publish_report')
global without sharing class FC_DisputeAPI_PublishReport {
    private static String DISPUTE_ID_PARAM = 'tds_dispute_id';
    /**
     * Exposed http POST method for testing the reports publishing
     */
    @HttpPost
    global static void postPublishReport() {
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

                runCreateAdjudicationRecordsFlow(disputeId);
                
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
            
            if(!deserializedPayload.containsKey(DISPUTE_ID_PARAM)) {
                throw new FC_DisputeAPI_Exception.MissingParamException('tds_dispute_id not provided');
            }
            else {
                Id caseId = (Id)deserializedPayload.get(DISPUTE_ID_PARAM);
                System.debug([select id from case].size());
                List<Case> dispute = [SELECT Id FROM Case WHERE Id = :caseId LIMIT 1];  
                if(dispute.size() == 0) {
                    throw new FC_DisputeAPI_Exception.CaseNotFoundException('Case not found');
                }
            }
            return deserializedPayload;
        }
    }
    /**
     * Runs the Create Adjudication Flow
     *
     * @param newCasesIds
     */
    private static void runCreateAdjudicationRecordsFlow(Id recordId) {
        try {
            Map<String, Object> params = new Map<String, Object>{
                    'recordId' => recordId,
                    'varDecisionType' => 'Adjudication',
                    'varDefaultParty' => ''
            };
            Flow.Interview.Flow_Create_Adjudication_Records crateAdjudicationRecordsFlow = new Flow.Interview.Flow_Create_Adjudication_Records(params);
            crateAdjudicationRecordsFlow.start();
            Id adjudicationReportId = (Id) crateAdjudicationRecordsFlow.getVariableValue('adjudicationReportId');
            update new Adjudication_Report__c(Id = adjudicationReportId, Status__c = FC_Constant.Adjudication_Report_Status_Published);
        }
        catch(FlowException flowException) {
            throw new FC_DisputeAPI_Exception.InternalException(FC_Constant.Internal_Error_Message);
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