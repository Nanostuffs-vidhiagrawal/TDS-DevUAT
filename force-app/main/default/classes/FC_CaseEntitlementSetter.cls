/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Sets the correct entitlement for Case based on the value from custom settings
 *
 * @when 31/10/2019
 */
public without sharing class FC_CaseEntitlementSetter {
    /**
   * Sets the correct entitlement for Case based on the value from custom settings
   * @param newCases List of cases to be affected
   */
    public static void setEntitlementForCase(List<Case> newCases){
        for(Case c : newCases) {
            String recordTypeDeveloperName = FC_RecordTypeUtils.getRecordTypeDeveloperNameById(Case.SObjectType,c.RecordTypeId);
            String entitlementName = recordTypeToEntitlementMap.get(recordTypeDeveloperName);
            Id entitlementId = entitlementIdByName.get(entitlementName);
            c.EntitlementId = entitlementId;
        }
    }

    private static Map<String,Id> entitlementIdByName  {
        get {
            if(entitlementIdByName == null) {
                entitlementIdByName = new Map<String, Id>();
                List<Entitlement> entitlements = [
                        SELECT Id, Name
                        FROM Entitlement
                        WHERE Name IN : recordTypeToEntitlementMap.values()];

                for(Entitlement entitlement : entitlements) {
                    entitlementIdByName.put(entitlement.Name,entitlement.Id);
                }
            }
            return entitlementIdByName;
        }
        set;
    }

    private static Map<String,String> recordTypeToEntitlementMap {
        get {
            if(recordTypeToEntitlementMap == null) {
                recordTypeToEntitlementMap = new Map<String,String>();

                Boolean isTest = Test.isRunningTest();
                RecordType_to_Entitlement__mdt[] recordTypeToEntitlementsMetadata = [
                        SELECT Record_Type_Name__c, Entitlement_Name__c
                        FROM RecordType_to_Entitlement__mdt
                        WHERE IsTest__c = :isTest
                ];

                for(RecordType_to_Entitlement__mdt recTypeToEntitlement : recordTypeToEntitlementsMetadata) {
                    recordTypeToEntitlementMap.put(recTypeToEntitlement.Record_Type_Name__c, recTypeToEntitlement.Entitlement_Name__c);
                }
            }
            return recordTypeToEntitlementMap;
        }
        set;
    }

}