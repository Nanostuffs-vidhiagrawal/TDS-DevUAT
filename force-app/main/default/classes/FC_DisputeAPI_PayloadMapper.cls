/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Processing mapping of payload for Dispute API
 *
 * @when 12/12/2019
 */
public with sharing class FC_DisputeAPI_PayloadMapper {
    private API_Account__c apiAccount;
    private FC_DisputeAPI_MappingsWrapper mappings;
    private Map<String,Object> deserializedPayload;
    private Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();
    /**
     * Public constructor
     *
     * @param deserializedPayload
     * @param apiAccount
     */
    public FC_DisputeAPI_PayloadMapper(Map<String,Object> deserializedPayload, API_Account__c apiAccount) {
        this.deserializedPayload = deserializedPayload;
        this.apiAccount = apiAccount;
        this.mappings = FC_DisputeAPI_MappingsWrapper.getInstance();
    }
    /**
     * Performs the data mapping for the payload. Runs through all payload object types and payload parameters and maps
     * them to correct SObject types and SObject fields.
     * Runs the validation of types in the process
     *
     * @return Map of SObjects by Type by PayloadObject type
     */
    public Map<String,Map<SObjectType,List<SObject>>> processDataMapping() {
        Map<String,Map<SObjectType,List<SObject>>> sObjectByPayloadObjectName = new Map<String,Map<SObjectType,List<SObject>>>();
        List<String> errors = new List<String>();

        for(String payloadObjectName : deserializedPayload.keySet()) {
            Map<SObjectType,List<SObject>> sObjectsByType = sObjectByPayloadObjectName.get(payloadObjectName) != null ? 
                    sObjectByPayloadObjectName.get(payloadObjectName) : new Map<SObjectType,List<SObject>>();
            Map<String,Dispute_API_Mapping__c> mappingsByParameter = mappings.getMappingsByPayloadParameter(payloadObjectName);
            
            Object payloadObject = deserializedPayload.get(payloadObjectName);
            for(Map<String,Object> payloadObjectRecord : FC_DisputeAPI_PayloadValidator.getPayloadObjectRecords(payloadObject)) {
                try {
                    Map<SObjectType,SObject> mappedSingleRecords = processSingeRecord(payloadObjectRecord, mappingsByParameter);
                    for(SObjectType sObjectType : mappedSingleRecords.keySet()) {
                        List<SObject> sObjectsForType = sObjectsByType.get(sObjectType) != null ?
                                sObjectsByType.get(sObjectType) : new List<SObject>();
                        sObjectsForType.add(mappedSingleRecords.get(sObjectType));
                        sObjectsByType.put(sObjectType,sObjectsForType);
                    }
                    sObjectByPayloadObjectName.put(payloadObjectName,sObjectsByType);
                }
                catch(FC_DisputeAPI_Exception.PayloadException exc) {
                    errors.add(exc.getMessage());
                }
            }
        }
        if(!errors.isEmpty()) {
            throw new FC_DisputeAPI_Exception.PayloadException(String.join(errors,'; '));
        }
        return sObjectByPayloadObjectName;
    }
    /**
     * Processing of single record. Applies validation for field type and length and parses the input value to correct field type value 
     *
     * @param payloadObjectRecord
     * @param mappingsByParameter
     *
     * @return SObject by SObject type. For tenency this will return 2 keys - Deposit and Property
     */
    private Map<SObjectType, SObject> processSingeRecord(Map<String, Object> payloadObjectRecord, Map<String, Dispute_API_Mapping__c> mappingsByParameter) {
        Map<SObjectType, SObject> sObjectByType = new Map<SObjectType, SObject>();
        List<String> errors = new List<String>();

        for(String parameterName : payloadObjectRecord.keySet()) {
            Dispute_API_Mapping__c mapping = mappingsByParameter.get(parameterName);
            SObjectType sObjectType = globalDescribe.get(mapping.SObject_Name__c);
            if(sObjectType == null) {
                continue;
            }
            SObject sObjectInstance = sObjectByType.get(sObjectType) != null ?
                    sObjectByType.get(sObjectType) : sObjectType.newSObject();

            try {
                Object parsedValue = getParsedValue(payloadObjectRecord.get(parameterName), mapping);
                sObjectInstance.put(mapping.Salesforce_Field_API_Name__c, parsedValue);
            }
            catch(FC_DisputeAPI_Exception exc) {
                errors.add(exc.getMessage());
            }
            catch(Exception exc) {
                errors.add('Invalid field type for key ' + mapping.Dispute_API_Object__r.Name + '.' + mapping.Payload_Parameter_Name__c);
            }
            
            sObjectByType.put(sObjectType, sObjectInstance);
        }

        if(!errors.isEmpty()) {
            throw new FC_DisputeAPI_Exception.PayloadException(String.join(errors,'; '));
        }
        return sObjectByType;
    }
    /**
     * Parses the value to field type and performs length validation 
     *
     * @param value
     * @param mapping
     *
     * @return Parsed value of field
     */
    private Object getParsedValue(Object value, Dispute_API_Mapping__c mapping) {
        String stringValue = prependExternalIdWithApiAccountId(value, mapping);
        if(String.isEmpty(stringValue)) {
            throw new FC_DisputeAPI_Exception.InternalException('Parameter ' + mapping.Dispute_API_Object__r.Name + '.' + mapping.Payload_Parameter_Name__c + ' can not be blank');
        }

        switch on mapping.Salesforce_Field_Type__c {
            when 'PICKLIST' {
                validatePicklistValues(stringValue,mapping);
                return stringValue;
            }
            when 'STRING' {
                validateLength(stringValue,mapping);
                return stringValue;
            }
            when 'ID' {
                validateLength(stringValue,mapping);
                return stringValue;
            }
            when 'DOUBLE' {
                validateLength(stringValue,mapping);
                return Decimal.valueOf(stringValue);
            }
            when 'DATETIME' {
                return (Datetime)JSON.deserialize('"' + stringValue + '"',Datetime.class);
            }
            when 'DATE' {
                return Date.valueOf(stringValue);
            }
            when 'BOOLEAN' {
                return Boolean.valueOf(stringValue);
            }
            when 'INTEGER' {
                validateLength(stringValue,mapping);
                return Integer.valueOf(stringValue);
            }
            when else {
                throw new FC_DisputeAPI_Exception.InternalException('Type not supported');
            }
        }
    }
    /**
     * Field length validation for String / number fields
     *
     * @param stringValue
     * @param mapping
     */
    private void validateLength(String stringValue, Dispute_API_Mapping__c mapping) {
        if(stringValue.length() > mapping.Salesforce_Field_Length__c) {
            throw new FC_DisputeAPI_Exception.InternalException('Field is too long: ' + mapping.Payload_Parameter_Name__c);
        }
    }
    /**
     * Field length validation for String / number fields
     *
     * @param stringValue
     * @param mapping
     */
    private void validatePicklistValues(String stringValue, Dispute_API_Mapping__c mapping) {
        SObjectType sObjectType = globalDescribe.get(mapping.SObject_Name__c);

        if(String.isNotBlank(mapping.Salesforce_Field_API_Name__c)) {
            SObjectField sObjectField = sObjectType.getDescribe().Fields.getMap().get(mapping.Salesforce_Field_API_Name__c);
            Set<String> picklistValues = new Set<String>();
            for(PicklistEntry ple : sObjectField.getDescribe().getPicklistValues()) {
                picklistValues.add(ple.getValue());
            }
            if(!FC_Utils.toLowerCase(picklistValues).contains(stringValue.toLowerCase())) {
                throw new FC_DisputeAPI_Exception.InternalException('Invalid value \'' + stringValue + '\' for '
                        + mapping.Dispute_API_Object__r.Name + '.' + mapping.Payload_Parameter_Name__c);            
            }
        }
    }
    /**
     * Prepend the id fields with API Account Id so that external Ids are related to particular API consumer
     *
     * @param value
     * @param mapping
     *
     * @return
     */
    private String prependExternalIdWithApiAccountId(Object value, Dispute_API_Mapping__c mapping) {
        String stringValue = String.valueOf(value);
        //When mapping/extracting parameter includes 'id', always prepend it with 'AccountID-' value. i.e. 'id':'54' -> 'id':'ZeroDeposit-54'
        if(mapping.Payload_Parameter_Name__c.equalsIgnoreCase('id') || mapping.Payload_Parameter_Name__c.endsWithIgnoreCase('_id')) {
            stringValue = apiAccount.API_Account_Id__c + '-' + stringValue;
        } 
        return stringValue;
    }
}