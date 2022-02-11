global without sharing class EI_SDS_MailJetUtilityCls {
    
    global static EmailWrapper getEmailWrapper(String subject, String recList, Map<String,String> variables, String template) 
    {
        EmailWrapper wrap = new EmailWrapper(recList, variables, template, Subject);
        return wrap;
    } 
    
    global static HttpRequest mailJetAuthentication() {
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
    
    global static List<Mailjet_Message__c> saveMessageDetails(String resJSON, Map<String,recipient> recMap, String Subject) 
    {
        List<response> jsonList = new List<response>();
        //add try catch if deserialize breaks create Message with error
        try {
            jsonList = ( List<response>) System.JSON.deserialize(resJSON, List<response>.class);
        }
        catch(Exception e) {
            //Mailjet_Message__c mm = new Mailjet_Message__c(response_status__c='Error',Subject__c=Subject,Record_ID__c=recMap.get(msg.to[0].Email).recid,
            //Message_Id__c=msg.to[0].MessageID,Email_ID__c=msg.to[0].Email);
            //insert mm;
            system.debug('ERROR --> '+e.getMessage());
            return null;
        }
        system.debug(jsonList);
        List<Mailjet_Message__c> mailJetList = new List<Mailjet_Message__c>();
        for(response res : jsonList) {
            for(Messages msg : res.Messages) {
                system.debug(msg);
                Mailjet_Message__c mm = new Mailjet_Message__c(response_status__c='success',Subject__c=Subject, 
                                                               Record_ID__c=recMap.get(msg.to[0].Email).recid, 
                                                               Message_Id__c=msg.to[0].MessageID, Email_ID__c=msg.to[0].Email);
                mailJetList.add(mm);
            }
        }
        return mailJetList;
    }
    
    global class EmailWrapper {
        public String recList;
        public Map<String,String> variables;
        public String templateName;
        public String Subject;
        
        public EmailWrapper(String recList,Map<String,String> variables,String templateName,String Subject) {
            this.recList = recList;
            this.variables = variables;
            this.templateName = templateName;
            this.Subject = Subject;
        }
        
    }
    
    global class recipient {
        String Email;
        String name;
        String recId;
        public String Link;
        public String buttonLink;
        public String Label;
        public String contactId;
        
        public recipient(String Email,String name,String recId,String Link,String contactId) {
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            this.link = link;
            this.contactId = contactId;
            
        }
        public recipient(String Email,String name,String recId,String Link,String buttonLink,String Label,String contactId) {
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            this.link = link;
            this.buttonLink = buttonLink;
            this.Label = Label;
            this.contactId = contactId;
        }
        public recipient(String Email,String name,String recId,String contactId) {
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            this.contactId = contactId;
            
        }
        
    }
    
    global class attachmentWrapper {
        public String contentType;
        public String filename;
        public String base64Content;
        public attachmentWrapper(String contentType, String filename, String base64Content) {
            this.contentType = contentType;
            this.filename = filename;
            this.base64Content = base64Content;
        }
    }
    
    global class response {
        String Status;
        List<Messages> messages;
    }
    
    global class Messages {
        String Status;
        String CustomID;
        List<To> To;
    }
    
    global class To {
        String Email;
        String MessageUUID;
        String MessageID;
        String MessageHref;
    }
    
    global class fetchWrapper {
        @AuraEnabled  public list<Case_Participant__c> cpList; 
        @AuraEnabled public String profile;
    }
    
    //public static List<Mailjet_Message__c> sendEmail(List<EmailWrapper> wrapList) {
    @future(callout=true)
    global static void sendEmail(String emailWrapList) {
        System.debug('Line 32 - '+emailWrapList);
        list<Mailjet_Message__c> postalMessageList = new list<Mailjet_Message__c>();
        List<EmailWrapper> wrapList = (List<EmailWrapper>) JSON.deserialize(emailWrapList, List<EmailWrapper>.class);
        for(EmailWrapper wrap:wrapList) {
            System.debug('recList -> '+wrap.recList);
            System.debug('variables -> '+wrap.variables);
            System.debug('templateName -> '+wrap.templateName);
            System.debug('Subject -> '+wrap.Subject);
        }
        
        
        if(!wrapList.isEmpty()) {
            System.debug('Line 42 ');
            List<Mailjet_Message__c> mailJetMessageList = new List<Mailjet_Message__c>();
            for(EmailWrapper wrap:wrapList) 
            {
                String subject = wrap.Subject;
                String recList = wrap.recList;
                Map<String,String> variables = wrap.variables;
                String template = wrap.templateName;
                
                String jsonData;
                //HttpRequest req = mailJet_Authentication(mailjet);
                //HttpRequest req = mailJetAuthentication();
                HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
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
                List<recipient> ParticipantList = (List<recipient>) JSON.deserialize(recList,List<recipient>.class);
                for(recipient rec:ParticipantList)
                {
                    System.debug('Line 74 -> '+rec.email);
                    System.debug('Line 74 -> '+rec.name);
                    System.debug('Line 74 -> '+rec.recId);
                }
                for(recipient rec:ParticipantList)
                {
                    toAddress = rec.email;
                    toName = rec.Name;
                    system.debug('>>>>>>>>>>>>>>>>>>'+toAddress);
                    //if(String.isNotBlank(toAddress) && toAddress.contains('xyz')){
                    if(String.isNotBlank(toAddress) && !toAddress.contains('xyz')) {
                        recMap.put(rec.email,rec);
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
                                {
                                    gen.writeStringField(key, variables.get(key));
                                    System.debug('Line 114 -> '+key+' value -> '+variables.get(key));
                                }
                            }
                        }
                        system.debug('Line 118 link  '+rec.link);
                        if(rec.link !=null) {
                            gen.writeStringField('paylink',rec.link);
                        }
                        if(rec.buttonLink != null) {
                            gen.writeStringField('buttonlink','<a href="'+rec.buttonLink+'" style="background-color: #F45372; color: white; padding: 15px 40px; text-decoration: none; display: inline-block; font-size: 8px; margin: 4px 2px; cursor: pointer; border-radius: 8px;font-size: 12px;" >'+rec.label+'</a>');
                        }
                        if(toName != null)
                            gen.writeStringField('name',toName);
                        gen.writeEndObject(); 
                        
                        gen.writeEndObject(); 
                    }
                    else{
                        Mailjet_Message__c msg = new Mailjet_Message__c();
                        msg.Subject__c = subject;
                        if(String.isNotBlank(rec.contactId)){
                            if(rec.contactId.startsWith('003')){
                                msg.Contact__c = rec.contactId;
                            }else{
                                msg.Account_Id__c = rec.contactId;
                            }
                        }
                            
                        msg.Record_Id__c = rec.recid;
                        msg.Is_Postal__c = true;
                        msg.Template_Id__c = String.valueOf(mailJetTemplateId);
                        msg.Source__c = 'SDS Custodial';
                        postalMessageList.add(msg);

                    }
                }
                try {
                    
                    gen.writeEndArray();
                    gen.writeEndObject();
                    jsonData =gen.getAsString();
                    req.setBody(jsonData);
                    system.debug('jsonData -> '+jsonData);
                    Http http = new Http();
                    if(!Test.isRunningTest()) {
                        HTTPResponse res = http.send(req); 
                        if(res.getStatusCode() == 200) {
                            System.debug('Line 142 success -> ');
                            String resBody = res.getBody();
                            if(!resBody.startsWith('[')) {
                                resBody = '['+resBody+']';
                            }
                            System.debug('Line 154 success -> '+resBody);
                            List<Mailjet_Message__c> mailJetLstToAdd = saveMessageDetails(resBody,recMap,Subject);
                            for(Mailjet_Message__c mailMess : mailJetLstToAdd) {
                                mailJetMessageList.add(mailMess);
                            }
                            //mailJetMessageList.addAll(mailJetLstToAdd);
                        }
                    }
                    //system.debug('res-->>'+res.getBody());
                }
                catch(exception e) {   
                    //saveMessageDetails(resBody,recMap,Subject );
                    System.debug(e);
                    //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
                }
                //return null;
            }
            if(!mailJetMessageList.isEmpty()) {
                System.debug('Line 172 -> '+mailJetMessageList);
                try {

                    if(!postalMessageList.isEmpty()){
                        mailJetMessageList.addAll(postalMessageList);
                    }
                    insert mailJetMessageList;
                    for(Mailjet_Message__c mailMess : mailJetMessageList) {
                        System.debug('Line 172 -> '+mailMess.Id);
                    }
                } catch(Exception e) {
					System.debug('ERROR --> '+e.getMessage());
                }
            }
            //return null; 
        }
        else {
            //return new List<Mailjet_Message__c>(); 
        }
        
    }
    
    global static void sendEmailFromBatch(String emailWrapList) {
        System.debug('Line 32 - '+emailWrapList);
        list<Mailjet_Message__c> postalMessageList = new list<Mailjet_Message__c>();
        List<EmailWrapper> wrapList = (List<EmailWrapper>) JSON.deserialize(emailWrapList, List<EmailWrapper>.class);
        for(EmailWrapper wrap:wrapList) {
            System.debug('recList -> '+wrap.recList);
            System.debug('variables -> '+wrap.variables);
            System.debug('templateName -> '+wrap.templateName);
            System.debug('Subject -> '+wrap.Subject);
        }
        
        
        if(!wrapList.isEmpty()) {
            System.debug('Line 42 ');
            List<Mailjet_Message__c> mailJetMessageList = new List<Mailjet_Message__c>();
            for(EmailWrapper wrap:wrapList) 
            {
                String subject = wrap.Subject;
                String recList = wrap.recList;
                Map<String,String> variables = wrap.variables;
                String template = wrap.templateName;
                
                String jsonData;
                //HttpRequest req = mailJet_Authentication(mailjet);
                //HttpRequest req = mailJetAuthentication();
                HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
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
                List<recipient> ParticipantList = (List<recipient>) JSON.deserialize(recList,List<recipient>.class);
                for(recipient rec:ParticipantList)
                {
                    System.debug('Line 74 -> '+rec.email);
                    System.debug('Line 74 -> '+rec.name);
                    System.debug('Line 74 -> '+rec.recId);
                }
                for(recipient rec:ParticipantList)
                {
                    toAddress = rec.email;
                    toName = rec.Name;
                    //if(String.isNotBlank(toAddress) && toAddress.contains('xyz')){
                    if(String.isNotBlank(toAddress) && !toAddress.contains('xyz')) {
                        recMap.put(rec.email,rec);
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
                                {
                                    gen.writeStringField(key, variables.get(key));
                                    System.debug('Line 114 -> '+key+' value -> '+variables.get(key));
                                }
                            }
                        }
                        system.debug('Line 118 link  '+rec.link);
                        if(rec.link !=null) {
                            gen.writeStringField('paylink',rec.link);
                        }
                        if(rec.buttonLink != null) {
                            gen.writeStringField('buttonlink','<a href="'+rec.buttonLink+'" style="background-color: #F45372; color: white; padding: 15px 40px; text-decoration: none; display: inline-block; font-size: 8px; margin: 4px 2px; cursor: pointer; border-radius: 8px;font-size: 12px;" >'+rec.label+'</a>');
                        }
                        if(toName != null)
                            gen.writeStringField('name',toName);
                        gen.writeEndObject(); 
                        
                        gen.writeEndObject();
                    }else{
                        Mailjet_Message__c msg = new Mailjet_Message__c();
                        msg.Subject__c = subject;
                        if(String.isNotBlank(rec.contactId)){
                            if(rec.contactId.startsWith('003')){
                                msg.Contact__c = rec.contactId;
                            }else{
                                msg.Account_Id__c = rec.contactId;
                            }
                        }
                        msg.Record_Id__c = rec.recid;
                        msg.Is_Postal__c = true;
                        msg.Template_Id__c = String.valueOf(mailJetTemplateId);
                        msg.Source__c = 'SDS Custodial';
                        postalMessageList.add(msg);
                    } 
                }
                try {
                    
                    gen.writeEndArray();
                    gen.writeEndObject();
                    jsonData =gen.getAsString();
                    req.setBody(jsonData);
                    system.debug('jsonData -> '+jsonData);
                    Http http = new Http();
                    if(!Test.isRunningTest()) {
                        HTTPResponse res = http.send(req); 
                        if(res.getStatusCode() == 200) {
                            System.debug('Line 142 success -> ');
                            String resBody = res.getBody();
                            if(!resBody.startsWith('[')) {
                                resBody = '['+resBody+']';
                            }
                            System.debug('Line 154 success -> '+resBody);
                            List<Mailjet_Message__c> mailJetLstToAdd = saveMessageDetails(resBody,recMap,Subject);
                            for(Mailjet_Message__c mailMess : mailJetLstToAdd) {
                                mailJetMessageList.add(mailMess);
                            }
                            //mailJetMessageList.addAll(mailJetLstToAdd);
                        }
                    }
                    //system.debug('res-->>'+res.getBody());
                }
                catch(exception e) {   
                    //saveMessageDetails(resBody,recMap,Subject );
                    System.debug(e);
                    //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
                }
                //return null;
            }
            if(!mailJetMessageList.isEmpty()) {
                System.debug('Line 172 -> '+mailJetMessageList);
                try {
                    if(!postalMessageList.isEmpty()){
                        mailJetMessageList.addAll(postalMessageList);
                    }
                    insert mailJetMessageList;
                    for(Mailjet_Message__c mailMess : mailJetMessageList) {
                        System.debug('Line 172 -> '+mailMess.Id);
                    }
                } catch(Exception e) {
					System.debug('ERROR --> '+e.getMessage());
                }
            }
            //return null; 
        }
        else {
            //return new List<Mailjet_Message__c>(); 
        }
        
    }
    
    global static void sendEmailFromBatchWithAttachments(String emailWrapList, List<attachmentWrapper> attachmentWrapperList) {
        System.debug('Line 32 - '+emailWrapList);
        List<EmailWrapper> wrapList = (List<EmailWrapper>) JSON.deserialize(emailWrapList, List<EmailWrapper>.class);
        list<Mailjet_Message__c> postalMessageList = new list<Mailjet_Message__c>();
        
        if(!wrapList.isEmpty()) {
            System.debug('Line 42 ');
            List<Mailjet_Message__c> mailJetMessageList = new List<Mailjet_Message__c>();
            String fileName = EncodingUtil.urlEncode('AssistanceToProtectDeposit', 'UTF-8');
            for(EmailWrapper wrap:wrapList) 
            {
                String subject = wrap.Subject;
                String recList = wrap.recList;
                Map<String,String> variables = wrap.variables;
                String template = wrap.templateName;
                
                String jsonData;
                //HttpRequest req = mailJet_Authentication(mailjet);
                //HttpRequest req = mailJetAuthentication();
                HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
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
                gen.writeStartObject();
                List<recipient> ParticipantList = (List<recipient>) JSON.deserialize(recList,List<recipient>.class);
                
                for(recipient rec:ParticipantList)
                {
                    toAddress = rec.email;
                    toName = rec.Name;
                    //if(String.isNotBlank(toAddress) && toAddress.contains('xyz')){
                    if(String.isNotBlank(toAddress) && !toAddress.contains('xyz')) {
                        recMap.put(rec.email,rec);
                        //gen.writeStartObject(); 
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
                                {
                                    gen.writeStringField(key, variables.get(key));
                                    System.debug('Line 114 -> '+key+' value -> '+variables.get(key));
                                }
                            }
                        }
                        
                        if(rec.link !=null) {
                            gen.writeStringField('paylink',rec.link);
                        }
                        if(rec.buttonLink != null) {
                            gen.writeStringField('buttonlink','<a href="'+rec.buttonLink+'" style="background-color: #F45372; color: white; padding: 15px 40px; text-decoration: none; display: inline-block; font-size: 8px; margin: 4px 2px; cursor: pointer; border-radius: 8px;font-size: 12px;" >'+rec.label+'</a>');
                        }
                        if(toName != null)
                            gen.writeStringField('name',toName);
                        gen.writeEndObject(); 
                        
                        /* Newly Code for Attachment */
                        gen.writeFieldName('Attachments');
                        gen.writeStartArray();
                        for(attachmentWrapper attchWrap : attachmentWrapperList) {
                            //String base64Str = EncodingUtil.base64Encode(attchWrap.base64Content);
                            gen.writeStartObject();
                            gen.writeStringField('ContentType',attchWrap.contentType); 
                            gen.writeStringField('Filename',attchWrap.filename);
                            gen.writeStringField('Base64Content', attchWrap.base64Content);
                            gen.writeEndObject();
                        }    
                        gen.writeEndArray();
                        /* Newly Code for Attachment */
                        gen.writeEndObject();
                        gen.writeEndArray();
                        gen.writeEndObject();
                        
                    }else{
                        Mailjet_Message__c msg = new Mailjet_Message__c();
                        msg.Subject__c = subject;
                        if(String.isNotBlank(rec.contactId)){
                            if(rec.contactId.startsWith('003')){
                                //msg.Contact__c = rec.contactId;
                            }else{
                                //msg.Account_Id__c = rec.contactId;
                            }
                        }
                        msg.Record_Id__c = rec.recid;
                        //msg.Is_Postal__c = true;
                        //msg.Template_Id__c = String.valueOf(mailJetTemplateId);
                        postalMessageList.add(msg);
                    }
                }
                try {
                    
                    jsonData =gen.getAsString();
                    req.setBody(jsonData);
                    system.debug('jsonData -> '+jsonData);
                    Http http = new Http();
                    //if(!Test.isRunningTest()) {
                        HTTPResponse res = http.send(req); 
                        if(res.getStatusCode() == 200) {
                            System.debug('Line 142 success -> ');
                            String resBody = res.getBody();
                            if(!resBody.startsWith('[')) {
                                resBody = '['+resBody+']';
                            }
                            System.debug('Line 154 success -> '+resBody);
                            List<Mailjet_Message__c> mailJetLstToAdd = saveMessageDetails(resBody,recMap,Subject);
                            for(Mailjet_Message__c mailMess : mailJetLstToAdd) {
                                mailJetMessageList.add(mailMess);
                            }
                            //mailJetMessageList.addAll(mailJetLstToAdd);
                        }
                    //}
                    //system.debug('res-->>'+res.getBody());
                }
                catch(exception e) {   
                    //saveMessageDetails(resBody,recMap,Subject );
                    System.debug(e);
                    //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
                }
                //return null;
            }
            if(!mailJetMessageList.isEmpty()) {
                System.debug('Line 172 -> '+mailJetMessageList);
                try {

                    if(!postalMessageList.isEmpty()){
                        mailJetMessageList.addAll(postalMessageList);
                    }
                    insert mailJetMessageList;
                    for(Mailjet_Message__c mailMess : mailJetMessageList) {
                        System.debug('Line 172 -> '+mailMess.Id);
                    }
                } catch(Exception e) {
					System.debug('ERROR --> '+e.getMessage());
                }
            }
            //return null; 
        }
        else {
            //return new List<Mailjet_Message__c>(); 
        }
        
    }
    
    //@future(callout=true)
    global static void sendEmailWithAttachments(String emailWrapList, List<attachmentWrapper> attachmentWrapperList) {
        sendEmailFromBatchWithAttachments(emailWrapList, attachmentWrapperList);
    }
    
}