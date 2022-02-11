public class EI_tenantusercreatehandler {
    @future
    public static void updateUser(Set<ID> userIds){
        
        List<User> userList = [Select id,IsActive from User where id =: userIds and isActive = false];
        for(User u: userList){
            u.isActive = true;
        }
        update userList;
    }
    
    public static void createuser (list<Deposit__c> depositlist){
        Map<String, String>  userMap = new Map<String, String>(); 
        Map<String, String>  userOldDataMap = new Map<String, String>();        
        List<Deposit_Allocation__c> depositwithMatcheduserList = new List<Deposit_Allocation__c>();
        list<user> newuserlist = new list<user>();
        set<Id> inactiveUerlist = new set<Id>();
        Map<String,Id> mapOfemailVsAccId = new Map<String,Id>();
        Map<String,String> mapOfemailVsAccName = new Map<String,String>();
        list<Deposit_Allocation__c> depositListItem = [SELECT id,Deposit__c,Role__c,Contact__c,Contact__r.AccountId,
                                                       Deposit_Holder__c,Deposit_Holder__r.Phone, 
                                                       Deposit_Holder__r.PersonContactId,  Deposit_Holder__r.Name,
                                                       Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName, 
                                                       Deposit_Holder__r.lastname,Deposit_Holder__r.PersonEmail,
                                                       Deposit_Holder__r.Activation_Code__pc,
                                                       Deposit_Holder__r.IsCustomerPortal,
                                                       Contact__r.Name, contact__r.Email
                                                       FROM Deposit_Allocation__c 
                                                       WHERE Deposit__c in :depositlist AND  role__c='tenant']; 
                                                    //   AND Deposit_Holder__r.IsCustomerPortal=false
        
        for(Deposit_Allocation__c da: depositListItem){
            if(da.Deposit_Holder__r.IsCustomerPortal=false){
                 userMap.put(da.Deposit_Holder__r.PersonEmail,da.Deposit_Holder__r.Name);
            }
           else if(da.Deposit_Holder__r.IsCustomerPortal=true){
            system.debug('$$inelse if');
                userOldDataMap.put(da.Deposit_Holder__r.PersonEmail,da.Deposit_Holder__r.Name);
           }
            
        }
        system.debug('$$userOldDataMap'+userOldDataMap);
        List<User> userList;
        
        List<User> userOldList;
                Map<String, User> userInSystemMap = new Map<String, User>();
         Map<String, User> userInSystemMapOld = new Map<String, User>();
          Map<String, User> userInActiveMapOld = new Map<String, User>();
       
        if(userMap.size()>0){
            userList = [SELECT Id, Name, email, contactId, accountId,IsActive
                               FROM User
                               WHERE email in:userMap.keySet()
                              ];
                              
            for(User u: userList){
            userInSystemMap.put(u.email, u);
      
            }
        }
        if(userOldDataMap.size()>0){
            userOldList = [SELECT Id, Name, email, contactId, accountId,IsActive
                               FROM User
                               WHERE email in:userOldDataMap.keySet()
                              ];
                              
             for(User u: userOldList){
               
                if(u.IsActive == false){
                    userInActiveMapOld.put(u.email, u); 
                    
                }
                 if(u.IsActive == true){
                     userInSystemMapOld.put(u.email, u); 
                 }
            }
        }
        system.debug('$$userInSystemMapOld '+userInSystemMapOld);

        for(Deposit_Allocation__c depall:depositListItem){
            system.debug(userInSystemMapOld.containsKey(depall.Deposit_Holder__r.PersonEmail)+' $$77 '+depall.Deposit_Holder__r.PersonEmail);
             if(userInSystemMapOld.containsKey(depall.Deposit_Holder__r.PersonEmail) ){
                  mapOfemailVsAccId.put( depall.Deposit_Holder__r.PersonEmail,depall.Deposit_Holder__r.Id);
                mapOfemailVsAccName.put( depall.Deposit_Holder__r.PersonEmail,depall.Deposit_Holder__r.Name);
             }
             else if (userInActiveMapOld.containsKey(depall.Deposit_Holder__r.PersonEmail) ){
              inactiveUerlist.add(userInActiveMapOld.get(depall.Contact__r.Email).id);
            }
            else if(userInSystemMap.containsKey(depall.Deposit_Holder__r.PersonEmail) ){
                depall.Contact__c = userInSystemMap.get(depall.Deposit_Holder__r.PersonEmail).contactId;
                depall.Deposit_Holder__c = userInSystemMap.get(depall.Deposit_Holder__r.PersonEmail).AccountId;
                depositwithMatcheduserList.add(depall);
               
                //   EI_AddDeposit.notifyExistingTenant(mapOfemailVsAccId,mapOfemailVsAccName,Depositnumber);
            }
            else if (depall.Deposit_Holder__r.PersonEmail ==null && depall.Deposit_Holder__r.Phone !=null ){
                mailJetSMSService.smstotenant(depall.Deposit_Holder__r.Phone,depall.Deposit_Holder__r.Activation_Code__pc);
            }
            else{
                User u = new User();
                // Alias Check
                String fullName = depall.Deposit_Holder__r.FirstName + depall.Deposit_Holder__r.lastname;
                if (fullName.length() >= 5){
                    u.alias = fullName.substring(0, 4);
                } else{
                    u.alias = fullName;
                }
                
                // NickName Check
                if(depall.Deposit_Holder__r.FirstName!=null){
                    String nickname = ((depall.Deposit_Holder__r.FirstName != null && depall.Deposit_Holder__r.FirstName.length() > 0) ? depall.Deposit_Holder__r.FirstName.substring(0, 1) : '')+depall.Deposit_Holder__r.FirstName.substring(0, 1);
                    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                    u.CommunityNickname = nickname;
                }
                else{
                    String nickname = ((depall.Deposit_Holder__r.lastname != null && depall.Deposit_Holder__r.lastname.length() > 0) ? depall.Deposit_Holder__r.lastname.substring(0, 1) : '')+depall.Deposit_Holder__r.lastname.substring(0, 1);
                    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                    u.CommunityNickname = nickname;   
                }
                
                // Username Check
                
                u.Title = depall.Deposit_Holder__r.Salutation;
                u.FirstName = depall.Deposit_Holder__r.FirstName;
                u.LastName = depall.Deposit_Holder__r.lastname;
                
                // Uncomment
                u.Username = depall.Deposit_Holder__r.PersonEmail;
                u.Phone = depall.Deposit_Holder__r.Phone;
                
                //u.Username = con.Email + 'abc';
                u.Email = depall.Deposit_Holder__r.PersonEmail;
                u.ProfileId = [Select Id,name from profile where name = 'Tenant' limit 1].Id;
                // u.profileId = ut.ProfileId;
                
                
                u.TimeZoneSidKey = 'Europe/London';
                u.LocaleSidKey = 'en_GB';
                u.LanguageLocaleKey = 'en_US';
                u.ContactId = depall.Deposit_Holder__r.PersonContactId;
                u.User_Type__c='Tenant';
                u.EmailEncodingKey = 'ISO-8859-1';
                // u.Addition_Permission__c = userpermission;
                //  u.User_Role__c = jobrole;
                // insert u;
                newuserlist.add(u); 
            }
            
        }
        if(depositwithMatcheduserList.size()>0){
            update depositwithMatcheduserList;
         //   EI_AddDeposit.notifyExistingTenant(mapOfemailVsAccId,mapOfemailVsAccName);
        }
        if(userInSystemMapOld.size()>0){
             EI_AddDeposit.notifyExistingTenant(mapOfemailVsAccId,mapOfemailVsAccName);
        }
        
        System.debug('@@ newuserlist '+newuserlist);
        System.debug('@@ inactiveUerlist '+inactiveUerlist);
        if(newuserlist.size()>0){
            insert  newuserlist;
        }
        if(inactiveUerlist.size()>0){
            updateUser(inactiveUerlist);
        }
        
    }
    public static void createuserNew (list<Deposit__c> depositlist,set<Id> depositIds){
       List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Map<String, String>  userMap = new Map<String, String>(); 
        Map<String, String>  userOldDataMap = new Map<String, String>();        
        List<Deposit_Allocation__c> depositwithMatcheduserList = new List<Deposit_Allocation__c>();
        list<user> newuserlist = new list<user>();
        set<Id> inactiveUerlist = new set<Id>();
        Map<String,Id> mapOfemailVsAccId = new Map<String,Id>();
        Map<String,String> mapOfemailVsAccName = new Map<String,String>();
        //set of Email IDs
        set<String> emailIds = new set<String>();
        set<string> mergeAllocationIds = new set<String>();
        map<string,Decimal> emailVsCounter = new map<String,Decimal>();
        set<string> flagEmails = new set<string>();
        map<string,list<Deposit_Allocation__c>> emailVslistDepositAllocation = new map<String,list<Deposit_Allocation__c>>();
        list<Deposit_Allocation__c> depositAllocationToUpdate = new list<Deposit_Allocation__c>();
        list<Deposit_Allocation__c> depositAllocationToUpdate2 = new list<Deposit_Allocation__c>();
        map<Id,Id> allocationVsAccountId = new map<Id,Id>();
        list<Account> accountsToDelete = new list<Account>(); 
        map<Id,Deposit_Allocation__c> idVsAllocation = new map<Id,Deposit_Allocation__c>();
           set<String> userDeposit = new set<String>(); 
        list<User> updatePaymentVariable = new list<User>();     
        
        for(Deposit__c dep: depositlist){
            if(dep.DepositProtectedByUser__c != ''){
                  userDeposit.add(dep.DepositProtectedByUser__c);
            }
          
        }
        

      system.debug('@@userDeposit '+userDeposit);
        for(User u: [Select id,Move_To_Certificate_Payment__c from User where ContactId in: userDeposit and ContactId != null]){
            u.Move_To_Certificate_Payment__c = false;
            updatePaymentVariable.add(u);
        }
        list<Deposit_Allocation__c> depositListItem = [SELECT id,Deposit__c,Role__c,Contact__c,Contact__r.AccountId,
                                                       Deposit_Holder__c,Deposit_Holder__r.Phone, 
                                                       Deposit_Holder__r.PersonContactId,  Deposit_Holder__r.Name,
                                                       Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName, 
                                                       Deposit_Holder__r.lastname,Deposit_Holder__r.PersonEmail,
                                                       Deposit_Holder__r.Activation_Code__pc,
                                                       Deposit_Holder__r.IsCustomerPortal,
                                                       Contact__r.Name, contact__r.Email,Deposit__r.Deposit_Account_Number__c,
                                                            Deposit__r.Property_Address__c
                                                       FROM Deposit_Allocation__c 
                                                       WHERE Deposit__c in :depositlist AND  role__c='tenant']; 
                                                    //   AND Deposit_Holder__r.IsCustomerPortal=false
        
        

        
        
        for(Deposit_Allocation__c da: depositListItem){
            
            if(da.Deposit_Holder__r.IsCustomerPortal=false){
                 userMap.put(da.Deposit_Holder__r.PersonEmail,da.Deposit_Holder__r.Name);
            }
            else if(da.Deposit_Holder__r.IsCustomerPortal=true){
                system.debug('$$inelse if');
                userOldDataMap.put(da.Deposit_Holder__r.PersonEmail,da.Deposit_Holder__r.Name);
            }

            if(String.isNotBlank(da.Deposit_Holder__r.PersonEmail) && emailVsCounter.containsKey(da.Deposit_Holder__r.PersonEmail)){
                list<Deposit_Allocation__c> allocationList = emailVslistDepositAllocation.get(da.Deposit_Holder__r.PersonEmail);
                allocationList.add(da);
                emailVsCounter.put(da.Deposit_Holder__r.PersonEmail,emailVsCounter.get(da.Deposit_Holder__r.PersonEmail)+1);
                emailVslistDepositAllocation.put(da.Deposit_Holder__r.PersonEmail,allocationList);
            }else if(String.isNotBlank(da.Deposit_Holder__r.PersonEmail)){
                
                emailVsCounter.put(da.Deposit_Holder__r.PersonEmail,1);
                emailVslistDepositAllocation.put(da.Deposit_Holder__r.PersonEmail,new list<Deposit_Allocation__c>{da});
            }
            
        }
        
        system.debug('>>>emailVsCounteremailVsCounter,1);>>>'+JSON.serializePretty(emailVsCounter));
        list<Deposit_Allocation__c> depositListItemOther = [SELECT id,Deposit__c,Role__c,Contact__c,Contact__r.AccountId,Deposit__r.Deposit_Account_Number__c,
                                                            Deposit__r.Property_Address__c,
                                                       Deposit_Holder__c,Deposit_Holder__r.Phone, 
                                                       Deposit_Holder__r.PersonContactId,  Deposit_Holder__r.Name,
                                                       Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName, 
                                                       Deposit_Holder__r.lastname,Deposit_Holder__r.PersonEmail,
                                                       Deposit_Holder__r.Activation_Code__pc,
                                                       Deposit_Holder__r.IsCustomerPortal,
                                                       Contact__r.Name, contact__r.Email
                                                       FROM Deposit_Allocation__c 
                                                       WHERE Deposit__c Not in :depositlist AND  role__c='tenant' AND Deposit_Holder__r.PersonEmail IN : emailVsCounter.keySet() AND Deposit__r.Status__c = 'Deposits held by scheme'];
        
        system.debug('>>>depositListItemOther>>>'+depositListItemOther);
        for(Deposit_Allocation__c da : depositListItemOther){

            list<Deposit_Allocation__c> allocationList = emailVslistDepositAllocation.get(da.Deposit_Holder__r.PersonEmail);

            for(Deposit_Allocation__c allocation : allocationList){
                if(allocation.Deposit_Holder__r.Name != da.Deposit_Holder__r.Name){
                    //flag Email
                    flagEmails.add(da.Deposit_Holder__r.PersonEmail);
                }else if(!idVsAllocation.containsKey(allocation.Id)){
                    //merge Contact
                    depositAllocationToUpdate.add(new Deposit_Allocation__c(Id = allocation.Id,Contact__c = da.Contact__c,Deposit_Holder__c = da.Deposit_Holder__c, Deposit__c = da.Deposit__c));
                    idVsAllocation.put(allocation.Id,allocation);
                    allocationVsAccountId.put(allocation.Id,allocation.Deposit_Holder__c);
                }
            } 
            
        }
        system.debug('$$userOldDataMap'+userOldDataMap);
        List<User> userList;
        List<User> userOldList;
        Map<String, User> userInSystemMap = new Map<String, User>();
        Map<String, User> userInSystemMapOld = new Map<String, User>();
        Map<String, User> userInActiveMapOld = new Map<String, User>();
       
        if(userMap.size()>0){
            userList = [SELECT Id, Name, email, contactId, accountId,IsActive
                               FROM User
                               WHERE email in:userMap.keySet()
                              ];
                              
            for(User u: userList){
            userInSystemMap.put(u.email, u);
      
            }
        }
        if(userOldDataMap.size()>0){
            userOldList = [SELECT Id, Name, email, contactId, accountId,IsActive
                               FROM User
                               WHERE email in:userOldDataMap.keySet()
                              ];
                              
             for(User u: userOldList){
               
                if(u.IsActive == false){
                    userInActiveMapOld.put(u.email, u); 
                    
                }
                 if(u.IsActive == true){
                     userInSystemMapOld.put(u.email, u); 
                 }
            }
        }
        system.debug('$$userInSystemMapOld '+userInSystemMapOld);

        for(Deposit_Allocation__c depall:depositListItem){
            if(String.isNotBlank(depall.Deposit_Holder__r.PersonEmail) && flagEmails.contains(depall.Deposit_Holder__r.PersonEmail)){
                //flag Deposit Allocation 
                depositAllocationToUpdate2.add(new Deposit_Allocation__c(Id = depall.Id, Flag_Email__c = true));

            }else if(String.isNotBlank(depall.Deposit_Holder__r.PersonEmail) && emailVsCounter.containsKey((depall.Deposit_Holder__r.PersonEmail)) && emailVsCounter.get((depall.Deposit_Holder__r.PersonEmail)) > 1){
                //flag Deposit Allocation 
                depositAllocationToUpdate2.add(new Deposit_Allocation__c(Id = depall.Id, Flag_Email__c = true));
                

            }/*else if(allocationVsAccountId.containsKey(depall.Id)){
                //
                // To mer ge existing Contact 
                accountsToDelete.add(new Account(Id = allocationVsAccountId.get(depall.Id)));
            }*/else{

            

                if(allocationVsAccountId.containsKey(depall.Id)){
                    //
                    // To mer ge existing Contact 
                    accountsToDelete.add(new Account(Id = allocationVsAccountId.get(depall.Id)));
                }
                system.debug(userInSystemMapOld.containsKey(depall.Deposit_Holder__r.PersonEmail)+' $$77 '+depall.Deposit_Holder__r.PersonEmail);
                if(userInSystemMapOld.containsKey(depall.Deposit_Holder__r.PersonEmail) ){
                    mapOfemailVsAccId.put( depall.Deposit_Holder__r.PersonEmail,depall.Deposit_Holder__r.Id);
                    mapOfemailVsAccName.put( depall.Deposit_Holder__r.PersonEmail,depall.Deposit_Holder__r.Name);
                }
                else if (userInActiveMapOld.containsKey(depall.Deposit_Holder__r.PersonEmail) ){
                inactiveUerlist.add(userInActiveMapOld.get(depall.Contact__r.Email).id);
                }
                else if(userInSystemMap.containsKey(depall.Deposit_Holder__r.PersonEmail) ){
                    depall.Contact__c = userInSystemMap.get(depall.Deposit_Holder__r.PersonEmail).contactId;
                    depall.Deposit_Holder__c = userInSystemMap.get(depall.Deposit_Holder__r.PersonEmail).AccountId;
                    depositwithMatcheduserList.add(depall);
                
                    //   EI_AddDeposit.notifyExistingTenant(mapOfemailVsAccId,mapOfemailVsAccName,Depositnumber);
                }
                else if (depall.Deposit_Holder__r.PersonEmail ==null && depall.Deposit_Holder__r.Phone !=null ){
                    mailJetSMSService.smstotenant(depall.Deposit_Holder__r.Phone,depall.Deposit_Holder__r.Activation_Code__pc);
                }
                else{
                    User u = new User();
                    // Alias Check
                    String fullName = depall.Deposit_Holder__r.FirstName + depall.Deposit_Holder__r.lastname;
                    if (fullName.length() >= 5){
                        u.alias = fullName.substring(0, 4);
                    } else{
                        u.alias = fullName;
                    }
                    
                    // NickName Check
                    if(depall.Deposit_Holder__r.FirstName!=null){
                        String nickname = ((depall.Deposit_Holder__r.FirstName != null && depall.Deposit_Holder__r.FirstName.length() > 0) ? depall.Deposit_Holder__r.FirstName.substring(0, 1) : '');
                        nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                        u.CommunityNickname = nickname;
                    }
                    else{
                        String nickname = ((depall.Deposit_Holder__r.lastname != null && depall.Deposit_Holder__r.lastname.length() > 0) ? depall.Deposit_Holder__r.lastname.substring(0, 1) : '')+depall.Deposit_Holder__r.lastname.substring(0, 1);
                        nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                        u.CommunityNickname = nickname;   
                    }
                    
                    // Username Check
                    
                    u.Title = depall.Deposit_Holder__r.Salutation;
                    u.FirstName = depall.Deposit_Holder__r.FirstName;
                    u.LastName = depall.Deposit_Holder__r.lastname;
                    
                    // Uncomment
                    u.Username = depall.Deposit_Holder__r.PersonEmail;
                    u.Phone = depall.Deposit_Holder__r.Phone;
                    
                    //u.Username = con.Email + 'abc';
                    u.Email = depall.Deposit_Holder__r.PersonEmail;
                    u.ProfileId = [Select Id,name from profile where name = 'Tenant' limit 1].Id;
                    // u.profileId = ut.ProfileId;
                    
                    
                    u.TimeZoneSidKey = 'Europe/London';
                    u.LocaleSidKey = 'en_GB';
                    u.LanguageLocaleKey = 'en_US';
                    u.ContactId = depall.Deposit_Holder__r.PersonContactId;
                    u.User_Type__c='Tenant';
                    u.EmailEncodingKey = 'ISO-8859-1';
                    // u.Addition_Permission__c = userpermission;
                    //  u.User_Role__c = jobrole;
                    // insert u;
                    newuserlist.add(u); 
                }
            }
        }

        if(!depositAllocationToUpdate.isEmpty()){
            update depositAllocationToUpdate;
            
            for(Deposit_Allocation__c allocation : depositAllocationToUpdate){
                if(idVsAllocation.containsKey(allocation.Id)){
                    mergeAllocationIds.add(allocation.Id);
                    sendEmail(JSON.serialize(idVsAllocation.get(allocation.Id)));
                    emailWrapperList.add(sendEmail(JSON.serialize(idVsAllocation.get(allocation.Id))));
                }
            }
             if(emailWrapperList.size()>0){
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
            }
            //we need to delete previous Account 

            //Delete accountsToDelete;
        }
        if(!updatePaymentVariable.isEmpty()){
           update updatePaymentVariable;
        }
        if(!depositAllocationToUpdate2.isEmpty()){
            Update depositAllocationToUpdate2;
        }
        if(depositwithMatcheduserList.size()>0){
            update depositwithMatcheduserList;
         //   EI_AddDeposit.notifyExistingTenant(mapOfemailVsAccId,mapOfemailVsAccName);
        }
        if(userInSystemMapOld.size()>0){
             EI_AddDeposit.notifyExistingTenant(mapOfemailVsAccId,mapOfemailVsAccName);
        }
        
        System.debug('@@ newuserlist '+newuserlist);
        System.debug('@@ inactiveUerlist '+inactiveUerlist);
        if(newuserlist.size()>0){
            insert  newuserlist;
        }
        if(inactiveUerlist.size()>0){
            updateUser(inactiveUerlist);
        }
        
        EI_BatchToSendInstallmentReminders.sendEmailHold(JSON.serialize(depositIds),JSON.serialize(mergeAllocationIds));
        
    }
    
    //@Future(callout=true)
    public static EI_SDS_MailJetUtilityCls.EmailWrapper sendEmail(String alloc) {
        
        Deposit_Allocation__c allocation = (Deposit_Allocation__c)System.JSON.deserialize(alloc, Deposit_Allocation__c.class);
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string loginlink;
        string emailsubject = 'New Deposit Protected – Confirm to add to your account';
        toName =allocation.Deposit_Holder__r.Name;
        toAddress = allocation.Deposit_Holder__r.personEmail;
        CustomerId =allocation.Deposit_Holder__c;
        loginlink ='<a href="https://staging-thedisputeservice.cs122.force.com/Sds/s">link to login</a>';
        
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();        
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, '', allocation.Deposit__c,allocation.Contact__c));
        Map<String, String> variableMap = new Map<String, String>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        
        variableMap.put('Date', todayStr);
        variableMap.put('name', allocation.Deposit_Holder__r.Name);
        variableMap.put('link_to_login', loginlink);
        // variableMap.put('offer_details', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper emailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'NewDepositWithCurrentTenantMail', emailsubject);    
        /* Newly added code for adding recipients, variables, template name, Subject END */
        
        return emailWrapper; 
    }
    
    /* Currently not in use */
    @future(callout=true)
    public static void sendEmail1(String alloc){
        Deposit_Allocation__c allocation = (Deposit_Allocation__c)System.JSON.deserialize(alloc, Deposit_Allocation__c.class);
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        // String fromAddress;
        // String fromName;
        //String toAddress;
        //String toName;
        Integer mailJetTemplateId;
        // String subject='Greetings from Zero Deposit';
        
        String name = allocation.Deposit_Holder__r.Name;
        String personEmail = allocation.Deposit_Holder__r.personEmail;
        
        

        //List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList(templateName); 
        
        //mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        
        //List<recipient> ParticipantList =(List<recipient>) JSON.deserialize(recList,List<recipient>.class);
        //Map<String,recipient> recMap = new Map<String,recipient>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();    
        gen.writeFieldName('Messages'); 
        gen.writeStartArray();
        
        
        gen.writeStartObject(); 
        gen.writeFieldName('From');
        
        gen.writeStartObject();
        gen.writeStringField('Email', 'deposits@safedepositsscotland.com');
        gen.writeStringField('Name', 'deposits@safedepositsscotland.com');
        
        
        
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email',personEmail); 
        gen.writeStringField('Name', name);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', 3100398); 
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', 'Confirmation of deposit protection');
        
        
        Date d = system.today();
          String  todaysDateStr = d.Day() + '/' + d.month() + '/' + d.year();
        gen.writeFieldName('Variables');    
        
        gen.writeStartObject();
        
        
        gen.writeStringField('name',name);
        //gen.writeStringField('body',mailBody);
        gen.writeStringField('date', todaysDateStr);
        gen.writeStringField('dan', allocation.Deposit__r.Deposit_Account_Number__c);
        gen.writeStringField('address', allocation.Deposit__r.Property_Address__c);
        gen.writeEndObject(); 
        
        gen.writeEndObject(); 
        
        try{
            
            gen.writeEndArray();
            gen.writeEndObject();
            String  jsonData =gen.getAsString();
            req.setBody(jsonData);
            system.debug(jsonData);
            Http http = new Http();
            
            HTTPResponse res = http.send(req); 
            if(res.getStatusCode() == 200){
                String resBody = res.getBody();
                if(!resBody.startsWith('[')){
                    resBody = '['+resBody+']';
                }
                //recipient rec = new recipient(acc.PersonEmail,acc.Name,caseId);
                //recMap.put(acc.PersonEmail,rec);
                //saveMessageDetailsAura(resBody,recMap,Subject,mailBody );
            }
            
            //system.debug('res-->>'+res.getBody());
        }
        catch(exception e){   
            //saveMessageDetails(resBody,recMap,Subject );
            system.debug(e);
            //Create Message(with error) from Here if no success response or it breaks  >>> res comes null  or status code is not expected 429 etc
        }
        //sendEmail( subject,  recList, variables, 'ZP7',  'mailJetZD');
        // recipient(String Email,String to,String recId);
        //Sent Mail by MailJet
    }
    
    public static void deactivateProperty(List<Deposit__c> depList, Map<Id,Deposit__c> newMap, Map<Id,Deposit__c> oldMap) {
     
        Id devRecordTypeId = Schema.SObjectType.Deposit__c.getRecordTypeInfosByName().get('SDS Deposit').getRecordTypeId();
        Set<Id> depoId = new Set<Id>();
        Set<Id> propId = new Set<Id>();
        
        for(Deposit__c dep : depList) {            
            if(oldMap.get(dep.Id).Status__c != dep.Status__c && dep.Status__c == 'Deposit registration deleted' && 
               dep.RecordTypeId == devRecordTypeId) 
            {
                //setOfCaseIds.add(eachCase.Id);
                //eachCase.Respond_Date__c = calculateWorkingDaysBetweenTwoDates(System.today(), 5);
                depoId.add(dep.Id);
                propId.add(dep.Property__c);
            } 
        }
        
        if(propId.size()>0) {
            List<Property__c> propToUpdate = new list<Property__c> ();
            List<Property__c> propList = [SELECT Id, Name, Property_status__c, (SELECT Id, Name, Active__c FROM Deposits__r WHERE Active__c=true AND 
                                                                                Status__c != 'Deposit registration deleted') 
                                          FROM Property__c WHERE Id IN: propId AND Property_status__c='Active'];
            system.debug('line-->613 ' + propList );
            for(Property__c prop : propList) {
                if(prop.Deposits__r.size()==0) {
                    prop.Property_status__c = 'Inactive';
                    propToUpdate.add(prop);
                }
            }
            if(propToUpdate.size()>0) {
                update propToUpdate;
            }
        }
        
    }
    
}