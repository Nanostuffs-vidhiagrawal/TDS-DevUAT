global class EI_DeactivateUser_NLD implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public String fromAddress;
    public String fromName;
    public String toAddress;
    public String toName;
    public Integer mailJetTemplateId;
    public String SUBJECT = 'Update about your SafeDeposits Scotland account ';
    public String propertyAddress;
    public Decimal amount;
    public String bankAccountName;
    public String schemeSignatory;
    public Integer daysRemaining;
    public String schemeAddress;
    public String danNo;
    public String sortCode;
    public String accountNumber;
    global Database.QueryLocator start(Database.BatchableContext BC){
       // String query = 'Select id,account.Deposit_Protections__c,Name,email,LastLoginDate,CreatedDate from user where IsActive=true and account.Deposit_Protections__c=0 and ContactId != null ';
        String query = 'Select Id, Account.Deposit_Protections__c, ContactId, Name, Email, LastLoginDate, CreatedDate from User '
            			+'where IsActive=true and account.Deposit_Protections__c=0 and ContactId != null and Id=\'0053H000001VW8l\' ';
        return Database.getQueryLocator(query);    
    }
    global void execute(Database.BatchableContext BC, List<User> userList){
        system.debug('userList-->'+userList.size());
        system.debug('userList-->'+userList);
        List<user> userlisttoupdate =new list<user>(); 
        String jsonData;
        
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Utility mailjet END */
        
        for(user usr:userList)
        {
            dateTime lastDate = null;
            if(usr.LastLoginDate !=null)
            {
                lastDate = usr.LastLoginDate;
            }
            else
            {
                lastDate = usr.CreatedDate;
            }
            if(math.abs((Date.valueOf(lastDate)).daysBetween(system.today())) >= 365)
            { 
                userlisttoupdate.add(new user(id= usr.id,IsActive =false));
                
                toAddress = usr.Email;
                toName = usr.Name;
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(usr.Email, usr.Name, '', usr.ContactId,usr.ContactId));
                Map<String, String> variableMap = new Map<String, String>(); 
                variableMap.put('name', usr.Email);
                variableMap.put('date', todayStr);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'SDSAccountDeactivation', 
                                                                               'Are you still using your SafeDeposits account?'));
                                                                               /*'Frozen account - after 12 months of no live deposits'*/
				/* Newly added code for adding recipients, variables, template name, Subject START */
				
            }
        }
        try{
            if(userlisttoupdate.size() > 0)
            {
                
                /* Send Email from Utility Class START */
                if(emailWrapperList.size()>0) {
                    EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList)); 	  
                }
                /* Send Email from Utility Class END */
                
                Database.update(userlisttoupdate,false);
            }  
        }
        catch(exception e){   
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}