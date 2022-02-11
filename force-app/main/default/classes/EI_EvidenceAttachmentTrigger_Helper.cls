public without sharing class EI_EvidenceAttachmentTrigger_Helper {

    public static void updateExternalIdFields(list<Evidence_Attachment__c> attachmentList){
        set<String> caseToQuery = new set<String>();
        set<String> disputeItemToQuery = new set<String>();
        set<Id> caseToQueryId = new set<Id>();
        set<Id> disputeItemToQueryId = new set<Id>();
        for(Evidence_Attachment__c attachment : attachmentList){
            
            if(String.isNotBlank(attachment.Case_Number_Custom__c)){
                caseToQuery.add(attachment.Case_Number_Custom__c);
            }else{
                caseToQueryId.add(attachment.Dispute__c);
            }
            if(String.isNotBlank(attachment.Dispute_Item_Custom__c)){
                disputeItemToQuery.add(attachment.Dispute_Item_Custom__c);
            }else{
                disputeItemToQueryId.add(attachment.Dispute_Item__c);
            }
        }

        map<Id,Case> idVsDispute = new map<Id,Case>();
        map<string,Case> customNumberVsCase = new map<string,Case>();
        map<Id,Dispute_Item__c> idVsDisputeItem = new map<Id,Dispute_Item__c>();
        map<string,Dispute_Item__c> customNumberVsDisputeItem = new map<string,Dispute_Item__c>();

        if(!caseToQuery.isEmpty() || !caseToQueryId.isEmpty()){
            for(Case dispute : [Select Id,CaseNumber,Case_Number_Custom__c from Case where Id IN : caseToQueryId OR Case_Number_Custom__c IN : caseToQuery]){
                
                idVsDispute.put(dispute.Id,dispute);
                if(String.isNotBlank(dispute.Case_Number_Custom__c)){
                    customNumberVsCase.put(dispute.Case_Number_Custom__c,dispute);
                }
                
            }
        }

        if(!disputeItemToQuery.isEmpty() || !disputeItemToQueryId.isEmpty()){
            for(Dispute_Item__c disputeItem : [Select Id,Dispute_Item_Custom_Number__c,Name from Dispute_Item__c where Id IN : disputeItemToQueryId OR Dispute_Item_Custom_Number__c IN : disputeItemToQuery]){
                
                idVsDisputeItem.put(disputeItem.Id,disputeItem);
                if(String.isNotBlank(disputeItem.Dispute_Item_Custom_Number__c)){
                    customNumberVsDisputeItem.put(disputeItem.Dispute_Item_Custom_Number__c,disputeItem);
                }
                
            }
        }
        
        for(Evidence_Attachment__c attachment : attachmentList){
            
            if(String.isNotBlank(attachment.Case_Number_Custom__c) && customNumberVsCase.containsKey(attachment.Case_Number_Custom__c)){
                attachment.Dispute__c = customNumberVsCase.get(attachment.Case_Number_Custom__c).Id;
            }else if(idVsDispute.containsKey(attachment.Dispute__c)){
                attachment.Case_Number_Custom__c = idVsDispute.get(attachment.Dispute__c).Case_Number_Custom__c;
            }
            
            if(String.isNotBlank(attachment.Dispute_Item_Custom__c) && customNumberVsDisputeItem.containsKey(attachment.Dispute_Item_Custom__c)){
                attachment.Dispute_Item__c = customNumberVsDisputeItem.get(attachment.Dispute_Item_Custom__c).Id;
            }else if(idVsDisputeItem.containsKey(attachment.Dispute_Item__c)){
                attachment.Dispute_Item_Custom__c = idVsDisputeItem.get(attachment.Dispute_Item__c).Dispute_Item_Custom_Number__c;
            }
        }

    }
}