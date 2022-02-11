/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what 
 *
 * @when 18/12/2019
 */
@IsTest
public with sharing class FC_DisputeAPI_V1_Test {
    static String accountId = 'ZeroDeposit';
    static String timestamp = String.valueOf(Datetime.now().getTime());
    static String hmac = FC_DisputeAPI_Authenticator.generateHMACKey(FC_Constant.TEST_CLIENT_ID, FC_Constant.TEST_CLIENT_SECRET, timestamp);

    @TestSetup
    public static void setup() {
        FC_TestFactory.createSObject(new API_Account__c(), 'FC_TestFactoryDefaults.APIAccountDefaults', true);
        FC_TestFactory.createSObject(new Scheme__c(), 'FC_TestFactoryDefaults.SchemeDefaults', true);
        /**
         * get new version of configs by running
         * List<Dispute_API_Object__c> objects = [select Name, Object_Type__c, isActive__c, isRequired__c, (SELECT Dispute_API_Object__c, Payload_Parameter_Name__c, SObject_Name__c, Salesforce_Field_API_Name__c, Salesforce_Field_Length__c, Salesforce_Field_Type__c, isActive__c, isRequired__c FROM Dispute_API_Mappings__r) from Dispute_API_Object__c];
         * for(Dispute_API_Object__c obj : objects) {
         *     obj.Id = null;
         *     for (Dispute_API_Mapping__c mapping : obj.Dispute_API_Mappings__r) {
         *         mapping.Id = null;
         *     }
         * }
         * System.debug(JSON.serialize(objects));
         */
        String jsonConfigs = '[{"attributes":{"type":"Dispute_API_Object__c"},"Name":"dispute","Object_Type__c":"Object","isActive__c":true,"isRequired__c":true,"Id":null,"Dispute_API_Mappings__r":{"totalSize":14,"done":true,"records":[{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"dispute_steps","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Dispute_Steps__c","Salesforce_Field_Length__c":32768,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"dispute_reasons","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Dispute_Reasons__c","Salesforce_Field_Length__c":32768,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"lead_landlord_id","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Lead_Landlord_External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"lead_tenant_id","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Lead_Tenant_External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"status","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Status","isActive__c":false,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"total_claim_amount","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Total_Claim_Amount__c","Salesforce_Field_Length__c":18,"Salesforce_Field_Type__c":"DOUBLE","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"id","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"initiated_by","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Dispute_Initiated_By__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"branch_id","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Branch_External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"agent_id","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Agent_External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"deposit_owner_id","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Deposit_Owner_External_Id__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"disputed_amount","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Disputed_Amount__c","Salesforce_Field_Length__c":18,"Salesforce_Field_Type__c":"DOUBLE","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"tenancy_id","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"Deposit_External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgJQAQ","Id":null,"Payload_Parameter_Name__c":"created_date","SObject_Name__c":"Case","Salesforce_Field_API_Name__c":"created_date_external__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATETIME","isActive__c":true,"isRequired__c":false}]}},{"attributes":{"type":"Dispute_API_Object__c"},"Name":"dispute_line","Object_Type__c":"Array","isActive__c":true,"isRequired__c":true,"Id":null,"Dispute_API_Mappings__r":{"totalSize":8,"done":true,"records":[{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgKQAQ","Id":null,"Payload_Parameter_Name__c":"dispute_id","SObject_Name__c":"Dispute_Item__c","Salesforce_Field_API_Name__c":"Dispute_External_Id__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgKQAQ","Id":null,"Payload_Parameter_Name__c":"type","SObject_Name__c":"Dispute_Item__c","Salesforce_Field_API_Name__c":"Type__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgKQAQ","Id":null,"Payload_Parameter_Name__c":"tenant_amount_agreed","SObject_Name__c":"Dispute_Item__c","Salesforce_Field_API_Name__c":"Agreed_by_Tenant__c","Salesforce_Field_Length__c":18,"Salesforce_Field_Type__c":"DOUBLE","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgKQAQ","Id":null,"Payload_Parameter_Name__c":"claimed_landlord","SObject_Name__c":"Dispute_Item__c","Salesforce_Field_API_Name__c":"Claimed_by_Landlord__c","Salesforce_Field_Length__c":18,"Salesforce_Field_Type__c":"DOUBLE","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgKQAQ","Id":null,"Payload_Parameter_Name__c":"landlord_statement","SObject_Name__c":"Dispute_Item__c","Salesforce_Field_API_Name__c":"Landlord_Statement__c","Salesforce_Field_Length__c":32768,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgKQAQ","Id":null,"Payload_Parameter_Name__c":"tenant_statement","SObject_Name__c":"Dispute_Item__c","Salesforce_Field_API_Name__c":"Tenant_Statement__c","Salesforce_Field_Length__c":32768,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgKQAQ","Id":null,"Payload_Parameter_Name__c":"created_date","SObject_Name__c":"Dispute_Item__c","Salesforce_Field_API_Name__c":"created_date_external__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATETIME","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgKQAQ","Id":null,"Payload_Parameter_Name__c":"id","SObject_Name__c":"Dispute_Item__c","Salesforce_Field_API_Name__c":"External_Id__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true}]}},{"attributes":{"type":"Dispute_API_Object__c"},"Name":"agent","Object_Type__c":"Object","isActive__c":true,"isRequired__c":false,"Id":null,"Dispute_API_Mappings__r":{"totalSize":11,"done":true,"records":[{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"created_date","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"created_date_external__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATETIME","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"job_title","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Title","Salesforce_Field_Length__c":128,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"id","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Agent_External_Id__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"branch_id","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Branch_External_Id__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"firstname","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"FirstName","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"lastname","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"LastName","Salesforce_Field_Length__c":80,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"phone","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Phone","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"mobile","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"MobilePhone","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"email","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Email","Salesforce_Field_Length__c":80,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"birth_date","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Birthdate","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATE","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgLQAQ","Id":null,"Payload_Parameter_Name__c":"salutation","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Salutation","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":false}]}},{"attributes":{"type":"Dispute_API_Object__c"},"Name":"tenant","Object_Type__c":"Array","isActive__c":true,"isRequired__c":true,"Id":null,"Dispute_API_Mappings__r":{"totalSize":10,"done":true,"records":[{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"firstname","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"FirstName","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"lastname","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"LastName","Salesforce_Field_Length__c":80,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"phone","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Phone","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"mobile","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"MobilePhone","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"id","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Tenant_External_Id__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"birth_date","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Birthdate","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATE","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"salutation","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Salutation","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"job_title","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Title","Salesforce_Field_Length__c":128,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"created_date","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"created_date_external__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATETIME","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgMQAQ","Id":null,"Payload_Parameter_Name__c":"email","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Email","Salesforce_Field_Length__c":80,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true}]}},{"attributes":{"type":"Dispute_API_Object__c"},"Name":"branch","Object_Type__c":"Object","isActive__c":true,"isRequired__c":false,"Id":null,"Dispute_API_Mappings__r":{"totalSize":9,"done":true,"records":[{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgNQAQ","Id":null,"Payload_Parameter_Name__c":"created_date","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"created_date_external__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATETIME","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgNQAQ","Id":null,"Payload_Parameter_Name__c":"website","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"Website","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgNQAQ","Id":null,"Payload_Parameter_Name__c":"country","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"BillingCountry","Salesforce_Field_Length__c":80,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgNQAQ","Id":null,"Payload_Parameter_Name__c":"city","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"BillingCity","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgNQAQ","Id":null,"Payload_Parameter_Name__c":"street","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"BillingStreet","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgNQAQ","Id":null,"Payload_Parameter_Name__c":"postcode","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"BillingPostalCode","Salesforce_Field_Length__c":20,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgNQAQ","Id":null,"Payload_Parameter_Name__c":"phone","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"Phone","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgNQAQ","Id":null,"Payload_Parameter_Name__c":"name","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"Name","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgNQAQ","Id":null,"Payload_Parameter_Name__c":"id","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"Branch_External_ID__c","Salesforce_Field_Length__c":254,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true}]}},{"attributes":{"type":"Dispute_API_Object__c"},"Name":"landlord","Object_Type__c":"Object","isActive__c":true,"isRequired__c":true,"Id":null,"Dispute_API_Mappings__r":{"totalSize":14,"done":true,"records":[{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"postcode","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"BillingPostalCode","Salesforce_Field_Length__c":20,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"street","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"BillingStreet","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"city","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"BillingCity","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"country","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"BillingCountry","Salesforce_Field_Length__c":80,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"created_date","SObject_Name__c":"Account","Salesforce_Field_API_Name__c":"created_date_external__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATETIME","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"job_title","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Title","Salesforce_Field_Length__c":128,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"id","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Landlord_External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"birth_date","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Birthdate","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATE","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"email","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Email","Salesforce_Field_Length__c":80,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"mobile","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"MobilePhone","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"phone","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Phone","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"lastname","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"LastName","Salesforce_Field_Length__c":80,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"firstname","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"FirstName","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgOQAQ","Id":null,"Payload_Parameter_Name__c":"salutation","SObject_Name__c":"Contact","Salesforce_Field_API_Name__c":"Salutation","Salesforce_Field_Length__c":40,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":false}]}},{"attributes":{"type":"Dispute_API_Object__c"},"Name":"tenancy","Object_Type__c":"Object","isActive__c":true,"isRequired__c":true,"Id":null,"Dispute_API_Mappings__r":{"totalSize":15,"done":true,"records":[{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"reference","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"Zero_Deposit_Reference__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"end_type","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"Tenancy_End_Type__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"customer_id","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"Customer_External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"customer_type","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"Customer_Type__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"created_date","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"created_date_external__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATETIME","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"nr_of_tenants","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"Number_Of_Tenants__c","Salesforce_Field_Length__c":3,"Salesforce_Field_Type__c":"DOUBLE","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"id","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"External_Id__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"postcode","SObject_Name__c":"Property__c","Salesforce_Field_API_Name__c":"Postal_Code__c","Salesforce_Field_Length__c":10,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"street","SObject_Name__c":"Property__c","Salesforce_Field_API_Name__c":"Street__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"city","SObject_Name__c":"Property__c","Salesforce_Field_API_Name__c":"City__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"country","SObject_Name__c":"Property__c","Salesforce_Field_API_Name__c":"Country__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"deposit_amount","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"Deposit_Amount__c","Salesforce_Field_Length__c":18,"Salesforce_Field_Type__c":"DOUBLE","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"start_date","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"Start_Date__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATE","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"end_date","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"End_Date__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATE","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgPQAQ","Id":null,"Payload_Parameter_Name__c":"rent_amount","SObject_Name__c":"Deposit__c","Salesforce_Field_API_Name__c":"Rent_Amount__c","Salesforce_Field_Length__c":18,"Salesforce_Field_Type__c":"DOUBLE","isActive__c":true,"isRequired__c":false}]}},{"attributes":{"type":"Dispute_API_Object__c"},"Name":"evidence","Object_Type__c":"Array","isActive__c":true,"isRequired__c":true,"Id":null,"Dispute_API_Mappings__r":{"totalSize":10,"done":true,"records":[{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"dispute_id","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"Dispute_External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"dispute_item_id","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"Dispute_Item_External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"filename","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"Filename__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"file_size","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"File_Size__c","Salesforce_Field_Length__c":18,"Salesforce_Field_Type__c":"DOUBLE","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"id","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"External_ID__c","Salesforce_Field_Length__c":244,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"file_url","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"Location__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"STRING","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"source","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"Source__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"uploader_type","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"User_Type__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":true},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"created_date","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"created_date_external__c","Salesforce_Field_Length__c":0,"Salesforce_Field_Type__c":"DATETIME","isActive__c":true,"isRequired__c":false},{"attributes":{"type":"Dispute_API_Mapping__c"},"Dispute_API_Object__c":"a128E000001grgQQAQ","Id":null,"Payload_Parameter_Name__c":"file_type","SObject_Name__c":"Evidence_Attachment__c","Salesforce_Field_API_Name__c":"File_Type__c","Salesforce_Field_Length__c":255,"Salesforce_Field_Type__c":"PICKLIST","isActive__c":true,"isRequired__c":false}]}}]';

        List<Dispute_API_Object__c> objects = (List<Dispute_API_Object__c>)JSON.deserialize(jsonConfigs, List<Dispute_API_Object__c>.class);
        List<Dispute_API_Mapping__c> mappings = new List<Dispute_API_Mapping__c>();
        insert objects;
        for(Dispute_API_Object__c obj : objects) {
            for(Dispute_API_Mapping__c mapping : obj.Dispute_API_Mappings__r) {
                mapping.Dispute_API_Object__c = obj.Id;
            }
            mappings.addAll(obj.Dispute_API_Mappings__r);
        }
        insert mappings;
    }

    @SuppressWarnings('PMD.NcssMethodCount')
    @IsTest
    static void testDisputeV1Strategy_positive() {
        Map<String,Object> payloadObject = new Map<String, Object>();

        String disputeId = 'disputeId1';
        String tenancyId = 'tenancyId1';
        String landlordId = 'landlordId1';

        //dispute
        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', disputeId);
        dispute.put('total_claim_amount', '1000');
        dispute.put('deposit_owner_id',landlordId);
        dispute.put('lead_landlord_id',landlordId);
        dispute.put('disputed_amount', '1000');
        dispute.put('tenancy_id', tenancyId);
        dispute.put('initiated_by', 'Landlord');
        payloadObject.put('dispute', dispute);

        //disputeItems
        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', '1111');
        disputeItem.put('dispute_id', disputeId);
        disputeItem.put('type', 'Rent');
        disputeItem.put('claimed_landlord', '1000');

        Map<String,Object> disputeItem1 = disputeItem.clone();
        disputeItem.put('id', '2222');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem1});

        //tenant
        Map<String,Object> tenant = new Map<String, Object>();
        tenant.put('id', '1111');
        tenant.put('firstname', 'tester');
        tenant.put('lastname', 'testing');
        tenant.put('email', 'test@test.com');
        payloadObject.put('tenant', new List<Object>{tenant});

        //evidence
        Map<String,Object> evidence = new Map<String, Object>();
        evidence.put('id', '1111');
        evidence.put('dispute_id', disputeId);
        evidence.put('filename', 'evidence1.txt');
        evidence.put('uploader_type', 'Landlord');
        evidence.put('file_url', 'https://test/evidence1.txt');
        payloadObject.put('evidence', new List<Object>{evidence});

        //tenancy
        Map<String,Object> tenancy = new Map<String, Object>();
        tenancy.put('id', tenancyId);
        tenancy.put('reference', '1111');
        tenancy.put('customer_id', landlordId);
        tenancy.put('customer_type', 'Landlord');
        tenancy.put('postcode', '12345');
        tenancy.put('street', 'Baker');
        tenancy.put('city', 'London');
        tenancy.put('country', 'UK');
        tenancy.put('deposit_amount', '1000');
        tenancy.put('start_date', '2019-12-23T17:59:32.000+0000');
        tenancy.put('end_date', '2019-12-23T17:59:32.000+0000');
        payloadObject.put('tenancy', tenancy);

        //landlord
        Map<String,Object> landlord = new Map<String, Object>();
        landlord.put('id', landlordId);
        landlord.put('firstname', 'tester');
        landlord.put('lastname', 'testing');
        landlord.put('email', 'test@test.com');
        payloadObject.put('landlord', landlord);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(payloadObject));
        req.requestURI = 'https://disputeApiTest';
        req.httpMethod = FC_Constant.HTTP_POST_METHOD;

        String accessToken = accountId + '-' + timestamp + '-' + hmac;
        req.headers.put('accessToken',accessToken);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        FC_DisputeAPI_V1.postDispute();
        Test.stopTest();

        try {
            FC_DisputeAPI_V1.SuccessResponse response = (FC_DisputeAPI_V1.SuccessResponse) JSON.deserializeStrict(RestContext.response.responseBody.toString(), FC_DisputeAPI_V1.SuccessResponse.class);
            System.assertEquals(1, [SELECT count() FROM Case WHERE Id = :response.tds_dispute_id]);
            System.assertEquals(2, [SELECT count() FROM Dispute_Item__c]);
            System.assertEquals(1, [SELECT count() FROM Property__c]);
            System.assertEquals(1, [SELECT count() FROM Deposit__c]);
            System.assertEquals(2, [SELECT count() FROM Deposit_Allocation__c]);
            System.assertEquals(2, [SELECT count() FROM Case_Participant__c]);
            System.assertEquals(1, [SELECT count() FROM Evidence_Attachment__c]);
            System.assertEquals(1, [SELECT count() FROM Account WHERE RecordType.DeveloperName = :FC_Constant.RecordType_Account_Individual_Landlord AND Region__c = :FC_Constant.Region_England_And_Wales]);
            System.assertEquals(1, [SELECT count() FROM Account WHERE RecordType.DeveloperName = :FC_Constant.RecordType_Account_Tenant AND Region__c = :FC_Constant.Region_England_And_Wales]);
        }
        catch (Exception exc) {
            System.assert(false, 'This request should generate the entire dispute structure and not throw any exceptions');
        }
        System.assert(true);
    }

    @SuppressWarnings('PMD.NcssMethodCount')
    @IsTest
    static void testDisputeV1Strategy_negative() {
        Map<String,Object> payloadObject = new Map<String, Object>();

        String disputeId = 'disputeId1';
        String tenancyId = 'tenancyId1';
        String landlordId = 'landlordId1';

        //dispute
        Map<String,Object> dispute = new Map<String, Object>();
        dispute.put('id', disputeId);
        dispute.put('total_claim_amount', '1000');
        dispute.put('deposit_owner_id',landlordId);
        dispute.put('lead_landlord_id',landlordId);
        dispute.put('disputed_amount', '1000');
        dispute.put('tenancy_id', tenancyId);
        //  spoof in an invalid value for picklist field
        dispute.put('initiated_by', 'invalidValue');
        payloadObject.put('dispute', dispute);

        //disputeItems
        Map<String,Object> disputeItem = new Map<String, Object>();
        disputeItem.put('id', '1111');
        disputeItem.put('dispute_id', disputeId);
        disputeItem.put('type', 'Rent');
        disputeItem.put('claimed_landlord', '1000');

        Map<String,Object> disputeItem1 = disputeItem.clone();
        disputeItem.put('id', '2222');
        payloadObject.put('dispute_line', new List<Object>{disputeItem,disputeItem1});

        //tenant
        Map<String,Object> tenant = new Map<String, Object>();
        tenant.put('id', '1111');
        tenant.put('firstname', 'tester');
        tenant.put('lastname', 'testing');
        tenant.put('email', 'test@test.com');
        payloadObject.put('tenant', new List<Object>{tenant});

        //evidence
        Map<String,Object> evidence = new Map<String, Object>();
        evidence.put('id', '1111');
        evidence.put('dispute_id', disputeId);
        evidence.put('filename', 'evidence1.txt');
        evidence.put('uploader_type', 'Landlord');
        evidence.put('file_url', 'https://test/evidence1.txt');
        payloadObject.put('evidence', new List<Object>{evidence});

        //tenancy
        Map<String,Object> tenancy = new Map<String, Object>();
        tenancy.put('id', tenancyId);
        tenancy.put('reference', '1111');
        tenancy.put('customer_id', landlordId);
        tenancy.put('customer_type', 'Landlord');
        tenancy.put('postcode', '12345');
        tenancy.put('street', 'Baker');
        tenancy.put('city', 'London');
        tenancy.put('country', 'UK');
        tenancy.put('deposit_amount', '1000');
        tenancy.put('start_date', '2019-12-23T17:59:32.000+0000');
        tenancy.put('end_date', '2019-12-23T17:59:32.000+0000');
        payloadObject.put('tenancy', tenancy);

        //landlord
        Map<String,Object> landlord = new Map<String, Object>();
        landlord.put('id', landlordId);
        landlord.put('firstname', 'tester');
        landlord.put('lastname', 'testing');
        landlord.put('email', 'test@test.com');
        payloadObject.put('landlord', landlord);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(payloadObject));
        req.requestURI = 'https://disputeApiTest';
        req.httpMethod = FC_Constant.HTTP_POST_METHOD;

        String accessToken = accountId + '-' + timestamp + '-' + hmac;
        req.headers.put('accessToken',accessToken);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        FC_DisputeAPI_V1.postDispute(); 
        Test.stopTest();

        FC_DisputeAPI_V1.ErrorResponse response = (FC_DisputeAPI_V1.ErrorResponse) JSON.deserializeStrict(RestContext.response.responseBody.toString(), FC_DisputeAPI_V1.ErrorResponse.class);
        System.assertNotEquals(null, response);
        System.assert(!response.success);
        System.assertNotEquals(null, response.errors);
        System.assertEquals('Invalid value \'invalidValue\' for dispute.initiated_by', response.errors);
    }
}