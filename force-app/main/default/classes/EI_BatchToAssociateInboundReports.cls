//Batch to associate Inbound Reports with Installment 
public class EI_BatchToAssociateInboundReports implements Database.Batchable<sObject>{
    
    public set<id> inboundReportIds;
    
    public EI_BatchToAssociateInboundReports(set<Id> inboundReportIds){
        this.inboundReportIds = new set<Id>();
        this.inboundReportIds = inboundReportIds;    
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        string method = 'Debit Card';
        string matchedColour = '';
        string status = 'Inactive';
        string query = 'Select Id,Type__c,File_Name__c,Status__c,Name,Installment__c,Transaction_Id__c,Reference1__c,Reference2__c,Reference3__c,Reference4__c,Reference5__c,Amount__c,Collection_Date__c,Matched_Colour__c,Payee_Name__c,Payment_Method__c from Inbound_Report__c where Id IN: inboundReportIds AND Payment_Method__c !=: method AND Matched_Colour__c =: matchedColour AND Status__c !=: status';
        return Database.getQueryLocator(query);
    }
   
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Boolean isMatched = false;
        Inbound_Report__c inboundReport = (Inbound_Report__c)scope[0];
        //?? add installment status (Inbound)
        list<Installment__c> matchedInstallments = [Select Id,Deposit__r.Deposit_Account_Number__c,Amount__c from Installment__c 
                                                            where (Deposit__r.Deposit_Account_Number__c =: inboundReport.Reference1__c
                                                            OR Deposit__r.Deposit_Account_Number__c =: inboundReport.Reference2__c
                                                            OR Deposit__r.Deposit_Account_Number__c =: inboundReport.Reference3__c
                                                            OR Deposit__r.Deposit_Account_Number__c =: inboundReport.Reference4__c
                                                            OR Deposit__r.Deposit_Account_Number__c =: inboundReport.Reference5__c)
                                                            AND Amount__c =:inboundReport.Amount__c
                                                            AND Status__c = 'Pending'
                                                            AND Installment_Type__c = 'Receivable' limit 50000] ;
        
        // Green Zone
        if(!matchedInstallments.isEmpty()){
            if(matchedInstallments.size() == 1){
                
                //add Payment Mode
                inboundReport.Installment__c = matchedInstallments[0].Id;
                inboundReport.Matched_Colour__c = 'Green';
                try {
                    
                    Update inboundReport;
                    isMatched = true; 
                    
                } catch (Exception exp) {
                    //create error logs
                }
            }else{
                
                //duplicate installments found 
            }
        }
        
        //for Bulk 
        if(!isMatched){

        
            list<Installment__c> installmentList = [Select Id,Amount__c,BLK_Number__c,Name,Deposit__r.Status__c, Deposit__r.Deposit_Account_Number__c,Deposit__c,Installment_Type__c,Status__c from Installment__c
                                                                            where (BLK_Number__c =: inboundReport.Reference1__c
                                                                            OR BLK_Number__c =: inboundReport.Reference2__c
                                                                            OR BLK_Number__c =: inboundReport.Reference3__c
                                                                            OR BLK_Number__c =: inboundReport.Reference4__c
                                                                            OR BLK_Number__c =: inboundReport.Reference5__c) 
                                                                            AND Status__c = 'Pending'
                                                                            AND Installment_Type__c = 'Receivable' 
                                                    						AND BLK_Number__c != '' ORDER BY LastModifiedDate DESC];
            
            system.debug('>>>>>>>>>>>'+JSON.serializePretty(installmentList));
            if(installmentList != null && !installmentList.isEmpty()){
                Decimal amountInstallments = 0;
                for(Installment__c inst : installmentList){
                    if(inst.Amount__c != null){
                        amountInstallments += inst.Amount__c;
                    }
                } 
                system.debug('>>>>>>>>>>>'+amountInstallments);
                if(inboundReport.Amount__c == amountInstallments){

                    createInboundReports(installmentList,inboundReport,'Green');
                    isMatched = true;
                }   
            }

        }
        ///// Amber Amber 
        //Property Address 
        if(!isMatched){
            list<Installment__c> installmentList = [Select Id,Deposit__r.Property_Address__c,Amount__c from Installment__c 
                                                            where (Deposit__r.Property_Address__c =: inboundReport.Reference1__c
                                                            OR Deposit__r.Property_Address__c =: inboundReport.Reference2__c
                                                            OR Deposit__r.Property_Address__c =: inboundReport.Reference3__c
                                                            OR Deposit__r.Property_Address__c =: inboundReport.Reference4__c
                                                            OR Deposit__r.Property_Address__c =: inboundReport.Reference5__c)
                                                            AND Status__c = 'Pending'
                                                            AND Installment_Type__c = 'Receivable'] ;
                                                
            // Amber Zone
            if(!installmentList.isEmpty()){

                Integer matchedInstallmentCount = 0;
                Decimal totalInstallmentAmounts = 0;
                String installmentId = '';
                for(Installment__c insta : installmentList){
                    if(inboundReport.Amount__c == insta.Amount__c){
                        matchedInstallmentCount++;
                        installmentId = insta.Id;

                    }
                    totalInstallmentAmounts = totalInstallmentAmounts+insta.Amount__c;
                }

                if(matchedInstallmentCount == 1){
                    
                    //add Payment Mode
                    inboundReport.Installment__c = installmentId;
                    inboundReport.Matched_Colour__c = 'Amber';
                    try {
                        
                        Update inboundReport;
                        isMatched = true; 
                        
                    } catch (Exception exp) {
                        //create error logs
                    }
                }else{

                    
                    if(inboundReport.Amount__c == totalInstallmentAmounts){

                        createInboundReports(installmentList,inboundReport,'Amber');
                        isMatched = true;
                    }
                    
                }
            }
        }
 
