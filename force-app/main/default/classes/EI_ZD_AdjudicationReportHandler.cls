public class EI_ZD_AdjudicationReportHandler {
    
    public static void beforeUpdate(List<Adjudication_Report__c> newReports, Map<Id, Adjudication_Report__c> oldMap) {
            List<Adjudication_Report__c> adjudicationReportsToGetLinks = new List<Adjudication_Report__c>();
            
                list<Adjudication_Report__c> latestADR = new list<Adjudication_Report__c>();
            for(Adjudication_Report__c newReport : newReports) {
                Adjudication_Report__c oldReport = oldMap == null ? null : oldMap.get(newReport.Id);
                if(newReport.Adjudication_Report_URL__c != oldReport.Adjudication_Report_URL__c && String.isNotBlank(newReport.Adjudication_Report_URL__c)) {
                    adjudicationReportsToGetLinks.add(newReport);
                }
                 if(newReport.Status__c != oldReport.Status__c && (newReport.Status__c =='Published') ) {
                    latestADR.add(newReport);
                }
            }
            if(latestADR.size()>0){
                EI_SDSUpdateLatestADR.getAllAdrToUpdateLatest(latestADR);
                }
            if(!adjudicationReportsToGetLinks.isEmpty()) {
                database.executeBatch(new EI_ZD_DocuSignPublicLinksBatch(adjudicationReportsToGetLinks), 1);
            }
        }
    public static void afterUpdate(List<Adjudication_Report__c> newReports, Map<Id, Adjudication_Report__c> oldMap) {
        List<Adjudication_Report__c> adjudicationReportsRecList = new List<Adjudication_Report__c>();
        for(Adjudication_Report__c newReport : newReports) {
                Adjudication_Report__c oldReport = oldMap == null ? null : oldMap.get(newReport.Id);
                if(newReport.Status__c != oldReport.Status__c &&(newReport.Status__c =='Published') && String.isNotBlank(newReport.Webhook_Report_Link__c) ) {
                    adjudicationReportsRecList.add(newReport);
                }
            }
            if(!adjudicationReportsRecList.isEmpty()) {
                list<case> caseTobeUpdated = new list<case>();
               
                for(Adjudication_Report__c adj : adjudicationReportsRecList)
                { 
                    if(adj.Case_Record_Type__c =='Zero Deposit Dispute'){
                    caseTobeUpdated.add(new case(id =adj.Dispute__c,status='Decision issued',Close_Reason__c='Adjudication decision reached',
                                                Amount_agreed_by_Adjudication__c =adj.Awarded_amount_to_LL_or_AA__c,Claim_Agreed_By__c='Adjudication'));
           
                    }
                 
                    else{
                        
                    }
                    }
                if(caseTobeUpdated.size() > 0)
                {
                    update caseTobeUpdated;
                }
          
                
            }
        
    }

}