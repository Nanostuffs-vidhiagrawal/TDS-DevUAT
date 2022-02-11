/*
 *TRIGGER TO UPDATE CONTACT IF COMMUNITY USER HAS BEEN CHANGED ANY INFORMATION
  DEVELOPED BY ESPIRE
  DATE:- 27 JAN 2022
*/
trigger EI_UpdateContactfromCommunityUser on User (after update) {
     if (Trigger.isAfter && Trigger.isUpdate) {
     User[] users = trigger.new;
    if(EI_RecursionUtility.isUserUpdate){       
        User userobbj = [SELECT ID, Profile.UserLicense.Name from User where Id =: Userinfo.getUserId()];
        system.debug('line-->10' + userobbj.Profile.UserLicense.Name);
           for (User userObj: users) {
               if(userObj.ContactId!=null && userobbj.Profile.UserLicense.Name =='Salesforce' && userObj.IsPortalEnabled == true)
               {
                  EI_UpdateContactforCommunityUserHandler.updateContacts(Trigger.newMap.keySet());
               }
           }
      }
    } 
}