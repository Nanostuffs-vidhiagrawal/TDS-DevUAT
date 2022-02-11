public class EI_BatchForMailjetContent implements Database.Batchable<sObject>,Database.AllowsCallouts,schedulable{
	
    public void execute(SchedulableContext SC){
    	
        Database.executeBatch(new EI_BatchForMailjetContent(), 1);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
		Date todayDate = System.today();
        String query = 'SELECT Id, Name, Record_ID__c, Contact__c, Account_Id__c, Sent_Message__c, Is_Postal__c, Template_Id__c, Content_Populated__c FROM Mailjet_Message__c where Content_Populated__c = false AND Is_Postal__c = true AND Record_ID__c != null';
        //String query = 'SELECT Id, Name, Record_ID__c, Contact__c, Account_Id__c, Sent_Message__c, Is_Postal__c, Template_Id__c, Content_Populated__c FROM Mailjet_Message__c where Id= \'a2U3H00000083DaUAI\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        map<String,String> returnTemplate = new map<String,String>();
    	Mailjet_Message__c mailjetMessage = (Mailjet_Message__c)scope[0];

        String conAccId = String.isNotBlank(mailjetMessage.Contact__c)?mailjetMessage.Contact__c: mailjetMessage.Account_Id__c;
        
        if(String.isNotBlank(mailjetMessage.Template_Id__c)){
            
            
            if(String.isNotBlank(conAccId) && conAccId.startsWith('001')){
                list<Account> accList = [Select Id,personContactId from Account where Id =:conAccId];
                if(!accList.isEmpty()){
                    if(String.isNotBlank(accList[0].personContactId)){
                        conAccId = accList[0].personContactId;
                    }
                }

            }
            if(String.isNotBlank(conAccId) && conAccId.startsWith('003')){
                returnTemplate = EI_SDS_SendManualEmailCls.getMailJetTextBody(Integer.valueOf(mailjetMessage.Template_Id__c),'', mailjetMessage.Record_ID__c, conAccId);
                system.debug('>>>>>>>>>>>'+returnTemplate);
            }else{
                //Flag Post Message 
                Update new Mailjet_Message__c(Id = mailjetMessage.Id, Flag_Post__c = true);

            }
                
        }
        // Populate Subject From Here 
        
        if(returnTemplate.containsKey('body')){
            mailjetMessage.Sent_Message__c = returnTemplate.get('body');
            mailjetMessage.Content_Populated__c = true;
            if(returnTemplate.containsKey('subject')){
                mailjetMessage.Subject__c = returnTemplate.get('subject');
            }
            if(String.isBlank(mailjetMessage.Contact__c) && String.isNotBlank(conAccId) && conAccId.startsWith('003')){
                mailjetMessage.Contact__c = conAccId;
                
            }
            
            Update mailjetMessage;
        }
	    
    }
    public void finish(Database.BatchableContext BC){
    	
    }
}