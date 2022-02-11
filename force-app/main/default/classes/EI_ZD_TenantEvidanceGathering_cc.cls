public class EI_ZD_TenantEvidanceGathering_cc {
   @AuraEnabled
    public static list<wrapperclass> getLoginUserDetails()
    {
        list<wrapperclass> wrprList = new list<wrapperclass>();
        
        user userdetails = [select id,profile.name,ContactId from user where id='0058E0000088sir'];//:UserInfo.getUserId()];
        List<Case_Participant__c>  caseparti = [select Id,No_of_Attempt__c,Is_Lead__c,Is_Active__c,Case__c,Contact__c,
                                                Case__r.Deposit_Account_Number__r.Property__r.Postal_Code__c,Case__r.Deposit_Account_Number__r.Name,
                                                Case__r.Deposit_Account_Number__r.Property__r.Street__c,
                                                Case__r.Deposit_Account_Number__r.Property__r.City__c,
                                                Case__r.Deposit_Account_Number__r.Property__r.Country__c,Case__r.ZD_Reference_Number__c,
                                                Case__r.Deposit_Account_Number__r.End_Date__c,
                                                Case__r.Deposit_Account_Number__r.Property_Address__c,Case__r.No_of_Tenants__c,
                                                Case__r.status
                                                from Case_Participant__c 
                                                where Contact__c=:userdetails.ContactId and  case__r.status != 'New' order by createddate desc Limit 1 ];
        wrprList.add(new wrapperclass(userdetails,caseparti));
        return wrprList;
    }
    
     @AuraEnabled
    public static list<case> getClaimDetails(String claimId)
    { 
        list<case> caseparti = [select id,casenumber, Dispute_Reasons__c, Deposit_Account_Number__c,Total_Claim_Amount__c,
                                Deposit_Account_Number__r.Name,Total_Agreed_by_Tenant__c,Respond_Date__c,TT_Made_offer__c,
                                Deposit_Account_Number__r.Property_Address__c,Deposit_Account_Number__r.Status__c, 
                                Deposit_Account_Number__r.Start_Date__c, Deposit_Account_Number__r.Deposit_Amount__c,
                                Deposit_Account_Number__r.End_Date__c,Status,TT_Offer_Amount__c,Total_Deposit__c,Total_Agreed_by_AG_LL__c,
                                AGLL_made_Offer__c,AGLL_Offer_Amount__c,ZD_Reference_Number__c,Not_reach_an_agreement_Reason_AG_LL__c,
                                Not_reach_an_agreement_Reason_Tenant__c,
                                (select id,Name,Type__c,Contact_Email__c,Is_Lead__c,Contact__r.Name, Contact__r.Phone
                                 from Case_Participants__r),
                                (select id,Name,Type__c,Agreed_by_Tenant__c,Agreed_by_AGLL__c,Adjustment_Percentage_by_AGLL__c,
                                 Claimed_by_Landlord__c,Landlord_Statement__c,Other_Reason__c,Tenant_Statement__c,Adjustment_Percentage_by_TT__c
                                 from Dispute_Items__r) 
                                from case where id=:claimId];
        return caseparti;
    }
       public class wrapperclass
    {
        @AuraEnabled public user usr{set;get;}
        @AuraEnabled public list<Case_Participant__c> Caseparticipant{set;get;}
        public wrapperclass(user usr,List<Case_Participant__c> cp)
        {
            this.usr = usr;
            this.Caseparticipant = cp;
        }
        
    }
}