global class EI_ZD_BatchScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        database.executeBatch(new EI_ZD_UpdateStatusBatch(), 50);
    }

}