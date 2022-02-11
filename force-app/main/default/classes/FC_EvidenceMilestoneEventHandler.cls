/**
 * @who   Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what  Handler class for Evidence Gathering Status Change Events
 * @when  14/01/2020
 */
public with sharing class FC_EvidenceMilestoneEventHandler {

    /**
     * Event structure to be mapped through process builder
     */
    public class EventStructure {
        @InvocableVariable public String recordId;
    }
    /**
     * Handle Case Evidence Gathering Status Update platform events
     *
     * @param webhookEventObjects
     */
    @InvocableMethod(label='Set Case.Evidence_Target_Date to Milestone.TargetDate')
    public static void handleWebhookEvents(List<EventStructure> eventsList) {
        FC_ErrorLogger.start();

        Set<Id> caseIds = new Set<Id>();
        for(EventStructure event : eventsList) {
            caseIds.add(event.recordId);
        }
        Set<String> milestoneTypeNames = new Set<String>{
                FC_Constant.CaseMilestone_Type_Evidence_Gathering_TT,
                FC_Constant.CaseMilestone_Type_Evidence_Gathering_LL
        };
        Map<Id,Case> caseWithMilestonesMap = new Map<Id,Case>([
                SELECT Id, Status,  (
                                SELECT TargetDate
                                FROM CaseMilestones
                                WHERE MilestoneType.Name IN:milestoneTypeNames
                                ORDER BY CreatedDate DESC
                            )
                FROM Case
                WHERE Id IN :caseIds
        ]);

        Map<Id,Case> casesToUpdate = new Map<Id, Case>();
        for(EventStructure event : eventsList) {
            try {
                String recordId = event.recordId;
                List<CaseMilestone> milestones  = caseWithMilestonesMap.containsKey(recordId)
                                                ? caseWithMilestonesMap.get(recordId).CaseMilestones
                                                : new List<CaseMilestone>();
                if(milestones.size() > 0) {
                    CaseMilestone milestone = milestones[0];
                    Case cs = new Case(
                            Id = recordId,
                            Evidence_Target_Date__c = milestone.TargetDate,
                            Status =  caseWithMilestonesMap.get(recordId).Status
                    );
                    casesToUpdate.put(recordId,cs);
                }
            }
            catch(Exception exc) {
                FC_ErrorLogger.error(exc);
            }
        }

        if (casesToUpdate.size() > 0) {
            try {
                update casesToUpdate.values();
            }catch(Exception exc) {
                FC_ErrorLogger.error(exc);
            }
        }
        /* call processCaseParticipantChecks() after setting Evidence Target Date, in order to
           be able to merge it in the email comms being triggered by those checks */
        FC_CaseParticipantHandler.processCaseParticipantChecks(caseWithMilestonesMap.values());
        FC_ErrorLogger.stop();
    }
}