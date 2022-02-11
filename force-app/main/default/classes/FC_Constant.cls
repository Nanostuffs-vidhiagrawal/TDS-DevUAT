/**
 * @who  Tiago Lopes <tiago.lopes@weare4c.com>
 * @what Constant placeholder class
 * @when 7/10/2019
 */
public with sharing class FC_Constant {
    public static final String Case_Status_New = 'New';
    public static final String Case_Status_On_Hold = 'On Hold';
    public static final String Case_Status_Review_Complete = 'Review Complete';
    public static final String Case_Status_Awaiting_Review = 'Awaiting Review';
    public static final String Case_Status_Evidence_Gathering_LL = 'Evidence Gathering - LL';
    public static final String Case_Status_Evidence_Gathering_TT = 'Evidence Gathering - TT';
    public static final String Case_Status_Adjudication = 'Adjudication';
    public static final String Case_Status_Closed = 'Closed';
    public static final String CaseMilestone_Type_Adjudication = 'Adjudication';
    public static final String CaseMilestone_Type_Evidence_Gathering_TT = 'Evidence Gathering TT';
    public static final String CaseMilestone_Type_Evidence_Gathering_LL = 'Evidence Gathering LL';
    public static final String Dispute_Item_Type_Damage = 'Damage';

    public static final String Entitlement_Dispute_EW_Insured = 'Dispute EW Insured';

    //same RecordType to Entitlements custom metadata with 'IsTest' checkbox checked
    //should be present in the custom metadata for record type Dispute EW Insured
    public static final String Entitlement_Dispute_EW_Insured_TEST_ENTITLEMENT_NAME = 'Dispute EW Insured TEST';

    public static final String Evidence_Attachment_User_Type_Landlord = 'Landlord';
    public static final String Evidence_Attachment_User_Type_Tenant = 'Tenant';
    public static final String Evidence_Attachment_User_Type_Agent = 'Agent';

    public static final String Allocation_And_Participant_Role_Tenant = 'Tenant';
    public static final String Allocation_And_Participant_Role_Landlord = 'Landlord';
    public static final String Allocation_And_Participant_Role_Agent = 'Agent';

    public static final String Case_Close_Reason_Adjudication_Decision_Reached = 'Adjudication decision reached';

    public static final String Adjudication_Report_Status_Published = 'Published';
    
    public static final String Agent_Work_Status_Assigned = 'Assigned';
    public static final String Agent_Work_Status_Opened = 'Opened';
    
    public static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    public static final String CONTENT_TYPE_APPLICATION_XML = 'application/xml';
    public static final String CONTENT_TYPE_APPLICATION_PDF = 'application/pdf';
    public static final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HEADER_ACCEPT = 'Accept';
    public static final String HEADER_ACCESS_TOKEN = 'AccessToken';
    public static final String HEADER_AUTHORIZATION = 'Authorization';
    public static final String HTTP_POST_METHOD = 'POST';
    public static final String HTTP_GET_METHOD = 'GET';
    public static final String ACCEPT_ANY = '*/*';
    
    public static final String CaseTeamRole_DRE = 'DRE';
    public static final String CaseTeamRole_DreAdjudication = 'DRE/Adjudicator';

    public static final String RecordType_Dispute_EW_Insured_Dev_Name = 'Dispute_EW_Insured';
    public static final String RecordType_Zero_Deposit_Dispute_Dev_Name = 'Zero_Deposit_Dispute';

    public static final String TEST_CLIENT_APIACCOUNTID = 'ZeroDeposit';
    public static final String TEST_CLIENT_ID = 'ksr4333432dds';
    public static final String TEST_CLIENT_SECRET = 'weare4c2019';
    
    public static final String Despoit_Scheme_England_And_Wales_Insured = 'England & Wales Insured';
    public static final String Region_England_And_Wales = 'England & Wales';
    public static final String RecordType_Account_Individual_Landlord = 'Individual_Landlord';
    public static final String RecordType_Account_Tenant = 'Person';
    
    public static final String Internal_Error_Message = 'Internal error has occurred, please contact TDS.';
    public static final String HMAC_SHA1_MAC_ENCRYPTION = 'hmacSHA1';
    public static final String CASE_UPDATE_EVENT_WEBHOOK_TYPE = 'Case Status Update';
    public static final String ADJUDICATION_RESULTS_EVENT_WEBHOOK_TYPE = 'Adjudication Results';
    
    public static final String LOG_TYPE_SPRINGCM = 'SpringCM';
    public static final String LOG_TYPE_ERRORLOG = 'ErrorLog';
    public static final String LOG_TYPE_WEBHOOKLOG = 'WebhookLog';
    public static final String LOG_TYPE_DISPUTEAPILOG = 'DisputeApiErrorLog';

    public static final String NO_SCHEDULED_JOB_DETAIL_FOR_MASTER_LABEL = 'There is no Scheduled Job Detail for given Master Label';
    public static final String THERE_IS_MORE_THAN_ONE_JOB_DETAIL_FOR_MASTER_LABEL = 'There is more than one Scheduled Job Detail for given Master Label';
    public static final String APEX_CLASS_FROM_SCHEDULED_DETAIL_NOT_FOUND = 'Apex class from Scheduled Details Job was not found';
}