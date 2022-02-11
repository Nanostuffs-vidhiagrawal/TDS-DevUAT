public without sharing class EI_ShowChatCaseController {
	
	@AuraEnabled
    public static list<Chat_History__c> updateChatFields(String caseId){
        
        list<Chat_History__c> chatList = [Select Id,Azure_File_Name__c,Case__c,Name,Download_File__c,File_Location__c,From__c,Message__c,To__c,To__r.Name,File_Name__c,File_Type__c,From_User_Type__c from Chat_History__c where Case__c =: caseId ORDER BY CreatedDate];
        
        for(Chat_History__c chat : chatList){
            if(String.isNotBlank(chat.File_Location__c)){
                chat.File_Location__c = chat.File_Location__c.UnescapeHTML4();
                
            }
        }
        
        return chatList;
        
    }
	    
}