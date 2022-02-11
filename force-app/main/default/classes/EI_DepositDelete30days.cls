/**
* @who  Ashish Singh
* @what Send reminder emails to user who haven't secured their deposit
* @when 01/02/2021
**/
public class EI_DepositDelete30days implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
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
        String query = 'SELECT Id, Start_Date__c, Customer__c,Property_Address_WO_Country__c, CreatedBy.Email,Protected_Amount__c, Deposit_Amount__c,customer__r.PersonEmail,Customer__r.Name, ';
        query = query + 'Deposit_Account_Number__c, ';
        query = query + 'Property_Address__c, CreatedBy.Profile.name,Status__c, createdDate FROM Deposit__c ';
        query = query + 'WHERE  id=\'a0L3H000000OQix\'';      
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Deposit__c> scope) {
        
        list<Deposit__c> depositlist = new list <Deposit__c>();
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        //EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
        /* Newly added code for Mailjet Utility Class END */
        
        for(Deposit__c d:scope) {
            System.debug('d=>'+d);
            System.debug('System.today=>'+System.today());
            System.debug('d.createdDate=>'+d.CreatedDate.date());
            System.debug('d.createdDate + 1=>'+d.createdDate.addDays(1));
            System.debug('d.Status__c  =>'+d.Status__c);
            
            
            
            //Send Emails if deposit not secured for 24 hours of deposit creation
            list<string> flaglist = new list<string>();
            
            if(d.Start_Date__c.addDays(1)==System.today() && d.Status__c=='Registered (not paid)') {
                
                Deposit__c Depo = New Deposit__c ();
                Depo.Id =d.id;
                Depo.Status__c= 'Deposit registration deleted';
                Date dateDepositRegistered = d.CreatedDate.date();
                String dateDepositRegisteredStr = dateDepositRegistered.day()+'/'+dateDepositRegistered.month()+'/'+dateDepositRegistered.year();
                    
                if(d.customer__r.PersonEmail!=null){
                toAddress = d.customer__r.PersonEmail;
                }
                else{
                 toAddress = d.customer__r.Email__c;
                }
                toName = d.customer__r.Name;
                propertyAddress = d.Property_Address_WO_Country__c;
                amount = d.Protected_Amount__c; 
                 /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, '', Depo.Id,d.Customer__c));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('Date', todayStr);
                variableMap.put('name', toName);
            	//variableMap.put('DAN', d.Deposit_Account_Number__c);
                variableMap.put('Date_deposit_registered', dateDepositRegisteredStr);
                variableMap.put('Property_address', propertyAddress);
                //variableMap.put('scheme_signatory', schemeSignatory);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositReminderEmail30Days', 
                                                                               'Deposit to be deleted - '+propertyAddress));
                /* Newly added code for adding recipients, variables, template name, Subject END */
				
                depositlist.add(Depo);
                
            }
                        
        }
        
        /* Newly added code for sending mail through MailJet START */
        EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
    
        if(depositlist.size()>0){
            Database.update(depositlist,false);  
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
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