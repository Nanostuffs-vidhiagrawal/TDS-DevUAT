public class EI_BatchToSendInstallmentReminders1 implements Database.Batchable<sObject>,Database.AllowsCallouts,schedulable {
	
    public static Boolean isTopup = false;
    
    public void execute(SchedulableContext SC) {
        Database.executeBatch(new EI_BatchToSendInstallmentReminders1(), 1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
		Date todayDate = System.today();
        String query = 'Select Id, Is_Topup__c, Deposit__c, Deposit__r.Customer_email__c, Deposit__r.Customer__c, Deposit__r.Date_Deposit_Received__c, '
            +'Deposit__r.Property_Address_WO_Country__c, Deposit__r.Status__c, X30_Days_Reminder__c, X60_Days_Reminder__c, Deposit__r.Customer__r.Name, '
            +'Deposit__r.Customer__r.PersonEmail from Installment__c where Status__c = \'Pending\' AND (X30_Days_Reminder__c =: todayDate '
            +'OR X60_Days_Reminder__c =: todayDate)';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        Installment__c inst = (Installment__c)scope[0];
        
        if(inst.X30_Days_Reminder__c == System.today() && inst.Deposit__r.Status__c != 'Registered (not paid)' && inst.Deposit__r.Status__c != 'Deposit registration deleted'){
            
            //Send30DaysEmail 
			sendEmail(inst,true);
            
        }else if(inst.Deposit__r.Status__c != 'Registered (not paid)' && inst.Deposit__r.Status__c != 'Deposit registration deleted'){
            
            sendEmail(inst,false);
			if(inst.Deposit__r.Status__c == 'Awaiting payment'){
                
                Update new Deposit__c(Id= inst.Deposit__c,Status__c = 'Deposit registration deleted');
            }
            Delete inst;
        }
    
    }
    
    public void finish(Database.BatchableContext BC) {
   
    }

    public static void sendEmail(Installment__c installment, Boolean is30Days) {
        
        //HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        // String fromAddress;
        // String fromName;
        //String toAddress;
        //String toName;
        Integer mailJetTemplateId;
        // String subject='Greetings from Zero Deposit';
        
        String name = installment.Deposit__r.Customer__r.Name;
        String personEmail = installment.Deposit__r.Customer_email__c;
        
        String mailSubject;
        String mailjetTemplateName;
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        /* Newly added code for Mailjet Utility Class END */
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(String.isNotBlank(personEmail)?personEmail:'', 
                                                                      name, '',installment.Deposit__c ,installment.Deposit__r.Customer__c));
        Map<String, String> variableMap = new Map<String, String>();
        
        if(is30Days) {
            //gen.writeNumberField('TemplateID', 3117693);
            mailjetTemplateName = 'NoPaymentReceivedAGLL30';
            //gen.writeStringField('Subject', 'Reminder - Deposit not yet received');
            mailSubject = 'Payment option picked, no payment received - 30 days';
        } else {
            //gen.writeNumberField('TemplateID', 3117694);
            mailjetTemplateName = 'NoPaymentReceivedAGLL60';
            /*if(installment.Is_Topup__c){
                gen.writeStringField('Subject', '60 Days reminder');
            }else{
                gen.writeStringField('Subject', 'Deposit to be deleted');
            }*/
            mailSubject = 'Payment option picked, no payment receieved, deleting deposit protection - 60 days';
            
        }
        
        variableMap.put('name',name);
		variableMap.put('dateDepositRegistered', String.valueOf(installment.Deposit__r.Date_Deposit_Received__c));
        variableMap.put('propertyAddress', installment.Deposit__r.Property_Address_WO_Country__c);
        
        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                       mailjetTemplateName, mailSubject));
        
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        /* Sending Email through MailJet Utility Class START */
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList)); 	  
        }
        /* Sending Email through MailJet Utility Class END */
        
    }
    
    @InvocableMethod(label='Send Topup' description='')
    public static void sendTopupEmails(List<ID> ids) {
        system.debug('>>>>>>'+ids.size());
        set<String> depositIds = new set<String>();
        list<Installment__c> installmentList = [Select Id,Deposit__c,Amount__c from Installment__c where Id IN: ids];
        map<string,Decimal> depositIdVsAmount = new map<string,Decimal>();
        map<string,list<Deposit_Allocation__c>> depositIdVsAllocations = new map<string,list<Deposit_Allocation__c>>();
        for(Installment__c inst : installmentList){
            depositIds.add(inst.Deposit__c);
            depositIdVsAmount.put(inst.Deposit__c,inst.Amount__c);
        }
        if(!depositIds.isEmpty()){

            list<Deposit_Allocation__c> allocationList = [Select Id,Deposit__c,Deposit__r.Customer_Email__c,Deposit__r.Customer_Name__c,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Name, 
                                                                    Deposit__r.Property_Address__c,
                                                                    Deposit__r.Deposit_Account_Number__c  from Deposit_Allocation__c where Deposit__c IN : depositIds];
            
            for(Deposit_Allocation__c allocation : allocationList){
                
                if(depositIdVsAllocations.containsKey(allocation.Deposit__c)){
                    list<Deposit_Allocation__c> all =  depositIdVsAllocations.get(allocation.Deposit__c);
                    all.add(allocation);
                    depositIdVsAllocations.put(allocation.Deposit__c,all);
                }else{
                    depositIdVsAllocations.put(allocation.Deposit__c,new list<Deposit_Allocation__c>{allocation});
                }
            }
            for(String depositId : depositIdVsAllocations.keySet()){
                
                list<Deposit_Allocation__c> allList = depositIdVsAllocations.get(depositId);
                
                sendEmailTopup(JSON.serialize(allList),depositIdVsAmount.get(depositId),allList[0].Deposit__r.Customer_Email__c,allList[0].Deposit__r.Customer_Name__c);
                
            }

        }
        
  	}
    
    @FUTURE(callout=true)
    public static void sendEmailHold(String depoIds) {

        set<Id> depositIds = (set<Id>)System.JSON.deserialize(depoIds, set<Id>.class);
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        // String fromAddress;
        // String fromName;
        //String toAddress;
        //String toName;
        
        //List<recipient> ParticipantList =(List<recipient>) JSON.deserialize(recList,List<recipient>.class);
        //Map<String,recipient> recMap = new Map<String,recipient>();
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
        for(Deposit__c dep : [Select Id,Customer_Name__c,Customer_Email__c,Property_Address__c,Deposit_Account_Number__c,(Select Id,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Name from Deposit_Allocations__r where Flag_Email__c = false) from Deposit__c where Id In: depositIds]){
            for(Deposit_Allocation__c allocation: dep.Deposit_Allocations__r)
            {
                
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                
                gen.writeStartObject();
                gen.writeStringField('Email', 'deposits@safedepositsscotland.com');
                gen.writeStringField('Name', 'deposits@safedepositsscotland.com');
            
                
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                
                gen.writeStartArray();
                gen.writeStartObject(); 
                
                gen.writeStringField('Email', String.isNotBlank(allocation.Deposit_Holder__r.personEmail)?allocation.Deposit_Holder__r.personEmail:''); 
    
                gen.writeStringField('Name', String.isNotBlank(allocation.Deposit_Holder__r.Name)?allocation.Deposit_Holder__r.Name:'');
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', 3100398); 
                gen.writeBooleanField('TemplateLanguage', true);
                
                gen.writeStringField('Subject', 'Confirmation of Deposit Protection');
                
                gen.writeFieldName('Variables');    
            
                gen.writeStartObject();
                
                if(String.isNotBlank(allocation.Deposit_Holder__r.Name))
                    gen.writeStringField('name',allocation.Deposit_Holder__r.Name);
                //gen.writeStringField('body',mailBody);
                //gen.writeStringField('date', todaysDateStr);
                gen.writeStringField('dan', dep.Deposit_Account_Number__c);
                gen.writeStringField('address', dep.Property_Address__c);
                gen.writeEndObject(); 
                
                gen.writeEndObject(); 
    
      
            } 
            //??????????????? for Agent 
    
            gen.writeStartObject(); 
            gen.writeFieldName('From');
            
            gen.writeStartObject();
            gen.writeStringField('Email', 'deposits@safedepositsscotland.com');
            gen.writeStringField('Name', 'deposits@safedepositsscotland.com');
        
            
            gen.writeEndObject();
            
            gen.writeFieldName('To');
            
            gen.writeStartArray();
            gen.writeStartObject(); 
            
            gen.writeStringField('Email', String.isNotBlank(dep.Customer_email__c)?dep.Customer_email__c:''); 
    
            gen.writeStringField('Name', String.isNotBlank(dep.Customer_Name__c)?dep.Customer_Name__c:'');
            gen.writeEndObject();      
            gen.writeEndArray();
            
            gen.writeNumberField('TemplateID', 3100398); 
            gen.writeBooleanField('TemplateLanguage', true);
            
            gen.writeStringField('Subject', 'Confirmation of Deposit Protection');
            
            gen.writeFieldName('Variables');    
        
            gen.writeStartObject();
            
            
            gen.writeStringField('name',String.isNotBlank(dep.Customer_Name__c)?dep.Customer_Name__c:'');
            //gen.writeStringField('body',mailBody);
            //gen.writeStringField('date', todaysDateStr);
            gen.writeStringField('dan', dep.Deposit_Account_Number__c);
            gen.writeStringField('address', dep.Property_Address__c);
            gen.writeEndObject(); 
            
            gen.writeEndObject();
        }
        
        try{
            
            gen.writeEndArray();
            gen.writeEndObject();
            String  jsonData =gen.getAsString();
            req.setBody(jsonData);
            system.debug(jsonData);
            Http http = new Http();
            
            HTTPResponse res = http.send(req); 
            if(res.getStatusCode() == 200){
                String resBody = res.getBody();
                if(!resBody.startsWith('[')){
                    resBody = '['+resBody+']';
                }
                //recipient rec = new recipient(acc.PersonEmail,acc.Name,caseId);
                //recMap.put(acc.PersonEmail,rec);
                //saveMessageDetailsAura(resBody,recMap,Subject,mailBody );
            }
            
            //system.debug('res-->>'+res.getBody());
        }
        catch(exception e){   
            //saveMessageDetails(resBody,recMap,Subject );
            system.debug(e);
            //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
        }
        //sendEmail( subject,  recList, variables, 'ZP7',  'mailJetZD');
        // recipient(String Email,String to,String recId);
        //Sent Mail by MailJet
    }
    
    @FUTURE(callout=true)
    public static void sendEmailTopup(String all,Decimal amount, String agentEmail, String agentName) {

        list<Deposit_Allocation__c> allocationList = (list<Deposit_Allocation__c>)System.JSON.deserialize(all, list<Deposit_Allocation__c>.class);
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        // String fromAddress;
        // String fromName;
        //String toAddress;
        //String toName;
        
        //List<recipient> ParticipantList =(List<recipient>) JSON.deserialize(recList,List<recipient>.class);
        //Map<String,recipient> recMap = new Map<String,recipient>();
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
        for(Deposit_Allocation__c allocation: allocationList)
        {
            
            gen.writeStartObject(); 
            gen.writeFieldName('From');
            
            gen.writeStartObject();
            gen.writeStringField('Email', 'deposits@safedepositsscotland.com');
            gen.writeStringField('Name', 'deposits@safedepositsscotland.com');
        
            
            gen.writeEndObject();
            
            gen.writeFieldName('To');
            
            gen.writeStartArray();
            gen.writeStartObject(); 
            
            gen.writeStringField('Email', String.isNotBlank(allocation.Deposit_Holder__r.personEmail)?allocation.Deposit_Holder__r.personEmail:''); 

            gen.writeStringField('Name', String.isNotBlank(allocation.Deposit_Holder__r.Name)?allocation.Deposit_Holder__r.Name:'');
            gen.writeEndObject();      
            gen.writeEndArray();
            
            gen.writeNumberField('TemplateID', 3117661); 
            gen.writeBooleanField('TemplateLanguage', true);
            
            gen.writeStringField('Subject', 'Topup Amount Received '+Amount);
            
            gen.writeFieldName('Variables');    
        
            gen.writeStartObject();
            
            if(String.isNotBlank(allocation.Deposit_Holder__r.Name))
                gen.writeStringField('name',allocation.Deposit_Holder__r.Name);
            //gen.writeStringField('body',mailBody);
            //gen.writeStringField('date', todaysDateStr);
            //gen.writeStringField('dan', allocation.Deposit__r.Deposit_Account_Number__c);
            //gen.writeStringField('address', allocation.Deposit__r.Property_Address__c);
            gen.writeEndObject(); 
            
            gen.writeEndObject(); 

  
        } 
        //??????????????? for Agent 

        gen.writeStartObject(); 
        gen.writeFieldName('From');
        
        gen.writeStartObject();
        gen.writeStringField('Email', 'deposits@safedepositsscotland.com');
        gen.writeStringField('Name', 'deposits@safedepositsscotland.com');
    
        
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        
        gen.writeStartArray();
        gen.writeStartObject(); 
        
        gen.writeStringField('Email', String.isNotBlank(agentEmail)?agentEmail:''); 

        gen.writeStringField('Name', String.isNotBlank(agentName)?agentName:'');
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 3117661); 
        gen.writeBooleanField('TemplateLanguage', true);
        
        gen.writeStringField('Subject', 'Topup Amount Received '+Amount);
        
        gen.writeFieldName('Variables');    
    
        gen.writeStartObject();
        
        
        gen.writeStringField('name',String.isNotBlank(agentName)?agentName:'');
        //gen.writeStringField('body',mailBody);
        //gen.writeStringField('date', todaysDateStr);
        //gen.writeStringField('dan', allocationList[0].Deposit__r.Deposit_Account_Number__c);
        //gen.writeStringField('address', allocationList[0].Deposit__r.Property_Address__c);
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        
        try{
            
            gen.writeEndArray();
            gen.writeEndObject();
            String  jsonData =gen.getAsString();
            req.setBody(jsonData);
            system.debug(jsonData);
            Http http = new Http();
            
            HTTPResponse res = http.send(req); 
            if(res.getStatusCode() == 200){
                String resBody = res.getBody();
                if(!resBody.startsWith('[')){
                    resBody = '['+resBody+']';
                }
                //recipient rec = new recipient(acc.PersonEmail,acc.Name,caseId);
                //recMap.put(acc.PersonEmail,rec);
                //saveMessageDetailsAura(resBody,recMap,Subject,mailBody );
            }
            
            //system.debug('res-->>'+res.getBody());
        }
        catch(exception e){   
            //saveMessageDetails(resBody,recMap,Subject );
            system.debug(e);
            //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
        }
        //sendEmail( subject,  recList, variables, 'ZP7',  'mailJetZD');
        // recipient(String Email,String to,String recId);
        //Sent Mail by MailJet
    }
    
}