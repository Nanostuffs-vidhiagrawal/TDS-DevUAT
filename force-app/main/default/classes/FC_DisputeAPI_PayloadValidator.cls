/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Processing validation of payload for Dispute API
 *
 * @when 10/12/2019
 */
public with sharing class FC_DisputeAPI_PayloadValidator {
    private FC_DisputeAPI_MappingsWrapper mappings; 
    private String payload;
    /**
     * Public constructor
     *
     * @param payload
     */
    public FC_DisputeAPI_PayloadValidator(String payload) {
        this.payload = payload;
    }
    /**
     * Performs payload validation step by step
     *
     * @return Deserialized payload
     */
    public Map<String, Object> validate() {
        Map<String, Object> deserializedPayload = deserializePayload(payload);
        Set<String> payloadObjectNamesLowerCase = FC_Utils.toLowerCase(deserializedPayload.keySet());
        mappings = FC_DisputeAPI_MappingsWrapper.getInstance();
        validatePayloadObjects(payloadObjectNamesLowerCase);
        validateRequiredPayloadObjects(payloadObjectNamesLowerCase);
        validatePayloadObjectTypes(deserializedPayload);
        validatePayloadObjectParameters(deserializedPayload);
        return deserializedPayload;
    }
    /**
     * Applies the payload untyped deserialization to validate JSON 
     *
     * @param payload
     *
     * @return Deserialized payload
     */
    private Map<String, Object> deserializePayload(String payload) {
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(payload);
        }
        catch(Exception exc) {
            throw new FC_DisputeAPI_Exception.JSONException('Invalid payload.');
        }
    }
    /**
     * Validates the payload object names against the mappings. Throws correct exception type in the process.
     *
     * @param payloadObjectNames
     */
    private void validatePayloadObjects(Set<String> payloadObjectNames) {
        Set<String> payloadObjectNamesToCheck = payloadObjectNames.clone();
        payloadObjectNamesToCheck.removeAll(mappings.getPayloadObjects());
        
        if(payloadObjectNamesToCheck.size() > 0) {
            throw new FC_DisputeAPI_Exception.PayloadException('Invalid Objects: '
                    + String.join(new List<String>(payloadObjectNamesToCheck), ','));
        }
    }
    /**
     * Validates required payload object names against the mapping. Throws correct exception type in the process.
     *
     * @param payloadObjectNames
     */
    private void validateRequiredPayloadObjects(Set<String> payloadObjectNames) {
        Set<String> requiredObjects = mappings.getRequiredPayloadObjects();
        requiredObjects.removeAll(payloadObjectNames);

        if(requiredObjects.size() > 0) {
            throw new FC_DisputeAPI_Exception.PayloadException('Missing required Objects: '
                    + String.join(new List<String>(requiredObjects), ','));
        }
    }
    /**
     * Validates payload object type (single object / array) against the mapping. 
     * Throws correct exception type in the process.
     *
     * @param deserializedPayload
     */
    private void validatePayloadObjectTypes(Map<String, Object> deserializedPayload) {
        List<String> errorObjects = new List<String>();
        List<String> missingRequiredListElements = new List<String>();
        for(String payloadObjectName : deserializedPayload.keySet()) {
            Object payloadObject = deserializedPayload.get(payloadObjectName);
            String errorObject = validatePayloadObjectType(payloadObject, mappings.getDisputeApiObject(payloadObjectName));
            if(errorObject != null) {
                errorObjects.add(errorObject);
            }
            if(payloadObject instanceof List<Object>) {
                missingRequiredListElements.addAll(getMissingRequiredListRecords(payloadObjectName, (List<Object>)payloadObject));
            }
        }
        if(!errorObjects.isEmpty()) {
            throw new FC_DisputeAPI_Exception.PayloadException('Invalid type for objects: ' + String.join(errorObjects,','));
        }
        else if(!missingRequiredListElements.isEmpty()) {
            throw new FC_DisputeAPI_Exception.PayloadException(String.join(new List<String>(missingRequiredListElements), ',') + ' - lists can not be empty');
        }
    }
    /**
     * Validates invalid and missing required payload object parameters 
     *
     * @param deserializedPayload
     */
    private void validatePayloadObjectParameters(Map<String, Object> deserializedPayload) {
        List<String> errors = new List<String>();

        for(String payloadObjectName : deserializedPayload.keySet()) {
            Object payloadObject = deserializedPayload.get(payloadObjectName);
            
            Set<String> invalidParameters = new Set<String>();
            Set<String> missingRequiredParameters = new Set<String>();
            List<Map<String,Object>> payloadObjectRecords = getPayloadObjectRecords(payloadObject);
            for(Map<String,Object> payloadObjectRecord : payloadObjectRecords) {
                invalidParameters.addAll(getInvalidParameters(payloadObjectName, payloadObjectRecord));
                missingRequiredParameters.addAll(getMissingRequiredParameters(payloadObjectName, payloadObjectRecord));
            }

            if(invalidParameters.size() > 0) {
                errors.add('Invalid parameters: ' + String.join(new List<String>(invalidParameters), ',') + ' for object ' + payloadObjectName);
            }
            else if(missingRequiredParameters.size() > 0) {
                errors.add('Missing required parameters: ' + String.join(new List<String>(missingRequiredParameters), ',') + ' for object ' + payloadObjectName);
            }
            
            if(!errors.isEmpty()) {
                throw new FC_DisputeAPI_Exception.PayloadException(String.join(errors,'; '));
            }
        }
    }
    /**
     * Helper method - get invalid payload object parameters
     *
     * @param payloadObjectName
     * @param payloadObjectRecord
     *
     * @return
     */
    private List<String> getInvalidParameters(String payloadObjectName, Map<String,Object> payloadObjectRecord) {
        Set<String> payloadParametersCaseInsensitive = FC_Utils.toLowerCase(payloadObjectRecord.keySet());
        Set<String> mappingAllPayloadParameters = mappings.getAllPayloadParametersForObject(payloadObjectName);

        payloadParametersCaseInsensitive.removeAll(mappingAllPayloadParameters);
        return new List<String>(payloadParametersCaseInsensitive);
    }
    /**
     * Helper method - get missing required payload object parameters
     *
     * @param payloadObjectName
     * @param payloadObjectRecord
     *
     * @return
     */
    private List<String> getMissingRequiredParameters(String payloadObjectName, Map<String,Object> payloadObjectRecord) {
        List<String> missingRequiredParameters = new List<String>();
        Set<String> requiredParametersForObject = mappings.getRequiredPayloadParametersForObject(payloadObjectName);
        
        for(String requiredParameterName : requiredParametersForObject) {
            if(!payloadObjectRecord.keySet().contains(requiredParameterName)) {
                missingRequiredParameters.add(requiredParameterName);
            }
        }
        return missingRequiredParameters;
    }
    /**
     * Helper method - get missing required list elements
     *
     * @param payloadObjectName
     * @param payloadObjectList
     *
     * @return
     */
    private List<String> getMissingRequiredListRecords(String payloadObjectName, List<Object> payloadObjectList) {
        List<String> missingRequiredListElements = new List<String>();
        Dispute_API_Object__c disputeAPIObject = mappings.getDisputeApiObject(payloadObjectName);

        if(disputeAPIObject.isRequired__c && disputeAPIObject.Object_Type__c == 'Array' && payloadObjectList.isEmpty()) {
            missingRequiredListElements.add(payloadObjectName);
        }
        return missingRequiredListElements;
    }
    /**
     * Helper method - retuns object name if its type does not match the mapping specified type (single object / array)
     *
     * @param payloadObject
     * @param disputeAPIObject
     *
     * @return
     */
    private static String validatePayloadObjectType(Object payloadObject, Dispute_API_Object__c disputeAPIObject) {
        if(payloadObject instanceof List<Object> && disputeAPIObject.Object_Type__c != 'Array'
                || !(payloadObject instanceof List<Object>) && disputeAPIObject.Object_Type__c != 'Object') {
            return disputeAPIObject.Name;
        }
        return null;
    }
    /**
     * Helper method - returns the list of payload object records. 
     * Adds all the array elements to list if payload object is array. 
     * Adds single object to returned list if payload object is single object.
     *
     * @param payloadObject
     *
     * @return List of payload object records 
     */
    public static List<Map<String,Object>> getPayloadObjectRecords(Object payloadObject) {
        List<Map<String,Object>> payloadObjectRecords = new List<Map<String,Object>>();
        if(payloadObject instanceof List<Object>) {
            for(Object obj : (List<Object>)payloadObject) {
                payloadObjectRecords.add((Map<String,Object>)obj);
            }
        }
        else {
            payloadObjectRecords.add((Map<String,Object>)payloadObject);
        }
        return payloadObjectRecords;
    }
}