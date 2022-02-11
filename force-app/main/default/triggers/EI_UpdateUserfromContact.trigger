/*
 *TRIGGER TO UPDATE COMMUNITY USER IF CONTACT HAS BEEN CHANGED ANY INFORMATION
  DEVELOPED BY ESPIRE
  DATE:- 27 JAN 2022
*/

trigger EI_UpdateUserfromContact on Contact (after update) {
 if (Trigger.isAfter && Trigger.isUpdate) {    
  Contact[] contObj = trigger.new;
  if(EI_RecursionUtility.isUserUpdate){       
    User userobbj = [SELECT ID, Profile.UserLicense.Name from User where Id =: Userinfo.getUserId()];
        for(Contact con : contObj) {
            if(con != null && userobbj.Profile.UserLicense.Name =='Salesforce'){
               EI_UpdateUserfromContactHandler.updateUsers(Trigger.newMap.keySet());
            }
        }
    }
  }
}