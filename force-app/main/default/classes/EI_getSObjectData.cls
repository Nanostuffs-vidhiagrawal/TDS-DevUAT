public without sharing class EI_getSObjectData {
    
    public static Map<Id,Case_Participant__c> getCasePart(Set<Id> setOfCaseIds){
        return new Map<Id,Case_Participant__c>([SELECT Id,Contact__r.Name,Is_Lead__c,Case__r.Deposit_Account_Number__r.Property_Address_WO_Country__c,Case__r.Total_Agreed_by_AG_LL__c,Case__r.Total_Agreed_by_Tenant__c, Type__c,Case__r.Disputed_Amount__c, Case__r.Status ,Case__r.Deposit_Account_Number__c,Case__r.Deposit_Account_Number__r.Name,  Contact__r.Email,Contact__r.FirstName,Contact__r.LastName,Case__r.Tenancy_Property_Address__c,  Account__c, Contact__c,Payable_Amount__c FROM Case_Participant__c where Case__c In : setOfCaseIds]);
    }
}