public without sharing class EI_TenentChangeoverApx {
    
    @AuraEnabled 
    Public static List<Case> getOutstandingCases() {
        
        List<Case> caseList = [Select id,Subject,Account.Name,Deposit_Account_Number__r.Deposit_Account_Number__c,ownerid,Status,CreatedDate from Case where ownerid=:UserInfo.getUserId() and ClosedDate != NULL Order By CreatedDate DESC];
        return caseList;
        
    }
    
    @AuraEnabled 
    Public static List<Case> getChangeOverCase(){
        User tenantAccount = [Select contact.AccountId,id from user where id=: UserInfo.getUserId()];
        set<Id> AccountId = new set<Id>();
        set<Id> DepositId = new set<Id>();
        
        for(Deposit_Allocation__c dplist :[Select id,Deposit_Holder__r.id,Deposit__r.id,Istenantmoved__c from Deposit_Allocation__c where Istenantmoved__c = true and Deposit_Holder__r.id =: tenantAccount.contact.AccountId]){
            AccountId.add(dplist.Deposit_Holder__r.id);
            DepositId.add(dplist.Deposit__r.id);
        }
        
        
        List<Case> caseList = [Select id,Subject,Deposit_Account_Number__r.Deposit_Account_Number__c,ownerid,Status from Case where 
                               (AccountId in: AccountId OR Deposit_Account_Number__c in: DepositId) 
                               and Status IN ('Tenant changeover initiated - tenant', 'Tenant changeover initiated - agent/landlord') 
                               and ChangeOver_Status__c IN ('Agent Approved', 'Agent Initiate')];
        if(caseList.size()>0){
            if(DepositId.size()>1){
                return caseList;}
            else{
                List<Case> singlist = new List<Case>();
                singlist.add(caseList[0]);
                return singlist;
            }
            
        }else{
            return null;}
        
    }
    
    @AuraEnabled 
    Public static String getLoggedInUserAccountId(){
        User tenantAccount = [Select contact.AccountId,id from user where id=: UserInfo.getUserId()];
        return tenantAccount.contact.AccountId;
    }
    
    @AuraEnabled 
    Public static String rejectChangeOver(String CaseId){
        try{
                   List<String> emailList = new List<String>();
                   Map<String,String> emailMembername = new Map<String,String>();
         Case updateCase = new Case(Id=CaseId, Status = 'Tenant Changeover cancelled',ChangeOver_Status__c = 'Tenant Rejected');
 
       
            string Message = 'Tenant changeover cancelled';
        list<deposit__c > deplist = [select Id,Tenant_Changeover_Status__c,Customer__r.Name,Customer__r.Email__c,Customer__r.PersonEmail,Customer__r.IsPersonAccount, Tenant_Changeover_Deposit__c from Deposit__c where id in (Select Deposit_Account_Number__c from Case where id=:CaseId) and Tenant_Changeover_Status__c ='In Progress' and Tenant_Changeover_Deposit__c !=null limit 1 ];    
       
        list<Deposit_Allocation__c > olddepositalllist = [select id,Deposit_Holder__c,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Name,Deposit__c,  Istenantmoved__c, Tenencychangeoveramount__c from Deposit_Allocation__c where Istenantmoved__c =true and Deposit__c in: deplist ];
        system.debug('line-->142' + olddepositalllist );
        if(deplist.size()>0){
            list<deposit__c> deletedepositlist = [select Id,Tenant_Changeover_Status__c,Status__c, Tenant_Changeover_Deposit__c from Deposit__c where id=:deplist[0].Tenant_Changeover_Deposit__c and  Status__c = null limit 1 ];  
            if(deletedepositlist.size()>0) {
                delete deletedepositlist;
            }
        }  
        
        if(olddepositalllist.size()>0){
            list<Deposit_Allocation__c> removemoveoutlist = new list<Deposit_Allocation__c> (); 
            for(Deposit_Allocation__c dept :olddepositalllist){
               // emailList.add(dept.Deposit_Holder__r.PersonEmail);

              
                emailList.add( dept.Deposit_Holder__r.Name);
                emailMembername.put(dept.Deposit_Holder__r.Name,dept.Deposit_Holder__r.PersonEmail);
               

                Deposit_Allocation__c dac = new Deposit_Allocation__c();
                dac.id =dept.id;
                dac.Istenantmoved__c=false;
                dac.Tenencychangeoveramount__c=null;
                removemoveoutlist.add(dac);
            } 
            update removemoveoutlist;
            
            
        }
        if(deplist.size()>0){
            list<deposit__c> updatedepositlist = new list<deposit__c> ();
            deposit__c  depst = new deposit__c();
            for(deposit__c  deposit :deplist ){
                if(deposit.Customer__r.IsPersonAccount){
                    emailList.add( deposit.Customer__r.Name);
                    emailMembername.put(deposit.Customer__r.Name,deposit.Customer__r.PersonEmail);
                //       emailList.add(deposit.Customer__r.PersonEmail);
                }else{
                    emailList.add( deposit.Customer__r.Name);
                    emailMembername.put(deposit.Customer__r.Name,deposit.Customer__r.Email__c);
               // emailList.add(deposit.Customer__r.Email__c);
            }
                depst.id =deposit.id; 
                depst.Tenant_Changeover_Status__c='Reject';
                depst.Tenant_Changeover_Deposit__c=null;   
                updatedepositlist.add(depst); 
            }
            update updatedepositlist;
        }
         update updateCase;
             MailJetService.mailTenentChangeOver(emailMembername,emailList,'Tenant Rejected',updateCase.Id);   
            
        return 'Successfully Updated';
        }
        catch(DmlException e) {
           return 'Failed in Update: ' + e.getMessage();
            }
    }
    
    @AuraEnabled 
    Public static String rejectChangeOverbyagent(String depositId){
        try{
          List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
            List<String> emailList = new List<String>();
            Map<String,String> emailMembername = new Map<String,String>();
            string Message = 'Tenant changeover cancelled';
            string customeremail;
            list<deposit__c> updatedepositlist = new list<deposit__c> ();
            
            // User tenantAccount = [Select contact.AccountId,id from user where id=: UserInfo.getUserId()];
            List<Case> caseList = [Select id,Subject,Deposit_Account_Number__c,ownerid,Status from Case where Deposit_Account_Number__c=:depositId   and Status = 'Tenant changeover initiated - tenant' and ChangeOver_Status__c = 'Tenant Initiate'];
            
            list<deposit__c > deplist = [select Id,Tenant_Changeover_Status__c,Property_Address_WO_Country__c,Customer__r.Name,Customer__r.Email__c,Customer__r.PersonEmail,Customer__r.IsPersonAccount, Tenant_Changeover_Deposit__c from Deposit__c where Id=:depositId  ];    
            
            list<Deposit_Allocation__c > olddepositalllist = [select id,Deposit_Holder__c,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Name,Deposit_Holder__r.Personcontactid,Deposit__c,  Istenantmoved__c, Tenencychangeoveramount__c from Deposit_Allocation__c where Istenantmoved__c =true and Deposit__c =: depositId ];
         
             list<Deposit_Allocation__c > olddepositstayedtenantlist = [select id,Deposit_Holder__c,Deposit_Holder__r.Personcontactid,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Name,Deposit__c,  Istenantmoved__c, Tenencychangeoveramount__c from Deposit_Allocation__c where Istenantmoved__c =false and Deposit__c =: depositId ];
            
            if(olddepositalllist.size()>0){
                list<Deposit_Allocation__c> removemoveoutlist = new list<Deposit_Allocation__c> (); 
                for(Deposit_Allocation__c dept :olddepositalllist){
                    emailList.add( dept.Deposit_Holder__r.Name);
                    emailMembername.put(dept.Deposit_Holder__r.Name,dept.Deposit_Holder__r.PersonEmail);
                    
                    Deposit_Allocation__c dac = new Deposit_Allocation__c();
                    dac.id =dept.id;
                    dac.Istenantmoved__c=false;
                    dac.Tenencychangeoveramount__c=0;
                    removemoveoutlist.add(dac);
                } 
                update removemoveoutlist;
                
                
            }
            if(deplist.size()>0){
                
                deposit__c  depst = new deposit__c();
                for(deposit__c  deposit :deplist ){
                    if(deposit.Customer__r.IsPersonAccount){
                        emailList.add( deposit.Customer__r.Name);
                        emailMembername.put(deposit.Customer__r.Name,deposit.Customer__r.PersonEmail);
                        //       emailList.add(deposit.Customer__r.PersonEmail);
                        customeremail =deposit.Customer__r.PersonEmail; 
                    }else{
                        emailList.add( deposit.Customer__r.Name);
                        emailMembername.put(deposit.Customer__r.Name,deposit.Customer__r.Email__c);
                       customeremail =deposit.Customer__r.Email__c;
                        // emailList.add(deposit.Customer__r.Email__c);
                    }
                    depst.id =deposit.id; 
                    depst.Tenant_Changeover_Status__c='Reject';
                    depst.Tenant_Changeover_Deposit__c=null;   
                    updatedepositlist.add(depst); 
                }
                update updatedepositlist;
            }
            // update updateCase;
            if(!deplist.isempty()){
                for(case caseobj :caseList ){  
                    caseobj.Status='Tenant Changeover cancelled';
                    caseobj.ChangeOver_Status__c='Agent Rejected';
                }
                update caseList;
                system.debug('line-->180' + olddepositalllist);
                system.debug('line-->181' + olddepositstayedtenantlist);
                system.debug('line-->182' + customeremail);
               // MailJetService.mailTenentChangeOver(emailMembername,emailList,'Tenant Rejected',caseList[0].id);
               
               // Email to Customer when changeover rejected by agll
               MailJetService.changeOverRejectedbyAGLLToCustomer(customeremail,deplist[0].Customer__r.Name,deplist[0].Property_Address_WO_Country__c,caseList[0].id,deplist[0].customer__c);
               emailWrapperList.add(MailJetService.changeOverRejectedbyAGLLToCustomer(customeremail,deplist[0].Customer__r.Name,deplist[0].Property_Address_WO_Country__c,caseList[0].id,deplist[0].customer__c)); 
                
                for(Deposit_Allocation__c depallfirst :olddepositstayedtenantlist ) {
                 // Email to stayed tenant when changeover rejected by agll
               MailJetService.ChangeOverRejectedbyAGLLToStayedTenants(depallfirst.Deposit_Holder__r.PersonEmail,depallfirst.Deposit_Holder__r.Name,deplist[0].Property_Address_WO_Country__c,caseList[0].id,depallfirst.Deposit_Holder__r.personcontactid);    
              emailWrapperList.add(MailJetService.ChangeOverRejectedbyAGLLToStayedTenants(depallfirst.Deposit_Holder__r.PersonEmail,depallfirst.Deposit_Holder__r.Name,deplist[0].Property_Address_WO_Country__c,caseList[0].id,depallfirst.Deposit_Holder__r.personcontactid)); 
                }
                
                for(Deposit_Allocation__c depalltwo :olddepositalllist ) {
                 // Email to moveouttenants when changeover rejected by agll
               MailJetService.ChangeOverRejectedbyAGLLToMoveoutTenants(depalltwo.Deposit_Holder__r.PersonEmail,depalltwo.Deposit_Holder__r.Name,deplist[0].Property_Address_WO_Country__c,caseList[0].id,depalltwo.Deposit_Holder__r.personcontactid);    
               emailWrapperList.add(MailJetService.ChangeOverRejectedbyAGLLToMoveoutTenants(depalltwo.Deposit_Holder__r.PersonEmail,depalltwo.Deposit_Holder__r.Name,deplist[0].Property_Address_WO_Country__c,caseList[0].id,depalltwo.Deposit_Holder__r.personcontactid)); 
                }
                if(emailWrapperList.size()>0){
                    EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
                }
            }
            return Message;
        }
        catch(DmlException e) {
            return 'Failed in Update: ' + e.getMessage();
        }
    }
    
    @AuraEnabled 
    Public static String updateCase(String depositId){
        try{
                List<String> emailList = new List<String>();
                Map<String,String> emailMembername = new Map<String,String>();
        Case updateCase = [Select id,Subject,Deposit_Account_Number__c,Account.Name,Account.PersonEmail,ownerid,owner.email,owner.Name,Status from Case where Deposit_Account_Number__c=: depositId and ownerid=: Userinfo.getUserId() and Status = 'Tenant changeover'];
      //  emailList.add(updateCase.owner.Email);
        //    emailList.add(updateCase.Account.PersonEmail);

            emailList.add( updateCase.owner.Name);
            emailList.add( updateCase.Account.Name);
            emailMembername.put(updateCase.owner.Name,updateCase.owner.Email);
            emailMembername.put(updateCase.Account.Name,updateCase.Account.PersonEmail);
            updateCase.Status = 'Tenant changeover cancelled';
        updateCase.ChangeOver_Status__c = 'Agent Rejected';
        update updateCase;
            
              list<deposit__c > deplist = [select Id,Tenant_Changeover_Status__c,Customer__r.Name,Customer__r.Email__c,Customer__r.PersonEmail,Customer__r.IsPersonAccount, Tenant_Changeover_Deposit__c from Deposit__c where id =:depositId and Tenant_Changeover_Status__c ='In Progress' limit 1 ];    
       
        list<Deposit_Allocation__c > olddepositalllist = [select id,Deposit_Holder__c,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Name,Deposit__c,  Istenantmoved__c, Tenencychangeoveramount__c from Deposit_Allocation__c where Istenantmoved__c =true and Deposit__c in: deplist ];
        system.debug('line-->142' + olddepositalllist );
        
        if(olddepositalllist.size()>0){
            list<Deposit_Allocation__c> removemoveoutlist = new list<Deposit_Allocation__c> (); 
            for(Deposit_Allocation__c dept :olddepositalllist){
               // emailList.add(dept.Deposit_Holder__r.PersonEmail);

              
                emailList.add( dept.Deposit_Holder__r.Name);
                emailMembername.put(dept.Deposit_Holder__r.Name,dept.Deposit_Holder__r.PersonEmail);
               

                Deposit_Allocation__c dac = new Deposit_Allocation__c();
                dac.id =dept.id;
                dac.Istenantmoved__c=false;
                dac.Tenencychangeoveramount__c=null;
                removemoveoutlist.add(dac);
            } 
            update removemoveoutlist;
            
            
        }
        if(deplist.size()>0){
            list<deposit__c> updatedepositlist = new list<deposit__c> ();
            deposit__c  depst = new deposit__c();
            for(deposit__c  deposit :deplist ){
                if(deposit.Customer__r.IsPersonAccount){
                    emailList.add( deposit.Customer__r.Name);
                    emailMembername.put(deposit.Customer__r.Name,deposit.Customer__r.PersonEmail);
                //       emailList.add(deposit.Customer__r.PersonEmail);
                }else{
                    emailList.add( deposit.Customer__r.Name);
                    emailMembername.put(deposit.Customer__r.Name,deposit.Customer__r.Email__c);
               // emailList.add(deposit.Customer__r.Email__c);
            }
                depst.id =deposit.id; 
                depst.Tenant_Changeover_Status__c='Reject';
                depst.Tenant_Changeover_Deposit__c=null;   
                updatedepositlist.add(depst); 
            }
            update updatedepositlist;
        }
               MailJetService.mailTenentChangeOver(emailMembername,emailList,'Agent Rejected',updatecase.id);
            return 'Successfully updated';
        } catch(DmlException e) {
           return 'Failed in Update: ' + e.getMessage();
            }
    }
    
    @AuraEnabled 
    Public static String submitCaseOnChangeOver(String depositId, String AgentId, Deposit_Allocation__c depositDetails){
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        string tenantData = '<table>';
        list<Deposit_Allocation__c> moveouttenantslist =  [Select id,Deposit_Holder__r.name,Tenencychangeoveramount__c,Deposit_Holder__r.Id,Deposit_Holder__r.PersonEmail,Deposit_holder__r.PersoncontactId,Istenantmoved__c from Deposit_Allocation__c where Deposit__c =:depositId and Istenantmoved__c = true];
        list<Deposit_Allocation__c> stayedtenantslist =  [Select id,Deposit_Holder__r.name,Tenencychangeoveramount__c,Deposit_Holder__r.Id,Deposit_Holder__r.PersonEmail,Deposit_holder__r.PersoncontactId,Istenantmoved__c from Deposit_Allocation__c where Deposit__c =:depositId and Istenantmoved__c = false]; 
        list<deposit__c > deplist = [select Id,Tenant_Changeover_Status__c,Name,Property_Address_WO_Country__c,Customer__c,Customer__r.Name,Customer__r.Email__c,Customer__r.PersonEmail,Customer__r.IsPersonAccount, Tenant_Changeover_Deposit__c from Deposit__c where Id=:depositId  ];   
      
        if(moveouttenantslist.size()>0 ){
            for(Deposit_Allocation__c depllone:moveouttenantslist){
                tenantData+= '<tr>';
                tenantData+= '<td>'+depllone.Deposit_Holder__r.name+':'+'<td>';
                tenantData+= '<td>'+'£'+depllone.Tenencychangeoveramount__c+'<td>';
                tenantData+= '</tr>';  
            } 
          tenantData+= '</table><br/><br/>';
            
        }
        System.debug('299 weird -');
        
        List<String> emailList = new List<String>();
        Id AccountUserId;
        Map<String,String> userMap = new Map<String,String>();
        Map<String,String> emailMembername = new Map<String,String>();
        String UserId;
        boolean multipleTenant = false;
        for(User u : [Select id,Email,Name,profile.name,Contact.Email,Contact.AccountId,Contact.Account.Name,Contact.Account.Email__c,Contact.Account.isPersonAccount from User where Contact.AccountId =: AgentId])   
        {
            if(u.profile.name == 'Agent' || u.profile.name == 'Landlord'){
             //   userMap.put(u.profile.name, u.email);
             if(u.Contact.Account.isPersonAccount){
                emailList.add( u.Contact.Account.Name);
                emailMembername.put(u.Contact.Account.Name,u.Contact.Email);
             }
             else{
                emailList.add( u.Contact.Account.Name); 
                emailMembername.put(u.Contact.Account.Name,u.Contact.Account.Email__c);
             }
             
                UserId = u.id;
            }
 
        }
        for(Deposit_Allocation__c depAllcation : [Select id,Deposit_Holder__r.name,Deposit_Holder__r.Id,Deposit_Holder__r.PersonEmail,Istenantmoved__c from Deposit_Allocation__c where Deposit__c =:depositId and Istenantmoved__c = true]){
         
               if(UserInfo.getUserEmail() == depAllcation.Deposit_Holder__r.PersonEmail){
                userMap.put('Tenant' , depAllcation.Deposit_Holder__r.Id);
                AccountUserId = depAllcation.Deposit_Holder__r.Id;
               }
               emailMembername.put(depAllcation.Deposit_Holder__r.name,depAllcation.Deposit_Holder__r.PersonEmail);
                emailList.add( depAllcation.Deposit_Holder__r.name);
               
                multipleTenant = true;
           
           
        }
     system.debug('EmailList '+emailList);
     //   emailList.add(UserInfo.getUserEmail());
        String tenentName = UserInfo.getName();
        system.debug('AccountUserId '+AccountUserId);
        id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
            Case newCase = new Case(AccountId = AccountUserId, RecordTypeId = caseRecordType, ChangeOver_Status__c = 'Tenant Initiate', 
                                    Deposit_Account_Number__c = depositId, OwnerId = UserId, Origin= 'Web', 
                                    Status='Tenant changeover initiated - tenant', Scheme__c='SafeDeposits Scotland', 
                                    Subject = 'Tenant Changeover request for '+tenentName, 
                                    Description = tenentName+' has initiated Tenant Change Over');
        try{
            System.debug('weird 344 -> ');
            //insert newCase;
            if(multipleTenant == false){
                emailMembername.put(depositDetails.Deposit_Holder__r.name,depositDetails.Deposit_Holder__r.PersonEmail);
                emailList.add( depositDetails.Deposit_Holder__r.name);
 
            depositDetails.Istenantmoved__c = true;
            AccountUserId = depositDetails.Deposit_Holder__r.Id;
            update depositDetails;
            
            newCase.AccountId = AccountUserId;
            
            }insert newCase;
            System.debug('weird newCase -> '+newCase.Id);
            Deposit__c updateDeposit = new Deposit__c(id=depositId,Tenant_Changeover_Status__c='In Progress');
            update updateDeposit;
                 // MailJetService.mailTenentChangeOver(emailMembername,emailList,'Tenant Initiate', newCase.id);
                
            // Tenant initiated changeover mail to customer
            MailJetService.ChangeOverInitiatedByTenantToCustomer(deplist[0].customer__r.email__c,deplist[0].customer__r.personemail,deplist[0].customer__r.name,deplist[0].Name,deplist[0].Property_Address_WO_Country__c,tenantData,newCase.id,deplist[0].customer__c);
            emailWrapperList.add(MailJetService.ChangeOverInitiatedByTenantToCustomer(deplist[0].customer__r.email__c,deplist[0].customer__r.personemail,deplist[0].customer__r.name,deplist[0].Name,deplist[0].Property_Address_WO_Country__c,tenantData,newCase.id,deplist[0].customer__c));
            
            for(Deposit_Allocation__c depalltwo: stayedtenantslist){
                
                // Tenant initiated changeover mail to stayed tenant
                MailJetService.ChangeOverInitiatedByTenantTostayedTennt(depalltwo.Deposit_Holder__r.personemail,depalltwo.Deposit_Holder__r.name,deplist[0].Name,deplist[0].Property_Address_WO_Country__c,tenantData,newCase.id,depalltwo.Deposit_Holder__r.personcontactid);
           emailWrapperList.add(MailJetService.ChangeOverInitiatedByTenantTostayedTennt(depalltwo.Deposit_Holder__r.personemail,depalltwo.Deposit_Holder__r.name,deplist[0].Name,deplist[0].Property_Address_WO_Country__c,tenantData,newCase.id,depalltwo.Deposit_Holder__r.personcontactid));
            }
            
            for(Deposit_Allocation__c depallthree: moveouttenantslist){
                
                // Tenant initiated changeover mail to stayed tenant
                MailJetService.ChangeOverInitiatedByTenantToMovingTennt(depallthree.Deposit_Holder__r.personemail,depallthree.Deposit_Holder__r.name,deplist[0].Name,deplist[0].Property_Address_WO_Country__c,tenantData,newCase.id,depallthree.Deposit_Holder__r.Personcontactid);
               emailWrapperList.add(MailJetService.ChangeOverInitiatedByTenantToMovingTennt(depallthree.Deposit_Holder__r.personemail,depallthree.Deposit_Holder__r.name,deplist[0].Name,deplist[0].Property_Address_WO_Country__c,tenantData,newCase.id,depallthree.Deposit_Holder__r.Personcontactid));
            }
            
            if(emailWrapperList.size()>0){
                EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
            }
            return 'Success';
        }
        catch (Exception e){
            System.debug('weird error -> '+String.valueOf(e.getMessage()));
            return 'Error '+String.ValueOf(e.getMessage());
        }
        
    }
    
    @AuraEnabled 
    Public static Deposit_Allocation__c getTenantAndDepositDetails(String depositId){
    User currentUser = [Select Contact.AccountId from user where id=: Userinfo.getUserId()];
        Deposit_Allocation__c depositAllocation = [Select Id, Deposit__r.Protected_Amount__c,Deposit__r.Customer__c,Deposit_Holder__r.PersonEmail,Istenantmoved__c ,Deposit__r.Deposit_Amount__c,Deposit__r.Id,Deposit_Holder__r.Name,Tenencychangeoveramount__c from Deposit_Allocation__c where Deposit__c =: depositId and Deposit_Holder__c =: currentUser.Contact.AccountId limit 1];
  
     return  depositAllocation;  
    }
    
    @AuraEnabled 
    Public static  list<Deposit_Allocation__c> alltenantlist(String depositId){
        User currentUserAccountID = [Select Contact.AccountId,AccountId from user where id=: Userinfo.getUserId()];
        list<Deposit_Allocation__c > depositAllocationlist = [Select Id, Deposit__r.Protected_Amount__c,Deposit__r.Customer__c,Deposit_Holder__r.PersonEmail,Istenantmoved__c ,Deposit__r.Deposit_Amount__c,Deposit__r.Id,Deposit_Holder__c,Deposit_Holder__r.Name,Tenencychangeoveramount__c from Deposit_Allocation__c where Deposit__c =: depositId ];
        for (Deposit_Allocation__c d : depositAllocationlist)  
        {
            if(currentUserAccountID.AccountId == d.Deposit_Holder__c)
            {
                d.Istenantmoved__c = true;
            }
        }
        return  depositAllocationlist;  
    }
    
    /*   @AuraEnabled 
    Public static List<Bank_Account__c> getBankDetails(List<Bank_Account__c> bankdetail){
    User currentUser = [Select Contact.AccountId from user where id=: Userinfo.getUserId()];
        if(bankdetail != null ){
            if(bankdetail[0].id != null){
                update bankdetail;}
            else{
                bankdetail[0].Account__c = currentUser.Contact.AccountId;
                insert bankdetail;}
        }
        
        List<Bank_Account__c> bankDetails = [Select International_Bank_Name__c,Bank_Address__c,BIC__c,Swift_Code__c,IBAN__c,International_Bank_Account_Holder_Name__c,Name,Account_Number__c,Bank_Account_Holder_Name__c,Bank_Name__c,Sort_Code__c from Bank_Account__c where Account__c =: currentUser.Contact.AccountId ];
  
     return  bankDetails;  
    }*/
    
    @Auraenabled
    public static List<Bank_Account__c> displayBankDetails() {
        List<Bank_Account__c> bankdetails  = [select id,Account__c,IBAN__c,BIC__c,Bank_Address__c,Swift_Code__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c,International_Account_Number__c,International_Bank_Account_Holder_Name__c,International_Bank_Name__c, Sort_Code__c from Bank_Account__c  where Contact__c IN (SELECT ContactId from User where Id = :UserInfo.getUserId()) limit 1 ];     
        return bankdetails;
    }
     
    public static string getKey(){
        /*Enter your API key here*/
        string key = Label.Sort_Code_API;
        string output = 'Key=' + key;   
        return output;
    }
      
    public static string getResponse(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req); 
        String responseBody = res.getBody(); 
        system.debug('responseBody---'+responseBody);       
        return responseBody; 
    }
    
    @AuraEnabled
    public static string updateBankDetailsOfTenant(String accountNumber, String sortCode,String bankAccountName,String bankName, 
                                                    String accountId,String contactId){
        if(accountId == '' && contactId == ''){
            User u = [Select id,contact.accountId,contact.Id from User where id =: UserInfo.getUserId()];
            accountId = u.contact.accountId;
            contactId = u.contactId;
        }
        String message,isCorrect,bankNameInfo;
        String url = Label.Sort_Code_URL+getKey()+'&AccountNumber='+accountNumber+'&SortCode='+sortCode;
        system.debug('url***'+url);
        String response = getResponse(url);
        JSONParser parser = JSON.createParser(response);
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                if(parser.getCurrentName() == 'IsCorrect') {
                    parser.nextToken();
                    isCorrect = parser.getText();
                }
                else if (parser.getCurrentName() == 'StatusInformation') {
                    parser.nextToken();
                    message = parser.getText();
                }
                if (parser.getCurrentName() == 'Bank') {
                    parser.nextToken();
                    bankNameInfo = parser.getText();
                }
            }
        }
        if(!Boolean.ValueOf(isCorrect)){
            if(message=='InvalidAccountNumber' || message=='UnknownSortCode'){
                message = message;
            }
            else{
                message = message;
            }
        }
        else{
            List<Bank_Account__c> bankdetails  = [select id,Account__c, Contact__c, Bank_Account_Holder_Name__c, Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where Contact__c = :contactId limit 1 ];
            if(bankdetails!=null && !bankdetails.isEmpty()){
                Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
                updatebankdetails.Name=bankAccountName;
                updatebankdetails.Contact__c=bankdetails[0].Contact__c;
                updatebankdetails.Account_Number__c= accountNumber;
                updatebankdetails.Sort_Code__c = sortCode;
                updatebankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                updatebankdetails.Bank_Name__c = bankNameInfo;
                update updatebankdetails;
                message = bankNameInfo;
            }
            else{
                Bank_Account__c insertbankdetails =new Bank_Account__c();
                insertbankdetails.Name=bankAccountName;
                insertbankdetails.Account__c=accountId;
                insertbankdetails.Contact__c=contactId;
                insertbankdetails.Account_Number__c= accountNumber;
                insertbankdetails.Sort_Code__c = sortCode;
                insertbankdetails.Bank_Account_Holder_Name__c= bankAccountName;
                insertbankdetails.Bank_Name__c = bankNameInfo;
                insert insertbankdetails;
                message = bankNameInfo;         
            }
        }
        return message;
    }
    
    @AuraEnabled
    public static string updateIntBankDetailsOfTenant(String bankIntName, String bankIntaddress,String bankIntAccountName,String bankIdentificationCode,
                                                    String bankSwiftCode,String IBAN,String accountId,String contactId){
      
 if(accountId == '' && contactId == ''){
            User u = [Select id,contact.accountId,contact.Id from User where id =: UserInfo.getUserId()];
            accountId = u.contact.accountId;
            contactId = u.contactId;
        }
      String message='';
        List<Bank_Account__c> bankdetails  = [select id,IBAN__c,Swift_Code__c,BIC__c,Bank_Address__c,Account__c, Contact__c, International_Bank_Account_Holder_Name__c, International_Bank_Name__c, Account_Number__c, Sort_Code__c from Bank_Account__c  where Contact__c =: contactId limit 1 ];
        if(bankdetails!=null && !bankdetails.isEmpty()){
            Bank_Account__c updatebankdetails = new Bank_Account__c(id=bankdetails[0].id);
            updatebankdetails.Name=bankIntAccountName;
            updatebankdetails.Contact__c=bankdetails[0].Contact__c;
            updatebankdetails.International_Bank_Account_Holder_Name__c= bankIntAccountName;
            updatebankdetails.International_Bank_Name__c = bankIntName;
            updatebankdetails.IBAN__c=IBAN;
            updatebankdetails.BIC__c= bankIdentificationCode;
            updatebankdetails.Bank_Address__c = bankIntaddress;
            updatebankdetails.Swift_Code__c = bankSwiftCode;
            update updatebankdetails;
            message = 'successMessage';
        }
        else{
            Bank_Account__c insertbankdetails =new Bank_Account__c();
            insertbankdetails.Name=bankIntAccountName;
            insertbankdetails.Account__c = accountId;
            insertbankdetails.Contact__c = contactId;
            insertbankdetails.International_Bank_Account_Holder_Name__c= bankIntAccountName;
            insertbankdetails.International_Bank_Name__c = bankIntName;
            insertbankdetails.IBAN__c=IBAN;
            insertbankdetails.BIC__c= bankIdentificationCode;
            insertbankdetails.Bank_Address__c = bankIntaddress;
            insertbankdetails.Swift_Code__c = bankSwiftCode;
            insert insertbankdetails;
            message = 'successMessage';         
        }
        return message;
    }
    
    @AuraEnabled 	
    Public static list<depositwrapper> getdeposittenantdetails(string depositId, string tenantChangeOver){	
        list<depositwrapper> wraplist = new list<depositwrapper>();   	
        for (deposit__C deposit :([select id,name,Deposit_Amount__c,Protected_Amount__c,Start_Date__c,Number_of_Tenants__c,Scheme__c,Property__c,Property_Address__c from deposit__C where id=:depositId]))	
        {	
            wraplist.add(new depositwrapper(deposit));	
        }	
        if(tenantChangeOver == 'true'){	
            for (Deposit_Allocation__c depall : ([select id,Deposit__c,Tenencychangeoveramount__c, Istenantmoved__c,Role__c,Is_Lead__c, Deposit_Holder__c,Deposit_Holder__r.Id,Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName, Deposit_Holder__r.LastName, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail, Deposit_Holder__r.Phone,Deposit_Holder__r.PersonMailingStreet,Deposit_Holder__r.PersonMailingCity,Deposit_Holder__r.PersonMailingCountry,Deposit_Holder__r.PersonMailingPostalCode from Deposit_Allocation__c where Deposit__c=:depositId and Role__c='Tenant' and Istenantmoved__c = true]))	
            {	
                wraplist.add(new depositwrapper(depall));	
            }	
        }else{	
            for (Deposit_Allocation__c depall : ([select id,Deposit__c,Tenencychangeoveramount__c, Istenantmoved__c,Role__c,Is_Lead__c, Deposit_Holder__c,Deposit_Holder__r.Id,Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName, Deposit_Holder__r.LastName, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail, Deposit_Holder__r.Phone,Deposit_Holder__r.PersonMailingStreet,Deposit_Holder__r.PersonMailingCity,Deposit_Holder__r.PersonMailingCountry,Deposit_Holder__r.PersonMailingPostalCode from Deposit_Allocation__c where Deposit__c=:depositId and Role__c='Tenant']))	
            {	
                wraplist.add(new depositwrapper(depall));	
            }  	
        }	
        	
        return  wraplist;  	
    }
    
    @Auraenabled
    public static List<Deposit__c> getDeposit(String searchField,string olddepositid) {
        string searchkey = '%' + searchField + '%';
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
        List<Deposit__c> depositList = new List<Deposit__c>();
        depositList = [SELECT Id,Name,Status__c,Deposit_Amount__c,Property_Address__c from Deposit__c where  Customer__c =:accountid and id !=:olddepositid  and (Name like :searchkey or Property_Address__c like:searchkey )];
        system.debug('+++++++depositList++'+depositList);
        return depositList;
    }
    
    @Auraenabled
    public static List<Deposit__c> getselectedDeposit(string selecteddepositid) {
        List<Deposit__c> depositList = new List<Deposit__c>();
        depositList = [SELECT Id,Name,Status__c,Deposit_Amount__c,Property_Address__c from Deposit__c where  id =:selecteddepositid ];
        system.debug('+++++++depositList++'+depositList);
        return depositList;
    }
    
    @AuraEnabled
    public static list<Deposit_Allocation__c> changeovertenantlist(list<string> selectedtenantids,string olddepositid){
     list<Deposit_Allocation__c> datalist = [select id,Deposit__c,Tenencychangeoveramount__c, Istenantmoved__c,Role__c,Is_Lead__c, Deposit_Holder__c,Deposit_Holder__r.Salutation,Deposit_Holder__r.FirstName, Deposit_Holder__r.LastName, Deposit_Holder__r.Name, Deposit_Holder__r.PersonEmail, Deposit_Holder__r.Phone from Deposit_Allocation__c where Deposit__c=:olddepositid and Deposit_Holder__c in: selectedtenantids ]; 
        
     return datalist;   
    }
    
    @AuraEnabled
    public static list<Deposit_Allocation__c> updatechchangeoverdetails(list<Deposit_Allocation__c> Depolist){        
        list<Deposit_Allocation__c> updatedlist = new list<Deposit_Allocation__c>();    
        for(Deposit_Allocation__c dac : Depolist){
            Deposit_Allocation__c dact = new  Deposit_Allocation__c();
            dact.id = dac.id;
            dact.Istenantmoved__c=true;
            if(dac.Tenencychangeoveramount__c !=null){
                dact.Tenencychangeoveramount__c=dac.Tenencychangeoveramount__c;    
            }
            else{
                dact.Tenencychangeoveramount__c=0;   
            }
            updatedlist.add(dact);
        }   
        update updatedlist;
        return updatedlist;   
        
    }
    
    @AuraEnabled
    public static list<Deposit_Allocation__c> updatedetailstenantchangeover(string depositId,string AgentId,string Depolist){ 
        User currentUser = [Select Contact.AccountId from user where id=: Userinfo.getUserId()];
        Deposit_Allocation__c depositallocation = [Select Deposit__r.Customer__c,Deposit_Holder__r.PersonEmail,Istenantmoved__c ,Deposit__r.Deposit_Amount__c,Deposit__r.Id,Deposit_Holder__r.Name,Tenencychangeoveramount__c from Deposit_Allocation__c where Deposit__c =: depositId and Deposit_Holder__c =: currentUser.Contact.AccountId limit 1];
        list<Deposit_Allocation__c> depalllist = (List<Deposit_Allocation__c>) System.JSON.deserialize(Depolist, List<Deposit_Allocation__c>.class);
        system.debug('line 520' +  depositId);
        system.debug('line 521' +  AgentId);
        system.debug('line 522' +  depositallocation);
        list<Deposit_Allocation__c> updatedlist = new list<Deposit_Allocation__c>();    
        for(Deposit_Allocation__c dac : depalllist){
            Deposit_Allocation__c dact = new  Deposit_Allocation__c();
            dact.id = dac.id;
            if(dac.Tenencychangeoveramount__c !=null && dac.Istenantmoved__c==true){
                dact.Istenantmoved__c=true;
                dact.Tenencychangeoveramount__c=dac.Tenencychangeoveramount__c;    
            }
            else{
                dact.Tenencychangeoveramount__c=0;   
                dact.Istenantmoved__c=false;
            }
            updatedlist.add(dact);
        }   
        update updatedlist;
        if(!updatedlist.isempty()){
            EI_TenentChangeoverApx.submitCaseOnChangeOver(depositId, AgentId, depositallocation);
        }
        return updatedlist;   
        
    } 
    
    @AuraEnabled
    public static string createnewdeposit(string depositid ,integer newdepositamount,integer newtenantsnumber,
                                          date newdepositstartdate,string Depolist,String tenantChange ) 
    {
        String DAN;
        Map<String,String> emailMembername = new Map<String,String>();
        Map<String,String> tenentAmount = new Map<String,String>();                                        
        List<String> emailDetails = new List<String>();                                        
        list<Deposit_Allocation__c> abc = (List<Deposit_Allocation__c>) System.JSON.deserialize(Depolist, List<Deposit_Allocation__c>.class);
        system.debug('line-->54'+ Depolist);
        system.debug('line-->55'+ abc[0].Deposit__c);                              
        string message = 'Record created';                               
        /* list<Deposit_Allocation__c> depalllist = (list<Deposit_Allocation__c>)Depolist;  
        system.debug('line-->58'+ depalllist);  */
        
        
        list<Deposit_Allocation__c> depall = [Select id,Is_Lead__c,deposit_holder__r.name,deposit_holder__c,Role__c  from Deposit_Allocation__c 
                                              where id not in:abc and Deposit__c=:depositid and Role__c='Tenant'];                             
        system.debug('line-->60-->>' + depall );
        list<Deposit_Allocation__c> newdepaloc = new list<Deposit_Allocation__c>();
        deposit__c deplist = [select id,Branch__c,Name,Property__c,Deposit_Account_Number__c,Customer__c,Customer__r.name,Scheme__C,Status__c,
                              Old_Deposit_Number__c, Protected_Amount__c from Deposit__c where id=:depositid limit 1];
        system.debug('line-->62' + deplist );
        system.debug('line-->63' + deplist.Property__c);
        system.debug('line-->64' + deplist.Customer__c);
        DAN =deplist.Deposit_Account_Number__c;
        deposit__c newdeposit = new deposit__c();
        if(deplist.Property__c !=null && deplist.Customer__c!=null){
            newdeposit.Branch__c = deplist.Branch__c;
            newdeposit.Customer__c = deplist.Customer__c;
            newdeposit.Property__c = deplist.Property__c;
            newdeposit.Scheme__c = deplist.Scheme__c;
            
            newdeposit.Status__c = '';
            newdeposit.Tenant_Changeover_Status__c='In Progress';
            
            newdeposit.Tenant_Changeover_Deposit__c=depositid;
            newdeposit.Old_Deposit_Number__c=deplist.Name;
            newdeposit.Old_Changeover_Deposit__c=depositid;
            newdeposit.Previous_Protected_Amount__c=deplist.Protected_Amount__c;
            System.debug('line-->650' + depositid);
            System.debug('line-->651' +newdeposit.Old_Changeover_Deposit__c);
            newdeposit.Status__c=null;
            newdeposit.Number_of_Tenants__c = newtenantsnumber;
            newdeposit.Deposit_Amount__c=newdepositamount;
            newdeposit.Start_Date__c=newdepositstartdate;
            insert newdeposit; 
        } 
        if(newdeposit.id !=null){
            for(Deposit_Allocation__c DA :depall ) {
                Deposit_Allocation__c dact = new  Deposit_Allocation__c();                                          
                dact.Deposit_Holder__c=DA.Deposit_Holder__c;
                dact.Deposit__c=newdeposit.id;
                dact.Role__c ='Tenant';
                dact.Is_Lead__c = DA.Is_Lead__c;
                newdepaloc.add(dact);
            }
            insert newdepaloc;
            system.debug('line-->86'+ newdepaloc);
        }     
        if(newdeposit.id !=null ) {
            Deposit__c olddeposit = new  Deposit__c();
            olddeposit.id=depositid;
            olddeposit.Tenant_Changeover_Deposit__c=newdeposit.id;
            olddeposit.New_Changeover_Deposit__c=newdeposit.id;
            if(DAN == ''){
                DAN = olddeposit.Deposit_Account_Number__c;}
            olddeposit.Tenant_Changeover_Status__c='In Progress';   
            
            update olddeposit;                                        
        } 
        
        list<Deposit_Allocation__c> updatedlist = new list<Deposit_Allocation__c>();    
        for(Deposit_Allocation__c dac : abc){
            Deposit_Allocation__c dact = new  Deposit_Allocation__c();
            dact.id = dac.id;
            dact.Istenantmoved__c=true;
            
            emailDetails.add(dac.Deposit_Holder__r.Name);
            emailMembername.put(dac.Deposit_Holder__r.Name,dac.Deposit_Holder__r.PersonEmail);
            if(dac.Tenencychangeoveramount__c !=null){
                dact.Tenencychangeoveramount__c=dac.Tenencychangeoveramount__c;  
                tenentAmount.put(dac.Deposit_Holder__r.Name,String.valueOf(dac.Tenencychangeoveramount__c));
            }
            else{
                if(tenantChange == 'true'){}else{
                    dact.Tenencychangeoveramount__c=0; 
                }
            }
            updatedlist.add(dact);
        }   
        update updatedlist;
        
        
        List<Case> caseList = new List<Case>();
        for(Case changeOverCase : [Select id,Status,ChangeOver_Status__c from Case where Deposit_Account_Number__c =: depositid and Status = 'Tenant changeover initiated - tenant' and ChangeOver_Status__c = 'Tenant Initiate'])        
        {
            changeOverCase.ChangeOver_Status__c = 'Agent Approved';
            caseList.add(changeOverCase);
        }
        update caseList;
        if(tenantChange == 'true') {
            //  MailJetService.mailTenantToAcceptChangeOver(emailMembername,emailDetails,tenentAmount,DAN);
            approveChangeOver(caseList[0].Id);
        } else {
           // User us = [select id,accountid,contactid from user where accountid=:deplist.Customer__c];
            Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
            Case newCase = new Case(AccountId = deplist.Customer__c, RecordTypeId = caseRecordType, 
                                    ChangeOver_Status__c = 'Agent Initiate', 
                                    Deposit_Account_Number__c = depositId, OwnerId = UserInfo.getUserId(), Origin= 'Web', 
                                    Status='Tenant changeover initiated - agent/landlord',Scheme__c='SafeDeposits Scotland', 
                                    Subject = 'Tenant Changeover requested by '+UserInfo.getUserName(), 
                                    Description=UserInfo.getUserName()+' has initiated Tenant Change Over');
            insert newCase;
            System.debug('Line 606 newCase '+newCase);
            
            tenancyinitiatedemaildetails(depositid,abc);
            
        }
        return message +'='+newdeposit.id; 
    }
    
    @AuraEnabled
    public static string changeoverrequest2(string depositid,string Depolist,string selecteddeposit,String tenantChange){
        String DAN;
        Map<String,String> emailMembername = new Map<String,String>();
        Map<String,String> tenentAmount = new Map<String,String>();                                        
        List<String> emailDetails = new List<String>();    
        
        string message = 'Changeover request initiated';   
        list<Deposit_Allocation__c> depalllist = (List<Deposit_Allocation__c>) System.JSON.deserialize(Depolist, List<Deposit_Allocation__c>.class);
        //    system.debug('line-->139' + depalllist);
        list<deposit__c> selecteddepositlist = (List<deposit__c>) System.JSON.deserialize(selecteddeposit, List<deposit__c>.class);  
        //  system.debug('line-->141' + selecteddepositlist);
        list<Deposit_Allocation__c> depall = [select id,Is_Lead__c,Deposit__c,deposit_holder__r.name,deposit_holder__c,Role__c  from Deposit_Allocation__c where id not in:depalllist and  Deposit__c=:depositid and Role__c='Tenant'];  
        deposit__c deplist = [select id,Property__c,Deposit_Account_Number__c,Customer__c,Customer__r.name,Scheme__C,Status__c from Deposit__c where id=:depositid ];
        //  system.debug('line-->143' + depall);
        //  list<deposit__c> olddepositlist = [select id,Status__c from deposit__c where id=:depositid limit 1];
        //    system.debug('line-->145' + olddepositlist);
        if(selecteddepositlist.size()>0 && depall.size()>0){
            list<Deposit_Allocation__c> newdepll = new list<Deposit_Allocation__c>();
            for (Deposit_Allocation__c dap :depall){
                Deposit_Allocation__c putdepall = new Deposit_Allocation__c();
                putdepall.Deposit_Holder__c=dap.Deposit_Holder__c;
                putdepall.Is_Lead__c = dap.Is_Lead__c;
                putdepall.Deposit__c=selecteddepositlist[0].id;
                DAN =selecteddepositlist[0].Deposit_Account_Number__c;
                putdepall.Role__c ='Tenant';
                newdepll.add(putdepall);
            }
            insert newdepll;
        }
        
        
        if(depalllist.size()>0 && depositid!=null){
            list<Deposit_Allocation__c> updatedlist = new list<Deposit_Allocation__c>();    
            for(Deposit_Allocation__c dac : depalllist){
                Deposit_Allocation__c dact = new  Deposit_Allocation__c();
                dact.id = dac.id;
                dact.Istenantmoved__c=true;
                emailDetails.add(dac.Deposit_Holder__r.Name);
                emailMembername.put(dac.Deposit_Holder__r.Name,dac.Deposit_Holder__r.PersonEmail);
                if(dac.Tenencychangeoveramount__c !=null){
                    dact.Tenencychangeoveramount__c=dac.Tenencychangeoveramount__c;    
                    tenentAmount.put(dac.Deposit_Holder__r.Name,String.valueOf(dac.Tenencychangeoveramount__c));
                }
                else{
                    if(tenantChange == 'true'){
                    }else{
                        dact.Tenencychangeoveramount__c=0; 
                    }
                }
                updatedlist.add(dact);   
            }   
            update updatedlist;
        }
        
        if(depositid !=null ){
            Deposit__c olddeposit = new  Deposit__c();
            olddeposit.id=depositid;
            olddeposit.Tenant_Changeover_Deposit__c=selecteddepositlist[0].id;
            
            olddeposit.Tenant_Changeover_Status__c='In Progress';   
            
            
            update olddeposit;                                        
        }
        if(tenantChange == 'true'){
            MailJetService.mailTenantToAcceptChangeOver(emailMembername,emailDetails,tenentAmount,DAN); 
        }else{
           // User us = [select id,accountid,contactid from user where accountid=:deplist.Customer__c];
            id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
            Case newCase = new Case(AccountId = deplist.Customer__c,RecordTypeId = caseRecordType, 
                                    ChangeOver_Status__c = 'Agent Initiate', 
                                    Deposit_Account_Number__c = depositId,OwnerId = UserInfo.getUserId() ,Origin= 'Web', 
                                    Status='Tenant changeover initiated - agent/landlord',Scheme__c='SafeDeposits Scotland',Subject = 'Tenant Changeover requested by '+UserInfo.getUserName(),Description=UserInfo.getUserName()+' has initiated Tenant Change Over');
            insert newCase;
            System.debug('Line 606 newCase '+newCase);
            tenancyinitiatedemaildetails(depositid,depalllist);}
        
        List<Case> caseList = new List<Case>();
        for(Case changeOverCase : [Select id,Status,ChangeOver_Status__c from Case where Deposit_Account_Number__c =: depositid and Status = 'Tenant changeover initiated - tenant' and ChangeOver_Status__c = 'Tenant Initiate'])        
        {
            changeOverCase.ChangeOver_Status__c = 'Agent Approved';
            caseList.add(changeOverCase);
        }
        update caseList;
        if(tenantChange == 'true'){
            return 'Changeover Approved Successfully='+depositid;
        }      
        else{
            
            return message;}
    }
    
    @AuraEnabled
    public static string changeoverrequest3(String depositid, Integer newdepositamount, Integer newtenantsnumber,
                                            Date newdepositstartdate, String Depolist, String newtenantlist, String tenantChange) 
    {
        String DAN;
        Map<String,String> emailMembername = new Map<String,String>();
        Map<String,String> tenentAmount = new Map<String,String>();                                        
        List<String> emailDetails = new List<String>();    
        
        List<Deposit_Allocation__c> depallist = (List<Deposit_Allocation__c>) System.JSON.deserialize(Depolist, List<Deposit_Allocation__c>.class);
        List<FinalWrapper> tenantRecList = (List<FinalWrapper>)System.JSON.deserialize(newtenantlist, list<FinalWrapper>.class);
        
        List<Deposit_Allocation__c> depall = 
                [SELECT id,Is_Lead__c,Deposit__c,deposit_holder__r.name,deposit_holder__c,Role__c FROM Deposit_Allocation__c 
                 WHERE id NOT in:depallist AND Deposit__c=:depositid AND Role__c='Tenant']; 
        
        //   deposit__c deplist = [select id,Deposit_Account_Number__c,Property__c,Customer__c,Scheme__C,Status__c from Deposit__c where id=:depositid ];   
        Deposit__c deplist = [SELECT id,Name,Branch__c,Branch__r.Id,Protected_Amount__c,Property__c,Deposit_Account_Number__c, 
                              Customer__c,Customer__r.name,Scheme__C,Status__c FROM Deposit__c WHERE id=:depositid ];
        
        DAN = deplist.Deposit_Account_Number__c;
        List<Account> tenantList = new list<Account>();                                        
        user userrec = [Select id, contactid, accountid, User_Type__c, contact.LandLord_Registration_Number__c,account.ownerid
                        from User where id =:UserInfo.getUserId()];                                        
        ID AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId(); 
        for (FinalWrapper t : tenantRecList){
            /* Account acc = new account();
            acc.Salutation = t.title;
            acc.FirstName = t.firstName;
            acc.LastName = t.SurName;
            // acc.Email__c = t.email;
            acc.PersonEmail = t.email;
            acc.Phone = t.phone;
            acc.RecordTypeId = AccountRecordTypeId;
            acc.OwnerId = userrec.account.ownerid;
            tenantList.add(acc);*/
            System.debug('Line 909 weird -> '+tenantRecList);
            if(t.IsOrg){
                Account acc = new account();
                acc.LastName = t.companyName;
                acc.FirstName = t.companyName;
                acc.Email__c = t.email;
                acc.PersonEmail = t.email;
                acc.Phone_Code__pc = t.phoneCode;
                acc.Phone = t.phone;
                acc.RecordTypeId = AccountRecordTypeId;
                acc.OwnerId = userrec.account.ownerid;
                tenantList.add(acc); 
            }else{
                Account acc = new account();
                acc.Salutation = t.title;
                acc.FirstName = t.firstName;
                acc.LastName = t.SurName;
                acc.Email__c = t.email;
                acc.PersonEmail = t.email;
                acc.Phone_Code__pc = t.phoneCode;
                acc.Phone = t.phone;
                acc.RecordTypeId = AccountRecordTypeId;
                acc.OwnerId = userrec.account.ownerid;
                tenantList.add(acc);
            }
        }
        List<id> tenantid = new List<id>();
        if (tenantList.size() > 0){
            Database.SaveResult[] recid = Database.insert(tenantList);
            for (Database.SaveResult sr : recid) {
                if(sr.isSuccess()){
                    tenantid.add(sr.getId());
                }
            }
        }
        List<account> acclist = [Select id, PersonContactId from Account where id in :tenantid]; 
        
        /* deposit__c olddeplist = [select id,Property__c,Customer__c,Scheme__C,Status__c from Deposit__c where id=:depositid ];
        system.debug('line-->62' + olddeplist );
        system.debug('line-->63' + olddeplist.Property__c);
        system.debug('line-->64' + olddeplist.Customer__c);*/
        deposit__c newdeposit = new deposit__c();
        if(deplist.Property__c !=null && deplist.Customer__c!=null){
            newdeposit.Branch__c = deplist.Branch__c;
            newdeposit.Customer__c = deplist.Customer__c;
            newdeposit.Property__c = deplist.Property__c;
            newdeposit.Scheme__c = deplist.Scheme__c;
            newdeposit.Status__c = '';
            newdeposit.Tenant_Changeover_Status__c='In Progress';
            newdeposit.Tenant_Changeover_Deposit__c=depositid;
            newdeposit.Old_Deposit_Number__c=deplist.Name;
            newdeposit.Old_Changeover_Deposit__c=depositid;
            newdeposit.Previous_Protected_Amount__c=deplist.Protected_Amount__c;
            newdeposit.Number_of_Tenants__c = newtenantsnumber;
            newdeposit.Deposit_Amount__c=newdepositamount;
            newdeposit.Start_Date__c=newdepositstartdate;
            insert newdeposit; 
        } 
        List<Deposit_Allocation__c> newdepaloc = new List<Deposit_Allocation__c>();
        if(newdeposit.id !=null){
            for(Deposit_Allocation__c DA :depall ) {                                        
                Deposit_Allocation__c dact = new  Deposit_Allocation__c();                                          
                dact.Deposit_Holder__c=DA.Deposit_Holder__c;
                dact.Deposit__c=newdeposit.id;
                dact.Role__c ='Tenant';
                dact.Is_Lead__c = DA.Is_Lead__c;
                newdepaloc.add(dact);
            }  
            System.debug('913 newdepaloc -->> '+newdepaloc);
            insert newdepaloc; 
        }
        if(newdeposit.id !=null ){
            Deposit__c olddeposit = new  Deposit__c();
            olddeposit.id=depositid;
            olddeposit.Tenant_Changeover_Deposit__c=newdeposit.id;
            olddeposit.New_Changeover_Deposit__c=newdeposit.id;
            olddeposit.Tenant_Changeover_Status__c='In Progress'; 
            
            System.debug('923 olddeposit -->> '+olddeposit);
            update olddeposit;                                        
        } 
        
        List<Deposit_Allocation__c> updatedlist = new List<Deposit_Allocation__c>();    
        for(Deposit_Allocation__c dac : depallist){
            Deposit_Allocation__c dact = new  Deposit_Allocation__c();
            dact.id = dac.id;
            dact.Istenantmoved__c=true;
            emailDetails.add(dac.Deposit_Holder__r.Name);
            emailMembername.put(dac.Deposit_Holder__r.Name,dac.Deposit_Holder__r.PersonEmail);
            if(dac.Tenencychangeoveramount__c !=null){
                dact.Tenencychangeoveramount__c=dac.Tenencychangeoveramount__c;    
                tenentAmount.put(dac.Deposit_Holder__r.Name,String.valueOf(dac.Tenencychangeoveramount__c));
            }
            else{
                if(tenantChange == 'true'){
                }else{
                    dact.Tenencychangeoveramount__c=0;  
                } 
            }
            updatedlist.add(dact);
        }   
        update updatedlist;  
        
        List<Deposit_Allocation__c> newtenantaddlist = new List<Deposit_Allocation__c>(); 
        if(newdeposit.id !=null){
            for(account Acc :acclist ) {                                        
                Deposit_Allocation__c dact = new  Deposit_Allocation__c();                                          
                dact.Deposit_Holder__c=Acc.id;
                dact.Deposit__c=newdeposit.id;
                
                dact.Role__c ='Tenant';
                newtenantaddlist.add(dact);
            } 
        }  
        insert newtenantaddlist;
        
        List<Case> caseList = new List<Case>();
        for(Case changeOverCase : [Select id,Status,ChangeOver_Status__c from Case where Deposit_Account_Number__c =: depositid and Status = 'Tenant changeover initiated - tenant' and ChangeOver_Status__c = 'Tenant Initiate'])        
        {
            changeOverCase.ChangeOver_Status__c = 'Agent Approved';
            caseList.add(changeOverCase);
        }
        update caseList;
        if(tenantChange == 'true'){
            MailJetService.mailTenantToAcceptChangeOver(emailMembername,emailDetails,tenentAmount,DAN); 
        }else{
           // User us = [select id,accountid,contactid from user where accountid=:deplist.Customer__c];
            id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
            Case newCase = new Case(AccountId = deplist.Customer__c, RecordTypeId = caseRecordType, 
                                    ChangeOver_Status__c = 'Agent Initiate', 
                                    Deposit_Account_Number__c = depositId, OwnerId = UserInfo.getUserId() ,Origin= 'Web', 
                                    Status = 'Tenant changeover initiated - agent/landlord', Scheme__c='SafeDeposits Scotland', 
                                    Subject = 'Tenant Changeover requested by '+UserInfo.getUserName(), 
                                    Description = UserInfo.getUserName()+' has initiated Tenant Change Over');
            insert newCase;
            System.debug('Line 606 newCase '+newCase);
            
            tenancyinitiatedemaildetails(depositid,depallist); }  
        if(tenantChange == 'true'){
            return 'Changeover Approved Successfully='+newdeposit.id;
        }      
        else{
            return 'Changeover Request Initiated';}
    }
    
    @AuraEnabled 
    Public static String approveChangeOver(String CaseId){
        List<Case> getCaseDetails = [Select id,ChangeOver_Status__c,Status,Deposit_Account_Number__c,AccountId from Case where id=: CaseId limit 1];   
        try{ 
            //list<id> depositId = new list<id>();
            //  List<Deposit__c> oldDepositList = new List<Deposit__c> ();
            //  List<Deposit__c> depositList = new List<Deposit__c> ();
            //depositId.add(getCaseDetails.Deposit_Account_Number__c);
            
            system.debug('depositIdlist@@  '+getCaseDetails[0].Deposit_Account_Number__c);
            EI_TenentChangeoverApx.approvedchangeover(getCaseDetails[0].Deposit_Account_Number__c);
            getCaseDetails[0].ChangeOver_Status__c= 'Tenant Approved';
            getCaseDetails[0].Status = 'Tenant changeover completed';
            update getCaseDetails;
            return 'Success';
        }
        catch(DMLException e){
            return 'Error '+e.getMessage(); 
        }
        
    }
    
    // @AuraEnabled 
    public static void approvedchangeover(String depositid) {
         List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        
        system.debug('depositIdlist@@ 742 '+depositid);
        List<deposit__c> olddepositlist = [Select Id, Name, Customer__r.Email__c, Customer__c, Property_Address_WO_Country__c, Customer__r.Name, 
                                           Property_Address__c,Customer__r.IsPersonAccount, Customer__r.PersonEmail, 
                                           Tenant_Changeover_Deposit__c, Remaining_Deposit_Amount__c, Payment_Received_By_Scheme__c
                                           from deposit__c where Id =:depositid limit 1];
        if(!olddepositlist.isEmpty()) 
        {
            
            List<deposit__c> newdepositlist = [select id, status__c, Protected_Amount__c from deposit__c 
                                               where id=:olddepositlist[0].Tenant_Changeover_Deposit__c limit 1 ];     
            List<Deposit_Allocation__c> olddepositalloclist = 
                [Select Id, Deposit__c, Deposit_Holder__c, Deposit_Holder__r.personcontactid, Deposit_Holder__r.Personemail, 
                 Deposit_Holder__r.Name, Istenantmoved__c, Tenencychangeoveramount__c  
                 from Deposit_Allocation__c where Deposit__c=: depositid and Istenantmoved__c=true ];
            
            List<Id> accId = new list<Id>();
            
            if(olddepositalloclist.size()>0) {
                for (Deposit_Allocation__c dall : olddepositalloclist) {
                    
                    for(Account acc: [Select Id, (Select Id, ValidInternationBankDetails__c, Account__c, Contact__c, Contact__r.Name, 
                                      Bank_Account_Holder_Name__c, Account_Number__c, Bank_Name__c, Sort_Code__c, International_Account_Number__c,  
                                      International_Bank_Account_Holder_Name__c, Bank_Address__c, International_Bank_Name__c, Swift_Code__c, 
                                      BIC__c, IBAN__c from Bank_Accounts__r), (Select Id from Contacts limit 1) 
                                      from Account where Id=: dall.Deposit_Holder__c]) 
                    {
                        system.debug('@@ bank '+acc.Bank_Accounts__r);
                        system.debug('@@ Payment_Received_By_Scheme__c '+olddepositlist[0].Payment_Received_By_Scheme__c);
                        system.debug('@@ Line 1017 '+acc.Contacts[0]);
                        if(acc.Bank_Accounts__r.size()==0) {
                            system.debug('@@ Line 1019 '+acc.Contacts[0]);
                            CreateNewCreditNote(null, null,dall.Tenencychangeoveramount__c, olddepositlist[0].id, 
                                                olddepositlist[0].Payment_Received_By_Scheme__c, null, acc.Contacts[0], null);  
                            
                        }
                        else {
                            system.debug('@@ Line 1025 '+acc.Contacts[0]);
                            CreateNewCreditNote(null, null,dall.Tenencychangeoveramount__c, olddepositlist[0].id, 
                                                olddepositlist[0].Payment_Received_By_Scheme__c, null, acc.Contacts[0], acc.Bank_Accounts__r );  
                        }
                    }
                    
                }
            }
            //System.debug('1033 newdepositlist[0].id -> '+newdepositlist[0].id);
            if(olddepositlist.size()>0) {
                Deposit__c newdeposit = new  Deposit__c();
                newdeposit.id=newdepositlist[0].id;
                newdeposit.Status__c = 'Deposits held by scheme';
                newdeposit.Protected_Amount__c=olddepositlist[0].Remaining_Deposit_Amount__c;
                newdeposit.Tenant_Changeover_Status__c = '';
                newdeposit.Previous_Protected_Amount__c=olddepositlist[0].Remaining_Deposit_Amount__c;
                update newdeposit;  
            }
            
            if(olddepositlist.size()>0) {
                Deposit__c olddeposit = new  Deposit__c(); 
                olddeposit.id=olddepositlist[0].id;
                olddeposit.Status__c='Deposit Closed';
                olddeposit.Tenant_Changeover_Status__c='Approved';
                olddeposit.Date_Moved__c=System.today();
                //olddeposit.Status__c=null;
                update olddeposit;     
            }
            
            
            /**
            * @who  Prakhar Kushwaha
            * @what Shifting all the installments from old deposit to new deposit START
            * @when 11/08/2021
            **/
            /*
            List<Installment__c> installmentsOnOldDeposit = 
                [Select id, Name, Deposit__c, Deposit__r.Name, X30_Days_Completion_Date__c, Amount__c, Bank_Account_Holder_Name__c, 
                 Bank_Account_Number__c, BIC__c, Bank_Name__c, Bank_Sort_Code__c, BLK_Number__c, Contact__c, Created_At__c, 
                 Credit_Note_Reference__c, Custom_Account_Number__c, Due_Date__c, Installment_Type__c, International_Payment__c, 
                 Is_Topup__c, Payment_Method__c, Payment_Reference__c, Payment_type__c, Payment_type_status__c, Reason_For_Flag__c, 
                 Reason_For_Flag_Specified__c, Status__c, Swift_Code__c 
                 from Installment__c where Deposit__c=:depositid];
            
            List<Installment__c> installmentsOnNewDeposit = new List<Installment__c>();
            System.debug('1061 installmentsOnOldDeposit -> '+installmentsOnOldDeposit.size());
            for(Installment__c instal: installmentsOnOldDeposit) {
                Installment__c newInstal = new Installment__c();
                newInstal  = instal.clone(false, true, true, false);
                newInstal.Deposit__c=newdepositlist[0].Id;
                installmentsOnNewDeposit.add(newInstal);
                System.debug('1066 newInstal -> '+newInstal);
            }
            
            if(!installmentsOnNewDeposit.isEmpty()) {
                insert installmentsOnNewDeposit;
            }
            System.debug('Line 1054 -> '+installmentsOnOldDeposit); */
            
            
            if(olddepositlist[0].Remaining_Deposit_Amount__c>0) 
            {
                String strResult1=EI_UtilityClassForPayments.getInstallmentForChangeover(null, null, null, olddepositlist[0].Remaining_Deposit_Amount__c, 
                                                                                         System.today(), olddepositlist[0].Id, null, null, true, 
                                                                                         'Paid', 'Payable', 'Final Payment', null, null, null);
                String strResult2=EI_UtilityClassForPayments.getInstallmentForChangeover(null, null, null, olddepositlist[0].Remaining_Deposit_Amount__c, 
                                                                                         System.today(), newdepositlist[0].Id, null, null, false, 
                                                                                         'Collected', 'Receivable', 'Final Payment', 
                                                                                         System.today(), null, null);
            }
            
            /**
            * Shifting all the installments from old deposit to new deposit END
            **/
            
            if(olddepositalloclist.size()>0 &&  olddepositlist.size()>0){
                
                for(Deposit_Allocation__c depoalloc : olddepositalloclist) {
                    
                    EI_TenancyChangeoverEmail.changeoveracceptancetotenant(depoalloc.Deposit_Holder__r.Personemail, depoalloc.Deposit_Holder__r.Name, 
                                                                           olddepositlist[0].Name, olddepositlist[0].Property_Address_WO_Country__c, 
                                                                           depoalloc.Deposit__c, depoalloc.Deposit_Holder__r.personcontactid);
                    emailWrapperList.add(EI_TenancyChangeoverEmail.changeoveracceptancetotenant(depoalloc.Deposit_Holder__r.Personemail, depoalloc.Deposit_Holder__r.Name, 
                                                                                                olddepositlist[0].Name, olddepositlist[0].Property_Address_WO_Country__c, 
                                                                                                depoalloc.Deposit__c, depoalloc.Deposit_Holder__r.personcontactid));  
                    
                }
                
                EI_TenancyChangeoverEmail.changeoveracceptance(olddepositlist[0].Customer__r.Email__c, olddepositlist[0].Customer__r.PersonEmail, 
                                                               olddepositlist[0].Customer__r.Name,olddepositlist[0].Name, 
                                                               olddepositlist[0].Property_Address_WO_Country__c,olddepositlist[0].Customer__c,olddepositlist[0].Id);
                
                emailWrapperList.add(EI_TenancyChangeoverEmail.changeoveracceptance(olddepositlist[0].Customer__r.Email__c, olddepositlist[0].Customer__r.PersonEmail, 
                                                                                    olddepositlist[0].Customer__r.Name, olddepositlist[0].Name, 
                                                                                    olddepositlist[0].Property_Address_WO_Country__c, olddepositlist[0].Customer__c, 
                                                                                    olddepositlist[0].Id));
            }
            
        }
        
    }
    
    public static void CreateNewCreditNote(String creditReference, String paymentReference, Decimal Amount, String DspositId, 
                                           Date paymentRecievedByScheme, String CaseIDs, Contact con, Bank_Account__c bankdetails) 
    {System.debug('Line 1083');
     System.debug('Line 1084 '+con);
        if(Amount>0) {
            System.debug('Line 1085 CreateNewCreditNote -> '+con.Id);
            String returnedStr = EI_UtilityClassForPayments.createCreditNoteRecord(creditReference, con.Id, paymentReference, Amount,
                                                                                   paymentRecievedByScheme, DspositId, CaseIDs, bankdetails, 
                                                                                   'Final Payment', 'Tenant changeover', null);
        }
    }
    
    /* wrapper class */  
    public class depositwrapper {
        @AuraEnabled public  Deposit__c Depositobject{get;set;}
        @AuraEnabled public  Deposit_Allocation__c Depallobject{get;set;}
        
        public depositwrapper(Deposit__c Depositobject ){
            this.Depositobject = Depositobject;
        }
        
        public depositwrapper(Deposit_Allocation__c Depallobject ){
            this.Depallobject = Depallobject;
        }

    }
    
    @Auraenabled
    public static string tenancyinitiatedemaildetails (string depositid,list<Deposit_Allocation__c>movingtenants ){
       List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        string message = 'Emails sent';
        string tenantData = '<table>';
        list<deposit__c> olddeposit = [select id,name,Customer__c,Property_Address_WO_Country__c,Property_Address__c,Customer__r.IsPersonAccount,customer__r.name,Customer__r.PersonEmail,customer__r.Email__c from deposit__c where id=:depositid limit 1];
        list<Deposit_Allocation__c> oldDepall = [select id,Deposit_Holder__r.Personcontactid,Tenencychangeoveramount__c,Deposit_Holder__r.name,Deposit_Holder__r.PersonEmail,Deposit__c from Deposit_Allocation__c where id in : movingtenants and Deposit__c=:depositid ];
        system.debug('line-->268' + oldDepall);
        
        if(oldDepall.size()>0 ){
            for(Deposit_Allocation__c depllone:oldDepall){
                tenantData+= '<tr>';
                tenantData+= '<td>'+depllone.Deposit_Holder__r.name+':'+'<td>';
                tenantData+= '<td>'+'£'+depllone.Tenencychangeoveramount__c+'<td>';
                tenantData+= '</tr>';  
            } 
            tenantData+= '</table><br/><br/>';    
        }
        //  List<String> emaillist = new List<String>();
        //  List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage >();
        if(olddeposit.size()>0 && oldDepall.size()>0 ){
        for (Deposit_Allocation__c dep :oldDepall ){
            EI_TenancyChangeoverEmail.changeoverrequestedtenants(dep.Deposit_Holder__r.PersonEmail,dep.Deposit_Holder__r.name,olddeposit[0].Name,olddeposit[0].Property_Address_WO_Country__c,dep.Deposit_Holder__r.Personcontactid,dep.Deposit__c,tenantData);
        emailWrapperList.add( EI_TenancyChangeoverEmail.changeoverrequestedtenants(dep.Deposit_Holder__r.PersonEmail,dep.Deposit_Holder__r.name,olddeposit[0].Name,olddeposit[0].Property_Address_WO_Country__c,dep.Deposit_Holder__r.Personcontactid,dep.Deposit__c,tenantData));    
        }
        EI_TenancyChangeoverEmail.changeoverrequestcustomer(olddeposit[0].Customer__r.Email__c,olddeposit[0].Customer__r.PersonEmail,olddeposit[0].Customer__r.Name,olddeposit[0].Name,olddeposit[0].Property_Address_WO_Country__c,olddeposit[0].Customer__c,olddeposit[0].Id);
        emailWrapperList.add(EI_TenancyChangeoverEmail.changeoverrequestcustomer(olddeposit[0].Customer__r.Email__c,olddeposit[0].Customer__r.PersonEmail,olddeposit[0].Customer__r.Name,olddeposit[0].Name,olddeposit[0].Property_Address_WO_Country__c,olddeposit[0].Customer__c,olddeposit[0].Id));
            if(emailWrapperList.size()>0){
        EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
            }
        }
        return message;
        
    }
    
    public class FinalWrapper{
        @AuraEnabled
        public String firstName{ get; set; }
        
        @AuraEnabled
        public String SurName{ get; set; }
        
        @AuraEnabled
        public String email{ get; set; }
        
        @AuraEnabled
        public String phoneCode{ get; set; }
        
        @AuraEnabled
        public String phone{ get; set; }
        
        @AuraEnabled
        public String title{ get; set; }
        
        
        @AuraEnabled
        public Boolean IsOrg{ get; set; }
        
        @AuraEnabled
        public String companyName{ get; set; }
        
        
    }
    
    @AuraEnabled
    public static String checkDuplicateEmail(String email, String phone, String type, String firstname, String surname){
        try{
            if (type == 'onlyemail'){
                Integer emailCount = [Select count()
                                      from Contact
                                      where email = :email and email != null];
                
                if (emailCount > 0){
                    return ('Duplicate email');
                }
                
             /*   if(firstname != '' && surname != ''){
                    String fullNameForSearch = firstname.trim() + ' ' + surname.trim();
                    List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
                                                          RETURNING Contact(ID WHERE email=:email.trim()) ];
                    System.debug('searchNameList : ' + searchNameList[0].size());
                    if(searchNameList[0].size() > 0){
                        return ('Duplicate Name');
                    }
                }
            */
                 
            } else if (type == 'onlyphone'){
                Integer phoneCount = [Select count()
                                      from Contact
                                      where phone = :phone and phone != null];
                if (phoneCount > 0){
                    return ('Duplicate Phone');
                }
            }
            return 'No Duplicate';
            
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<string> getPhoneCodePiclistValues(){
        try {
            Schema.DescribeFieldResult fieldDescription = Contact.Phone_Code__c.getDescribe();
            List<String> countryCodes = new List<String>();
            for (Schema.PicklistEntry cc : fieldDescription.getPicklistValues()) {
                
                if(cc.isActive()){
                    countryCodes.add(cc.getValue());
                }    
            }
            return countryCodes;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }
    @AuraEnabled
    public static List<Deposit_Allocation__c> getTenantsInformation(List<Id> allocationIds, String depId) {
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        depositAllocationList = [SELECT Id, Deposit__r.Customer_Name__c, Deposit__r.Customer__r.Name, Deposit__r.Protected_Amount__c, 
                                 Deposit_Holder__r.PersonContactId, Deposit_Holder__c, Deposit_Holder__r.Name, Deposit_Holder__r.Salutation, Is_Lead__c,
                                 Deposit_Holder__r.PersonMailingStreet,Deposit_Holder__r.PersonMailingCity,Deposit_Holder__r.PersonMailingCountry,Deposit_Holder__r.PersonMailingPostalCode,Deposit_Holder__r.PersonEmail
                                 from Deposit_Allocation__c where Deposit__c =: depId AND Deposit_Holder__c IN :allocationIds AND Role__c='Tenant' 
                                 AND Deposit_Holder__r.PersonMailingStreet = ''
                                 AND Deposit_Holder__r.PersonMailingCity = ''
                                 AND Deposit_Holder__r.PersonMailingCountry = ''
                                 AND Deposit_Holder__r.PersonMailingPostalCode = ''
                                 AND Deposit_Holder__r.PersonEmail = '' Order By Is_Lead__c desc];
        return depositAllocationList;
    }
    
    

    
}