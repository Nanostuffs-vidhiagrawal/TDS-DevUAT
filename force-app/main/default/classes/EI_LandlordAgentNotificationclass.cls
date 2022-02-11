public without sharing class EI_LandlordAgentNotificationclass {
    
     @AuraEnabled
    public static List<Deposit__c> getLandLordStatus(){
      	 Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        system.debug('AccountId='+accountid);
        
        List<Deposit__c> finalList = new List<Deposit__c>();
        List<Deposit__c> depositTransferdList = new List<Deposit__c>();  
        List<Deposit__c> reviewTransferDepositList = new List<Deposit__c>();
        List<Deposit__c> returnFinalList = new List<Deposit__c>();
         List<DateTime> sortDateList = new List<DateTime>();  
        
        List<Case> caseList = new List<Case>();
        
        FinalList =  [Select Id,Name,LastModifiedDate,Status__c,Deposit_Account_Number__c,Case_Status__c,Property_Address__c ,createdDate,(Select id,Deposit_Account_Number__c,ChangeOver_Status__c, Status from Cases__r /*where Status in ('Decision issued - awaiting request for review','Review request accepted','Awaiting evidence review','Tenant changeover initiated - tenant','Repayment disputed - self-resolution','Evidence gathering AA/LL','Repayment requested - tenant')*/ order by createdDate desc Limit 1 ) from Deposit__c where Customer__c=:accountid and Case_Status__c IN ('Decision issued - awaiting request for review','Review request accepted','Awaiting evidence review','Tenant changeover initiated - tenant','Repayment disputed - self-resolution','Evidence gathering AA/LL','Repayment requested - tenant')];
             
        depositTransferdList = [SELECT Id,Name,Start_Date_Text__c,createdDate,LastModifiedDate,Status__c,Deposit_Amount__c,Deposit_Account_Number__c,Case_Status__c,Property_Address__c,(Select id,Deposit_Account_Number__c,ChangeOver_Status__c, Status from Cases__r /*where Status =: 'Deposit transfer requested' */ order by createdDate desc Limit 1 ) from Deposit__c where Deposit_Transferred_to_Account__c =:accountid and Deposit_Transferred__c=true and Case_Status__c= : 'Deposit transfer requested' ];
       
		//reviewTransferDepositList = [SELECT Id,Name,Start_Date_Text__c,createdDate,LastModifiedDate,Status__c,Deposit_Amount__c,Deposit_Account_Number__c,Case_Status__c,Property_Address__c,(Select id,Deposit_Account_Number__c,ChangeOver_Status__c, Status from Cases__r where Status =: 'Deposit transfer requested' order by createdDate desc Limit 1 ) from Deposit__c where Customer__c =:accountid and Deposit_Transferred__c=true];
       
         for(Deposit__c depo : FinalList){
            if(!depo.Cases__r.isEmpty()){
                returnFinalList.add(depo);
            }
        }
        
        if(!depositTransferdList.isEmpty()){
            returnFinalList.addAll(depositTransferdList);
        }
        
     /*   if(!reviewTransferDepositList.isEmpty()){
            returnFinalList.addAll(reviewTransferDepositList);
        }*/
        List<EI_AGLLNotificationComparable> depositListWrapper = new List<EI_AGLLNotificationComparable>();
        for(Deposit__c depoReturn : returnFinalList){
            EI_AGLLNotificationComparable obj = new EI_AGLLNotificationComparable(depoReturn);
            depositListWrapper.add(obj);
            system.debug('::CreatedDate='+depoReturn.CreatedDate);
        }
        depositListWrapper.sort();
        List<Deposit__c> depoList = new List<Deposit__c>();
        for(EI_AGLLNotificationComparable dObj :depositListWrapper){
         depoList.add(dObj.deposit);   
        }
        return depoList;
    }
    }