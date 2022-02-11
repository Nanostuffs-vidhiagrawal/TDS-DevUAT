trigger userTrigger on User (before insert,after update,after insert) {

    if(trigger.isbefore && trigger.isinsert ){        
            EI_UserTriggerHandler.beforeinsert(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isinsert ){        
            EI_UserTriggerHandler.afterinsert(trigger.new);
    }
    
    // This code is done for user to contact details  sync form backend//
    // Written by Himanshu Modi  27-01-2022 //
    if (Trigger.isAfter && (Trigger.isUpdate || Trigger.IsInsert)) {
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