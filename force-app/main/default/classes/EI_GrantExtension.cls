public class EI_GrantExtension {

    @AuraEnabled
    public static case updateExtenionForParties(String recordId, String partyGivenExt, Integer daysExtended)
    {
        case casedetails = [select Id from case where Id=:recordId];
        casedetails.Party_given_extension__c = partyGivenExt;
        casedetails.Extended_days_for_evidence__c = daysExtended;
        return casedetails;
    }
    
}