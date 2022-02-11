public class EI_AgentLandlordPostloginemails {

	@future(callout = true)
    public static void updatebankdetails(string useremail,string username){ 
    	string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'ashish.singh1@espire.com');
        gen.writeStringField('Name', 'SafeDeposits');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', useremail);
        gen.writeStringField('Name', username);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2356163);
        gen.writeBooleanField('TemplateLanguage', true);
       // gen.writeStringField('Subject', 'TDS: Your bank details have been updated');
        gen.writeStringField('Subject', 'Confirmation of change of payment details');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('date', Datetime.now().format('dd-MM-yyyy'));
        gen.writeStringField('agentname', username);
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

   //@future(callout = true)
    public static void customeraccountclosertotds(string useremail,string username,string usermemberid){ 
    string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'ashish.singh1@espire.com');
        gen.writeStringField('Name', 'SafeDeposits');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', 'himanshuumody15@gmail.com');
        gen.writeStringField('Name', username);
        //gen.writeStringField('Email', 'himanshuumody15@gmail.com'); actual tds email will be:-"client.relations@safedepositsscotland.com"
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2346637);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Customer Account Closure');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Customerid', usermemberid);
        gen.writeStringField('today', system.today().format());
        gen.writeStringField('customerid', usermemberid);
        gen.writeStringField('customername', username);
        gen.writeStringField('customeremail', useremail);
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
    
    //@future(callout = true)
    public static void accountcloserstatustouser(string useremail,string username){ 
    string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'ashish.singh1@espire.com');
        gen.writeStringField('Name', 'SafeDeposits');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', useremail);
        gen.writeStringField('Name', 'username');
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2358295);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Account Closer status');
        gen.writeFieldName('Variables');       
        gen.writeStartObject();
        gen.writeStringField('username', username);
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
    
    @future(callout = true)
    public static void accountcloserrequestwithactivetenancies(string useremail,string username,string usermemberid){ 
    	string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'ashish.singh1@espire.com');
        gen.writeStringField('Name', 'SafeDeposits');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', 'himanshuumody15@gmail.com');
        gen.writeStringField('Name', username);
        //gen.writeStringField('Email', 'himanshuumody15@gmail.com'); actual tds email will be:-"client.relations@safedepositsscotland.com"
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2358252);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Customer Request to Close Account with Active Tenancies');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('memberid', usermemberid);
        gen.writeStringField('username', username);
        gen.writeStringField('useremail', useremail);
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
    
    //@future(callout = true)
    public static void landlordasistance(string useremail,string username) { 
    	string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'ashish.singh1@espire.com');
        gen.writeStringField('Name', 'SafeDeposits');
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', useremail);
        gen.writeStringField('Name', username);
        //gen.writeStringField('Email', 'himanshuumody15@gmail.com'); actual tds email will be:-"client.relations@safedepositsscotland.com"
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2360551);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Do you need assistance?');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('today', system.today().format());
        gen.writeStringField('username', username);
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