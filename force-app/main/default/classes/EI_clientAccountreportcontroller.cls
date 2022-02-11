public class EI_clientAccountreportcontroller {

@AuraEnabled
    public static List<deposit__c> fetchdeposit(String startDate,String endDate){
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        Date startDateValue, endDateValue;
		if(String.IsNotBlank(startDate)){
			startDateValue = Date.valueOf(startDate);
            system.debug('line-->9'+startDateValue);
		}
		if(String.IsNotBlank(endDate)){
			endDateValue = Date.valueOf(endDate);
            system.debug('lne-->13'+startDateValue);
		}
        List<Deposit__c> depositList = new List<Deposit__c>();
        if(startDateValue==null && endDateValue==null){
            for(deposit__c dep : [select Id,Deposit_Account_Number__c, Property_Address__c, Deposit_Amount__c,Member_s_Own_Deposit_Reference__c,Amount_paid_to_tenant__c,Amount_paid_to_Landlord__c,
                              Scheme__r.name,Customer__r.name,Tenants_Name__c,Case_Status__c,Protected_Amount__c,Start_Date__c,End_Date__c,Date_Paid_to_Landlord__c from Deposit__c where Customer__c =:accountid
                             ]){
                    depositList.add(dep);
            }
        }
        else  if(startDateValue!=null && endDateValue==null){
            for(deposit__c dep : [select Id,Deposit_Account_Number__c, Property_Address__c, Deposit_Amount__c,Member_s_Own_Deposit_Reference__c,Amount_paid_to_tenant__c,Amount_paid_to_Landlord__c,
                              Scheme__r.name,Customer__r.name,Tenants_Name__c,Case_Status__c,Protected_Amount__c,Start_Date__c,End_Date__c,Date_Paid_to_Landlord__c from Deposit__c where Customer__c =:accountid
                             and Protection_Start_Date__c<=:startDateValue]){
                    depositList.add(dep);
            }
        }
        else if(startDateValue==null && endDateValue!=null){
            for(deposit__c dep : [select Id,Deposit_Account_Number__c, Property_Address__c, Deposit_Amount__c,Member_s_Own_Deposit_Reference__c,Amount_paid_to_tenant__c,Amount_paid_to_Landlord__c,
                              Scheme__r.name,Customer__r.name,Tenants_Name__c,Case_Status__c,Protected_Amount__c,Start_Date__c,End_Date__c,Date_Paid_to_Landlord__c from Deposit__c where Customer__c =:accountid
                             and Protection_Start_Date__c>=:endDateValue]){
                    depositList.add(dep);
            }
        }
        else if(startDateValue!=null && endDateValue!=null){
            for(deposit__c dep : [select Id,Deposit_Account_Number__c, Property_Address__c, Deposit_Amount__c,Member_s_Own_Deposit_Reference__c,Amount_paid_to_tenant__c,Amount_paid_to_Landlord__c,
                              Scheme__r.name,Customer__r.name,Tenants_Name__c,Case_Status__c,Protected_Amount__c,Start_Date__c,End_Date__c,Date_Paid_to_Landlord__c from Deposit__c where Customer__c =:accountid
                             and Protection_Start_Date__c >=:startDateValue and Protection_Start_Date__c<=:endDateValue]){
                    depositList.add(dep);
            }
        }
        
        system.debug('line-->10'+depositList);
        return depositList;        
    }
}