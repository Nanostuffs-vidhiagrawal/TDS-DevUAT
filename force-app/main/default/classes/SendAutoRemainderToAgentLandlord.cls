/*
* Class Name: SendAutoRemainderToTenant
* Description: Batch class to send the auotoreminder to tenant
* Test Class: TestSendAutoRemainderToTenant
* Date : 12th Jan 2021
*/
global class SendAutoRemainderToAgentLandlord implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    
    public Integer reminder15MailSend = Integer.valueOf(System.Label.FirstReminderMail);
    public Integer reminder30MailSend = Integer.valueOf(System.Label.ThirdReminderMail);
    public String fromAddress;
    public String fromName;
    public Integer mailJetTemplateId;
    public String schemeSignatory;
    public Integer thirtyMailJetTemplateId;
    public String thirtySchemeSignatory;
    
    /*
    * Method Name: start
    * Description: to query all the records
    * Parameters : Database.BatchableContext BC
    * Return Type: Database.QueryLocator
    * Date : 12th Jan 2021
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {            
        String query = 'Select id,Repayment_Request__r.id,Repayment_Request__r.Status__c,Repayment_Request__r.Total_Amount_By_Tenant__c, '
            +'CalculatePercent__c,Repayment_Request__r.Ten_Init_AgentNoRes__c,Repayment_Request__r.Deposit__r.Protected_Amount__c, '
            +'Repayment_Request__r.Deposit__r.Customer__r.Name,Repayment_Request__c,CreatedDate,AA_LL_Email__c,Repayment_Request__r.Case__c, '
            +'Repayment_Request__r.Deposit__r.Id, Is_Lead__c,Account__r.Email__c, Repayment_Requested_Mail_Sent__c, '
            +'Repayment_Request__r.Deposit__r.Property_Address__c, Account__r.Name, Account__r.PersonEmail, AL_ReqAmt__c, '
            +'Repayment_Request__r.Deposit__c, Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c, '
            +'Repayment_Request__r.Deposit__r.Name, Tenant_ReqAmt__c,Repayment_Request__r.Deposit__r.Scheme_Name__c,Account__r.RecordType.Name, '
            +'Account__r.Id from Repayment_Request_Line__c where  CalculatePercent__c != 0.0 and '
            +'Repayment_Request__r.Status__c=\'Repayment requested - tenant\' and Repayment_Request__r.Ten_Init_AgentNoRes__c= false';
        system.debug('+++++++++++++++'+query);
        return Database.getQueryLocator(query);
    }
    
    /*
    * Method Name: execute.
    * Description: to process all the records
    * Parameters : Database.BatchableContext BC, List<Repayment_Request_Line__c> repaymentRequestLineList
    * Return Type: void
    * Date : 12th Jan 2021
    */
    global void execute(Database.BatchableContext BC, List<Repayment_Request_Line__c> repaymentRequestLineList) {
        system.debug('++++++repaymentRequestLineList+++++++++'+repaymentRequestLineList);
        Map<Id,String> mapDepositIdDepositStatus = new Map<Id,String>();
        List<Case> listCaseRecords = new List<Case>();
        
        //Date firstMailDaysDate = System.today().addDays(-reminder15MailSend);
        //Date lastMailDaysDate = System.today().addDays(-reminder30MailSend);
        Set<Id> AccountIdList =new Set<Id>();
        Set<Id> depositId =new Set<Id>();
        Decimal depositAmount=0.0;
        Decimal percentAmount = 0.0;
        Decimal AgentAmount = 0.0;
        
        List<Repayment_Request__c> repaymentList = new List<Repayment_Request__c>();
        String jsonData;
        String TDate = String.valueOf(System.today());
        map<Id,Id> DepAccId=new map<Id,Id>();
        map<Id,Id> CaseAccId=new map<Id,Id>();
		
        /* Newly added code for Mailjet Utility Class START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        /* Newly added code for Mailjet Utility Class END */
        
        for(Repayment_Request_Line__c repaymentRequestLine : repaymentRequestLineList) {
            list<string> flaglist = new list<string>();
            Date firstMailDaysDate =EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(repaymentRequestLine.Repayment_Requested_Mail_Sent__c, 15);
            Date lastMailDaysDate =EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(repaymentRequestLine.Repayment_Requested_Mail_Sent__c, 30);
            system.debug('@@dat '+firstMailDaysDate +' ## '+lastMailDaysDate );
            //15 and 25 days reminder date
            if(System.today()==firstMailDaysDate){
                mapDepositIdDepositStatus.put(repaymentRequestLine.Repayment_Request__r.Case__c,Label.No_response_from_agent_landlord);
            }
            
            //30 days reminder date
            if(System.today()==lastMailDaysDate && repaymentRequestLine.Repayment_Request__r.Ten_Init_AgentNoRes__c==false) {
                system.debug(repaymentRequestLine.Account__r.id +' && '+repaymentRequestLine.Repayment_Request__r.Deposit__r.Id);
                mapDepositIdDepositStatus.put(repaymentRequestLine.Repayment_Request__r.Case__c,Label.NoDispute_Repaid);
                AccountIdList.add(repaymentRequestLine.Account__r.id);
                DepAccId.put(repaymentRequestLine.Account__r.id,repaymentRequestLine.Repayment_Request__r.Deposit__r.Id);
                depositId.add(repaymentRequestLine.Repayment_Request__r.Deposit__c);
                
                depositAmount = repaymentRequestLine.Repayment_Request__r.Deposit__r.Protected_Amount__c;
                percentAmount = repaymentRequestLine.CalculatePercent__c;
                AgentAmount = repaymentRequestLine.Repayment_Request__r.Total_Amount_By_Tenant__c;
                
                CaseAccId.put(repaymentRequestLine.Account__r.id,repaymentRequestLine.Repayment_Request__r.Case__c);
                Repayment_Request__c requestRepay = new Repayment_Request__c(id=repaymentRequestLine.Repayment_Request__r.id,Ten_Init_AgentNoRes__c=true);
                repaymentList.add(requestRepay);  
            }
            if(Label.Tenant.equalsIgnoreCase(repaymentRequestLine.Account__r.RecordType.Name)){
                if(flaglist.size() > 0 &&  !(flaglist.contains(repaymentRequestLine.id))){
                    //gen.writeString(','); 
                }
                system.debug('Line 50');
                
                /* Newly added code for adding recipients, variables, template name, Subject START */
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(repaymentRequestLine.Account__r.PersonEmail, 
                                                                              repaymentRequestLine.Account__r.Name, 
                                                                              repaymentRequestLine.Repayment_Request__r.Deposit__c, repaymentRequestLine.Account__r.personContactId));
                Map<String, String> variableMap = new Map<String, String>();
                Date responseDate = EI_UtilityClassForPayments.dueDateMethod(System.today(), 30);
                String responseDateStr = responseDate.day()+'/'+responseDate.month()+'/'+responseDate.year();
                
                variableMap.put('date', todayStr);
                variableMap.put('Name', repaymentRequestLine.Repayment_Request__r.Deposit__r.Customer__r.Name);
                variableMap.put('Address', repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address__c);
                variableMap.put('DAN', repaymentRequestLine.Repayment_Request__r.Deposit__r.Name);
                variableMap.put('responseDate', responseDateStr);
                variableMap.put('linkToLoginAndRespond', 'https://staging-thedisputeservice.cs122.force.com/Sds/s/respondtorequest?depositId='
                                +repaymentRequestLine.Repayment_Request__r.Deposit__c);
                
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'ReminderToAgentLandlord', 
                                                                               'Reminder to respond to deposit repayment request - '
                                                                               +repaymentRequestLine.Repayment_Request__r.Deposit__r.Property_Address_WO_Country__c));
                
                /* Newly added code for adding recipients, variables, template name, Subject END */
                
            }
        }
        
        /* Newly added code for sending mail through MailJet START */
        EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));
        /* Newly added code for sending mail through MailJet END */
        
        try{
            update repaymentList;
            
            List<Account> AccBankDetail=new List<Account>();
            if(AccountIdList !=null && AccountIdList.size()>0)
            {
                AccBankDetail=[Select id,PersonContactId ,(Select id,ValidInternationBankDetails__c,Contact__c,Contact__r.name,International_Bank_Account_Holder_Name__c,International_Account_Number__c,International_Bank_Name__c,IBAN__c,Bank_Account_Holder_Name__c,Account__r.Id,Account_Number__c,Sort_Code__c,Bank_Name__c from Bank_Accounts__r) from Account where Id IN :AccountIdList and recordtype.Name = 'Tenant'];
            }
            
            for(Id caseId : mapDepositIdDepositStatus.keyset()){
                Case case1 = new Case(id=caseId);
                case1.Status = mapDepositIdDepositStatus.get(caseId);
                listCaseRecords.add(case1);
            }
            
            if(!listCaseRecords.isEmpty()){
                update listCaseRecords;
            }
            //List<cpm__Installment__c> Installmentrec=new List<cpm__Installment__c>();
            List<Installment__c> Installmentrec=new List<Installment__c>();
            
            //List<cpm__Payment__c> payment=new List<cpm__Payment__c>();
            //
            List<Inbound_Report__c> payment=new List<Inbound_Report__c>();
            Integer accSize = AccBankDetail.size();
            //Decimal breakAmount = depositAmount/accSize;
            Decimal divideAmt = percentAmount/100;
            Decimal breakAmount = divideAmt * depositAmount;
            system.debug('@@DepAccId '+DepAccId);
            if(AccBankDetail !=null && AccBankDetail.size()>0){
                for(Account Acc: AccBankDetail)
                {
                    
                    if(Acc.Bank_Accounts__r.size() == 0) {
                        
                        Installmentrec.add(new Installment__c(Contact__c =Acc.PersonContactId,Created_at__c= date.today(),
                                                              Credit_note_reference__c ='creditReference',Payment_reference__c ='paymentReference',
                                                              Amount__c =breakAmount,Deposit__c =DepAccId.get(Acc.id),Status__c ='Pending processing',
                                                              Case__c =CaseAccId.get(Acc.id)
                                                              
                                                             ));
                    }
                    else {
                        
                        for(Bank_Account__c bankdetails:Acc.Bank_Accounts__r)
                        {
                            system.debug(Acc.id+' @@@1 '+DepAccId.get(Acc.id));
                            system.debug(bankdetails.Account__r.id +' @@@2 '+DepAccId.get(bankdetails.Account__r.id));
                            if(!bankdetails.ValidInternationBankDetails__c) {
                                
                                Installmentrec.add( new Installment__c(Contact__c =bankdetails.Contact__c, Created_at__c= date.today(),
                                                                       Credit_note_reference__c ='creditReference',Payment_reference__c ='paymentReference',
                                                                       Bank_account_holder_name__c=bankdetails.International_Bank_Account_Holder_Name__c,
                                                                       Bank_account_number__c =bankdetails.International_Account_Number__c,Status__c ='Pending processing',
                                                                       Bank_name__c =bankdetails.International_Bank_Name__c,Amount__c =breakAmount,Deposit__c =DepAccId.get(bankdetails.Account__r.id),
                                                                       Case__c =CaseAccId.get(Acc.id)
                                                                      ));
                            }
                            else {
                                
                                Installmentrec.add( new Installment__c(Contact__c =bankdetails.Contact__c, Created_at__c= date.today(),
                                                                       Credit_note_reference__c ='creditReference',Payment_reference__c ='paymentReference',Status__c ='Pending processing',
                                                                       Bank_account_holder_name__c=bankdetails.Bank_Account_Holder_Name__c,
                                                                       Bank_account_number__c =bankdetails.Account_Number__c,Bank_sort_code__c = bankdetails.Sort_Code__c,
                                                                       Bank_name__c =bankdetails.Bank_Name__c,Amount__c =breakAmount,Deposit__c =DepAccId.get(bankdetails.Account__r.id),
                                                                       Case__c =CaseAccId.get(Acc.id)/*,cpm__Custom_IBAN__c =string.valueof(bankdetails.Account_Number__c)*/
                                                                      ) );                                                       
                                
                            }
                            
                        }
                    }
                }
                
                if(Installmentrec!=null && Installmentrec.size()>0)
                {
                    insert Installmentrec;
                    
                    for(Installment__c cmpIns: Installmentrec)
                    {
                        if(cmpIns.Bank_sort_code__c != null) {
                            
                            payment.add(new Inbound_Report__c(Installment__c =cmpIns.id, 
                                                              Collection_Date__c=date.today(),
                                                              Amount__c =cmpIns.Amount__c));
                        }
                        else {
                            payment.add(new Inbound_Report__c(Installment__c =cmpIns.id,Collection_Date__c=date.today(),
                                                              Amount__c =cmpIns.Amount__c)) ;
                        }
                        
                    }
                    if(payment!=null && payment.size()>0)
                        insert payment;
                }
            }
        }
        catch(exception e){
            system.debug('++++++++++e.getlinenumber()+++++'+e.getlinenumber());
            system.debug('++++++++++e.getmessage()+++++'+e.getmessage());
        }       
        
    }
    
    /*
    * Method Name: finish
    * Description: 
    * Parameters : Database.BatchableContext BC
    * Return Type: void
    * Date : 12th Jan 2021
    */
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job  = [SELECT Id, Status, NumberOfErrors,
                             JobItemsProcessed,
                             TotalJobItems, CreatedBy.Email
                             FROM AsyncApexJob
                             WHERE Id = :bc.getJobId()];
        System.debug('Job'+job);
    }
    
}