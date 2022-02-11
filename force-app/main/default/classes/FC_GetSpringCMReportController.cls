/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Controller for LWC fc_GetSpringCMReportLWC used to download file from SpringCM
 *
 * @when 13/11/2019
 */
public with sharing class FC_GetSpringCMReportController {
    /**
     * Get the report document from the SpringCM
     *
     * @param recordId Adjudication Report record Id
     * 
     * @return Downloaded Document / error response
     */
    @AuraEnabled
    public static FC_SpringCMCommon.ISpringCMResponse getReport(Id recordId) {
        FC_SpringCMCommon.ISpringCMResponse springCMResponse;
        Adjudication_Report__c report = [SELECT Adjudication_Report_URL__c FROM Adjudication_Report__c WHERE Id = :recordId];
        Map<String,String> headers = new Map<String, String>{FC_Constant.HEADER_ACCEPT => FC_Constant.CONTENT_TYPE_APPLICATION_PDF};
        springCMResponse = new FC_SpringCMDownloadDocument(report.Adjudication_Report_URL__c, recordId, headers).sendRequest();
        
        if(springCMResponse instanceof FC_SpringCMDownloadDocument.DownloadDocumentErrorResponse) {
            //attempt to download PDF again- first request makes it create PDF asynchronously on the service side
            springCMResponse = new FC_SpringCMDownloadDocument(report.Adjudication_Report_URL__c, recordId, headers).sendRequest();
            if(springCMResponse instanceof FC_SpringCMDownloadDocument.DownloadDocumentErrorResponse) {
                //if 2nd attempt failed - try again to download in native format
                springCMResponse = new FC_SpringCMDownloadDocument(report.Adjudication_Report_URL__c, recordId).sendRequest();
            }
        }
        return springCMResponse;
    } 
}