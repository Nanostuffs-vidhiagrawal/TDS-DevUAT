public without sharing class EI_ZD_CommonHeader_cc {
    
    @AuraEnabled
    public static String getTenantDetails(String urlID,String userType){
        system.debug(userType);
        system.debug(urlID);
       if(userType == 'agent'){
            List<Case_Participant__c>  tenantList = [SELECT Id, Account__r.Name FROM Case_Participant__c WHERE Access_Code__c = :urlID];
           system.debug(tenantList);
            if(tenantList.size()>0){
                return tenantList[0].Account__r.Name ;
            }
        }
         if(userType == 'tenant'){
            return userInfo.getName();
        }
        return null;
    }
    
}