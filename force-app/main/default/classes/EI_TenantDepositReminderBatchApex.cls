public class EI_TenantDepositReminderBatchApex implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public String fromAddress;
    public String fromName;
    public String toAddress;
    public String toName;
    public Integer mailJetTemplateId;
    public String SUBJECT = 'Reminder: You have not sent the deposit – your deposit is not protected';
    public String propertyAddress;
    public Decimal amount;
    public String bankAccountName;
    public String schemeSignatory;
    public Integer daysRemaining;
    public String schemeAddress;
    public String danNo;
    public String sortCode;
    public String accountNumber;
    public String Depositlookuplink;
    
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
           String query ='select id,email,CreatedDate,accountid,ContactId,name,account.Deposit_allocations__c ,account.Deposit_Protections__c from user where IsActive=true  and  ContactId != null and account.Deposit_allocations__c=0 and account.Deposit_Protections__c=0 and User_Type__c=\'Tenant\' and id=\'0053H000001kRb5\'';
        system.debug('line-->10' +query );
        return Database.getQueryLocator(query);
    }   
    
    public void execute(Database.BatchableContext bc, List<User> useList) {
        
        system.debug('line-->28' +useList );
        list<user> userlist = new list<user>();
        list<string> flaglist = new list<string>();   
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        //EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
        /* Newly added code for Mailjet Utility Class END */
        
        for(user us :useList) {
            
            if((us.CreatedDate>=System.Today()-40) && (us.CreatedDate<System.Today()-39) ) {
                
                // List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('DepositReminderEmailForAGLL');
                Depositlookuplink = '<a href="https://staging-thedisputeservice.cs122.force.com/Sds/s/depositlookup">link to deposit lookup page</a>';
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(us.Email, us.Name, '', us.accountid,us.ContactId));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', todayStr);
                variableMap.put('name', toName);
                variableMap.put('Link_To_Deposit_lookup_Page', Depositlookuplink);
                //variableMap.put('scheme_signatory', schemeSignatory);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DeposiLinkReminderToTenant40Days', 'Your SafeDeposits account'));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            } 
            
            if((us.CreatedDate>=System.Today()-365) && (us.CreatedDate<System.Today()-364)) { 
                
                // List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('DepositReminderEmailForAGLL');
                Depositlookuplink = '<a href="https://staging-thedisputeservice.cs122.force.com/Sds/s/depositlookup">link to deposit lookup page</a>';
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(us.Email, us.Name, us.accountid,us.ContactId));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', todayStr);
                variableMap.put('name', toName);
                variableMap.put('link_to_deposit_lookup_page', Depositlookuplink);
                //variableMap.put('scheme_signatory', schemeSignatory);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DeposiLinkReminderToTenant1Year', 'We are closing your SafeDeposits account'));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            } 
            if((us.CreatedDate>=System.Today()-395) && (us.CreatedDate<System.Today()-394)) { 
                //  if((us.CreatedDate>=System.Today())){
                system.debug(' Line 179->>');
                // List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('DepositReminderEmailForAGLL');
                //  Depositlookuplink = '<a href="https://staging-thedisputeservice.cs122.force.com/Sds/s/depositlookup">link to deposit lookup page</a>';
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(us.Email, us.Name, us.accountid,us.ContactId));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', todayStr);
                variableMap.put('name', toName);
                // variableMap.put('link_to_deposit_lookup_page', Depositlookuplink);
                //variableMap.put('scheme_signatory', schemeSignatory);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DeposiLinkRemToTenantdeactivateaccount', 'We have closed your SafeDeposits account'));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
                User usr = new User();
                usr.id = us.id;
                usr.IsActive =false;
                userlist.add(usr);
                
            } 
            
        }
         if(userlist.size()>0){
            update userlist;
        }
        EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
        
    }
    
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('Job'+job);
    }
    
}