public without sharing class EI_TenantNotificationClass {    
  
    @AuraEnabled
    public static List<Deposit_Allocation__c> getdepositstatus( ){
    Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;  
    
        
    List<Deposit_Allocation__c> finalList = new List<Deposit_Allocation__c>();    
    list<Deposit_Allocation__c> alldata = [select id,Deposit__c, Deposit__r.Name,Deposit__r.LastModifiedDate,Deposit__r.Case_Status__c ,Deposit__r.Deposit_Account_Number__c,Deposit__r.Deposit_Amount_Amend__c,createdDate,Deposit__r.Property_Address__c,Deposit__r.ChangeOver_CaseStatus__c,Deposit_Holder__c,Istenantmoved__c from deposit_allocation__c where  (Deposit__r.Case_Status__c in('Decision issued - awaiting request for review','Review request accepted','Awaiting evidence review','Evidence gathering TT','Repayment disputed - self-resolution','Repayment requested - agent/landlord')OR Deposit__r.Deposit_Amount_Amend__c = true)  and Deposit_Holder__c =:accountid order by LastModifiedDate desc ];
    list<Deposit_Allocation__c>changeoverdata =[select id,Deposit__c, Deposit__r.Name,Deposit__r.LastModifiedDate,Deposit__r.Case_Status__c ,Deposit__r.Deposit_Account_Number__c,Deposit__r.Deposit_Amount_Amend__c,createdDate,Deposit__r.Property_Address__c,Deposit__r.ChangeOver_CaseStatus__c,Deposit_Holder__c,Istenantmoved__c from deposit_allocation__c where  (Deposit__r.Case_Status__c in('Tenant changeover initiated - agent/landlord','Tenant changeover initiated - tenant')AND Istenantmoved__c = true)  and Deposit_Holder__c =:accountid order by LastModifiedDate desc ];
        
        If(!alldata.isempty() && alldata.size()>0 ){
         finalList.addall(alldata);   
        }
        If(!changeoverdata.isempty() && changeoverdata.size()>0 ){
         finalList.addall(changeoverdata);   
        }
        
        
    return finalList;  
        
    }
    
   @auraEnabled
    public static string updateDeposit(string depositId){
        Deposit__c depo = new Deposit__c();
        depo.id= depositId;
        depo.Deposit_Amount_Amend__c = false;
        update depo;
        return 'success';
		 
    }
}