public class depositProtectionCertificate_CX {

    public String currentRecordId  {get;set;}
    public Deposit__c  deptObj{get;set;}
    public String userid{get;set;}
     public Id accountid {get;set;}

    public depositProtectionCertificate_CX(ApexPages.StandardController controller) {
      //Id accountid = Userinfo.getUserId();
     
     string accountid = [Select id,Contact.AccountId, AccountId from User where id=:Userinfo.getUserId() LIMIT 1][0].AccountId;
          system.debug('::Userid='+accountid );
    
     deptObj= [ select id,Amount_of_Deposit_Protected_by_TDS__c,Customer__c ,Date_Deposit_Received__c,Property__r.House_No__c,Property__r.City__c,Property__r.Country__c,Tenants_Name__c,Customer__r.Name,customer__r.id,Deposit_Account_Number__c,Amount_of_Deposit_in_Tenancy_Agreement__c from Deposit__c where Customer__c =: accountid LIMIT  1];
    
     

    }

}