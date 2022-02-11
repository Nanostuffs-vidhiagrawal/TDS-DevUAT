@IsTest
private class FC_EvidenceUploadCommunityControllerTest {


    @TestSetup
    static void setup() {
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person').getRecordTypeId();

        Account tenant1 = (Account) FC_TestFactory.createSObject(new Account(LastName = 'Daffy Duck', PersonEmail = 'aaa@bbb.com', RecordTypeId = personAccountRecordTypeId), 'FC_TestFactoryDefaults.EmptyAccountDefaults', true);
        Account tenant2 = (Account) FC_TestFactory.createSObject(new Account(LastName = 'Road runner', PersonEmail = 'ccc@ddd.com', RecordTypeId = personAccountRecordTypeId), 'FC_TestFactoryDefaults.EmptyAccountDefaults',true);
        Account landlord = (Account) FC_TestFactory.createSObject(new Account(LastName = 'Elmer Fudd', RecordTypeId = personAccountRecordTypeId), 'FC_TestFactoryDefaults.EmptyAccountDefaults', true);
        Account propertyOwner = (Account) FC_TestFactory.createSObject(new Account(LastName = 'Bugs Bunny', RecordTypeId = personAccountRecordTypeId),'FC_TestFactoryDefaults.EmptyAccountDefaults', true);
        Scheme__c scheme1 = (Scheme__c) FC_TestFactory.createSObject(new Scheme__c(), 'FC_TestFactoryDefaults.SchemeDefaults', true);
        Property__c prop = (Property__c) FC_TestFactory.createSObject(new Property__c(Property_Owner__c = propertyOwner.Id, Postal_Code__c = '11 1 1'), 'FC_TestFactoryDefaults.PropertyDefaults', true);
        Deposit__c deposit1 = (Deposit__c) FC_TestFactory.createSObject(new Deposit__c(Scheme__c = scheme1.Id, Customer__c = landlord.Id, Property__c = prop.Id), 'FC_TestFactoryDefaults.DepositDefaults', true);


        Case newDispute = (Case) FC_TestFactory.createSObject(new Case(Subject = 'New Dispute', Status = FC_Constant.Case_Status_Evidence_Gathering_TT, Deposit_Account_Number__c = deposit1.Id, RecordTypeId =
                FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Case.SObjectType, FC_Constant.RecordType_Zero_Deposit_Dispute_Dev_Name))
                , 'FC_TestFactoryDefaults.CaseDefaults', true);
        Case_Participant__c tenantPart1 = (Case_Participant__c) FC_TestFactory.createSObject(
                new Case_Participant__c(Account__c = tenant1.Id,
                        Case__c = newdispute.Id,
                        Type__c = FC_Constant.Allocation_And_Participant_Role_Tenant,
                        Access_Code__c = '123456'),

                true);

        System.debug([SELECT Id, Access_Code__c FROM Case_Participant__c WHERE Id = :tenantPart1.Id]);
        Case_Participant__c landlordPart = (Case_Participant__c) FC_TestFactory.createSObject(
                new Case_Participant__c(Account__c = landlord.Id,
                        Case__c = newdispute.Id,
                        Type__c = FC_Constant.Allocation_And_Participant_Role_Landlord),
                true);

        Dispute_Item__c disputeItem = new Dispute_Item__c();
        disputeItem.Dispute__c = newDispute.Id;
        disputeItem.Type__c = 'Cleaning';
        disputeItem.Landlord_Statement__c = 'test landlord statement';
        insert disputeItem;

