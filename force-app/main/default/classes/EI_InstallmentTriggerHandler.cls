public without sharing class EI_InstallmentTriggerHandler {

    public static void createChequePayments(map<Id,Installment__c> oldMap, list<Installment__c> installmentList){

        list<Payment__c> listOfPaymentsToCreate = new list<Payment__c>();
        list<Installment__c> listOfInstallmentsToUpdate = new list<Installment__c>(); 
        list<Id> depositIdsToUpdate = new list<Id>();
        map<Id,Decimal> depositIdVsAmountToDecrease = new map<Id,Decimal>();
        Id paymentRecId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('SDS Payment').getRecordTypeId();

        for(Installment__c installment : installmentList){
            if(installment.Paid_By_Cheque__c && installment.Status__c == 'Pending Processing' && (oldMap == null || !oldMap.containsKey(installment.Id) || oldMap.get(installment.Id).Paid_By_Cheque__c != installment.Paid_By_Cheque__c)){
                
                
                //to update status of Installments
                listOfInstallmentsToUpdate.add(new Installment__c(Id = installment.Id,Status__c = 'Paid'));
                
                
                Payment__c payment = new Payment__c();
                payment.Installment__c = installment.Id;
                payment.RecordTypeId = paymentRecId;
                payment.Amount__c = installment.Amount__c;
                payment.DAN__c = installment.Deposit__c;
                payment.Payment_Status__c = 'Paid';
                payment.Payment_Type__c = 'Payable';
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
                EI_RepaymentsUtility.updateDepositAmounts(depositIdsToUpdate,depositIdVsAmountToDecrease);
    
    
            } catch (Exception exc) {
                //Create Logs 
            }
        }
    }
}