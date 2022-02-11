/**
* @who  Ashish Singh
* @what Send reminder emails to user who haven't secured their deposit
* @when 01/02/2021
**/
public class EI_depositReminderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
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
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Start_Date__c, Customer__c, CreatedBy.Email,Protected_Amount__c, Deposit_Amount__c,customer__r.PersonEmail,Customer__r.Name, ';
        query = query + 'Deposit_Account_Number__c, ';
        query = query + 'Property_Address__c, CreatedBy.Profile.name,Status__c, createdDate FROM Deposit__c ';
        query = query + 'WHERE  id=\'a0L3H000000ZR68\'';      
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Deposit__c> scope) {
        
        List<Deposit__c> depositlist = new List<Deposit__c>();
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('DepositReminderEmail'); 
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        schemeSignatory = templateId[0].Scheme_Signatory__c;
        schemeAddress = templateId[0].Scheme_Address__c;
        
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        //EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
        /* Newly added code for Mailjet Utility Class END */
        
        for(Deposit__c d:scope) {
            System.debug('d=>'+d);
            System.debug('System.today=>'+System.today());
            System.debug('d.createdDate=>'+d.CreatedDate.date());
            System.debug('d.createdDate + 1=>'+d.createdDate.addDays(1));
            System.debug('d.Status__c  =>'+d.Status__c);
            
            //Send Emails if deposit not secured for 24 hours of deposit creation
            
            if(d.createdDate.addDays(1)==System.today() && d.Status__c=='Registered (not paid)') {  
                //  if(d.Start_date__c.addDays(1)==System.today() && d.Status__c=='Registered (not paid)') {
                
                toAddress = d.customer__r.PersonEmail;
                toName = d.customer__r.Name;
                propertyAddress = d.Property_Address__c;
                amount = d.Protected_Amount__c; 
                daysRemaining = (System.today()).daysBetween(d.createdDate.addDays(30).date());
                //daysRemaining = (System.today()).daysBetween(d.Start_date__c.addDays(30));
                danNo = d.Deposit_Account_Number__c;
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, d.Id,d.Customer__c));
                Map<String, String> variableMap = new Map<String, String>();
                
                variableMap.put('date', todayStr);
                variableMap.put('name', toName);
                variableMap.put('address', propertyAddress);
                variableMap.put('amount', String.valueOf(amount));
                variableMap.put('bank_account_name', bankAccountName);
                variableMap.put('sort_code', sortCode);
                variableMap.put('account_number', accountNumber);
                variableMap.put('DAN_no', danNo);
                variableMap.put('scheme_address', schemeAddress);
                variableMap.put('days', String.valueOf(daysRemaining));
                //variableMap.put('scheme_signatory', schemeSignatory);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositReminderEmail', 'Reminder - Deposits awaiting payment'));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            }
            
            if(d.createdDate.addDays(10)==System.today() && d.Status__c=='Registered (not paid)') {  
                //if(d.Start_date__c.addDays(10)==System.today() && d.Status__c=='Registered (not paid)') {
                
                toAddress = d.customer__r.PersonEmail;
                toName = d.customer__r.Name;
                propertyAddress = d.Property_Address__c;
                amount = d.Protected_Amount__c; 
                //daysRemaining = (System.today()).daysBetween(d.createdDate.addDays(30).date());
                danNo = d.Deposit_Account_Number__c;
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, d.Id,d.Customer__c));
                Map<String, String> variableMap = new Map<String, String>();
                Date dateDepositRegistered = d.createdDate.date();
                String dateDepositRegisteredStr = dateDepositRegistered.day()+'/'+dateDepositRegistered.month()+'/'+dateDepositRegistered.year();
                
                // variableMap.put('date', String.valueOf(System.today().format()));
                variableMap.put('name', toName);
                variableMap.put('property_address', propertyAddress);
                variableMap.put('date_deposit_registered', dateDepositRegisteredStr);
                //  variableMap.put('bank_account_name', bankAccountName);
                // variableMap.put('sort_code', sortCode);
                //  variableMap.put('account_number', accountNumber);
                //  variableMap.put('DAN_no', danNo);
                //  variableMap.put('scheme_address', schemeAddress);
                //  variableMap.put('days', String.valueOf(daysRemaining));
                //variableMap.put('scheme_signatory', schemeSignatory);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositReminderEmailAfter10Days', 'Reminder - Deposit not yet received- '+propertyAddress));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            }
            
            if(d.createdDate.addDays(14)==System.today() && d.Status__c=='Registered (not paid)') {
                //if(d.Start_date__c.addDays(14)==System.today() && d.Status__c=='Registered (not paid)') {
                system.debug('148');
                
                toAddress = d.customer__r.PersonEmail;
                toName = d.customer__r.Name;
                propertyAddress = d.Property_Address__c;
                amount = d.Protected_Amount__c; 
                //daysRemaining = (System.today().adddays(14)).daysBetween(d.createdDate.addDays(30).date());
                daysRemaining = (System.today()).daysBetween(d.createdDate.addDays(30).date());
                danNo = d.Deposit_Account_Number__c; 
                bankAccountName = templateId[0].Scheme_Bank_Name__c;
                sortCode = templateId[0].Scheme_Sort_Code__c;
                accountNumber = templateId[0].Scheme_Bank_Account_Number__c;
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, d.Id,d.Customer__c));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', todayStr);
                variableMap.put('name', toName);
                variableMap.put('address', propertyAddress);
                variableMap.put('amount', String.valueOf(amount));
                variableMap.put('bank_account_name', bankAccountName);
                variableMap.put('sort_code', sortCode);
                variableMap.put('account_number', accountNumber);
                variableMap.put('DAN_no', danNo);
                variableMap.put('scheme_address', schemeAddress);
                variableMap.put('days', String.valueOf(daysRemaining));
                //variableMap.put('scheme_signatory', schemeSignatory);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositReminderEmail', 'Reminder - Deposits awaiting payment'));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            }
            
            if(d.createdDate.addDays(21)==System.today() && d.Status__c=='Registered (not paid)') {
                //   if(d.Start_date__c.addDays(21)==System.today() && d.Status__c=='Registered (not paid)') {
                
                toAddress = d.customer__r.PersonEmail;
                toName = d.customer__r.Name;
                propertyAddress = d.Property_Address__c;
                amount = d.Protected_Amount__c; 
                daysRemaining = (System.today()).daysBetween(d.createdDate.addDays(30).date());
                //  daysRemaining = (System.today()).daysBetween(d.Start_date__c.addDays(30));
                danNo = d.Deposit_Account_Number__c; 
                bankAccountName = templateId[0].Scheme_Bank_Name__c;
                sortCode = templateId[0].Scheme_Sort_Code__c;
                accountNumber = templateId[0].Scheme_Bank_Account_Number__c;
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, d.Id,d.Customer__c));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', todayStr);
                variableMap.put('name', toName);
                variableMap.put('address', propertyAddress);
                variableMap.put('amount', String.valueOf(amount));
                variableMap.put('bank_account_name', bankAccountName);
                variableMap.put('sort_code', sortCode);
                variableMap.put('account_number', accountNumber);
                variableMap.put('DAN_no', danNo);
                variableMap.put('scheme_address', schemeAddress);
                variableMap.put('days', String.valueOf(daysRemaining));
                //variableMap.put('scheme_signatory', schemeSignatory);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositReminderEmail', 'Reminder - Deposits awaiting payment'));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            }
            
            //if(d.createdDate.addDays(30)==System.today() && d.Status__c=='Registered (not paid)') {
            if(d.Start_date__c.addDays(30)==System.today() && d.Status__c=='Registered (not paid)') {
                
                Deposit__c Depo = New Deposit__c ();
                Depo.Id =d.id;
                Depo.Status__c= 'Deposit registration deleted';               
                
                toAddress = d.customer__r.PersonEmail;
                toName = d.customer__r.Name;
                propertyAddress = d.Property_Address__c;
                amount = d.Protected_Amount__c; 
                //  daysRemaining = (System.today().adddays(21)).daysBetween(d.createdDate.addDays(30).date());
                daysRemaining = 0;
                danNo = d.Deposit_Account_Number__c; 
                bankAccountName = templateId[0].Scheme_Bank_Name__c;
                sortCode = templateId[0].Scheme_Sort_Code__c;
                accountNumber = templateId[0].Scheme_Bank_Account_Number__c;
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, d.Id,d.Customer__c));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', todayStr);
                variableMap.put('name', toName);
                variableMap.put('address', propertyAddress);
                variableMap.put('amount', String.valueOf(amount));
                variableMap.put('bank_account_name', bankAccountName);
                variableMap.put('sort_code', sortCode);
                variableMap.put('account_number', accountNumber);
                variableMap.put('DAN_no', danNo);
                variableMap.put('scheme_address', schemeAddress);
                variableMap.put('days', String.valueOf(daysRemaining));
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositReminderEmail', 'Deposit to be deleted'));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
                depositlist.add(Depo);
                
            }
            
        }
        
        /* Newly added code for sending mail through MailJet START */
        if(emailWrapperList.size()>0) {
        	EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
        }
        /* Newly added code for sending mail through MailJet END */
        
        if(depositlist.size()>0){
            Database.update(depositlist,false);  
        }
        
    }
    
    public void finish(Database.BatchableContext bc) {
        //  System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        System.debug('Job'+job);
        // call some utility to send email
        //    EmailUtils.sendMessage(job, recordsProcessed);
    }
}