/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_DisputeAPI_DataManipulatorTest
 *
 * @when 20/12/2019
 */
@IsTest
private class FC_DisputeAPI_DataManipulatorTest {
    @TestSetup
    public static void setup() {
        FC_TestFactory.createSObject(new API_Account__c(), 'FC_TestFactoryDefaults.APIAccountDefaults', true);
        FC_TestFactory.createSObject(new Scheme__c(), 'FC_TestFactoryDefaults.SchemeDefaults', true);

        List<Dispute_API_Object__c> objects = new List<Dispute_API_Object__c>{
                (Dispute_API_Object__c) FC_TestFactory.createSObject(
                        new Dispute_API_Object__c(
                                Name = 'dispute',
                                isRequired__c = true),
                        false
                ),
                (Dispute_API_Object__c) FC_TestFactory.createSObject(
                        new Dispute_API_Object__c(
                                Name = 'dispute_line',
                                isRequired__c = false),
                        false
                ),
                (Dispute_API_Object__c) FC_TestFactory.createSObject(
                        new Dispute_API_Object__c(
                                Name = 'tenant',
                                isRequired__c = false),
                        false
                ),
                (Dispute_API_Object__c) FC_TestFactory.createSObject(
                        new Dispute_API_Object__c(
                                Name = 'branch',
                                isRequired__c = false),
                        false
                ),
                (Dispute_API_Object__c) FC_TestFactory.createSObject(
                        new Dispute_API_Object__c(
                                Name = 'agent',
                                isRequired__c = false),
                        false
                ),
                (Dispute_API_Object__c) FC_TestFactory.createSObject(
                        new Dispute_API_Object__c(
                                Name = 'landlord',
                                isRequired__c = false),
                        false
                ),
                (Dispute_API_Object__c) FC_TestFactory.createSObject(
                        new Dispute_API_Object__c(
                                Name = 'evidence',
                                isRequired__c = false),
                        false
                )
        };
        insert objects;

        List<Dispute_API_Mapping__c> mappings = new List<Dispute_API_Mapping__c>{
                (Dispute_API_Mapping__c)FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = objects[0].Id,
                                Payload_Parameter_Name__c = 'id',
                                SObject_Name__c = 'Case',
                                Salesforce_Field_API_Name__c = 'External_Id__c',
                                isRequired__c = true
                        ),
                        false
                ),
                (Dispute_API_Mapping__c)FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = objects[0].Id,
                                Payload_Parameter_Name__c = 'branch_id',
                                SObject_Name__c = 'Case',
                                Salesforce_Field_API_Name__c = 'Branch_External_ID__c',
                                isRequired__c = false
                        ),
                        false
                ),
                (Dispute_API_Mapping__c)FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = objects[0].Id,
                                Payload_Parameter_Name__c = 'disputed_amount',
                                SObject_Name__c = 'Case',
                                Salesforce_Field_API_Name__c = 'Disputed_Amount__c',
                                isRequired__c = false
                        ),
                        false
                ),
                (Dispute_API_Mapping__c)FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = objects[1].Id,
                                Payload_Parameter_Name__c = 'id',
                                SObject_Name__c = 'Dispute_Item__c',
                                Salesforce_Field_API_Name__c = 'External_Id__c',
                                isRequired__c = true
                        ),
                        false
                ),
                (Dispute_API_Mapping__c)FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = objects[1].Id,
                                Payload_Parameter_Name__c = 'dispute_id',
                                SObject_Name__c = 'Dispute_Item__c',
                                Salesforce_Field_API_Name__c = 'Dispute_External_Id__c',
                                isRequired__c = true
                        ),
                        false
                ),
                (Dispute_API_Mapping__c)FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = objects[1].Id,
                                Payload_Parameter_Name__c = 'type',
                                SObject_Name__c = 'Dispute_Item__c',
                                Salesforce_Field_API_Name__c = 'Type__c',
                                isRequired__c = true
                        ),
                        false
                ),
                (Dispute_API_Mapping__c)FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = objects[2].Id,
                                Payload_Parameter_Name__c = 'birth_date',
                                SObject_Name__c = 'Contact',
                                Salesforce_Field_API_Name__c = 'Birthdate',
                                isRequired__c = false
                        ),
                        false
                )
        };
        insert mappings;
    }
    
    @IsTest
    static void testNoRequiredField() {
        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);

        Map<String,Object> payloadObject = new Map<String, Object>();

        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', '123');
        payloadObject.put('dispute', dispute);

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', '1111');
        disputeItem.put('dispute_id', '123');
        //comment out required field
        //disputeItem.put('type', 'Rent');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem});

        Map<String,Map<SObjectType,List<SObject>>> mappedPayload = new FC_DisputeAPI_PayloadMapper(payloadObject, apiAccount).processDataMapping();
        FC_DisputeAPI_DataManipulator dataManipulator = new FC_DisputeAPI_DataManipulator(mappedPayload, apiAccount);
        try {
            List<SObject> disputes = dataManipulator.performDML();
        }
        catch(Exception e) {
            System.assertEquals('Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Type__c]: [Type__c]',e.getMessage());
        }
    }

    @IsTest
    static void testSuccessWithRelations() {
        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);

        Map<String,Object> payloadObject = new Map<String, Object>();

        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', '123');
        payloadObject.put('dispute', dispute);

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', '1111');
        disputeItem.put('dispute_id', '123');
        disputeItem.put('type', 'Rent');

        Map<String,Object> disputeItem1 = disputeItem.clone();
        disputeItem.put('id', '2222');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem1});

        Map<String,Map<SObjectType,List<SObject>>> mappedPayload = new FC_DisputeAPI_PayloadMapper(payloadObject, apiAccount).processDataMapping();
        FC_DisputeAPI_DataManipulator dataManipulator = new FC_DisputeAPI_DataManipulator(mappedPayload, apiAccount);
        List<SObject> disputes = dataManipulator.performDML();
        
        System.assertEquals(1, [SELECT count() FROM Case WHERE External_ID__c = 'ZeroDeposit-123' AND OwnerId = :apiAccount.Data_Owner_User__c]);
        System.assertEquals(2, [SELECT count() FROM Dispute_Item__c WHERE Dispute__r.External_ID__c = 'ZeroDeposit-123']);
    }

    @IsTest
    static void testSameIdsException() {
        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);

        Map<String,Object> payloadObject = new Map<String, Object>();

        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', '123');
        payloadObject.put('dispute', dispute);

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', '1111');
        disputeItem.put('dispute_id', '123');
        disputeItem.put('type', 'Rent');

        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem});

        Map<String,Map<SObjectType,List<SObject>>> mappedPayload = new FC_DisputeAPI_PayloadMapper(payloadObject, apiAccount).processDataMapping();
        FC_DisputeAPI_DataManipulator dataManipulator = new FC_DisputeAPI_DataManipulator(mappedPayload, apiAccount);
        
        try {
            List<SObject> disputes = dataManipulator.performDML();
        }
        catch(Exception e) {
            System.assertEquals('Duplicate dispute_line id found',e.getMessage());
        }
    }

    @IsTest
    static void testSuccessCaseParticipantsQueueable() {
        Dispute_API_Object__c disputeAPIObject = [SELECT Id FROM Dispute_API_Object__c WHERE Name = 'branch'];
        List<Dispute_API_Mapping__c> mappings = new List<Dispute_API_Mapping__c>{
                (Dispute_API_Mapping__c) FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = disputeAPIObject.Id,
                                Payload_Parameter_Name__c = 'id',
                                SObject_Name__c = 'Account',
                                Salesforce_Field_API_Name__c = 'Branch_External_Id__c',
                                isRequired__c = true
                        ),
                        false
                ),
                (Dispute_API_Mapping__c) FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = disputeAPIObject.Id,
                                Payload_Parameter_Name__c = 'name',
                                SObject_Name__c = 'Account',
                                Salesforce_Field_API_Name__c = 'Name',
                                isRequired__c = true
                        ),
                        false
                )
        };
        insert mappings;
        
        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);

        Map<String,Object> payloadObject = new Map<String, Object>();

        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', '123');
        payloadObject.put('dispute', dispute);

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', '1111');
        disputeItem.put('dispute_id', '123');
        disputeItem.put('type', 'Rent');

        Map<String,Object> disputeItem1 = disputeItem.clone();
        disputeItem.put('id', '2222');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem1});

        Map<String,Object> branch = new Map<String, Object>();
        branch.put('id', 'branchExternalId-111');
        branch.put('name', 'testBranchName');
        payloadObject.put('branch', branch);

        Map<String,Map<SObjectType,List<SObject>>> mappedPayload = new FC_DisputeAPI_PayloadMapper(payloadObject, apiAccount).processDataMapping();
        FC_DisputeAPI_DataManipulator dataManipulator = new FC_DisputeAPI_DataManipulator(mappedPayload, apiAccount);
        
        Test.startTest();
        List<SObject> disputes = dataManipulator.performDML();
        System.assertEquals(1, [SELECT count() FROM AsyncApexJob]);
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Account WHERE Branch_External_ID__c = 'ZeroDeposit-branchExternalId-111']);
        System.assertEquals(1, [SELECT count() FROM Case_Participant__c WHERE Type__c = 'agent']);
    }
    
    @IsTest
    static void testExceptionCaseParticipantsQueueable() {
        Dispute_API_Object__c disputeAPIObject = [SELECT Id FROM Dispute_API_Object__c WHERE Name = 'branch'];
        List<Dispute_API_Mapping__c> mappings = new List<Dispute_API_Mapping__c>{
                (Dispute_API_Mapping__c) FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = disputeAPIObject.Id,
                                Payload_Parameter_Name__c = 'id',
                                SObject_Name__c = 'Account',
                                Salesforce_Field_API_Name__c = 'External_Id__c',
                                isRequired__c = true
                        ),
                        false
                ),
                (Dispute_API_Mapping__c) FC_TestFactory.createSObject(
                        new Dispute_API_Mapping__c(
                                Dispute_API_Object__c = disputeAPIObject.Id,
                                Payload_Parameter_Name__c = 'name',
                                SObject_Name__c = 'Account',
                                Salesforce_Field_API_Name__c = 'Name',
                                isRequired__c = true
                        ),
                        false
                )
        };
        insert mappings;

        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);

        Map<String,Object> payloadObject = new Map<String, Object>();

        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', '123');
        payloadObject.put('dispute', dispute);

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', '1111');
        disputeItem.put('dispute_id', '123');
        disputeItem.put('type', 'Rent');

        Map<String,Object> disputeItem1 = disputeItem.clone();
        disputeItem.put('id', '2222');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem1});

        Map<String,Object> branch = new Map<String, Object>();
        branch.put('id', 'branchExternalId-111');
        branch.put('name', 'testBranchName');
        payloadObject.put('branch', branch);

        Map<String,Map<SObjectType,List<SObject>>> mappedPayload = new FC_DisputeAPI_PayloadMapper(payloadObject, apiAccount).processDataMapping();
        FC_DisputeAPI_DataManipulator dataManipulator = new FC_DisputeAPI_DataManipulator(mappedPayload, apiAccount);
        dataManipulator.throwException = true;
        Exception thrownException;
        try {
            Test.startTest();
            List<SObject> disputes = dataManipulator.performDML();
            Test.stopTest();
        }catch(Exception ex) {
            thrownException = ex;
        }

        System.assertEquals(0, [SELECT count() FROM AsyncApexJob]);
        System.assertNotEquals(null, thrownException);
    }

}