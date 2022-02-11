public class MailJetService {
    public MailJetService() {}
    
    @future(callout=true)
    public static void mailForTranferDeposit(Map<String,String> emailMembername,List<String> emailDetails){ 
        
        String fromAddress;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('TransferDepositToAnotherProperty');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        
        
        for(String key: emailDetails){
            list<string> flaglist = new list<string>();
            if(flaglist.size() > 0 &&  !(flaglist.contains(key))){
                gen.writeString(','); 
            }
            gen.writeStartObject(); 
            gen.writeFieldName('From');
            gen.writeStartObject();
            gen.writeStringField('Email', fromAddress);
            gen.writeStringField('Name', fromName);
            gen.writeEndObject();
            gen.writeFieldName('To');
            gen.writeStartArray();
            system.debug('@@tenemail '+ emailMembername.get(key));
            gen.writeStartObject(); 
            gen.writeStringField ('Email',  emailMembername.get(key));
            
            gen.writeEndObject();   
            gen.writeEndArray();
            
            String TDate = String.valueOf(System.today());
            /* Template for Tranfer Deposit to another property  
*/  
            
            gen.writeNumberField('TemplateID', mailJetTemplateId);
            gen.writeBooleanField('TemplateLanguage', true);
            gen.writeStringField('Subject', 'Deposit transfer to another property successfully');       
            gen.writeFieldName('Variables');       
            gen.writeStartObject(); 
            gen.writeStringField('date', TDate);
            gen.writeStringField('endUser', key);
            gen.writeEndObject();
            
            
            gen.writeEndObject(); 
            flaglist.add(key);
        }
        
        
        //     gen.writeEndObject(); 
        gen.writeEndArray(); 
        gen.writeEndObject(); 
        
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        
        
        
        
    }
    
    @future(callout=true)
    public static void mailTenantToAcceptChangeOver(Map<String,String> emailMembername,List<String> emailDetails, Map<String,String> tenentAmount,String DAN){ 
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        /*    String endpoint = 'https://api.mailjet.com/v3.1/send';
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setHeader('Content-Type','application/text'); 

String username = '149e22044add6860160c56c12a500708';
String password = '3bc9ecf441468a0dee61982308eb7fb7';

Blob headerValue = Blob.valueOf(username + ':' + password);
String authorizationHeader = 'Basic ' +
EncodingUtil.base64Encode(headerValue);

req.setHeader('Authorization', authorizationHeader);     */
        String fromAddress;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        //Integer mailJetTemplateIdTenant;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('TTChangeOverToTTtoAccept');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        
        
        for(String key: emailDetails){
            list<string> flaglist = new list<string>();
            if(flaglist.size() > 0 &&  !(flaglist.contains(key))){
                gen.writeString(','); 
            }
            gen.writeStartObject(); 
            gen.writeFieldName('From');
            gen.writeStartObject();
            gen.writeStringField('Email', 'ashish.singh1@espire.com');
            gen.writeStringField('Name', 'SDS');
            gen.writeEndObject();
            gen.writeFieldName('To');
            gen.writeStartArray();
            system.debug('@@tenemail '+ emailMembername.get(key));
            gen.writeStartObject(); 
            gen.writeStringField ('Email',  emailMembername.get(key));
            
            gen.writeEndObject();   
            gen.writeEndArray();
            
            String TDate = String.valueOf(System.today());
            /* Template for Tranfer Deposit to another property  
*/  
            
            gen.writeNumberField('TemplateID', mailJetTemplateId);
            gen.writeBooleanField('TemplateLanguage', true);
            gen.writeStringField('Subject', 'DAN '+DAN +' - Log in to agree or disagree with the tenant changeover request');       
            gen.writeFieldName('Variables');       
            gen.writeStartObject(); 
            gen.writeStringField('TenantName', key);
            gen.writeStringField('Amount', tenentAmount.get(key));
            gen.writeStringField('Today', TDate);
            gen.writeStringField('DAN', DAN);
            gen.writeEndObject();
            
            
            gen.writeEndObject(); 
            flaglist.add(key);
        }
        
        
        //     gen.writeEndObject(); 
        gen.writeEndArray(); 
        gen.writeEndObject(); 
        
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        
        
        
        
    }
    
    @future(callout=true)
    public static void mailTenentChangeOver(Map<String,String> emailMembername,List<String> emailDetails, String Status,string caseid){ 
        
        /*  HttpRequest req = new HttpRequest();
String endpoint = 'https://api.mailjet.com/v3.1/send';
req.setEndpoint(endpoint);
req.setMethod('POST');
req.setHeader('Content-Type','application/text'); 

String username = '149e22044add6860160c56c12a500708';
String password = '3bc9ecf441468a0dee61982308eb7fb7';

Blob headerValue = Blob.valueOf(username + ':' + password);
String authorizationHeader = 'Basic ' +
EncodingUtil.base64Encode(headerValue);

req.setHeader('Authorization', authorizationHeader);    */
        
        String fromAddress;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateIdAgentReject;
        Integer mailJetTemplateIdTenantReject;
        Integer mailJetTemplateIdTenantInitiate;
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateIdInitiate = EI_CustomMetadataUtility.metaDataList('TenantChangeOverInitiateToAAnTT');    
        List<API_Service__mdt> templateIdAgentReject = EI_CustomMetadataUtility.metaDataList('TTChangeOverRejectedToAA');  
        List<API_Service__mdt> templateIdTenantReject = EI_CustomMetadataUtility.metaDataList('TTChangeOverRejectedToTenant');  
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateIdAgentReject  = Integer.valueof(templateIdAgentReject[0].Template_Id__c);
        mailJetTemplateIdTenantInitiate  = Integer.valueof(templateIdInitiate[0].Template_Id__c);
        mailJetTemplateIdTenantReject  = Integer.valueof(templateIdTenantReject[0].Template_Id__c);
        SchemeSignatory = templateIdAgentReject[0].Scheme_Signatory__c;
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        
        
        for(String key: emailDetails){
            list<string> flaglist = new list<string>();
            if(flaglist.size() > 0 &&  !(flaglist.contains(key))){
                gen.writeString(','); 
            }
            gen.writeStartObject(); 
            gen.writeFieldName('From');
            gen.writeStartObject();
            gen.writeStringField('Email', 'ashish.singh1@espire.com');
            gen.writeStringField('Name', 'SDS');
            gen.writeEndObject();
            gen.writeFieldName('To');
            gen.writeStartArray();
            system.debug('@@tenemail '+ emailMembername.get(key));
            gen.writeStartObject(); 
            gen.writeStringField ('Email',  emailMembername.get(key));
            
            gen.writeEndObject();   
            gen.writeEndArray();
            
            String TDate = String.valueOf(System.today());
            /* Template for Tranfer Deposit to another property  
*/  
            if(Status == 'Agent Rejected'){
                gen.writeNumberField('TemplateID', mailJetTemplateIdAgentReject);
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', 'Agent Rejected Tenant ChangeOver');       
                gen.writeFieldName('Variables');       
                gen.writeStartObject(); 
                gen.writeStringField('date', TDate);
                gen.writeStringField('endUser', key);
                gen.writeEndObject();
                
            }
            else if(Status =='Tenant Initiate'){
                gen.writeNumberField('TemplateID', mailJetTemplateIdTenantInitiate);
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', 'Tenant Change Over Inititated');        
                gen.writeFieldName('Variables');       
                gen.writeStartObject(); 
                gen.writeStringField('date', TDate);
                gen.writeStringField('endUser', key);
                gen.writeEndObject();
            }
            else{
                gen.writeNumberField('TemplateID', mailJetTemplateIdTenantReject);
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', 'Tenant Rejected ChangeOver');        
                gen.writeFieldName('Variables');       
                gen.writeStartObject(); 
                gen.writeStringField('date', TDate);
                gen.writeStringField('endUser', key);
                gen.writeEndObject();
            }
            gen.writeEndObject(); 
            flaglist.add(key);
        }
        
        
        //     gen.writeEndObject(); 
        gen.writeEndArray(); 
        gen.writeEndObject(); 
        
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    
    @future(callout=true)
    public static void mailService(String Dan, List<String> tenantEmail){ 
        
        API_Service__mdt threatMappings = [SELECT MasterLabel, EndPoint_URL__c, Username__c ,Password__c FROM API_Service__mdt where MasterLabel = 'MailJet'];
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
        system.debug('@@tenemail '+tenantEmail);
        for(integer i = 0;i<tenantEmail.size();i++){
            system.debug('@@tenemail '+tenantEmail[i]);
            gen.writeStartObject(); 
            gen.writeStringField ('Email', tenantEmail[i]);
            //gen.writeStringField('Name', 'Tajinder1');
            gen.writeEndObject();     
        }        
        gen.writeEndArray();
        
        
        String TDate = String.valueOf(System.today());
        /* Template for Tranfer Deposit to another property  
*/  
        gen.writeNumberField('TemplateID', 2352448);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Transfer deposit to another property');        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Date', TDate);
        gen.writeStringField('DAN', Dan);
        
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
    
    public static EI_SDS_MailJetUtilityCls.EmailWrapper mailfortransferdeposittenant(string userpersonemail,string username,string OLDDAN,String NEWDAN, 
		String OLDAddress,String NEWAddress,string tenantid, String contactId) 
    {
        String fromAddress;
        String toName;
        string toAddress;
        // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Changes to your deposit '+NEWAddress;
        toName =username;
        toAddress = userpersonemail;   
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, tenantid, contactId));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('Date', todayStr);
        variableMap.put('Tenant_name', username);
        variableMap.put('DAN', OLDDAN);
        variableMap.put('Old_Property_Address', OLDAddress);
        variableMap.put('New_Property_Address', NEWAddress);
        variableMap.put('New_DAN', NEWDAN);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'Deposittransfrertopropertymailtenant', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
    }
    
    public static EI_SDS_MailJetUtilityCls.EmailWrapper mailfortransferdepositagentlandlord(String useremail, String userpersonemail, String username, 
		String OLDDAN, String NEWDAN, String OLDAddress, String NEWAddress, String customerid, String contactId) 
    {
        String fromAddress;
        String toName;
        String toAddress;
     	//  String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Changes to your deposit  '+NEWAddress;
        toName =username;
        if(userpersonemail!=null){
            toAddress = userpersonemail;
        }
        else{
            toAddress = useremail;   
        }
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, '', customerid,contactId));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('date', todayStr);
        variableMap.put('endUser', username);
        variableMap.put('original_address', OLDAddress);
        variableMap.put('new_address', NEWAddress);
        variableMap.put('Old_DAN', OLDDAN);
        variableMap.put('New_DAN', NEWDAN);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'Deposittransfrertopropertymailagent', emailsubject);    
		/* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
    }
    
    public static EI_SDS_MailJetUtilityCls.EmailWrapper changeOverRejectedbyAGLLToCustomer(string useremail, string username, 
                                                                                           String propaddress, string caseid,string customerid)
    {
        String fromAddress;
        String toName;
        String toAddress;
        //  String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover rejected-'+propaddress;
        toName =username;
        toAddress = useremail;
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, customerid));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('date', todayStr);
        variableMap.put('endUser', username);
        variableMap.put('Address', propaddress);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'ChangeOverRejectedbyAGLLToCustomer', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
        
    }
    
    public static EI_SDS_MailJetUtilityCls.EmailWrapper ChangeOverRejectedbyAGLLToStayedTenants(String useremail, String username, 
                                                                                                String propaddress, String caseid, string contactid) 
    {
        String fromAddress;
        String toName;
        String toAddress;
        // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover rejected-'+propaddress;
        toName =username;
        toAddress = useremail;  
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, contactid));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('date', todayStr);
        variableMap.put('endUser', username);
        variableMap.put('Tenancy_Address', propaddress);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'ChangeOverRejectedbyAGLLToStayedTenants', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */        
        
        return EmailWrapper;
        
    }
    
    public static EI_SDS_MailJetUtilityCls.EmailWrapper ChangeOverRejectedbyAGLLToMoveoutTenants(String useremail, String username, 
                                                                                                 String propaddress, String caseid, string contactid) 
    {
        String fromAddress;
        String toName;
        String toAddress;
        //String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover rejected-'+propaddress;
        toName =username;
        toAddress = useremail;   
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, contactid));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('date', todayStr);
        variableMap.put('endUser', username);
        variableMap.put('Tenancy_Address', propaddress);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'ChangeOverRejectedbyAGLLToMoveoutTenants', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
        
    }
    
    // Tenant initiated changeover mail to customer
    public static EI_SDS_MailJetUtilityCls.EmailWrapper ChangeOverInitiatedByTenantToCustomer
        (String useremail, String personemail, String username, String dannumber, String propaddress, String changeoverdetails,string caseid,string customerid) 
    {
        String fromAddress;
        String toName;
        String toAddress;
        //String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover initiated by tenant-'+propaddress;
        toName =username;
        if(useremail!=null){
            toAddress = useremail; }
        else{
            toAddress = personemail;
        }
		        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, customerid));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('Date', todayStr);
        variableMap.put('name', username);
        variableMap.put('DAN', dannumber);
        variableMap.put('Address', propaddress);
        variableMap.put('Tenant_changeover_details', changeoverdetails);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'ChangeOverInitiatedByTenantToCustomer', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
        
    }
    
    // Tenant initiated changeover mail to stayed tenant
    public static EI_SDS_MailJetUtilityCls.EmailWrapper ChangeOverInitiatedByTenantTostayedTennt(String personemail, String username, 
                                                                                                 String dannumber, String propaddress, 
                                                                                                 String changeoverdetails, String caseid,string contactid) 
    {
        String fromAddress;
        String toName;
        string toAddress;
        //  String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover initiated by tenant-'+propaddress;
        toName =username;
        toAddress = personemail;
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, contactid));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('Date', todayStr);
        variableMap.put('name', username);
        variableMap.put('DAN', dannumber);
        variableMap.put('Address', propaddress);
        variableMap.put('Tenant_changeover_details', changeoverdetails);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'ChangeOverInitiatedByTenantTostayedTennt', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
        
    }
    
    // Tenant initiated changeover mail to moved out tenant
    public static EI_SDS_MailJetUtilityCls.EmailWrapper ChangeOverInitiatedByTenantToMovingTennt(String personemail, String username, 
                                                                                                 String dannumber, String propaddress, 
                                                                                                 String changeoverdetails, String caseid,string contactid) 
    {
        String fromAddress;
        String toName;
        string toAddress;
        //String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Tenant changeover initiated by tenant-'+propaddress;
        toName =username;
        toAddress = personemail;
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, caseid, contactid));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('Date', todayStr);
        variableMap.put('name', username);
        variableMap.put('DAN', dannumber);
        variableMap.put('Address', propaddress);
        variableMap.put('Tenant_changeover_details', changeoverdetails);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'ChangeOverInitiatedByTenantToMovingTennt', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
        
    }
    
}