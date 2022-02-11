public without sharing class EI_MailJetUtility {
	
    public static EmailWrapper getEmailWrapper(String subject, String recList,Map<String,String> variables,String template){
        
        
        EmailWrapper wrap = new EmailWrapper(recList,variables,template,Subject);
        
        
        
        
        return wrap;
        
    }
    
    public static HttpRequest mailJetAuthentication(){
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        
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

    public static List<Mailjet_Message__c> SenEmail(EmailWrapper wrap){
        

        if(wrap == null)
            return new List<Mailjet_Message__c>();

        String subject = wrap.Subject;
        String recList = wrap.recList;
        Map<String,String> variables = wrap.variables;
        String template = wrap.templateName;
        
        String jsonData;
        //  HttpRequest req = mailJet_Authentication(mailjet);
        HttpRequest req = mailJetAuthentication();
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList(template); 
        fromAddress = templateId[0].From_Address__c;
        fromName  = templateId[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        Map<String,recipient> recMap = new Map<String,recipient>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
        List<recipient> ParticipantList =(List<recipient>) JSON.deserialize(recList,List<recipient>.class);
        for(recipient rec:ParticipantList)
        {
            recMap.put(rec.email,rec);
            toAddress = rec.email;
            toName = rec.Name;
            gen.writeStartObject(); 
            gen.writeFieldName('From');
            
            gen.writeStartObject();
            if(String.isNotBlank(fromAddress)){
                gen.writeStringField('Email', fromAddress);
            }
            if(String.isNotBlank(fromName)){
                gen.writeStringField('Name', fromName);
            }
            
            
            gen.writeEndObject();
            
            gen.writeFieldName('To');
            
            gen.writeStartArray();
            gen.writeStartObject(); 
            gen.writeStringField('Email', String.isNotBlank(toAddress)?toAddress:''); 
            gen.writeStringField('Name', String.isNotBlank(toName)?toName:'');
            gen.writeEndObject();      
            gen.writeEndArray();
            
            gen.writeNumberField('TemplateID', mailJetTemplateId); 
            gen.writeBooleanField('TemplateLanguage', true);
            
            if(String.isNotBlank(subject)){
                gen.writeStringField('Subject', subject);
            }
            
            gen.writeFieldName('Variables');    
            
            gen.writeStartObject();
            if(variables!=null){
                for(String key : variables.keySet()){
                    if( variables.get(key) !=null)
                        gen.writeStringField(key, variables.get(key)); 
                }
            }
            system.debug('link  '+rec.link);
            if(rec.link !=null){
                gen.writeStringField('paylink',rec.link);
            }
            if(rec.buttonLink != null){
                gen.writeStringField('buttonlink','<a href="'+rec.buttonLink+'" style="background-color: #F45372; color: white; padding: 15px 40px; text-decoration: none; display: inline-block; font-size: 8px; margin: 4px 2px; cursor: pointer; border-radius: 8px;font-size: 12px;" >'+rec.label+'</a>');
            }
            if(toName != null)
                gen.writeStringField('name',toName);
            gen.writeEndObject(); 
            
            gen.writeEndObject(); 
        }
        try{
            
            gen.writeEndArray();
            gen.writeEndObject();
            jsonData =gen.getAsString();
            req.setBody(jsonData);
            system.debug(jsonData);
            Http http = new Http();
            if(!Test.isRunningTest()){
                HTTPResponse res = http.send(req); 
                if(res.getStatusCode() == 200){
                    String resBody = res.getBody();
                    if(!resBody.startsWith('[')){
                        resBody = '['+resBody+']';
                    }
                    saveMessageDetails(resBody,recMap,Subject );
                }
            }
            //system.debug('res-->>'+res.getBody());
        }
        catch(exception e){   
            //saveMessageDetails(resBody,recMap,Subject );
            system.debug(e);
            //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
        }
        return null;
        
    }
    
    public static List<Mailjet_Message__c> saveMessageDetails(String resJSON,Map<String,recipient> recMap, STring Subject){
        List<response> jsonList = new  List<response>();
        //add try catch if deserialize breaks create Message with error
        try{
            jsonList =    ( List<response>) System.JSON.deserialize(resJSON, List<response>.class);
        }
        catch(Exception e){
            //Mailjet_Message__c mm = new Mailjet_Message__c(response_status__c='Error',Subject__c=Subject,Record_ID__c=recMap.get(msg.to[0].Email).recid,
            //              Message_Id__c=msg.to[0].MessageID,Email_ID__c=msg.to[0].Email);
            //insert mm;
            system.debug('ERROR --> '+e.getMessage());
        }
        system.debug(jsonList);
        List<Mailjet_Message__c> mailJetList = new List<Mailjet_Message__c>();
        for(response res : jsonList){
            
            for(Messages msg : res.Messages){
                system.debug(msg);
                Mailjet_Message__c mm = new Mailjet_Message__c(response_status__c='success',Subject__c=Subject,Record_ID__c=recMap.get(msg.to[0].Email).recid,
                                                               Message_Id__c=msg.to[0].MessageID,Email_ID__c=msg.to[0].Email);
                mailJetList.add(mm);
            }
        }
        
        return mailJetList;
    }

    public class EmailWrapper{

        public String recList;
        public Map<String,String> variables;
        public String templateName;
        public String Subject;

        public EmailWrapper(String recList,Map<String,String> variables,String templateName,String Subject){
            this.recList = recList;
            this.variables = variables;
            this.templateName = templateName;
            this.Subject = Subject;
        }

    }

    public class recipient{
        String Email;
        String name;
        String recId;
        public String Link;
        public String buttonLink;
        public String Label;
        
        public recipient(String Email,String name,String recId,String Link){
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            this.link = link;
            
        }
        public recipient(String Email,String name,String recId,String Link,String buttonLink,String Label){
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            this.link = link;
            this.buttonLink = buttonLink;
            this.Label = Label;
        }
        public recipient(String Email,String name,String recId){
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            
        }
    }
    
    public class response{
        String Status;
        List<Messages> messages;
    }
    
    public class Messages{
        String Status;
        String CustomID;
        List<To> To;
    }
        
    public class To{
        String Email;
        String MessageUUID;
        String MessageID;
        String MessageHref;
    }
    
    public class fetchWrapper{
        @AuraEnabled  public list<Case_Participant__c> cpList; 
        @AuraEnabled public String profile;
    }
}