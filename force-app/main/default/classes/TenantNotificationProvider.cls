public class TenantNotificationProvider {
    
         @auraEnabled
    public static List<Deposit__c> CaseStatus(){
         Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit__c> finalList = new List<Deposit__c>();
        List<Case> caseList = new List<Case>();
        
        FinalList =  [ Select id,LastModifiedDate,Status__c,Deposit_Account_Number__c,Case_Status__c, (Select id,Deposit_Account_Number__c, Status from Cases__r where Status in ('Repayment disputed - self-resolution','Awaiting evidence review','Deposit held','Decision issued - awaiting request for review','Review of decision requested','Tenant changeover accepted','Deposit to be repaid - repayment agreed') order by createdDate desc Limit 1 ) from Deposit__c where Customer__c=:accountid];
      
                     return FinalList;
    
    }
                     
    }