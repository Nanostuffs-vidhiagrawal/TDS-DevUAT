public without sharing class EI_SendEmailFromActApex {
     
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
    
    @future(callout =true)
    public static void sendEmailByMailJet(string CaseId, string subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = new list<Case>();
        if(subjectvalue =='Tenant agrees to claim')
        {
            caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                        Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                        Deposit_Account_Number__r.Property_Address__c,
                        Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                        Deposit_Account_Number__r.Start_Date__c, 
                        Deposit_Account_Number__r.Deposit_Amount__c,
                        (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                         Contact__r.Name,
                         Contact__r.Phone FROM Case_Participants__r),
                        (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                         Claimed_by_Landlord__c,Landlord_Statement__c,
                         Other_Reason__c,Tenant_Statement__c 
                         FROM Dispute_Items__r
                         ORDER BY type__c ASC) 
                        FROM Case 
                        WHERE id=:CaseId]; 
        }
        else if(subjectvalue =='Self Resolution Invitation Mail')
        {
            caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                        Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                        Deposit_Account_Number__r.Property_Address__c,
                        Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                        Deposit_Account_Number__r.Start_Date__c, 
                        Deposit_Account_Number__r.Deposit_Amount__c,
                        (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                         Contact__r.Name,
                         Contact__r.Phone FROM Case_Participants__r),
                        (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                         Claimed_by_Landlord__c,Landlord_Statement__c,
                         Other_Reason__c,Tenant_Statement__c 
                         FROM Dispute_Items__r
                         ORDER BY type__c ASC) 
                        FROM Case 
                        WHERE id=:CaseId]; 
            
        }
        else
        {
            caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                        Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                        Deposit_Account_Number__r.Property_Address__c,
                        Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                        Deposit_Account_Number__r.Start_Date__c, 
                        Deposit_Account_Number__r.Deposit_Amount__c,
                        (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                         Contact__r.Name,
                         Contact__r.Phone FROM Case_Participants__r 
                         WHERE type__c = 'tenant'),
                        (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                         Claimed_by_Landlord__c,Landlord_Statement__c,
                         Other_Reason__c,Tenant_Statement__c 
                         FROM Dispute_Items__r
                         ORDER BY type__c ASC) 
                        FROM Case 
                        WHERE id=:CaseId];
        }
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = subjectvalue /*caseList[0].ZD_Reference_Number__c+ '– Invitation to respond to agent/landlord claim'*/;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        
        
        for(Case_Participant__c cp:caseList[0].Case_Participants__r)
        {
            
            toAddress = cp.Contact__r.Email;
            toName = cp.Contact__r.Name;
            gen.writeStartObject(); 
            gen.writeFieldName('From');
            gen.writeStartObject();
            gen.writeStringField('Email', fromAddress);
            gen.writeStringField('Name', fromName);
            gen.writeEndObject();
            
            gen.writeFieldName('To');
            gen.writeStartArray();
            gen.writeStartObject(); 
            gen.writeStringField('Email', toAddress); 
            gen.writeStringField('Name', toName);
            gen.writeEndObject();      
            gen.writeEndArray();
            
            gen.writeNumberField('TemplateID', mailJetTemplateId); 
            gen.writeBooleanField('TemplateLanguage', true);
            gen.writeStringField('Subject', SUBJECT); 
            
            gen.writeFieldName('Variables');       
            gen.writeStartObject();
            gen.writeStringField('tenant_name', toName); 
            gen.writeStringField('property_address',caseList[0].Deposit_Account_Number__r.Property_Address__c); 
            gen.writeStringField('claim_number', caseList[0].ZD_Reference_Number__c);
            gen.writeStringField('claim_table', claimTable);
            gen.writeStringField('total_claim', String.valueOf(caseList[0].Total_Claim_Amount__c));
            gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
            gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
            gen.writeEndObject(); 
            gen.writeEndObject(); 
        }
        try{
            
            gen.writeEndArray();
            gen.writeEndObject();
            jsonData =gen.getAsString();
            req.setBody(jsonData);
            Http http = new Http();
            HTTPResponse res = http.send(req); 
            system.debug('res-->>'+res.getBody());
        }
        catch(exception e){   
        }
        
    }
    
    public static void sendEmailByMailJet2(string CaseId, String Subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                               Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                               Deposit_Account_Number__r.Property_Address__c,
                               Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                               Deposit_Account_Number__r.Start_Date__c, 
                               Deposit_Account_Number__r.Deposit_Amount__c,
                               (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                                Contact__r.Name,
                                Contact__r.Phone FROM Case_Participants__r),
                               (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                                Claimed_by_Landlord__c,Landlord_Statement__c,
                                Other_Reason__c,Tenant_Statement__c 
                                FROM Dispute_Items__r
                                ORDER BY type__c ASC) 
                               FROM Case 
                               WHERE id=:CaseId]; 
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = Subjectvalue;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        
        
        for(Case_Participant__c cp:caseList[0].Case_Participants__r)
        {
            
            toAddress = cp.Contact__r.Email;
            toName = cp.Contact__r.Name;
            gen.writeStartObject(); 
            gen.writeFieldName('From');
            gen.writeStartObject();
            gen.writeStringField('Email', fromAddress);
            gen.writeStringField('Name', fromName);
            gen.writeEndObject();
            
            gen.writeFieldName('To');
            gen.writeStartArray();
            gen.writeStartObject(); 
            gen.writeStringField('Email', toAddress); 
            gen.writeStringField('Name', toName);
            gen.writeEndObject();      
            gen.writeEndArray();
            
            gen.writeNumberField('TemplateID', mailJetTemplateId); 
            gen.writeBooleanField('TemplateLanguage', true);
            gen.writeStringField('Subject', SUBJECT); 
            
            gen.writeFieldName('Variables');       
            gen.writeStartObject();
            gen.writeStringField('tenant_name', toName); 
            gen.writeStringField('property_address',caseList[0].Deposit_Account_Number__r.Property_Address__c); 
            gen.writeStringField('claim_number', caseList[0].ZD_Reference_Number__c);
            gen.writeStringField('claim_table', claimTable);
            gen.writeStringField('total_claim', String.valueOf(caseList[0].Total_Claim_Amount__c));
            gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
            gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
            gen.writeEndObject(); 
            gen.writeEndObject(); 
        }
        try{
            
            gen.writeEndArray();
            gen.writeEndObject();
            jsonData =gen.getAsString();
            req.setBody(jsonData);
            Http http = new Http();
            HTTPResponse res = http.send(req); 
        }
        catch(exception e){   
        }
        
    }
    
    public static void sendEmailByMailJetSelfresolution(List<Case> CaseId, string subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                               Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                               Deposit_Account_Number__r.Property_Address__c,
                               Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                               Deposit_Account_Number__r.Start_Date__c, 
                               Deposit_Account_Number__r.Deposit_Amount__c,
                               (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                                Contact__r.Name,
                                Contact__r.Phone FROM Case_Participants__r),
                               (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                                Claimed_by_Landlord__c,Landlord_Statement__c,
                                Other_Reason__c,Tenant_Statement__c 
                                FROM Dispute_Items__r
                                ORDER BY type__c ASC) 
                               FROM Case 
                               WHERE id in :CaseId]; 
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = subjectvalue /*caseList[0].ZD_Reference_Number__c+ '– Invitation to respond to agent/landlord claim'*/;
        
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        system.debug('caseList-->>'+caseList.size());
        for(Case Cs: caseList)
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();    
            gen.writeFieldName('Messages'); 
            gen.writeStartArray();
            for(Case_Participant__c cp:Cs.Case_Participants__r)
            {
                toAddress = cp.Contact__r.Email;
                toName = cp.Contact__r.Name;
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                gen.writeStartObject();
                gen.writeStringField('Email', fromAddress);
                gen.writeStringField('Name', fromName);
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                gen.writeStartArray();
                gen.writeStartObject(); 
                gen.writeStringField('Email', toAddress); 
                gen.writeStringField('Name', toName);
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', mailJetTemplateId); 
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', SUBJECT); 
                
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('tenant_name', toName); 
              /*  gen.writeStringField('property_address',caseList[0].Deposit_Account_Number__r.Property_Address__c); 
                gen.writeStringField('claim_number', caseList[0].ZD_Reference_Number__c);
                gen.writeStringField('claim_table', claimTable);
                gen.writeStringField('total_claim', String.valueOf(caseList[0].Total_Claim_Amount__c));*/
                gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
                gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
                gen.writeEndObject(); 
                gen.writeEndObject(); 
            }
            try{
                
                gen.writeEndArray();
                gen.writeEndObject();
                jsonData =gen.getAsString();
                req.setBody(jsonData);
                Http http = new Http();
                HTTPResponse res = http.send(req); 
                system.debug('res-->>'+res.getBody());
            }
            catch(exception e){   
            }
            
        } 
    }
    
    public static void sendReminderEmailAGLL(List<Case> CaseId, string subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                               Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                               Deposit_Account_Number__r.Property_Address__c,
                               Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                               Deposit_Account_Number__r.Start_Date__c, 
                               Deposit_Account_Number__r.Deposit_Amount__c,
                               (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                                Contact__r.Name,
                                Contact__r.Phone FROM Case_Participants__r where type__c != 'tenant' ),
                               (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                                Claimed_by_Landlord__c,Landlord_Statement__c,
                                Other_Reason__c,Tenant_Statement__c 
                                FROM Dispute_Items__r
                                ORDER BY type__c ASC) 
                               FROM Case 
                               WHERE id in :CaseId]; 
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = subjectvalue /*caseList[0].ZD_Reference_Number__c+ '– Invitation to respond to agent/landlord claim'*/;
        
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        system.debug('caseList-->>'+caseList.size());
        for(Case Cs: caseList)
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();    
            gen.writeFieldName('Messages'); 
            gen.writeStartArray();
            for(Case_Participant__c cp:Cs.Case_Participants__r)
            {
                toAddress = cp.Contact__r.Email;
                toName = cp.Contact__r.Name;
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                gen.writeStartObject();
                gen.writeStringField('Email', fromAddress);
                gen.writeStringField('Name', fromName);
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                gen.writeStartArray();
                gen.writeStartObject(); 
                gen.writeStringField('Email', toAddress); 
                gen.writeStringField('Name', toName);
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', mailJetTemplateId); 
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', SUBJECT); 
                
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('tenant_name', toName); 
              /*  gen.writeStringField('property_address',caseList[0].Deposit_Account_Number__r.Property_Address__c); 
                gen.writeStringField('claim_number', caseList[0].ZD_Reference_Number__c);
                gen.writeStringField('claim_table', claimTable);
                gen.writeStringField('total_claim', String.valueOf(caseList[0].Total_Claim_Amount__c));*/
                gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
                gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
                gen.writeEndObject(); 
                gen.writeEndObject(); 
            }
            try{
                
                gen.writeEndArray();
                gen.writeEndObject();
                jsonData =gen.getAsString();
                req.setBody(jsonData);
                Http http = new Http();
                HTTPResponse res = http.send(req); 
                system.debug('res-->>'+res.getBody());
            }
            catch(exception e){   
            }
            
        } 
    }
    
    public static void sendReminderEmailTT(List<Case> CaseId, string subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                               Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                               Deposit_Account_Number__r.Property_Address__c,
                               Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                               Deposit_Account_Number__r.Start_Date__c, 
                               Deposit_Account_Number__r.Deposit_Amount__c,
                               (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                                Contact__r.Name,
                                Contact__r.Phone FROM Case_Participants__r where type__c = 'tenant' ),
                               (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                                Claimed_by_Landlord__c,Landlord_Statement__c,
                                Other_Reason__c,Tenant_Statement__c 
                                FROM Dispute_Items__r
                                ORDER BY type__c ASC) 
                               FROM Case 
                               WHERE id in :CaseId]; 
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = subjectvalue /*caseList[0].ZD_Reference_Number__c+ '– Invitation to respond to agent/landlord claim'*/;
        
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        system.debug('caseList-->>'+caseList.size());
        for(Case Cs: caseList)
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();    
            gen.writeFieldName('Messages'); 
            gen.writeStartArray();
            for(Case_Participant__c cp:Cs.Case_Participants__r)
            {
                toAddress = cp.Contact__r.Email;
                toName = cp.Contact__r.Name;
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                gen.writeStartObject();
                gen.writeStringField('Email', fromAddress);
                gen.writeStringField('Name', fromName);
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                gen.writeStartArray();
                gen.writeStartObject(); 
                gen.writeStringField('Email', toAddress); 
                gen.writeStringField('Name', toName);
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', mailJetTemplateId); 
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', SUBJECT); 
                
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('tenant_name', toName); 
              /*  gen.writeStringField('property_address',caseList[0].Deposit_Account_Number__r.Property_Address__c); 
                gen.writeStringField('claim_number', caseList[0].ZD_Reference_Number__c);
                gen.writeStringField('claim_table', claimTable);
                gen.writeStringField('total_claim', String.valueOf(caseList[0].Total_Claim_Amount__c));*/
                gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
                gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
                gen.writeEndObject(); 
                gen.writeEndObject(); 
            }
            try{
                
                gen.writeEndArray();
                gen.writeEndObject();
                jsonData =gen.getAsString();
                req.setBody(jsonData);
                Http http = new Http();
                HTTPResponse res = http.send(req); 
                system.debug('res-->>'+res.getBody());
            }
            catch(exception e){   
            }
            
        } 
    }
    
    public static void sendEmailCaseCloseBothNotRespond(List<Case> CaseId, string subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                               Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                               Deposit_Account_Number__r.Property_Address__c,
                               Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                               Deposit_Account_Number__r.Start_Date__c, 
                               Deposit_Account_Number__r.Deposit_Amount__c,
                               (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                                Contact__r.Name,
                                Contact__r.Phone FROM Case_Participants__r),
                               (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                                Claimed_by_Landlord__c,Landlord_Statement__c,
                                Other_Reason__c,Tenant_Statement__c 
                                FROM Dispute_Items__r
                                ORDER BY type__c ASC) 
                               FROM Case 
                               WHERE id in :CaseId]; 
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = subjectvalue /*caseList[0].ZD_Reference_Number__c+ '– Invitation to respond to agent/landlord claim'*/;
        
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        system.debug('caseList-->>'+caseList.size());
        for(Case Cs: caseList)
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();    
            gen.writeFieldName('Messages'); 
            gen.writeStartArray();
            for(Case_Participant__c cp:Cs.Case_Participants__r)
            {
                toAddress = cp.Contact__r.Email;
                toName = cp.Contact__r.Name;
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                gen.writeStartObject();
                gen.writeStringField('Email', fromAddress);
                gen.writeStringField('Name', fromName);
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                gen.writeStartArray();
                gen.writeStartObject(); 
                gen.writeStringField('Email', toAddress); 
                gen.writeStringField('Name', toName);
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', mailJetTemplateId); 
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', SUBJECT); 
                
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('tenant_name', toName); 
              /*  gen.writeStringField('property_address',caseList[0].Deposit_Account_Number__r.Property_Address__c); 
                gen.writeStringField('claim_number', caseList[0].ZD_Reference_Number__c);
                gen.writeStringField('claim_table', claimTable);
                gen.writeStringField('total_claim', String.valueOf(caseList[0].Total_Claim_Amount__c));*/
                gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
                gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
                gen.writeEndObject(); 
                gen.writeEndObject(); 
            }
            try{
                
                gen.writeEndArray();
                gen.writeEndObject();
                jsonData =gen.getAsString();
                req.setBody(jsonData);
                Http http = new Http();
                HTTPResponse res = http.send(req); 
                system.debug('res-->>'+res.getBody());
            }
            catch(exception e){   
            }
            
        } 
    }
    
    public static void sendEmailCaseCloseAGLLNotRespond(List<Case> CaseId, string subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                               Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                               Deposit_Account_Number__r.Property_Address__c,
                               Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                               Deposit_Account_Number__r.Start_Date__c, 
                               Deposit_Account_Number__r.Deposit_Amount__c,
                               (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                                Contact__r.Name,
                                Contact__r.Phone FROM Case_Participants__r),
                               (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                                Claimed_by_Landlord__c,Landlord_Statement__c,
                                Other_Reason__c,Tenant_Statement__c 
                                FROM Dispute_Items__r
                                ORDER BY type__c ASC) 
                               FROM Case 
                               WHERE id in :CaseId]; 
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = subjectvalue /*caseList[0].ZD_Reference_Number__c+ '– Invitation to respond to agent/landlord claim'*/;
        
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        system.debug('caseList-->>'+caseList.size());
        for(Case Cs: caseList)
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();    
            gen.writeFieldName('Messages'); 
            gen.writeStartArray();
            for(Case_Participant__c cp:Cs.Case_Participants__r)
            {
                toAddress = cp.Contact__r.Email;
                toName = cp.Contact__r.Name;
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                gen.writeStartObject();
                gen.writeStringField('Email', fromAddress);
                gen.writeStringField('Name', fromName);
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                gen.writeStartArray();
                gen.writeStartObject(); 
                gen.writeStringField('Email', toAddress); 
                gen.writeStringField('Name', toName);
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', mailJetTemplateId); 
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', SUBJECT); 
                
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('tenant_name', toName); 
              /*  gen.writeStringField('property_address',caseList[0].Deposit_Account_Number__r.Property_Address__c); 
                gen.writeStringField('claim_number', caseList[0].ZD_Reference_Number__c);
                gen.writeStringField('claim_table', claimTable);
                gen.writeStringField('total_claim', String.valueOf(caseList[0].Total_Claim_Amount__c));*/
                gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
                gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
                gen.writeEndObject(); 
                gen.writeEndObject(); 
            }
            try{
                
                gen.writeEndArray();
                gen.writeEndObject();
                jsonData =gen.getAsString();
                req.setBody(jsonData);
                Http http = new Http();
                HTTPResponse res = http.send(req); 
                system.debug('res-->>'+res.getBody());
            }
            catch(exception e){   
            }
            
        } 
    }
    
    public static void sendEmailInviteEvidanceGathering(List<Case> CaseId, string subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                               Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                               Deposit_Account_Number__r.Property_Address__c,
                               Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                               Deposit_Account_Number__r.Start_Date__c, 
                               Deposit_Account_Number__r.Deposit_Amount__c,
                               (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                                Contact__r.Name,
                                Contact__r.Phone FROM Case_Participants__r),
                               (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                                Claimed_by_Landlord__c,Landlord_Statement__c,
                                Other_Reason__c,Tenant_Statement__c 
                                FROM Dispute_Items__r
                                ORDER BY type__c ASC) 
                               FROM Case 
                               WHERE id in :CaseId]; 
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = subjectvalue /*caseList[0].ZD_Reference_Number__c+ '– Invitation to respond to agent/landlord claim'*/;
        
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        system.debug('caseList-->>'+caseList.size());
        for(Case Cs: caseList)
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();    
            gen.writeFieldName('Messages'); 
            gen.writeStartArray();
            for(Case_Participant__c cp:Cs.Case_Participants__r)
            {
                toAddress = cp.Contact__r.Email;
                toName = cp.Contact__r.Name;
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                gen.writeStartObject();
                gen.writeStringField('Email', fromAddress);
                gen.writeStringField('Name', fromName);
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                gen.writeStartArray();
                gen.writeStartObject(); 
                gen.writeStringField('Email', toAddress); 
                gen.writeStringField('Name', toName);
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', mailJetTemplateId); 
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', SUBJECT); 
                
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('tenant_name', toName); 
              /*  gen.writeStringField('property_address',caseList[0].Deposit_Account_Number__r.Property_Address__c); 
                gen.writeStringField('claim_number', caseList[0].ZD_Reference_Number__c);
                gen.writeStringField('claim_table', claimTable);
                gen.writeStringField('total_claim', String.valueOf(caseList[0].Total_Claim_Amount__c));*/
                gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
                gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
                gen.writeEndObject(); 
                gen.writeEndObject(); 
            }
            try{
                
                gen.writeEndArray();
                gen.writeEndObject();
                jsonData =gen.getAsString();
                req.setBody(jsonData);
                Http http = new Http();
                HTTPResponse res = http.send(req); 
                system.debug('res-->>'+res.getBody());
            }
            catch(exception e){   
            }
            
        } 
    }
    
    @future(callout =true)
    public static void sendEmailtoLandlordSelfResolution(string CaseId, string subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                               Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                               Deposit_Account_Number__r.Property_Address__c,
                               Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                               Deposit_Account_Number__r.Start_Date__c, 
                               Deposit_Account_Number__r.Deposit_Amount__c,
                               (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                                Contact__r.Name,
                                Contact__r.Phone FROM Case_Participants__r where Type__c !='Tenant'),
                               (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                                Claimed_by_Landlord__c,Landlord_Statement__c,
                                Other_Reason__c,Tenant_Statement__c 
                                FROM Dispute_Items__r
                                ORDER BY type__c ASC) 
                               FROM Case 
                               WHERE id =:CaseId]; 
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = subjectvalue ;
        
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        for(Case Cs: caseList)
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();    
            gen.writeFieldName('Messages'); 
            gen.writeStartArray();
            for(Case_Participant__c cp:Cs.Case_Participants__r)
            {
                toAddress = cp.Contact__r.Email;
                toName = cp.Contact__r.Name;
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                gen.writeStartObject();
                gen.writeStringField('Email', fromAddress);
                gen.writeStringField('Name', fromName);
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                gen.writeStartArray();
                gen.writeStartObject(); 
                gen.writeStringField('Email', toAddress); 
                gen.writeStringField('Name', toName);
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', mailJetTemplateId); 
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', SUBJECT); 
                
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('tenant_name', toName); 
                
                gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
                gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
                gen.writeEndObject(); 
                gen.writeEndObject(); 
            }
            try{
                
                gen.writeEndArray();
                gen.writeEndObject();
                jsonData =gen.getAsString();
                req.setBody(jsonData);
                Http http = new Http();
                HTTPResponse res = http.send(req); 
            }
            catch(exception e){   
            }
            
        } 
    }
    
    @future(callout =true)
    public static void sendEmailtoTenantSelfResolution(string CaseId, string subjectvalue)
    {
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String SUBJECT;
        String propertyAddress;
        Decimal amount;
        String bankAccountName;
        String schemeSignatory;
        Integer daysRemaining;
        String schemeAddress;
        String danNo;
        String sortCode;
        String accountNumber;
        String claimNumber;
        List<Case> caseList = [SELECT id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,
                               Total_Claim_Amount__c,Deposit_Account_Number__r.Name,Respond_Date__c,
                               Deposit_Account_Number__r.Property_Address__c,
                               Deposit_Account_Number__r.Status__c,ZD_Reference_Number__c, 
                               Deposit_Account_Number__r.Start_Date__c, 
                               Deposit_Account_Number__r.Deposit_Amount__c,
                               (SELECT id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Email,
                                Contact__r.Name,
                                Contact__r.Phone FROM Case_Participants__r where Type__c ='Tenant'),
                               (SELECT id,Name,Type__c,Agreed_by_Tenant__c,
                                Claimed_by_Landlord__c,Landlord_Statement__c,
                                Other_Reason__c,Tenant_Statement__c 
                                FROM Dispute_Items__r
                                ORDER BY type__c ASC) 
                               FROM Case 
                               WHERE id =:CaseId]; 
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        
        SUBJECT = subjectvalue ;
        
        
        String claimTable='';
        for(Dispute_Item__c d:caseList[0].Dispute_Items__r)
        {
            if(d.type__c == 'other'){
                claimTable = claimTable + d.Type__c+ ' - ' + d.Other_Reason__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>' ;
            }else{
                claimTable = claimTable + d.Type__c + ' : £' +  d.Claimed_by_Landlord__c +'<br/>';
            }    
        }
        for(Case Cs: caseList)
        {
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();    
            gen.writeFieldName('Messages'); 
            gen.writeStartArray();
            for(Case_Participant__c cp:Cs.Case_Participants__r)
            {
                toAddress = cp.Contact__r.Email;
                toName = cp.Contact__r.Name;
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                gen.writeStartObject();
                gen.writeStringField('Email', fromAddress);
                gen.writeStringField('Name', fromName);
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                gen.writeStartArray();
                gen.writeStartObject(); 
                gen.writeStringField('Email', toAddress); 
                gen.writeStringField('Name', toName);
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', mailJetTemplateId); 
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', SUBJECT); 
                
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('tenant_name', toName); 
                
                gen.writeStringField('due_date', String.valueOf(caseList[0].Respond_Date__c));
                gen.writeStringField('link_url', 'https://espdevpro1-thedisputeservice.cs87.force.com/s/');
                gen.writeEndObject(); 
                gen.writeEndObject(); 
            }
            try{
                
                gen.writeEndArray();
                gen.writeEndObject();
                jsonData =gen.getAsString();
                req.setBody(jsonData);
                Http http = new Http();
                HTTPResponse res = http.send(req); 
            }
            catch(exception e){   
            }
            
        } 
    }
    
    @future(callout = true)
    public static void sendEMailToTenantEarLResolution(String caseJson,String SUBJECT,String participants){
        String jsonData;
        HttpRequest req = mailJetAuthentication();
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        //String SUBJECT;
        String propertyAddress;
        String danNo;
        system.debug(participants);
         List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJetZD');
          List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('InvitationtorespondtoclaimTT'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        case c =  (case) JSON.deserialize(caseJson, Case.class);
        system.debug(c);
        List<case_participant__c> ParticipantList =(List<case_participant__c>) JSON.deserialize(participants,List<case_participant__c>.class);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
        for(Case_Participant__c cp:ParticipantList)
        {
            toAddress = cp.Contact__r.Email;
            toName = cp.Contact__r.Name;
            gen.writeStartObject(); 
            gen.writeFieldName('From');
            
            gen.writeStartObject();
            gen.writeStringField('Email', fromAddress);
            gen.writeStringField('Name', fromName);
            gen.writeEndObject();
            
            gen.writeFieldName('To');
            
            gen.writeStartArray();
            gen.writeStartObject(); 
            gen.writeStringField('Email', toAddress); 
            gen.writeStringField('Name', toName);
            gen.writeEndObject();      
            gen.writeEndArray();
            
            gen.writeNumberField('TemplateID', mailJetTemplateId); 
            gen.writeBooleanField('TemplateLanguage', true);
            gen.writeStringField('Subject', SUBJECT); 
            
            gen.writeFieldName('Variables');       
            gen.writeStartObject();
            gen.writeStringField('tenant_name', toName); 
           // gen.writeStringField('PropertyName', c.Tenancy_Property_Address__c); 
           // gen.writeStringField('GuaranteeNo.', toName); 
            gen.writeEndObject(); 
            
            gen.writeEndObject(); 
        }
        try{
            
            gen.writeEndArray();
            gen.writeEndObject();
            jsonData =gen.getAsString();
            req.setBody(jsonData);
            Http http = new Http();
            HTTPResponse res = http.send(req); 
            system.debug('res-->>'+res.getBody());
        }
        catch(exception e){   
        }
        
    }
    
    @future(CallOut = true)
    public static void sendEmail(String subject, String recList,Map<String,String> variables,String template, String mailjet){
        
        String jsonData;
        HttpRequest req = mailJet_Authentication(mailjet);
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailjet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList(template); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
    	
        List<recipient> ParticipantList =(List<recipient>) JSON.deserialize(recList,List<recipient>.class);
        Map<String,recipient> recMap = new Map<String,recipient>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
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
                gen.writeStringField('Email', fromName);
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
            
            if(String.isNotBlank(SUBJECT)){
                gen.writeStringField('Email', SUBJECT);
            }
            
            gen.writeFieldName('Variables');    
             
            gen.writeStartObject();
            if(variables!=null){
                for(String key : variables.keySet()){
                    if( variables.get(key) !=null)
                        gen.writeStringField(key, variables.get(key)); 
                }
            }
            gen.writeStringField('name',toName);
            gen.writeEndObject(); 
            
            gen.writeEndObject(); 
        }
        try{
            
            gen.writeEndArray();
            gen.writeEndObject();
            jsonData =gen.getAsString();
            req.setBody(jsonData);
            //system.debug(jsonData);
            Http http = new Http();
            HTTPResponse res = http.send(req); 
            if(res.getStatusCode() == 200){
                 String resBody = res.getBody();
            if(!resBody.startsWith('[')){
                resBody = '['+resBody+']';
            }
            saveMessageDetails(resBody,recMap,Subject );
            }
           
            //system.debug('res-->>'+res.getBody());
        }
        catch(exception e){   
            //saveMessageDetails(resBody,recMap,Subject );
            system.debug(e);
            //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
        }
        
    }
    
    public class recipient{
        String Email;
        String name;
        String recId;
        public recipient(){}
        public recipient(String Email,String name,String recId){
            this.Name = name;
            this.Email = email;
            this.recId = recId;
            
        }
    }
    
    public static void saveErrorDetails(String recId,String error,String subject,String email){
        Mailjet_Message__c mm = new Mailjet_Message__c(response_status__c='Error',Subject__c=Subject,Record_ID__c=recId,
                                                       Error__c=error);
        insert mm;
    }
    
    public static void saveMessageDetails(String resJSON,Map<String,recipient> recMap, STring Subject){
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
        
        insert mailJetList;
    }
    
    public static HttpRequest mailJet_Authentication(String mailjet){
        List<API_Service__mdt> mailJetSettings = metaDataList(mailjet);
        
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
    
    public static List<API_Service__mdt> metaDataList(String metaDataLabel){
        List<API_Service__mdt> metaDataList = [SELECT EndPoint_URL__c, Username__c, Password__c, From_Name__c, From_Address__c,
                                               Template_Id__c, Scheme_Signatory__c, Scheme_Address__c,Scheme_Bank_Account_Number__c,
                                               Scheme_Sort_Code__c,Scheme_Bank_Name__c
                                               FROM API_Service__mdt 
                                               WHERE QualifiedApiName=:metaDataLabel];
        return metaDataList;
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
    
    @AuraEnabled
    public static list<Case_Participant__c> fetchCP(String caseId){
        list<Case_Participant__c> CP = [select id, Account__r.name, Account__r.PersonEmail from Case_Participant__c where Case__c=:caseId];
     	return CP;   
    }
    
    @AuraEnabled
    public static void sendEmailFromActivityTab(String caseId, String fromEmail, String to, String mailBody){
    	//Sent Mail by MailJet
    }
    
}