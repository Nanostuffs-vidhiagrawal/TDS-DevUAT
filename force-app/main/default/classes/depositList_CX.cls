public class depositList_CX {
    
    public list<Deposit__c> deptlist{get;set;}
    public Deposit__c deposit {get;set;}
    
    
    public depositList_CX(ApexPages.StandardController controller) {
    
    deposit =(Deposit__c) controller.getRecord();
    
  
    }
    
    public  static List<Deposit__c> method(){
    List<Deposit__c>  deptlist = [select Amount_of_Deposit_Protected_by_TDS__c,Date_Deposit_Received__c,Property_Address__c,Tenants_Name__c,Deposit_Account_Number__c,Amount_of_Deposit_in_Tenancy_Agreement__c from Deposit__c];
  return deptlist;
    
    }

}