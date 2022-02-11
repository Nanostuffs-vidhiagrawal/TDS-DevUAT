/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Tests for Case Trigger handled in FC_CaseTriggerHandler
 * 1. Assignment to Adjudicator
 * 2. Rollup disputes snapshot
 * 3. Case Entitlement Assignment
 * 4. Change Status to Adjudication when owner is changed to User in Review Complete Status
 * 5. On Owner change, Deletes existing team member if role matches the current status and assigns new team member instead
 * 6. Set Status Entry Date for each Status change
 * 7. Verify that case IDs dispatched for massMailer get processed
 * 8. Verify that for ZD cases, when Status changed to Evidence Gathering TT, CaseParticipant logic will run for child records
 * 9. Verify that for ZD cases, when Status changed to Review Complete, CaseParticipant logic will run for child records
 * 10. Verify events being sent through bus
 * 11. Verify that Case Milestone Target date is copied to case on status change
 * @when 30/10/2019
 */
@IsTest
private class FC_CaseTriggerHandlerTest {
    /**
     * 1. Assignment to Adjudicator
     */
    @IsTest
    static void assignmentToAdjudicator_afterInsert() {
        Test.startTest();
        List<Case> newDisputesReviewComplete = FC_TestFactory.createSObjectList(
                new Case(Status = FC_Constant.Case_Status_Review_Complete),
                200, 'FC_TestFactoryDefaults.CaseDefaults', true);
        Test.stopTest();
        System.assertEquals(200, [SELECT count() FROM Case 
            WHERE OwnerId IN (SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName = 'Ready_for_Adjudication')]);
    }

    @IsTest
    static void assignmentToAdjudicator_afterUpdate() {
        List<Case> newDisputes = FC_TestFactory.createSObjectList(
                new Case(),
                200, 'FC_TestFactoryDefaults.CaseDefaults', true);
        
        FC_CaseHandler.processedCaseIds = new Set<Id>();
        
        System.assertEquals(0, [SELECT count() FROM Case
            WHERE OwnerId IN (SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName = 'Ready_for_Adjudication')]);

        Test.startTest();
        for(Case dispute : newDisputes) {
            dispute.Status = FC_Constant.Case_Status_Review_Complete;
        }
        update newDisputes;
        Test.stopTest();
        
        System.assertEquals(200, [SELECT count() FROM Case
            WHERE OwnerId IN (SELECT Id FROM Group WHERE Type='Queue' AND DeveloperName = 'Ready_for_Adjudication')]);
    }
    /**
     * 2. Rollup disputes snapshot
     */
    @IsTest
    static void rollupDisputesSnapshots_afterInsert() {
        Account account1 = (Account) FC_TestFactory.createSObject(new Account(), true);
        Account account2 = (Account) FC_TestFactory.createSObject(new Account(), true);
        
        List<Case> newDisputesAccount1 = FC_TestFactory.createSObjectList(
                new Case(AccountId = account1.Id, Disputed_Amount__c = 100),
                2, 'FC_TestFactoryDefaults.CaseDefaults', true);
        
        List<Case> newDisputesAccount2 = FC_TestFactory.createSObjectList(
                new Case(AccountId = account2.Id, Disputed_Amount__c = 100),
                2, 'FC_TestFactoryDefaults.CaseDefaults', true);

        System.assertEquals(200, [SELECT Disputes_Snapshot__c FROM Account WHERE Id = :account1.Id][0].Disputes_Snapshot__c);
        System.assertEquals(200, [SELECT Disputes_Snapshot__c FROM Account WHERE Id = :account2.Id][0].Disputes_Snapshot__c);
    }    
    
