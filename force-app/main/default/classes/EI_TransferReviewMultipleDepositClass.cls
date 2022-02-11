public without sharing class EI_TransferReviewMultipleDepositClass {
    
    
    // This method is using for fetch the transferrable deposits of logged in Agent/Landlord //
    @Auraenabled
    public static List<depositListWrapper> getDepositInformation(String branchId) {
        List<depositListWrapper> lstdepositListWrapper = new List<depositListWrapper>(); 
        try{
            Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId; 
            
            if(branchId == null){
                for(Deposit__c deposit :[SELECT Id,Name,Property_Address__c,Protected_Amount__c,Customer__c,Customer__r.Name,Number_of_Tenants__c,
                                         Deposit_Amount__c,Bulk_transfer_attempts__c, BatchID__c, No_of_attempt__c, Transfer_verified__c,
                                         (select id,Deposit_Holder__r.LastName from Deposit_Allocations__r where Role__c ='Tenant')
                                         from Deposit__c where Customer__c =:accountid and  Status__c in ('Deposits held by scheme','Repayment requested by tenant','Repayment requested by agent/landlord','Repayment not agreed - In self-resolution','Repayment not agreed - In dispute resolution','No response from agent/landlord – chasing agent/landlord response to request','Repayment requested - no response from tenant')
                                         and Deposit_Transferred__c=false]){
                                             lstdepositListWrapper.add(new depositListWrapper(false,deposit));                   
                                         }
            }
            else{
                for(Deposit__c deposit :[SELECT Id,Name,Property_Address__c,Protected_Amount__c,Customer__c,Customer__r.Name,Number_of_Tenants__c,
                                         Deposit_Amount__c,Bulk_transfer_attempts__c, BatchID__c, No_of_attempt__c, Transfer_verified__c,
                                         (select id,Deposit_Holder__r.LastName from Deposit_Allocations__r where Role__c ='Tenant')
                                         from Deposit__c where Customer__c =:accountid and  Status__c in ('Deposits held by scheme','Repayment requested by tenant','Repayment requested by agent/landlord','Repayment not agreed - In self-resolution','Repayment not agreed - In dispute resolution','No response from agent/landlord – chasing agent/landlord response to request','Repayment requested - no response from tenant')
                                         and Deposit_Transferred__c=false and branch__c =:branchId]){
                                             lstdepositListWrapper.add(new depositListWrapper(false,deposit));                   
                                         }
            }
            return lstdepositListWrapper;
        }
        catch (Exception e) {
            return lstdepositListWrapper;
        }
        
    }
    
    
    @AuraEnabled
    public static List<depositemailgroupWrapper> viewtransferreddeposits(String branchId) {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId; 
        set<string> listofemail =new set<string> ();
        Map<Id, Deposit__c> mapOfDeposits = new Map<Id, Deposit__c>();
        
        if(branchId == null){
            for(Deposit__c deposit : [Select id,New_Customer_Email__c,Customer_email__c,Transfer_Deposit_start_date__c,
                                      Name,Property_Address__c,Protected_Amount__c,Number_of_Tenants__c,
                                      LastModifiedDate,Deposit_Amount__c,Bulk_transfer_attempts__c, BatchID__c, No_of_attempt__c, Transfer_verified__c,
                                      (select id,Deposit_Holder__r.LastName from Deposit_Allocations__r where Role__c ='Tenant')
                                      from deposit__C 
                                      where New_Customer_Email__c !=null and Deposit_Transferred__c=true 
                                      and  Customer__c =:accountid and Transfer_Deposit_start_date__c !=null ])
            {
                listofemail.add(deposit.New_Customer_Email__c);
                mapOfDeposits.put(deposit.Id, deposit);
            }
        }
        else{
            for(Deposit__c deposit : [Select id,New_Customer_Email__c,Customer_email__c,Transfer_Deposit_start_date__c,
                                      Name,Property_Address__c,Protected_Amount__c,Number_of_Tenants__c,
                                      LastModifiedDate,Deposit_Amount__c,Bulk_transfer_attempts__c, BatchID__c, No_of_attempt__c, Transfer_verified__c,
                                      (select id,Deposit_Holder__r.LastName from Deposit_Allocations__r where Role__c ='Tenant')
                                      from deposit__C 
                                      where New_Customer_Email__c !=null and Deposit_Transferred__c=true 
                                      and Customer__c =:accountid and Transfer_Deposit_start_date__c !=null and branch__c =:branchId])
            {
                listofemail.add(deposit.New_Customer_Email__c);
                mapOfDeposits.put(deposit.Id, deposit);
            }
        }
        
        Map<string,list<depositListWrapper>> acctmap = new Map<string,list<depositListWrapper>>();
        List<depositemailgroupWrapper> finalwrapperlist = new List<depositemailgroupWrapper>();
        Integer index = 0;
        for(string rep : listofemail) {   
            Set<Date> uniquedate = new Set<Date>();
            Map<Id, Date> mapOfDepIdWithDate = new Map<Id, Date>();
            Map<Date, List<Id>> mapOfDate = new Map<Date, List<Id>>();
            for(Deposit__c depo :mapOfDeposits.values()) {
                if(rep == depo.New_Customer_Email__c) {
                    DateTime dT = depo.Transfer_Deposit_start_date__c;
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    uniquedate.add(myDate);
                    mapOfDepIdWithDate.put(depo.Id, myDate);
                    
                }
            } 
            
            // Wrapping the current iteration of Email with Unique Deposit Transfrer Date
            
            for(Date uniqDt:uniquedate) { 
                List<depositListWrapper> listdepositwrap =  new List<depositListWrapper>();
                Integer countdeposit = 0;
                
                Decimal totalamount=0;
                for(String depositId : mapOfDepIdWithDate.keySet()) {
                    if(uniqDt==mapOfDepIdWithDate.get(depositId)) {
                        countdeposit++;
                        totalamount =totalamount+mapOfDeposits.get(depositId).Protected_Amount__c;
                        listdepositwrap.add(new depositListWrapper(false,mapOfDeposits.get(depositId)));
                    }
                }
                
                finalwrapperlist.add(new depositemailgroupWrapper(false, index, rep, totalamount, countdeposit, uniqDt, listdepositwrap));
                index++;
            }
        }   
        
        return  finalwrapperlist ;
        
    }
    
    /* Wrapper class for checkbox with deposit */  
    public class depositListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Deposit__c objDeposit{get;set;}
        public depositListWrapper(boolean isChecked, Deposit__c objDeposit){
            this.isChecked = isChecked;
            this.objDeposit = objDeposit;
        }
    }
    
    /* Wrapper class with unique email and date transferred combination */  
    public class depositemailgroupWrapper {
        @AuraEnabled public  Boolean isSelectAll {get;set;}
        @AuraEnabled public  String useremail {get;set;}
        @AuraEnabled public  Decimal totalamount {get;set;}
        @AuraEnabled public  Integer countdeposit{get;set;}
        @AuraEnabled public  Date uniqDate{get;set;}
        @AuraEnabled public  Decimal indexNumber{get;set;}
        
        @AuraEnabled public  List<depositListWrapper> Depositlistwrapper{get;set;}
        public depositemailgroupWrapper(Boolean isSelectAll,decimal i,String useremail, Decimal totalamount, Integer countdeposit, Date uniqDate, 
                                        List<depositListWrapper> Depositlistwrapper) 
        {
            this.isSelectAll=isSelectAll;
            this.indexNumber=i;
            this.uniqDate=uniqDate;
            this.useremail = useremail;
            this.totalamount = totalamount;
            this.countdeposit = countdeposit;
            this.Depositlistwrapper =Depositlistwrapper; 
        }
    }
    
    @Auraenabled
    public static string transferDeposit(list<string> selectedDepositID,string emailValue )
    {
        List<Case> listCase = new List<Case>();
        list<Deposit__c> depositToUpadte  = new list<Deposit__c>();
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
        List<User> listUser = new List<User>();
        listUser = [Select id,Email,ContactId,User.Name,AccountId,Contact.Account.Email__c,Profile.Name,Contact.Account.Name from User where Email =:emailValue and Isactive=true limit 1];
        Boolean checkfortenant  = false;
        
        if(listUser.size() > 0)
        {
            if(listUser[0].Profile.Name =='Tenant') 
            {
                checkfortenant = true; 
            }
        }
        
        if(checkfortenant)
        {
            return 'Email is exists for Tenant';
        }
        else
        {
            for(string depositId : selectedDepositID )
            {
                Case newCase = new Case();
                Deposit__c deposit = new Deposit__c();
                deposit.Id = depositId;
                deposit.Deposit_Transferred__c = true;
                deposit.Transfer_Deposit_start_date__c = system.now();
                if(listUser.size() > 0)
                {
                    if(listUser[0].AccountId != null)
                    {
                        deposit.Deposit_Transferred_to_Account__c = listUser[0].AccountId;
                        deposit.New_Customer_Email__c = emailValue;
                        newCase.AccountId=listUser[0].AccountId;
                    }
                    
                }
                else 
                {
                    deposit.New_Customer_Email__c = emailValue;
                }
                depositToUpadte.add(deposit);
                newCase.RecordTypeId = caseRecordType;
                newCase.Deposit_Account_Number__c = deposit.Id;
                newCase.OwnerId =  UserInfo.getUserId();
                newCase.Status=Label.Deposit_transfer_requested;
                newCase.Scheme__c = 'SafeDeposits Scotland';
                listCase.add(newCase);
            }
            
            try{
                if (listCase.size() >0)
                {
                    insert listCase;
                }
                if (depositToUpadte.size() >0)
                {
                    update depositToUpadte;
                }
                
                // ============send Email from mailJet ===============
                List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
                Date todayDate = System.today();
                String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
                
                List<User> receivingUserList = [SELECT Id, Email, Name, Contact.Name, ContactId, AccountId, Contact.Email FROM User where Email =:emailValue];
                Map<String, User> receivingUserMap = new Map<String, User>();
                System.Debug('receivingUserList => ' + receivingUserList);
                
                user currentUser = [select id, Email, Name, AccountId, ContactId from user where id = :UserInfo.getUserId()];
                // if Case open against transfer AC3.2 (3149803) => receiving agent/landlord
                set<Id> caseIdSet = new set<Id>();
                for(Case c: listCase){
                	caseIdSet.add(c.Id);
                }
                if(caseIdSet.size() > 0 && receivingUserList.size() > 0 ){
                    User receivingUser = receivingUserList[0];
                    for(Case cs : [Select Id, Status, Deposit_Account_Number__r.Name, Deposit_Account_Number__r.Property_Address__c, Deposit_Account_Number__r.Status__c From Case Where Id IN:caseIdSet 
                                   and status IN('Tenant changeover initiated - tenant', 'Tenant changeover initiated - agent/landlord', 'Repayment requested - tenant', 'Repayment requested - agent/landlord',
                                                 'Repayment requested - no response from tenant', 'Repayment requested - no response from agent/landlord', 'Repayment disputed - self-resolution', 'Evidence gathering AA/LL', 'Evidence gathering TT')])
                    {
                        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(receivingUser.Email, receivingUser.Contact.Name, cs.Id, receivingUser.ContactId));					
                        Map<String, String> variableMap = new Map<String, String>(); 
						
                        variableMap.put('date', todayStr);
                        variableMap.put('name', receivingUser.Contact.Name);
                        variableMap.put('DAN', cs.Deposit_Account_Number__r.Name);
                        variableMap.put('deposit_address', cs.Deposit_Account_Number__r.Property_Address__c);
                        variableMap.put('deposit_status', cs.Deposit_Account_Number__r.Status__c);
                        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                       'CaseOpenAgainstBulkTransfer', 
                                                                                       'Case open against transfer'));
                    }
                }
                // ============send Email from mailJet ===============
                // if transfer success send to non member(not exist in System) AC 3.16 (3149813) => receiving agent/landlord
                if(listUser.size() <= 0){
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(emailValue, emailValue.substringBefore('@'), '', ''));					
                    Map<String, String> variableMap = new Map<String, String>(); 
                    
                    variableMap.put('date', todayStr);
                    variableMap.put('name', emailValue.substringBefore('@'));
                    variableMap.put('number_of_deposits_in_transfer', String.valueOf(selectedDepositID.size()));
                    String link_to_create_an_account = '<a href="https://staging-thedisputeservice.cs122.force.com/Sds/s">link to create an account</a>';
                    variableMap.put('link_to_create_an_account', link_to_create_an_account);
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'TransferBulkDepositsToNonMember', 
                                                                                   'Transfer deposits- non member'));
                }else{
                    // if transfer success send to any landlord/agent AC 3.17 (3149819) => receiving agent/landlord
                    User receivingUser = receivingUserList[0];
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(receivingUser.Email, receivingUser.Contact.Name, receivingUser.AccountId, receivingUser.ContactId));					
                    Map<String, String> variableMap = new Map<String, String>(); 
                    
                    variableMap.put('date', todayStr);
                    variableMap.put('name', receivingUser.Contact.Name);
                    variableMap.put('number_of_deposits_in_transfer', String.valueOf(selectedDepositID.size()));
                    String link_to_verify_deposits = '<a href="https://staging-thedisputeservice.cs122.force.com/Sds/s/bulkactions">link to verify deposits</a>';
                    variableMap.put('link_to_verify_deposits', link_to_verify_deposits);
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'TransferBulkDepositsToMember', 
                                                                                   'Transfer deposits - member'));
                }
                
                // if transfer success send to transferring agent/Landlord AC 3.18(3149822) => sending agent/landlord
                if(receivingUserList.size() > 0){
                    User receivingUser = receivingUserList[0];
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(currentUser.Email, currentUser.Name, currentUser.AccountId, currentUser.ContactId));					
                    Map<String, String> variableMap = new Map<String, String>();
                    
                    variableMap.put('date', todayStr);
                    variableMap.put('name', currentUser.Name);
                    variableMap.put('number_of_deposits_in_transfer', String.valueOf(selectedDepositID.size()));
                    variableMap.put('name_of_receiving_party', receivingUser.Contact.Name);
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                   'ConfirmationOfBulkDepositTransfer', 
                                                                                   'Confirmation of transfer'));
                }
                if(emailWrapperList.size()>0) {
                    EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
                }
                return 'deposit transferred';
            }
            catch(exception e)
            {
                return string.valueof(e);
            }
            
        }
        
        
    }
    
    @Auraenabled
    public static string cancelSingleDeposit(string selectedDepositId)
    {
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
        list<Deposit__c> depositrec = [select id, Deposit_Transferred__c, Transfer_Deposit_start_date__c, Deposit_Transferred_to_Account__c, 
                                       New_Customer_Email__c, Property_Address__c, Customer_Name__c, 
                                       (select id from Cases__r where recordtypeid =:caseRecordType and status =:Label.Deposit_transfer_requested  order by lastmodifieddate desc limit 1 ) 
                                       from Deposit__c where id =:selectedDepositId and Deposit_Transferred__c=true]; 
        list<Deposit__c> depositToUpadte =new list<Deposit__c>();
        list<case> caseToUpdate = new list<Case>();
        User receivingUser = new User();
        
        Savepoint sp = Database.setSavepoint();
        if(depositrec.size() > 0)
        {
            Deposit__c dep = new Deposit__c(id =depositrec[0].id,
                                            Deposit_Transferred__c=false,
                                            Transfer_Deposit_start_date__c =null,
                                            Deposit_Transferred_to_Account__c = null,
                                            New_Customer_Email__c =''
                                           );
            depositToUpadte.add(dep);
        }
        
        if(depositrec[0].Cases__r.size() >0 )
        {
            caseToUpdate.add(new case(id=depositrec[0].Cases__r[0].id, status='Deposit transfer cancelled'));
        }
        try{
            if(depositToUpadte.size() > 0)
            {
                update depositToUpadte;
            }
            if(caseToUpdate.size() > 0)
            {
                update caseToUpdate;
            }
            
            List<User> receivingUserList = new List<User>();
            for(User u : [SELECT Id, Email, Name, Contact.Name, ContactId, AccountId, Contact.Email FROM User where Email =: depositrec[0].New_Customer_Email__c]){
                receivingUserList.add(u);
            }
            
            if(receivingUserList.size() > 0){
                receivingUser = receivingUserList[0];
                // ========email will be sent by MailZet=========//
                List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
                Date todayDate = System.today();
                String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
                
                // if transfer cancelled Ac 4.4.3 (3149826)
                List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(receivingUser.Email, receivingUser.Contact.Name, receivingUser.AccountId, receivingUser.ContactId));					
                Map<String, String> variableMap = new Map<String, String>(); 
                
                variableMap.put('date', todayStr);
                variableMap.put('name', receivingUser.Contact.Name);
                variableMap.put('number_of_deposits_in_transfer', String.valueOf(1));
                variableMap.put('name_of_transferring_agent', depositrec[0].Customer_Name__c);
                variableMap.put('address_of_cancelled_deposit', depositrec[0].Property_Address__c); 	
                emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                               'SingleDepositBulkTransferCancelled', 
                                                                               'Transfer cancelled'));
                
                if(emailWrapperList.size()>0) {
                    EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
                }
            }
            
            return 'Successfully removed';
        }
        catch (exception e)
        {
            Database.RollBack(sp);
            return string.valueOf(e);
        }
        
    }
    
    @Auraenabled
    public static string cancelMultipleDeposit(List<string> selectedDepositId)
    {
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
        list<Deposit__c> depositrec = [select id, Deposit_Transferred__c, Transfer_Deposit_start_date__c, Deposit_Transferred_to_Account__c, New_Customer_Email__c, 
                                       Deposit_Transferred_to_Account__r.Name, Deposit_Transferred_to_Account__r.Email__c, 
                                       Customer_Name__c, 
                                       (select id from Cases__r where recordtypeid =:caseRecordType and status =:Label.Deposit_transfer_requested  order by lastmodifieddate desc limit 1 ) 
                                       from Deposit__c where id in :selectedDepositId and Deposit_Transferred__c=true]; 
        set<string> listofemail =new set<string> ();
        Map<Id, Deposit__c> mapOfDeposits = new Map<Id, Deposit__c>();
        list<Deposit__c> depositToUpadte =new list<Deposit__c>();
        list<case> caseToUpdate = new list<Case>();
        Savepoint sp = Database.setSavepoint();
        if(depositrec.size() > 0)
        {
            for(Deposit__c deposit :depositrec)
            {
                Deposit__c dep = new Deposit__c(id =deposit.id,
                                                Deposit_Transferred__c=false,
                                                Transfer_Deposit_start_date__c =null,
                                                Deposit_Transferred_to_Account__c = null,
                                                New_Customer_Email__c =''
                                               );
                depositToUpadte.add(dep);
                
                if(deposit.Cases__r.size() >0 )
                {
                    caseToUpdate.add(new case(id=deposit.Cases__r[0].id, status='Deposit transfer cancelled'));
                }
            }
            
            for(Deposit__c deposit :depositrec){
                listofemail.add(deposit.New_Customer_Email__c);
                mapOfDeposits.put(deposit.Id, deposit);
            }
        }
        
        try{
            if(depositToUpadte.size() > 0)
            {
                update depositToUpadte;
            }
            if(caseToUpdate.size() > 0)
            {
                update caseToUpdate;
            }
            
            Map<String, User> receivingUserMap = new Map<String, User>();
            for(User u : [SELECT Id, Email, Name, ContactId, AccountId, Contact.Email FROM User where Email IN:listofemail]){
                receivingUserMap.put(u.Email, u);
            }
            
            if(receivingUserMap.size() > 0){
                // ========email will be sent by MailZet=========//
                List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
                Date todayDate = System.today();
                String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
                // if transfers cancelled Ac 4.7 (3149831)
                
                for(string rep : listofemail) {   
                    Set<Date> uniquedate = new Set<Date>();
                    Map<Id, Date> mapOfDepIdWithDate = new Map<Id, Date>();
                    Map<Date, List<Id>> mapOfDate = new Map<Date, List<Id>>();
                    User receivingUser = receivingUserMap.get(rep); //[SELECT Id, Email, Name, ContactId, AccountId, Contact.Email FROM User where Contact.Email =:rep limit 1];
                    for(Deposit__c depo :mapOfDeposits.values()) {
                        if(rep == depo.New_Customer_Email__c) {
                            DateTime dT = depo.Transfer_Deposit_start_date__c;
                            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                            uniquedate.add(myDate);
                            mapOfDepIdWithDate.put(depo.Id, myDate);
                        }
                    } 
                    
                    // Wrapping the current iteration of Email with Unique Deposit Transfrer Date
                    
                    for(Date uniqDt:uniquedate) {
                        List<deposit__c> listDeposits =  new List<deposit__c>();
                        
                        for(String depositId : mapOfDepIdWithDate.keySet()) {
                            if(uniqDt==mapOfDepIdWithDate.get(depositId)) {
                                listDeposits.add(mapOfDeposits.get(depositId) );
                            }
                        }
                        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(receivingUser.Email, receivingUser.Name, receivingUser.AccountId, receivingUser.ContactId));					
                        Map<String, String> variableMap = new Map<String, String>(); 
                        
                        variableMap.put('date', todayStr);
                        variableMap.put('name', receivingUser.Name);
                        variableMap.put('number_of_deposits_in_transfer', String.valueOf(listDeposits.size()));
                        variableMap.put('name_of_transferring_agent', listDeposits[0].Customer_Name__c);	
                        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                       'MultipleDepositBulkTransferCancelled', 
                                                                                       'Transfer cancelled'));
                    }
                }
                
                if(emailWrapperList.size()>0) {
                    EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
                }
            }
            return 'Successfully removed';
            
        }
        catch (exception e)
        {
            Database.RollBack(sp);
            return string.valueOf(e.getMessage());
        } 
    }
    
    @AuraEnabled
    public static List<depositemailgroupWrapper> viewAwatingTransferredDeposits(String branchId) {
        string accountid = [Select id,Contact.AccountId, Contact.Email from User where id=:Userinfo.getUserId()].Contact.Email; 
        set<string> listofemail =new set<string> ();
        Map<Id, Deposit__c> mapOfDeposits = new Map<Id, Deposit__c>();
        if(branchId == null){
            for(Deposit__c deposit : [Select id,New_Customer_Email__c, Customer__c,Customer_Name__c,Customer_email__c,Transfer_Deposit_start_date__c,
                                      Name,Property_Address__c,Protected_Amount__c,Number_of_Tenants__c,
                                      LastModifiedDate,
                                      Deposit_Amount__c, Bulk_transfer_attempts__c, BatchID__c, No_of_attempt__c, Transfer_verified__c,
                                      (select id,Deposit_Holder__r.LastName from Deposit_Allocations__r where Role__c ='Tenant')
                                      from deposit__C 
                                      where New_Customer_Email__c !=null and Deposit_Transferred__c=true 
                                      //and Bulk_transfer_attempts__c = false
                                      and  New_Customer_Email__c =:accountid and Transfer_Deposit_start_date__c != null])
            {
                listofemail.add(deposit.Customer__c+'-'+deposit.Customer_Name__c);
                mapOfDeposits.put(deposit.Id, deposit);
            }
        }
        else{
            for(Deposit__c deposit : [Select id,New_Customer_Email__c, Customer__c,Customer_Name__c,Customer_email__c,Transfer_Deposit_start_date__c,
                                      Name,Property_Address__c,Protected_Amount__c,Number_of_Tenants__c,
                                      LastModifiedDate,
                                      Deposit_Amount__c, Bulk_transfer_attempts__c, BatchID__c, No_of_attempt__c, Transfer_verified__c,
                                      (select id,Deposit_Holder__r.LastName from Deposit_Allocations__r where Role__c ='Tenant')
                                      from deposit__C 
                                      where New_Customer_Email__c !=null and Deposit_Transferred__c=true 
                                      //and Bulk_transfer_attempts__c = false
                                      and New_Customer_Email__c =:accountid and Transfer_Deposit_start_date__c != null 
                                      and branch__c =:branchId])
            {
                listofemail.add(deposit.Customer__c+'-'+deposit.Customer_Name__c);
                mapOfDeposits.put(deposit.Id, deposit);
            }
        }
        
        Map<string,list<depositListWrapper>> acctmap = new Map<string,list<depositListWrapper>>();
        List<depositemailgroupWrapper> finalwrapperlist = new List<depositemailgroupWrapper>();
        Integer index = 0;
        for(string rep : listofemail) {   
            Set<Date> uniquedate = new Set<Date>();
            Map<Id, Date> mapOfDepIdWithDate = new Map<Id, Date>();
            Map<Date, List<Id>> mapOfDate = new Map<Date, List<Id>>();
            for(Deposit__c depo :mapOfDeposits.values()) {
                if(rep == (depo.Customer__c+'-'+depo.Customer_Name__c)) {
                    DateTime dT = depo.Transfer_Deposit_start_date__c;
                    Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                    uniquedate.add(myDate);
                    mapOfDepIdWithDate.put(depo.Id, myDate);
                    
                }
            } 
            
            // Wrapping the current iteration of Email with Unique Deposit Transfrer Date
            
            for(Date uniqDt:uniquedate) { 
                List<depositListWrapper> listdepositwrap =  new List<depositListWrapper>();
                Integer countdeposit = 0;
                
                Decimal totalamount=0;
                for(String depositId : mapOfDepIdWithDate.keySet()) {
                    if(uniqDt==mapOfDepIdWithDate.get(depositId)) {
                        countdeposit++;
                        totalamount =totalamount+(mapOfDeposits.get(depositId).Protected_Amount__c != null ? mapOfDeposits.get(depositId).Protected_Amount__c : 0);
                        listdepositwrap.add(new depositListWrapper(true,mapOfDeposits.get(depositId)));
                    }
                }
                
                string customerName = rep.split('-')[1] !='' ? rep.split('-')[1] : 'Unknown' ;
                finalwrapperlist.add(new depositemailgroupWrapper(true, index, customerName, totalamount, countdeposit, uniqDt, listdepositwrap));
                index++;
            }
        }   
        
        return  finalwrapperlist ;
        
    }
    
    @AuraEnabled
    public static string rejectMultipleDeposit(List<string> selectedDepositId)
    {
        List<Case> CaseToUpdate = new List<Case>();
        Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
        List<Deposit__c> depositToUpdate = new List<Deposit__c>();
        set<string> listofemail =new set<string> ();
        Map<Id, Deposit__c> mapOfDeposits = new Map<Id, Deposit__c>();
        Savepoint sp = Database.setSavepoint();
        for(Deposit__c deposit : [SELECT id,New_Customer_Email__c, Customer__c,Customer_Name__c,Customer_email__c,Transfer_Deposit_start_date__c,
                                  Name,Property_Address__c,Protected_Amount__c,Number_of_Tenants__c,Deposit_Transferred__c,
                                  LastModifiedDate,Deposit_Amount__c,Deposit_Transferred_to_Account__c, Deposit_Transferred_to_Account__r.Email__c, Deposit_Transferred_to_Account__r.Name,
                                  (select id from Cases__r where recordtypeid =:caseRecordType and status =:Label.Deposit_transfer_requested  order by lastmodifieddate desc limit 1 )
                                  from Deposit__c where Id IN :selectedDepositId 
                                  and Deposit_Transferred__c=true])
        {
            deposit.Deposit_Transferred__c=false;
            deposit.Transfer_Deposit_start_date__c =null;
            deposit.Deposit_Transferred_to_Account__c = null;
            deposit.New_Customer_Email__c ='';
            depositToUpdate.add(deposit);
            
            if(deposit.Cases__r.size() > 0 )
            {
                CaseToUpdate.add(new case(id=deposit.Cases__r[0].id, status=Label.Deposit_transfer_rejected));
            }
            
        }

        for(Deposit__c deposit : [SELECT id,New_Customer_Email__c, Customer__c,Customer_Name__c,Customer_email__c,Transfer_Deposit_start_date__c,
                                  Name,Property_Address__c,Protected_Amount__c,Number_of_Tenants__c,Deposit_Transferred__c,
                                  LastModifiedDate,Deposit_Amount__c,Deposit_Transferred_to_Account__c, Deposit_Transferred_to_Account__r.Email__c, Deposit_Transferred_to_Account__r.Name,
                                  (select id from Cases__r where recordtypeid =:caseRecordType and status =:Label.Deposit_transfer_requested  order by lastmodifieddate desc limit 1 )
                                  from Deposit__c where Id IN :selectedDepositId 
                                  and Deposit_Transferred__c=true])
        {
            listofemail.add(deposit.New_Customer_Email__c);
            mapOfDeposits.put(deposit.Id, deposit);
        }
        try{
            if(depositToUpdate.size() > 0)
            {
                update depositToUpdate;
            }
            if(caseToUpdate.size() > 0)
            {
                update caseToUpdate;
            }
            
            Map<String, User> receivingUserMap = new Map<String, User>();
            for(User u : [SELECT Id, Email, Name, ContactId, AccountId, Contact.Email FROM User where Contact.Email IN:listofemail]){
                receivingUserMap.put(u.Email, u);
            }
            
            // ========email will be sent by MailZet=========//
            List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
            Date todayDate = System.today();
            String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
            
            for(string rep : listofemail) {   
                Set<Date> uniquedate = new Set<Date>();
                Map<Id, Date> mapOfDepIdWithDate = new Map<Id, Date>();
                Map<Date, List<Id>> mapOfDate = new Map<Date, List<Id>>();
                User receivingUser = receivingUserMap.get(rep);
                
                for(Deposit__c depo :mapOfDeposits.values()) {
                    if(rep == depo.New_Customer_Email__c) {
                        DateTime dT = depo.Transfer_Deposit_start_date__c;
                        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                        uniquedate.add(myDate);
                        mapOfDepIdWithDate.put(depo.Id, myDate);
                    }
                } 
                System.Debug('mapOfDepIdWithDate => ' + mapOfDepIdWithDate);
                System.Debug('uniquedate => ' + uniquedate);
                // Wrapping the current iteration of Email with Unique Deposit Transfrer Date
                for(Date uniqDt:uniquedate) {
                    List<deposit__c> listDeposits =  new List<deposit__c>();
                   
                    for(String depositId : mapOfDepIdWithDate.keySet()) {
                        if(uniqDt==mapOfDepIdWithDate.get(depositId)) {
                            listDeposits.add(mapOfDeposits.get(depositId) );
                        }
                    }
                    // to transferring (prev) agent/landlord (3149881)
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList1 = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList1.add(new EI_SDS_MailJetUtilityCls.recipient(listDeposits[0].Customer_email__c, listDeposits[0].Customer_Name__c, listDeposits[0].Customer__c, receivingUser.ContactId));					
                    System.Debug('emailRecipientList1 => ' + emailRecipientList1); 
                    Map<String, String> variableMap1 = new Map<String, String>(); 
                    
                    variableMap1.put('date', todayStr);
                    variableMap1.put('name', listDeposits[0].Customer_Name__c);
                    variableMap1.put('number_of_deposits_in_transfer', String.valueOf(listDeposits.size()));
                    variableMap1.put('new_agent_name', receivingUser.Name);	
                    variableMap1.put('address_of_rejected_deposit', '');
                    variableMap1.put('receiving_agent', receivingUser.Name);
                    
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList1), variableMap1, 
                                                                                   'BulkTransferRejectedTrasferringAGLL', 
                                                                                   'Some deposits rejected'));
                    System.Debug('emailWrapperList => ' + emailWrapperList);
                    // to rejecting (new) agent/landlord (3149887)
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList2 = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList2.add(new EI_SDS_MailJetUtilityCls.recipient(receivingUser.Email, receivingUser.Name, receivingUser.AccountId, receivingUser.ContactId));					
                    System.Debug('emailRecipientList2 => ' + emailRecipientList2);    
                    Map<String, String> variableMap2 = new Map<String, String>(); 
                    
                    variableMap2.put('date', todayStr);
                    variableMap2.put('name', receivingUser.Name);
                    variableMap2.put('number_of_deposits_in_transfer', String.valueOf(listDeposits.size()));
                    variableMap2.put('address_of_rejected_deposit', '');	
                    variableMap2.put('sending_agent_name', listDeposits[0].Customer_Name__c);	
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList2), variableMap2, 
                                                                                   'BulkTransferRejectedRejectingAGLL', 
                                                                                   'Some deposits rejected'));
                    System.Debug('emailWrapperList => ' + emailWrapperList);    
                }
            }
            if(emailWrapperList.size()>0) {
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
            }
            
            return 'Successfully rejected';
            
        }
        catch (exception e)
        {
            Database.RollBack(sp);
            return string.valueOf(e);
        } 
    }
    
    @Auraenabled
    public static String validateTenantNameAndAccept(List<Id> listDepositId,String tenantValue, String branchId) {
        user currentUser = [select id, accountid, contactid from user where id = :UserInfo.getUserId()];
        Savepoint sp = Database.setSavepoint();
        
        set<string> listofemail =new set<string> ();
        Map<Id, Deposit__c> mapOfDeposits = new Map<Id, Deposit__c>();
        List<Deposit__c> updateDeposit = new List<Deposit__c>(); 
        Map<Id, Property__c> updateProperty = new Map<Id, Property__c>(); 
        Map<Id, Property_Allocation__c> updatePropertyAllocation = new Map<Id, Property_Allocation__c>(); 
        List<Case> listCaseToUpdate = new List<Case>();
        try{
            system.debug('listDepositId>>>>>'+listDepositId);
            
            for(Deposit__c deposit : [SELECT Id,Name,Deposit_Transferred__c,Customer__c,Customer_email__c,Customer_Name__c, Property_Address__c, New_Customer_Email__c,
                                      Deposit_Transferred_to_Account__c, Deposit_Transferred_to_Account__r.Email__c, Deposit_Transferred_to_Account__r.Name, Transfer_deposit_start_date__c,
                                      Property__c, Property__r.Property_Owner__c,
                                      (select id, Deposit_Holder__c, Deposit_Holder__r.Email__c, Deposit_Holder__r.Name, Contact__c from Deposit_Allocations__r where Role__c ='Tenant')
                                      from Deposit__c where Id IN :listDepositId 
                                      and Deposit_Transferred__c=true
                                      Limit 1000])
            {
                listofemail.add(deposit.New_Customer_Email__c);
                mapOfDeposits.put(deposit.Id, deposit);
                
                deposit.Customer__c = currentUser.AccountId;
                deposit.Deposit_Transferred__c = false;
                deposit.Deposit_Transferred_to_Account__c = null;
                deposit.Transfer_verified__c = true;
                if(branchId != null){
                    deposit.Branch__c = branchId;
                }
                updateDeposit.add(deposit);
                
                updateProperty.put(deposit.Property__c, new Property__c(Id = deposit.Property__c, Property_Owner__c = currentUser.AccountId));
                
            } 
            
            If(!updateDeposit.isEmpty()){
                update updateDeposit;
                
                for(Case cs :  [Select id,Status from Case where Deposit_Account_Number__c IN:listDepositId and (Status=:Label.Deposit_transfer_requested OR status=:Label.Deposit_transfer_cancelled OR status=:Label.Deposit_transfer_rejected)]){
                    cs.status = Label.Deposit_transfer_accepted;
                    listCaseToUpdate.add(cs);
                }
                if(!listCaseToUpdate.isEmpty()){
                    update listCaseToUpdate;
                }
            }
            
            
            if(updateProperty.size() > 0){
                update updateProperty.values();
                
                for(Property_Allocation__c propAlloc : [Select Id, Name, Relation_to_Property__c, Contact__c, Property__c 
                                                        From Property_Allocation__c 
                                                        Where Relation_to_Property__c = 'Primary Landlord' 
                                                        and Property__c IN :updateProperty.keySet()] )
                {
                    if(updateProperty.containsKey(propAlloc.Property__c)){
                        propAlloc.Contact__c = currentUser.ContactId;
                        updatePropertyAllocation.put(propAlloc.Id, propAlloc);
                    }
                }
                
                if(updatePropertyAllocation.size() > 0){
                    update updatePropertyAllocation.values();
                }
            }
            
            Map<String, User> receivingUserMap = new Map<String, User>();
            for(User u : [SELECT Id, Email, Name, ContactId, AccountId, Contact.Email FROM User where Contact.Email IN:listofemail]){
                receivingUserMap.put(u.Email, u);
            }
            
            // ========email will be sent by MailZet=========//
            List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
            Date todayDate = System.today();
            String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
            
            for(string rep : listofemail) {   
                Set<Date> uniquedate = new Set<Date>();
                Map<Id, Date> mapOfDepIdWithDate = new Map<Id, Date>();
                Map<Date, List<Id>> mapOfDate = new Map<Date, List<Id>>();
                User receivingUser = receivingUserMap.get(rep);
                for(Deposit__c depo :mapOfDeposits.values()) {
                    if(rep == depo.New_Customer_Email__c) {
                        DateTime dT = depo.Transfer_Deposit_start_date__c;
                        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                        uniquedate.add(myDate);
                        mapOfDepIdWithDate.put(depo.Id, myDate);
                    }
                } 
                
                // Wrapping the current iteration of Email with Unique Deposit Transfrer Date
                for(Date uniqDt:uniquedate) {
                    List<deposit__c> listDeposits =  new List<deposit__c>();
                    
                    for(String depositId : mapOfDepIdWithDate.keySet()) {
                        if(uniqDt==mapOfDepIdWithDate.get(depositId)) {
                            listDeposits.add(mapOfDeposits.get(depositId) );
                        }
                    }
                    // to tenants AC 5.15 (3149850)
                    for(Deposit__c depo : listDeposits){
                        for(Deposit_Allocation__c dAlloc : depo.Deposit_Allocations__r){
                            List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList1 = new List<EI_SDS_MailJetUtilityCls.recipient>();
                            emailRecipientList1.add(new EI_SDS_MailJetUtilityCls.recipient(dAlloc.Deposit_Holder__r.Email__c, dAlloc.Deposit_Holder__r.Name, dAlloc.Deposit_Holder__c, dAlloc.Contact__c));					
                            Map<String, String> variableMap1 = new Map<String, String>();
                            
                            variableMap1.put('date', todayStr);
                            variableMap1.put('name', dAlloc.Deposit_Holder__r.Name);
                            variableMap1.put('tenancy_address', depo.Property_Address__c);
                            variableMap1.put('sending_agent', depo.Customer_Name__c);
                            variableMap1.put('new_agent', depo.Deposit_Transferred_to_Account__r.Name);	
                            emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList1), variableMap1, 
                                                                                           'BulkTransferAcceptedTenants', 
                                                                                           'Transfer accepted'));
                        }
                    }
                    
                    // to prev agent/landlord AC 5.15 (3149859)
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList1 = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList1.add(new EI_SDS_MailJetUtilityCls.recipient(listDeposits[0].Customer_email__c, listDeposits[0].Customer_Name__c, listDeposits[0].Customer__c, receivingUser.ContactId));					
                    Map<String, String> variableMap1 = new Map<String, String>(); 
                    DateTime toDate = System.today();
                    variableMap1.put('date', todayStr);
                    variableMap1.put('name', listDeposits[0].Customer_Name__c);
                    variableMap1.put('number_of_deposits_in_transfer', String.valueOf(listDeposits.size()));
                    variableMap1.put('new_agent_name', receivingUser.Name);	
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList1), variableMap1, 
                                                                                   'BulkTransferAcceptedPrevAGLL', 
                                                                                   'Transfer accepted'));
                    
                    // to new agent/Landlord AC 5.15 (3149868)
                    List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList2 = new List<EI_SDS_MailJetUtilityCls.recipient>();
                    emailRecipientList2.add(new EI_SDS_MailJetUtilityCls.recipient(receivingUser.Email, receivingUser.Name, receivingUser.AccountId, receivingUser.ContactId));					
                    Map<String, String> variableMap2 = new Map<String, String>(); 
                    variableMap2.put('date', todayStr);
                    variableMap2.put('name', receivingUser.Name);
                    variableMap2.put('number_of_transferred_deposits', String.valueOf(listDeposits.size()));
                    variableMap2.put('previous_agent', listDeposits[0].Customer_Name__c);	
                    emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList2), variableMap2, 
                                                                                   'BulkTransferAcceptedNewAGLL', 
                                                                                   'Transfer accepted'));
                }
            }
            if(emailWrapperList.size()>0) {
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList)); 	  
            }
            
            return 'Successfully accepted';
        }
        catch(Exception e){
            Database.rollback(sp);
            return string.valueOf(e);
        }
    }
    
    @AuraEnabled
    public static void checkBulkTransferAttempts(List<Id> listDepositId){
        List<Deposit__c> updateDeposit = new List<Deposit__c>();
        
        for(Deposit__c depo : [Select Id, Name, Bulk_transfer_attempts__c FROM Deposit__c Where Id IN :listDepositId]){
            depo.Bulk_transfer_attempts__c = true;
            updateDeposit.add(depo);
        }
        
        if(!updateDeposit.isEmpty()){
            update updateDeposit;
        }
    }
    
    @AuraEnabled
    public static void updateNoOfAttemptsLeft(List<Id> listDepositId, Integer attemptsLeft){
        List<Deposit__c> updateDeposit = new List<Deposit__c>();
        
        for(Deposit__c depo : [Select Id, Name, No_of_attempt__c FROM Deposit__c Where Id IN :listDepositId]){
            depo.No_of_attempt__c = attemptsLeft;
            updateDeposit.add(depo);
        }
        
        if(!updateDeposit.isEmpty()){
            update updateDeposit;
        }
    }
    
    
}