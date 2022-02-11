public without sharing class EI_BatchClassForCourtCase implements DataBase.Batchable<sObject>,Database.Stateful {
    
    Map<String,Set<Id>> mapOfMailTypeVsCaseIds = new Map<String,Set<Id>>();
    //Set<Id> setOfCourtCaseIds = new Set<Id>();
    public EI_BatchClassForCourtCase() {
        /*mapOfMailTypeVsCaseIds.put('EvidenceGLL',new Set<Id>()); // NPP-4,5
        mapOfMailTypeVsCaseIds.put('EvidenceGTT',new Set<Id>());
        mapOfMailTypeVsCaseIds.put('SelfRes',new Set<Id>());  // NPP-37 
        mapOfMailTypeVsCaseIds.put('SelfRes10DayR',new Set<Id>()); */
        mapOfMailTypeVsCaseIds.put('CourtCase',new Set<Id>()); //NPP-29
        mapOfMailTypeVsCaseIds.put('EvidRevComp',new Set<Id>()); //NPP-6
        mapOfMailTypeVsCaseIds.put('Adjudication',new Set<Id>()); //NPP-6
    }
    public DataBase.QueryLocator start(DataBase.BatchableContext BC){
        
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        //Integer days = Integer.valueOf(system.Label.Working_Days_For_Reminder);
        //Date currentDate = system.today().addDays(-days);
        String query = 'SELECT Id, Two_times_no_engagement__c, AGLL_Respond_Self_resolution__c, TT_respond_Self_resolution__c, No_Tenant_Evidence__c, '
            +'Counter__c, IIIrd_Working_Day_SR__c, No_Landlord_Evidence__c, Status, Respond_Date__c,PreviousStatus__c, AGLL_Respond_Evidance_Gathering__c, '
            +'TT_respond_evidence_gathering__c, Remaining_protected_amount__c, (Select Id, Contact__r.Email, Contact__r.FirstName, '
            +'Type__c, Access_Code__c FROM Case_Participant__c) FROM Case where Respond_Date__c != null AND '
            +'(Status In (\'Deposit to be repaid - court case\', \'Evidence review complete\', \'Adjudication\',\'On Hold\')) AND RecordtypeId=:devRecordTypeId';
        //String query = 'select id,Status,Counter__c,AGLL_Respond_Self_resolution__c,TT_respond_Self_resolution__c,AGLL_Respond_Evidance_Gathering__c,TT_respond_evidence_gathering__c,Respond_Date__c,IIIrd_Working_Day_SR__c from Case where Origin= \'Zero Deposit\' and  Id= \'5008E00000Itqnf\' ';
        //String query = 'SELECT FIELDS(ALL) FROM Case where Respond_Date__c != null AND (Status In (\'Evidence gathering AA/LL\', \'Evidence Gathering TT\') OR (TT_respond_evidence_gathering__c = false OR AGLL_Respond_Evidance_Gathering__c = false OR AGLL_Respond_Self_resolution__c = false OR TT_respond_Self_resolution__c = false))';
        return DataBase.getQueryLocator(query);
    }
    
    public void execute(DataBase.BatchableContext BC,List<Case> caseList) {
        // Respond_Date__c != null AND Respond_Date__c<=:currentDate
        List<Case> updateCaseList = new List<Case>();
        list<case> evidReviewAndAdjudicationList = new list<case>();
        /* Newly added code for Utility mailjet START */
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        /* Newly added code for Utility mailjet END */
        
        if(!caseList.isEmpty()) {
            //Integer days = Integer.valueOf(system.Label.Working_Days_For_Reminder);
            // Date currentDate = system.today().addDays(-days);
            // Date backDays = system.today().addDays(-10);
            List<Case> lstCourtCase = new List<Case>();
            
            for(Case eachCase : caseList) {
                // NPP 29
                if(eachCase.Status == 'Deposit to be repaid - court case' || eachCase.PreviousStatus__c =='Deposit to be repaid - court case') {
                    if(eachCase.Remaining_protected_amount__c > 0) {
                        System.debug('Line 41'+calculateWorkingDaysBetweenTwoDates(eachCase.Respond_Date__c,1));
                        // method to calculate working days diff btw two dates
                        if(System.today() == calculateWorkingDaysBetweenTwoDates(eachCase.Respond_Date__c,1)) {
                            System.debug('Line 43');
                            mapOfMailTypeVsCaseIds.get('CourtCase').add(eachCase.Id);
                            //setOfCourtCaseIds.add(eachCase.Id);
                            // collect ids to send mail
                        }
                    }
                } else if( eachCase.Status == 'Evidence review complete' || eachCase.PreviousStatus__c =='Evidence review complete' ) {
                    
                    mapOfMailTypeVsCaseIds.get('EvidRevComp').add(eachCase.Id);
                    if(eachCase.IIIrd_Working_Day_SR__c == system.today())
                    {
                        evidReviewAndAdjudicationList.add(eachCase);
                        /* Newly added code for adding recipients, variables, template name, Subject START */
                        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
                        /*emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(usr.Email, usr.Name, usr.ContactId));
                        system.debug('emailRecipientList 38 -> ' + emailRecipientList);
                        Map<String, String> variableMap = new Map<String, String>();
                        variableMap.put('date', System.today().format());
                        variableMap.put('landlordname', usr.Name);
						
                        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                       'SDSDepositProtectionAssistance',
                                                                                       'How to protect a deposit with SafeDeposits'));*/
                        /* Newly added code for adding recipients, variables, template name, Subject END */
                    }   
                    
                } else if( eachCase.Status == 'Adjudication' ) {
                    
                    mapOfMailTypeVsCaseIds.get('Adjudication').add(eachCase.Id);
                    if(eachCase.IIIrd_Working_Day_SR__c == system.today())
                    {
                        evidReviewAndAdjudicationList.add(eachCase);
                    }   
                    
                }
                
            }
            
            // ===== NPP-6 ====
            
            if(evidReviewAndAdjudicationList.size() >0 )
            {
                mailtoAllParties(evidReviewAndAdjudicationList);
            }
            
            if(!updateCaseList.isEmpty()) {
                DataBase.update(updateCaseList, false);
            }
            
            if(!mapOfMailTypeVsCaseIds.isEmpty()) {
                System.enqueueJob(new EI_PaymentsAndEmails(mapOfMailTypeVsCaseIds));
            }
            
            /* Send Email from Utility Class START */
            if(emailWrapperList.size()>0) {
                EI_SDS_MailJetUtilityCls.sendEmailFromBatch(JSON.serialize(emailWrapperList));  
            }
            /* Send Email from Utility Class END */
            
        }
    }
    
    public void finish(DataBase.BatchableContext BC) {
        
        
        /*if(!setOfCourtCaseIds.isEmpty()) {
            system.enqueueJob(new EI_PaymentsAndEmails(setOfCourtCaseIds));
        } */
    }
    
    // ===== NPP-6 ====
    public static void mailtoAllParties(List<Case> CaseRec)
    {
        for(Case cs :CaseRec)
        {
            cs.IIIrd_Working_Day_SR__c = calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
        }
        update CaseRec;
        
      
      
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
        if(weekStart.daysBetween(currentDate) ==0 || weekStart.daysBetween(currentDate) == 6){
            return false;
        } 
        else
        {
            return true;    
        }
    }
    
    public static Integer calculateWorkingDays(Date startDate, Date endDate)
    {        
        
        Integer workingDays = 0;
        
        for(integer i=0; i <= startDate.daysBetween(endDate); i++)
        {
            Date dt = startDate + i;
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
            String todayDay = currDate.format('EEEE');
            if(todayDay != 'Saturday' && todayDay !='Sunday')
            {
                workingDays = workingDays + 1;
            }
        }
        
        return workingDays-1;
    }
    
}