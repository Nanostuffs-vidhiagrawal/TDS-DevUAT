public class EI_ScheduleTenantDepositReminder implements Schedulable {
    
     public void execute(SchedulableContext sc) {
        
        EI_TenantDepositReminderBatchApex b1 = new EI_TenantDepositReminderBatchApex();
        ID batchprocessid = Database.executeBatch(b1,200);           
    }

}