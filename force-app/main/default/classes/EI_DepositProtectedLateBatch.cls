global class EI_DepositProtectedLateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    public String fromAddress;
    public String fromName;
    public String toAddress;
    public String toName;
    public Integer mailJetTemplateId;
    public String SUBJECT = 'Deposit Protected Late (registered)';
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
            String query = 'select id,Start_Date__c,createdDate,customer__r.PersonEmail,customer__r.Email__c,Property_Address_WO_Country__c,Protection_Start_Date__c,customer__r.Name,Status__c,Deposit_Amount__c,Property_Address__c,(select id,contact__c,Deposit_holder__r.Personemail,Deposit_holder__r.personcontactid,Contact__r.Email,Contact__r.firstname,Contact__r.name,Contact__r.lastname from  Deposit_Allocations__r where Role__c=\'Tenant\') from Deposit__c where WD_PD_Difference__c > 30 and DepositLatemailsent__c= true and id=\'a0L3H000000ZR68\'';
        // zString query = 'select id,account.Deposit_Protections__c,email,LastLoginDate,CreatedDate from user where IsActive=true and account.Deposit_Protections__c=0 and ContactId != null and id=\'0058E000006dCLS\' ';
        return Database.getQueryLocator(query);    
    }
    global void execute(Database.BatchableContext BC, List<Deposit__c> Depositlist) {
        
        list<Deposit__c> depositlist11 = new list <Deposit__c>();
        
        system.debug('line-->24' + Depositlist );
        
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        //EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
        /* Newly added code for Mailjet Utility Class END */
        
        for(Deposit__c d:Depositlist) {
            
            Deposit__c Depo = New Deposit__c ();
            Depo.Id =d.id;
            Depo.DepositLatemailsent__c =true;
            
            for(Deposit_Allocation__c ds: d.Deposit_Allocations__r)
            {
                Date fromDate = d.CreatedDate.Date();
                String fromDateStr = fromDate.day()+'/'+fromDate.month()+'/'+fromDate.year();
                Date startDate = d.Start_Date__c;
                String startDateStr = startDate.day()+'/'+startDate.month()+'/'+startDate.year();
                toAddress = ds.Deposit_holder__r.Personemail;
                toName = ds.Contact__r.name;
                propertyAddress = d.Property_Address_WO_Country__c;
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, '', Depo.Id,d.Customer__c));
                Map<String, String> variableMap = new Map<String, String>();
                variableMap.put('date', todayStr);
                variableMap.put('name', toName);
                //variableMap.put('DAN', d.Deposit_Account_Number__c);
                variableMap.put('from_date', fromDateStr);
                variableMap.put('start_date', startDateStr);
                variableMap.put('address', propertyAddress);
                //variableMap.put('scheme_signatory', schemeSignatory);
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'DepositLate', 
                                                                               'Information about your deposit - '+propertyAddress));
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            }
            depositlist11.add(Depo);
            
            // }
                        
        }
        
        /* Newly added code for sending mail through MailJet START */
        EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
    
        if(depositlist11.size()>0) {
            Database.update(depositlist11,false);  
        }
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
    
}