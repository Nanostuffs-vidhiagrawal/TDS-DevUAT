public without sharing class EI_BatchClassForEvidenceGatheringStatus implements DataBase.Batchable<sObject>,Database.Stateful{
    
    
    Map<String,Set<Id>> mapOfMailTypeVsCaseIds = new Map<String,Set<Id>>();
    
    public EI_BatchClassForEvidenceGatheringStatus(){
        mapOfMailTypeVsCaseIds.put('EvidenceGLL',new Set<Id>()); // NPP-4,5
        mapOfMailTypeVsCaseIds.put('EvidenceGTT',new Set<Id>());
        mapOfMailTypeVsCaseIds.put('SelfRes',new Set<Id>());  // NPP-37 
        mapOfMailTypeVsCaseIds.put('SelfRes10DayR',new Set<Id>());
    }
    public DataBase.QueryLocator start(DataBase.BatchableContext BC){
        
        //Integer days = Integer.valueOf(system.Label.Working_Days_For_Reminder);
        //Date currentDate = system.today().addDays(-days);
        String query = 'SELECT Id,Two_times_no_engagement__c,AGLL_Respond_Self_resolution__c,TT_respond_Self_resolution__c, No_Tenant_Evidence__c, '
            +'No_Landlord_Evidence__c, Status, Respond_Date__c, AGLL_Respond_Evidance_Gathering__c, PreviousStatus__c,TT_respond_evidence_gathering__c '
            +'FROM Case where Respond_Date__c != null AND (Status In (\'Evidence gathering AA/LL\', \'Evidence Gathering TT\', \'On Hold\') OR '
            +'(TT_respond_evidence_gathering__c = false OR AGLL_Respond_Evidance_Gathering__c = false OR AGLL_Respond_Self_resolution__c = false '
            +'OR TT_respond_Self_resolution__c = false)) '
            +'AND Id=\'5003H000005Su7D\' ';
        //String query = 'SELECT FIELDS(ALL) FROM Case where Respond_Date__c != null AND (Status In (\'Evidence gathering AA/LL\', \'Evidence Gathering TT\') OR (TT_respond_evidence_gathering__c = false OR AGLL_Respond_Evidance_Gathering__c = false OR AGLL_Respond_Self_resolution__c = false OR TT_respond_Self_resolution__c = false))';
        return DataBase.getQueryLocator(query);
    }
    
    public void execute(DataBase.BatchableContext BC,List<Case> caseList){
        // Respond_Date__c != null AND Respond_Date__c<=:currentDate
        List<Case> updateCaseList = new List<Case>();
        if(!caseList.isEmpty()){
            
            //Integer days = Integer.valueOf(system.Label.Working_Days_For_Reminder);
            // Date currentDate = system.today().addDays(-days);
            // Date backDays = system.today().addDays(-10);
            
            for(Case eachCase : caseList){
                // Start - NPP - 4,5
                if(eachCase.Status == 'Evidence gathering AA/LL' || eachCase.PreviousStatus__c =='Evidence gathering AA/LL'){
                    if(!eachCase.AGLL_Respond_Evidance_Gathering__c){
                        // method to calculate working days diff btw two dates
                        Integer diffinDays =0;
                        if(System.today() <= eachCase.Respond_Date__c){
                            diffinDays = calculateWorkingDays(System.today(),eachCase.Respond_Date__c);
                            if(diffinDays == 5) {
                                system.debug('sendEmail');
                                mapOfMailTypeVsCaseIds.get('EvidenceGLL').add(eachCase.Id);
                                // collect ids to send mail
                            }
                        }else{
                            diffinDays = calculateWorkingDays(eachCase.Respond_Date__c,System.today());
                                if(diffinDays == 1){
                                    eachCase.No_Landlord_Evidence__c = true;
                                    eachCase.Status = 'Awaiting evidence review';
                                    updateCaseList.add(eachCase);
                                }
                        }
                    }
                }
                if(eachCase.Status == 'Evidence gathering TT' || eachCase.PreviousStatus__c == 'Evidence gathering TT' ){
                    if(!eachCase.TT_respond_evidence_gathering__c){
                        // method to calculate working days diff btw two dates
                        Integer diffinDays =0;
                        if(System.today() <= eachCase.Respond_Date__c){
                            diffinDays = calculateWorkingDays(System.today(),eachCase.Respond_Date__c);
                            if(diffinDays == 5) {
                                mapOfMailTypeVsCaseIds.get('EvidenceGTT').add(eachCase.Id);
                                // collect ids to send mail
                            }
                        }else{
                                diffinDays = calculateWorkingDays(eachCase.Respond_Date__c,System.today());
                                if(diffinDays == 1){
                                    eachCase.No_Tenant_Evidence__c = true;
                                    eachCase.Status = 'Awaiting evidence review';
                                    updateCaseList.add(eachCase);
                                }
                        }
                    }
                }
                // END - NPP - 4,5
                // Start - NPP 37
                if(eachCase.Status == 'Repayment disputed - self-resolution' || eachcase.Status =='Repayment disputed - self-resolution'){
                    if(!eachCase.AGLL_Respond_Self_resolution__c && !eachCase.TT_respond_Self_resolution__c){
                        // method to calculate working days diff btw two dates
                        Integer diffinDays =0;
                        if(System.today() <= eachCase.Respond_Date__c){
                            diffinDays = calculateWorkingDays(System.today(),eachCase.Respond_Date__c);
                            if(diffinDays == 5) {
                                mapOfMailTypeVsCaseIds.get('SelfRes').add(eachCase.Id);
                                // collect ids to send mail
                            }
                        }else{
                            diffinDays = calculateWorkingDays(eachCase.Respond_Date__c,System.today());
                                if(diffinDays == 1){
                                    if(!eachCase.Two_times_no_engagement__c){
                                        eachCase.Two_times_no_engagement__c = true; 
                                        eachCase.Respond_Date__c = EI_UpdateRepaymentRequestToCase.calculateWorkingDaysBetweenTwoDates(eachCase.Respond_Date__c,10);
                                        updateCaseList.add(eachCase);
                                        mapOfMailTypeVsCaseIds.get('SelfRes10DayR').add(eachCase.Id);
                                    }
                                // update respond date for next 10 days
                                }
                            }
                    }
                } 
                // End - NPP 37
                // Start NPP-41
                if(eachCase.Status == 'Repayment disputed - self-resolution' || eachCase.PreviousStatus__c=='Repayment disputed - self-resolution'){
                    if(eachCase.AGLL_Respond_Self_resolution__c || eachCase.TT_respond_Self_resolution__c){
                        
                        if(System.today() > eachCase.Respond_Date__c){
                            integer diffinDays = calculateWorkingDays(eachCase.Respond_Date__c,System.today());
                            if(diffinDays == 1){
                                eachCase.Status = 'Self-resolution - awaiting review';
                                updateCaseList.add(eachCase);
                            }
                        }
                    }
                } 
            } 
        }
        
        if(!updateCaseList.isEmpty()){
            DataBase.update(updateCaseList, false);
        }
    }
    
    public void finish(DataBase.BatchableContext BC){
        
        if(!mapOfMailTypeVsCaseIds.isEmpty()){
            system.enqueueJob(new EI_ReminderForEvidenceMails(mapOfMailTypeVsCaseIds));
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