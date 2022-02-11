trigger EI_ZD_Adjudication_ReportTrigger on Adjudication_Report__c (before update,after Update) {
    
    if(trigger.isUpdate && trigger.isbefore)
    EI_ZD_AdjudicationReportHandler.beforeUpdate(trigger.new, Trigger.oldMap);
    
    
    if(trigger.isUpdate && trigger.isAfter)
        EI_ZD_AdjudicationReportHandler.afterUpdate(trigger.new, Trigger.oldMap);

}