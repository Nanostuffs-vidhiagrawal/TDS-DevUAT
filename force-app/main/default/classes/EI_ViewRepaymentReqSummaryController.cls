public without sharing class EI_ViewRepaymentReqSummaryController {

    @AuraEnabled
    public static List<Repayment_Request__c> fetchRepaymentrecord(String depositId) {
        try{
            List<Repayment_Request__c> repayList = 
                [SELECT Total_Amount_Offer_from_AALL_To_Tenant__c,Deposit__r.Customer__c,Deposit__r.Customer__r.IspersonAccount, AL_CleaningAmt__c, 
                 AL_DmgPropAmt__c, AL_GardeningAmt__c, AL_OtherAmt__c, AL_Other_Reason__c, AL_RedecorationAmt__c, AL_Rent_Arrears__c, 
                 AL_Repay_Requested__c, Account__c, Account__r.Name, Deposit__r.Protected_Amount__c, Deposit__c, Deposit__r.name, 
                 Tenancy_End_Date__c, Tenant_Cleaning__c, Tenant_Dmg_to_Property__c, Contact__c, Contact__r.Name, Deposit__r.Payment_Received_By_Scheme__c,
                 Tenant_Gardening__c, Tenant_Other_Reason__c, Tenant_Other__c, Tenant_Redecoration__c, Tenant_Rent_Arrears__c, Total_Amount_By_Tenant__c, 
                 Tenant_Repay_Requested__c, Total_Amount_Requested_AL__c, Status__c, Tenancy_End_Date_Agent__c, Total_Amount_By_Agent_Landlord__c, 
                 Deposit__r.Customer__r.Name,
                 (SELECT AL_ReqAmt__c, Account__c,Repayment_Request__r.Deposit__r.Customer__r.PersoncontactId, Repayment_Request__r.Deposit__c, 
                  Repayment_Request__r.Deposit__r.Customer__c,Repayment_Request__r.Deposit__r.Customer__r.IspersonAccount, Contact__c, 
                  Repayment_Request__r.Contact__c, Repayment_Request__r.Account__c, Repayment_Request__r.Deposit__r.name, Account__r.PersonContactId, 
                  Account__r.Name, Tenant_ReqAmt__c, Repayment_Request__r.Deposit__r.Payment_Received_By_Scheme__c FROM Repayment_Request_Lines__r 
                  where Account__r.RecordType.Name IN ('Tenant'))
                 FROM Repayment_Request__c WHERE Deposit__c = :depositId and Status__c IN ('Repayment requested - agent/landlord', 
                  'Repayment requested - tenant') limit 1];
            System.debug('Line 19 - '+repayList);
            return repayList;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}