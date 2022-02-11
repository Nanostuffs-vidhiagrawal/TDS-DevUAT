public without sharing class EI_CaseStatusHistory {
    
    /* For capturing time duration of Case Status on INSERT START */
    public static void caseStatusHistoryOnInsert(List<Case> caseList, Map<Id,Case> newMap) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        Set<Id> caseStatusChanged = new Set<Id>();
        
        for(Case eachCase : caseList) {
            if((eachCase.Status != '' || eachCase.Status != null) && eachCase.RecordTypeId == devRecordTypeId) 
            {
                caseStatusChanged.add(eachCase.Id);
            }
        }
        
        if(!caseStatusChanged.isEmpty()) {
            List<History_of_Case__c> lstCaseHistory = new List<History_of_Case__c>();
            for(String csId : caseStatusChanged) {
                    History_of_Case__c histCs = new History_of_Case__c(Case__c=csId, Case_Status__c=newMap.get(csId).Status, Number_of_Movements__c=1, 
                                                                       Moved_In_Date__c=System.today(), Moved_In_DateTime__c=System.now());
                    lstCaseHistory.add(histCs);
            }
            
            if(!lstCaseHistory.isEmpty()) {
                Savepoint sp = Database.setSavepoint();
                try {
                    insert lstCaseHistory;
                    
                } catch(Exception e) {
                    Database.rollback(sp);
                }
            }
        }
        
    }
    /* For capturing time duration of Case Status on INSERT END */
    
    /* For capturing time duration of Case Status on UPDATE START */
    public static void caseStatusHistoryOnUpdate(List<Case> caseList, Map<Id,Case> newMap, Map<Id,Case> oldMap) {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        Set<Id> caseStatusChanged = new Set<Id>();
        
        for(Case eachCase : caseList) {
            if((oldMap.get(eachCase.Id).Status!=eachCase.Status || (oldMap.get(eachCase.Id).Status=='' && eachCase.Status!=''))
               && eachCase.RecordTypeId == devRecordTypeId) 
            {
                caseStatusChanged.add(eachCase.Id);
            }
        }
        
        if(!caseStatusChanged.isEmpty()) {
            
            List<Case> casesWithCaseHist = [SELECT Id, Status, 
                                            (SELECT Id, Case_Status__c, Case__c, Previous_Case_Status__c, Moved_In_Date__c, Moved_Out_Date__c, 
                                             Total_No_of_Days__c, Number_of_days__c, Working_Days__c, Total_Working_Days__c, 
                                             Number_of_Movements__c FROM History_of_Cases__r) 
                                            FROM Case WHERE Id IN : caseStatusChanged];
            
            Map<Id, Map<String, History_of_Case__c>> mapOfCaseHistoryToCase = new Map<Id, Map<String, History_of_Case__c>>();
            List<History_of_Case__c> lstCaseHistory = new List<History_of_Case__c>();
            
            for(Case cs:casesWithCaseHist) {
                Map<String, History_of_Case__c> caseHistoriesMap = new Map<String, History_of_Case__c>();
                for(History_of_Case__c caseHist:cs.History_of_Cases__r) {
                    if(caseHist.Case_Status__c==newMap.get(cs.Id).Status) {
                        caseHistoriesMap.put('newStatus',caseHist);
                        
                    } else if(caseHist.Case_Status__c==oldMap.get(cs.Id).Status) {
                        caseHistoriesMap.put('oldStatus',caseHist);
                    }
                }
                mapOfCaseHistoryToCase.put(cs.Id,caseHistoriesMap);
            }
            
            for(String csId : mapOfCaseHistoryToCase.keySet()) {
                Map<String, History_of_Case__c> mapOfCsHist = mapOfCaseHistoryToCase.get(csId);
                
                if(mapOfCsHist.get('oldStatus')!=null) {
                    History_of_Case__c histCs = mapOfCsHist.get('oldStatus');
                    /* if(histCs.Moved_In_Date__c.daysBetween(System.today())<1) 
                    {
                    	histCs.Number_of_days__c = mapOfCsHist.get('oldStatus').Total_No_of_Days__c;
                    } else {
						histCs.Number_of_days__c = mapOfCsHist.get('oldStatus').Total_No_of_Days__c;
                    } */
                    
                    histCs.Moved_Out_Date__c = System.today();
                    histCs.Moved_Out_DateTime__c = System.now();
                    if(mapOfCsHist.get('oldStatus').Number_of_days__c!=null) {
                        histCs.Number_of_days__c = mapOfCsHist.get('oldStatus').Number_of_days__c + 
                            (histCs.Moved_In_Date__c.daysBetween(histCs.Moved_Out_Date__c)+1);
                    } else {
                        histCs.Number_of_days__c = 0 + (histCs.Moved_In_Date__c.daysBetween(histCs.Moved_Out_Date__c)+1);
                    }
                    if(mapOfCsHist.get('oldStatus').Working_Days__c!=null) {
                        histCs.Working_Days__c = mapOfCsHist.get('oldStatus').Working_Days__c + 
                            EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(histCs.Moved_In_Date__c,histCs.Moved_Out_Date__c);
                    } else {
                        histCs.Working_Days__c = 0 + EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(histCs.Moved_In_Date__c,histCs.Moved_Out_Date__c);
                    }
                    //histCs.Working_Days__c = mapOfCsHist.get('oldStatus').Working_Days__c + 
                    //							EI_UtilityClassForPayments.calculateWorkingDaysBetweenTwoDates(histCs.Moved_In_Date__c,histCs.Moved_Out_Date__c);
                    histCs.Next_Case_Status__c = newMap.get(csId).Status;
                    
                    system.debug('Line 102 Number_of_days__c -> '+histCs.Number_of_days__c);
                    system.debug('Line 103 Total Number_of_days__c -> '+histCs.Total_No_of_Days__c);
                    
                    
                    lstCaseHistory.add(histCs);
                } else {
                    History_of_Case__c histCs = new History_of_Case__c(Case__c=csId, Case_Status__c=oldMap.get(csId).Status, Number_of_Movements__c=1, 
                                                                       Moved_Out_Date__c=System.today(), Moved_Out_DateTime__c=System.now(), 
                                                                       Next_Case_Status__c=newMap.get(csId).Status );
                    lstCaseHistory.add(histCs);
                }
                
                if(mapOfCsHist.get('newStatus')!=null) {
                    History_of_Case__c histCs = mapOfCsHist.get('newStatus');
                    histCs.Case_Status__c = newMap.get(csId).Status;
                    histCs.Previous_Case_Status__c=oldMap.get(csId).Status;
                    histCs.Moved_In_Date__c = System.today();
                    histCs.Moved_In_DateTime__c = System.now();
                    if(histCs.Moved_Out_Date__c==System.today()) {
                        histCs.Number_of_days__c = histCs.Number_of_days__c-1;
                        /*if(EI_UtilityClassForPayments.checkifItisWorkingDay(System.today(), [Select StartTimeInMinutes, Name, ActivityDate 
                          													  FROM Holiday] )) 
						{
                            if(histCs.Working_Days__c!=null) {
                                histCs.Working_Days__c = histCs.Working_Days__c-1;
                            } else {
                                histCs.Working_Days__c = 0;
                            }
                        }
                        */
                    }
                    histCs.Moved_Out_Date__c = null;
                    histCs.Moved_Out_DateTime__c = null;
                    if(histCs.Number_of_Movements__c!=null) {
                        histCs.Number_of_Movements__c = histCs.Number_of_Movements__c+1;
                    } else {
                        histCs.Number_of_Movements__c = 1;
                    }
                    histCs.Next_Case_Status__c='';
                    //histCs.Number_of_Movements__c = histCs.Number_of_Movements__c+1;
                    lstCaseHistory.add(histCs);
                    
                } else {
                    History_of_Case__c histCs = new History_of_Case__c(Case__c=csId, Case_Status__c=newMap.get(csId).Status, 
                                                                       Previous_Case_Status__c=oldMap.get(csId).Status,
                                                                       Moved_In_Date__c=System.today(), Moved_In_DateTime__c=System.now(), 
                                                                       Number_of_Movements__c=1);
                    lstCaseHistory.add(histCs);
                }
                
            }
            
            if(!lstCaseHistory.isEmpty()) {
                Savepoint sp = Database.setSavepoint();
                try {
                    upsert lstCaseHistory;
                    
                } catch(Exception e) {
                    Database.rollback(sp);
                }
            }
            
        }
        
    }
    /* For capturing time duration of Case Status on UPDATE END */
    
}