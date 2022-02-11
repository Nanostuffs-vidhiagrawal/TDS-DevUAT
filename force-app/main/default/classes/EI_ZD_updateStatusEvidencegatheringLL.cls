global class EI_ZD_updateStatusEvidencegatheringLL implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
global Database.QueryLocator start(Database.BatchableContext BC){
    DateTime todaysDate = System.today();
    String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        String query = 'select id,(select id,Name,Type__c,Contact_Email__c,Is_Lead__c, Contact__r.Phone from Case_Participants__r) from case ';
    			query= query+' Where Status=\'Invitation to view the claim\'';
    			query= query+' and Respond_Date__c = '+todaysDateStr;
        return Database.getQueryLocator(query);    
    }
    global void execute(Database.BatchableContext BC, List<case> caseList){
        list<case> casetoupdate = new list<case>();
        map<string,Case> EmailtoSend = new Map<string,Case>();
        for(case cs:caseList)
        {
            
                casetoupdate.add(new case(id=cs.id, status='Evidence Gathering - LL'));
                //EI_ZD_EmailUtility.sendEmailByMailJet2(cs.id,'Invitation to submit evidence');
          
        }
        if(casetoupdate.size() > 0 )
        {
            update casetoupdate;
        }
        
            
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}