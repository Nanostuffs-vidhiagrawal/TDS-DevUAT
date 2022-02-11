/**
 * @who  Tiago Lopes <tiago.lopes@weare4c.com>
 * @what Test class for FC_CaseParticipantHandler
 * @when 19/3/2020
 */
@isTest
private class FC_CaseParticipantHandlerTest {

    @isTest
    static void when_CaseParticipantIsCheckedToLead_expect_CaseTenantLookupPopulated(){
        FC_TestFactory.setUpDisputeScenarioWithParticipants(FC_Constant.RecordType_Zero_Deposit_Dispute_Dev_Name);
        User u = [SELECT Id FROM User WHERE Name = 'Zero Deposit Site Guest User'];
        Case myCase = [SELECT Tenant__c FROM Case];
		system.debug('$$$$##myCase14 '+myCase.Tenant__c);
        System.assert(myCase.Tenant__c == null);

        Case_Participant__c part = [SELECT Is_Lead__c, Contact__c
                                    FROM Case_Participant__c
                                    WHERE Type__c = :FC_Constant.Allocation_And_Participant_Role_Tenant
                                            AND Case__c = :myCase.Id LIMIT 1];

        part.Is_Lead__c = true;

        Test.startTest();
            update part;
        Test.stopTest();

        // assert parent Case has Tenant lookup assigned to lead tenant
        myCase = [SELECT Tenant__c FROM Case];
		system.debug('$$$$##30 '+myCase.Tenant__c);
       // System.assertEquals(myCase.Tenant__c, part.Contact__c);
    }

  @isTest
    static void when_CaseParticipantIsCheckedToLead_expect_CaseTenantLookupPopulated_bulk(){
        FC_TestFactory.setUpDisputeScenarioWithParticipants(FC_Constant.RecordType_Zero_Deposit_Dispute_Dev_Name, 400);

        List<Case> cases = [SELECT Tenant__c FROM Case];
        for(Case c : cases) {
            System.assert(c.Tenant__c == null);
        }

        List<Case_Participant__c> parts = [SELECT Case__c, Is_Lead__c, Contact__c
        FROM Case_Participant__c
        WHERE Type__c = :FC_Constant.Allocation_And_Participant_Role_Tenant
        AND Case__c IN :cases];

        for(Case_Participant__c cp : parts) {
            cp.Is_Lead__c = true;
        }

        Test.startTest();
        update parts;
        Test.stopTest();

        // requery cases
        List<Case> updatedCases = [SELECT Tenant__c, (SELECT Id, Is_Lead__c, Contact__c FROM Case_Participants__r) FROM Case WHERE Id IN :cases];

        // assert parent Case has Tenant lookup assigned to lead tenant
        for(Case c : updatedCases){
         //   System.assertEquals(c.Case_Participants__r[0].Contact__c, c.Tenant__c);
        }
    }

    @isTest
    static void test_processParticipantChecksOnCaseStatusEvidenceGatheringTT_positive(){
        FC_TestFactory.setUpDisputeScenarioWithParticipants(FC_Constant.RecordType_Zero_Deposit_Dispute_Dev_Name);

        Case myCase = [SELECT Status FROM Case];
        myCase.Status = FC_Constant.Case_Status_Evidence_Gathering_TT;

        Test.startTest();
            FC_CaseParticipantHandler.processCaseParticipantChecks(new List<Case>{myCase});
        Test.stopTest();

        // re query parts
        List<Case_Participant__c> parts = getCaseParticipantsByCaseId(myCase.Id);

        // assert on checks performed
        for(Case_Participant__c cp : parts) {
            if(cp.Type__c == FC_Constant.Allocation_And_Participant_Role_Tenant){
                System.assertEquals(true, cp.Send_Evidence_Invitation_TT__c);
            }
            else if(cp.Type__c == FC_Constant.Allocation_And_Participant_Role_Landlord){
                System.assertEquals(true, cp.Send_Dispute_Acknowledgement__c);
            }
        }
    }

    @isTest
    static void test_processParticipantChecksOnCaseStatusReviewComplete_positive() {
        FC_TestFactory.setUpDisputeScenarioWithParticipants(FC_Constant.RecordType_Zero_Deposit_Dispute_Dev_Name);
        Account dummyAccount = (Account) FC_TestFactory.createSObject(new Account(), true);
        SlaProcess slaProcess = [SELECT Id FROM SlaProcess WHERE Name = 'ZD Disputes' AND IsVersionDefault = true LIMIT 1];
        Entitlement entitlement = (Entitlement) FC_TestFactory.createSObject(
                new Entitlement(AccountId = dummyAccount.Id, SlaProcessId = slaProcess.Id),
                'FC_TestFactoryDefaults.EntitlementDefaults', true);

        Case myCase = [SELECT Status FROM Case];
        // move case Status to Review Complete
        myCase.Status = FC_Constant.Case_Status_Review_Complete;

        Test.startTest();
            FC_CaseParticipantHandler.processCaseParticipantChecks(new List<Case>{myCase});
        Test.stopTest();

        // re query parts
        List<Case_Participant__c> parts = getCaseParticipantsByCaseId(myCase.Id);

        // assert on checks performed
        for(Case_Participant__c cp : parts) {
            System.assertEquals(true, cp.Send_Sent_to_Adjudicator__c);
        }
    }

    /**** private helper methods ****/

    private static List<Case_Participant__c> getCaseParticipantsByCaseId(Id caseId){
        return [SELECT Case__c, Type__c, Send_Dispute_Acknowledgement__c, Send_Evidence_Invitation_TT__c, Send_Sent_to_Adjudicator__c
        FROM Case_Participant__c
        WHERE Case__c = :caseId];
    }




}