public  class EI_FinalDepositPaymentStatusBatch implements DataBase.Batchable<sObject> {
    
    
    Public Database.queryLocator start(Database.BatchableContext BC){
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();   
        String query = 'SELECT Id, Status,Deposit_Account_Number__c,Deposit_Account_Number__r.Amount_Received_By_Scheme__c,Deposit_Account_Number__r.Amount_Paid_By_Scheme__c, Respond_Date__c FROM Case where Respond_Date__c != null AND Deposit_Account_Number__c!=null AND Deposit_Account_Number__r.Amount_Received_By_Scheme__c>0  AND RecordtypeId=:devRecordTypeId AND  id=\'5008E00000K6rnmQAB\' ';  
      //  String query = 'SELECT Id, Status,Deposit_Account_Number__c,Deposit_Account_Number__r.Amount_Received_By_Scheme__c,Deposit_Account_Number__r.Amount_Paid_By_Scheme__c, Respond_Date__c FROM Case where Respond_Date__c != null AND Deposit_Account_Number__c!=null AND Deposit_Account_Number__r.Amount_Received_By_Scheme__c>0 AND (Status In (\'Deposit to be repaid – decision issued\', \'Deposit closed - deposit paid in part\', \'Deposit closed – unable to repay\',\'Deposit to be Repaid - Repayment Agreed\',\'Deposit to be repaid - resolved without adjudication\' ,\'Deposit to be repaid - court case\')) AND RecordtypeId=:devRecordTypeId AND  id=\'5008E00000K4XCJ\' ';  
        system.debug('line-->8 ' + query );
        return Database.getQueryLocator(query);
    }
    
    Public void execute(DataBase.BatchableContext BC,List<Case> caseList) {
        system.debug('line-->13' + caseList);
        list<case> modifycase = new list<case>();
        list<Deposit__c> modifydeposit = new list<Deposit__c>();
        Decimal totalprotectedamount =0;
        Decimal totalpayedamount =0;
        case newcase = new case();
        Deposit__c newdeposit = new Deposit__c ();
        for(case caseobj  : caseList){
            totalprotectedamount = caseobj.Deposit_Account_Number__r.Amount_Received_By_Scheme__c;
            totalpayedamount=caseobj.Deposit_Account_Number__r.Amount_Paid_By_Scheme__c;
            if(system.today() > caseobj.Respond_Date__c){
                system.debug('line--> 23' );
                newcase.Id =  caseobj.Id;
                newdeposit.Id = caseobj.Deposit_Account_Number__c;
                if(caseobj.status =='Deposit to be repaid – decision issued' || caseobj.status =='Deposit to be Repaid - Repayment Agreed' || caseobj.status == 'Deposit to be repaid - resolved without adjudication' || caseobj.status == 'Deposit to be repaid - court case'){
                    system.debug('line--> 24' + caseobj.status);
                    if(totalprotectedamount==totalpayedamount){
                        system.debug('line--> 28');
                        newcase.Status = 'Deposit closed – deposit repaid in full';
                        newdeposit.Status__c = 'Deposits repayments concluded in the last year';
                        modifycase.add(newcase);
                        modifydeposit.add(newdeposit);
                    }
                    if((totalprotectedamount > totalpayedamount) && totalpayedamount>0){
                        system.debug('line--> 35');
                        newcase.Status = 'Deposit closed - deposit paid in part';
                        newdeposit.Status__c = 'Deposits repayments concluded in the last year'; 
                        modifycase.add(newcase);
                        modifydeposit.add(newdeposit);
                    }
                    if((totalprotectedamount > totalpayedamount) && totalpayedamount==0){
                        system.debug('line--> 42');
                        newcase.Status = 'Deposit closed - unable to repay';
                        newdeposit.Status__c = 'Deposits repayments concluded in the last year'; 
                        modifycase.add(newcase);
                        modifydeposit.add(newdeposit);
                    }
                    
                }
                // modifycase.add(newcase);
                //  modifydeposit.add(newdeposit); 
                
                if(caseobj.status =='Deposit closed – deposit repaid in part' || caseobj.status =='Deposit closed – unable to repay'){
                    system.debug('line--> 51' + caseobj.status);
                  //  newcase.Id =  caseobj.Id;
                  //  newdeposit.Id = caseobj.Deposit_Account_Number__c;
                    
                    if(totalprotectedamount==totalpayedamount){
                        system.debug('line--> 59' + caseobj.status);
                        newcase.Status = 'Deposit closed – deposit repaid in full';
                        newdeposit.Status__c = 'Deposits repayments concluded in the last year';  
                        modifycase.add(newcase);
                        modifydeposit.add(newdeposit);
                    }
                    if( (totalprotectedamount > totalpayedamount) && totalpayedamount>0 ){
                        system.debug('line--> 66' + caseobj.status);
                        newcase.Status = 'Deposit closed – deposit repaid in part';
                        newdeposit.Status__c = 'Deposits repayments concluded in the last year';  
                        modifycase.add(newcase);
                        modifydeposit.add(newdeposit);
                    }
                }
                
            }
            
            else{
                
            }
            
        }    
        if(!modifycase.isempty()){
            Database.update(modifycase,false);
        }
        if(!modifydeposit.isempty()){
            Database.update(modifydeposit,false);
        }
        
        
        
    }
    Public void finish(DataBase.BatchableContext BC) {
        
        
    }
    
    
}