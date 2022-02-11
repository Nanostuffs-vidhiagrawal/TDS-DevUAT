/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Unit tests for FC_GetSpringCMReportController
 *
 * @when 20/12/2019
 */
@IsTest
private class FC_GetSpringCMReportControllerTest {
    @IsTest
    static void testController() {
        Test.setMock(HttpCalloutMock.class, new FC_SpringCMCalloutMock.DocumentDownloadSuccessMock());

        Case caseNew = (Case)FC_TestFactory.createSObject(new Case(), 'FC_TestFactoryDefaults.CaseDefaults', true);
        Adjudication_Report__c adjudicationReport = (Adjudication_Report__c)FC_TestFactory.createSObject(
                new Adjudication_Report__c(Dispute__c = caseNew.Id, Adjudication_Report_URL__c = 'https://test.com'),true
        );
        
        Test.startTest();
        FC_SpringCMDownloadDocument.DownloadDocumentResponse springCMResponse = (FC_SpringCMDownloadDocument.DownloadDocumentResponse) FC_GetSpringCMReportController.getReport(adjudicationReport.Id);
        Test.stopTest();

        System.assertEquals(EncodingUtil.base64Encode(Blob.valueOf('testData')), springCMResponse.encodedDocumentBlob);
        System.assertEquals('test.txt', springCMResponse.fileName);
        System.assertEquals('text/plain', springCMResponse.contentType);
    }
}