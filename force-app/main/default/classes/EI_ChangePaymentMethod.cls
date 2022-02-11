public class EI_ChangePaymentMethod {
	@AuraEnabled
    public static DepositInstallmentWrapper getDepositInstallmentData(String depositId){
        list<Deposit__c> deposits = [Select Id,Property_Address__c,Deposit_Account_Number__c,Protected_Amount__c, (Select Id,Payment_Method__c from Installments1__r ORDER BY CreatedDate DESC LIMIT 1) from Deposit__c where Id =:depositId Limit 1];
        
        DepositInstallmentWrapper depositInstallmentInstance = new DepositInstallmentWrapper();
        if(!deposits.isEmpty()){
            depositInstallmentInstance.objDeposit = deposits[0];
            if(!deposits[0].Installments1__r.isEmpty()){
                depositInstallmentInstance.objInstallment = deposits[0].Installments1__r[0];
            }
        }
        return depositInstallmentInstance ;
    }
    
    @AuraEnabled
    public static void cancelPayment(String depositId){
        if(String.isNotBlank(depositId)){
            try{
            	Update new Deposit__c(Id = depositId, Status__c = 'Registered (not paid)');
            }catch(Exception exc){
                
            }
        }
        
        //Message needs to be returned 
        
        
    }
    
    @AuraEnabled
    public static void updatePaymentMethod(String installmentId, String newMethod){
		if(String.isNotBlank(installmentId) && String.isNotBlank(newMethod)){
            try{
                Update new Installment__c(Id = installmentId, Payment_Method__c = newMethod);
            }catch(Exception exc){
                
            }  
        }
        //Message needs to be returned
    }
    
    /* wrapper class */  
    public class DepositInstallmentWrapper {
        @AuraEnabled public  Deposit__c objDeposit{get;set;}
        @AuraEnabled public  Installment__c objInstallment{get;set;}
    }
}