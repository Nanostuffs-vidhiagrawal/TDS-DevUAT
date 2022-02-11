/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_SpringCMShareLinksQueueable
 *
 * @when 04/02/2020
 */
@IsTest
public with sharing class FC_SpringCMShareLinksQueueableTest {
    public static Integer NUMBER_OF_RECORDS_TO_TEST = 20;
    @TestSetup
    static void setup() {
        Account dummyAccount = (Account) FC_TestFactory.createSObject(new Account(), true);
        SlaProcess slaProcess = [SELECT Id FROM SlaProcess WHERE Name = 'EW Disputes' AND IsVersionDefault = true LIMIT 1];
        Entitlement entitlement = (Entitlement) FC_TestFactory.createSObject(
                new Entitlement(AccountId = dummyAccount.Id, SlaProcessId = slaProcess.Id),
                'FC_TestFactoryDefaults.EntitlementDefaults', true);
        List<Case> disputes = FC_TestFactory.createSObjectList(
                new Case(Status = FC_Constant.Case_Status_Review_Complete),
                NUMBER_OF_RECORDS_TO_TEST, 'FC_TestFactoryDefaults.CaseDefaults', true);

        List<Adjudication_Report__c> adjudicationReports = new List<Adjudication_Report__c>();
        for(Case dispute : [SELECT Id FROM Case]) {
            Adjudication_Report__c report = (Adjudication_Report__c)FC_TestFactory.createSObject(
                    new Adjudication_Report__c(Dispute__c = dispute.Id));
            adjudicationReports.add(report);
        }
        insert adjudicationReports;
        FC_TestFactory.createSObject(new SpringCM_Settings__c(), 'FC_TestFactoryDefaults.SpringCMSettingsDefaults', true);
    }

    @IsTest
    static void testAdjudicationReportPublished_Published() {
        List<Adjudication_Report__c> adjudicationReports = [SELECT Id FROM Adjudication_Report__c];
        for(Adjudication_Report__c report : adjudicationReports) {
            report.Adjudication_Report_URL__c = 'https://test.com';
        }

        Test.setMock(HttpCalloutMock.class, new FC_SpringCMCalloutMock.ShareLinksSuccessMock());
        Test.startTest();
        update adjudicationReports;
        Test.stopTest();

        //only 1 batch will be fired in tests context
        System.assertEquals(FC_SpringCMShareLinksQueueable.BATCH_SIZE, [SELECT count() FROM Adjudication_Report__c WHERE Webhook_Report_Link__c = 'https://test.com']);
    }

    @IsTest
    static void testAdjudicationReportPublished_Published_few_records() {
        List<Adjudication_Report__c> adjudicationReports = [SELECT Id FROM Adjudication_Report__c LIMIT 5];
        for(Adjudication_Report__c report : adjudicationReports) {
            report.Adjudication_Report_URL__c = 'https://test.com';
        }

        Test.setMock(HttpCalloutMock.class, new FC_SpringCMCalloutMock.ShareLinksSuccessMock());
        Test.startTest();
        update adjudicationReports;
        Test.stopTest();

        System.assertEquals(5, [SELECT count() FROM Adjudication_Report__c WHERE Webhook_Report_Link__c = 'https://test.com']);
    }
}