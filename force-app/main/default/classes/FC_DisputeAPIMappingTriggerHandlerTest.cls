/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_DisputeAPIMappingTriggerHandler
 *
 * @when 09/12/2019
 */
@IsTest
public with sharing class FC_DisputeAPIMappingTriggerHandlerTest {
    @IsTest
    static void testRequired() {
        try {
            FC_TestFactory.createSObject(
                    new Dispute_API_Mapping__c(SObject_Name__c = 'case', Salesforce_Field_API_Name__c = 'Id'),
                    'FC_TestFactoryDefaults.DisputeAPIMappingsDefaults', true);
            System.assert(false, 'Code should not reach this step');
        }
        catch(Exception exc) {
            System.assert(true, 'Field is universally required in Salesforce, please mark it as required');
        }
    }

    @IsTest
    static void testPositive() {
        Dispute_API_Object__c obj = (Dispute_API_Object__c) FC_TestFactory.createSObject(
                new Dispute_API_Object__c(isRequired__c = true),
                'FC_TestFactoryDefaults.DisputeAPIObjectDefaults', true);
                
        FC_TestFactory.createSObject(
                new Dispute_API_Mapping__c(Dispute_API_Object__c = obj.Id, SObject_Name__c = 'case', 
                        Salesforce_Field_API_Name__c = 'Id', isRequired__c = true),
                'FC_TestFactoryDefaults.DisputeAPIMappingsDefaults', true);
        System.assert(true, 'Mapping has been created');
    }

    @IsTest
    static void testBeforeUpdate_positive() {
        Dispute_API_Object__c obj = (Dispute_API_Object__c) FC_TestFactory.createSObject(
                new Dispute_API_Object__c(isRequired__c = true),
                'FC_TestFactoryDefaults.DisputeAPIObjectDefaults', true);

        FC_TestFactory.createSObject(
                new Dispute_API_Mapping__c(Dispute_API_Object__c = obj.Id, SObject_Name__c = 'case',
                        Salesforce_Field_API_Name__c = 'Dispute_Initiated_By__c', isRequired__c = false),
                'FC_TestFactoryDefaults.DisputeAPIMappingsDefaults', true);
        System.assert(true, 'Mapping has been created');

        Dispute_API_Mapping__c mapping = [SELECT isRequired__c
                                          FROM Dispute_API_Mapping__c
                                          WHERE Salesforce_Field_API_Name__c = 'Dispute_Initiated_By__c' LIMIT 1];
        System.assertEquals(false, mapping.isRequired__c);

        mapping.isRequired__c = true;
        update mapping;
        System.assert(true, 'Mapping has been updated');
    }

    @IsTest
    static void testBadObject() {
        try {
            FC_TestFactory.createSObject(
                    new Dispute_API_Mapping__c(SObject_Name__c = 'case1', Salesforce_Field_API_Name__c = 'Id',
                            isRequired__c = true),
                    'FC_TestFactoryDefaults.DisputeAPIMappingsDefaults', true);
            System.assert(false, 'Code should not reach this step');
        }
        catch(Exception exc) {
            System.assert(true, 'Wrong SObject Name provided');
        }
    }    
    
    @IsTest
    static void testBadField() {
        try {
            FC_TestFactory.createSObject(
                    new Dispute_API_Mapping__c(SObject_Name__c = 'case', Salesforce_Field_API_Name__c = 'Id1',
                            isRequired__c = true),
                    'FC_TestFactoryDefaults.DisputeAPIMappingsDefaults', true);
            System.assert(false, 'Code should not reach this step');
        }
        catch(Exception exc) {
            System.assert(true, 'Wrong Salesforce Field Name provided');
        }
    }
}