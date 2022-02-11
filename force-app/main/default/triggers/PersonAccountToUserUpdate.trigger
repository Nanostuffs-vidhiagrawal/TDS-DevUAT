Trigger PersonAccountToUserUpdate on Account (After Update) {
    
    Set<Id> ContactIdlist = new Set<Id>();
    If (Trigger.isAfter && Trigger.isUpdate) {
        Account[] Accobj = trigger.new;
        if(EI_RecursionUtility.isUserUpdate){ 
            User userobbj = [SELECT ID, Profile.UserLicense.Name from User where Id =: Userinfo.getUserId()]; 
            for(Account Acc : Accobj) {
                if(Acc.IsPersonAccount==true && userobbj.Profile.UserLicense.Name =='Salesforce'){
                    ContactIdlist.add(Acc.PersonContactId);
                }
                if(ContactIdlist.size()>0){
                    EI_UpdateUserfromContactHandler.updateUsers(ContactIdlist);
                }
            }
        }
    }
}