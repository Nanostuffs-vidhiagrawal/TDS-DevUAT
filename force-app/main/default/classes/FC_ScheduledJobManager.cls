/**
 * @who  Hubert Jaskolski <hubert.jaskolski@weare4c.com>
 * @what Implementation, which works as a main dispatcher of scheduled jobs basing on Scheduled_Job_Detail__mdt custom
 * metadata.
 *
 * @when 06/03/2020
 */
public with sharing class FC_ScheduledJobManager {
    private Scheduled_Job_Detail__mdt scheduledJobDetail;
    private String jobId;

    /**
     * Getter for jobId received after scheduling job
     *
     * @return jobId
     */
    public String getJobId() {
        return this.jobId;
    }

    /**
     * Constructor with masterLabel, invokes setScheduledJobDetail method
     *
     * @param masterLabel
     */
    public FC_ScheduledJobManager(String masterLabel) {
        setScheduledJobDetail(masterLabel);
    }

    /**
    * Set scheduledJobDetail custom metadata. Throws custom exception when there is
    * no Scheduled_Job_Detail__mdt for given param or number of found records is bigger than one.
    *
    * @param masterLabel
    */
    private void setScheduledJobDetail(String masterLabel) {
        List<Scheduled_Job_Detail__mdt> scheduledJobDetails = queryScheduledJobDetails(masterLabel);

        if (scheduledJobDetails == null || scheduledJobDetails.isEmpty()) {
            throw new FC_ScheduledJobManagerException(FC_Constant.NO_SCHEDULED_JOB_DETAIL_FOR_MASTER_LABEL);
        } else if (scheduledJobDetails.size() > 1) {
            throw new FC_ScheduledJobManagerException(FC_Constant.THERE_IS_MORE_THAN_ONE_JOB_DETAIL_FOR_MASTER_LABEL);
        } else {
            this.scheduledJobDetail = scheduledJobDetails.get(0);
        }
    }

    /**
    * Query Scheduled_Job_Detail__mdt custom metadata basing on given Master Label
    *
    * @param masterLabel
    *
    * @return List<Scheduled_Job_Detail__mdt>
    */
    private List<Scheduled_Job_Detail__mdt> queryScheduledJobDetails(String masterLabel) {
        return [
                SELECT Id,
                        Apex_Class__c,
                        Parameters__c,
                        Schedule_Description__c,
                        Schedule_Expression__c,
                        DeveloperName,
                        MasterLabel
                FROM Scheduled_Job_Detail__mdt
                WHERE MasterLabel = :masterLabel
        ];
    }

    /**
     * Schedule job basing on initiated Scheduled_Job_Detail__mdt. Throws exception when Apex Class given in
     * Scheduled_Job_Detail__mdt was not found.
     */
    public void execute() {
        Type scheduledClassType = Type.forName(this.scheduledJobDetail.Apex_Class__c);

        if (scheduledClassType != null) {

            Schedulable scheduledInstance =
                    (Schedulable) JSON.deserialize(this.scheduledJobDetail.Parameters__c, scheduledClassType);

            this.jobId = System.schedule(
                    this.scheduledJobDetail.MasterLabel,
                    this.scheduledJobDetail.Schedule_Expression__c,
                    scheduledInstance
            );
        } else {
            throw new FC_ScheduledJobManagerException(FC_Constant.APEX_CLASS_FROM_SCHEDULED_DETAIL_NOT_FOUND);
        }
    }


    public class FC_ScheduledJobManagerException extends Exception {
    }
}