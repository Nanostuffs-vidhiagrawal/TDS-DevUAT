/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_DisputeAPI_PayloadValidator
 *
 * @when 18/12/2019
 */
@IsTest
private class FC_DisputeAPI_PayloadValidatorTest {
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
                                isRequired__c = false,
                                Object_Type__c = 'Array'), 
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
                                Dispute_API_Object__c = objects[0].Id,
                                Payload_Parameter_Name__c = 'lead_landlord_id',
                                SObject_Name__c = 'Case',
                                Salesforce_Field_API_Name__c = 'Lead_Landlord_External_ID__c',
                                isRequired__c = false
                        ),
                        false
                )
        };
        insert mappings;
    }
    
    @IsTest
    static void testNullPayload() {
        String payload = null;
        try {
            new FC_DisputeAPI_PayloadValidator(payload).validate();
            System.assert(false);
        }
        catch(FC_DisputeAPI_Exception e) {
            System.assertEquals('Invalid payload.',e.getMessage());
            System.assertEquals(400, e.statusCode);
        }
    }

    @IsTest
    static void test_invalid_object_with_valid_object() {
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        payloadObject.put('dispute', dispute);
        payloadObject.put('dispute1', dispute);

        String payload = JSON.serialize(payloadObject);
        try {
            new FC_DisputeAPI_PayloadValidator(payload).validate();
            System.assert(false);
        }
        catch(FC_DisputeAPI_Exception e) {
            System.assertEquals('Invalid Objects: dispute1',e.getMessage());
            System.assertEquals(200, e.statusCode);
        }
    }
    
    @IsTest
    static void test_2_invalid_objects() {
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        payloadObject.put('dispute2', dispute);
        payloadObject.put('dispute1', dispute);
        
        String payload = JSON.serialize(payloadObject);
        try {
            new FC_DisputeAPI_PayloadValidator(payload).validate();
            System.assert(false);
        }
        catch(FC_DisputeAPI_Exception e) {
            System.assertEquals('Invalid Objects: dispute1,dispute2',e.getMessage());
            System.assertEquals(200, e.statusCode);
        }
    }
    
    @IsTest
    static void test_missing_required_objects() {
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        payloadObject.put('dispute_line', dispute);
        
        String payload = JSON.serialize(payloadObject);
        try {
            new FC_DisputeAPI_PayloadValidator(payload).validate();
            System.assert(false);
        }
        catch(FC_DisputeAPI_Exception e) {
            System.assertEquals('Missing required Objects: dispute',e.getMessage());
            System.assertEquals(200, e.statusCode);
        }
    }

    @IsTest
    static void test_missing_required_parameters() {
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        payloadObject.put('dispute', dispute);

        String payload = JSON.serialize(payloadObject);
        try {
            new FC_DisputeAPI_PayloadValidator(payload).validate();
            System.assert(false);
        }
        catch(FC_DisputeAPI_Exception e) {
            System.assertEquals('Missing required parameters: id for object dispute',e.getMessage());
            System.assertEquals(200, e.statusCode);
        }
    }

    @IsTest
    static void test_invalid_parameters() {
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('testInvalid', 'value');
        dispute.put('id', 'value');
        payloadObject.put('dispute', dispute);

        String payload = JSON.serialize(payloadObject);
        try {
            new FC_DisputeAPI_PayloadValidator(payload).validate();
            System.assert(false);
        }
        catch(FC_DisputeAPI_Exception e) {
            System.assertEquals('Invalid parameters: testinvalid for object dispute',e.getMessage());
            System.assertEquals(200, e.statusCode);
        }
    }

    @IsTest
    static void test_valid() {
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', 'value');
        payloadObject.put('dispute', dispute);

        String payload = JSON.serialize(payloadObject);
        
        new FC_DisputeAPI_PayloadValidator(payload).validate();
        System.assert(true, 'Validation passed sucessfully');
    }

    @IsTest
    static void test_validate_Invalid_for_Child_Objects() {
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', 'value');
        payloadObject.put('dispute', dispute);

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', 'value');
        disputeItem.put('invalidparam', 'value');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem});

        String payload = JSON.serialize(payloadObject);

        try {
            new FC_DisputeAPI_PayloadValidator(payload).validate();
            System.assert(false);
        }
        catch(FC_DisputeAPI_Exception e) {
            System.assertEquals('Invalid parameters: invalidparam for object dispute_line',e.getMessage());
            System.assertEquals(200, e.statusCode);
        }
    }

    @IsTest
    static void test_valid_child_Objects() {
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', 'value');
        payloadObject.put('dispute', dispute);

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', 'value');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem});

        String payload = JSON.serialize(payloadObject);

        new FC_DisputeAPI_PayloadValidator(payload).validate();
        System.assert(true, 'Validation passed successfully');
    }

    @IsTest
    static void test_no_required_child_Objects() {
        Dispute_API_Object__c disputeAPIObject = (Dispute_API_Object__c) FC_TestFactory.createSObject(
                new Dispute_API_Object__c(
                        Name = 'tennant',
                        isRequired__c = true,
                        Object_Type__c = 'Array'),
                true
        );
        FC_TestFactory.createSObject(
                new Dispute_API_Mapping__c(
                        Dispute_API_Object__c = disputeAPIObject.Id,
                        Payload_Parameter_Name__c = 'id',
                        SObject_Name__c = 'Case',
                        Salesforce_Field_API_Name__c = 'Id',
                        isRequired__c = false
                ),
                false
        );
        
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', 'value');
        payloadObject.put('dispute', dispute);
        
        payloadObject.put('tennant', new List<Object>{});

        String payload = JSON.serialize(payloadObject);

        try {
            new FC_DisputeAPI_PayloadValidator(payload).validate();
            System.assert(false);
        }
        catch(Exception e) {
            System.assertEquals('tennant - lists can not be empty',e.getMessage());
        }
    }

    @IsTest
    static void test_invalid_Object_types() {
        Map<String,Object> payloadObject = new Map<String, Object>();
        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', 'value');
        payloadObject.put('dispute', new List<Object>{dispute,dispute});

        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', 'value');

        payloadObject.put('dispute_line', disputeItem);

        String payload = JSON.serialize(payloadObject);

        try {
            new FC_DisputeAPI_PayloadValidator(payload).validate();
            System.assert(false);
        }
        catch(Exception e) {
            System.assertEquals('Invalid type for objects: dispute_line,dispute',e.getMessage());
        }
    }
    
}