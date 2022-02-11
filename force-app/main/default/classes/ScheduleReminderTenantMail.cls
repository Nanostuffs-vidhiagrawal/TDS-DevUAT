global class ScheduleReminderTenantMail implements Schedulable{

  /*
    Run every 30 mins on Tuesady and Wednesday. 
  */
  //public static final String CRON_EXPR = '0 0,30 * ? * TUE-WED';
  
    global void execute(SchedulableContext SC) {
        SendAutoRemainderToTenant sendReminderMail = new SendAutoRemainderToTenant(); 
        database.executebatch(sendReminderMail,200);
    }
}