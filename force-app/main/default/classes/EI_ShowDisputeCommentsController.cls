public without sharing class EI_ShowDisputeCommentsController {
	@AuraEnabled
    public static Dispute_Item__c getDisputeItem(String recId){
        
        list<Dispute_Item__c> itemList = [select id,Type__c,RecordType.Name,Claim_description_for_cleaning_agll__c,Supporting_clause_cleaning_agll__c,Evidence_at_tenancystart_cleaning_agll__c,Evidence_at_tenancy_end_for_cleaning_agl__c,Supporting_evidence_for_cleaning_agll__c,Claim_description_for_damage_agll__c,Supporting_clause_damage_agll__c,Evidence_at_tenancystart_damage_agll__c,Evidence_at_tenancy_end_for_damage_agll__c,Claim_description_for_gardening_agll__c,Supporting_clause_gardening_agll__c,Evidence_at_tenancystart_gardening_agll__c,Evidence_at_tenancyend_gardening_agll__c,Supporting_evidence_for_gardening__c,Rent_arrears_description_agll__c,Was_the_property_re_let_rent_agll__c,Supporting_clause_rent_agll__c,Supporting_evidence_for_rent_agll__c,Claim_description_for_redecoration_agll__c,Supporting_clause_redecoration_agll__c,Evidence_at_tenancystart_redecoration_ag__c,Evidence_at_tenancyend_redecoration_agll__c,Supporting_evidence_for_redecoration_agl__c,Claim_breakdown_other_AGLL__c,Supporting_clause_other_agll__c,Supporting_evidence_for_other_agll__c from Dispute_Item__c where Id =: recId limit 1];
		        
        if(itemList.isEmpty()){
            return new Dispute_Item__c();
        }else{
            return itemList[0];
        }
        
        
    }
}