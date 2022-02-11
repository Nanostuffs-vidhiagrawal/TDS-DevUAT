public class EI_BankAccount_Handler {

    public static void updateBankAccount(List<Bank_Account__c> bnkAccs) {
        
        Set<Id> bnkAccIds = new Set<Id>();
        Set<Id> conId = new Set<Id>();
        for(Bank_Account__c bnkAcc : bnkAccs) {
            conId.add(bnkAcc.Contact__c);
        }
        List<Installment__c> installments=[Select id, Status__c, Contact__c, Created_at__c, Bank_account_holder_name__c, Bank_account_number__c,
                                           Amount__c, Bank_name__c,Bank_sort_code__c from Installment__c where Contact__c in: conId and 
                                           Status__c = 'Pending Processing'];
        
        set<Id> installmentId = new set<Id>();
        List<Installment__c> installmentList = new List<Installment__c>();
        //List<cpm__Payment__c> paymentList = new List<cpm__Payment__c>();
        Map<Id,Bank_Account__c> bankDetails = new Map<Id,Bank_Account__c>();
        for(Bank_Account__c bankAcc : bnkAccs) {
            conId.add(bankAcc.Contact__c);
            bankDetails.put(bankAcc.Contact__c,bankAcc);
        }
        for(Installment__c inst : installments) {
            installmentId.add(inst.Id);
            if(!bankDetails.get(inst.Contact__c).ValidInternationBankDetails__c) {
                inst.Bank_account_number__c = bankDetails.get(inst.Contact__c).International_Account_Number__c;
                inst.Bank_name__c = bankDetails.get(inst.Contact__c).International_Bank_Name__c;
                inst.Custom_Account_Number__c = bankDetails.get(inst.Contact__c).IBAN__c;
                inst.Swift_Code__c = 	bankDetails.get(inst.Contact__c).Swift_Code__c; 
                inst.BIC__c = 	bankDetails.get(inst.Contact__c).BIC__c; 
                inst.Bank_account_holder_name__c = bankDetails.get(inst.Contact__c).International_Bank_Account_Holder_Name__c;
                inst.International_Payment__c = true;
                
            } else {
                inst.Bank_account_number__c = bankDetails.get(inst.Contact__c).Account_Number__c;
                inst.Bank_name__c = bankDetails.get(inst.Contact__c).Bank_Name__c;
                inst.Bank_sort_code__c = bankDetails.get(inst.Contact__c).Sort_Code__c;
                inst.Bank_account_holder_name__c = bankDetails.get(inst.Contact__c).Bank_Account_Holder_Name__c;
                inst.International_Payment__c = false;
            } 
            //   inst.cpm__Installment__r.cpm__Status__c = 'Outstanding';
            installmentList.add(inst);
        }
        /*for(Id insallID : installmentId){
        Installment__c installRecord = new Installment__c(id=insallID,cpm__Status__c='Outstanding');
        installmentList.add(installRecord);
        }
        if(paymentList.size()>0) {
        update paymentList;
        }*/
        if(installmentList.size()>0) {
            update installmentList;
        }
        
    }
    
}