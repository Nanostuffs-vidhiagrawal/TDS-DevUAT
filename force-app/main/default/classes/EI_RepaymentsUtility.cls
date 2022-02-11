public without sharing class EI_RepaymentsUtility {
	
    @AuraEnabled
    public static list<InstallmentWrapper> returnInternationalInstallments(Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){

        list<InstallmentWrapper> wrapperToReturn = new list<InstallmentWrapper>();
        map<Id,Decimal> depositIdVsAmountToBePaid = new map<Id,Decimal>();
        map<Id,Decimal> depositIdVsMaxAmount = new map<Id,Decimal>();
        map<Id,list<InstallmentWrapper>> depositIdVslistInstallments = new map<Id,list<InstallmentWrapper>>();
        
        set<Id> parentIds = new set<Id>();
        map<Id,Integer> idVsNotes = new map<Id,Integer>();
        //???should be list of Installments
        list<InstallmentWrapper> installmentsUnableToPay = new list<InstallmentWrapper>();
        list<Installment__c> Installments = new list<Installment__c>();
        if(!isFilter){
            Installments = [Select Id,Name,
                                            Deposit__r.Deposit_Account_Number__c,
                                            Amount__c,
                                            Deposit__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,
                                            Deposit__r.Amount_Received_By_Scheme__c,
                                            Bank_Account_Holder_Name__c,Case__c,Case__r.CaseNumber,
                                            Custom_Account_Number__c,
                                            Bank_Name__c,Held_For_30_Days__c,
                                            Deposit__r.Amount_Paid_By_Scheme__c,
                                            Swift_Code__c,BIC__c,Contact__c,Contact__r.Name
                                            from Installment__c 
                                            where Status__c = 'Pending Processing'
                                            AND Cheque_Sent__c = false
                                            AND Installment_Type__c = 'Payable'
                                            AND Held_For_30_Days__c = true
                                            AND International_Payment__c = true
                                            AND Reason_For_Flag_Specified__c = ''
                                            AND Reason_For_Flag__c = ''
                            				AND RecordType.Name = 'SDS Installment'
                                            AND (LastModifiedDate != Today OR Pay_Today__c = true) ORDER BY Deposit__r.Deposit_Account_Number__c ASC];
        }else if(filterType == 'date'){
            
            endCreatedDate = endCreatedDate.addDays(1);
        	Installments = [Select Id,Name,
                                        Deposit__r.Deposit_Account_Number__c,
                                        Amount__c,
                                        Deposit__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,
                                        Deposit__r.Amount_Received_By_Scheme__c,
                                        Bank_Account_Holder_Name__c,Case__c,Case__r.CaseNumber,
                                        Custom_Account_Number__c,
                                        Bank_Name__c,Held_For_30_Days__c,
                                        Deposit__r.Amount_Paid_By_Scheme__c,
                                        Swift_Code__c,BIC__c,Contact__c,Contact__r.Name
                                        from Installment__c 
                                        where Status__c = 'Pending Processing'
                                        AND CreatedDate >: startCreatedDate
                                        AND CreatedDate <: endCreatedDate
                                        AND Cheque_Sent__c = false
                                        AND Installment_Type__c = 'Payable'
                                        AND Held_For_30_Days__c = true
                                        AND International_Payment__c = true
                                        AND Reason_For_Flag_Specified__c = ''
                                        AND Reason_For_Flag__c = ''
                            			AND RecordType.Name = 'SDS Installment'
                                        AND (LastModifiedDate != Today OR Pay_Today__c = true) ORDER BY Deposit__r.Deposit_Account_Number__c ASC];
        }else if(filterType == 'amount'){
            Installments = [Select Id,Name,
                                            Deposit__r.Deposit_Account_Number__c,
                                            Amount__c,
                                            Deposit__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,
                                            Deposit__r.Amount_Received_By_Scheme__c,
                                            Bank_Account_Holder_Name__c,Case__c,Case__r.CaseNumber,
                                            Custom_Account_Number__c,
                                            Bank_Name__c,Held_For_30_Days__c,
                                            Deposit__r.Amount_Paid_By_Scheme__c,
                                            Swift_Code__c,BIC__c,Contact__c,Contact__r.Name
                                            from Installment__c 
                                            where Status__c = 'Pending Processing'AND Amount__c =: amount
                                            AND Cheque_Sent__c = false
                                            AND Installment_Type__c = 'Payable'
                                            AND Held_For_30_Days__c = true
                                            AND International_Payment__c = true
                                            AND Reason_For_Flag_Specified__c = ''
                                            AND Reason_For_Flag__c = ''
                            				AND RecordType.Name = 'SDS Installment'
                                            AND (LastModifiedDate != Today OR Pay_Today__c = true) ORDER BY Deposit__r.Deposit_Account_Number__c ASC];
        }
        for(Installment__c installment : Installments){
            parentIds.add(installment.Deposit__c);
            if(String.isNotBlank(installment.Case__c)){
                parentIds.add(installment.Case__c);
            }
        }
        list<ContentDocumentLink> notesList = new list<ContentDocumentLink>();
        if(!parentIds.isEmpty()){
            notesList = [SELECT ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId IN : parentIds];
        }

        
        for(ContentDocumentLink note : notesList){
            if(idVsNotes.containsKey(note.LinkedEntityId)){
                Integer previousNumber = idVsNotes.get(note.LinkedEntityId);
                idVsNotes.put(note.LinkedEntityId,previousNumber+1);
            }else{
                idVsNotes.put(note.LinkedEntityId,1);
            }
        }
        for(Installment__c installment : Installments){

            InstallmentWrapper wrap = new InstallmentWrapper();
            wrap.isSelected = false;
            wrap.objInstallment = Installment;
            Integer numberOfNotes = 0;
            if(idVsNotes.containsKey(installment.Case__c)){
                numberOfNotes = numberOfNotes + idVsNotes.get(installment.Case__c);
            }
            if(idVsNotes.containsKey(installment.Deposit__c)){
                numberOfNotes = numberOfNotes + idVsNotes.get(installment.Deposit__c);
            }
            
            wrap.numberOfNotes = numberOfNotes;

            if(depositIdVslistInstallments.containsKey(installment.Deposit__c)){
                list<InstallmentWrapper> listToAdd = depositIdVslistInstallments.get(installment.Deposit__c);
                listToAdd.add(wrap);
                depositIdVslistInstallments.put(installment.Deposit__c,listToAdd);
            }else{

                depositIdVslistInstallments.put(installment.Deposit__c,new list<InstallmentWrapper>{wrap});
            }

            if(!depositIdVsMaxAmount.containsKey(installment.Deposit__c)){
                depositIdVsMaxAmount.put(installment.Deposit__c,installment.Deposit__r.Amount_Received_By_Scheme__c - installment.Deposit__r.Amount_Paid_By_Scheme__c);
            }
            

            if(depositIdVsAmountToBePaid.containsKey(installment.Deposit__c)){
                Decimal previousValue = depositIdVsAmountToBePaid.get(installment.Deposit__c);
                depositIdVsAmountToBePaid.put(installment.Deposit__c,installment.Amount__c+previousValue);
            }else{
                depositIdVsAmountToBePaid.put(installment.Deposit__c,installment.Amount__c);
            }

            
            
        }

        for(Id depositId : depositIdVslistInstallments.keySet()){
            
            if(depositIdVsAmountToBePaid.get(depositId) > depositIdVsMaxAmount.get(depositId)){
                installmentsUnableToPay.addAll(depositIdVslistInstallments.get(depositId));
            }else{
                wrapperToReturn.addAll(depositIdVslistInstallments.get(depositId));
            }
        }
        
        // Move to Unable To Pay 
        if(!installmentsUnableToPay.isEmpty()){
            moveToUnablePay(installmentsUnableToPay);
        }
        
        return wrapperToReturn; 
    }
    @AuraEnabled
    public static list<InstallmentWrapper> paySelected(list<InstallmentWrapper> wrapperList, String Id,Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){
        
        //list<Installment__c> InstallmentsToUpdate = new list<Installment__c>();
        list<Payment__c> listOfPaymentsToCreate = new list<Payment__c>();
        list<Installment__c> listOfInstallmentsToUpdate = new list<Installment__c>(); 
        list<Id> depositIdsToUpdate = new list<Id>();
        map<Id,Decimal> depositIdVsAmountToDecrease = new map<Id,Decimal>();
		Id paymentRecId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('SDS Payment').getRecordTypeId();
        for(InstallmentWrapper wrap : wrapperList){
            Installment__c installment = wrap.objInstallment;
            if(wrap.isSelected || (String.isNotBlank(Id) && Id == wrap.objInstallment.Id)){
                
                
                //to update status of Installments
                listOfInstallmentsToUpdate.add(new Installment__c(Id = installment.Id,Status__c = 'Paid'));
                
                
                Payment__c payment = new Payment__c();
                payment.Installment__c = installment.Id;
                payment.Amount__c = installment.Amount__c;
                payment.DAN__c = installment.Deposit__c;
                payment.Payment_Status__c = 'Paid';
                payment.Payment_Type__c = 'Payable';
                payment.RecordTypeId = paymentRecId;
                listOfPaymentsToCreate.add(payment);

                depositIdsToUpdate.add(installment.Deposit__c);
                if(depositIdVsAmountToDecrease.containsKey(installment.Deposit__c)){

                    Decimal previousValue = depositIdVsAmountToDecrease.get(installment.Deposit__c);
                    depositIdVsAmountToDecrease.put(installment.Deposit__c,installment.Amount__c+previousValue);
                }else{
                    depositIdVsAmountToDecrease.put(installment.Deposit__c,installment.Amount__c);
                }
                

            }
        }
        
        
        if(!listOfInstallmentsToUpdate.isEmpty()){
            try {
                Update listOfInstallmentsToUpdate;
                Insert listOfPaymentsToCreate;
                //to update deposit status
                updateDepositAmounts(depositIdsToUpdate,depositIdVsAmountToDecrease);


            } catch (Exception exc) {
                //Create Logs 
            }
        }
        return returnInternationalInstallments(amount,isFilter,filterType,startCreatedDate,endCreatedDate);
    }

    public static void updateDepositAmounts(list<Id> depositIdsToUpdate,map<Id,Decimal> depositIdVsAmountToDecrease){

        list<Deposit__c> depositsToUpdate = new list<Deposit__c>();

        for(Deposit__c deposit : [Select Id,Status__c,Protected_Amount__c,Deposit_Amount__c,Amount_Received_By_Scheme__c,Amount_Paid_By_Scheme__c from Deposit__c where Id IN: depositIdsToUpdate]){
            //???? Update Status of Deposit According To Amount 
            deposit.Protected_Amount__c = deposit.Protected_Amount__c - depositIdVsAmountToDecrease.get(deposit.Id);
            deposit.Deposit_Amount__c = deposit.Deposit_Amount__c - depositIdVsAmountToDecrease.get(deposit.Id);
            //deposit.Status__c = 'Deposits repayments concluded in the last year'; 
            depositsToUpdate.add(deposit);
        }

        if(!depositsToUpdate.isEmpty()){
            Update depositsToUpdate;
        }
        
    }
    public static void moveToUnablePay(list<InstallmentWrapper> installmentsUnableToPay){
        
        list<Installment__c> installmentsToUpdate = new list<Installment__c>();
        for(InstallmentWrapper wrap : installmentsUnableToPay){
            installmentsToUpdate.add(new Installment__c(Id = wrap.objInstallment.Id, Reason_For_Flag__c = 'Payment amount is greater than the amount held'));
        }

        if(!installmentsToUpdate.isEmpty()){
            Update installmentsToUpdate;
        }
    }
    @AuraEnabled
    public static list<InstallmentWrapper> getUnableInstallments(Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){
		set<Id> parentIds = new set<Id>();
        map<Id,Integer> idVsNotes = new map<Id,Integer>();
        list<Installment__c> installments = new list<Installment__c>();
        
        if(!isFilter){
            
        
            installments = [Select Id,Name,Case__c,Case__r.CaseNumber,
                                                        Deposit__r.Deposit_Account_Number__c,   
                                                        Amount__c,Contact__c,Contact__r.Name,
                                                        Deposit__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,
                                                        Deposit__r.Amount_Received_By_Scheme__c,
                                                        Bank_Account_Holder_Name__c,Bank_Sort_Code__c,
                                                        Custom_Account_Number__c,Bank_Account_Number__c,
                                                        Bank_Name__c,Held_For_30_Days__c,LastModifiedDate,
                                                        Deposit__r.Amount_Paid_By_Scheme__c from Installment__c 
                                                        where Status__c = 'Pending Processing'
                                                            AND Cheque_Sent__c = false
                            								AND RecordType.Name = 'SDS Installment'
                                                            AND Installment_Type__c = 'Payable'
                                                            AND (Held_For_30_Days__c = false
                                                            OR Bank_Name__c = ''
                                                            OR LastModifiedDate = Today
                                                            OR Bank_Account_Holder_Name__c = ''
                                                            OR Reason_For_Flag_Specified__c != ''
                                                            OR Reason_For_Flag__c != ''
                                                            OR(Bank_Sort_Code__c = '' AND International_Payment__c = false)
                                                            OR(Bank_Account_Number__c = '' AND International_Payment__c = false)
                                                            )];
        }else if(filterType == 'date'){
            
            
            endCreatedDate = endCreatedDate.addDays(1);
            
            installments = [Select Id,Name,Case__c,Case__r.CaseNumber,
                                                        Deposit__r.Deposit_Account_Number__c,   
                                                        Amount__c,Contact__c,Contact__r.Name,
                                                        Deposit__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,
                                                        Deposit__r.Amount_Received_By_Scheme__c,
                                                        Bank_Account_Holder_Name__c,Bank_Sort_Code__c,
                                                        Custom_Account_Number__c,Bank_Account_Number__c,
                                                        Bank_Name__c,Held_For_30_Days__c,LastModifiedDate,
                                                        Deposit__r.Amount_Paid_By_Scheme__c from Installment__c 
                                                        where Status__c = 'Pending Processing'
                            								AND CreatedDate >: startCreatedDate
                            								AND CreatedDate <: endCreatedDate
                            								AND RecordType.Name = 'SDS Installment'
                                                            AND Cheque_Sent__c = false
                                                            AND Installment_Type__c = 'Payable'
                                                            AND (Held_For_30_Days__c = false
                                                            OR Bank_Name__c = ''
                                                            OR LastModifiedDate = Today
                                                            OR Bank_Account_Holder_Name__c = ''
                                                            OR Reason_For_Flag_Specified__c != ''
                                                            OR Reason_For_Flag__c != ''
                                                            OR(Bank_Sort_Code__c = '' AND International_Payment__c = false)
                                                            OR(Bank_Account_Number__c = '' AND International_Payment__c = false)
                                                            )];
            
        }else if(filterType == 'amount'){
            
            installments = [Select Id,Name,Case__c,Case__r.CaseNumber,
                                                        Deposit__r.Deposit_Account_Number__c,   
                                                        Amount__c,Contact__c,Contact__r.Name,
                                                        Deposit__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,
                                                        Deposit__r.Amount_Received_By_Scheme__c,
                                                        Bank_Account_Holder_Name__c,Bank_Sort_Code__c,
                                                        Custom_Account_Number__c,Bank_Account_Number__c,
                                                        Bank_Name__c,Held_For_30_Days__c,LastModifiedDate,
                                                        Deposit__r.Amount_Paid_By_Scheme__c from Installment__c 
                                                        where Status__c = 'Pending Processing'
                                                            AND Cheque_Sent__c = false AND Amount__c =: amount
                            								AND RecordType.Name = 'SDS Installment'
                                                            AND Installment_Type__c = 'Payable'
                                                            AND (Held_For_30_Days__c = false
                                                            OR Bank_Name__c = ''
                                                            OR LastModifiedDate = Today
                                                            OR Bank_Account_Holder_Name__c = ''
                                                            OR Reason_For_Flag_Specified__c != ''
                                                            OR Reason_For_Flag__c != ''
                                                            OR(Bank_Sort_Code__c = '' AND International_Payment__c = false)
                                                            OR(Bank_Account_Number__c = '' AND International_Payment__c = false)
                                                            )];
            
        }
        //
        list<InstallmentWrapper> wrapperToReturn = new list<InstallmentWrapper>();
        for(Installment__c installment : Installments){
            parentIds.add(installment.Deposit__c);
            if(String.isNotBlank(installment.Case__c)){
                parentIds.add(installment.Case__c);
            }
        }
        list<ContentDocumentLink> notesList = new list<ContentDocumentLink>();
        if(!parentIds.isEmpty()){
            notesList = [SELECT ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId IN : parentIds];
        }
   
        for(ContentDocumentLink note : notesList){
            if(idVsNotes.containsKey(note.LinkedEntityId)){
                Integer previousNumber = idVsNotes.get(note.LinkedEntityId);
                idVsNotes.put(note.LinkedEntityId,previousNumber+1);
            }else{
                idVsNotes.put(note.LinkedEntityId,1);
            }
        }
        for(Installment__c installment : installments){

            InstallmentWrapper wrap = new InstallmentWrapper();
            //wrap.isSelected = false;
            wrap.objInstallment = installment;
            Date modifiedDate = date.newinstance(installment.LastModifiedDate.year(), installment.LastModifiedDate.month(), installment.LastModifiedDate.day());
            if(modifiedDate == System.today()){
                wrap.isAddedToday = true;
            }
            Integer numberOfNotes = 0;
            if(idVsNotes.containsKey(installment.Case__c)){
                numberOfNotes = numberOfNotes + idVsNotes.get(installment.Case__c);
            }
            if(idVsNotes.containsKey(installment.Deposit__c)){
                numberOfNotes = numberOfNotes + idVsNotes.get(installment.Deposit__c);
            }
            
            wrap.numberOfNotes = numberOfNotes;
            wrapperToReturn.add(wrap);
        }
        return wrapperToReturn;

    }

    @AuraEnabled
    public static list<InstallmentWrapper> getUKInstallmentsToPay(Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){
        list<InstallmentWrapper> wrapperToReturn = new list<InstallmentWrapper>();
        map<Id,Decimal> depositIdVsAmountToBePaid = new map<Id,Decimal>();
        map<Id,Decimal> depositIdVsMaxAmount = new map<Id,Decimal>();
        map<Id,list<InstallmentWrapper>> depositIdVslistInstallments = new map<Id,list<InstallmentWrapper>>();
        list<InstallmentWrapper> installmentsUnableToPay = new list<InstallmentWrapper>();
        set<Id> parentIds = new set<Id>();
        map<Id,Integer> idVsNotes = new map<Id,Integer>();
        Date nextWorkingDate = EI_UtilityClassForPayments.dueDateMethod(System.today(),1);
        list<Installment__c> installments = new list<Installment__c>();
        
        if(!isFilter){
            installments = [Select Id,Name,Case__c,
                                                        Deposit__r.Deposit_Account_Number__c,
                                                        Amount__c,Case__r.CaseNumber,
                                                        Deposit__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,
                                                        Deposit__r.Amount_Received_By_Scheme__c,
                                                        Bank_Account_Holder_Name__c,
                                                        Custom_Account_Number__c,
                                                        Bank_Name__c,Held_For_30_Days__c,
                                                        Bank_Sort_Code__c,Bank_Account_Number__c,
                                                        Deposit__r.Amount_Paid_By_Scheme__c from Installment__c
                                                         
                                                        where Status__c = 'Pending Processing'
                                                            AND Cheque_Sent__c = false
                                                            AND Installment_Type__c = 'Payable'
                                                            AND Held_For_30_Days__c = true
                            								AND RecordType.Name = 'SDS Installment'
                                                            AND Bank_Name__c != ''
                                                            AND International_Payment__c = false
                                                            AND Bank_Account_Holder_Name__c != ''
                                                            AND Reason_For_Flag_Specified__c = ''
                                                            AND Reason_For_Flag__c = ''
                                                            AND Bank_Account_Number__c != ''
                                                            AND (LastModifiedDate != Today OR Pay_Today__c = true)
                                                            AND Bank_Sort_Code__c != '' ORDER BY Deposit__r.Deposit_Account_Number__c ASC];
        
        }else if(filterType == 'date'){
            endCreatedDate = endCreatedDate.addDays(1);
            installments = [Select Id,Name,Case__c,
                                                        Deposit__r.Deposit_Account_Number__c,
                                                        Amount__c,Case__r.CaseNumber,
                                                        Deposit__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,
                                                        Deposit__r.Amount_Received_By_Scheme__c,
                                                        Bank_Account_Holder_Name__c,
                                                        Custom_Account_Number__c,
                                                        Bank_Name__c,Held_For_30_Days__c,
                                                        Bank_Sort_Code__c,Bank_Account_Number__c,
                                                        Deposit__r.Amount_Paid_By_Scheme__c from Installment__c
                                                         
                                                        where Status__c = 'Pending Processing'
                                                            AND Cheque_Sent__c = false
                                                            AND Installment_Type__c = 'Payable'
                            								AND CreatedDate >: startCreatedDate
                            								AND CreatedDate <: endCreatedDate
                                                            AND Held_For_30_Days__c = true
                            								AND RecordType.Name = 'SDS Installment'
                                                            AND Bank_Name__c != ''
                                                            AND International_Payment__c = false
                                                            AND Bank_Account_Holder_Name__c != ''
                                                            AND Reason_For_Flag_Specified__c = ''
                                                            AND Reason_For_Flag__c = ''
                                                            AND Bank_Account_Number__c != ''
                                                            AND (LastModifiedDate != Today OR Pay_Today__c = true)
                                                            AND Bank_Sort_Code__c != '' ORDER BY Deposit__r.Deposit_Account_Number__c ASC];
            
            
        }else if(filterType == 'amount'){
            installments = [Select Id,Name,Case__c,
                                                        Deposit__r.Deposit_Account_Number__c,
                                                        Amount__c,Case__r.CaseNumber,
                                                        Deposit__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,
                                                        Deposit__r.Amount_Received_By_Scheme__c,
                                                        Bank_Account_Holder_Name__c,
                                                        Custom_Account_Number__c,
                                                        Bank_Name__c,Held_For_30_Days__c,
                                                        Bank_Sort_Code__c,Bank_Account_Number__c,
                                                        Deposit__r.Amount_Paid_By_Scheme__c from Installment__c
                                                         
                                                        where Status__c = 'Pending Processing'
                                                            AND Cheque_Sent__c = false AND Amount__c =: amount
                                                            AND Installment_Type__c = 'Payable'
                                                            AND Held_For_30_Days__c = true
                            								AND RecordType.Name = 'SDS Installment'
                                                            AND Bank_Name__c != ''
                                                            AND International_Payment__c = false
                                                            AND Bank_Account_Holder_Name__c != ''
                                                            AND Reason_For_Flag_Specified__c = ''
                                                            AND Reason_For_Flag__c = ''
                                                            AND Bank_Account_Number__c != ''
                                                            AND (LastModifiedDate != Today OR Pay_Today__c = true)
                                                            AND Bank_Sort_Code__c != '' ORDER BY Deposit__r.Deposit_Account_Number__c ASC];
        }
        for(Installment__c installment : Installments){
            parentIds.add(installment.Deposit__c);
            if(String.isNotBlank(installment.Case__c)){
                parentIds.add(installment.Case__c);
            }
        }
        list<ContentDocumentLink> notesList = new list<ContentDocumentLink>();
        if(!parentIds.isEmpty()){
            notesList = [SELECT ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId IN : parentIds];
        }
   
        for(ContentDocumentLink note : notesList){
            if(idVsNotes.containsKey(note.LinkedEntityId)){
                Integer previousNumber = idVsNotes.get(note.LinkedEntityId);
                idVsNotes.put(note.LinkedEntityId,previousNumber+1);
            }else{
                idVsNotes.put(note.LinkedEntityId,1);
            }
        }
        for(Installment__c installment : installments){
			
            InstallmentWrapper wrap = new InstallmentWrapper();
            wrap.isSelected = false;
            wrap.objInstallment = installment;
            Integer numberOfNotes = 0;
            String days = String.valueOf(nextWorkingDate.day());
            String months = String.valueOf(nextWorkingDate.month());
            
            
            if(days.length() == 1){
                days = '0'+days;
            }
            if(months.length() == 1){
                months = '0'+months;
            }
            
            
            wrap.workingDate = days+months+String.valueOf(nextWorkingDate.year());
            if(idVsNotes.containsKey(installment.Case__c)){
                numberOfNotes = numberOfNotes + idVsNotes.get(installment.Case__c);
            }
            if(idVsNotes.containsKey(installment.Deposit__c)){
                numberOfNotes = numberOfNotes + idVsNotes.get(installment.Deposit__c);
            }
            
            wrap.numberOfNotes = numberOfNotes;

            if(depositIdVslistInstallments.containsKey(installment.Deposit__c)){
                list<InstallmentWrapper> listToAdd = depositIdVslistInstallments.get(installment.Deposit__c);
                listToAdd.add(wrap);
                depositIdVslistInstallments.put(installment.Deposit__c,listToAdd);
            }else{

                depositIdVslistInstallments.put(installment.Deposit__c,new list<InstallmentWrapper>{wrap});
            }

            if(!depositIdVsMaxAmount.containsKey(installment.Deposit__c)){
                depositIdVsMaxAmount.put(installment.Deposit__c,installment.Deposit__r.Amount_Received_By_Scheme__c - installment.Deposit__r.Amount_Paid_By_Scheme__c);
            }
            

            if(depositIdVsAmountToBePaid.containsKey(installment.Deposit__c)){
                Decimal previousValue = depositIdVsAmountToBePaid.get(installment.Deposit__c);
                depositIdVsAmountToBePaid.put(installment.Deposit__c,installment.Amount__c+previousValue);
            }else{
                depositIdVsAmountToBePaid.put(installment.Deposit__c,installment.Amount__c);
            }

            
            
        }

        for(Id depositId : depositIdVslistInstallments.keySet()){
            
            if(depositIdVsAmountToBePaid.get(depositId) > depositIdVsMaxAmount.get(depositId)){
                installmentsUnableToPay.addAll(depositIdVslistInstallments.get(depositId));
            }else{
                wrapperToReturn.addAll(depositIdVslistInstallments.get(depositId));
            }
        }
        
        // Move to Unable To Pay 
        if(!installmentsUnableToPay.isEmpty()){
            moveToUnablePay(installmentsUnableToPay);
        }
        
        return wrapperToReturn;
    }
    @AuraEnabled
    public static list<InstallmentWrapper> payUKInstallments(list<InstallmentWrapper> wrapperList, Boolean doAll,Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){
        
        list<Payment__c> listOfPaymentsToCreate = new list<Payment__c>();
        list<Installment__c> listOfInstallmentsToUpdate = new list<Installment__c>();
        list<Id> depositIdsToUpdate = new list<Id>();
        map<Id,Decimal> depositIdVsAmountToDecrease = new map<Id,Decimal>();
        Id paymentRecId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('SDS Payment').getRecordTypeId();
        for(InstallmentWrapper wrap : wrapperList){
            if(doAll || wrap.isSelected){
                Installment__c installment = wrap.objInstallment;
                    
                
                //to update status of Installments
                listOfInstallmentsToUpdate.add(new Installment__c(Id = installment.Id,Status__c = 'Paid'));
                
                
                Payment__c payment = new Payment__c();
                payment.Installment__c = installment.Id;
                payment.Amount__c = installment.Amount__c;
                payment.DAN__c = installment.Deposit__c;
                payment.Payment_Status__c = 'Paid';
                payment.Payment_Type__c = 'Payable';
                payment.RecordTypeId = paymentRecId;
                listOfPaymentsToCreate.add(payment);

                depositIdsToUpdate.add(installment.Deposit__c);
                if(depositIdVsAmountToDecrease.containsKey(installment.Deposit__c)){

                    Decimal previousValue = depositIdVsAmountToDecrease.get(installment.Deposit__c);
                    depositIdVsAmountToDecrease.put(installment.Deposit__c,installment.Amount__c+previousValue);
                }else{
                    depositIdVsAmountToDecrease.put(installment.Deposit__c,installment.Amount__c);
                }
            }    

        }
        
        
        if(!listOfInstallmentsToUpdate.isEmpty()){
            try {
                Update listOfInstallmentsToUpdate;
                Insert listOfPaymentsToCreate;
                //to update deposit status
                updateDepositAmounts(depositIdsToUpdate,depositIdVsAmountToDecrease);


            } catch (Exception exc) {
                //Create Logs 
            }
        }
        return getUKInstallmentsToPay(amount,isFilter, filterType, startCreatedDate, endCreatedDate);
    }
    @AuraEnabled
    public static Map<String, String> getReasons(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = Installment__c.Reason_For_Flag__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    @AuraEnabled
    public static list<InstallmentWrapper> updateInstallments(String recId, String reason, String reasonSpecified, String paymentType,Decimal amount,Boolean isFilter, String filterType, Date startCreatedDate, Date endCreatedDate){

        Installment__c inst = new Installment__c();
        inst.Id = recId;
        inst.Reason_For_Flag__c = reason;
        if(String.isNotBlank(reasonSpecified))
            inst.Reason_For_Flag_Specified__c = reasonSpecified;
        
        Update inst;

        if(paymentType == 'UK'){
            return getUKInstallmentsToPay(amount,isFilter, filterType, startCreatedDate, endCreatedDate);
        }else{
            return returnInternationalInstallments(amount,isFilter,filterType,startCreatedDate,endCreatedDate);
        }
    }

    public class InstallmentWrapper{
        @AuraEnabled public  Installment__c objInstallment{get;set;}
        @AuraEnabled public  Boolean isSelected{get;set;}
        @AuraEnabled public Integer numberOfNotes{get;set;}
        @AuraEnabled public Boolean isAddedToday = false;
        @AuraEnabled public String workingDate{get;set;}

        
    }
}