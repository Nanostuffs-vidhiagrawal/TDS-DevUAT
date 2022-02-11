global class EI_BatchLandlordAssistance implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select Id, Name, Email, Account.Deposit_Protections__c, ContactId from User where IsActive=true and user_assistance_mail__c=false '
        +'and account.Deposit_Protections__c=0 and User_Type__c=\'Landlord\' and CreatedDate=LAST_n_DAYS:15 and Id=\'0053H000001k9CDQAY\' ';                
        // String query = 'select id,account.Deposit_Protections__c,email from user where IsActive=true and user_assistance_mail__c=false and account.Deposit_Protections__c=0 and User_Type__c=\'Landlord\' and id=\'0053H000001DBwA\' ';
        System.debug('query -> '+query);
        return Database.getQueryLocator(query);    
    }
    
    global void execute(Database.BatchableContext BC, List<User> useList) { 
        system.debug('check  19' + useList);
        system.debug('check  20' + useList.size());
        /* Newly Code for Attachment */
        //PageReference assistancePdf = PageReference.forResource('DemoAssistancePdf', path).getUrl();
        //PageReference assistancePdf = PageReference.forResource('DemoAssistancePdf').getUrl();
        Blob bodyAsBlob; 
        //bodyAsBlob = assistancePdf.getContentAsPDF(); 
        bodyAsBlob = Blob.valueOf(PageReference.forResource('DemoAssistancePdf').getUrl());
        // string depositCertificateName = depo.Id+'.pdf';
        // boolean result = uploadBlob(bodyAsBlob,bodyAsBlob.size(),'application/pdf', depositCertificateName);
        // call mailjet
        String dpcCertificateBase64 = EncodingUtil.base64Encode(bodyAsBlob);
        System.debug('File64='+dpcCertificateBase64);
        //EI_SDS_MailJetUtilityCls.sendEmailFromBatchWithAttachment(depo, dpcCertificateBase64);
        /* Newly Code for Attachment */
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
		List<EI_SDS_MailJetUtilityCls.attachmentWrapper> attachmentWrapperList = new List<EI_SDS_MailJetUtilityCls.attachmentWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Utility mailjet END */
        
        for(User usr : useList) {
            //EI_AgentLandlordPostloginemails.landlordasistance(usr.Email,usr.Name);
            usr.user_assistance_mail__c=true;
            usr.Email_send_date__c=system.now();
            
            /* Newly added code for adding recipients, variables, template name, Subject START */
            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
            Map<String, String> variableMap = new Map<String, String>();
            
            emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(usr.Email, usr.Name, '', usr.ContactId,usr.ContactId));
            //attachmentWrapperList.add('application/pdf','Assistance.pdf',bodyAsBlob);
            
            variableMap.put('date', todayStr);
            variableMap.put('landlordname', usr.Name);
            
            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                           'SDSDepositProtectionAssistance',
                                                                           'How to protect a deposit with SafeDeposits'));
            /* Newly added code for adding recipients, variables, template name, Subject END */
        }
        
        /* Send Email from Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmailFromBatchWithAttachments(JSON.serialize(emailWrapperList), attachmentWrapperList);  
        }
        /* Send Email from Utility Class END */
        
        Database.update(useList,true);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}