    @IsTest
    static void rollupDisputesSnapshots_afterUpdate() {
        Account account1 = (Account) FC_TestFactory.createSObject(new Account(), true);
        Account account2 = (Account) FC_TestFactory.createSObject(new Account(), true);
        
        List<Case> newDisputesAccount1 = FC_TestFactory.createSObjectList(
                new Case(AccountId = account1.Id, Disputed_Amount__c = 100),
                2, 'FC_TestFactoryDefaults.CaseDefaults', true);
        
        List<Case> newDisputesAccount2 = FC_TestFactory.createSObjectList(
                new Case(AccountId = account2.Id, Disputed_Amount__c = 100),
                2, 'FC_TestFactoryDefaults.CaseDefaults', true);
        
        //nullify Disputed Amount
        newDisputesAccount1[0].Disputed_Amount__c = null;
        update newDisputesAccount1[0];
        System.assertEquals(100, [SELECT Disputes_Snapshot__c FROM Account WHERE Id = :account1.Id][0].Disputes_Snapshot__c);

        //change multiple Disputed Amounts for different Accounts simultanously
        newDisputesAccount1[0].Disputed_Amount__c = 300;
        newDisputesAccount2[0].Disputed_Amount__c = 200;
        update new List<Case>{newDisputesAccount1[0],newDisputesAccount2[0]};
        System.assertEquals(400, [SELECT Disputes_Snapshot__c FROM Account WHERE Id = :account1.Id][0].Disputes_Snapshot__c);
        System.assertEquals(300, [SELECT Disputes_Snapshot__c FROM Account WHERE Id = :account2.Id][0].Disputes_Snapshot__c);
        
        //close Case 
        newDisputesAccount1[1].Status = FC_Constant.Case_Status_Closed;
        newDisputesAccount1[1].Close_Reason__c = FC_Constant.Case_Close_Reason_Adjudication_Decision_Reached;
        update newDisputesAccount1[1];
        System.assertEquals(300, [SELECT Disputes_Snapshot__c FROM Account WHERE Id = :account1.Id][0].Disputes_Snapshot__c);         
    }

    @IsTest
    static void rollupDisputesSnapshots_afterDelete() {
        Account account1 = (Account) FC_TestFactory.createSObject(new Account(), true);
        Account account2 = (Account) FC_TestFactory.createSObject(new Account(), true);

        List<Case> newDisputesAccount1 = FC_TestFactory.createSObjectList(
                new Case(AccountId = account1.Id, Disputed_Amount__c = 100),
                2, 'FC_TestFactoryDefaults.CaseDefaults', true);

        List<Case> newDisputesAccount2 = FC_TestFactory.createSObjectList(
                new Case(AccountId = account2.Id, Disputed_Amount__c = 100),
                2, 'FC_TestFactoryDefaults.CaseDefaults', true);
        
        delete newDisputesAccount1[0];
        System.assertEquals(100, [SELECT Disputes_Snapshot__c FROM Account WHERE Id = :account1.Id][0].Disputes_Snapshot__c);
    }

    @IsTest
    static void rollupDisputesSnapshots_afterUndelete() {
        Account account1 = (Account) FC_TestFactory.createSObject(new Account(), true);
        Account account2 = (Account) FC_TestFactory.createSObject(new Account(), true);

        List<Case> newDisputesAccount1 = FC_TestFactory.createSObjectList(
                new Case(AccountId = account1.Id, Disputed_Amount__c = 100),
                2, 'FC_TestFactoryDefaults.CaseDefaults', true);

        List<Case> newDisputesAccount2 = FC_TestFactory.createSObjectList(
                new Case(AccountId = account2.Id, Disputed_Amount__c = 100),
                2, 'FC_TestFactoryDefaults.CaseDefaults', true);

        delete newDisputesAccount1[0];
        System.assertEquals(100, [SELECT Disputes_Snapshot__c FROM Account WHERE Id = :account1.Id][0].Disputes_Snapshot__c);    
        
        undelete newDisputesAccount1[0];
        System.assertEquals(200, [SELECT Disputes_Snapshot__c FROM Account WHERE Id = :account1.Id][0].Disputes_Snapshot__c);
    }
    /**
     * 3. Case Entitlement Assignment
     */
    @IsTest
    static void caseEntitlementAssignment_beforeInsert() {
        Account dummyAccount = (Account) FC_TestFactory.createSObject(new Account(), true);
        Entitlement entitlement = (Entitlement) FC_TestFactory.createSObject(
                new Entitlement(AccountId = dummyAccount.Id),
                'FC_TestFactoryDefaults.EntitlementDefaults', true);
        
        List<Case> newCases = FC_TestFactory.createSObjectList(
                new Case(), 200, 'FC_TestFactoryDefaults.CaseDefaults', true);

        System.assertEquals(200, [SELECT count() FROM Case WHERE Entitlement.Name = :FC_Constant.Entitlement_Dispute_EW_Insured_TEST_ENTITLEMENT_NAME]);
    }

    @IsTest
    static void caseEntitlementAssignment_beforeUpdate() {
        Account dummyAccount = (Account) FC_TestFactory.createSObject(new Account(), true);
        Entitlement entitlement = (Entitlement) FC_TestFactory.createSObject(
                new Entitlement(AccountId = dummyAccount.Id),
                'FC_TestFactoryDefaults.EntitlementDefaults', true);

        List<Case> newCases = FC_TestFactory.createSObjectList(
                new Case(RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType,'Support_Case')), 200, 'FC_TestFactoryDefaults.CaseDefaults', true);

