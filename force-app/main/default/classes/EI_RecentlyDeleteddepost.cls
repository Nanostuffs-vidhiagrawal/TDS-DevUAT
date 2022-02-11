public class EI_RecentlyDeleteddepost {

 	@Auraenabled
	public static List<Deposit__c> getDeposits() {
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit__c> depositList = new List<Deposit__c>();
		depositList = [SELECT Id,Name,Property_Address__c,Start_Date__c,Deposit_Amount__c
						 from Deposit__c where Customer__c =:accountid and Status__c='Deposit registration deleted'];
        return depositList;
    }   

    
}