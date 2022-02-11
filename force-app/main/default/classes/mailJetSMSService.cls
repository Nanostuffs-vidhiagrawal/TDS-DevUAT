public class mailJetSMSService {
 
    public static HttpRequest authorizationCode(){
        
        API_Service__mdt smsService = [SELECT Label, Bearer_Token__c,EndPoint_URL__c 
                                       FROM API_Service__mdt
                                       WHERE QualifiedApiName = 'mailJetSMS'
                                      ];
        String endpoint = smsService.EndPoint_URL__c;
        String bearerToken = smsService.Bearer_Token__c;    
        HttpRequest req = new HttpRequest();       
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/text');       
        String authorizationHeader = 'Bearer ' +bearerToken;    
        req.setHeader('Authorization', authorizationHeader); 
        return req;
    }
    
    @future(callout = true)
    public static void smstotenant(string tenantphone,string activationcode){
        system.debug('line --> 22 ' + tenantphone );
        system.debug('line --> 23' + activationcode );
     HttpRequest req = mailJetSMSService.authorizationCode();   

     JSONGenerator gen = JSON.createGenerator(true);
                String textbdy = 'Please use this activation code  '+activationcode +' to activate your account by clicking on  '+System.Label.tenantactivationurl+' this link';
        if(tenantphone.startswith('0')){
            tenantphone = tenantphone.removeStart('0');
        }
                gen.writeStartObject();     
                gen.writeStringField('Text', textbdy);
                gen.writeStringField('To', System.Label.internationalphonecode+tenantphone);
                gen.writeStringField('From', 'TDS ');
                gen.writeEndObject();
                
                String jsonData = gen.getAsString(); 
                System.debug('jsonData- ' + jsonData);
                
                req.setBody(jsonData);
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                
                System.debug(res.getBody());      
                
                Map<String, Object> resMap = 
                    (Map<String, Object>)
                    JSON.deserializeUntyped(res.getBody());
                System.debug('resMap'+resMap);   
        
    }
    
}