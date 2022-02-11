/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Execute the callouts in queueable context
 *
 * @when 31/01/2020
 */

public with sharing class FC_SpringCMShareLinksQueueable implements Queueable, Database.AllowsCallouts {
    @TestVisible
    private static final Integer BATCH_SIZE = 10;
    private List<Adjudication_Report__c> adjudicationReports;
    
    public FC_SpringCMShareLinksQueueable(List<Adjudication_Report__c> adjudicationReports) {
        this.adjudicationReports = adjudicationReports;
    }
    
    public void execute(QueueableContext queueableContext) {
        FC_ErrorLogger.start();
        Integer numberOfRecordsToProcess = BATCH_SIZE < adjudicationReports.size() ? BATCH_SIZE : adjudicationReports.size();

        List<Adjudication_Report__c> adjudicationReportsToGetLinks = new List<Adjudication_Report__c>();
        for(Integer i=0; i < numberOfRecordsToProcess; i++) {
            adjudicationReportsToGetLinks.add(adjudicationReports.remove(0));
        }

        List<Adjudication_Report__c> adjudicationReportsToUpdate = new List<Adjudication_Report__c>();
        for(Adjudication_Report__c adjudicationReport : adjudicationReportsToGetLinks) {
            if(adjudicationReport.Webhook_Report_Link__c == null) {
                try {
                    FC_SpringCMCommon.ISpringCMResponse springCMResponse = (FC_SpringCMCommon.ISpringCMResponse)
                            new FC_SpringCMShareLinks(adjudicationReport.Adjudication_Report_URL__c, adjudicationReport.Id).sendRequest();
                    if(springCMResponse instanceof FC_SpringCMShareLinks.ShareLinksResponse) {
                        FC_SpringCMShareLinks.ShareLinksResponse shareLinksResponse = (FC_SpringCMShareLinks.ShareLinksResponse) springCMResponse;
                        adjudicationReport.Webhook_Report_Link__c = shareLinksResponse.Url;
                        adjudicationReportsToUpdate.add(adjudicationReport);
                    }
                }
                catch(Exception exc) {
                    FC_ErrorLogger.error(exc, adjudicationReport.Id);
                }
            }
        }
        if(adjudicationReportsToUpdate.size() > 0) {
            update adjudicationReportsToUpdate;
        }
        FC_ErrorLogger.stop();
        
        if(adjudicationReports.size() > 0 && !Test.isRunningTest()) {
            System.enqueueJob(new FC_SpringCMShareLinksQueueable(adjudicationReports));
        }
    }
}