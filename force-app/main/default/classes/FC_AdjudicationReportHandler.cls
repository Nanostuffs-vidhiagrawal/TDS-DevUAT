/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Handler class model for Adjudication Report
 * @when 09/11/2019
 */
public with sharing class FC_AdjudicationReportHandler {
    public class BulkCaseHandler {

        /**
         * Handles bulk Adjudication Report coming from onAfterInsert OnAfterUpdate trigger event
         * @param newMap
         * @param oldMap
         */
        public void handleAdjudicationReportPublishedStatus(List<Adjudication_Report__c> newReports, Map<Id, Adjudication_Report__c> oldMap) {
            List<Adjudication_Report__c> adjudicationReportsToUpdate = new List<Adjudication_Report__c>();

            for(Adjudication_Report__c newReport : newReports) {
                Adjudication_Report__c oldReport = oldMap == null ? null : oldMap.get(newReport.Id);
                if(isStatusSetToPublished(newReport, oldReport)) {
                    adjudicationReportsToUpdate.add(newReport);
                }
            }
            if(!adjudicationReportsToUpdate.isEmpty()) {
                FC_AdjudicationReportHandler.updateAdjudicationReportAndRelatedCases(adjudicationReportsToUpdate);
            }
        }

        /**
         * Handles bulk Adjudication Report coming from OnAfterUpdate trigger event
         * @param newMap
         * @param oldMap
         */
        public void handleAdjudicationReportWebhookEvents(List<Adjudication_Report__c> newReports, Map<Id, Adjudication_Report__c> oldMap) {
            List<Adjudication_Report__c> adjudicationReportsToUpdate = new List<Adjudication_Report__c>();

            for(Adjudication_Report__c newReport : newReports) {
                Adjudication_Report__c oldReport = oldMap == null ? null : oldMap.get(newReport.Id);
                if(isStatusSetToPublishedForApiAccount(newReport, oldReport)) {
                    adjudicationReportsToUpdate.add(newReport);
                }
            }
            if(!adjudicationReportsToUpdate.isEmpty()) {
                new FC_WebhookEventPublisher.AdjudicationReportEventPublisher(adjudicationReportsToUpdate).publishEvents();
            }
        }
        /**
         * Handle callback from Report MergeDoc flow. 
         *
         * @param newReports
         * @param oldMap
         */
        public void handleAdjudicationReportURLFromMergeDoc(List<Adjudication_Report__c> newReports, Map<Id, Adjudication_Report__c> oldMap) {
            List<Adjudication_Report__c> adjudicationReportsToGetLinks = new List<Adjudication_Report__c>();

            for(Adjudication_Report__c newReport : newReports) {
                Adjudication_Report__c oldReport = oldMap == null ? null : oldMap.get(newReport.Id);
                if(isAdjudicationReportUrlProvided(newReport, oldReport)) {
                    adjudicationReportsToGetLinks.add(newReport);
                }
            }
            if(!adjudicationReportsToGetLinks.isEmpty()) {
                System.enqueueJob(new FC_SpringCMShareLinksQueueable(adjudicationReportsToGetLinks));
            }
        }

        private Boolean isStatusSetToPublished(Adjudication_Report__c newReport, Adjudication_Report__c oldReport){
            return oldReport == null ? (newReport.Status__c == FC_Constant.Adjudication_Report_Status_Published)
                    : (newReport.Status__c == FC_Constant.Adjudication_Report_Status_Published
                            && oldReport.Status__c != FC_Constant.Adjudication_Report_Status_Published);
        }

        private Boolean isStatusSetToPublishedForApiAccount(Adjudication_Report__c newReport, Adjudication_Report__c oldReport){
            return isStatusSetToPublished(newReport,oldReport) && newReport.Dispute_API_Account_Id__c != null;
        }
        
        private Boolean isAdjudicationReportUrlProvided(Adjudication_Report__c newReport, Adjudication_Report__c oldReport){
            return newReport.Adjudication_Report_URL__c != oldReport.Adjudication_Report_URL__c && String.isNotBlank(newReport.Adjudication_Report_URL__c);
        }
    }

    private static void updateAdjudicationReportAndRelatedCases(List<Adjudication_Report__c> adjudicationReports) {
        List<Case> parentDisputesToUpdate = new List<Case>();
        List<CaseMilestone> milestonesToClose = [SELECT Id FROM CaseMilestone WHERE IsCompleted = false
            AND MilestoneType.Name = :FC_Constant.CaseMilestone_Type_Adjudication];

        for(Adjudication_Report__c report : adjudicationReports) {
            report.Published_Date__c = Datetime.now();
            if(report.Dispute__c != null) {
                Case parentDispute = new Case(
                        Id = report.Dispute__c, Status = FC_Constant.Case_Status_Closed,
                        Close_Reason__c = FC_Constant.Case_Close_Reason_Adjudication_Decision_Reached
                );
                parentDisputesToUpdate.add(parentDispute);
            }
        }

        for(CaseMilestone milestone : milestonesToClose) {
            milestone.CompletionDate = Datetime.now();
        }

        try {
            update milestonesToClose;
            try {
                update parentDisputesToUpdate;
            }
            catch (DmlException dmle1) {
                FC_ErrorLogger.error(dmle1);
                System.debug('### Failed to update Cases on updateAdjudicationReportAndRelatedCases():' + dmle1.getMessage());
            }
        }
        catch (DmlException dmle) {
            FC_ErrorLogger.error(dmle);
            System.debug('### Failed to update CaseMilestones on updateAdjudicationReportAndRelatedCases():' + dmle.getMessage());
        }
    }
}