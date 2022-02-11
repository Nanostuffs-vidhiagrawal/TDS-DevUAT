public without sharing class EI_CreateAdjudicationReportRecordCls {
    
    @AuraEnabled
    public static List<Case> getCaseRecord(String caseId) {
        return [Select Id, Status, No_Landlord_Evidence__c, No_Tenant_Evidence__c from Case where Id=:caseId limit 1];
    }
    
    @AuraEnabled
    public static String createAdjReportRec (String caseId, String decisionType) 
    {
        System.debug('Line 6');
        List<Case> cs = [Select Id, Remaining_protected_amount__c, (Select Id, Name, Dispute_Amount__c, Type__c from Dispute_Items__r) 
                         from Case where Id =: caseId limit 1];
        Id devRecordTypeId = Schema.SObjectType.Adjudication_Report__c.getRecordTypeInfosByName().get('SDS Adjudication Report').getRecordTypeId();
        System.debug('Line 10');
        Adjudication_Report__c adjRepRecord = new Adjudication_Report__c();
        if(!cs.isEmpty()) 
        {
            adjRepRecord.Dispute__c = caseId;
            adjRepRecord.Status__c = 'Draft';
            adjRepRecord.Decision_Type__c = decisionType;
            adjRepRecord.RecordTypeId =devRecordTypeId;
            
            /* Inserting adjudication report record */
            try { 
                insert adjRepRecord;
            } catch(Exception e) {
                String strError = 'The following exception has occurred: '+e.getMessage();
                System.debug('The following exception has occurred: ' + e.getMessage());
                return strError;
            }
            
            System.debug('Line 18 -> '+adjRepRecord.Id+' '+adjRepRecord);
            if(adjRepRecord.Id!=null) {
                Id ARRecordTypeId = Schema.SObjectType.Adjudication_Report_Item__c.getRecordTypeInfosByName().get('SDS Adjudication Report Item').getRecordTypeId();
                
                List<Adjudication_Report_Item__c> adjReportItems = new List<Adjudication_Report_Item__c>();
                
                for(Dispute_Item__c disItem :  cs[0].Dispute_Items__r)
                {System.debug('Line 24 -> '+disItem.Id+' '+disItem);
                    Adjudication_Report_Item__c adjRepItem = new Adjudication_Report_Item__c();
                    
                    if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Cleaning' )
                    {
                        adjRepItem.Type__c = 'Cleaning' ;
                        adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                        adjRepItem.Dispute_Item__c = disItem.Id;
                        adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                        adjRepItem.RecordTypeId =ARRecordTypeId;
                        adjReportItems.add(adjRepItem);
                    }
                    if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Damage' )
                    {
                        adjRepItem.Type__c = 'Damage' ;
                        adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                        adjRepItem.Dispute_Item__c = disItem.Id;
                        adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                        adjRepItem.RecordTypeId =ARRecordTypeId;
                        adjReportItems.add(adjRepItem);
                    }
                    if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Gardening' )
                    {
                        adjRepItem.Type__c = 'Gardening' ;
                        adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                        adjRepItem.Dispute_Item__c = disItem.Id;
                        adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                        adjRepItem.RecordTypeId =ARRecordTypeId;
                        adjReportItems.add(adjRepItem);
                    }
                    if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Rent' )
                    {
                        adjRepItem.Type__c = 'Rent' ;
                        adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                        adjRepItem.Dispute_Item__c = disItem.Id;
                        adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                        adjRepItem.RecordTypeId =ARRecordTypeId;
                        adjReportItems.add(adjRepItem);
                    }
                    if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Redecoration' )
                    {
                        adjRepItem.Type__c = 'Redecoration' ;
                        adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                        adjRepItem.Dispute_Item__c = disItem.Id;
                        adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                        adjRepItem.RecordTypeId =ARRecordTypeId;
                        adjReportItems.add(adjRepItem);
                    }
                    if(disItem.Dispute_Amount__c > 0 && disItem.Type__c == 'Other' )
                    {
                        adjRepItem.Type__c = 'Other' ;
                        adjRepItem.Adjudication_Report__c = adjRepRecord.Id; 
                        adjRepItem.Dispute_Item__c = disItem.Id;
                        adjRepItem.Disputed_Amount__c = disItem.Dispute_Amount__c;
                        adjRepItem.RecordTypeId =ARRecordTypeId;
                        adjReportItems.add(adjRepItem);
                    }
                    
                }
                System.debug('Line 71 -> '+adjReportItems);
                if(!adjReportItems.isEmpty())
                {
                    insert adjReportItems;
                }
                
            }
                
        }
        
        cs[0].Total_Claim_Amount__c = cs[0].Remaining_protected_amount__c;
        update cs[0];
        
        return adjRepRecord.Id; 
    }
    
}