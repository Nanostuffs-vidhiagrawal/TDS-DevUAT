/*
Author : Biswajeet Samal
Description : Community users login using rest API
*/
@RestResource(urlMapping='/CommunityLoginAPI/*')
global without sharing class CommunityLoginAPI { 
     
    /*
* Validate User login
* @param username : Login User Username
* @param password : Login User Password
* @param domain : Login domain instance ('login' for a prod/dev instance) and ('test' for a sandbox instance)
* @return LoginResponse : For login validate response message
*/
    @HttpPost
    global static LoginResponse login() {
         
        LoginResponse objResponse = new LoginResponse();
         
        String username = RestContext.request.params.get('username');
        String password = RestContext.request.params.get('password');
        String domain = RestContext.request.params.get('domain');
         
        try{
            string loginXML = '<?xml version="1.0" encoding="utf-8"?>';  
            loginXML += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">';  
            loginXML += '<soapenv:Header>';  
            loginXML += '<urn:LoginScopeHeader>';  
            loginXML += '<urn:organizationId>'+ UserInfo.getOrganizationId() +'</urn:organizationId>';  
            loginXML += '</urn:LoginScopeHeader>';  
            loginXML += '</soapenv:Header>';  
            loginXML += '<soapenv:Body>'; 
            loginXML += '<urn:login>';
            loginXML += '<urn:username>'+ username +'</urn:username>';
            loginXML += '<urn:password>'+ password +'</urn:password>';
            loginXML += '</urn:login>'; 
            loginXML += '</soapenv:Body>';  
            loginXML += '</soapenv:Envelope>';
             
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://'+ domain +'.salesforce.com/services/Soap/c/44.0');
            request.setTimeout(60000); 
            request.setMethod('POST');
            request.setHeader('SOAPAction', 'login');
            request.setHeader('Accept','text/xml');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            request.setBody(loginXML);       
            HttpResponse response = new Http().send(request);
             
            String responseBody = response.getBody();
            String sessionId = getValueFromXMLString(responseBody, 'sessionId');
             
            objResponse.statusMessage = response.getStatus();
            objResponse.statusCode = response.getStatusCode();
             
            if(string.isNotBlank(sessionId)){
                objResponse.isSuccess = true;
                objResponse.sessionId = sessionId;
                 
            }else{
                objResponse.isSuccess = false;
            }
        }
        catch(System.Exception ex){
            objResponse.isSuccess = false;
            objResponse.statusMessage = ex.getMessage();
        }
        system.debug('objResponse-' + objResponse);
        return objResponse;
    }
     
    /*
* Get XML tag value from XML string
* @param xmlString : String XML
* @param keyField : XML key tag
* @return String : return XML tag key value
*/
    public static string getValueFromXMLString(string xmlString, string keyField){
        String xmlKeyValue = '';
        if(xmlString.contains('<' + keyField + '>')){
            try{
                xmlKeyValue = xmlString.substring(xmlString.indexOf('<' + keyField + '>')+keyField.length() + 2, xmlString.indexOf('</' + keyField + '>'));   
            }catch (exception e){
                 
            }            
        }
        return xmlKeyValue;
    }
     
    global class LoginResponse {
        public String sessionId {get; set;}
        public Boolean isSuccess {get; set;}
        public String statusMessage {get; set;}
        public Integer statusCode {get; set;}
    }
}