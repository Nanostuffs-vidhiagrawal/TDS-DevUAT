/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Wrapper class for disputeMappings - singleton implementation. Used by many parts of the process.
 * Provides utility methods for mappings queried from database
 *
 * @when 12/12/2019
 */
public with sharing class FC_DisputeAPI_MappingsWrapper {
    private static FC_DisputeAPI_MappingsWrapper mappingsWrapperInstance;
    private List<Dispute_API_Object__c> objects;
    private Map<String,Dispute_API_Object__c> mappingsByPayloadObjectName {
        get {
            if(mappingsByPayloadObjectName == null) {
                mappingsByPayloadObjectName = new Map<String,Dispute_API_Object__c>();
                for(Dispute_API_Object__c obj : objects) {
                    mappingsByPayloadObjectName.put(obj.Name, obj);
                }
            }
            return mappingsByPayloadObjectName;
        }
        set;
    }
    private Set<String> payloadObjects;
    private Set<String> requiredPayloadObjects;
    /**
     * Private constructor
     */
    private FC_DisputeAPI_MappingsWrapper() {
        objects =  [
                SELECT Id, Name, isRequired__c, Object_Type__c,
                        (SELECT Id, Salesforce_Field_API_Name__c, Payload_Parameter_Name__c, Salesforce_Field_Length__c,
                            Salesforce_Field_Type__c, isRequired__c, SObject_Name__c, Dispute_API_Object__r.Name
                        FROM Dispute_API_Mappings__r
                        WHERE isActive__c = true)
                FROM Dispute_API_Object__c
                WHERE isActive__c = true
        ];
    }
    /**
     * Singleton instance getter
     *
     * @return FC_DisputeAPI_MappingsWrapper instance
     */
    public static FC_DisputeAPI_MappingsWrapper getInstance() {
        if(mappingsWrapperInstance == null) {
            mappingsWrapperInstance = new FC_DisputeAPI_MappingsWrapper();
        }
        return mappingsWrapperInstance;
    }
    /**
     * Get all payload object names in lower case
     *
     * @return Payload object names in lower case
     */
    public Set<String> getPayloadObjects() {
        if(payloadObjects == null) {
            payloadObjects = new Set<String>();
            for(Dispute_API_Object__c obj : objects) {
                payloadObjects.add(obj.Name.toLowerCase());
            }
        }
        return payloadObjects;
    }
    /**
     * Get only required payload object names in lower case
     *
     * @return Required payload object names in lower case
     */
    public Set<String> getRequiredPayloadObjects() {
        if(requiredPayloadObjects == null) {
            requiredPayloadObjects = new Set<String>();
            for(Dispute_API_Object__c obj : objects) {
                if(obj.isRequired__c) {
                    requiredPayloadObjects.add(obj.Name.toLowerCase());
                }
            }
        }
        return requiredPayloadObjects;
    }
    /**
     * Get all payload object parameters in lower case
     *
     * @param objectName Payload object name
     *
     * @return Payload object parameters in lower case
     */
    public Set<String> getAllPayloadParametersForObject(String objectName) {
        return getMappingsByPayloadParameter(objectName, false).keySet();
    }
    /**
     * Get required payload object parameters in lower case
     *
     * @param objectName Payload object name
     *
     * @return Required payload object parameters set in lower case
     */
    public Set<String> getRequiredPayloadParametersForObject(String objectName) {
        return getMappingsByPayloadParameter(objectName, true).keySet();
    }
    /**
     * Get mappings related to payload object 
     *
     * @param objectName Payload object name
     *
     * @return Dispute_API_Mapping__c by payload parameter name
     */
    public Map<String,Dispute_API_Mapping__c> getMappingsByPayloadParameter(String objectName) {
        return getMappingsByPayloadParameter(objectName, false);
    }
    /**
     * Get related Dispute_API_Object__c for payload object name
     *
     * @param objectName Payload object name
     *
     * @return Dispute_API_Object__c
     */
    public Dispute_API_Object__c getDisputeApiObject(String objectName) {
        return mappingsByPayloadObjectName.get(objectName);
    }
    /**
     * Helper method for getting payload object parameters
     *
     * @param objectName Payload object name
     * @param requiredOnly
     *
     * @return Dispute_API_Mapping__c by payload parameter name
     */
    private Map<String,Dispute_API_Mapping__c> getMappingsByPayloadParameter(String objectName, Boolean requiredOnly) {
        Map<String,Dispute_API_Mapping__c> payloadParametersMap = new Map<String,Dispute_API_Mapping__c>();
        for(Dispute_API_Mapping__c mapping : mappingsByPayloadObjectName.get(objectName).Dispute_API_Mappings__r) {
            if(!requiredOnly || (requiredOnly && mapping.isRequired__c)) {
                payloadParametersMap.put(mapping.Payload_Parameter_Name__c.toLowerCase(),mapping);
            }
        }
        return payloadParametersMap;
    }
}