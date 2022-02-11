global class EI_FinalDepoBatchTest implements DataBase.Batchable<sObject> {
    
    global Database.queryLocator start(Database.BatchableContext BC){
       // Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();   
       // String query = 'SELECT Id, Status,Deposit_Account_Number__c,Deposit_Account_Number__r.Amount_Received_By_Scheme__c,Deposit_Account_Number__r.Amount_Paid_By_Scheme__c, Respond_Date__c FROM Case where Respond_Date__c != null AND Deposit_Account_Number__c!=null AND Deposit_Account_Number__r.Amount_Received_By_Scheme__c>0 AND (Status In (\'Deposit to be repaid – decision issued\', \'Deposit closed - deposit paid in part\', \'Deposit closed – unable to repay\',\'Deposit to be Repaid - Repayment Agreed\',\'Deposit to be repaid - resolved without adjudication\' ,\'Deposit to be repaid - court case\')) AND RecordtypeId=:devRecordTypeId AND  id=\'5008E00000K4XCJ\' ';  
        String query = 'SELECT Id, Name FROM Account limit 10';
        system.debug('line-->8 '+query);
        system.debug('line--> 9 -> ' + Database.query(query) );
        return Database.getQueryLocator(query);
    }
    
    global void execute(DataBase.BatchableContext BC,List<Account> caseList) {
        system.debug('line-->13'+caseList);
        for(Account c:caseList) {
            system.debug('line-->16'+c.Id);
        }
    }
    global void finish(DataBase.BatchableContext BC) {
        system.debug('line-->18 finish');
    }
    
    
}