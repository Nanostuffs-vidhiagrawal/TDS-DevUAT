global class EI_ScheduleReminderEmail implements Schedulable {
    
   // public static String sched = '0 00 00 * * ?';  //Every Day at Midnight 
    
    /*global static String scheduleMe() {
        EI_batchlandlordassistance SC = new EI_batchlandlordassistance(); 
        return System.schedule('My batch Job', sched, SC);
    } 
    
    */
    global void execute(SchedulableContext sc) {
        
        EI_BatchLandlordAssistance b1 = new EI_BatchLandlordAssistance();
        ID batchprocessid = Database.executeBatch(b1,50);           
    }
}