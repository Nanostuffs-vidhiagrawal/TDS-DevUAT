/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Validation of header for Dispute API
 *
 * @when 10/12/2019
 */
public with sharing class FC_DisputeAPI_HeaderValidator {
    private Set<String> SUPPORTED_CONTENT_TYPES = new Set<String>{FC_Constant.CONTENT_TYPE_APPLICATION_JSON};
    private Set<String> SUPPORTED_ACCEPT = new Set<String>{FC_Constant.CONTENT_TYPE_APPLICATION_JSON, FC_Constant.ACCEPT_ANY};
    private Map<String,String> headersMap;
    /**
     * Public constructor. Transforms keys to lower case
     *
     * @param headersMap
     */
    public FC_DisputeAPI_HeaderValidator(Map<String,String> headersMap) {
        if(headersMap == null) {
            headersMap = new Map<String, String>();
        }
        this.headersMap = getHeadersToLowerCase(headersMap);
    }
    /**
     * Performs the valiation step by step.
     * Returns lower case transformed headers
     *
     * @return Lower case transformed headers
     */
    public Map<String,String> validateHeader() {
        this.validateAccept(headersMap.get(FC_Constant.HEADER_ACCEPT.toLowerCase()));
        this.validateContentType(headersMap.get(FC_Constant.HEADER_CONTENT_TYPE.toLowerCase()));
        this.validateAccessToken(headersMap.get(FC_Constant.HEADER_ACCESS_TOKEN.toLowerCase()));
        return headersMap;
    }
    /**
     * Validation of Content type header. Adding default value if header is missing.
     *
     * @param contentType
     */
    private void validateContentType(String contentType) {
        if(String.isBlank(contentType)) {
            contentType = FC_Constant.CONTENT_TYPE_APPLICATION_JSON;
        }
        if(!SUPPORTED_CONTENT_TYPES.contains(contentType.toLowerCase())){
            throw new FC_DisputeAPI_Exception.ContentTypeException('Content Type not supported: ' + contentType);
        }
    }
    /**
     * Validation of Accept header. Adding default value if header is missing.
     *
     * @param accept
     */
    private void validateAccept(String accept) {
        if(String.isBlank(accept)) {
            accept = FC_Constant.CONTENT_TYPE_APPLICATION_JSON;
        }
        if(!SUPPORTED_ACCEPT.contains(accept.toLowerCase())){
            throw new FC_DisputeAPI_Exception.AcceptException('Accept not supported: ' + accept);
        }
    }
    /**
     * Validation of accessToken existance.
     *
     * @param accessToken
     */
    private void validateAccessToken(String accessToken) {
        if(String.isBlank(accessToken)) {
            throw new FC_DisputeAPI_Exception.AuthenticationException('No accessToken provided.');
        }
    }
    /**
     * Transforms keyset to lower case
     *
     * @param headersMap
     *
     * @return
     */
    private Map<String,String> getHeadersToLowerCase(Map<String,String> headersMap) {
        Map<String,String> headersMapLowerCase = new Map<String, String>();
        for(String key : headersMap.keySet()) {
            headersMapLowerCase.put(key.toLowerCase(),headersMap.get(key).toLowerCase());
        }
        return headersMapLowerCase;
    }
}