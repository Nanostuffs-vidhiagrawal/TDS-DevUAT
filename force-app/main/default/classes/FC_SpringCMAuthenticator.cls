/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Implementation of Spring CM Authorization API   
 *
 * @when 19/11/2019
 */
public with sharing class FC_SpringCMAuthenticator extends FC_SpringCMCommon  {
    /**
     * Constructor containing the request data
     */
    public FC_SpringCMAuthenticator() {
        super(
                new AuthRequest(springCMAPIClientData.API_User_Client_Id__c, springCMAPIClientData.API_User_Client_Secret__c),
                FC_Constant.HTTP_POST_METHOD,
                new Map<String,String>{FC_Constant.HEADER_CONTENT_TYPE => FC_Constant.CONTENT_TYPE_APPLICATION_JSON},
                springCMAPIClientData.Auth_Endpoint__c,
                false
        );
    }
    /**
    * SpringCM authentication request
    */
    public class AuthRequest implements ISpringCMRequest {
        public String client_id;
        public String client_secret;
        
        private AuthRequest(String client_Id, String client_secret) {
            this.client_id = client_id;
            this.client_secret = client_secret;
        }
    }
    /**
     * SpringCM authentication success response
     */
    public class AuthResponse implements ISpringCMResponse {
        public String access_token;
        public String token_type;
        public String expires_in;
        public String api_base_url;
    }
    /**
    * SpringCM authentication error response
    */
    public class AuthErrorResponse implements ISpringCMResponse{
        public String error;
        public String errorDescription;
    }
    /**
     * Processing of authentication success response coming from the service
     *
     * @param response
     *
     * @return
     */
    protected override ISpringCMResponse processSuccessResponse(HttpResponse response) {
        return (ISpringCMResponse) JSON.deserialize(response.getBody(), AuthResponse.class);
    }
    /**
     * Processing of authentication error response coming from the service
     *
     * @param response
     *
     * @return
     */
    protected override ISpringCMResponse processErrorResponse(HttpResponse response) {
        return (ISpringCMResponse) JSON.deserialize(response.getBody(), AuthErrorResponse.class);
    }
    /**
     * Parsing the authentication error response coming from the service into SpringCM Error Log object
     *
     * @param errorLog
     * @param springCMResponse
     *
     * @return
     */
    protected override Error_Log_Event__e parseHttpErrorResponseToLog(Error_Log_Event__e errorLog, ISpringCMResponse springCMresponse) {
        AuthErrorResponse authErrorResponse = (AuthErrorResponse) springCMresponse;
        if(authErrorResponse.errorDescription != null) {
            errorLog.put('Message__c',authErrorResponse.errorDescription.left(32768));
        }
        return errorLog;
    }
    /**
     * Get Spring CM API user credentials
     */
    public static SpringCM_Settings__c springCMAPIClientData {
        get {
            if(springCMAPIClientData == null) {
                springCMAPIClientData = SpringCM_Settings__c.getInstance();                 
            }
            return springCMAPIClientData;
        }
        set;
    }
}