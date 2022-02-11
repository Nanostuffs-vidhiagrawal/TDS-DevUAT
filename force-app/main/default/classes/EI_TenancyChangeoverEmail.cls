public class EI_TenancyChangeoverEmail {
    
	//@future(callout = true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper changeoveracceptance(string useremail,string userpersonemail,string username,string DAN,
                                                                             String Address,string customerid,string depositid) 
    { 
    string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover accepted -'+Address;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('ChangeoverAcceptMailToAALL');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        if(useremail!=null){
            toAddress = useremail;
        }
        else{
            toAddress = userpersonemail;   
        }
        
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, customerid));
        Map<String, String> variableMap = new Map<String, String>(); 
        variableMap.put('Date', tdstr);
        variableMap.put('name', username);
         variableMap.put('DAN', DAN);
        variableMap.put('Address', Address);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'ChangeoverAcceptMailToAALL', emailsubject);
        
        /*HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
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
        if(useremail!=null)
        gen.writeStringField('Email', useremail);
        else{
         gen.writeStringField('Email', userpersonemail);    
        }
        gen.writeStringField('Name', username);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2358560);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Reference: '+DAN+'Acceptance of tenant changeover – action required');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Date', system.today().format());
        gen.writeStringField('name', username);
        gen.writeStringField('DAN', DAN);
        gen.writeStringField('Address', Address);
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
             
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());*/
        
        Return EmailWrapper;
    }
    
    //@future(callout = true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper changeoveracceptancetotenant(string userpersonemail,string username,string DAN,String Address,
                                                                                     string depositid, String contactId) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = ' Thank you for confirming you have moved out -'+Address;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('ChangeoverAcceptMailToTenant');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = userpersonemail;
        
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName,depositid,contactId));
        Map<String, String> variableMap = new Map<String, String>(); 
        variableMap.put('Date', tdstr);
        variableMap.put('name', username);
        variableMap.put('DAN', DAN);
        variableMap.put('Address', Address);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'ChangeoverAcceptMailToTenant', emailsubject);    
        
        
        /* HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
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
        gen.writeStringField('Email', userpersonemail);    
        gen.writeStringField('Name', username);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2358560);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Reference: '+DAN+'Acceptance of tenant changeover – action required');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Date', system.today().format());
        gen.writeStringField('name', username);
        gen.writeStringField('DAN', DAN);
        gen.writeStringField('Address', Address);
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody()); */
        return EmailWrapper;
    }
    
  	//@future(callout = true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper changeovercanceltenants(string useremail,string username,string DAN,String Address, 
                                                                                string tenantid, string contactId) 
    { 
        
       string message = 'mail send';
        
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
          
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover cancelled -'+Address;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('AgentlandlordCancelChangeovrMailToTenant');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username; 
        toAddress = useremail;    
        
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName,tenantid, '', contactId));
        Map<String, String> variableMap = new Map<String, String>(); 
               variableMap.put('date', tdstr);
                variableMap.put('endUser', username);
               // variableMap.put('DAN', DAN);
                variableMap.put('propertyaddress', Address);
                //variableMap.put('scheme_signatory', schemeSignatory);
                EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'AgentlandlordCancelChangeovrMailToTenant', emailsubject);
        
       
        return EmailWrapper;
    }

    //@future(callout = true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper changeovercancellandlordagent(string useremail,string userpersonemail,string username,string DAN,String Address,string customerid, String contactId){ 
    string message = 'mail send';
       
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
      	// String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover cancelled -'+Address;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('AgentlandlordCancelChangeovrMailToAALL');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        if(useremail!=null){
            toAddress = useremail;
        }
        {
            toAddress = userpersonemail;    
        }
        
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName,customerid, '', contactId));
        Map<String, String> variableMap = new Map<String, String>(); 
        variableMap.put('date', tdstr);
        variableMap.put('endUser', username);
        // variableMap.put('DAN', DAN);
        variableMap.put('propertyaddress', Address);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'AgentlandlordCancelChangeovrMailToAALL', emailsubject);
        
      	/* HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
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
          if(useremail!=null)
        gen.writeStringField('Email', useremail);
        else{
         gen.writeStringField('Email', userpersonemail);    
        }
        gen.writeStringField('Name', username);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 2358650);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Reference: '+DAN+'Tenant changeover request expired');
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Date', system.today().format());
        gen.writeStringField('name', username);
        gen.writeStringField('DAN', DAN);
        gen.writeStringField('Address', Address);
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
             
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());*/
        return EmailWrapper;
    }
    
   // @future(callout = true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper changeoverrequestedtenants(string useremail,string username,string DAN,String Address, 
                                                                                   string tenantid,string depositid,string tenantdata) 
    {
        system.debug('line-->322');
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
          
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Please confirm you have moved out -'+Address;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('AAChangeOverInitiatedToTenant');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username; 
        toAddress = useremail;    
        
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, tenantid));
        Map<String, String> variableMap = new Map<String, String>(); 
        variableMap.put('Date', tdstr);
        variableMap.put('name', username);
        variableMap.put('DAN', DAN);
        variableMap.put('Address', Address);
        variableMap.put('Tenant_changeover_details',tenantdata );
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'AAChangeOverInitiatedToTenant', emailsubject);
      
        return EmailWrapper;
    }
    
    // @future(callout = true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper changeoverrequestcustomer(string useremail,string userpersonemail,string username,
                                                                                  string DAN,String Address,string CustomerId,string depositid) 
    { 
        string message = 'mail send';
        
        /* Newly added code for Mailjet Utility Class START */
        // List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        
        // EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
        /* Newly added code for Mailjet Utility Class END */
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover initiated -' +Address;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('AAChangeOverInitiatedToAA');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username; 
        if(useremail!=null){
            toAddress = useremail;
        }
        else{
            toAddress = userpersonemail;    
        }
        
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, CustomerId));
        Map<String, String> variableMap = new Map<String, String>(); 
        variableMap.put('Date', tdstr);
        variableMap.put('name', username);
        variableMap.put('DAN', DAN);
        variableMap.put('Address', Address);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'AAChangeOverInitiatedToAA', emailsubject);
        //  emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
        //                                                                 'AAChangeOverInitiatedToAA', emailsubject));
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        /* Newly added code for sending mail through MailJet START */
        // EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
        /* Newly added code for sending mail through MailJet END */
        
        
        /*      JSONGenerator gen = JSON.createGenerator(true);

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
        if(useremail!=null)
        	gen.writeStringField('Email', useremail);
        else{
        	gen.writeStringField('Email', userpersonemail);    
        }
        gen.writeStringField('Name', username);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', mailJetTemplateId);
        gen.writeBooleanField('TemplateLanguage', true);
        // gen.writeStringField('Subject', 'Reference: '+DAN+' Tenant changeover requested');
        gen.writeStringField('Subject', emailsubject);
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Date', system.today().format());
        gen.writeStringField('name', username);
        gen.writeStringField('DAN', DAN);
        gen.writeStringField('Address', Address);
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());*/
        return EmailWrapper;
    }

}