        Evidence_Attachment__c attachment = new Evidence_Attachment__c();
        attachment.Filename__c = 'file 1';
        attachment.Dispute_Item__c = disputeItem.Id;
        attachment.Dispute__c = newDispute.Id;
        insert attachment;
    }

    @IsTest
    static void testGetCaseParticipantSuccessful() {
        FC_EvidenceUploadCommunityController.FC_AuthorizationDataWrapper wrapper = new FC_EvidenceUploadCommunityController.FC_AuthorizationDataWrapper();
        wrapper.postCode = '1 1 11'; //different spacings than on property record - used on purpose to test the ignore spacings requirement
        wrapper.emailAddress = 'aaa@bbb.com';
        wrapper.accessCode = '123456';

        FC_EvidenceUploadCommunityController.FC_AuthorizationResponseDataWrapper responseDataWrapper = FC_EvidenceUploadCommunityController.getCaseParticipant(wrapper);
        System.assertEquals(true, responseDataWrapper.isSuccess);
        System.assertEquals(false, responseDataWrapper.isLead);
        System.assertNotEquals(null, responseDataWrapper.caseId);
    }

    @IsTest
    static void testGetCaseParticipantFailed() {
        FC_EvidenceUploadCommunityController.FC_AuthorizationDataWrapper wrapper = new FC_EvidenceUploadCommunityController.FC_AuthorizationDataWrapper();
        wrapper.postCode = '1111';
        wrapper.emailAddress = 'aaa@bbb.com';
        wrapper.accessCode = '111333'; //WRONG Access Code

        FC_EvidenceUploadCommunityController.FC_AuthorizationResponseDataWrapper responseDataWrapper = FC_EvidenceUploadCommunityController.getCaseParticipant(wrapper);
        System.assertEquals(false, responseDataWrapper.isSuccess);
        System.assertEquals(null, responseDataWrapper.caseId);
    }

    @IsTest
    static void testIsLeadTenantWithNoExistingLeadTenant(){
        Case_Participant__c cp = [SELECT Id, Case__c FROM Case_Participant__c WHERE Account__r.Name ='Daffy Duck'];

        FC_EvidenceUploadCommunityController.FC_IsLeadTenantDataWrapper wrapper = new FC_EvidenceUploadCommunityController.FC_IsLeadTenantDataWrapper();
        wrapper.caseId = cp.Case__c;
        wrapper.caseParticipantId = cp.Id;

        Boolean result = FC_EvidenceUploadCommunityController.isLeadTenant(wrapper);
        System.assertEquals(true, result);
    }

    @IsTest
    static void testIsLeadTenantWithExistingLeadTenant(){
        Account tenant2 = [SELECT Id FROM Account WHERE Name ='Road runner'];
        Case newDispute = [SELECT Id FROM Case WHERE Subject = 'New Dispute'];

        Case_Participant__c tenantPart2 = (Case_Participant__c) FC_TestFactory.createSObject(
                new Case_Participant__c(Account__c = tenant2.Id,
                        Case__c = newDispute.Id,
                        Type__c = FC_Constant.Allocation_And_Participant_Role_Tenant,
                        Access_Code__c = '654321',
                        Is_Lead__c = true
                ),
                true);

        Case_Participant__c cp = [SELECT Id, Case__c FROM Case_Participant__c WHERE Account__r.Name ='Daffy Duck'];

        FC_EvidenceUploadCommunityController.FC_IsLeadTenantDataWrapper wrapper = new FC_EvidenceUploadCommunityController.FC_IsLeadTenantDataWrapper();
        wrapper.caseId = cp.Case__c;
        wrapper.caseParticipantId = cp.Id;

        Boolean result = FC_EvidenceUploadCommunityController.isLeadTenant(wrapper);
        System.assertEquals(false, result);
    }


    @IsTest
    static void testGetContext(){
        Case newDispute = [SELECT Id FROM Case WHERE Subject = 'New Dispute'];

        FC_EvidenceUploadCommunityController.FC_GetContextRequestDataWrapper dataWrapper = new FC_EvidenceUploadCommunityController.FC_GetContextRequestDataWrapper();
        dataWrapper.caseId = newDispute.Id;
        FC_EvidenceUploadCommunityController.FC_GetContextResultDataWrapper contextResultDataWrapper = FC_EvidenceUploadCommunityController.getContext(dataWrapper);

        System.assertEquals(dataWrapper.caseId, contextResultDataWrapper.caseId);
    }

    @IsTest
    static void testUpdateTenantData(){
        Account accTenant1 = [SELECT Id, PersonContactId, PersonHomePhone FROM Account WHERE Name ='Daffy Duck'];
        Contact conTenant1 = [SELECT Id FROM Contact WHERE Id = :accTenant1.PersonContactId];

        FC_EvidenceUploadCommunityController.FC_TenantDataWrapper dataWrapper = new FC_EvidenceUploadCommunityController.FC_TenantDataWrapper();
        dataWrapper.id = accTenant1.Id;
        dataWrapper.phone = '123123123';
        dataWrapper.email = 'bbb@aaa.com';
        dataWrapper.contactId = accTenant1.PersonContactId;
        FC_EvidenceUploadCommunityController.FC_UpdateTenantResultDataWrapper result = FC_EvidenceUploadCommunityController.updateTenantData(dataWrapper);

        System.assertEquals(true, result.isSuccess);
        // assert on personAccount update
        Account tenant1AfterUpdate = [SELECT Id, PersonHomePhone, PersonEmail FROM Account WHERE Name ='Daffy Duck'];
        System.assertEquals(dataWrapper.phone, tenant1AfterUpdate.PersonHomePhone);
        System.assertEquals(dataWrapper.email, tenant1AfterUpdate.PersonEmail);
        // assert on personContact update
        Contact tenant1ContactAfterUpdate = [SELECT Id, Phone, Email FROM Contact WHERE Id = :conTenant1.Id];
        System.assertEquals(dataWrapper.phone, tenant1ContactAfterUpdate.Phone);
        System.assertEquals(dataWrapper.email, tenant1ContactAfterUpdate.Email);
    }

    @IsTest
    static void testGetEvidenceUploadBannerTexts(){
        Map<String,String> bannerTextResponse = FC_EvidenceUploadCommunityController.getEvidenceUploadBannerTexts();
        System.assert(String.isNotBlank(bannerTextResponse.get('claim_details_lead_text_with_date')));
        System.assert(String.isNotBlank(bannerTextResponse.get('claim_details_lead_text_no_date')));
        System.assert(String.isNotBlank(bannerTextResponse.get('claim_details_non_lead_text')));
        System.assert(String.isNotBlank(bannerTextResponse.get('evidence_upload_lead_text')));
        System.assert(String.isNotBlank(bannerTextResponse.get('evidence_upload_non_lead_text')));
    }

    @IsTest
    static void testGetEvidenceCommunityLabels(){
        Map<String,String> labelsMap = FC_EvidenceUploadCommunityController.getEvidenceUploadCommunityLabels();
        System.assert(String.isNotBlank(labelsMap.get('final_toast_text')));
    }

    @IsTest
    static void testUpdateTenantClaimStatement(){
        Dispute_Item__c disputeItem = [SELECT Id FROM Dispute_Item__c];

        FC_EvidenceUploadCommunityController.FC_DisputeItemWrapper dataWrapper = new FC_EvidenceUploadCommunityController.FC_DisputeItemWrapper();
        dataWrapper.id = disputeItem.Id;
        dataWrapper.tenantStatement = 'test modified tenantStatement';
        FC_EvidenceUploadCommunityController.FC_ResultDataWrapper result = FC_EvidenceUploadCommunityController.updateTenantClaimStatement(dataWrapper);

        System.assertEquals(true, result.isSuccess);
        Dispute_Item__c disputeItemAfterUpdate = [SELECT Id, Tenant_Statement__c FROM Dispute_Item__c WHERE Id =: disputeItem.Id];
        System.assertEquals(dataWrapper.tenantStatement, disputeItemAfterUpdate.Tenant_Statement__c);

    }

    @IsTest
    static void testDeleteEvidenceAttachment(){
        Evidence_Attachment__c attachment = [SELECT Id FROM Evidence_Attachment__c WHERE Filename__c ='file 1'];
        FC_EvidenceUploadCommunityController.FC_ResultDataWrapper result = FC_EvidenceUploadCommunityController.deleteEvidenceAttachment(attachment.Id);
        System.assertEquals(true, result.isSuccess);
    }

}