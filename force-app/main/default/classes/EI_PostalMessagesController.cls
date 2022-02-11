public without sharing class EI_PostalMessagesController {
    
    @AuraEnabled
	public static list<PostalReportWrapper> returnMessages(String source){

        list<PostalReportWrapper> wrapperList = new list<PostalReportWrapper>();
     	
        for(Mailjet_Message__c msg : [Select Id, Content_Populated__c,Name,Contact__c,Contact__r.Name,Record_Id__c,Subject__c,Flag_Post__c,Is_Printed__c from Mailjet_Message__c where Is_Postal__c = true AND CreatedDate = Today AND Source__c =: source ORDER BY CreatedDate DESC]){
            
            PostalReportWrapper wrap = new PostalReportWrapper();
            wrap.isSelected = false;
            wrap.objMessage = msg; 
            wrapperList.add(wrap);
        }

        return wrapperList;
    }

    @AuraEnabled
	public static list<PostalReportWrapper> returnMessagesFilter(Date startDate, Date endDate,String source){

        //startDate = startDate.addDays(-1);
        endDate = endDate.addDays(1);
        
        list<PostalReportWrapper> wrapperList = new list<PostalReportWrapper>();
     	
        for(Mailjet_Message__c msg : [Select Id, Is_Printed__c,Content_Populated__c,Name,Contact__c,Contact__r.Name,Record_Id__c,Subject__c,Flag_Post__c from Mailjet_Message__c where CreatedDate >: startDate AND CreatedDate <: endDate AND Is_Postal__c = true AND Source__c =: source ORDER BY CreatedDate DESC]){
            
            PostalReportWrapper wrap = new PostalReportWrapper();
            wrap.isSelected = false;
            wrap.objMessage = msg; 
            wrapperList.add(wrap);
        }

        return wrapperList;
    }
    
    public class PostalReportWrapper{
        @AuraEnabled public  Mailjet_Message__c objMessage{get;set;}
        @AuraEnabled public  Boolean isSelected{get;set;}
        
    }
}