public without sharing class EI_viewLandlordApex {  
    
    @AuraEnabled
    public static List<Contact> myLandlordList(String searchVar){     
        List<Contact> listlandlord = new List<Contact>();
        QueryLimits__c querylimit = [Select id,LandlordLimit__c from QueryLimits__c where name = 'All Limits'];
        Integer noOfLandlord = Integer.valueOf(querylimit.LandlordLimit__c);
       // user u  = [select id,accountid,name from user where id = :UserInfo.getUserId()];
        
        //for(Property__c acc : [select id,name,City__c,County__c,No_of_bedrooms__c  ,Is_Furnished__c,No_of_living_rooms__c,Town__c, Country__c, Property_Owner__c, Postal_Code__c from Property__c 
         //                      where Property_Owner__c = :u.AccountId   LIMIT 500])
      String searchTxt;
        searchTxt = '%' + searchVar + '%';
        system.debug(' searchVar '+searchVar);
            
        if(searchVar != '' || searchVar != null){
            
         for(Contact con : [select id ,FirstName,LastName,Account_Status__c ,Phone,Email,LandLord_Registration_Number__c,LandLord_Registration_Status__c,AddressFormula__c,Account.Deposit_Protections__c,Account.Number_of_Properties__c from Contact  where (name like : searchTxt OR LandLord_Registration_Number__c = : searchTxt OR AddressFormula__c like : searchTxt OR Phone = : searchTxt) and CreatedById = :UserInfo.getUserId() and Account.RecordType.Name = 'Individual Landlord' LIMIT : noOfLandlord]){
            listlandlord.add(con);        
        }   
        }else{
         for(Contact con : [select id ,FirstName,LastName,Account_Status__c ,Phone,Email,LandLord_Registration_Number__c,LandLord_Registration_Status__c,AddressFormula__c,Account.Deposit_Protections__c,Account.Number_of_Properties__c from Contact  where CreatedById = :UserInfo.getUserId() and Account.RecordType.Name = 'Individual Landlord' and Account_Status__c != '' LIMIT :noOfLandlord]){
            listlandlord.add(con);        
        }
        }
        return listlandlord;
    }
}