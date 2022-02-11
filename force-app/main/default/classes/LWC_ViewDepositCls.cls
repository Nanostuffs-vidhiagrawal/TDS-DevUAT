public with sharing class LWC_ViewDepositCls {
    public LWC_ViewDepositCls() {

    }

    @Auraenabled
    public static List<Deposit__c> getDepositsList() {

     //Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;

     List<Deposit__c> depositList = new List<Deposit__c>();
     depositList = [SELECT Id,Name,Start_Date_Text__c,Status__c,Deposit_Amount__c,Protected_Amount__c from Deposit__c limit 100]; //and Deposit_Transferred__c=false];
     
     return depositList;
    }
}