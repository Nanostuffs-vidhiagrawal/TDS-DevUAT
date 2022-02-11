/**
* @who  Ashish Singh
* @what Consume API service for MailJet
* @when 01/02/2021
**/
public class EI_mailJetServiceUtility {
    
/**
* Authorization template
**/
    public static HttpRequest mailJetAuthentication(){
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
               
        HttpRequest req = new HttpRequest();
        String endPoint = mailJetSettings[0].EndPoint_URL__c;
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/text'); 
        
        String username = mailJetSettings[0].Username__c;
        String password = mailJetSettings[0].Password__c;
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);       
        req.setHeader('Authorization', authorizationHeader);   
        return req;      
    }
}