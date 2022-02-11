public class EmailMailJetService {
    
    public EmailMailJetService() {}
    
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> sendRepReqEmailsTenantInitiated 
        (Id repaymentRecordId, String depositId, Date tenancyDate, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) 
    {
        String fromAddress,fromName;
        Decimal totalTenantAmount=0.0,depositRepaidAgent=0.0;
        String tenantNameAmount='';
        Integer mailJetTemplateId;
        
        String jsonData;
        String TDate = String.valueOf(System.today().format());
        
        
        for(Repayment_Request_Line__c repayRequestLine : [SELECT id,Is_Lead__c, Account__r.Name,Account__r.PersonEmail,Repayment_Request__c,
                                Tenant_ReqAmt__c,Repayment_Request__r.Deposit__r.Name,Repayment_Request__r.Deposit__r.Property_Address__c,
                                Account__r.RecordType.Name from Repayment_Request_Line__c where Repayment_Request__c =:repaymentRecordId]) 
        {
            if(Label.Tenant.equalsIgnorecase(repayRequestLine.Account__r.RecordType.Name)) {
                tenantNameAmount = repayRequestLine.Account__r.Name+' : <b>'+repayRequestLine.Tenant_ReqAmt__c+'</b>\n';
                totalTenantAmount = totalTenantAmount+repayRequestLine.Tenant_ReqAmt__c;
            }
            else {
                depositRepaidAgent = repayRequestLine.Tenant_ReqAmt__c;
            }
        }
        
        for(Repayment_Request_Line__c repaymentRequestLine : 
            [SELECT id, Is_Lead__c, Account__r.Name, Account__r.PersonEmail, Account__r.personContactId, Repayment_Request__c,
             Tenant_ReqAmt__c,Repayment_Request__r.Deposit__r.Name,Repayment_Request__r.Deposit__r.Property_Address__c,
             Account__r.RecordType.Name,Repayment_Request__r.Deposit__r.Protected_Amount__c,Account__r.Email__c, 
             Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c,Repayment_Request__r.Deposit__c, Type__c from Repayment_Request_Line__c 
             where Repayment_Request__c =:repaymentRecordId /*and Account__r.RecordType.Name!=:Label.Tenant*/]) 
        {
            Date responseDate = EI_UtilityClassForPayments.dueDateMethod(System.today(), 30);
            String responseDateStr = responseDate.day()+'/'+responseDate.month()+'/'+responseDate.year();
            
            if(repaymentRequestLine.Type__c.equalsIgnorecase('Tenant')) {
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentRequestLine.Account__r.PersonEmail, 
                                                                              repaymentRequestLine.Account__r.Name, 
                                                                              repaymentRequestLine.Repayment_Request__r.Deposit__c, 
                                                                              repaymentRequestLine.Account__r.personContactId));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('tenantName', repaymentRequestLine.Account__r.Name);
                variableMap.put('DAN', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
                variableMap.put('responseDate', responseDateStr);
                //variableMap.put('repaymentRequestDetails', ''));
                
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'TenantProposalToTenants', 
                                                                               'Confirmation of repayment request - '
                                                                               +repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                              ));
                /* Newly added code for adding recipients, variables, template name, Subject END */
            } 
            else {
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentRequestLine.Account__r.PersonEmail, 
                                                                              repaymentRequestLine.Account__r.Name, 
                                                                              repaymentRequestLine.Repayment_Request__r.Deposit__c, 
                                                                              repaymentRequestLine.Account__r.personContactId));
                Date todaydate = System.today(); 
                string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', tdstr);
                variableMap.put('customer', repaymentRequestLine.Account__r.Name);
                variableMap.put('propertyaddress', repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
                variableMap.put('DAN', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
                variableMap.put('proposalDetails', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
                variableMap.put('responseDate', responseDateStr);
                variableMap.put('linkToLoginPage', 'https://staging-thedisputeservice.cs122.force.com/Sds/s/login/');
                
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'TenantProposalToAgentLandlord', 
                                                                               'Deposit repayment request - response required - '
                                                                               +repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                              ));
                /* Newly added code for adding recipients, variables, template name, Subject END */
            }
            
        }
        
        Deposit__c deposit = new Deposit__c(id=depositId);
        deposit.Status__c = Label.Repayment_requested_by_tenant;
        deposit.Tenancy_End_Date_TT__c = tenancyDate;
        update deposit;
        
        return emailWrapperList;
    }
    
    //@future(callout=true)
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> sendTenantProposalToAgentLandlord 
        (Id repaymentRecordId, String depositId, Date tenancyDate, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) 
    {
        String fromAddress,fromName;
        Decimal totalTenantAmount=0.0,depositRepaidAgent=0.0;
        String tenantNameAmount='';
        Integer mailJetTemplateId;
        
        String jsonData;
        String TDate = String.valueOf(System.today().format());
        
        
        for(Repayment_Request_Line__c repayRequestLine : [SELECT id,Is_Lead__c, Account__r.Name,Account__r.PersonEmail,Repayment_Request__c,
                                Tenant_ReqAmt__c,Repayment_Request__r.Deposit__r.Name,Repayment_Request__r.Deposit__r.Property_Address__c,
                                Account__r.RecordType.Name from Repayment_Request_Line__c where Repayment_Request__c =:repaymentRecordId]) 
        {
            if(Label.Tenant.equalsIgnorecase(repayRequestLine.Account__r.RecordType.Name)) {
                tenantNameAmount = repayRequestLine.Account__r.Name+' : <b>'+repayRequestLine.Tenant_ReqAmt__c+'</b>\n';
                totalTenantAmount = totalTenantAmount+repayRequestLine.Tenant_ReqAmt__c;
            }
            else {
                depositRepaidAgent = repayRequestLine.Tenant_ReqAmt__c;
            }
        }
        
        for(Repayment_Request_Line__c repaymentRequestLine : 
            [SELECT id,Is_Lead__c, Account__r.Name,Account__r.PersonEmail,Account__r.personContactId,Repayment_Request__c,
             Tenant_ReqAmt__c,Repayment_Request__r.Deposit__r.Name,Repayment_Request__r.Deposit__r.Property_Address__c,
             Account__r.RecordType.Name,Repayment_Request__r.Deposit__r.Protected_Amount__c,Account__r.Email__c, 
             Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c,Repayment_Request__r.Deposit__c, Type__c from Repayment_Request_Line__c 
             where Repayment_Request__c =:repaymentRecordId and Account__r.RecordType.Name!=:Label.Tenant]) 
        {
            
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentRequestLine.Account__r.PersonEmail, 
                                                                          repaymentRequestLine.Account__r.Name, 
                                                                          repaymentRequestLine.Repayment_Request__r.Deposit__c, repaymentRequestLine.Account__r.personContactId));
			
            Map<String, String> variableMap = new Map<String, String>();
            Date todayDate = System.today();
            String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
            Date responseDate = EI_UtilityClassForPayments.dueDateMethod(System.today(), 30);
            String responseDateStr = responseDate.day()+'/'+responseDate.month()+'/'+responseDate.year();
            
            variableMap.put('date', todayStr);
            variableMap.put('customer', repaymentRequestLine.Account__r.Name);
            variableMap.put('propertyaddress', repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c);
            variableMap.put('DAN', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
            variableMap.put('proposalDetails', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
            variableMap.put('responseDate', responseDateStr);
            variableMap.put('linkToLoginPage', 'https://staging-thedisputeservice.cs122.force.com/Sds/s/login/');
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'TenantProposalToAgentLandlord', 
                                                                           'Deposit repayment request - response required - '
                                                                           +repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                          ));
            /* Newly added code for adding recipients, variables, template name, Subject END */
            
        }
        
        Deposit__c deposit = new Deposit__c(id=depositId);
        deposit.Status__c = Label.Repayment_requested_by_tenant;
        deposit.Tenancy_End_Date_TT__c = tenancyDate;
        update deposit;
        
        return emailWrapperList;
    }
    
    //@future(callout=true)
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> sendTenantProposalToTenants
        (String repaymentRecordId, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList) 
    {
        String fromAddress,fromName;
        Decimal totalTenantAmount=0.0,depositRepaidAgent=0.0;
        String tenantNameAmount='';
        Integer mailJetTemplateId;
        
        for(Repayment_Request_Line__c repayRequestLine : 
            [SELECT id,Is_Lead__c, Account__r.Name,Account__r.PersonEmail, Repayment_Request__c,Repayment_Request__r.Deposit__c,
             Tenant_ReqAmt__c,Repayment_Request__r.Deposit__r.Name,Repayment_Request__r.Deposit__r.Property_Address__c,
             Account__r.RecordType.Name from Repayment_Request_Line__c where Repayment_Request__c =:repaymentRecordId]) 
        {
            if(Label.Tenant.equalsIgnorecase(repayRequestLine.Account__r.RecordType.Name)) {
                tenantNameAmount = repayRequestLine.Account__r.Name+' : <b>'+repayRequestLine.Tenant_ReqAmt__c+'</b>\n';
                totalTenantAmount = totalTenantAmount+repayRequestLine.Tenant_ReqAmt__c;
            }
            else {
                depositRepaidAgent = repayRequestLine.Tenant_ReqAmt__c;
            }
        }
        
        for(Repayment_Request_Line__c repaymentRequestLine : 
            [SELECT id,Is_Lead__c, Account__r.Name,Account__r.PersonEmail, Account__r.personContactId, Repayment_Request__c,
             Tenant_ReqAmt__c,Repayment_Request__r.Deposit__r.Name,Repayment_Request__r.Deposit__r.Property_Address__c,
             Account__r.RecordType.Name,Repayment_Request__r.Deposit__r.Protected_Amount__c, 
             Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c from Repayment_Request_Line__c 
             where Repayment_Request__c =:repaymentRecordId and Account__r.RecordType.Name=:Label.Tenant]) 
        {
			/* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentRequestLine.Account__r.PersonEmail, 
                                                                          repaymentRequestLine.Account__r.Name, 
                                                                          repaymentRequestLine.Repayment_Request__r.Deposit__c, repaymentRequestLine.Account__r.personContactId));
            Map<String, String> variableMap = new Map<String, String>();
            Date responseDate = EI_UtilityClassForPayments.dueDateMethod(System.today(), 30);
            String responseDateStr = responseDate.day()+'/'+responseDate.month()+'/'+responseDate.year();
            
            variableMap.put('tenantName', repaymentRequestLine.Account__r.Name);
            variableMap.put('DAN', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
            variableMap.put('responseDate', responseDateStr);
            //variableMap.put('repaymentRequestDetails', ''));
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'TenantProposalToTenants', 
                                                                           'Confirmation of repayment request - '
                                                                           +repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c
                                                                          ));
            /* Newly added code for adding recipients, variables, template name, Subject END */
        }
        
        return emailWrapperList;
        
    }
    
    // @future(callout=true)
    // public static void singleDepositTransferToCustomer(String landlordAgentEmail, String landlordAgentName , String DAN,
    //        String propAddress, String schemeName , String customerName) {
    public static EI_SDS_MailJetUtilityCls.EmailWrapper singleDepositTransferToCustomer(String landlordAgentEmail, String landlordAgentName , String DAN,
                                                        String propAddress, String schemeName , String customerName,string customerid, string depositId) 
    {                                         
        
        String fromAddress;
        String toName;
        string toAddress;
        // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Request to accept deposit transfer';
        // customerName;
        toName =landlordAgentName;
        toAddress = landlordAgentEmail; 
        
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositId,customerid));
        Map<String, String> variableMap = new Map<String, String>(); 
        variableMap.put('Date', todayStr);
       // variableMap.put('name', landlordAgentName);
        variableMap.put('Name', toName);
        // variableMap.put('DAN', DAN);                                                    
        variableMap.put('PropertyAddress', propAddress);
        variableMap.put('customerName', customerName);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'SingleDepositTransfer', emailsubject);                                                          
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;                                                     
    }
    
    // @future(callout=true)
    // public static void multipleDepositTransferToCustomer(String landlordAgentEmail, String landlordAgentName ,
                                                      //  String schemeName , String customerName ,Integer transferSize){
      
	public static EI_SDS_MailJetUtilityCls.EmailWrapper multipleDepositTransferToCustomer(String landlordAgentEmail, String landlordAgentName ,
                                                       String schemeName , String customerName ,Integer transferSize,string customerid,string depositid) 
    {   
        
        String fromAddress;
        String toName;
        string toAddress;
        // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Request to accept deposit transfer';
        toName =customerName;
        toAddress = landlordAgentEmail;
        
        Date todaydate = System.today(); 
        string todayStr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, customerid));
        Map<String, String> variableMap = new Map<String, String>(); 
        variableMap.put('Date', todayStr);
        variableMap.put('Name', landlordAgentName);
        // variableMap.put('DAN', DAN);                                                    
        variableMap.put('NoOfProperties', String.valueof(transferSize));
        variableMap.put('customerName', customerName);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'MultipleDepositTransfer', emailsubject);                                                     
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;                                                     
    }
    
    //  @future(callout=true)
    //  public static void rejectTransfers(String customerEmail, String customerName , String DAN
    //                                                      , String recievingName,String propAddress, String schemeName ){
    
    // @future(callout=true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper rejectTransfers(String useremail,String personemail,String customerName , String DAN,
                                                                         String propAddress, String sendername, String customerid,string depositid) 
    {
        String fromAddress;
        String toName;
        string toAddress;
        // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit transfer cancelled' ;
        toName =customerName;
        if(useremail!=null){                                                     
            toAddress = useremail; 
        }
        else{
            toAddress = personemail;                                                        
        }
        Date todaydate = System.today(); 
        string todayStr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, customerid));
        Map<String, String> variableMap = new Map<String, String>(); 
        variableMap.put('Date', todayStr);
        variableMap.put('name', customerName);
        variableMap.put('DAN', DAN);
        variableMap.put('Address', propAddress);
        variableMap.put('Sending_Customer_Name', sendername);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'RejectTransfers', emailsubject);
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;                                                      
    }
    

    // @future(callout=true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper rejectTransfersmailtosender(String useremail, String customerName, String DAN,
                                                        String propAddress, String sendername, String schemename, String customerid, String depositid ) 
    {  
        String fromAddress;
        String toName;
        string toAddress;
        // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        String emailsubject = 'Deposit transfer cancelled' ;
        toName =customerName;                                                    
        toAddress = useremail;

        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, customerid));
        Map<String, String> variableMap = new Map<String, String>();
        Date todaydate = System.today();
        String todayStr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        
        variableMap.put('Date', todayStr);
        variableMap.put('name', customerName);
        variableMap.put('DAN', DAN);
        variableMap.put('Address', propAddress);
        variableMap.put('receivingCustomer', sendername);
        variableMap.put('scheme', schemename);
        
        EI_SDS_MailJetUtilityCls.EmailWrapper emailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'RejectTransferstotranferee', emailsubject);  
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return emailWrapper;                                                      
    }    
    
    
    @future(callout=true)
    public static void formerCustomerEmail(String customerEmail, String customerName , String DAN, 
                                           String recievingName,String propAddress ) 
    {
        String fromAddress;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        
        String jsonData;
        String TDate = String.valueOf(System.today().format());
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('FormerCustomerMail');             
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', fromAddress);
        gen.writeStringField('Name', fromName);
        gen.writeEndObject();

        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('Email', customerEmail);
        gen.writeStringField('Name', customerName);
        gen.writeEndObject(); 
        gen.writeEndArray();
        gen.writeNumberField('TemplateID', mailJetTemplateId);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Reference: '+DAN+' Confirmation of transfer to another landlord/agent');        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Date', TDate);
        gen.writeStringField('name', customerName);
        gen.writeStringField('DAN', DAN);
        gen.writeStringField('Address', propAddress);
        gen.writeStringField('newCustomer', recievingName);
        gen.writeStringField('schemeSignature', SchemeSignatory);
        
        gen.writeEndObject();
        gen.writeEndObject(); 
        gen.writeEndArray(); 
        gen.writeEndObject(); 


        jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);

        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    @future(callout=true)
    public static void newCustomerEmail(String customerEmail, String customerName , String DAN, 
                                        String formerName,String propAddress , String schemeName) 
    {
        String fromAddress;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        
        String jsonData;
        String TDate = String.valueOf(System.today().format());
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('NewCustomerMail');            
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', fromAddress);
        gen.writeStringField('Name', fromName);
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('Email', customerEmail);
        gen.writeStringField('Name', customerName);
        gen.writeEndObject(); 
        gen.writeEndArray();
        gen.writeNumberField('TemplateID', mailJetTemplateId);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Reference: '+DAN+' Deposit transfer accepted');        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('Date', TDate);
        gen.writeStringField('name', customerName);
        gen.writeStringField('DAN', DAN);
        gen.writeStringField('Address', propAddress);
        gen.writeStringField('formerCustomer', formerName);
        gen.writeStringField('Scheme', schemeName);
        gen.writeStringField('schemeSignature', SchemeSignatory);
        
        gen.writeEndObject();
        gen.writeEndObject(); 
        gen.writeEndArray(); 
        gen.writeEndObject(); 
        
        jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    
    //@future(callout = true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper DepositTransfertoAGLLMailToTransferee(String useremail, String transfereename, String receivinguser, 
                                                                                              String propertyaddress, String customerid, String depositid) 
    {
        String fromAddress;
        String toName;
        string toAddress;
        // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit transfer request received';
        toName = transfereename;
        toAddress = useremail;
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, customerid));
        Map<String, String> variableMap = new Map<String, String>();
        Date todaydate = System.today(); 
        String todayStr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        
        variableMap.put('date', todayStr);
        variableMap.put('name', transfereename);
        variableMap.put('Transfer_Property_Address', propertyaddress);
        variableMap.put('Receiving_User', receivinguser);
        //variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'DepositTransferToAGLLMailToTransferee', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return EmailWrapper;
    }
    
}