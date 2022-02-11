/**
 * @who   Tiago Lopes <tiago.lopes@weare4c.com>
 * @what  Handler model class for Case_Participant__c and related logic
 * @when  13/1/2020
 */

public without sharing class FC_CaseParticipantHandler {

    private Case_Participant__c participant;

    public FC_CaseParticipantHandler(Case_Participant__c participant){
        this.participant = participant;
    }

    /**
     * Processes logic checks for this Case Participant when Case Status is Evidence Gathering TT
     */
    public void processChecksForEvidenceGatheringTTCaseStatus(){
        if(isLandlord()){
            participant.Send_Dispute_Acknowledgement__c = true;
        }
        else if(isTenant()){
            participant.Send_Evidence_Invitation_TT__c = true;
        }

    }

    /**
     * Processes logic checks for this Case Participant when Case Status is Review Complete
     */
    public void processChecksForReviewCompleteCaseStatus(){
        participant.Send_Sent_to_Adjudicator__c = true;
    }

    /**** filters ****/

    private Boolean isLandlord(){
        return this.participant.Type__c == FC_Constant.Allocation_And_Participant_Role_Landlord;
    }

    private Boolean isTenant(){
        return this.participant.Type__c == FC_Constant.Allocation_And_Participant_Role_Tenant;
    }

    private Boolean isAgent(){
        return this.participant.Type__c == FC_Constant.Allocation_And_Participant_Role_Agent;
    }



    /******** static handlers used from TriggerHandlers ********/

    /**
     *  Updates Case Participant related Case Tenant lookup with CaseParticipant.Contact__c for participants marked
     *  as lead tenants 
     *
     * @param participants
     */
    public static void updateParentCaseLeadTenantLookup(List<Case_Participant__c> participants) {
        FC_ErrorLogger.start('FC_CaseParticipantCommChecksProcessorInv', 'updateParentCaseLeadTenantLookup');
        Set<Id> parentCaseIds = new Set<Id>();
        List<Case> casesToUpdate = new List<Case>();

        for (Case_Participant__c part : participants) {
            parentCaseIds.add(part.Case__c);
        }

        Map<Id, Case> parentCaseMap = new Map<Id, Case>([SELECT Id FROM Case WHERE Id IN :parentCaseIds]);

        for (Case_Participant__c part : participants) {
            FC_CaseHandler myCase = new FC_CaseHandler(parentCaseMap.get(part.Case__c));
            myCase.setLeadTenant(part.Contact__c);
            casesToUpdate.add(myCase.getCase());
        }

        if (!casesToUpdate.isEmpty()) {
            List<Database.Saveresult> results = Database.update(casesToUpdate, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    FC_ErrorLogger.error(results[i].getErrors(), casesToUpdate[i].Id);
                }
            }
        }
        FC_ErrorLogger.stop();
    }
    
    /**                 
    * Entry point from Case Handler that fetches all child Case Participant for given Cases and uses model class to
    * mark checkboxes depending on Case status value
    *
    * @param newCases
    */
    public static void processCaseParticipantChecks(List<Case> newCases) {
        FC_ErrorLogger.start('FC_CaseParticipantCommChecksProcessorInv', 'processCaseParticipantChecks');
        List<Case_Participant__c> reviewCompleteCaseParticipants = new List<Case_Participant__c>();
        List<Case_Participant__c> evidenceGatheringTTCaseParticipants = new List<Case_Participant__c>();
        List<Case_Participant__c> participantsToUpdate = new List<Case_Participant__c>();
        List<Case_Participant__c> childParticipants = [
                SELECT Case__c, Type__c, Send_Dispute_Acknowledgement__c, Send_Evidence_Invitation_TT__c, Send_Sent_to_Adjudicator__c
                FROM Case_Participant__c
                WHERE Case__c
                        IN :newCases
        ];

        for (Case c : newCases) {
            for (Case_Participant__c part : childParticipants) {
                if (part.Case__c == c.Id) {
                    if (c.Status == FC_Constant.Case_Status_Review_Complete) reviewCompleteCaseParticipants.add(part);
                    else if (c.Status == FC_Constant.Case_Status_Evidence_Gathering_TT) evidenceGatheringTTCaseParticipants.add(part);
                }
            }
        }
        // actually process logic
        if (!reviewCompleteCaseParticipants.isEmpty()) {
            for (Case_Participant__c cp : reviewCompleteCaseParticipants) {
                if (cp != null) {
                    FC_CaseParticipantHandler handler = new FC_CaseParticipantHandler(cp);
                    handler.processChecksForReviewCompleteCaseStatus();
                    participantsToUpdate.add(cp);
                }
            }
        }
        if (!evidenceGatheringTTCaseParticipants.isEmpty()) {
            for (Case_Participant__c cp : evidenceGatheringTTCaseParticipants) {
                if (cp != null) {
                    FC_CaseParticipantHandler handler = new FC_CaseParticipantHandler(cp);
                    handler.processChecksForEvidenceGatheringTTCaseStatus();
                    participantsToUpdate.add(cp);
                }
            }
        }
        if (!participantsToUpdate.isEmpty()) {
            try {
                List<Database.SaveResult> updateResults = Database.update(participantsToUpdate, true);
                for (Integer i = 0; i < updateResults.size(); i++) {
                    if (!updateResults[i].isSuccess()) {
                        FC_ErrorLogger.error(updateResults[i].getErrors(), participantsToUpdate[i].Id);
                    }
                }
            } catch (DmlException dme) {
                FC_ErrorLogger.error(dme);
                System.debug('### Failed to update Cases on FC_CaseParticipantCommChecksProcessorInv.processCaseParticipantChecks():' + dme.getMessage());
            }
        }
        FC_ErrorLogger.stop();
    }

}