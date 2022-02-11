/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Framework for processing the SpringCM outbound http requests
 *
 * @when 18/11/2019
 */
public abstract with sharing class FC_SpringCMCommon {
    private Id recordId;
    private String endpoint, method;
    private ISpringCMRequest springCMRequest;
    private Map<String,String> headersMap;
    private Boolean includeAuthHeader;
    /**
     * Constructor for the new requests
     *
     * @param springCMRequest Implementation of SpringCM request
     * @param method HTTP method
     * @param headersMap Map of headers to be attached to request
     * @param endpoint Endpoint
     * @param includeAuthHeader Indicates whether authorization header should be included in the request
     */
    protected FC_SpringCMCommon(ISpringCMRequest springCMRequest, String method, Map<String,String> headersMap, String endpoint, Boolean includeAuthHeader) {
        this.springCMRequest = springCMRequest;
        this.method = method;
        this.headersMap = headersMap;
        this.endpoint = endpoint;
        this.includeAuthHeader = includeAuthHeader;
    }
    /**
     * Interface for SpringCM requests
     */
    public interface ISpringCMRequest {}
    /**
     * Interface for SpringCM responses
     */
    public interface ISpringCMResponse {}
    /**
     * The method performs the actual callout to the desired Webservice
     *
     * @return Parsed SpringCM response
     */
    public ISpringCMResponse sendRequest() {
        FC_ErrorLogger.start();
        List<Error_Log_Event__e> logs = new List<Error_Log_Event__e>();
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(method);
            for(String headerName : headersMap.keySet()) {
                req.setHeader(headerName, headersMap.get(headerName));
            }
            if(includeAuthHeader) {
                req.setHeader(FC_Constant.HEADER_AUTHORIZATION, 'bearer ' + accessToken);
            }
            if(springCMRequest != null) {
                req.setBody(JSON.serialize(springCMRequest));
            }

            HTTPResponse httpResponse = new Http().send(req);
            ISpringCMResponse springCMResponse =  processSpringCMResponse(httpResponse, springCMRequest);
            if (httpResponse.getStatusCode() < 200 || httpResponse.getStatusCode() > 300 ) {
                logs.add(logErrorResponse(httpResponse, springCMResponse, springCMRequest));    
            }
            return springCMResponse;
            
        }
        catch(Exception exc) {
            logs.add(logException(exc, springCMRequest));
        }
        finally {
            FC_ErrorLogger.publishLogs(logs);
            FC_ErrorLogger.stop();
        }
        return null;
    }
    /**
     * Set record Id to be included in the Spring CM error log
     *
     * @param recordId
     */
    public void setRecordId(Id recordId) {
        this.recordId = recordId;
    }
    /**
     * Abstract method for processing success HTTPresponse coming from WS
     *
     * @param response HttpResponse to be processed
     *
     * @return ISpringCMResponse interface implementation
     */
    protected abstract ISpringCMResponse processSuccessResponse(HttpResponse response);
    /**
     * Abstract method for processing error HTTPresponse coming from WS
     *
     * @param response HttpResponse to be processed
     *
     * @return ISpringCMResponse interface implementation
     */
    protected abstract ISpringCMResponse processErrorResponse(HttpResponse response);
    /**
    * Abstract method parses the error response returned by the Webservice into Spring CM Error Log
    *
    * @param log
    * @param springCMresponse
    *
    * @return
    */
    protected abstract Error_Log_Event__e parseHttpErrorResponseToLog(Error_Log_Event__e log, ISpringCMResponse springCMresponse);
    /**
     * The method initially processes the Httpresponse to distinct whether the request was a success or an error
     *
     * @param httpResponse
     * @param springCMRequest
     *
     * @return
     */
    private ISpringCMResponse processSpringCMResponse(HttpResponse httpResponse, ISpringCMRequest springCMRequest) {
        if(200 <= httpResponse.getStatusCode() && httpResponse.getStatusCode() < 300) {
            return processSuccessResponse(httpResponse);
        }
        else if (httpResponse.getStatusCode() < 200 || httpResponse.getStatusCode() > 300 ) {
            return processErrorResponse(httpResponse);
        }
        return null;
    }
    /**
     * If apex exception happens - the method add the exception into the log
     *
     * @param exc
     * @param request
     */
    private Error_Log_Event__e logException(Exception exc, ISpringCMRequest request) {
        Error_Log_Event__e errorLog = logRequestData(request);
        errorLog.put('Message__c',exc.getMessage().left(131072));
        errorLog.put('StackTrace__c',exc.getStackTraceString().left(131072));
        errorLog.put('LineNumber__c',exc.getLineNumber());
        return errorLog;
    }
    /**
     * Logs the Httpresponse returned by the webservice
     *
     * @param httpResponse
     * @param springCMResponse
     * @param springCMrequest
     */
    private Error_Log_Event__e logErrorResponse(HttpResponse httpResponse, ISpringCMResponse springCMResponse, ISpringCMRequest springCMrequest) {
        Error_Log_Event__e errorLog = logRequestData(springCMrequest);
        errorLog.JSON_response__c = httpResponse.getBody();
        errorLog.HttpStatusCode__c = httpResponse.getStatusCode();
        errorLog = parseHttpErrorResponseToLog(errorLog, springCMresponse);
        return errorLog;
    }
    /**
     * Logs the Spring CM request into SpringCM error log
     *
     * @param springCMrequest
     *
     * @return
     */
    private Error_Log_Event__e logRequestData(ISpringCMRequest springCMrequest) {
        Error_Log_Event__e errorLog = new Error_Log_Event__e();
        errorLog.Log_Type__c = FC_Constant.LOG_TYPE_SPRINGCM;
        errorLog.Endpoint__c = endpoint;
        errorLog.JSON_request__c = JSON.serialize(springCMrequest);
        if(recordId != null) {
            errorLog.SObject_ID__c = recordId;
        }
        return errorLog;
    } 
    /**
     * The if accessToken has not been acquired yet by the class, it will perform the Authentication and store the 
     * access token for future requests
     */
    private static String accessToken {
        get {
            if(accessToken == null) {
                //for unit testing we don't want to actually call the service as it's already being tested in separate class
                if(Test.isRunningTest()) {
                    return 'access_token';
                }
                FC_SpringCMAuthenticator.AuthResponse authResponse = (FC_SpringCMAuthenticator.AuthResponse) new FC_SpringCMAuthenticator().sendRequest();
                if(authResponse != null) {
                    accessToken = authResponse.access_token;
                }
                else {
                    throw new SpringCMException('Could not authenticate');
                }
            }
            return accessToken;
        }
        set;
    }
    /**
     * Exception class for Spring CM
     */
    public class SpringCMException extends Exception {}
}