        if(!isMatched){
            //Amber Zone
            set<Id> accountIDs = new set<Id>();
            set<id> propertyIds = new set<Id>();
            set<id> depositIds = new set<Id>();
            list<Deposit_Allocation__c> listDepositAllocations = [Select Id,Deposit_Holder__c,Deposit__c,
                                                                        Deposit_Holder__r.Name,
                                                                        Deposit_Holder__r.FirstName,
                                                                        Deposit_Holder__r.LastName from Deposit_Allocation__c
                                                                            where (Deposit_Holder__r.Name =:inboundReport.Reference1__c
                                                                            OR Deposit_Holder__r.FirstName =:inboundReport.Reference1__c
                                                                            OR Deposit_Holder__r.LastName =:inboundReport.Reference1__c
                                                                            OR Deposit_Holder__r.Name =:inboundReport.Reference2__c
                                                                            OR Deposit_Holder__r.FirstName =:inboundReport.Reference2__c
                                                                            OR Deposit_Holder__r.LastName =:inboundReport.Reference2__c
                                                                            OR Deposit_Holder__r.Name =:inboundReport.Reference3__c
                                                                            OR Deposit_Holder__r.FirstName =:inboundReport.Reference3__c
                                                                            OR Deposit_Holder__r.LastName =:inboundReport.Reference3__c
                                                                            OR Deposit_Holder__r.Name =:inboundReport.Reference4__c
                                                                            OR Deposit_Holder__r.FirstName =:inboundReport.Reference4__c
                                                                            OR Deposit_Holder__r.LastName =:inboundReport.Reference4__c
                                                                            OR Deposit_Holder__r.Name =:inboundReport.Reference5__c
                                                                            OR Deposit_Holder__r.FirstName =:inboundReport.Reference5__c
                                                                            OR Deposit_Holder__r.LastName =:inboundReport.Reference5__c
                                                                            
                                                                            )  AND
                                                                            (Deposit__r.Status__c =: 'Awaiting Payment'
                                                                            OR Deposit__r.Status__c =: 'Deposits held by scheme'
                                                                            OR Deposit__r.Status__c =: 'Registered (not paid)')];
            
            //
            list<Property_Allocation__c> propertyAllocations = [Select Id,Name,Property__c,Contact__c,Contact__r.AccountId from Property_Allocation__c 
                                                                                                where Contact__c != null AND (      
                                                                                                       Contact__r.Name =:inboundReport.Reference1__c
                                                                                                    OR Contact__r.FirstName =:inboundReport.Reference1__c
                                                                                                    OR Contact__r.LastName =:inboundReport.Reference1__c
                                                                                                    OR Contact__r.Name =:inboundReport.Reference2__c
                                                                                                    OR Contact__r.FirstName =:inboundReport.Reference2__c
                                                                                                    OR Contact__r.LastName =:inboundReport.Reference2__c
                                                                                                    OR Contact__r.Name =:inboundReport.Reference3__c
                                                                                                    OR Contact__r.FirstName =:inboundReport.Reference3__c
                                                                                                    OR Contact__r.LastName =:inboundReport.Reference3__c
                                                                                                    OR Contact__r.Name =:inboundReport.Reference4__c
                                                                                                    OR Contact__r.FirstName =:inboundReport.Reference4__c
                                                                                                    OR Contact__r.LastName =:inboundReport.Reference4__c
                                                                                                    OR Contact__r.Name =:inboundReport.Reference5__c
                                                                                                    OR Contact__r.FirstName =:inboundReport.Reference5__c
                                                                                                    OR Contact__r.LastName =:inboundReport.Reference5__c
                                                                                                    
                                                                                                    ) ];
            for(Deposit_Allocation__c allocations : listDepositAllocations){
                
                depositIds.add(allocations.Deposit__c);
            
            }
            for(Property_Allocation__c allocations : propertyAllocations){
                
                accountIDs.add(allocations.Contact__r.AccountId);
            
            }

            list<Installment__c> installmentList = [Select Id,Amount__c from Installment__c where (Deposit__r.Property__c IN: propertyIds
                                                                 OR Deposit__r.Customer__c IN : accountIDs
                                                                 OR ID IN : depositIds
                                                                 ) 
                                                                 AND  Status__c = 'Pending'
                                                                 AND Installment_Type__c = 'Receivable'];

            //
            if(!installmentList.isEmpty()){

                Integer matchedInstallmentCount = 0;
                Decimal totalInstallmentAmounts = 0;
                String installmentId = '';
                for(Installment__c insta : installmentList){
                    if(inboundReport.Amount__c == insta.Amount__c){
                        matchedInstallmentCount++;
                        installmentId = insta.Id;

                    }
                    totalInstallmentAmounts = totalInstallmentAmounts+insta.Amount__c;
                }

                if(matchedInstallmentCount == 1){
                    
                    //add Payment Mode
                    inboundReport.Installment__c = installmentId;
                    inboundReport.Matched_Colour__c = 'Amber';
                    try {
                        
                        Update inboundReport;
                        isMatched = true; 
                        
                    } catch (Exception exp) {
                        //create error logs
                    }
                }else{

                    
                    if(inboundReport.Amount__c == totalInstallmentAmounts){

                        createInboundReports(installmentList,inboundReport,'Amber');
                        isMatched = true;
                    }
                    
                }
            }
        }
        
