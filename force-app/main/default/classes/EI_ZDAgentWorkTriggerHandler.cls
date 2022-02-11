public class EI_ZDAgentWorkTriggerHandler {
    
    public static void beforeUpdate(Map<Id, AgentWork> newItems, Map<Id, AgentWork> oldItems) {
        Savepoint sp = Database.setSavepoint();
        List<Id> casesIdsToUpdate = new List<Id>();
        map<string,integer> casesRecordmap = new map<string,integer>();
        list<case> CaseRec = new list<case>();
        List<Id> AgentID = new List<Id>();
        String adjUserId = '';
        List<Case> disputesToUpdate = new List<Case>();
        for(AgentWork agentWork : newItems.values()) {
            casesIdsToUpdate.add(agentWork.WorkItemId);
            adjUserId = agentWork.UserId;
        }
        
        if(casesIdsToUpdate != null)
        {
            CaseRec = [SELECT Id, Status,(select id,Account__c from Case_Participants__r), OwnerId FROM Case WHERE Id IN :casesIdsToUpdate ];
        }

        for(case agentWork : CaseRec) {
                if(agentWork.Status == 'Evidence review complete') {
                    disputesToUpdate.add(new case(Status = 'Adjudication', id = agentWork.id, Adjudicator__c = adjUserId));
                }
        }
        if(disputesToUpdate.size() > 0)
        {
            update disputesToUpdate;
        }

    }
    
}