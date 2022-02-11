public class EI_depositAmountEmail {
    public String fromAddress;
    public String fromName;
    public String toAddress;
    public String toName;
    public Integer mailJetTemplateId;
    public String propertyAddress;
    public Decimal amount;
    public String bankAccountName;
    public String schemeSignatory;
    public Integer daysRemaining;
    public String schemeAddress;
    public String danNo;
    public String sortCode;
    public String accountNumber;
    public void sendEmail( Decimal OldAmount,Decimal newAmount,String DepositId,
                          list<Deposit_Allocation__c> selectedTenant)
    {
        Deposit__c depositdetails =[select id,name,customer__c,
                                    Property__c,Deposit_Account_Number__c,customer__r.Salutation, customer__r.Name ,customer__r.Phone, customer__r.PersonEmail,
                                    Property_Address__c,Start_Date__c,Rent_Amount__c,Deposit_Amount__c,Date_Deposit_Received__c,CreatedBy.Name,
                                    Amount_of_Deposit_Protected_by_TDS__c,Status__c,CreatedBy.Email, CreatedBy.profile.UserLicense.Name,
                                    (select id,Deposit_Holder__r.Name,Deposit_Holder__r.PersonEmail,Is_Lead__c from Deposit_Allocations__r)
                                    from Deposit__c
                                    where id=:DepositId];
        
        String SUBJECT = 'Reference: '+depositdetails.Deposit_Account_Number__c +' Confirmation of deposit reduction';
        String jsonData;
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('DepositReductionTenant'); 
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
        decimal diifrenceinAmount= math.abs(OldAmount-newAmount) ;
        for(Deposit_Allocation__c d:depositdetails.Deposit_Allocations__r){
            system.debug('d-->>'+d);
            //Send Emails if deposit not secured for 24 hours of deposit creation
            //
            
            if(flaglist.size() > 0 &&  !(flaglist.contains(d.id)))
            {
               // gen.writeString(','); 
            }
            toAddress = d.Deposit_Holder__r.PersonEmail;
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
            gen.writeStringField('address', propertyAddress); 
            gen.writeNumberField('difference_amount', diifrenceinAmount); 
            if(selectedTenant != null )
            {
               gen.writeStringField('lead_tenant_name', string.valueOf(selectedTenant[0].Deposit_Holder__r.Name));
               gen.writeStringField('tenant_name', string.valueOf(d.Deposit_Holder__r.Name));
                
            }
            gen.writeStringField('new_deposit_amount', string.valueOf(newAmount)); 
            gen.writeStringField('old_amount',string.valueOf( OldAmount));
            gen.writeStringField('customer_name', depositdetails.customer__r.Name);
            gen.writeStringField('danNo', danNo); 
            gen.writeStringField('scheme_name', 'SafeDeposits'); 
            gen.writeStringField('date', string.valueOf(system.today())); 
            gen.writeStringField('scheme_signatory', schemeSignatory); 
            gen.writeEndObject(); 
            gen.writeEndObject(); 
            flaglist.add(d.id); 
        }
        gen.writeEndArray();
        gen.writeEndObject();
        jsonData =gen.getAsString();
        system.debug('jsonData-->>'+jsonData);
        req.setBody(jsonData);
        system.debug('req-->>'+req);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if(depositdetails.CreatedBy.profile.UserLicense.Name !='Salesforce')
        {
            String jsonData1;
            HttpRequest req1 = EI_mailJetServiceUtility.mailJetAuthentication();
            List<API_Service__mdt> templateId1 = EI_CustomMetadataUtility.metaDataList('DepositReductionLandlordAgent'); 
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
            gen1.writeStringField('address', propertyAddress); 
            gen1.writeNumberField('difference_in_amount', diifrenceinAmount);  
            gen1.writeStringField('new_amount', string.valueOf(newAmount)); 
            gen1.writeStringField('old_amount',string.valueOf( OldAmount)); 
            gen1.writeStringField('danNo', danNo); 
            gen1.writeStringField('tenant_name', selectedTenant[0].Deposit_Holder__r.Name);
            gen1.writeStringField('scheme_name', 'SafeDeposits'); 
            gen1.writeStringField('date', string.valueOf(system.today())); 
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
    
    public void ConfirmationWithoutBankdetailssendEmail( Decimal OldAmount,Decimal newAmount,String DepositId,
                          list<Deposit_Allocation__c> selectedTenant)
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
        
        String SUBJECT = 'Reference: '+depositdetails.Deposit_Account_Number__c +' Confirmation of deposit reduction';
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
			
            toAddress = selectedTenant[0].Deposit_Holder__r.PersonEmail;      
            toName = selectedTenant[0].Deposit_Holder__r.Name;
            propertyAddress = depositdetails.Property_Address__c;
            danNo = depositdetails.Deposit_Account_Number__c; 
            decimal diffrenceinAmount= math.abs(OldAmount-newAmount) ;           
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
            gen.writeStringField('Subject','Please update your payment details'  ); 
            
            gen.writeFieldName('Variables');       
            gen.writeStartObject();
            gen.writeStringField('name', toName); 
            gen.writeStringField('amount',string.valueOf(diffrenceinAmount) ); 
            gen.writeStringField('DAN', danNo);  
            gen.writeStringField('date', string.valueOf(system.today())); 
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
            List<API_Service__mdt> templateId1 = EI_CustomMetadataUtility.metaDataList('DepositReductionLandlordAgent'); 
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
            
            gen1.writeStringField('address', propertyAddress); 
            gen1.writeNumberField('difference_in_amount', diffrenceinAmount);  
            gen1.writeStringField('new_amount', string.valueOf(newAmount)); 
            gen1.writeStringField('old_amount',string.valueOf( OldAmount)); 
            gen1.writeStringField('danNo', danNo); 
            gen1.writeStringField('tenant_name', selectedTenant[0].Deposit_Holder__r.Name);
            gen1.writeStringField('scheme_name', 'SafeDeposits'); 

            gen1.writeStringField('date', string.valueOf(system.today())); 
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
    public void sendEmailgraterAmount( Decimal OldAmount,Decimal newAmount,String DepositId,
                          list<Deposit_Allocation__c> selectedTenant)
    {
        Deposit__c depositdetails =[select id,name,customer__c,
                                    Property__c,Deposit_Account_Number__c,customer__r.Salutation, customer__r.Name ,customer__r.Phone, customer__r.PersonEmail,
                                    Property_Address__c,Start_Date__c,Rent_Amount__c,Deposit_Amount__c,Date_Deposit_Received__c,CreatedBy.Name,
                                    Amount_of_Deposit_Protected_by_TDS__c,Status__c,CreatedBy.Email, CreatedBy.profile.UserLicense.Name,
                                    (select id,Deposit_Holder__r.Name,Deposit_Holder__r.PersonEmail,Is_Lead__c from Deposit_Allocations__r)
                                    from Deposit__c
                                    where id=:DepositId];
        
        String SUBJECT = 'Reference: '+depositdetails.Deposit_Account_Number__c +' Confirmation of deposit reduction';
        String jsonData;
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('DepositReductionTenantLessAmount'); 
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
        decimal diifrenceinAmount= math.abs(OldAmount-newAmount) ;
        for(Deposit_Allocation__c d:depositdetails.Deposit_Allocations__r){
            system.debug('d-->>'+d);
            //Send Emails if deposit not secured for 24 hours of deposit creation
            //
            
            if(flaglist.size() > 0 &&  !(flaglist.contains(d.id)))
            {
               // gen.writeString(','); 
            }
            toAddress = d.Deposit_Holder__r.PersonEmail;
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
            /*
            gen.writeStringField('address', propertyAddress); 
            gen.writeNumberField('difference_amount', diifrenceinAmount); 
            if(selectedTenant != null )
            {
               gen.writeStringField('lead_tenant_name', string.valueOf(selectedTenant[0].Deposit_Holder__r.Name));
               gen.writeStringField('tenant_name', string.valueOf(d.Deposit_Holder__r.Name));
                
            }
            gen.writeStringField('new_deposit_amount', string.valueOf(newAmount)); 
            gen.writeStringField('old_amount',string.valueOf( OldAmount));
            gen.writeStringField('customer_name', depositdetails.customer__r.Name);
            gen.writeStringField('danNo', danNo); 
            gen.writeStringField('scheme_name', 'SafeDeposits');
*/
            gen.writeStringField('date', string.valueOf(system.today())); 
            gen.writeStringField('scheme_signatory', schemeSignatory); 
            gen.writeEndObject(); 
            gen.writeEndObject(); 
            flaglist.add(d.id); 
        }
        gen.writeEndArray();
        gen.writeEndObject();
        jsonData =gen.getAsString();
        system.debug('jsonData-->>'+jsonData);
        req.setBody(jsonData);
        system.debug('req-->>'+req);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if(depositdetails.CreatedBy.profile.UserLicense.Name !='Salesforce')
        {
            String jsonData1;
            HttpRequest req1 = EI_mailJetServiceUtility.mailJetAuthentication();
            List<API_Service__mdt> templateId1 = EI_CustomMetadataUtility.metaDataList('DepositReductionTenantLessAmount'); 
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
            /*
            gen1.writeStringField('address', propertyAddress); 
            gen1.writeNumberField('difference_in_amount', diifrenceinAmount);  
            gen1.writeStringField('new_amount', string.valueOf(newAmount)); 
            gen1.writeStringField('old_amount',string.valueOf( OldAmount)); 
            gen1.writeStringField('danNo', danNo); 
            gen1.writeStringField('tenant_name', selectedTenant[0].Deposit_Holder__r.Name);
            gen1.writeStringField('scheme_name', 'SafeDeposits'); 
*/
            gen1.writeStringField('date', string.valueOf(system.today())); 
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
    
}