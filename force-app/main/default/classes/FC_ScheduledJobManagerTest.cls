/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what FC_ScheduledJobManager unit test class
 *
 * @when 06/03/2020
 */
@IsTest
public with sharing class FC_ScheduledJobManagerTest {

    @IsTest
    static void testScheduleForJobDetailNotFound() {
        try {
            System.Test.startTest();

            FC_ScheduledJobManager fcScheduledJobManager =
                    new FC_ScheduledJobManager('Not existed');

            System.Test.stopTest();

            System.assert(false);
        } catch (FC_ScheduledJobManager.FC_ScheduledJobManagerException ex) {
            System.assert(true);
        }
    }

    @IsTest
    static void testScheduleForJobDetailApexClassNotFound() {
        try {
            System.Test.startTest();

            FC_ScheduledJobManager fcScheduledJobManager =
                    new FC_ScheduledJobManager('Not Existed');

            fcScheduledJobManager.execute();
            System.Test.stopTest();

            System.assert(false);
        } catch (FC_ScheduledJobManager.FC_ScheduledJobManagerException ex) {
            System.assert(true);
        }
    }

    @IsTest
    static void testScheduleForDefaultJobDetail() {
        try {
            System.Test.startTest();
            String scheduleMasterLabel = 'ScheduledJobManager';

            Scheduled_Job_Detail__mdt scheduledJobDetail = [
                    SELECT Id, Schedule_Expression__c, Apex_Class__c, Parameters__c, Schedule_Description__c
                    FROM Scheduled_Job_Detail__mdt
                    WHERE MasterLabel = :scheduleMasterLabel
            ];

            FC_ScheduledJobManager fcScheduledJobManager =
                    new FC_ScheduledJobManager(scheduleMasterLabel);

            fcScheduledJobManager.execute();
            System.Test.stopTest();

            List<CronTrigger> cronTriggers = [
                    SELECT  Id,
                            CronExpression,
                            TimesTriggered,
                            NextFireTime
                    FROM CronTrigger
                    WHERE Id = :fcScheduledJobManager.getJobId()
            ];

            System.assertNotEquals(null, cronTriggers);
            System.assert(!cronTriggers.isEmpty());
            System.assertEquals(1, cronTriggers.size());
            System.assertEquals(scheduledJobDetail.Schedule_Expression__c, cronTriggers.get(0).CronExpression);
        } catch (FC_ScheduledJobManager.FC_ScheduledJobManagerException ex) {
            System.assert(false);
        }

    }

}