/**
 * @who  Mark Lotz <mark.lotz@weare4c.com> / Tiago Lopes <tiago.lopes@weare4c.com>
 * @what Handler for Azure Blob Storage authorisation and credentials management
 * @when 27/1/2020
 */
public inherited sharing class FC_AzureStorageService {
    // values for sas generation, these should be stable so being kept as part of class for the moment
    private final static String UTF = 'UTF-8';
    private final static String NEW_LINE = '\n';
    private final static String HMAC_ALGO = 'hmacSHA256';
    private final static String SERVICE_VERSION = '2019-02-02';
    private final static String SIGNED_SERVICES = 'b'; //blobs
    private final static String SIGNED_RESOURCE_TYPES = 'o'; //objects
    private final static String DATE_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss';
    private final static String PROTOCOL = 'https';
    /* allowed operations are only read, create, or both */
    private final static Set<String> permissions = new Set<String>{'c','r','cr','rc','w'};
    private static Azure_Storage_Credentials_per_Scheme__mdt credentials;

    /**
     * Creates resource URL to use for file upload. Contains the host endpoint and url-like token with parameters including signature
     *
     * @param schemeName
     * @param isInternal
     * @param operation
     *
     * @return String with url
     */
    @AuraEnabled
    public static String createAccessUrl(String schemeName, Boolean isInternal, String operation) {
        String url;
        try {
            if (getCredentialsForScheme(schemeName) != null) {
                // validate operation requested
                if (operationIsValid(operation)) {
                    String sasToken = createSASToken(schemeName, isInternal, operation);
                    String endpoint = FC_Utils.isRunningOnSandbox() ? credentials.Endpoint_Sandbox__c : credentials.Endpoint_Production__c;
                    // concat URL with sas token
                    url = endpoint + '?' + sasToken;
                }
            }
        }
        catch(CredentialsForSchemeNotFoundException ce){
            FC_ErrorLogger.error(ce);
            throw ce;
        }
        catch(OperationNotAllowedException oe){
            FC_ErrorLogger.error(oe);
            throw oe;
        }
        catch(Exception e){
            FC_ErrorLogger.error(e);
            throw e;
        }

        return url;
    }

    /**
     * Generates url like token including shared access signature.
     * Can be called outside of createAccessUrl method to generate url token to append to resource links.
     *
     * @param schemeName
     * @param operation
     *
     * @return String with sas token
     */
    public static String createSASToken(String schemeName, Boolean isInternal, String operation){
        String sasToken;
        if (getCredentialsForScheme(schemeName) != null) {
            String start = convertToUtc(Datetime.now());
            String expire = convertToUtc(getExpiryDatetimeForPermission(operation));
            String signature = getSignature(operation, start, expire);
            sasToken =
                    'sv=' + SERVICE_VERSION +
                            '&ss=' + SIGNED_SERVICES +
                            '&srt=' + SIGNED_RESOURCE_TYPES +
                            '&sp=' + operation +
                            '&st=' + start +
                            '&se=' + expire +
                            '&spr=' + PROTOCOL +
                            '&sig=' + urlEncode(signature);
        }
        return sasToken;
    }

    /**** helpers ****/

    /**
     * Generates shared access signature to be used in token
     *
     * @param operation
     * @param start
     * @param expire
     *
     * @return String with signature
     */
    private static String getSignature(string operation, String start, String expire){
        String signature;
        String accountName = FC_Utils.isRunningOnSandbox() ? credentials.Account_Name_Sandbox__c : credentials.Account_Name_Production__c;
        String storageKey = FC_Utils.isRunningOnSandbox() ? credentials.Storage_Key_Sandbox__c : credentials.Storage_Key_Production__c;
        Blob stringBlobToSign = Blob.valueOf(
                accountName + NEW_LINE +
                        operation + NEW_LINE +
                        SIGNED_SERVICES + NEW_LINE +
                        SIGNED_RESOURCE_TYPES + NEW_LINE +
                        start + NEW_LINE +
                        expire + NEW_LINE +
                        NEW_LINE + //i know...
                        PROTOCOL + NEW_LINE +
                        SERVICE_VERSION + NEW_LINE
        );

        signature = EncodingUtil.base64Encode(
                Crypto.generateMac(HMAC_ALGO, stringBlobToSign, EncodingUtil.base64Decode(storageKey))
        );
        return signature;
    }

    /**
     * Retrieves Azure Storage credentials info stored in back end
     *
     * @param SchemeName
     *
     * @return Azure_Storage_Credentials_per_Scheme__mdt with credentials
     */
    private static Azure_Storage_Credentials_per_Scheme__mdt getCredentialsForScheme(String SchemeName){
        if(credentials == null) {
            try{
                credentials = [
                        SELECT
                                Endpoint_Production__c,
                                Endpoint_Sandbox__c,
                                Storage_Key_Sandbox__c,
                                Storage_Key_Production__c,
                                Account_Name_Sandbox__c,
                                Account_Name_Production__c
                        FROM Azure_Storage_Credentials_per_Scheme__mdt
                        WHERE MasterLabel = :schemeName
                ];
            }
            catch(QueryException qe){
                throw new CredentialsForSchemeNotFoundException('Credentials not found for scheme name: ' + schemeName,qe);
            }
        }
        return credentials;

    }

    /**
     * Calculated expiry date for given operation parameter
     *
     * @param operation
     *
     * @return Datetime with calculated expiry time
     */
    private static Datetime getExpiryDatetimeForPermission(String operation){
        Datetime expiryDate;
        //if perm contains create, set shorter lifetime
        if (operation.contains('c') || operation.contains('w')) expiryDate = Datetime.now().addMinutes(5);
        // if file is for read/download only, set lifetime of SAS for a full year
        else expiryDate = Datetime.now().addDays(365);
        return expiryDate;
    }

    /**
     * Encodes given string to UTF-8
     *
     * @param stringToEncode
     *
     * @return String with encoded input
     */
    private static String urlEncode (String stringToEncode) {
        return EncodingUtil.urlEncode(stringToEncode, UTF);
    }

    /**
     * Formats given date/time into UTC format
     *
     * @param inputDate
     *
     * @return String with formatted date/time
     */
    private static String convertToUtc (Datetime inputDate) {
        return inputDate.formatGMT(DATE_FORMAT) + 'Z';
    }

    /**
     * Validates if a given operation is within the allowed operation set. For example 'd' for deletion is not allowed
     *
     * @param operation
     *
     * @return Boolean flagging whether operation is allowed by class or not
     */
    private static Boolean operationIsValid(String operation){
        Boolean isValid = true;
        if(!permissions.contains(operation)) {
            isValid = false;
            throw new OperationNotAllowedException('Operation requested not allowed');
        }
        return isValid;
    }

    /** custom exceptions **/
    @testVisible private class OperationNotAllowedException extends Exception{}
    @testVisible private class CredentialsForSchemeNotFoundException extends Exception{}
}