        if(!isMatched){
             //For Bank Name
             list<Bank_Account__c> listBankAccounts = [Select Id,Name,Contact__c,Account__c,Contact__r.AccountId from Bank_Account__c where Bank_Account_Holder_Name__c =: inboundReport.Reference1__c
                                                                                                                    OR Bank_Account_Holder_Name__c =: inboundReport.Reference2__c
                                                                                                                    OR Bank_Account_Holder_Name__c =: inboundReport.Reference3__c
                                                                                                                    OR Bank_Account_Holder_Name__c =: inboundReport.Reference4__c
                                                                                                                    OR Bank_Account_Holder_Name__c =: inboundReport.Reference5__c];
             set<Id> accountIDs = new set<Id>();
             set<id> propertyIds = new set<Id>();
             if(!listBankAccounts.isEmpty()){
                for(Bank_Account__c bank : listBankAccounts){
                    accountIDs.add(bank.Account__c);
                     if(String.isNotBlank(bank.Contact__c) && String.isNotBlank(bank.Contact__r.AccountId)){
                        accountIDs.add(bank.Contact__r.AccountId);
                    }
                }

                
                list<Property_Allocation__c> allocations = [Select Id,Name,Property__c from Property_Allocation__c 
                                                                                                where Contact__r.AccountId =: accountIDs ];

                for(Property_Allocation__c pro : allocations ){
                    propertyIds.add(pro.Property__c);
                }

                list<Installment__c> installmentList = [Select Id,Amount__c from Installment__c where (Deposit__r.Property__c IN: propertyIds
                                                                 OR Deposit__r.Customer__c IN : accountIDs
                                                                 ) 
                                                                 AND  Status__c = 'Pending'
                                                                 AND Installment_Type__c = 'Receivable'];

                if(!installmentList.isEmpty()){

                    Integer matchedInstallmentCount = 0;
                    Decimal totalInstallmentAmounts = 0;
                    String installmentId = '';
                    for(Installment__c insta : installmentList){
                        if(inboundReport.Amount__c == insta.Amount__c){
                            matchedInstallmentCount++;
                            installmentId = insta.Id;

                        }
                        totalInstallmentAmounts = totalInstallmentAmounts+insta.Amount__c;
                    }

                    if(matchedInstallmentCount == 1){
                        
                        //add Payment Mode
                        inboundReport.Installment__c = installmentId;
                        inboundReport.Matched_Colour__c = 'Amber';
                        try {
                            
                            Update inboundReport;
                            isMatched = true; 
                            
                        } catch (Exception exp) {
                            //create error logs
                        }
                    }else{
    
                        
                        if(inboundReport.Amount__c == totalInstallmentAmounts){
    
                            createInboundReports(installmentList,inboundReport,'Amber');
                            isMatched = true;
                        }
                        
                    }
                }
                
            }
        }
        
