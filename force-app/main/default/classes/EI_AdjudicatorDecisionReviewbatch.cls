public class EI_AdjudicatorDecisionReviewbatch implements DataBase.Batchable<sObject>{ //,Database.Stateful
    
 	Map<String,Set<Id>> mapOfCaseIds = new Map<String,Set<Id>>();
    
    public EI_AdjudicatorDecisionReviewbatch(){
        mapOfCaseIds.put('CourtCase',new Set<Id>()); //NPP-12
    }
    public DataBase.QueryLocator start(DataBase.BatchableContext BC){
        String query = 'SELECT Id, Status, Amount_to_tenants__c, PreviousStatus__c,Amount_to_agent_landlord__c, Respond_Date__c, Tenant_responded_on_adjudication__c, Agent_landlord_responded_on_adjudication__c FROM Case where Respond_Date__c != null AND (Status In (\'Decision issued - awaiting request for review\',\'On Hold\'))';
        return DataBase.getQueryLocator(query);
    }
    
    public void execute(DataBase.BatchableContext BC,List<Case> caseList) {
        // Respond_Date__c != null AND Respond_Date__c<=:currentDate
        List<Case> updateCaseList = new List<Case>();
        System.debug('caseList => ' + caseList);
        
        if(!caseList.isEmpty()) {
           
            for(Case eachCase : caseList) {
                
                // NPP 12
                if((eachCase.Status == 'Decision issued - awaiting request for review' || eachCase.PreviousStatus__c=='Decision issued - awaiting request for review'  )&& (eachCase.Tenant_responded_on_adjudication__c == true
                      || eachCase.Agent_landlord_responded_on_adjudication__c == true) ) {
                          System.debug('Line 25');
                    if(eachCase.Amount_to_tenants__c > 0 || eachCase.Amount_to_agent_landlord__c > 0) {
                        // method to calculate working days diff btw two dates
                        
                        //Integer diffinDays = 0;
                        if(System.today() > eachCase.Respond_Date__c) {
                            
                            //diffinDays = calculateWorkingDays(eachCase.Respond_Date__c, System.today());
                            Date twelvethWorkingDay = calculateWorkingDaysBetweenTwoDates(eachCase.Respond_Date__c, 2);
                            System.debug('Line 33 twelvethWorkingDay -> '+twelvethWorkingDay);
                            //if(diffinDays == 12) {
                            if(twelvethWorkingDay == System.today()) {
                                System.debug('Line 37 twelvethWorkingDay -> '+twelvethWorkingDay);
                                Case cs   = new Case();
                                cs.Id     = eachCase.Id;
                                cs.Status = 'Deposit to be repaid – decision issued';
                                updateCaseList.add(cs);
                                mapOfCaseIds.get('CourtCase').add(eachCase.Id);
                            }
                        }
                    }
                }
            }
            
            if(!updateCaseList.isEmpty()) {
                DataBase.update(updateCaseList, false);
            }
            
            System.debug('mapOfcaseIds in BAtch=> ' + mapOfCaseIds);
            if(!mapOfCaseIds.isEmpty() && mapOfCaseIds.get('CourtCase').size() > 0) {
                system.enqueueJob(new EI_AdjudicatorPaymentAndInstalllment(mapOfCaseIds));
            }
        }
    }
    
    public void finish(DataBase.BatchableContext BC) {
     
    }
    
    public static Date calculateWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 1;
        while(allWorkingDays<=noOfDays)
        {
            if(checkifItisWorkingDay(startDate.addDays(totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(totalDays);
    }
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if(weekStart.daysBetween(currentDate) ==5 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }
    
    
}