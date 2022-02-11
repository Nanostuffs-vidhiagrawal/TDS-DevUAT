/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Handler class model for Agent Work
 *
 * @when 14/11/2019
 */
public with sharing class FC_AgentWorkHandler {
    // bulk handler sub class to handle filtering and dispatch
    public class BulkAgentWorkHandler {
        /**
         * Handles bulk Agent Works coming from OnAfterUpdate trigger event
         * Change Case team if the work is accepted by the user through omnichannel
         * @param newList
         * @param oldMap
         */
        public void handleAgentWorkAssignment(List<AgentWork> newList, Map<Id,AgentWork> oldMap) {
            List<Id> casesIdsToUpdate = new List<Id>();
            // filter
            for(AgentWork agentWork : newList) {
                if(isAgentWorkItemCaseAndIsAssignedToUser(agentWork, oldMap.get(agentWork.Id))) {
                    casesIdsToUpdate.add(agentWork.WorkItemId);
                }
            }
            if(!casesIdsToUpdate.isEmpty()) {
                List<Case> disputesToUpdate = [SELECT Id, Status, OwnerId FROM Case WHERE Id IN :casesIdsToUpdate];
                FC_CaseTeamHandler.setCaseTeamForCase(disputesToUpdate);
                setAdjudicationStatusForReviewCompleteCases(disputesToUpdate);
            }
        }

        private Boolean isAgentWorkItemCaseAndIsAssignedToUser(AgentWork newAgentWork, AgentWork oldAgentWork){
            return  oldAgentWork.Status != newAgentWork.Status 
                    && newAgentWork.Status == FC_Constant.Agent_Work_Status_Opened
                    && oldAgentWork.Status == FC_Constant.Agent_Work_Status_Assigned
                    && newAgentWork.WorkItemId.getSobjectType() == Case.SObjectType;
        }
    }
    
    private static void setAdjudicationStatusForReviewCompleteCases(List<Case> disputesToCheck) {
        List<Case> disputesToUpdate = new List<Case>(); 
        
        for(Case dispute : disputesToCheck) {
            if(dispute.Status == FC_Constant.Case_Status_Review_Complete) {
                dispute.Status = FC_Constant.Case_Status_Adjudication;
            }
            disputesToUpdate.add(dispute);
        }
        update disputesToUpdate;
    }
}