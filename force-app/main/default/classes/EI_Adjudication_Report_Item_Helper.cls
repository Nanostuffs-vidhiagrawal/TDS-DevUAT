public without sharing class EI_Adjudication_Report_Item_Helper {

    public static void updateExternalIdFields(list<Adjudication_Report_Item__c> reportItemList){
        set<String> reportToQuery = new set<String>();
        set<String> disputeItemToQuery = new set<String>();
        set<Id> reportToQueryId = new set<Id>();
        set<Id> disputeItemToQueryId = new set<Id>();
        for(Adjudication_Report_Item__c report : reportItemList){
            
            if(String.isNotBlank(report.Adjudication_Report_Custom__c)){
                reportToQuery.add(report.Adjudication_Report_Custom__c);
            }else{
                reportToQueryId.add(report.Adjudication_Report__c);
            }
            if(String.isNotBlank(report.Dispute_Item_Custom__c)){
                disputeItemToQuery.add(report.Dispute_Item_Custom__c);
            }else{
                disputeItemToQueryId.add(report.Dispute_Item__c);
            }
        }

        map<Id,Adjudication_Report__c> idVsReport = new map<Id,Adjudication_Report__c>();
        map<string,Adjudication_Report__c> customNumberVsReport = new map<string,Adjudication_Report__c>();
        map<Id,Dispute_Item__c> idVsReportItem = new map<Id,Dispute_Item__c>();
        map<string,Dispute_Item__c> customNumberVsDisputeItem = new map<string,Dispute_Item__c>();

        if(!reportToQuery.isEmpty() || !reportToQueryId.isEmpty()){
            for(Adjudication_Report__c report : [Select Id,Name,Adjudication_Report_Custom__c from Adjudication_Report__c where Id IN : reportToQueryId OR Adjudication_Report_Custom__c IN : reportToQuery]){
                
                idVsReport.put(report.Id,report);
                if(String.isNotBlank(report.Adjudication_Report_Custom__c)){
                    customNumberVsReport.put(report.Adjudication_Report_Custom__c,report);
                }
                
            }
        }

        if(!disputeItemToQuery.isEmpty() || !disputeItemToQueryId.isEmpty()){
            for(Dispute_Item__c disputeItem : [Select Id,Dispute_Item_Custom_Number__c,Name from Dispute_Item__c where Id IN : disputeItemToQueryId OR Dispute_Item_Custom_Number__c IN : disputeItemToQuery]){
                
                idVsReportItem.put(disputeItem.Id,disputeItem);
                if(String.isNotBlank(disputeItem.Dispute_Item_Custom_Number__c)){
                    customNumberVsDisputeItem.put(disputeItem.Dispute_Item_Custom_Number__c,disputeItem);
                }
                
            }
        }
        
        for(Adjudication_Report_Item__c report : reportItemList){
            
            if(String.isNotBlank(report.Adjudication_Report_Custom__c) && customNumberVsReport.containsKey(report.Adjudication_Report_Custom__c)){
                report.Adjudication_Report__c = customNumberVsReport.get(report.Adjudication_Report_Custom__c).Id;
            }else if(idVsReport.containsKey(report.Adjudication_Report__c)){
                report.Adjudication_Report_Custom__c = idVsReport.get(report.Adjudication_Report__c).Adjudication_Report_Custom__c;
            }
            
            if(String.isNotBlank(report.Dispute_Item_Custom__c) && customNumberVsDisputeItem.containsKey(report.Dispute_Item_Custom__c)){
                report.Dispute_Item__c = customNumberVsDisputeItem.get(report.Dispute_Item_Custom__c).Id;
            }else if(idVsReportItem.containsKey(report.Dispute_Item__c)){
                report.Dispute_Item_Custom__c = idVsReportItem.get(report.Dispute_Item__c).Dispute_Item_Custom_Number__c;
            }
        }
    }
}