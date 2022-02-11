trigger EI_Trigger_Adjudication_Report_Item on Adjudication_Report_Item__c (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        EI_Adjudication_Report_Item_Helper.updateExternalIdFields(Trigger.New);
    }
}