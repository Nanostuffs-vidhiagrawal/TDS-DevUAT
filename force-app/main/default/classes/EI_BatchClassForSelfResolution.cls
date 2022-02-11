public class EI_BatchClassForSelfResolution implements Database.Batchable<sObject> {
    
    public DataBase.QueryLocator start(DataBase.BatchableContext BC){
        
        Date currentDate = system.today().addDays(-10);
        String query = 'SELECT Id, No_Tenant_Evidence__c, No_Landlord_Evidence__c, Status, Respond_Date__c, AGLL_Respond_Evidance_Gathering__c, TT_respond_evidence_gathering__c FROM Case where Respond_Date__c != null AND Respond_Date__c>=:currentDate';
        return DataBase.getQueryLocator(query);
    }
    
    public void execute(DataBase.BatchableContext BC,List<Case> caseList){
        
        List<Case> updateCaseList = new List<Case>();
        
        if(!caseList.isEmpty()){
            
            for(Case eachCase : caseList){
                if(system.today() > eachCase.Respond_Date__c){
                    eachCase.Status = 'Self-resolution - awaiting review';
                    updateCaseList.add(eachCase);
                }
            } 
            
        }
        
        if(!updateCaseList.isEmpty()){
            DataBase.update(updateCaseList, false);
        }
    }
    
    public void finish(DataBase.BatchableContext BC){
        
        
    }
}