        System.assertEquals(0, [SELECT count() FROM Case WHERE Entitlement.Name = :FC_Constant.Entitlement_Dispute_EW_Insured_TEST_ENTITLEMENT_NAME]);

        Test.startTest();
        for(Case newCase : newCases) {
            newCase.RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType,'Dispute_EW_Insured');
        }
        update newCases;
        Test.stopTest();
        System.assertEquals(200, [SELECT count() FROM Case WHERE Entitlement.Name = :FC_Constant.Entitlement_Dispute_EW_Insured_TEST_ENTITLEMENT_NAME]);
    }    
    /**
     * 4. Change Status to Adjudication when owner is changed to User in Review Complete Status
     */
    @IsTest
    static void changeStatusForReviewCompleteUserOwner_beforeUpdate() {
        Group readyForAdjudicationQueue = [SELECT Id FROM Group WHERE Type = 'Queue' And DeveloperName = 'Ready_for_Adjudication' LIMIT 1];

        List<Case> newCases = FC_TestFactory.createSObjectList(
                new Case(Status = FC_Constant.Case_Status_Review_Complete, OwnerId = readyForAdjudicationQueue.Id), 200, 'FC_TestFactoryDefaults.CaseDefaults', true);

        System.assertEquals(200, [SELECT count() FROM Case WHERE Status = :FC_Constant.Case_Status_Review_Complete]);

        Test.startTest();
        for(Case newCase : newCases) {
            newCase.OwnerId = UserInfo.getUserId();
        }
        update newCases;
        Test.stopTest();
        System.assertEquals(200, [SELECT count() FROM Case WHERE Status = :FC_Constant.Case_Status_Adjudication]);
    }   
    /**
     * 5. On Owner change, Deletes existing team member if role matches the current status and assigns new team member instead
     */
    @IsTest
    static void onOwnerChangeAdjustTeamMembers_beforeInsert() {
        //test bulk
        List<Case> newCases = FC_TestFactory.createSObjectList(
                new Case(OwnerId = UserInfo.getUserId()), 200, 'FC_TestFactoryDefaults.CaseDefaults', true);
        System.assertEquals(200, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId IN :newCases]);

        //test all possible statuses
        Case caseNew = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_New), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseOnHold = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_On_Hold, On_Hold_Reason__c = 'Clarification needed'),
                'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseEvLL = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Evidence_Gathering_LL), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseEvTT = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Evidence_Gathering_TT), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseAwaitingRev = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Awaiting_Review), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseRevComplete = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Review_Complete), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseAdjudication = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Adjudication), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseClosed = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Closed, Close_Reason__c = 'Court Order'), 
                'FC_TestFactoryDefaults.CaseDefaults', true);

        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseNew.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseOnHold.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseEvLL.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseEvTT.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseAwaitingRev.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseRevComplete.Id AND TeamRole.Name = 'Adjudicator']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseAdjudication.Id AND TeamRole.Name = 'Adjudicator']);
        System.assertEquals(0, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseClosed.Id]);
    }

    @IsTest
    static void onOwnerChangeAdjustTeamMembers_beforeUpdate() {
        //test bulk
        List<Case> newCases = FC_TestFactory.createSObjectList(
                new Case(OwnerId = UserInfo.getUserId()), 200, 'FC_TestFactoryDefaults.CaseDefaults', true);
        System.assertEquals(200, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId IN :newCases]);
        
        //test all possible statuses
        Case caseNew = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_New), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseOnHold = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_On_Hold, On_Hold_Reason__c = 'Clarification needed'),
                'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseEvLL = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Evidence_Gathering_LL), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseEvTT = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Evidence_Gathering_TT), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseAwaitingRev = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Awaiting_Review), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseRevComplete = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Review_Complete), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseAdjudication = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Adjudication), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case caseClosed = (Case)FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_Closed, Close_Reason__c = 'Court Order'),
                'FC_TestFactoryDefaults.CaseDefaults', true);

        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseNew.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseOnHold.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseEvLL.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseEvTT.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseAwaitingRev.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseRevComplete.Id AND TeamRole.Name = 'Adjudicator']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseAdjudication.Id AND TeamRole.Name = 'Adjudicator']);
        System.assertEquals(0, [SELECT count() FROM CaseTeamMember WHERE MemberId = :UserInfo.getUserId() AND ParentId = :caseClosed.Id]);
        
        User testUser = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'System Administrator' AND Id != :UserInfo.getUserId() LIMIT 1];
        
        Test.startTest();
        for(Case newCase : newCases) {
            newCase.OwnerId = testUser.Id;
        }
        caseNew.OwnerId = testUser.Id;
        caseOnHold.OwnerId = testUser.Id;
        caseEvLL.OwnerId = testUser.Id;
        caseEvTT.OwnerId = testUser.Id;
        caseAwaitingRev.OwnerId = testUser.Id;
        caseRevComplete.OwnerId = testUser.Id;
        caseAdjudication.OwnerId = testUser.Id;
        caseClosed.OwnerId = testUser.Id;
        
        update new List<Case>{caseNew,caseOnHold,caseEvLL,caseEvTT,caseAwaitingRev,caseRevComplete,caseAdjudication,caseClosed};
        update newCases;
        Test.stopTest();
        
        System.assertEquals(200, [SELECT count() FROM CaseTeamMember WHERE MemberId = :testUser.Id AND ParentId IN :newCases]);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :testUser.Id AND ParentId = :caseNew.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :testUser.Id AND ParentId = :caseOnHold.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :testUser.Id AND ParentId = :caseEvLL.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :testUser.Id AND ParentId = :caseEvTT.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :testUser.Id AND ParentId = :caseAwaitingRev.Id AND TeamRole.Name = 'DRE']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :testUser.Id AND ParentId = :caseRevComplete.Id AND TeamRole.Name = 'Adjudicator']);
        System.assertEquals(1, [SELECT count() FROM CaseTeamMember WHERE MemberId = :testUser.Id AND ParentId = :caseAdjudication.Id AND TeamRole.Name = 'Adjudicator']);
        System.assertEquals(0, [SELECT count() FROM CaseTeamMember WHERE MemberId = :testUser.Id AND ParentId = :caseClosed.Id]);
    }
    /**
    * 6. Set Status Entry Date for each Status change
    */
    @IsTest
    static void caseStatusEntryDate_beforeInsert() {
        List<Case> newCases = FC_TestFactory.createSObjectList(
                new Case(), 200, 'FC_TestFactoryDefaults.CaseDefaults', true);

        System.assertEquals(200, [SELECT count() FROM Case WHERE Status_Entry_Date__c != null]);
    }

    @IsTest
    static void caseStatusEntryDate_beforeUpdate() {
        List<Case> newCases = FC_TestFactory.createSObjectList(
                new Case(), 200, 'FC_TestFactoryDefaults.CaseDefaults', true);

        for(Case newCase : newCases) {
            newCase.Status_Entry_Date__c = null;
        }
        update newCases;

        //status entry dates are cleared now
        System.assertEquals(200, [SELECT count() FROM Case WHERE Status_Entry_Date__c = null]);

        Test.startTest();
        for(Case newCase : newCases) {
            newCase.Status = FC_Constant.Case_Status_Adjudication;
        }
        update newCases;
        Test.stopTest();

        //status entry dates are being set again
        System.assertEquals(200, [SELECT count() FROM Case WHERE Status_Entry_Date__c != null]);
    }
    /**
    * 7. Mass mailer run process
    */
    @IsTest
    static void run_Massmailer() {
        Test.startTest();
        List<Case> newDisputes = FC_TestFactory.createSObjectList(
                new Case(Status = FC_Constant.Case_Status_New),
                200, 'FC_TestFactoryDefaults.CaseDefaults', true);        
        
        List<Case> reviewCompleteDisputes = FC_TestFactory.createSObjectList(
                new Case(Status = FC_Constant.Case_Status_Review_Complete),
                200, 'FC_TestFactoryDefaults.CaseDefaults', true);
        Test.stopTest();
        
        //ensure the emails will not be sent twice
        for(Case newDispute : newDisputes) {
            System.assert(FC_CaseHandler.massMailerProcessedCaseIds.contains(newDispute.Id));
        }
    }

    /**
     * 8. Run CaseParticipant logic on Case Status change to Evidence Gathering TT
     */
    @isTest
    static void when_caseStatusMovesToEvidenceGatheringTT_expect_ParticipantsChecksLogicToRun(){
        Account tenant1 = (Account) FC_TestFactory.createSObject(new Account(Name='Daffy Duck'), true);
        Account tenant2 = (Account) FC_TestFactory.createSObject(new Account(Name='Speedy Gonzales'), true);
        Account landlord = (Account) FC_TestFactory.createSObject(new Account(Name='Elmer Fudd'), true);
        Scheme__c scheme1 = (Scheme__c) FC_TestFactory.createSObject(new Scheme__c(), 'FC_TestFactoryDefaults.SchemeDefaults', true);
        Deposit__c deposit1 = (Deposit__c) FC_TestFactory.createSObject(new Deposit__c(Scheme__c = scheme1.Id, Customer__c=landlord.Id), 'FC_TestFactoryDefaults.DepositDefaults', true);
        Case newDispute = (Case) FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_New, RecordTypeId=
                                                                FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType,FC_Constant.RecordType_Zero_Deposit_Dispute_Dev_Name))
                                                                , 'FC_TestFactoryDefaults.CaseDefaults',true);
        Case_Participant__c tenantPart1 = (Case_Participant__c) FC_TestFactory.createSObject(
                                                                new Case_Participant__c(Account__c = tenant1.Id,
                                                                                        Case__c = newdispute.Id,
                                                                                        Type__c = FC_Constant.Allocation_And_Participant_Role_Tenant),
                                                                true);
        Case_Participant__c tenantPart2 = (Case_Participant__c) FC_TestFactory.createSObject(
                new Case_Participant__c(Account__c = tenant2.Id,
                        Case__c = newdispute.Id,
                        Type__c = FC_Constant.Allocation_And_Participant_Role_Tenant),
                true);
        Case_Participant__c landlordPart = (Case_Participant__c) FC_TestFactory.createSObject(
                new Case_Participant__c(Account__c = landlord.Id,
                        Case__c = newdispute.Id,
                        Type__c = FC_Constant.Allocation_And_Participant_Role_Landlord),
                true);
        // query Participants and assert the checkboxes of interest are unchecked before we move Case status
        List<Case_Participant__c> parts = getCaseParticipantsByCaseId(newDispute.Id);
        // assert
        for(Case_Participant__c cp : parts){
            System.assertEquals(false, cp.Send_Dispute_Acknowledgement__c);
            System.assertEquals(false, cp.Send_Evidence_Invitation_TT__c);
            System.assertEquals(false, cp.Send_Sent_to_Adjudicator__c);
        }
        // move case Status to Evidence Gathering TT
        newDispute.Status = FC_Constant.Case_Status_Evidence_Gathering_TT;

        Test.startTest();
            update newDispute;
        Test.stopTest();

        // re query parts
        parts = getCaseParticipantsByCaseId(newDispute.Id);

        // assert on checks performed
        for(Case_Participant__c cp : parts) {
            if(cp.Type__c == FC_Constant.Allocation_And_Participant_Role_Tenant){
          //      System.assertEquals(true, cp.Send_Evidence_Invitation_TT__c);
            }
            else if(cp.Type__c == FC_Constant.Allocation_And_Participant_Role_Landlord){
             //   System.assertEquals(true, cp.Send_Dispute_Acknowledgement__c);
            }
        }

    }

    /**
     * 9. Run CaseParticipant logic on Case Status change to Review Complete
     */
    @isTest
    static void when_caseStatusMovesToReviewComplete_expect_ParticipantsChecksLogicToRun(){
        Account dummyAccount = (Account) FC_TestFactory.createSObject(new Account(), true);
        SlaProcess slaProcess = [SELECT Id FROM SlaProcess WHERE Name = 'ZD Disputes' AND IsVersionDefault = true LIMIT 1];
        Entitlement entitlement = (Entitlement) FC_TestFactory.createSObject(
                new Entitlement(AccountId = dummyAccount.Id, SlaProcessId = slaProcess.Id),
                'FC_TestFactoryDefaults.EntitlementDefaults', true);
        Account tenant1 = (Account) FC_TestFactory.createSObject(new Account(Name='Daffy Duck'), true);
        Account tenant2 = (Account) FC_TestFactory.createSObject(new Account(Name='Speedy Gonzales'), true);
        Account landlord = (Account) FC_TestFactory.createSObject(new Account(Name='Elmer Fudd'), true);
        Scheme__c scheme1 = (Scheme__c) FC_TestFactory.createSObject(new Scheme__c(), 'FC_TestFactoryDefaults.SchemeDefaults', true);
        Deposit__c deposit1 = (Deposit__c) FC_TestFactory.createSObject(new Deposit__c(Scheme__c = scheme1.Id, Customer__c=landlord.Id), 'FC_TestFactoryDefaults.DepositDefaults', true);
        Case newDispute = (Case) FC_TestFactory.createSObject(new Case(Status = FC_Constant.Case_Status_New, RecordTypeId=
                FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType,FC_Constant.RecordType_Zero_Deposit_Dispute_Dev_Name))
                , 'FC_TestFactoryDefaults.CaseDefaults',true);
        Case_Participant__c tenantPart1 = (Case_Participant__c) FC_TestFactory.createSObject(
                new Case_Participant__c(Account__c = tenant1.Id,
                        Case__c = newdispute.Id,
                        Type__c = FC_Constant.Allocation_And_Participant_Role_Tenant),
                true);
        Case_Participant__c tenantPart2 = (Case_Participant__c) FC_TestFactory.createSObject(
                new Case_Participant__c(Account__c = tenant2.Id,
                        Case__c = newdispute.Id,
                        Type__c = FC_Constant.Allocation_And_Participant_Role_Tenant),
                true);
        Case_Participant__c landlordPart = (Case_Participant__c) FC_TestFactory.createSObject(
                new Case_Participant__c(Account__c = landlord.Id,
                        Case__c = newdispute.Id,
                        Type__c = FC_Constant.Allocation_And_Participant_Role_Landlord),
                true);
        // query Participants and assert the checkboxes of interest are unchecked before we move Case status
        List<Case_Participant__c> parts = getCaseParticipantsByCaseId(newDispute.Id);
        // assert
        for(Case_Participant__c cp : parts){
            System.assertEquals(false, cp.Send_Sent_to_Adjudicator__c);
        }
        // move case Status to Review Complete
        newDispute.Status = FC_Constant.Case_Status_Review_Complete;

        Test.startTest();
        update newDispute;
        Test.stopTest();

        // re query parts
        parts = getCaseParticipantsByCaseId(newDispute.Id);

        // assert on checks performed
        for(Case_Participant__c cp : parts) {
         //   System.assertEquals(true, cp.Send_Sent_to_Adjudicator__c);
        }

    }
    /**
     * 10. Verify events being sent through bus - test moved to FC_WebhookTest.testBulkSuccessesCaseUpdateEventPublisher() 
     */
    /**
     * 11. Verify that Case Milestone Target date is copied to case on status change
     */
    @isTest
    static void testCaseMilestoneTargetDateIsCopiedToCase() {
        Test.startTest();
        Account dummyAccount = (Account) FC_TestFactory.createSObject(new Account(), true);
        SlaProcess slaProcess = [SELECT Id FROM SlaProcess WHERE Name = 'EW Disputes' AND IsVersionDefault = true LIMIT 1];
        Entitlement entitlement = (Entitlement) FC_TestFactory.createSObject(
                new Entitlement(AccountId = dummyAccount.Id, SlaProcessId = slaProcess.Id),
                'FC_TestFactoryDefaults.EntitlementDefaults', true);

        List<Case> newCases = FC_TestFactory.createSObjectList(
                new Case(AccountId = dummyAccount.Id, Disputed_Amount__c = 100, Status = 'New'),
                2, 'FC_TestFactoryDefaults.CaseDefaults', true);

        newCases = [SELECT Id, Status FROM Case];
        System.assertEquals(2, newCases.size());
        for(Case cs : newCases) {
            System.assertEquals('New', cs.Status);
            cs.Status = 'Evidence Gathering - LL';
        }

        update newCases;
        Test.stopTest();

        Map<Id, Case> updatedCases = new Map<Id, Case>([SELECT Id, Status, Evidence_Target_Date__c FROM Case]);
        List<CaseMilestone> milestones = [SELECT Id, TargetDate, CaseId FROM CaseMilestone];
        System.assertEquals(2, milestones.size());
        for(CaseMilestone milestone : milestones) {
            Case cs = updatedCases.get(milestone.CaseId);
          //  System.assertEquals(milestone.TargetDate, cs.Evidence_Target_Date__c);
        }
    }

    /**** private helper methods ****/

    private static List<Case_Participant__c> getCaseParticipantsByCaseId(Id caseId){
        return [SELECT Case__c, Type__c, Send_Dispute_Acknowledgement__c, Send_Evidence_Invitation_TT__c, Send_Sent_to_Adjudicator__c
                FROM Case_Participant__c
                WHERE Case__c = :caseId];
    }

}