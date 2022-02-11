public without sharing class EI_ZD_AGLLRespondToTenantClaim {
	/*@AuraEnabled
    public static list<case> getClaimDetails(String claimId)
    { 
        list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,
                                Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c, 
                                Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,
                                Deposit_Account_Number__r.End_Date__c,Status,
								(select id,Name,Type__c,Contact_Email__c,Is_Lead__c, Contact__r.Phone from Case_Participants__r),
                                (select id,Name,Type__c,Agreed_by_Tenant__c,Claimed_by_Landlord__c,Landlord_Statement__c,Other_Reason__c,Tenant_Statement__c from Dispute_Items__r) 
                                from case where id=:claimId];
        return caseparti;
    }*/
}