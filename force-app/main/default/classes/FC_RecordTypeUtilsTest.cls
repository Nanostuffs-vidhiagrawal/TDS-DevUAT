/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Tests for FC_RecordTypeUtils
 *
 * @when 17/12/2019
 */
@IsTest
public with sharing class FC_RecordTypeUtilsTest {
    @IsTest
    static void testExistingAccountRecordTypes() {
        List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Account'];
        
        for(RecordType rt : recordTypes) {
            Id recordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType, rt.DeveloperName);
            System.assertEquals(recordTypeId, rt.Id);

            String recordTypeDevName = FC_RecordTypeUtils.getRecordTypeDeveloperNameById(Account.SObjectType, rt.Id);
            System.assertEquals(recordTypeDevName, rt.DeveloperName);
        }
    }

    @IsTest
    static void testExceptions() {
        try {
            Id recordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType, 'testBadRecordType');
            System.assert(false, 'Code should never reach this point');
        }
        catch(Exception e) {
            System.assert(true, 'Exception Occured');
        }
        
        try {
            String recordTypeDevName = FC_RecordTypeUtils.getRecordTypeDeveloperNameById(Account.SObjectType, '0128E000000U3r0ZZZ');
            System.assert(false, 'Code should never reach this point');
        }
        catch(Exception e) {
            System.assert(true, 'Exception Occured');
        }
    }
}