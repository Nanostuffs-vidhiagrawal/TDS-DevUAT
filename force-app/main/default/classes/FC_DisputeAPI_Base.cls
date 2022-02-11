/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Abstract class for processing new Disputes   
 *
 * @when 06/12/2019
 */
public abstract class FC_DisputeAPI_Base {
    protected Map<String,String> headersMap;
    protected String payload;
    protected String apiAccountId;
    protected API_Account__c apiAccount;
    protected List<Case> disputes;
    /**
     * Overridable Success response class
     */
    public abstract class Response {}
    protected abstract Response createSuccessResponse();
    protected abstract Response createErrorResponse(String error);
    /**
     * Executes the sequence of methods to sucessfully process the API request.
     * Throws any handled exception as FC_DisputeAPI_Exception, any internal error is thrown as InternalException
     *
     * @return Success Response
     */
    public virtual Response execute() {
        FC_ErrorLogger.start();
        List<Error_Log_Event__e> logs = new List<Error_Log_Event__e>();
        try {
            this.headersMap = headerValidation();
            this.apiAccount = authenticate();
            Map<String,Object> deserializedPayload = validatePayload();
            Map<String,Map<SObjectType,List<SObject>>> sObjectByPayloadObjectName = processMapping(deserializedPayload, apiAccount);
            this.disputes = performDML(sObjectByPayloadObjectName, apiAccount);
            Response successResponse = createSuccessResponse();
            logs.add(getSuccessLogEvent(successResponse, this.disputes[0].Id));
            return successResponse;
        }
        catch(FC_DisputeAPI_Exception disputeAPIException) {
            logs.add(getErrorLogEvent(disputeAPIException));
            throw disputeAPIException;
        }
        catch(Exception internalException) {
            logs.add(getErrorLogEvent(internalException));    
            throw new FC_DisputeAPI_Exception.InternalException(FC_Constant.Internal_Error_Message);
        }
        finally {
            FC_ErrorLogger.publishLogs(logs);
            FC_ErrorLogger.stop();
        }
    }
    /**
     * Overridable header validation method. Converts the header keys to lower case.
     *
     * @return Lower case headers
     */
    protected virtual Map<String,String> headerValidation() {
        FC_DisputeAPI_HeaderValidator headerValidator = new FC_DisputeAPI_HeaderValidator(headersMap);
        return headerValidator.validateHeader();
    }
    /**
     * Overridable authentication method
     *
     * @return API Account
     */
    protected virtual API_Account__c authenticate() {
        FC_DisputeAPI_Authenticator authenticator = new FC_DisputeAPI_Authenticator(headersMap.get('accessToken'.toLowerCase()));
        this.apiAccountId = authenticator.getApiAccountId();
        return authenticator.authenticate();
    }
    /**
     * Overridable payload validation method
     *
     * @return Deserialized payload
     */
    protected virtual Map<String, Object> validatePayload() {
        FC_DisputeAPI_PayloadValidator payloadValidator = new FC_DisputeAPI_PayloadValidator(payload);
        return payloadValidator.validate();
    }
    /**
     * Overridable mapping processing method
     *
     * @param deserializedPayload
     * @param apiAccount
     *
     * @return PayloadObject keys mapped to SObjects that should be upserted 
     */
    protected virtual Map<String,Map<SObjectType,List<SObject>>> processMapping(Map<String,Object> deserializedPayload, API_Account__c apiAccount) {
        FC_DisputeAPI_PayloadMapper payloadMapper = new FC_DisputeAPI_PayloadMapper(deserializedPayload, apiAccount);
        return payloadMapper.processDataMapping();
    }
    /**
     * Overridable perform DML method
     *
     * @param sObjectByPayloadObjectName
     * @param apiAccount
     *
     * @return List of successfully upserted Disputes 
     */
    protected virtual List<Case> performDML(Map<String,Map<SObjectType,List<SObject>>> sObjectByPayloadObjectName, API_Account__c apiAccount) {
        FC_DisputeAPI_DataManipulator dataManipulator = new FC_DisputeAPI_DataManipulator(sObjectByPayloadObjectName, apiAccount);
        return dataManipulator.performDML();
    }
    /**
     * Logs the successes into database for easy debugging
     *
     * @param response
     */
    protected virtual Error_Log_Event__e getSuccessLogEvent(Response response, Id sObjectId) {
        Error_Log_Event__e errorLog = new Error_Log_Event__e(
                API_Account__c = apiAccount != null ? apiAccount.Id : null,
                JSON_request__c = payload,
                JSON_response__c = JSON.serialize(response),
                HttpStatusCode__c = 201,
                SObject_ID__c = sObjectId,
                Log_Type__c = FC_Constant.LOG_TYPE_DISPUTEAPILOG
        );
        return errorLog;
    }
    /**
     * Logs the errors into database for easy debugging
     *
     * @param exc
     */
    protected virtual Error_Log_Event__e getErrorLogEvent(Exception exc) {
        Error_Log_Event__e errorLog = new Error_Log_Event__e(
                API_Account__c = apiAccount != null ? apiAccount.Id : null,
                JSON_request__c = payload,
                JSON_response__c = JSON.serialize(createErrorResponse(exc instanceOf FC_DisputeAPI_Exception ? exc.getMessage() : FC_Constant.Internal_Error_Message)),
                HttpStatusCode__c = exc instanceOf FC_DisputeAPI_Exception ? ((FC_DisputeAPI_Exception)exc).statusCode : 500,
                Log_Type__c = FC_Constant.LOG_TYPE_DISPUTEAPILOG
        );
        errorLog.StackTrace__c = exc.getStackTraceString().left(131072);
        errorLog.Message__c = exc.getMessage().left(131072);
        errorLog.LineNumber__c = exc.getLineNumber();
        return errorLog;
    }
}