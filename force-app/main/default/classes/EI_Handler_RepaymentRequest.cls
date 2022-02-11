public without sharing class EI_Handler_RepaymentRequest{
    
    public EI_Handler_RepaymentRequest(){
    
    }

    public static void afterUpdateoperation(List<Repayment_Request__c> newList,List<Repayment_Request__c> oldList,
                                            Map<Id,Repayment_Request__c> newmap,Map<Id,Repayment_Request__c> oldMap){
    Id profileId=userinfo.getProfileId();
    String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    // Notify agent/landlord when tenant request to SDS colleague
    if(profileName == 'Sds Internal User')
        EI_RepaymentRequestUtility.notifyAgent(newList,oldMap);
    
    }
    
    public static void afterInsertoperation(List<Repayment_Request__c> newList,List<Repayment_Request__c> oldList,
                                            Map<Id,Repayment_Request__c> newmap,Map<Id,Repayment_Request__c> oldMap){
    Id profileId=userinfo.getProfileId();
    String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    // Notify agent/landlord when tenant request to SDS colleague
    if(profileName == 'Sds Internal User')
        EI_RepaymentRequestUtility.notifyAgent(newList,oldMap);
    
    }



}