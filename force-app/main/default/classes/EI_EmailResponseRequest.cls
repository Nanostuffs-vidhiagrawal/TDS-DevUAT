public class EI_EmailResponseRequest {
    
    
    @Auraenabled
    public static string updatepaymentdetails (){
        string message = 'Emails sent';
        List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage >(); 
        Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
        string htmlBody = date.today().format()+'<br/><br/>';
        htmlBody+= 'Dear <br/><br/>';
        htmlBody+= 'Tenant changeover requested<br/><br/>';
        htmlBody+= 'SafeDeposits Scotland has been unable to pay the amount of [amount] that is due to you for the repayment<br/> ';
        htmlBody+= 'of deposit [DAN]. This is because you have not yet provided your payment details.<br/><br/>';
        htmlBody+= 'To provide these, please follow the below instructions:<br/><br/> ';
        htmlBody+= '•  Login to your online account at [website]<br/>';
        htmlBody+= '•  Select My Details<br/><br/>';
        htmlBody+= '•  Click Repayment details from the left-hand menu, and enter the following:<br/>';
        htmlBody+= '       o   The name on your account<br/>';
        htmlBody+= '       o   Your sort code<br/>';
        htmlBody+= '       o   Your account number<br/><br/>';
        htmlBody+= 'Once SafeDeposits Scotland has your payment details, your payment will be sent to you within 5 working days.<br/><br/>';
        htmlBody+= 'Kind regards,<br/><br/>';
        htmlBody+= '[Scheme signatory]';
        message1.setReplyTo('no-reply@company.com');
        message1.setUseSignature(false); 
        message1.setBccSender(false); 
        message1.setSaveAsActivity(false);
        message1.setHtmlBody(htmlBody);
        message1.setSubject('Please update your payment details');
        message1.setToAddresses(new String[] {'himanshuumody15@gmail.com'});   
        emails.add(message1);
        Messaging.sendEmail(emails,true);
        return message;
    }
    
    
    @Auraenabled
    public static string disagreewithrepaymentrequest (){
        string message = 'Emails sent';
        List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage >(); 
        Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
        string htmlBody = date.today().format()+'<br/><br/>';
        htmlBody+= 'Dear <br/><br/>';
        htmlBody+= 'Deposit Account Number: [DAN]<br/>';
        htmlBody+= 'Property Address: [property address]<br/><br/>';
        htmlBody+= 'Agent/landlord disagrees with repayment request<br/><br/>';
        htmlBody+= 'Thank you for your request for the repayment of the deposit relating to this tenancy. You<br/><br/>';
        htmlBody+= 'have requested that the deposit is repaid as follows:<br/><br/>';
        htmlBody+= 'Agent/landlord to receive: [amount]<br/>';
        htmlBody+= 'The agent/landlords claim is for:<br/><br/>';
        htmlBody+= '<table border="1" style="color: black" ><tr><td>Cleaning</td><td>[amount]</td></tr>';
        htmlBody+= '<tr><td>Damage</td><td>[amount]</td></tr>';
        htmlBody+= '<tr><td>Redecoration</td><td>[amount]</td></tr>';
        htmlBody+= '<tr><td>Gardening</td><td>[amount]</td></tr>';
        htmlBody+= '<tr><td>Rent Arrears</td><td>[amount]</td></tr>';
        htmlBody+= '<tr><td>Other</td><td>[amount]</td></tr>';
        htmlBody+= '<tr><td>Other (reason)</td><td>[text]</td></tr>';
        htmlBody+= '</table>';
        htmlBody+= '       o   The name on your account<br/>';
        htmlBody+= '       o   Your sort code<br/>';
        htmlBody+= '       o   Your account number<br/><br/>';
        htmlBody+= 'Once SafeDeposits Scotland has your payment details, your payment will be sent to you within 5 working days.<br/><br/>';
        htmlBody+= 'Kind regards,<br/><br/>';
        htmlBody+= '[Scheme signatory]';
        message1.setReplyTo('no-reply@company.com');
        message1.setUseSignature(false); 
        message1.setBccSender(false); 
        message1.setSaveAsActivity(false);
        message1.setHtmlBody(htmlBody);
        message1.setSubject('Reference: [DAN] Agent/landlord disagrees with repayment request');
        message1.setToAddresses(new String[] {'himanshuumody15@gmail.com'});   
        emails.add(message1);
        Messaging.sendEmail(emails,true);
        return message;
    }
    
    @AuraEnabled
    public static string caseClosureNotificationTenant (String DANnumber,  String propAddress, String tenantEmailIds){
        String fromAddress;
        String fromName;
        String toAddress;
        String toName;
        Integer mailJetTemplateId;
        String schemeSignatory;
       
        string message = 'Emails sent';
        String jsonData;
        HttpRequest req1 = EI_mailJetServiceUtility.mailJetAuthentication();
        
        List<API_Service__mdt> templateId1 = EI_CustomMetadataUtility.metaDataList('TenancyNotEndedToTenant');
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId1[0].Template_Id__c);
        schemeSignatory = templateId1[0].Scheme_Signatory__c;
        
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
       // gen1.writeStringField('Email', depositdetails.CreatedBy.Email); 
      //  gen1.writeStringField('Name', depositdetails.CreatedBy.Name);
        gen1.writeEndObject();      
        gen1.writeEndArray();
        
        gen1.writeNumberField('TemplateID', mailJetTemplateId); 
        gen1.writeBooleanField('TemplateLanguage', true);
      //  gen1.writeStringField('Subject', SUBJECT); 
        
        gen1.writeFieldName('Variables');       
        gen1.writeStartObject();
        gen1.writeStringField('date', string.valueOf(system.today()));
     //   gen1.writeStringField('tenant_name', depositdetails.CreatedBy.Name); 
        gen1.writeStringField('dan_no', DANnumber); 
        gen1.writeStringField('property_address', propAddress); 
      //  gen1.writeStringField('scheme_signatory', depositdetails.customer__r.Name);
        gen1.writeEndObject(); 
        gen1.writeEndObject(); 
        gen1.writeEndArray();
        gen1.writeEndObject();
        jsonData =gen1.getAsString();
        req1.setBody(jsonData);
        Http http1 = new Http();
        HTTPResponse res1 = http1.send(req1);
        /* List <Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage >(); 
Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
string htmlBody = date.today().format()+'<br/><br/>';
htmlBody+= 'Dear Customer,<br/><br/>';
htmlBody+= '<b>Agent/landlord advises tenancy has not yet ended.</b><br/><br/>';
htmlBody+= '<b>Deposit Account Number: '+DANnumber+'</b><br/>';
htmlBody+= '<b>Property Address: '+propAddress+'</b><br/><br/>';	
htmlBody+= 'You recently completed a request for the repayment of the deposit.<br/><br/>';
htmlBody+= 'We have been informed by the agent/landlord that your tenancy has not yet ended.<br/><br/> ';
htmlBody+= 'We are unable to deal with the return of a deposit until after the tenancy has ended, so we have cancelled your repayment request. The deposit remains with Safe Deposit.';
htmlBody+= 'Please contact your agent/landlord if you need to discuss this.<br/><br/> ';
htmlBody+= 'Yours sincerely,<br/>';
htmlBody+= 'Mike Smith';
message1.setReplyTo('no-reply@company.com');
message1.setUseSignature(false); 
message1.setBccSender(false); 
message1.setSaveAsActivity(false);
message1.setHtmlBody(htmlBody);
message1.setSubject('Reference: '+DANnumber+' Agent/landlord advises tenancy has not yet ended');
message1.setToAddresses(new String[] {tenantEmailIds});   
emails.add(message1);
Messaging.sendEmail(emails,true); */
        return message;
    }
    
    @Auraenabled
    public static string caseClosureNotificationLandlord (String DANnumber,  String propAddress){
        user userDetails = [select email, contactId,Accountid from user where id=:userinfo.getUserId()];
        string message = 'Emails sent';
        List <Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage >(); 
        Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
        string htmlBody = date.today().format()+'<br/><br/>';
        htmlBody+= 'Dear Customer,<br/><br/>';
        htmlBody+= 'Confirmation that tenancy has not yet ended.<br/><br/>';
        htmlBody+= '<b>Deposit Account Number: '+DANnumber+'</b><br/>';
        htmlBody+= '<b>Property Address: '+propAddress+'</b><br/><br/>';	
        htmlBody+= 'You recently responded to a deposit repayment request from the tenant(s) to inform us that the tenancy has not yet ended.<br/><br/> ';
        htmlBody+= 'As a result, we have cancelled the tenant(s) request and advised them accordingly. The deposit remains with Safe Deposit.<br/><br/>';
        htmlBody+= 'Yours sincerely,<br/>';
        htmlBody+= 'Mike Smith';
        message1.setReplyTo('no-reply@company.com');
        message1.setUseSignature(false); 
        message1.setBccSender(false); 
        message1.setSaveAsActivity(false);
        message1.setHtmlBody(htmlBody);
        message1.setSubject('Reference: '+DANnumber+' Confirmation that tenancy has not yet ended');
        message1.setToAddresses(new String[] {userDetails.Email});   
        emails.add(message1);
        Messaging.sendEmail(emails,true);
        return message;
    }
    
    @Auraenabled
    public static string depositReductionAgentLandlord (String DANnumber, String recipientName,  String propAddress, String recipientEmail, String previousAmount, String newDepositAmount, String newProtectedAmount, String previousProtectedAmount, String differenceAmount, String tenantName){
        //   user userDetails = [select email, contactId,Accountid from user where id=:userinfo.getUserId()];
        string message = 'Emails sent';
        List <Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage >(); 
        Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
        String htmlBody = date.today().format()+'<br/><br/>';
        htmlBody+= 'Dear '+recipientName+',<br/><br/>';
        htmlBody+= 'Confirmation of deposit reduction – '+DANnumber+'.<br/><br/>';	
        htmlBody+= 'Thank you for amending the deposit amount from '+previousAmount+'to '+newDepositAmount+'. Safe Deposit now protects '+newProtectedAmount+'. As we only protected '+previousProtectedAmount+' before, we are arranging to pay the excess amount of differenceAmount to the tenant, '+tenantName+'. You do not need to do anything more.<br/><br/> ';
        htmlBody+= 'An updated deposit protection certificate is available in your account now.';
        htmlBody+= 'Yours sincerely,<br/>';
        htmlBody+= 'Mike Smith';
        message1.setReplyTo('no-reply@company.com');
        message1.setUseSignature(false); 
        message1.setBccSender(false); 
        message1.setSaveAsActivity(false);
        message1.setHtmlBody(htmlBody);
        message1.setSubject('Reference: '+DANnumber+' Confirmation of deposit reduction');
        message1.setToAddresses(new String[] {recipientEmail});   
        emails.add(message1);
        Messaging.sendEmail(emails,true);
        return message;
    }
    
    @Auraenabled
    public static string depositReductionTenant(String DANnumber, String recipientName,  String recipientEmail,  String newDepositAmount, String differenceAmount, String tenantName){
        //   user userDetails = [select email, contactId,Accountid from user where id=:userinfo.getUserId()];
        string message = 'Emails sent';
        List <Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage >(); 
        Messaging.SingleEmailMessage message1 = new Messaging.SingleEmailMessage();
        String htmlBody = date.today().format()+'<br/><br/>';
        htmlBody+= 'Dear '+recipientName+',<br/><br/>';
        htmlBody+= 'Confirmation of deposit reduction – '+DANnumber+'.<br/><br/>';	
        htmlBody+= recipientName+' has reduced the amount of your deposit. The amount of the deposit Safe Deposit now protects is '+newDepositAmount+' and we are arranging to pay the excess amount of '+differenceAmount+' to the lead tenant, '+tenantName+'.';
        htmlBody+= tenantName+',  if  you  have  not  yet  activated  your  Safe Deposit  account  and  added  your  bank details, we will send you a separate email with instructions on how to do so.';
        htmlBody+= 'Yours sincerely,<br/>';
        htmlBody+= 'Mike Smith';
        message1.setReplyTo('no-reply@company.com');
        message1.setUseSignature(false); 
        message1.setBccSender(false); 
        message1.setSaveAsActivity(false);
        message1.setHtmlBody(htmlBody);
        message1.setSubject('Reference: '+DANnumber+' Confirmation of deposit reduction');
        message1.setToAddresses(new String[] {recipientEmail});   
        emails.add(message1);
        Messaging.sendEmail(emails,true);
        return message;
    }
}