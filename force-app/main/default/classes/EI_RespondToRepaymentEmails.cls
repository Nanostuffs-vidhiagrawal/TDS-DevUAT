public class EI_RespondToRepaymentEmails {
    
    public static String fromAddress;
    public static  String fromName;
    public static  String toAddress;
    public static  String toName;
    public static  Integer mailJetTemplateId;
    public static  String propertyAddress;
    public static  Decimal amount;
    public static  String bankAccountName;
    public static  String schemeSignatory;
    public static  Integer daysRemaining;
    public static  String schemeAddress;
    public static  String danNo;
    public static  String sortCode;
    public static  String accountNumber;
    
    //@future(Callout=true)
    public static List<EI_SDS_MailJetUtilityCls.EmailWrapper> ConfirmationWithBankdetailssendEmail
        (String DepositId, Date TenancyEndDate, List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList)
    {
        
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        System.debug('TenancyEndDate - '+TenancyEndDate+' - DepositId - '+DepositId);
        Deposit__c depositdetails =[Select id, Name, Customer__c, End_Date__c, CreatedById, 
                                    Property__c,Deposit_Account_Number__c, Customer__r.Salutation, Customer__r.Name ,
                                    Customer__r.Phone, Customer__r.PersonEmail, Property_Address__c, Start_Date__c,
                                    Rent_Amount__c, Deposit_Amount__c, Date_Deposit_Received__c, CreatedBy.Name,
                                    Amount_of_Deposit_Protected_by_TDS__c, Status__c, CreatedBy.Email, CreatedBy.ContactId, 
                                    CreatedBy.profile.UserLicense.Name, Property_Address_WO_Country__c, 
                                    (Select id, Deposit__c, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail,Is_Lead__c, Contact__c, 
                                     Deposit_Holder__r.IsPersonAccount, Deposit_Holder__r.Bank_Acc_Count__c 
                                     from Deposit_Allocations__r)
                                    from Deposit__c where id=:DepositId limit 1];
        System.debug('depositdetails'+depositdetails);
        
        //String SUBJECT = 'Reference: '+depositdetails.Deposit_Account_Number__c +' Confirmation of agent/landlord’s agreement to repayment request ';
        String SUBJECT = 'Deposit repayment agreed - '+depositdetails.Property_Address__c;
     
     	/* Agreement of Repayment Request by AGLL initiated by tenant - Emails to AGLL */
        if(depositdetails.CreatedBy.profile.UserLicense.Name !='Salesforce')
        {
            
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(depositdetails.CreatedBy.Email, depositdetails.CreatedBy.Name, 
                                                                          depositdetails.Id, depositdetails.CreatedBy.ContactId));
            Map<String, String> variableMap = new Map<String, String>();
            Date deadlineDate = EI_UtilityClassForPayments.dueDateMethod(System.today(), 5);
            String deadlineDateStr = deadlineDate.day()+'/'+deadlineDate.month()+'/'+deadlineDate.year();
            
            variableMap.put('Date', todayStr);
            variableMap.put('name', depositdetails.CreatedBy.Name);
            variableMap.put('DAN', string.valueof(depositdetails.Deposit_Account_Number__c));
            variableMap.put('Address', string.valueof(depositdetails.Property_Address__c ));
            //variableMap.put('agreed_amounts', '');
            variableMap.put('deadline_date', deadlineDateStr);
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'ConfirmationOfAgent_landlordAgreement', 
                                                                           'Deposit repayment agreed - '
                                                                           +depositdetails.Property_Address_WO_Country__c));
            
            /* Newly added code for adding recipients, variables, template name, Subject END */
        } 
        
        /* Agreement of Repayment Request by AGLL initiated by tenant - Emails to tenants */
        for(Deposit_Allocation__c d:depositdetails.Deposit_Allocations__r) {
            
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList1 = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList1.add(new EI_SDS_MailJetUtilityCls.recipient(d.Deposit_Holder__r.PersonEmail, d.Deposit_Holder__r.Name, 
                                                                           d.Deposit__c, d.Contact__c));
            Map<String, String> variableMap1 = new Map<String, String>();
            
            variableMap1.put('Date', todayStr);
            variableMap1.put('name', depositdetails.CreatedBy.Name);
            variableMap1.put('DAN', string.valueof(depositdetails.Deposit_Account_Number__c));
            variableMap1.put('Address', string.valueof(depositdetails.Property_Address_WO_Country__c));
            //variableMap1.put('agreed_amounts', '');
            variableMap1.put('passwordResetLink', 'https://staging-thedisputeservice.cs122.force.com/Sds/s/login/ForgotPassword');
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList1), variableMap1, 
                                                                           'ConfirmationOfTenantAgreement', 
                                                                           depositdetails.Deposit_Account_Number__c+', '
                                                                           +depositdetails.Property_Address_WO_Country__c+', '+
                                                                           ''
                                                                          ));
            /* Newly added code for adding recipients, variables, template name, Subject END */
            
        }
        
        List<Repayment_Request_Line__c> repReq = new List<Repayment_Request_Line__c>();
        repReq = [Select Id, Account__c, Account__r.RecordType.Name, Account__r.Bank_Acc_Count__c, Tenant_ReqAmt__c, Account__r.PersonEmail, 
                  Account__r.Name, Repayment_Request__r.Case__c from Repayment_Request_Line__c 
                  where Repayment_Request__r.Status__c = 'Approved By Agent/Landlord' and Repayment_Request__r.Deposit__c=:DepositId 
                  and Account__r.RecordType.Name='Tenant' and Account__r.Bank_Acc_Count__c=0];
        System.debug('Line 164 repReq - '+repReq);
        
        
        /* Bank details missing for tenants - Emails to tenants */
        for(Repayment_Request_Line__c rrl:repReq) {
            
            System.debug('Line 166 mail');
            
            toAddress = rrl.Account__r.PersonEmail;
            toName = rrl.Account__r.Name ;
            propertyAddress = depositdetails.Property_Address__c;
            danNo = depositdetails.Deposit_Account_Number__c; 
            decimal diffrenceinAmount = rrl.Tenant_ReqAmt__c;       
            System.debug('toName '+toName);
            System.debug('toAddress '+toAddress);
            System.debug('propertyAddress '+propertyAddress);
            System.debug('danNo '+danNo);
            System.debug('diffrenceinAmount '+diffrenceinAmount);
            System.debug('mailJetTemplateId '+mailJetTemplateId);
            System.debug('schemeSignatory '+schemeSignatory);
            
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, rrl.Repayment_Request__r.Case__c, rrl.Account__c));
            
            Map<String, String> variableMap = new Map<String, String>();
            
            variableMap.put('date', todayStr);
            variableMap.put('name', toName);
            variableMap.put('amount', string.valueOf(diffrenceinAmount));
            variableMap.put('DAN', danNo);
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'BankDetailMissingForTenants', 
                                                                           'amount due to '+toName+', '+danNo
                                                                           ));
            
            /* Newly added code for adding recipients, variables, template name, Subject END */
            
        }
        
        return emailWrapperList;
        
    }
    
    /* Currently not in use */
    public void ConfirmationWithoutBankdetailssendEmail( String DepositId, Repayment_Request__c TenantDetails, Decimal Amount, Date TenancyEndDate)
    {
        Deposit__c depositdetails =[select id,name,customer__c,End_Date__c,
                                    Property__c,Deposit_Account_Number__c,customer__r.Salutation, customer__r.Name ,
                                    customer__r.Phone, customer__r.PersonEmail,Property_Address__c,Start_Date__c,
                                    Rent_Amount__c,Deposit_Amount__c,Date_Deposit_Received__c,CreatedBy.Name,
                                    Amount_of_Deposit_Protected_by_TDS__c,Status__c,CreatedBy.Email, 
                                    CreatedBy.profile.UserLicense.Name,
                                    (select id,Deposit_Holder__r.Name,Deposit_Holder__r.PersonEmail,Is_Lead__c 
                                     from Deposit_Allocations__r)
                                    from Deposit__c
                                    where id=:DepositId]; 
        
        String SUBJECT = 'Reference: '+depositdetails.Deposit_Account_Number__c +' Confirmation of agent/landlord’s agreement to repayment request ';
        String jsonData;
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('BankDetailMissing'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        schemeSignatory = templateId[0].Scheme_Signatory__c;
        schemeAddress = templateId[0].Scheme_Address__c;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
        list<string> flaglist = new list<string>(); 
        
        
        toAddress = TenantDetails.Repayment_Request_Lines__r[0].Account__r.PersonEmail;
        toName = TenantDetails.Repayment_Request_Lines__r[0].Account__r.Name;
        propertyAddress = depositdetails.Property_Address__c;
        danNo = depositdetails.Deposit_Account_Number__c;           
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
        gen.writeStringField('Subject',SUBJECT ); 
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();
        gen.writeStringField('name', toName); 
        gen.writeStringField('amount',string.valueOf(Amount) ); 
        gen.writeStringField('DAN', danNo);  
        gen.writeStringField('date', System.today().format()); 
        gen.writeStringField('scheme_signatory', schemeSignatory); 
        gen.writeEndObject(); 
        gen.writeEndObject(); 
        
        
        gen.writeEndArray();
        gen.writeEndObject();
        jsonData =gen.getAsString();
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if(depositdetails.CreatedBy.profile.UserLicense.Name !='Salesforce')
        {
            String jsonData1;
            HttpRequest req1 = EI_mailJetServiceUtility.mailJetAuthentication();
            List<API_Service__mdt> templateId1 = EI_CustomMetadataUtility.metaDataList('ConfirmationOfAgent_landlordAgreement'); 
            fromAddress = mailJetSettings[0].From_Address__c;
            fromName  = mailJetSettings[0].From_Name__c;
            mailJetTemplateId  = Integer.valueof(templateId1[0].Template_Id__c);
            schemeSignatory = templateId1[0].Scheme_Signatory__c;
            schemeAddress = templateId1[0].Scheme_Address__c;
            JSONGenerator gen1 = JSON.createGenerator(true);
            gen1.writeStartObject();    
            gen1.writeFieldName('Messages'); 
            gen1.writeStartArray();  
            gen1.writeStartObject(); 
            gen1.writeFieldName('From');
            gen1.writeStartObject();
            gen1.writeStringField('Email', fromAddress);
            gen1.writeStringField('Name', fromName);
            gen1.writeEndObject();
            
            gen1.writeFieldName('To');
            gen1.writeStartArray();
            gen1.writeStartObject(); 
            gen1.writeStringField('Email', depositdetails.CreatedBy.Email); 
            gen1.writeStringField('Name', depositdetails.CreatedBy.Name);
            gen1.writeEndObject();      
            gen1.writeEndArray();
            
            gen1.writeNumberField('TemplateID', mailJetTemplateId); 
            gen1.writeBooleanField('TemplateLanguage', true);
            gen1.writeStringField('Subject', SUBJECT); 
            
            gen1.writeFieldName('Variables');       
            gen1.writeStartObject();
            gen1.writeStringField('name', depositdetails.CreatedBy.Name); 
            gen1.writeStringField('Address', propertyAddress); 
            gen1.writeStringField('DAN', danNo); 
            gen1.writeStringField('customer_name', depositdetails.customer__r.Name);
            gen1.writeStringField('Date', System.today().format());
            gen1.writeStringField('deadline_date', TenancyEndDate.format());
            gen1.writeStringField('scheme_signatory', schemeSignatory); 
            gen1.writeEndObject(); 
            gen1.writeEndObject(); 
            gen1.writeEndArray();
            gen1.writeEndObject();
            jsonData1 =gen1.getAsString();
            req1.setBody(jsonData1);
            Http http1 = new Http();
            HTTPResponse res1 = http1.send(req1);
        } 
    }
    
    /* Currently not in use */
    public void sendEmail(Repayment_Request__c RepaymentRec)
    {
        System.debug('Line 272 '+RepaymentRec);
        Deposit__c depositdetails =[select id,name,customer__c,End_Date__c,
                                    Property__c,Deposit_Account_Number__c,customer__r.Salutation, customer__r.Name ,
                                    customer__r.Phone, customer__r.PersonEmail,Property_Address__c,Start_Date__c,
                                    Rent_Amount__c,Deposit_Amount__c,Date_Deposit_Received__c,CreatedBy.Name,
                                    Amount_of_Deposit_Protected_by_TDS__c,Status__c,CreatedBy.Email, Protected_Amount__c,
                                    CreatedBy.profile.UserLicense.Name,
                                    (select id,Deposit_Holder__r.Name,Deposit_Holder__r.PersonEmail,Is_Lead__c 
                                     from Deposit_Allocations__r )
                                    from Deposit__c
                                    where id=:RepaymentRec.Deposit__c];
        System.debug('Line 272 '+depositdetails);
        String SUBJECT = 'Reference: '+depositdetails.Deposit_Account_Number__c +' Confirmation of agent/landlord’s agreement to repayment request ';
        String jsonData;
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('AgentLandlordDisagreesWithRepaymentLead'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        schemeSignatory = templateId[0].Scheme_Signatory__c;
        schemeAddress = templateId[0].Scheme_Address__c;
        string LeadTenantName = '';
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
        list<string> flaglist = new list<string>(); 
        for(Deposit_Allocation__c d:depositdetails.Deposit_Allocations__r){
            //Send Emails if deposit not secured for 24 hours of deposit creation
            //
            
            if(flaglist.size() > 0 &&  !(flaglist.contains(d.id)))
            {
               // gen.writeString(','); 
            }
            if(d.Is_Lead__c)
            {
                system.debug('Line 308');
                toAddress = d.Deposit_Holder__r.PersonEmail;
                LeadTenantName = d.Deposit_Holder__r.Name;
                toName = d.Deposit_Holder__r.Name;
                propertyAddress = depositdetails.Property_Address__c;
                danNo = depositdetails.Deposit_Account_Number__c; 
                // decimal diifrenceinAmount= math.abs(OldAmount-newAmount) ;          
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
                gen.writeStringField('Subject',SUBJECT ); 
                
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('name', toName); 
                gen.writeStringField('Address', propertyAddress); 
                gen.writeStringField('DAN', danNo);  
                gen.writeStringField('Date', System.today().format());
                gen.writeStringField('agentAmount', string.valueOf(RepaymentRec.Total_Amount_Requested_AL__c ));
                decimal TenantAmount =(depositdetails.Protected_Amount__c -RepaymentRec.Total_Amount_Requested_AL__c);
                gen.writeStringField('TenantAmount', string.valueOf(TenantAmount));
                gen.writeStringField('cleanNo', string.valueOf(RepaymentRec.AL_CleaningAmt__c));
                gen.writeStringField('damangeNo', string.valueOf(RepaymentRec.AL_DmgPropAmt__c));
                gen.writeStringField('reDecorationNo', string.valueOf(RepaymentRec.AL_RedecorationAmt__c));
                gen.writeStringField('gardeningNo', string.valueOf(RepaymentRec.AL_GardeningAmt__c));
                gen.writeStringField('rentArrNo', string.valueOf(RepaymentRec.AL_Rent_Arrears__c));
                gen.writeStringField('otherNo', string.valueOf(RepaymentRec.AL_OtherAmt__c));
                gen.writeStringField('otherReasonNo', string.valueOf(RepaymentRec.AL_Other_Reason__c));
                gen.writeStringField('scheme_signatory', schemeSignatory); 
                gen.writeEndObject(); 
                gen.writeEndObject(); 
                flaglist.add(d.id);
            }
            
        }
        gen.writeEndArray();
        gen.writeEndObject();
        jsonData =gen.getAsString();
        req.setBody(jsonData);
        Http http = new Http();
        system.debug('Line 362');
        HTTPResponse res = http.send(req);
        
        String jsonData2;
        HttpRequest req2 = EI_mailJetServiceUtility.mailJetAuthentication();
        List<API_Service__mdt> templateId2 = EI_CustomMetadataUtility.metaDataList('AgentLandlordDisagreesWithRepaymentJoint'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId2[0].Template_Id__c);
        schemeSignatory = templateId2[0].Scheme_Signatory__c;
        schemeAddress = templateId2[0].Scheme_Address__c;
        JSONGenerator gen2 = JSON.createGenerator(true);
        gen2.writeStartObject();    
        gen2.writeFieldName('Messages'); 
        gen2.writeStartArray();
        list<string> flaglist2 = new list<string>(); 
        for(Deposit_Allocation__c d:depositdetails.Deposit_Allocations__r){
            //Send Emails if deposit not secured for 24 hours of deposit creation
            //
            
            if(flaglist2.size() > 0 &&  !(flaglist2.contains(d.id)))
            {
                //gen2.writeString(','); 
            }
            if(!d.Is_Lead__c)
            {
                toAddress = d.Deposit_Holder__r.PersonEmail;
                toName = d.Deposit_Holder__r.Name;
                propertyAddress = depositdetails.Property_Address__c;
                danNo = depositdetails.Deposit_Account_Number__c; 
                // decimal diifrenceinAmount= math.abs(OldAmount-newAmount) ;          
                gen2.writeStartObject(); 
                gen2.writeFieldName('From');
                gen2.writeStartObject();
                gen2.writeStringField('Email', fromAddress);
                gen2.writeStringField('Name', fromName);
                gen2.writeEndObject();
                
                gen2.writeFieldName('To');
                gen2.writeStartArray();
                gen2.writeStartObject(); 
                gen2.writeStringField('Email', toAddress); 
                gen2.writeStringField('Name', toName);
                gen2.writeEndObject();      
                gen2.writeEndArray();
                
                gen2.writeNumberField('TemplateID', mailJetTemplateId); 
                gen2.writeBooleanField('TemplateLanguage', true);
                gen2.writeStringField('Subject',SUBJECT ); 
                
                gen2.writeFieldName('Variables');       
                gen2.writeStartObject();
                gen2.writeStringField('name', toName); 
                gen2.writeStringField('Address', propertyAddress); 
                gen2.writeStringField('DAN', danNo);  
                gen2.writeStringField('Date', System.today().format());
                gen2.writeStringField('agentAmount', string.valueOf(RepaymentRec.Total_Amount_Requested_AL__c ));
                decimal TenantAmount =(depositdetails.Protected_Amount__c -RepaymentRec.Total_Amount_Requested_AL__c);
                gen2.writeStringField('TenantAmount', string.valueOf(TenantAmount));
                gen2.writeStringField('cleanNo', string.valueOf(RepaymentRec.AL_CleaningAmt__c));
                gen2.writeStringField('damangeNo', string.valueOf(RepaymentRec.AL_DmgPropAmt__c));
                gen2.writeStringField('reDecorationNo', string.valueOf(RepaymentRec.AL_RedecorationAmt__c));
                gen2.writeStringField('gardeningNo', string.valueOf(RepaymentRec.AL_GardeningAmt__c));
                gen2.writeStringField('rentArrNo', string.valueOf(RepaymentRec.AL_Rent_Arrears__c));
                gen2.writeStringField('otherNo', string.valueOf(RepaymentRec.AL_OtherAmt__c));
                gen2.writeStringField('otherReasonNo', string.valueOf(RepaymentRec.AL_Other_Reason__c));
                gen2.writeStringField('lead_tenant', string.valueOf(LeadTenantName));
                gen2.writeStringField('deadline_date', string.valueOf(system.today().adddays(30)));
                gen2.writeStringField('scheme_signatory', schemeSignatory); 
                
                gen2.writeEndObject(); 
                gen2.writeEndObject(); 
                flaglist2.add(d.id);
            }
            
        }
        gen2.writeEndArray();
        gen2.writeEndObject();
        jsonData2 =gen2.getAsString();
        req2.setBody(jsonData2);
        Http http2 = new Http();
        if(flaglist2.size() >0)
        {
            system.debug('Line 445');
            HTTPResponse res2 = http.send(req2);
            system.debug(res2.getBody());
        }
        
        
        
        if(depositdetails.CreatedBy.profile.UserLicense.Name !='Salesforce')
        {
            String jsonData1;
            HttpRequest req1 = EI_mailJetServiceUtility.mailJetAuthentication();
            List<API_Service__mdt> templateId1 = EI_CustomMetadataUtility.metaDataList('Agent_landlordDisagreesWithRepayment'); 
            fromAddress = mailJetSettings[0].From_Address__c;
            fromName  = mailJetSettings[0].From_Name__c;
            mailJetTemplateId  = Integer.valueof(templateId1[0].Template_Id__c);
            schemeSignatory = templateId1[0].Scheme_Signatory__c;
            schemeAddress = templateId1[0].Scheme_Address__c;
            JSONGenerator gen1 = JSON.createGenerator(true);
            gen1.writeStartObject();    
            gen1.writeFieldName('Messages'); 
            gen1.writeStartArray();  
            gen1.writeStartObject(); 
            gen1.writeFieldName('From');
            gen1.writeStartObject();
            gen1.writeStringField('Email', fromAddress);
            gen1.writeStringField('Name', fromName);
            gen1.writeEndObject();
            
            gen1.writeFieldName('To');
            gen1.writeStartArray();
            gen1.writeStartObject(); 
            gen1.writeStringField('Email', depositdetails.CreatedBy.Email); 
            gen1.writeStringField('Name', depositdetails.CreatedBy.Name);
            gen1.writeEndObject();      
            gen1.writeEndArray();
            
            gen1.writeNumberField('TemplateID', mailJetTemplateId); 
            gen1.writeBooleanField('TemplateLanguage', true);
            gen1.writeStringField('Subject', SUBJECT); 
            
            gen1.writeFieldName('Variables');       
            gen1.writeStartObject();
            gen1.writeStringField('name', toName); 
            gen1.writeStringField('Address', propertyAddress); 
            gen1.writeStringField('DAN', danNo);  
            gen1.writeStringField('Date', System.today().format());
            gen1.writeStringField('agentAmount', string.valueOf(RepaymentRec.Total_Amount_Requested_AL__c ));
            decimal TenantAmount =(depositdetails.Protected_Amount__c -RepaymentRec.Total_Amount_Requested_AL__c);
            gen1.writeStringField('TenantAmount', string.valueOf(TenantAmount));
            gen1.writeStringField('cleanNo', string.valueOf(RepaymentRec.AL_CleaningAmt__c));
            gen1.writeStringField('damangeNo', string.valueOf(RepaymentRec.AL_DmgPropAmt__c));
            gen1.writeStringField('reDecorationNo', string.valueOf(RepaymentRec.AL_RedecorationAmt__c));
            gen1.writeStringField('gardeningNo', string.valueOf(RepaymentRec.AL_GardeningAmt__c));
            gen1.writeStringField('rentArrNo', string.valueOf(RepaymentRec.AL_Rent_Arrears__c));
            gen1.writeStringField('otherNo', string.valueOf(RepaymentRec.AL_OtherAmt__c));
            gen1.writeStringField('otherReasonNo', string.valueOf(RepaymentRec.AL_Other_Reason__c));
            gen1.writeStringField('scheme_signatory', schemeSignatory); 
            gen1.writeEndObject(); 
            gen1.writeEndObject(); 
            gen1.writeEndArray();
            gen1.writeEndObject();
            jsonData1 =gen1.getAsString();
            req1.setBody(jsonData1);
            Http http1 = new Http();
            HTTPResponse res1 = http1.send(req1);
        }
    }
    
    /* Sending AGLL repayment request disagreement emails */
    public static void sendDisagreementEmails(Repayment_Request__c RepaymentRec)
    {
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        System.debug('Line 733 '+RepaymentRec);
        Deposit__c depositdetails = 
            [SELECT Id, Name, Customer__c, End_Date__c, Property__c, Deposit_Account_Number__c, Customer__r.Salutation, Customer__r.Name, 
             Customer__r.Phone, Customer__r.PersonEmail, Property_Address__c, Start_Date__c, Rent_Amount__c, Deposit_Amount__c, Date_Deposit_Received__c, 
             CreatedBy.Name, Amount_of_Deposit_Protected_by_TDS__c,Status__c,CreatedBy.Email, Protected_Amount__c, CreatedBy.profile.UserLicense.Name, 
             Property_Address_WO_Country__c, (SELECT Id, Deposit_Holder__c,Deposit_Holder__r.personcontactid, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail, Is_Lead__c 
              FROM Deposit_Allocations__r) FROM Deposit__c WHERE Id=:RepaymentRec.Deposit__c];
        System.debug('Line 740 '+depositdetails);
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        /* Newly added code for Mailjet Utility Class END */
        
        String leadTenantName = '';
        
        for(Deposit_Allocation__c d:depositdetails.Deposit_Allocations__r) {
            
            if(d.Is_Lead__c)
            {                
                leadTenantName = d.Deposit_Holder__r.Name;
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(d.Deposit_Holder__r.PersonEmail, 
                                                                              d.Deposit_Holder__r.Name, 
                                                                              RepaymentRec.Case__c,d.Deposit_Holder__r.personcontactid /*d.Deposit_Holder__c*/));
                Map<String, String> variableMap = new Map<String, String>();
                
                variableMap.put('name', d.Deposit_Holder__r.Name);
                variableMap.put('Address', depositdetails.Property_Address_WO_Country__c);
                variableMap.put('DAN', depositdetails.Deposit_Account_Number__c);
                variableMap.put('Date', todayStr);
                variableMap.put('agentAmount', String.valueOf(RepaymentRec.Total_Amount_Requested_AL__c));
                Decimal TenantAmount =(depositdetails.Protected_Amount__c-RepaymentRec.Total_Amount_Requested_AL__c);
                variableMap.put('TenantAmount', String.valueOf(TenantAmount));
                variableMap.put('cleanNo', String.valueOf(RepaymentRec.AL_CleaningAmt__c));
                variableMap.put('damangeNo', String.valueOf(RepaymentRec.AL_DmgPropAmt__c));
                variableMap.put('reDecorationNo', String.valueOf(RepaymentRec.AL_RedecorationAmt__c));
                variableMap.put('gardeningNo', String.valueOf(RepaymentRec.AL_GardeningAmt__c));
                variableMap.put('rentArrNo', String.valueOf(RepaymentRec.AL_Rent_Arrears__c));
                variableMap.put('otherNo', String.valueOf(RepaymentRec.AL_OtherAmt__c));
                variableMap.put('otherReasonNo', String.valueOf(RepaymentRec.AL_Other_Reason__c));
                //variableMap.put('scheme_signatory', schemeSignatory);                 
                
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'AgentLandlordDisagreesWithRepaymentLead', 
                                                                               'Reference: '+depositdetails.Deposit_Account_Number__c+
                                                                               ' Confirmation of agent/landlord’s disagreement to repayment request'));
                
                /* Newly added code for adding recipients, variables, template name, Subject END */
            }
            else {
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(d.Deposit_Holder__r.PersonEmail, 
                                                                              d.Deposit_Holder__r.Name, 
                                                                              RepaymentRec.Case__c,d.Deposit_Holder__r.personcontactid /*d.Deposit_Holder__c*/));
                Map<String, String> variableMap = new Map<String, String>();
                Date deadlineDate = EI_UtilityClassForPayments.dueDateMethod(System.today(), 30);
                String deadlineDateStr = deadlineDate.day()+'/'+deadlineDate.month()+'/'+deadlineDate.year();
                
                variableMap.put('name', d.Deposit_Holder__r.Name);
                variableMap.put('Address', depositdetails.Property_Address_WO_Country__c);
                variableMap.put('DAN', depositdetails.Deposit_Account_Number__c);
                variableMap.put('Date', todayStr);
                variableMap.put('agentAmount', String.valueOf(RepaymentRec.Total_Amount_Requested_AL__c));
                Decimal TenantAmount =(depositdetails.Protected_Amount__c-RepaymentRec.Total_Amount_Requested_AL__c);
                variableMap.put('TenantAmount', String.valueOf(TenantAmount));
                variableMap.put('cleanNo', String.valueOf(RepaymentRec.AL_CleaningAmt__c));
                variableMap.put('damangeNo', String.valueOf(RepaymentRec.AL_DmgPropAmt__c));
                variableMap.put('reDecorationNo', String.valueOf(RepaymentRec.AL_RedecorationAmt__c));
                variableMap.put('gardeningNo', String.valueOf(RepaymentRec.AL_GardeningAmt__c));
                variableMap.put('rentArrNo', String.valueOf(RepaymentRec.AL_Rent_Arrears__c));
                variableMap.put('otherNo', String.valueOf(RepaymentRec.AL_OtherAmt__c));
                variableMap.put('otherReasonNo', String.valueOf(RepaymentRec.AL_Other_Reason__c));
                variableMap.put('lead_tenant', String.valueOf(leadTenantName));
                variableMap.put('deadline_date', deadlineDateStr);
                //variableMap.put('scheme_signatory', schemeSignatory);                 
                
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'AgentLandlordDisagreesWithRepaymentJoint', 
                                                                               'Reference: '+depositdetails.Deposit_Account_Number__c+
                                                                               ' Confirmation of agent/landlord’s disagreement to repayment request'));
                
                /* Newly added code for adding recipients, variables, template name, Subject END */
            }
            
        }
        
        if(depositdetails.CreatedBy.profile.UserLicense.Name!='Salesforce')
        {
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(depositdetails.CreatedBy.Email, 
                                                                          depositdetails.CreatedBy.Name, 
                                                                          RepaymentRec.Case__c, depositdetails.Customer__c));
            Map<String, String> variableMap = new Map<String, String>();
            Decimal TenantAmount =(depositdetails.Protected_Amount__c-RepaymentRec.Total_Amount_Requested_AL__c);
            
            variableMap.put('name', depositdetails.Customer__r.Name);
            variableMap.put('Address', depositdetails.Property_Address_WO_Country__c);
            variableMap.put('DAN', depositdetails.Deposit_Account_Number__c);
            variableMap.put('Date', todayStr);
            variableMap.put('agentAmount', String.valueOf(RepaymentRec.Total_Amount_Requested_AL__c));
            variableMap.put('TenantAmount', String.valueOf(TenantAmount));
            variableMap.put('cleanNo', String.valueOf(RepaymentRec.AL_CleaningAmt__c));
            variableMap.put('damangeNo', String.valueOf(RepaymentRec.AL_DmgPropAmt__c));
            variableMap.put('reDecorationNo', String.valueOf(RepaymentRec.AL_RedecorationAmt__c));
            variableMap.put('gardeningNo', String.valueOf(RepaymentRec.AL_GardeningAmt__c));
            variableMap.put('rentArrNo', String.valueOf(RepaymentRec.AL_Rent_Arrears__c));
            variableMap.put('otherNo', String.valueOf(RepaymentRec.AL_OtherAmt__c));
            variableMap.put('otherReasonNo', String.valueOf(RepaymentRec.AL_Other_Reason__c));
            //variableMap.put('scheme_signatory', schemeSignatory);                 
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'Agent_landlordDisagreesWithRepayment', 
                                                                           'Reference: '+depositdetails.Deposit_Account_Number__c+
                                                                           ' Confirmation of agent/landlord’s disagreement to repayment request'));
            /* Newly added code for adding recipients, variables, template name, Subject END */
        }
        
        System.debug('Line 852 '+RepaymentRec);
        
        /* Sending Email through MailJet Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
        }
        /* Sending Email through MailJet Utility Class END */
        
    }
    
}