public without sharing class EI_sdsDepositReportController {
    
    @AuraEnabled
    public static List<Deposit__c>fetchdeposit1(Date startDate, Date endDate){
        
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        //System.debug('Account Id : ' + accountId);
        
        List<Deposit__c> depositList = new List<Deposit__c>();       
        for(deposit__c dep:[select Id,Deposit_Account_Number__c,Property_Address__c,Protection_Start_Date__c,End_Date__c,Repaid_reason_status__c,Deposit_Amount__c,Customer__r.name,Case_Status__c,Amount_paid_to_TenantNew__c,Amount_paid_to_AG_LL__c,
                            (select id,Total_Amount_Requested_AL__c,Deposit__c from Repayment_Requests__r Limit 1) from Deposit__c where customer__c =:accountid AND Case_Status__c IN ('Deposit closed - deposit paid in part','Deposit closed - deposit repaid in full','Deposit closed - unable to repay')
                            AND CreatedDate>=:startDate AND CreatedDate <=:endDate]){
                                depositList.add(dep);
                            }      
        //system.debug('::line-->15'+depositList);
        return depositList;    
        
    }
    
     @AuraEnabled
    public static List<Deposit__c>fetchdeposit2(Date startDate, Date endDate){
        System.debug('startDate : ' + startDate + '	endDate : ' + endDate);
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        System.debug('Account Id : ' + accountId);
        //return accountid;
        System.debug('startDate : ' + startDate + '	endDate : ' + endDate);  
        
        List<Deposit__c> depositList = new List<Deposit__c>();       
        for(deposit__c dep : [select Id,Deposit_Account_Number__c,Property_Address__c,Status__c,Deposit_Amount__c,Amount_paid_to_TenantNew__c,Case_Status__c,Repaid_reason_status__c,
                              Amount_paid_to_AG_LL__c,Customer__r.name,CreatedDate from Deposit__c 
                              where customer__c =:accountid AND Case_Status__c IN ('Deposit closed - deposit paid in part','Deposit closed - deposit repaid in full','Deposit closed - unable to repay','Rejected') 
                              AND Status__c = 'Deposits repayments concluded in the last year' AND CreatedDate>=:startDate AND CreatedDate <=:endDate ]){
                                  depositList.add(dep);
                              }      
        system.debug('line-->38'+depositList);
        return depositList;    
       
    }    
    
    @AuraEnabled
 public static List<Deposit__c>fetchdeposit3(Date startDate, Date endDate){
     System.debug('startDate : ' + startDate + '	endDate : ' + endDate);
     Id accountid = [Select id, Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
     System.debug('Account Id : ' + accountId);
     //return accountid;
     System.debug('startDate : ' + startDate + '	endDate : ' + endDate);        
     List<Deposit__c> depositList = new List<Deposit__c>();       
     for(deposit__c dep : [select Id,Deposit_Account_Number__c,Property_Address__c,Protection_Start_Date__c,Deposit_Amount__c,Number_of_Tenants__c,Protected_Amount__c,No_of_days_status__c,
                           Customer__r.name,Status__c,CreatedDate from Deposit__c
                           where customer__c =:accountid AND 
                           Status__c IN ('Registered (not paid)','Awaiting payment','Deposits held by scheme',
                          'Repayment requested by tenant','Repayment requested by agent/landlord','Repayment not agreed - In self-resolution',
                          'Repayment not agreed - In dispute resolution','Repayment process') 
                           AND CreatedDate>=:startDate AND CreatedDate <=:endDate ]){
                               depositList.add(dep);
                           }
     system.debug('line-->56'+depositList);
     return depositList;    
       
    }    
     
     @AuraEnabled
    public static List<Deposit__c>fetchdeposit4 (){
       // System.debug('startDate : ' + startDate + '	endDate : ' + endDate);
        Id accountid = [Select id, Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        System.debug('Account Id : ' + accountId);
        //return accountid;
       // System.debug('startDate : ' + startDate + '	endDate : ' + endDate);
       
        Date startDate= System.today()-365;
        Date endDate = System.today();
        
        List<Deposit__c> depositList = new List<Deposit__c>();       
        for(deposit__c dep : [select Id,Deposit_Account_Number__c,Property_Address__c,Protection_Start_Date__c,Deposit_Amount__c,
                              Repaid_reason_status__c,Amount_paid_to_TenantNew__c,Amount_paid_to_AG_LL__c, Case_Status__c,
                              Customer__r.name,Status__c,CreatedDate,(select id,Total_Amount_Requested_AL__c,
                              Deposit__c from Repayment_Requests__r limit 1) from Deposit__c where customer__c =:accountid AND 
                              Status__c ='Deposits repayments concluded in the last year' AND 
                              Case_Status__c IN ('Deposit closed - deposit paid in part','Deposit closed - deposit repaid in full',
                              'Deposit closed - unable to repay','Rejected')AND CreatedDate>=:startDate AND CreatedDate <=:endDate]){
                                  depositList.add(dep);
                              }
        system.debug('line-->74'+depositList);
        return depositList;    
        
    }  
    
   /* @AuraEnabled
    public static List<Deposit__c> fetchdeposit5(Date startDate, Date endDate){
        System.debug('startDate : ' + startDate + '	endDate : ' + endDate);
        Id accountid = [Select id, Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        System.debug('Account Id : ' + accountId);
        //return accountid;
        System.debug('startDate : ' + startDate + '	endDate : ' + endDate);
        
        
        
        List<Deposit__c> depositList = new List<Deposit__c>();       
        for(deposit__c dep : [select Id,Deposit_Account_Number__c,Property_Address__c,Member_s_Own_Deposit_Reference__c,Protection_Start_Date__c,End_Date__c,Deposit_Amount__c,Amount_paid_to_tenant__c,Case_Status__c,
                              Amount_paid_to_Landlord__c,Customer__r.name,Status__c,CreatedDate from Deposit__c where customer__c =:accountid AND Case_Status__c IN ('Deposit closed - deposit paid in part','Deposit closed - deposit repaid in full','Deposit closed - unable to repay','Rejected') AND CreatedDate>=:startDate AND CreatedDate <=:endDate]){
                                  depositList.add(dep);
                              } 
      
        system.debug('line-->95'+depositList);
          return depositList;    
       
    }*/    
    
   @AuraEnabled
    public static List<Installment__c>fetchdeposit5(Date startDate, Date endDate){
        System.debug('startDate : ' + startDate + '	endDate : ' + endDate);
        Id contactId = [Select id,ContactId, Contact.AccountId from User where id=:Userinfo.getUserId()].ContactId;
       // System.debug('Account Id : ' + accountId);
        //return accountid;
        System.debug('startDate : ' + startDate + '	endDate : ' + endDate);    
        
        List<Installment__c> installmentList = new List<Installment__c>(); 
        
        for(Installment__c dep : [select Id,Deposit__r.Deposit_Account_Number__c,Deposit__r.Property_Address__c,Deposit__r.Deposit_Amount__c,Deposit__r.Case_Status__c,Deposit__r.Amount_paid_to_AG_LL__c, Deposit__r.Amount_paid_to_TenantNew__c, 
                              Contact__r.name,CreatedDate,Installment_Type__c,Status__c
                                  from Installment__c where Contact__c=:contactId AND Deposit__r.Case_Status__c IN ('Deposit closed - deposit paid in part','Deposit closed - deposit repaid in full','Deposit closed - unable to repay')
                                  AND CreatedDate>=:startDate AND CreatedDate <=:endDate AND Installment_Type__c='Payable' AND Status__c='Paid']){
                                  installmentList.add(dep);
                              }      
        system.debug('line-->95'+installmentList);
          return installmentList;    
       
    } 

}