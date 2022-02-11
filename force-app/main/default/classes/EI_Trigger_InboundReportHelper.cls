public class EI_Trigger_InboundReportHelper {

    //public static Boolean isRecursive = false;

    public static void createPayments(map<Id,Inbound_Report__c> oldMap,set<Id> inboundReportsIds){

        list<Inbound_Report__c> inboundReports = [Select Id,Status__c,Collection_Date__c,Matched_Colour__c,Installment__c,Amount__c,Installment__r.Deposit__c,
                                                                                    Installment__r.Deposit__r.Status__c,Payment_Method__c ,
                                                  									Installment__r.Deposit__r.Protected_Amount__c,
                                                                                    Installment__r.Deposit__r.Deposit_Amount__c,Installment__r.Installment_type__c
                                                                                    From Inbound_Report__c where ID IN: inboundReportsIds AND Amount__c != null AND RecordType.Name = 'SDS Inbound Report'];
        list<Payment__c> listPaymentToCreate = new list<Payment__c>();
        list<Deposit__c> depositToUpdate = new list<Deposit__c>();
        Id paymentRecId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('SDS Payment').getRecordTypeId();
        list<Installment__c> installmentsToUpdate = new list<Installment__c>();
        map<Id,Decimal> depositIdVSAmountTobeUpdated = new map<Id,Decimal>();
        map<Id,Decimal> depositIdVSDepositAmount = new map<Id,Decimal>();
        map<Id,Decimal> depositIdVSProtectedAmount = new map<Id,Decimal>();
        for(Inbound_Report__c report : inboundReports){
            if(report.Installment__c != null && report.Status__c != 'Inactive' && String.isBlank(report.Matched_Colour__c) && String.isNotBlank(oldMap.get(report.Id).Matched_Colour__c)){

                Payment__c payment = new Payment__c();
                payment.Inbound_Report__c = report.Id;
                payment.RecordTypeId = paymentRecId;
                payment.Installment__c = report.Installment__c;
                //??? Colletion Date 
                payment.Collection_Date__c = report.Collection_Date__c;
                payment.Amount__c = report.Amount__c;
                payment.DAN__c = report.Installment__r.Deposit__c;
                payment.Payment_Status__c = 'Paid';
                payment.Payment_Type__c = 'Receivable';
                listPaymentToCreate.add(payment);

                //Update Installment
                
                installmentsToUpdate.add(new Installment__c(Id=report.Installment__c,Status__c = 'Collected',Payment_Method__c = report.Payment_Method__c));
                

                //Update Deposit Status and Amounts
                if(report.Installment__r.Deposit__c != null && report.Installment__r.Deposit__r.Status__c != 'Deposits held by scheme'){
                    depositToUpdate.add(new Deposit__c(Id =report.Installment__r.Deposit__c,Status__c = 'Deposits held by scheme' ));
                }else if(report.Installment__r.Deposit__c != null){
                    
                    depositIdVSDepositAmount.put(report.Installment__r.Deposit__c,report.Installment__r.Deposit__r.Deposit_Amount__c);
                    depositIdVSProtectedAmount.put(report.Installment__r.Deposit__c,report.Installment__r.Deposit__r.Protected_Amount__c);
                    if(depositIdVSAmountTobeUpdated.containsKey(report.Installment__r.Deposit__c) && depositIdVSAmountTobeUpdated.get(report.Installment__r.Deposit__c) != null){
                        Decimal paymentAmount = depositIdVSAmountTobeUpdated.get(report.Installment__r.Deposit__c);
                        depositIdVSAmountTobeUpdated.put(report.Installment__r.Deposit__c,report.Amount__c+paymentAmount);
                    }else{
                        depositIdVSAmountTobeUpdated.put(report.Installment__r.Deposit__c,report.Amount__c);
                    }
                    
                }
                

                
            }
        }

        
        
        if(!listPaymentToCreate.isEmpty()){
            try {
                Insert listPaymentToCreate;
                if(!installmentsToUpdate.isEmpty()){
                    Update installmentsToUpdate;
                }
                if(!depositToUpdate.isEmpty()){
                    Update depositToUpdate;
                }
                if(!depositIdVSAmountTobeUpdated.isEmpty()){

                    list<Deposit__c> depositsToUpdateWithAmount = new list<Deposit__c>();
                    for(Id depositId : depositIdVSAmountTobeUpdated.keySet()){
                        Decimal depositAmountToUpdate = depositIdVSAmountTobeUpdated.get(depositId) + depositIdVSDepositAmount.get(depositId);
                        Decimal protectedAmountToUpdate = depositIdVSAmountTobeUpdated.get(depositId) + depositIdVSProtectedAmount.get(depositId);
                        if(protectedAmountToUpdate > depositIdVSDepositAmount.get(depositId)){
                            depositsToUpdateWithAmount.add(new Deposit__c(Id = depositId,Deposit_Amount__c = protectedAmountToUpdate,Protected_Amount__c = protectedAmountToUpdate));
                        }else{
                            depositsToUpdateWithAmount.add(new Deposit__c(Id = depositId,Protected_Amount__c = protectedAmountToUpdate));
                        }
                        
                    }

                    Update depositsToUpdateWithAmount;
                }
            } catch (Exception exc) {
                
            }
        }

        //???? Update Installment and deposit status 
    }

    public static void callAllocationBatch(set<Id> inboundReportIds){
        
        if(!inboundReportIds.isEmpty() && !System.isBatch() && !System.isFuture()){
            Database.executeBatch(new EI_BatchToAssociateInboundReports(inboundReportIds),1);
        }
    }
}