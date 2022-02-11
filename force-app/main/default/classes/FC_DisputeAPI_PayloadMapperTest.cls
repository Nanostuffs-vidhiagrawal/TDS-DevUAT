/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_DisputeAPI_PayloadMapper
 *
 * @when 18/12/2019
 */
@IsTest
public with sharing class FC_DisputeAPI_PayloadMapperTest {
    @TestSetup
    private static void setup() {
        FC_TestFactory.createSObject(new API_Account__c(), 'FC_TestFactoryDefaults.APIAccountDefaults', true);

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
                                Payload_Parameter_Name__c = 'initiated_by',
                                SObject_Name__c = 'Case',
                                Salesforce_Field_API_Name__c = 'Dispute_Initiated_By__c',
                                isRequired__c = false
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
    private static void testAddDisputeWithTwoLines() {
        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);
        
        Map<String,Object> payloadObject = new Map<String, Object>();

        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', '123');
        dispute.put('initiated_by','Agent');
        payloadObject.put('dispute', dispute);

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', '1111');
        disputeItem.put('dispute_id', '123');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem});

        Map<String,Object> tenant = new Map<String, Object>();
        tenant.put('birth_date', '2019-12-12');
        payloadObject.put('tenant', tenant);

        Map<String,Map<SObjectType,List<SObject>>> mappedPayload = new FC_DisputeAPI_PayloadMapper(payloadObject, apiAccount).processDataMapping();
        
        for(Case disputeSObject : (List<Case>)mappedPayload.get('dispute').get(Case.SObjectType)) {
            System.assertEquals('ZeroDeposit-123', disputeSObject.External_ID__c);
        }

        for(Dispute_Item__c disputeLine : (List<Dispute_Item__c>)mappedPayload.get('dispute_line').get(Dispute_Item__c.SObjectType)) {
            System.assertEquals('ZeroDeposit-1111', disputeLine.External_ID__c);
            System.assertEquals('ZeroDeposit-123', disputeLine.Dispute_External_Id__c);
        }
    }

    @IsTest
    private static void when_disputeInitiatedByIsInvalid_expect_exceptionThrown() {
        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);

        Map<String,Object> payloadObject = new Map<String, Object>();

        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', '123');
        dispute.put('initiated_by','invalidValue');
        payloadObject.put('dispute', dispute);

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', '1111');
        disputeItem.put('dispute_id', '123');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem});

        Map<String,Object> tenant = new Map<String, Object>();
        tenant.put('birth_date', '2019-12-12');
        payloadObject.put('tenant', tenant);

        try {
            Map<String, Map<SObjectType, List<SObject>>> mappedPayload = new FC_DisputeAPI_PayloadMapper(payloadObject, apiAccount).processDataMapping();
        }
        catch(Exception e){
            System.assert(e instanceof FC_DisputeAPI_Exception.PayloadException);
        }

    }

    @IsTest
    private static void testBadType() {
        API_Account__c apiAccount = FC_DisputeAPI_Authenticator.getAPIAccount(FC_Constant.TEST_CLIENT_APIACCOUNTID);

        Map<String,Object> payloadObject = new Map<String, Object>();

        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', '123');
        dispute.put('disputed_amount', 'test');
        payloadObject.put('dispute', dispute);

        try {
            Map<String, Map<SObjectType, List<SObject>>> mappedPayload = new FC_DisputeAPI_PayloadMapper(payloadObject, apiAccount).processDataMapping();
            System.assert(false);
        }
        catch (Exception e) {
            System.assertEquals('Invalid field type for key dispute.disputed_amount',e.getMessage());
        }
    }

}