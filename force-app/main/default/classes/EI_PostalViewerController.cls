public without sharing class EI_PostalViewerController {

    @AuraEnabled
    public static list<Mailjet_Message__c> getMailjetMessageDetails(String recId){
        
        return [select id,Email_ID__c,Message_Id__c,Sent_Message__c,Record_ID__c,Subject__c,Createddate,Content_Populated__c,Contact__r.Name
                from Mailjet_Message__c where record_id__c =: recId AND Is_Postal__c = true order by createddate desc];
        
    }
}