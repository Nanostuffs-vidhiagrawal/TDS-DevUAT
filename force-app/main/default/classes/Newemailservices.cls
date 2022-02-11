public class Newemailservices {
    
 public static string method1(){ 
     string message = 'mail send';
        HttpRequest req = new HttpRequest();
        String endpoint = 'https://api.mailjet.com/v3.1/send';
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/text'); 
        
        String username = '149e22044add6860160c56c12a500708';
        String password = '3bc9ecf441468a0dee61982308eb7fb7';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        
        req.setHeader('Authorization', authorizationHeader);     
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'ashish.singh1@espire.com');
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', 'himanshuumody15@gmail.com');
        gen.writeStringField('Name', 'Ashish');
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2245873);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Your SafeDeposits Scotland registration');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('date', '21-Jan-2021');
        gen.writeStringField('name', 'Ashish Singh');
        gen.writeStringField('business_name', 'Espire Infolabs Private Limited');
        gen.writeStringField('fullname', 'Ashish Singh');
        gen.writeStringField('postal_address', '122001');
        gen.writeStringField('customerphone', '0124-225500xx');
        gen.writeStringField('email_address', 'himanshuumody15@gmail.com');
        gen.writeStringField('pin', '122001');         
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
             
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
   return  message;
    }
    
    @future(callout = true)
    public static void deactivationmailtouser(string email,string customername,string memberid ){ 
    string message = 'mail send';
        HttpRequest req = new HttpRequest();
        String endpoint = 'https://api.mailjet.com/v3.1/send';
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/text'); 
        
        String username = '149e22044add6860160c56c12a500708';
        String password = '3bc9ecf441468a0dee61982308eb7fb7';
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        
        req.setHeader('Authorization', authorizationHeader);     
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'ashish.singh1@espire.com');
        gen.writeStringField('Name', 'SDS');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', email);
        gen.writeStringField('Name', customername);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2346637);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', ' Customer Account Closure');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Customerid', memberid);
        gen.writeStringField('today', system.today().format());
        gen.writeStringField('customerid', memberid);
        gen.writeStringField('customername', customername);
        gen.writeStringField('customeremail', email);
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
             
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
}