trigger ContactTrigger on Contact (before insert,after update) {
    
  if(trigger.isbefore && trigger.isinsert ){        
        ContactTriggerHandler.handleBeforeInsert(trigger.new);        
    }
 
    // This code is done for contact to user details  sync form backend//
    // Written by Himanshu Modi  27-01-2022 //
    // ,after update

    if (Trigger.isAfter && Trigger.isUpdate) {   
        system.debug('line-->11');
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