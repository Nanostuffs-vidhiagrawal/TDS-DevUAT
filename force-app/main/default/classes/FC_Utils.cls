/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Utility class for the project
 *
 * @when 31/10/2019
 */
public with sharing class FC_Utils {
    private static Map<String, RecordTypeInfo> caseRecordTypeInfoMap {
        get {
            if (caseRecordTypeInfoMap == null) {
                caseRecordTypeInfoMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
            }
            return caseRecordTypeInfoMap;
        }
        set;
    }
    private static Map<Id, String> caseRecordTypeByIdMap {
        get {
            if (caseRecordTypeByIdMap == null) {
                caseRecordTypeByIdMap = new Map<Id, String>();
                for (RecordTypeInfo rti : caseRecordTypeInfoMap.values()) {
                    caseRecordTypeByIdMap.put(rti.getRecordTypeId(), rti.getDeveloperName());
                }
            }
            return caseRecordTypeByIdMap;
        }
        set;
    }
    private static Set<Id> disputeCaseRecordTypeIds;
    private static Boolean isRunningOnSandbox;

    /**
     * Get Records Type Ids of Case related to Dispute (Record Type Name starts with 'dispute')
     *
     * @return
     */
    public static Set<Id> getDisputeCaseRecordTypeIds() {
        if (disputeCaseRecordTypeIds == null) {
            disputeCaseRecordTypeIds = new Set<Id>();
            for (String recordTypeName : caseRecordTypeInfoMap.keySet()) {
                if (recordTypeName.startsWithIgnoreCase('dispute')) {
                    disputeCaseRecordTypeIds.add(caseRecordTypeInfoMap.get(recordTypeName).getRecordTypeId());
                }
            }
        }
        return disputeCaseRecordTypeIds;
    }
    /**
     * Get list of Ids of SObjects from the input sObject list
     *
     * @param sObjects
     *
     * @return
     */
    public static List<Id> pluckIds(List<SObject> sObjects) {
        return new List<Id>(pluckIdsSet(sObjects));
    }
    /**
     * Get set of Ids of SObjects from the input sObject list
     *
     * @param sObjects
     *
     * @return
     */
    public static Set<Id> pluckIdsSet(List<SObject> sObjects) {
        return new Map<Id, SObject>(sObjects).keySet();
    }
    /**
     * Get list of ids of a field from SObject list  
     * Example:
     * pluckIdFieldsSet(casesList, 'AccountId') will get set of Ids related to Cases 
     *
     * @param sObjects
     * @param fieldName
     *
     * @return
     */
    public static List<Id> pluckIdFields(List<SObject> sObjects, String fieldName) {
        return new List<Id>(pluckIdFieldsSet(sObjects, fieldName));
    }
    /**
     * Get set of ids of a field from SObject list  
     * Example:
     * pluckIdFieldsSet(casesList, 'AccountId') will get set of Ids related to Cases 
     *
     * @param sObjects
     * @param fieldName
     *
     * @return
     */
    public static Set<Id> pluckIdFieldsSet(List<SObject> sObjects, String fieldName) {
        Set<Id> ids = new Set<Id>();
        for (SObject sObj : sObjects) {
            if(sObj.get(fieldName)!= null) {
                ids.add((Id) sObj.get(fieldName));
            }
        }
        return ids;
    }
    /**
     * Generate random string of specified length
     *
     * @param stringLength
     *
     * @return
     */
    public static String generateRandomString(Integer stringLength) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < stringLength) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    /**
     * Generate hmac key for input and key using specified MAC encryption method
     *
     * @param macEncryption
     * @param input
     * @param key
     *
     * @return
     */
    public static String generateHMACKey(String macEncryption, String input, String key){
        Blob keyBlob = Blob.valueof(key);
        Blob inputBlob = Blob.valueOf(input);
        Blob mac = Crypto.generateMac(macEncryption, inputBlob, keyBlob);
        String token = EncodingUtil.convertToHex(mac);
        return token;
    }
    /**
     * Get information whether the organization is a sandbox instance 
     *
     * @return true for sandbox, false for production
     */
    public static Boolean isRunningOnSandbox() {
        if(isRunningOnSandbox == null) {
            isRunningOnSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        }
        return isRunningOnSandbox;
    }
    /**
     * Helper method - Returns set in lower case to easily operate on the sets 
     *
     * @param inputSet
     *
     * @return
     */
    public static Set<String> toLowerCase(Set<String> inputSet) {
        Set<String> outputSet = new Set<String>();
        for(String inputValue : inputSet) {
            outputSet.add(inputValue.toLowerCase());
        }
        return outputSet;
    }
}