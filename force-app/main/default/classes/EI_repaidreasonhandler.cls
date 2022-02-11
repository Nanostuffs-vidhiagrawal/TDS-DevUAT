public class EI_repaidreasonhandler {
    
    
public static void repaidReasonStatus(list<Deposit__c>depList){
          
        list<Deposit__c>updatedepList = new  list<deposit__c> ();
          
          for (Deposit__c dep : depList){    
              
              if(dep.Case_Status__c =='Deposit to be repaid – decision issued') {            
                  dep.Repaid_reason_status__c = 'Dispute';
                  // updatedepList.add(dep);                 
              }
              
              if((dep.Case_Status__c =='Deposit to be repaid - repayment agreed') || (dep.Case_Status__c =='Deposit to be repaid - resolved without adjudication')|| (dep.Case_Status__c =='Deposit to be repaid - court case')) {
                  dep.Repaid_reason_status__c = 'Tenancy closed';            
                  //	updatedepList.add(dep);
              } 
              if (dep.Case_Status__c == 'Deposit transferred'){              
                  dep.Repaid_reason_status__c = 'Transfer';
                  //updatedepList.add(dep);
              }             
              
          }        
  } 
    
 public static void repaidReasonStatus1(list<Deposit__c>depList1){
        system.debug('line no28'+depList1);
        
        for(Deposit__c objDeposit:depList1){             
            objDeposit.Depositnew_Date_Status__c =system.today();        
            
        }
    }
    
 public static void repaidReasonStatus2(list<Deposit__c>depList2,Map<Id, Deposit__c>depMap){ 
        
     for(Deposit__c objDeposit:depList2){                
         if(depMap!= null){
             if(depMap.get(objDeposit.Id).status__c !=objDeposit.Status__c){
                 objDeposit.Depositnew_Date_Status__c =system.today();
             } 
         }             
     }            
    }
    

}