public without sharing class EI_Sds_OnholdStatus {
    
    
    public static void updateResponddate(Map<Id,Case> newMap, Map<Id,Case> oldMap) 
    {
        Id devRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        list<Case> casetoUpdate= new list<Case>();
         for(Case newCase : newMap.values()) {
         /*   if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit' && (newCase.Status=='Self-Resolution' || newCase.Status=='Evidence gathering agent/landlord' || newCase.Status=='Evidence gathering tenant' ) && oldMap.get(newCase.Id).Status !='On Hold' )
            {
                Date ResponseDate=EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
                Date IIIrdWorkingdate  = EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 3);
                newCase.Respond_Date__c=ResponseDate;
                newcase.IIIrd_Working_Day_SR__c = IIIrdWorkingdate;
                newcase.Previous_on_hold_end_date__c = null;
                newcase.On_Hold_Start_Date__c = null;
                newcase.On_Hold_End_Date__c = null;
                newcase.On_Hold_Reason__c='';
               // EI_ZDCaseTriggerHandler.isExecuted = true;
            }
            else if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit' && (newCase.Status=='Evidence review complete' || newCase.Status=='Adjudication') && oldMap.get(newCase.Id).Status !='On Hold' &&  oldMap.get(newCase.Id).Status !='Evidence review complete' )
            {
                Date ResponseDate=EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(),20);
                Date IIIrdWorkingdate  = EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
                newCase.Respond_Date__c=ResponseDate;
                newcase.IIIrd_Working_Day_SR__c = IIIrdWorkingdate; 
                newcase.Previous_on_hold_end_date__c = null;
                newcase.On_Hold_Start_Date__c = null;
                newcase.On_Hold_End_Date__c = null;
                newcase.On_Hold_Reason__c='';
             //   EI_ZDCaseTriggerHandler.isExecuted = true;
            }
            if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit' && newCase.Status=='Invitation to view the claim')
            {
                newcase.Previous_on_hold_end_date__c = null;
                newcase.On_Hold_Start_Date__c = null;
                newcase.On_Hold_End_Date__c = null;
                newcase.On_Hold_Reason__c='';
            }
            
            if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId && newCase.Origin=='Zero Deposit' && newCase.Status=='Evidence review complete')
            {
                newcase.On_Hold_Start_Date__c = null;
                newcase.On_Hold_End_Date__c = null;
                newcase.On_Hold_Reason__c='';
            }
            */
             if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId  && 
                (newCase.Status=='Evidence review complete' || newCase.Status=='Adjudication') && oldMap.get(newCase.Id).Status !='On Hold' &&  
                oldMap.get(newCase.Id).Status !='Evidence review complete' )
            {
                Date ResponseDate=EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(),20);
                Date IIIrdWorkingdate  = EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(Date.today(), 5);
                newCase.Respond_Date__c=ResponseDate;
                newCase.Adjudication_Start_date__c=System.today();
                newcase.IIIrd_Working_Day_SR__c = IIIrdWorkingdate; 
                newcase.Previous_on_hold_end_date__c = null;
                newcase.On_Hold_Start_Date__c = null;
                newcase.On_Hold_End_Date__c = null;
                newcase.On_Hold_Reason__c='';
             //   EI_ZDCaseTriggerHandler.isExecuted = true;
            }
            if(newCase.Status != oldMap.get(newCase.Id).Status && newCase.RecordTypeId ==devRecordTypeId )
            {
                
                if(newCase.Status=='On Hold'){
                    newCase.PreviousStatus__c = oldMap.get(newCase.Id).Status;
                    integer totalNoOfDays = 0;
                    integer checkday =0;
                    
                    if(newCase.Previous_on_hold_end_date__c != null && newCase.On_Hold_Start_Date__c == newCase.Previous_on_hold_end_date__c)
                    {
                        system.debug('line-->70' + newCase.Previous_on_hold_end_date__c );
                        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
                        if(EI_ZD_HomePage.checkifItisWorkingDay(newCase.On_Hold_Start_Date__c,holidays))
                        {
                            checkday=1; 
                        }
                    }
                    system.debug('line-->76' + checkday );
                    if(newCase.On_Hold_End_Date__c != null)
                    {
                        if(newCase.On_Hold_Start_Date__c == newcase.On_Hold_End_Date__c)
                        {
                            if(checkday >0)
                            {
                                totalNoOfDays=0;
                            }
                            else
                            {
                                totalNoOfDays=1;
                            }
                            system.debug('line-->77' + totalNoOfDays );
                            /*
                            if(newCase.Previous_on_hold_end_date__c == newcase.On_Hold_End_Date__c)
                            {
                                totalNoOfDays=0;
                            }
                            else
                            {
                                totalNoOfDays=1; 
                            }*/
                        }
                        else
                        {
                            if(checkday >0)
                            {
                                totalNoOfDays = EI_ZD_HomePage.calculateWorkingDays(newCase.On_Hold_Start_Date__c.adddays(1),newCase.On_Hold_End_Date__c);
                            }
                            else
                            {
                                totalNoOfDays = EI_ZD_HomePage.calculateWorkingDays(newCase.On_Hold_Start_Date__c,newCase.On_Hold_End_Date__c);
                            }
                            
                        }
                        
                    }
                    if(totalNoOfDays > 0)
                    {
                        if(!Test.isRunningTest()){
                            newCase.Respond_Date__c= EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(newCase.Respond_Date__c,totalNoOfDays+1); 
                            system.debug('line-->106' + newCase.Respond_Date__c );
                        }
                    }
                    
                  if(oldMap.get(newCase.Id).Status =='Repayment disputed - self-resolution') {
                        decimal oldnoofdays = newCase.On_hold_self_resolution__c != null ? newCase.On_hold_self_resolution__c : 0;
                        newCase.On_hold_self_resolution__c = oldnoofdays+totalNoOfDays;
                        system.debug('line-->117' + newCase.On_hold_self_resolution__c );
                    }
                    else if (oldMap.get(newCase.Id).Status =='Evidence gathering AA/LL')
                    {
                        decimal oldnoofdays = newCase.On_hold_Evidence_gathering_agent_landlor__c != null ? newCase.On_hold_Evidence_gathering_agent_landlor__c : 0;
                        newCase.On_hold_Evidence_gathering_agent_landlor__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Evidence Gathering TT')
                    {
                        decimal oldnoofdays = newCase.On_hold_Evidence_gathering_tenant__c != null ? newCase.On_hold_Evidence_gathering_tenant__c : 0;
                        newCase.On_hold_Evidence_gathering_tenant__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Awaiting evidence review')
                    {
                        decimal oldnoofdays = newCase.On_hold_Awaiting_evidence_review__c != null ? newCase.On_hold_Awaiting_evidence_review__c : 0;
                        newCase.On_hold_Awaiting_evidence_review__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Evidence review complete')
                    {
                        decimal oldnoofdays = newCase.On_hold_evidence_review_complete__c != null ? newCase.On_hold_evidence_review_complete__c : 0;
                        newCase.On_hold_evidence_review_complete__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Adjudication')
                    {
                        decimal oldnoofdays = newCase.On_hold_adjudication__c != null ? newCase.On_hold_adjudication__c : 0;
                        newCase.On_hold_adjudication__c = oldnoofdays+totalNoOfDays;
                    }
                    else if (oldMap.get(newCase.Id).Status =='Decision issued - awaiting request for review')
                    {
                        decimal oldnoofdays = newCase.Adjudication_Review_Onhold_Days__c != null ? newCase.Adjudication_Review_Onhold_Days__c : 0;
                        newCase.Adjudication_Review_Onhold_Days__c = oldnoofdays+totalNoOfDays;
                    }
                    
                    else if (oldMap.get(newCase.Id).Status =='Review of decision requested')
                    {
                        decimal oldnoofdays = newCase.Onhold_Review_Decision_Request__c != null ? newCase.Onhold_Review_Decision_Request__c : 0;
                        newCase.Onhold_Review_Decision_Request__c = oldnoofdays+totalNoOfDays;
                    }
                    
                    else if (oldMap.get(newCase.Id).Status =='Review request declined')
                    {
                        decimal oldnoofdays = newCase.Onhold_Review_Request_Declined__c != null ? newCase.Onhold_Review_Request_Declined__c : 0;
                        newCase.Onhold_Review_Request_Declined__c = oldnoofdays+totalNoOfDays;
                    }
                   	
                   else if (oldMap.get(newCase.Id).Status =='Review request accepted')
                    {
                        decimal oldnoofdays = newCase.Onhold_Review_Request_Accepted__c != null ? newCase.Onhold_Review_Request_Accepted__c : 0;
                        newCase.Onhold_Review_Request_Accepted__c = oldnoofdays+totalNoOfDays;
                    }
                    
                    else if (oldMap.get(newCase.Id).Status =='Review request accepted – assign to adjudicator')
                    {
                        decimal oldnoofdays = newCase.Onhold_Assign_to_Adjudicator__c != null ? newCase.Onhold_Assign_to_Adjudicator__c : 0;
                        newCase.Onhold_Assign_to_Adjudicator__c = oldnoofdays+totalNoOfDays;
                    }
                    
                    
                    //newcase.Previous_on_hold_end_date__c = newCase.On_Hold_End_Date__c;
                }
                if(oldMap.get(newCase.Id).Status=='On Hold' && newCase.Status != 'On Hold' ){
                    if((newCase.On_Hold_End_Date__c != Date.today() &&  newCase.On_Hold_End_Date__c > Date.today()) || newCase.On_Hold_End_Date__c== null )
                    {
                        newCase.On_Hold_End_Date__c =Date.today();
                    }
                    newcase.Previous_on_hold_end_date__c = newCase.On_Hold_End_Date__c;
                }
                 
            }
            
            if(oldMap.get(newCase.Id).Status =='On Hold' && newCase.RecordTypeId ==devRecordTypeId )
            {
                /*
                 * 
                 * 
                 */
                
                if ( oldMap.get(newCase.Id).On_Hold_End_Date__c != null && newCase.On_Hold_End_Date__c != null  && oldMap.get(newCase.Id).On_Hold_End_Date__c != newCase.On_Hold_End_Date__c)
                {
                    
                    integer totalNoOfDays =0 ;
                    
                   // newCase.Previous_on_hold_end_date__c = newCase.On_Hold_End_Date__c;
                   
                    system.debug('newCase.On_Hold_End_Date-->'+newCase.On_Hold_End_Date__c);
                    system.debug('newCase.oldMap.get(newCase.Id).On_Hold_End_Date__c-->>'+oldMap.get(newCase.Id).On_Hold_End_Date__c);
                    
                        if(oldMap.get(newCase.Id).On_Hold_End_Date__c > newCase.On_Hold_End_Date__c)
                        {
                            totalNoOfDays = EI_ZD_HomePage.calculateWorkingDays(newCase.On_Hold_End_Date__c.adddays(1),oldMap.get(newCase.Id).On_Hold_End_Date__c);
                            totalNoOfDays= (totalNoOfDays) * (-1);
                        }
                        else
                        {
                                totalNoOfDays = EI_ZD_HomePage.calculateWorkingDays((oldMap.get(newCase.Id).On_Hold_End_Date__c).adddays(1),newCase.On_Hold_End_Date__c);
                           
                        }
                    
                    
                    system.debug('totalNoOfDays-->>'+totalNoOfDays);
//============================================================   
//
                 
                    
                    
                    /*integer checkday =0;
                    
                    if(newCase.Previous_on_hold_end_date__c != null && newCase.On_Hold_Start_Date__c !=newCase.On_Hold_End_Date__c  
                       && newCase.On_Hold_Start_Date__c == newCase.Previous_on_hold_end_date__c)
                    {
                        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
                        if(EI_ZD_HomePage.checkifItisWorkingDay(newCase.On_Hold_Start_Date__c,holidays))
                        {
                            checkday=1; 
                        }
                    } */
                    
                    if(totalNoOfDays > 0)
                    {
                        
                        newCase.Respond_Date__c=EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(oldMap.get(newCase.Id).Respond_Date__c,(totalNoOfDays+1));	
                        system.debug('line-->203' + newCase.Respond_Date__c );
                    }
                    else
                    {
                        if(totalNoOfDays < 0)
                        {
                            newCase.Respond_Date__c=calculateNegativeWorkingDaysBetweenTwoDates(oldMap.get(newCase.Id).Respond_Date__c,math.abs(totalNoOfDays-1));
                        	    
                        }
                    }
                    
                    
                     if(newCase.PreviousStatus__c =='Repayment disputed - self-resolution' || oldMap.get(newCase.Id).PreviousStatus__c =='Repayment disputed - self-resolution') 
                    {
                        decimal oldnoofdays = newCase.On_hold_self_resolution__c != null ? newCase.On_hold_self_resolution__c : 0;
                        newCase.On_hold_self_resolution__c = oldnoofdays+totalNoOfDays;
                        system.debug('line-->223' + newCase.On_hold_self_resolution__c );   
                    }
                    else if (newCase.PreviousStatus__c =='Evidence gathering AA/LL' || oldMap.get(newCase.Id).PreviousStatus__c =='Evidence gathering AA/LL')
                    {
                        decimal oldnoofdays = newCase.On_hold_Evidence_gathering_agent_landlor__c != null ? newCase.On_hold_Evidence_gathering_agent_landlor__c : 0;
                        newCase.On_hold_Evidence_gathering_agent_landlor__c = oldnoofdays+totalNoOfDays;
                        
                    }
                    else if (newCase.PreviousStatus__c =='Evidence Gathering TT' || oldMap.get(newCase.Id).PreviousStatus__c =='Evidence Gathering TT')
                    {
                        decimal oldnoofdays = newCase.On_hold_Evidence_gathering_tenant__c != null ? newCase.On_hold_Evidence_gathering_tenant__c : 0;
                        newCase.On_hold_Evidence_gathering_tenant__c = oldnoofdays+totalNoOfDays;
                        
                    }
                    else if (newCase.PreviousStatus__c =='Awaiting evidence review' || oldMap.get(newCase.Id).PreviousStatus__c =='Awaiting evidence review')
                    {
                        decimal oldnoofdays = newCase.On_hold_Awaiting_evidence_review__c != null ? newCase.On_hold_Awaiting_evidence_review__c : 0;
                        newCase.On_hold_Awaiting_evidence_review__c = oldnoofdays+totalNoOfDays;
                        
                    }
                    else if (newCase.PreviousStatus__c =='Evidence review complete' || oldMap.get(newCase.Id).PreviousStatus__c =='Evidence review complete')
                    {
                        decimal oldnoofdays = newCase.On_hold_evidence_review_complete__c != null ? newCase.On_hold_evidence_review_complete__c : 0;
                        newCase.On_hold_evidence_review_complete__c = oldnoofdays+totalNoOfDays;
                        
                    }
                    else if (newCase.PreviousStatus__c =='Adjudication' || oldMap.get(newCase.Id).PreviousStatus__c =='Adjudication')
                    {
                        decimal oldnoofdays = newCase.On_hold_adjudication__c != null ? newCase.On_hold_adjudication__c : 0;
                        
                            newCase.On_hold_adjudication__c = oldnoofdays+totalNoOfDays;                        
                    }
                    
                    else if (newCase.PreviousStatus__c =='Decision issued - awaiting request for review' || oldMap.get(newCase.Id).PreviousStatus__c =='Decision issued - awaiting request for review')
                    {
                        decimal oldnoofdays = newCase.Adjudication_Review_Onhold_Days__c != null ? newCase.Adjudication_Review_Onhold_Days__c : 0;
                        
                            newCase.Adjudication_Review_Onhold_Days__c = oldnoofdays+totalNoOfDays;                        
                    }
                   // newCase.Previous_on_hold_end_date__c = newCase.On_Hold_End_Date__c;
                   else if (newCase.PreviousStatus__c =='Review of decision requested' || oldMap.get(newCase.Id).PreviousStatus__c =='Review of decision requested')
                    {
                        decimal oldnoofdays = newCase.Onhold_Review_Decision_Request__c != null ? newCase.Onhold_Review_Decision_Request__c : 0;
                        
                            newCase.Onhold_Review_Decision_Request__c = oldnoofdays+totalNoOfDays;                        
                    }
                    
                 else if (newCase.PreviousStatus__c =='Review request declined' || oldMap.get(newCase.Id).PreviousStatus__c =='Review request declined')
                    {
                        decimal oldnoofdays = newCase.Onhold_Review_Request_Declined__c	 != null ? newCase.Onhold_Review_Request_Declined__c : 0;
                        
                            newCase.Onhold_Review_Request_Declined__c = oldnoofdays+totalNoOfDays;                        
                    }
                    
                    else if (newCase.PreviousStatus__c =='Review request accepted' || oldMap.get(newCase.Id).PreviousStatus__c =='Review request accepted')
                    {
                        decimal oldnoofdays = newCase.Onhold_Review_Request_Accepted__c	 != null ? newCase.Onhold_Review_Request_Accepted__c : 0;
                        
                        newCase.Onhold_Review_Request_Accepted__c = oldnoofdays+totalNoOfDays;                        
                    }
                    
                    else if (newCase.PreviousStatus__c =='Review request accepted – assign to adjudicator' || oldMap.get(newCase.Id).PreviousStatus__c =='Review request accepted – assign to adjudicator')
                    {
                        decimal oldnoofdays = newCase.Onhold_Assign_to_Adjudicator__c	 != null ? newCase.Onhold_Assign_to_Adjudicator__c : 0;
                        
                        newCase.Onhold_Assign_to_Adjudicator__c = oldnoofdays+totalNoOfDays;                        
                    }

                } 
/*
 * 
 * 
 * 
 */
            }
            
        } 
    }
    
     public static Date calculateNegativeWorkingDaysBetweenTwoDates(Date startDate, integer noOfDays)
    {
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        Integer allWorkingDays=0;
        Integer totalDays = 0;
        while(allWorkingDays<=noOfDays)
        {
            
            if(checkifItisWorkingDay(startDate.addDays(-totalDays),holidays)){
                allWorkingDays++;
                if(allWorkingDays==noOfDays)
                    break;
            }
            totalDays++;
        }
        while(!checkifItisWorkingDay(startDate.addDays(-totalDays), holidays)) {
            totalDays++;
        }
        return startDate.addDays(-totalDays);
    }
    
    public static boolean checkifItisWorkingDay(Date currentDate, List<Holiday> holidays)
    {
        Date weekStart  = currentDate.toStartofWeek();
        Time timeflag  = Time.newInstance(0, 0, 0, 0);
        datetime currentdatetime = DateTime.newInstance(currentDate,timeflag);
        for(Holiday hDay:holidays){
            if(currentDate.daysBetween(hDay.ActivityDate) == 0){
                return false;
            }
        }
        if( currentdatetime.format('EEEE').toLowercase() =='sunday' || currentdatetime.format('EEEE').toLowercase() =='Saturday')
        {
            return false;
        }
        else
        {
           return true; 
        } 
    }
    
}