        //
        if(!isMatched){
             //for User
             list<User> userList = [Select Id,Contact.AccountId,Alias from User where (Alias =: inboundReport.Reference1__c
                                                                                                                    OR Alias =: inboundReport.Reference2__c
                                                                                                                    OR Alias =: inboundReport.Reference3__c
                                                                                                                    OR Alias =: inboundReport.Reference4__c
                                                                                                                    OR Alias =: inboundReport.Reference5__c) 
                                                                                                                    AND Contact.AccountId != null];

             set<Id> accountIDs = new set<Id>();
             set<id> propertyIds = new set<Id>();
             if(!userList.isEmpty()){

                for(User user : userList){
                     
                    accountIDs.add(user.Contact.AccountId);
                }

                
                list<Property_Allocation__c> allocations = [Select Id,Name,Property__c from Property_Allocation__c 
                                                                                                where Contact__r.AccountId =: accountIDs ];

                for(Property_Allocation__c pro : allocations ){
                    propertyIds.add(pro.Property__c);
                }

                list<Installment__c> installmentList = [Select Id,Amount__c from Installment__c where (Deposit__r.Property__c IN: propertyIds
                                                                 OR Deposit__r.Customer__c IN : accountIDs
                                                                 ) 
                                                                 AND  Status__c = 'Pending'
                                                                 AND Installment_Type__c = 'Receivable'];

                if(!installmentList.isEmpty()){

                    Integer matchedInstallmentCount = 0;
                    Decimal totalInstallmentAmounts = 0;
                    String installmentId = '';
                    for(Installment__c insta : installmentList){
                        if(inboundReport.Amount__c == insta.Amount__c){
                            matchedInstallmentCount++;
                            installmentId = insta.Id;

                        }
                        totalInstallmentAmounts = totalInstallmentAmounts+insta.Amount__c;
                    }

                    if(matchedInstallmentCount == 1){
                        
                        //add Payment Mode
                        inboundReport.Installment__c = installmentId;
                        inboundReport.Matched_Colour__c = 'Amber';
                        try {
                            
                            Update inboundReport;
                            isMatched = true; 
                            
                        } catch (Exception exp) {
                            //create error logs
                        }
                    }else{
    
                        
                        if(inboundReport.Amount__c == totalInstallmentAmounts){
    
                            createInboundReports(installmentList,inboundReport,'Amber');
                            isMatched = true;
                        }
                        
                    }
                }
                
            }
        }
        if(!isMatched){
            //For Deposit STatus
            //should run last 
            list<Installment__c> installmentList = [Select ID,Name from Installment__c where Status__c = 'Pending' AND Installment_Type__c = 'Receivable' AND Amount__c =: inboundReport.Amount__c];
            if(!installmentList.isEmpty() && installmentList.size() == 1){
                Installment__c installment= installmentList[0];
                //add Payment Mode
                inboundReport.Installment__c = installment.Id;
                inboundReport.Matched_Colour__c = 'Amber';
                try {
                    
                    Update inboundReport;
                    isMatched = true;
                } catch (Exception exp) {
                    //create error logs
                }
                    
            }else{
                //Duplicate Deposits or Intsallments 
            }
        }


        ////Red Redddd
        if(!isMatched){
            //Update to Red
            
            try {
                inboundReport.Matched_Colour__c = 'Red';       
                Update inboundReport;
                
            } catch (Exception exp) {
                //create error logs
            }
        }

    }
   
    public void finish(Database.BatchableContext BC){
   
    }

    public static void createInboundReports(list<Installment__c> installmentList, Inbound_Report__c inboundReport, String colour){

        list<Inbound_Report__c> reportsToInsert = new list<Inbound_Report__c>();
        Id reportRecId = Schema.SObjectType.Inbound_Report__c.getRecordTypeInfosByName().get('SDS Inbound Report').getRecordTypeId();
        
        for(Installment__c inst : installmentList){
                
            Inbound_Report__c report = new Inbound_Report__c();
            report.RecordTypeId = reportRecId;
            report.Reference1__c = inboundReport.Reference1__c;
            report.Collection_Date__c = inboundReport.Collection_Date__c;
            report.Reference2__c = inboundReport.Reference2__c;
            report.Reference3__c = inboundReport.Reference3__c;
            report.Reference4__c = inboundReport.Reference4__c;
            report.Reference5__c = inboundReport.Reference5__c;
            report.Parent_Report__c = inboundReport.Id;
            report.Type__c = inboundReport.Type__c; 
            report.Amount__c = inst.Amount__c;
            report.Installment__c = inst.Id;
            report.File_Name__c = inboundReport.File_Name__c;
            
            report.Payment_Method__c = inboundReport.Payment_Method__c;
            
            report.Transaction_Id__c = inboundReport.Transaction_Id__c;

            report.Matched_Colour__c = colour;
            reportsToInsert.add(report);

            
            
        }
        if(!reportsToInsert.isEmpty()){
                
            insert reportsToInsert;

            update new Inbound_Report__c(Id = inboundReport.Id, Status__c = 'Inactive');
        }
    }
}