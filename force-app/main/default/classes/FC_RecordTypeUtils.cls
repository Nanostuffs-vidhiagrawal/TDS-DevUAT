/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what A utility class to get Record Type Id and Record Type Name
 *
 * @when 17/12/2019
 */
public with sharing class FC_RecordTypeUtils {

    private static Map<SObjectType, Map<String,Schema.RecordTypeInfo>>   mapRecordTypeByName = new Map<SObjectType, Map<String,Schema.RecordTypeInfo>>();
    private static Map<SObjectType, Map<Id, Schema.RecordTypeInfo>>      mapRecordTypeById   = new Map<SObjectType, Map<Id, Schema.RecordTypeInfo>>();

    public static void getSObjectAllAvailableRecordTypes(Schema.SObjectType sObjType){
        Schema.DescribeSObjectResult sObjSchemaResult = sObjType.getDescribe();
        List<Schema.RecordTypeInfo> lstRecordTypeInfos = sObjSchemaResult.getRecordTypeInfos();
    }

    private static void init(Schema.SObjectType sObjType) {
        if (!mapRecordTypeByName.containsKey(sObjType) || !mapRecordTypeById.containsKey(sObjType)) {
            Schema.DescribeSObjectResult d = sObjType.getDescribe();
            mapRecordTypeByName.put(sObjType, d.getRecordTypeInfosByDeveloperName());
            mapRecordTypeById.put(sObjType, d.getRecordTypeInfosById());
        }
    }

    public static Id getRecordTypeIdByDeveloperName(Schema.SObjectType sObjType, String sRecordTypeName){
        init(sObjType);
        if (mapRecordTypeByName.get(sObjType).containsKey(sRecordTypeName)) {
            Schema.RecordTypeInfo rtInfo = mapRecordTypeByName.get(sObjType).get(sRecordTypeName);
            return rtInfo.getRecordTypeId();
        }
        throw new RecordTypeException('Wrong RecordType DeveloperName provided ' + sRecordTypeName + ' for object ' + sObjType.getDescribe().getName());
    }

    public static String getRecordTypeDeveloperNameById(Schema.SObjectType sObjType, Id recordTypeId) {
        init(sObjType);
        if (mapRecordTypeById.get(sObjType).containsKey(recordTypeId)) {
            Schema.RecordTypeInfo rtInfo =  mapRecordTypeById.get(sObjType).get(recordTypeId);
            return rtInfo.getDeveloperName();
        }
        throw new RecordTypeException('Wrong RecordType Id provided' + recordTypeId + ' for object ' + sObjType.getDescribe().getName());
    }
    
    private class RecordTypeException extends Exception{}
}