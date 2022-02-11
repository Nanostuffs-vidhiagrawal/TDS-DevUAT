public class EI_SDS_MileStone {
    @AuraEnabled
    public static case getCaseDetails(string recordId)
    {
        
        case casedetails = [select id,status,Days_Remaining__c from case where Id=:recordId];
        return casedetails;
    
}	
}