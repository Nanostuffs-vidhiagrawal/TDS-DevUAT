/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Handler class model for Dispute API Mapping
 *
 * @when 06/12/2019
 */
public with sharing class FC_DisputeAPIMappingHandler {
    public class BulkDisputeAPIMappingHandler {
        /**
         * Handles bulk Dispute API Mapping coming from onBeforeInsert OnBeforeUpdate trigger event
         * @param newList
         * @param oldMap
         */
        public void handleFieldMetadata(List<Dispute_API_Mapping__c> newMappings, Map<Id, Dispute_API_Mapping__c> oldMap) {
            List<Dispute_API_Mapping__c> mappingsToUpdate = new List<Dispute_API_Mapping__c>();
            for(Dispute_API_Mapping__c mapping : newMappings) {
                Dispute_API_Mapping__c oldMapping = oldMap == null ? null : oldMap.get(mapping.Id);
                if(requiresFieldMetadataUpdate(mapping, oldMapping)) {
                    mappingsToUpdate.add(mapping);
                }
            }
            
            if(!mappingsToUpdate.isEmpty()) {
                setMetadataForMappings(mappingsToUpdate);
            }
        }

        private Boolean requiresFieldMetadataUpdate(Dispute_API_Mapping__c mapping, Dispute_API_Mapping__c oldMapping){
            return oldMapping == null ? true :
                    mapping.SObject_Name__c == oldMapping.SObject_Name__c || mapping.Salesforce_Field_API_Name__c == oldMapping.Salesforce_Field_API_Name__c
                    || mapping.isActive__c == oldMapping.isActive__c || mapping.isRequired__c == oldMapping.isRequired__c;
        }
    }
    /**
     * Performs the basic validation of SObject and field name, gets the field type / length from describe 
     *
     * @param mappings
     */
    private static void setMetadataForMappings(List<Dispute_API_Mapping__c> mappings) {
        Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();
        
        Set<String> existingMappingKeys = new Set<String>();
        for(Dispute_API_Mapping__c mapping : [SELECT Dispute_API_Object__r.Name, Payload_Parameter_Name__c FROM Dispute_API_Mapping__c]) {
            existingMappingKeys.add(getPayloadKey(mapping));
        }
        
        for(Dispute_API_Mapping__c mapping : mappings) {
            if(!mapping.isActive__c) {
                continue;
            }
            
            try {
                String sObjectName = mapping.SObject_Name__c;
                String fieldName = mapping.Salesforce_Field_API_Name__c;

                if(sObjectName == null && fieldName == null) {
                    continue;    
                }

                mapping.Salesforce_Field_Type__c = null;
                mapping.Salesforce_Field_Length__c = null;
                
                if(sObjectName == null || fieldName == null) {
                    throw new MappingException('SObject Name or Salesforce Field API Name missing');
                }

                SObjectType sObjectType = globalDescribe.get(sObjectName.toLowerCase());
                if(sObjectType == null) {
                    mapping.addError('Wrong SObject Name provided');
                    continue;
                }
                
                Map<String, Schema.SObjectField> sObjectFieldMap = sObjectType.getDescribe().Fields.getMap();
                Schema.SObjectField sObjectField = sObjectFieldMap.get(fieldName);

                if(sObjectField == null) {
                    mapping.addError('Wrong Salesforce Field Name provided');
                    continue;
                }
                
                if(existingMappingKeys.contains(getPayloadKey(mapping))) {
                    mapping.addError('Payload key already exists in mappings');
                    continue;
                }

                DescribeFieldResult describeFieldResult = sObjectField.getDescribe();

                if(!mapping.isRequired__c && !describeFieldResult.isNillable()) {
                    mapping.addError('Field is universally required in Salesforce, please mark it as required');
                    continue;
                }
                
                mapping.Salesforce_Field_Type__c = describeFieldResult.getType() == DisplayType.PICKLIST ? String.valueOf(DisplayType.PICKLIST) :
                        String.valueOf(describeFieldResult.getSoapType());
                mapping.Salesforce_Field_Length__c = (mapping.Salesforce_Field_Type__c.equalsIgnoreCase('DOUBLE') || mapping.Salesforce_Field_Type__c.equalsIgnoreCase('INTEGER'))
                        ? describeFieldResult.getPrecision() : describeFieldResult.getLength();
                
            }
            catch(Exception e) {
                mapping.addError(e);
            }
        }
    }
    /**
     * Get payload key as concatenation of name and parameter
     *
     * @param mapping
     *
     * @return
     */
    private static String getPayloadKey(Dispute_API_Mapping__c mapping) {
        return (mapping.Dispute_API_Object__r.Name + '.' + mapping.Payload_Parameter_Name__c).toLowerCase();
    }
    
    private class MappingException extends Exception{}
}