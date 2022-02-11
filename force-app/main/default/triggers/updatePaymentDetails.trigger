/*
Created By: Tajinder Singh
Update payment details on Payment Object 
*/

trigger updatePaymentDetails on Bank_Account__c (after insert, after update) {
        
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        EI_BankAccount_Handler.updateBankAccount(trigger.new);
    }
    
}