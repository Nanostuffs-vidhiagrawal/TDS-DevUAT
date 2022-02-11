public class EI_PaymentsTriggerHelper {
    
    public static void validatePayments(list<Payment__c> paymentList, set<Id> newIds){
        
        Set<id> installmentIds = new Set<id>();
        Map<id, Installment__c> mapInstallment = new Map<id, Installment__c>();
      
        for (Payment__c pay : paymentList) {
            installmentIds.add(pay.Installment__c);
        }
      
        List<Installment__c> installmentList = [SELECT Id, Name,(Select Id from Payments__r) FROM Installment__c WHERE Id IN : installmentIds];
        if (!installmentList.isEmpty()) {
            map<Id,Integer> idVsSize = new map<Id,Integer>();
            for(Installment__c inst : installmentList){
                idVsSize.put(inst.Id,inst.Payments__r.size());
            }
            for (Payment__c pay : paymentList) {
                if (idVsSize.containsKey(pay.Installment__c) && idVsSize.get(pay.Installment__c) > 1) {
                    pay.addError('A Payment already exist for the Installment');
                }
            }
        }
    }

}