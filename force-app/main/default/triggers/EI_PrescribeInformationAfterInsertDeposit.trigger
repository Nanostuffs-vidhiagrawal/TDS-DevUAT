trigger EI_PrescribeInformationAfterInsertDeposit on Deposit__c (after insert,after update) {
    if(trigger.isAfter && trigger.isInsert ||  trigger.isAfter && trigger.IsUpdate ){
        for(Deposit__c depoObject : trigger.new){
          //  EI_PICertificateToAzure.savePICertificate(depoObject.id);
        }
    }

}