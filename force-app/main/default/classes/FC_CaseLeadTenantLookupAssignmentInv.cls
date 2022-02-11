/**
 * @who   Tiago Lopes <tiago.lopes@weare4c.com>
 * @what  Invocable util to process a Case_Participant Case tenant lookup assignment from Case Participant Process builder on isLead check
 * @when  19/3/2020
 */
public with sharing class FC_CaseLeadTenantLookupAssignmentInv {

    @InvocableMethod(label='Set parent Case Tenant lookup to Case Participant related Contact lookup.')
    public static void AssignLeadTenantToCase(List<Case_Participant__c> participants){
        system.debug('participants # ' + participants);
        FC_CaseParticipantHandler.updateParentCaseLeadTenantLookup(participants);
    }
}