/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Authentication method for Dispute API (used by Zero Deposit and other partners)
 *
 * @when 05/12/2019
 */
public with sharing class FC_DisputeAPI_Authenticator {
    private String accessToken;
    private API_Account__c apiAccount;
    private String accountId;
    private String timestamp;
    private String inputHMAC;
    private String clientId;
    private String clientSecret;
    /**
     * Public constructor
     *
     * @param accessToken
     */
    public FC_DisputeAPI_Authenticator(String accessToken) {
        this.accessToken = accessToken;
        this.validateAndProcessToken(accessToken);
        this.apiAccount = this.getAPIAccountData(accountId);
    }
    /**
     * Authentication method. Throws AuthenticationException with proper error code
     * if any exception occurs, otherwise returns API_Account__c  
     *
     * @return API_Account__c data
     */
    public API_Account__c authenticate() {
        this.checkTimestamp(timestamp);
        this.matchToken(clientId, clientSecret, timestamp);
        return apiAccount;
    }
    /**
     * Allows parent class to gather AccountId provided to customer and save it in error log before performing actual authentication
     *
     * @return
     */
    public String getApiAccountId() {
        return accountId;
    }
    /**
     * Throws AuthenticationException if access token has incorrect structure
     *
     * @param accessToken
     */
    private void validateAndProcessToken(String accessToken) {
        List<String> tokenParts = accessToken.split('-');

        if(tokenParts.size() != 3) {
            throw new FC_DisputeAPI_Exception.AuthenticationException('Invalid access token format.');
        }
        this.accountId = tokenParts[0];
        this.timestamp = tokenParts[1];
        this.inputHMAC = tokenParts[2];
    }
    /**
     * Matches the token against HMAC code generated in agreed structure, throws AuthenticationException
     *
     * @param clientId
     * @param clientSecret
     * @param timestamp
     */
    private void matchToken(String clientId, String clientSecret, String timestamp){
        String generatedHMAC = generateHMACKey(clientId, clientSecret, timestamp);
        if(inputHMAC != generatedHMAC) {
            throw new FC_DisputeAPI_Exception.AuthorizationException('Invalid access token.');
        }
    }
    /**
     * Checks the input timestamp against the current timestamp, throws TimestampTooOldException for errors
     *
     * @param timestamp
     */
    private void checkTimestamp(String timestamp){
        Integer maxTimeWindowInMins = 5;
        Datetime dt;
        try{
            dt = Datetime.newInstance(Long.valueof(timestamp));
        }
        catch (Exception exc) {
            throw new FC_DisputeAPI_Exception.AuthorizationException('Timestamp invalid.');
        }

        Long msDiff = Datetime.now().getTime() - dt.getTime();
        Integer minsDiff = Integer.valueOf(msDiff / 1000 / 60);
        
        if(minsDiff >= maxTimeWindowInMins) {
            throw new FC_DisputeAPI_Exception.TimestampTooOldException('Timestamp is too old.');
        }
    }
    /**
     * Get API Account by id
     *
     * @param accountId
     *
     * @return API Account with data
     */
    private API_Account__c getAPIAccountData(String apiAccountId) {
        try {
            API_Account__c apiAccount = getAPIAccount(apiAccountId);
            this.clientId = apiAccount.Client_Id__c;
            this.clientSecret = apiAccount.Client_Secret__c;
            return apiAccount;
        }
        catch(QueryException exc) {
            throw new FC_DisputeAPI_Exception.AuthorizationException('AccountID not authorized.');
        }
    }
    /**
     * Get API Account by API Account Id
     *
     * @param apiAccountId
     */
    @TestVisible
    private static API_Account__c getAPIAccount(String apiAccountId) {
        return [
                SELECT Id, Client_Id__c, Client_Secret__c, Dispute_Record_Type__c, API_Account_Id__c, Deposit_Scheme_Name__c, Data_Owner_User__c, DML_Strategy_Processor__c
                FROM API_Account__c
                WHERE API_Account_Id__c = :apiAccountId
        ];
    }

    /**
     * HMAC Generator method
     *
     * @param clientId
     * @param clientSecret
     * @param timestamp
     *
     * @return AccessToken to be compared against incoming data
     */
    @TestVisible
    private static String generateHMACKey(String clientId, String clientSecret, String timestamp){
        return FC_Utils.generateHMACKey(FC_Constant.HMAC_SHA1_MAC_ENCRYPTION, getCredentialsString(clientId,clientSecret,timestamp), clientSecret);
    }
    /**
     * Generates credentials string in an agreed form
     *
     * @param client_id
     * @param client_secret
     * @param timestamp
     *
     * @return Credentials string 
     */
    private static String getCredentialsString(String client_id, String client_secret, String timestamp) {
        return 'client_id=' + client_id +
                '&' + 'client_secret=' + client_secret +
                '&' + 'timestamp=' + timestamp;
    }
}