/**
 * @who  Tiago Lopes <tiago.lopes@weare4c.com>
 * @what Class that holds invocable method to handle Case Participant checks for outbound communication based on
 *       parent Case Status updated values captured from platform event via Process Builder
 * @when 9/3/20
 */

public with sharing class FC_CaseParticipantCommChecksProcessorInv {
    /**
     * Event structure to be mapped through process builder
     */
    public class EventStructure {
        @InvocableVariable public Case eventCase;
    }

    @InvocableMethod(label='Set child Case Participant checkboxes based on given Case status value.')
    public static void processCaseParticipantChecks(List<EventStructure> eventsList){

        List<Case> caseList = new List<Case>();
        for(EventStructure event : eventsList) {
            caseList.add(event.eventCase);
        }
        FC_CaseParticipantHandler.processCaseParticipantChecks(caseList);
    }

}