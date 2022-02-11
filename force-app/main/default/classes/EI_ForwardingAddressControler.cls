public without sharing class EI_ForwardingAddressControler {

    @AuraEnabled
    public static void updateAddress(Deposit_Allocation__c allocation,String showEmailInput, String showAddInput, String emailAddress, String houseName, String streetName, String cityName, String countryName, String postCode) {
        
        if(showEmailInput == 'Yes'){
            update new Account(Id = allocation.Deposit_Holder__c,personEmail = emailAddress);
        }else if(showAddInput == 'Yes'){
            // update Mailing address 
            
             update new Account(Id = allocation.Deposit_Holder__c,
                               personMailingStreet = houseName+', '+streetName,
                               personMailingCity = cityName,
                               //personMailingState = emailAddress,
                               personMailingPostalCode = postCode,
                               personMailingCountry = countryName);
        }
        
    }
}