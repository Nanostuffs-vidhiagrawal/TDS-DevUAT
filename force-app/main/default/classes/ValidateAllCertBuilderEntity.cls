@RestResource(urlMapping='/CreateRecordFromCert/*/*')
global without sharing class ValidateAllCertBuilderEntity {
   global class ResponseClass 
    {

        global String responseID;
        global String message;
        global String retURL;
      

        global ResponseClass(String responseID, String message, String retURL) 
        {
            this.responseID = responseID;
            this.message = message;
            this.retURL = retURL;
        }
    }
    
@HttpPost
    global static ResponseClass createDraft(CertificateBuilderDraftWrapper wrapper) {
       //  system.debug('@@draft '+jsonDraft);
         try{
            String[] uriKeys = RestContext.request.requestURI.split('/');  
        String prevRecordId= uriKeys.get(uriKeys.size()-1);
          String recordType= uriKeys.get(uriKeys.size()-2);     
             system.debug('prevRecordId '+prevRecordId+' ** '+recordType);
               Map<String, String> pstAreaCode=  new Map<String, String>();
      // CertificateBuilderDraftWrapper wrapper = (CertificateBuilderDraftWrapper) JSON.deserialize(jsonDraft, CertificateBuilderDraftWrapper.class);
      CertificateBuilderDraftWrapper.cls_Landlords[] landlords = wrapper.Landlords;
              CertificateBuilderDraftWrapper.cls_Tenants[] tenants = wrapper.Tenants;
        boolean isOrguser;
             Id personAccountRectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Landlord').getRecordTypeId();
             Property__c prop = new Property__c();
              Deposit__c dep = new Deposit__c();
              List<Account> listLandLordAccount = new List<Account>();  
               List<Contact> listLandLordContact = new List<Contact>();  
             
             List<Account> listTenantAccount = new List<Account>();
               Id AccountRecordTypeId;
              List<Property_Allocation__c> propAllocList = new List<Property_Allocation__c>();
             if(recordType == 'Property'){

             Boolean checkPostCode = EI_Properties.contains(wrapper.TenantAddress.postalcode);
            if(checkPostCode){
             
                  prop.Property_status__c = 'Active'; 
                    prop.Street__c = wrapper.TenantAddress.street;
                    prop.City__c = wrapper.TenantAddress.city;
                    prop.County__c = wrapper.TenantAddress.county;
                    prop.Country__c = wrapper.TenantAddress.country;
                    prop.Postal_Code__c = wrapper.TenantAddress.postalcode;
                    prop.Property_Owner__c = System.Label.DefaultPropertyOwner;
                  prop.House_No__c = wrapper.TenantAddress.houseNo;
                if(wrapper.TenantAddress.localAuthorityArea == null || wrapper.TenantAddress.localAuthorityArea == ''){
                    for(Area_Code_For_Landlord__mdt areCode : [select id,Local_Authority_Area__c, Postal_Code__c from Area_Code_For_Landlord__mdt where Postal_Code__c=: prop.Postal_Code__c]){
                    pstAreaCode.put(areCode.Postal_Code__c, areCode.Local_Authority_Area__c);
                    }
                        if(prop.Local_Authority_Area__c == '' || prop.Local_Authority_Area__c == null){
                        prop.Local_Authority_Area__c = pstAreaCode.get(prop.Postal_Code__c);
                    }
                }else{
                    prop.Local_Authority_Area__c = wrapper.TenantAddress.localAuthorityArea;
                }
                List<Property__c> oldProp = [Select id from Property__c where id =: prevRecordId limit 1];
                if(oldProp != NULL && oldProp.size()>0)  {
                     prop.Id = oldProp[0].id;
                    
                }
                 upsert prop;
                  
                 return new ResponseClass(prop.id, 'Success','');    
                 
            }
             else{
                    return new ResponseClass(null, 'Please select post code of scotland','');    
              //   return 'Post Code is not allowed';
             }
         }
             else if(recordType == 'Landlord'){
                 Property__c oldProp;             
                 List<Account> accList;
                  set<Id> propAccId = new set<Id>();
                 if(!String.isBlank(prevRecordId)){
                     oldProp = [SELECT Id,(Select id,Contact__r.AccountId from Property_Allocations__r) FROM Property__c where id =:  prevRecordId ];
                     if(oldProp.Property_Allocations__r.size()>0 ){
                       
                         for(Property_Allocation__c propall: oldProp.Property_Allocations__r){
                             propAccId.add(propall.Contact__r.AccountId );
                         }
                         accList = [Select id from Account where id in: propAccId];
                         delete oldProp.Property_Allocations__r;
                      
                     }
                    
                 }    
                 
                 //  Map<Id, CertificateBuilderDraftWrapper.cls_Landlords> maplandlord= new Map<Id, CertificateBuilderDraftWrapper.cls_Landlords>();
                  
                 for(CertificateBuilderDraftWrapper.cls_Landlords landLordWrapper : landlords){
               Account acc;
               Contact con; 
                     Integer counter=1;
                       if (landLordWrapper.isOrguser){ 
                          AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                             acc = new Account(BackEndLandlordNo__c='Landlord'+counter ,name = landLordWrapper.LandlordCompanyName, Phone_Code__c = landLordWrapper.LandlordCompanyPhoneCode, Phone = landLordWrapper.LandlordCompanyPhone, RecordTypeId = AccountRecordTypeId, Email__c = landLordWrapper.LandlordEmail,
                              OwnerId = userinfo.getUserId(),BillingStreet = landLordWrapper.LandlordAddress.street,
                             BillingCity = landLordWrapper.LandlordAddress.city,BillingPostalCode = landLordWrapper.LandlordAddress.postalcode,BillingCountry = landLordWrapper.LandlordAddress.country,BillingState = landLordWrapper.LandlordAddress.county);
                        
                           con = new contact(BackEndLandlordNo__c='Landlord'+counter,AccountId = Acc.id, Salutation = landLordWrapper.LandlordTittle, FirstName = landLordWrapper.LandlordFirstName,Account_Status__c= 'Active',
                           lastname = landLordWrapper.LandlordLastName, email = landLordWrapper.LandlordEmail, Phone_Code__c = landLordWrapper.LandlordPhoneCode, Phone = landLordWrapper.LandlordPhone, MailingStreet = landLordWrapper.LandlordAddress.street,
                           MailingCity = landLordWrapper.LandlordAddress.city,MailingPostalCode = landLordWrapper.LandlordAddress.postalcode,MailingCountry = landLordWrapper.LandlordAddress.country,
                           MailingState = landLordWrapper.LandlordAddress.county, LandLord_Registration_Number__c = landLordWrapper.LandlordRegNumber, 
                          LandLord_Registration_Status__c = landLordWrapper.LandlordRegStatus,PrimaryLandlord__c = landLordWrapper.isPrimaryLandlord);
                               
                       listLandLordAccount.add(acc);
                       listLandLordContact.add(con);
                      }          
                      else{
                          AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId();
                                                  Acc = new Account();
                                                  Acc.FirstName = landLordWrapper.LandlordFirstName;
                                                  Acc.LastName = landLordWrapper.LandlordLastName;
                                                  Acc.Salutation = landLordWrapper.LandlordTittle;
                                                  acc.OwnerId = Userinfo.getUserId();
                                                  Acc.PersonEmail = landLordWrapper.LandlordEmail;
                                                  Acc.Email__c = landLordWrapper.LandlordEmail;
                                                  Acc.PersonHomePhone = landLordWrapper.LandlordPhone;
                                                  Acc.Phone_Code__pc = landLordWrapper.LandlordPhoneCode;
                                                  Acc.Phone = landLordWrapper.LandlordPhone;
                                                  Acc.RecordTypeId = AccountRecordTypeId;
                                                //  Acc.Parent_person_account__c = landLordWrapper.LandlordLastName;
                                                  acc.BillingStreet = landLordWrapper.LandlordAddress.street;
                                                  acc.BillingCity = landLordWrapper.LandlordAddress.city;
                                                  acc.BillingPostalCode = landLordWrapper.LandlordAddress.postalcode;
                                                  acc.BillingCountry = landLordWrapper.LandlordAddress.country;
                                                  acc.BillingState = landLordWrapper.LandlordAddress.county;
                                                  acc.PersonMailingStreet = landLordWrapper.LandlordAddress.street;
                                                  acc.PersonMailingCity = landLordWrapper.LandlordAddress.city;
                                                  acc.PersonMailingPostalCode = landLordWrapper.LandlordAddress.postalcode;
                                                  acc.PersonMailingCountry = landLordWrapper.LandlordAddress.country;
                                                  acc.PersonMailingState = landLordWrapper.LandlordAddress.county;
                                                  acc.LandLord_Registration_Number__pc = landLordWrapper.LandlordRegNumber;
                                                  acc.LandLord_Registration_Status__pc = landLordWrapper.LandlordRegStatus;
                                                  acc.Account_Status__pc= 'Active';
                                                  acc.PrimaryLandlord__pc = landLordWrapper.isPrimaryLandlord;
                                              
                          listLandLordAccount.add(acc);
                      }
                 }
                 
                Insert listLandLordAccount;
                   // system.debug('@@ total maplandlord '+maplandlord);
                 for(Account Acc : listLandLordAccount){
                     if( Acc.IsPersonAccount == false ){     
                         for(Contact con : listLandLordContact){
                             if(con.BackEndLandlordNo__c == Acc.BackEndLandlordNo__c){
                                  con.AccountId = Acc.Id;
                                 break;
                             }
                            
                         }
                     /*    contact con = new contact(AccountId = Acc.id, Salutation = maplandlord.get(Acc.Id).LandlordTittle, FirstName =  maplandlord.get(Acc.Id).LandlordFirstName,Account_Status__c= 'Active',
                           lastname =  maplandlord.get(Acc.Id).LandlordLastName, email =  maplandlord.get(Acc.Id).LandlordEmail, Phone_Code__c =  maplandlord.get(Acc.Id).LandlordPhoneCode, Phone =  maplandlord.get(Acc.Id).LandlordPhone, MailingStreet =  maplandlord.get(Acc.Id).LandlordAddress.street,
                           MailingCity =  maplandlord.get(Acc.Id).LandlordAddress.city,MailingPostalCode =  maplandlord.get(Acc.Id).LandlordAddress.postalcode,MailingCountry =  maplandlord.get(Acc.Id).LandlordAddress.country,
                           MailingState =  maplandlord.get(Acc.Id).LandlordAddress.county, LandLord_Registration_Number__c =  maplandlord.get(Acc.Id).LandlordRegNumber, 
                          LandLord_Registration_Status__c =  maplandlord.get(Acc.Id).LandlordRegStatus,PrimaryLandlord__c =  maplandlord.get(Acc.Id).isPrimaryLandlord);
                        listLandLordContact.add(con);*/
                     }
                    
                 }
                 if(!listLandLordContact.IsEmpty()){
                       Insert listLandLordContact; 
                 }

                 for(Contact con : [Select id,AccountId,Account.IsPersonAccount,PrimaryLandlord__c,LandLord_Registration_Number__c,LandLord_Registration_Status__c from Contact where Accountid in: listLandLordAccount and Account.IsPersonAccount = true]){
                     listLandLordContact.add(con);
                 }
                 system.debug('@@ total Contact '+listLandLordContact);
              /*   if(listLandLordContact.isEmpty()){
                    listLandLordContact = [Select id,AccountId,firstName,MailingStreet,MailingCity,MailingCountry,MailingState,MailingPostalCode,Phone,Email, lastName from Contact where AccountId in: listLandLordAccount];
               
                 }else{
                     Insert listLandLordContact;
                 }*/
                      String propertyRegNumber = '';
                 Id primaryLandlordId;
                 if(listLandLordContact.size()>0){
                       for(Contact landLordCon : listLandLordContact){
                        Property_Allocation__c propAlloc = new Property_Allocation__c();
                        propAlloc.Contact__c = landLordCon.Id;
                           if(prevRecordId != null){
                               propAlloc.Property__c = prevRecordId;
                           }
                           if(landLordCon.PrimaryLandlord__c){
                               propAlloc.Relation_to_Property__c = 'Primary Landlord';
                               primaryLandlordId = landLordCon.AccountId;
                           }else{
                               propAlloc.Relation_to_Property__c = 'Joint Landlord';
                           }
                           if(landLordCon.LandLord_Registration_Number__c != '' & landLordCon.LandLord_Registration_Number__c != NULL ){
                                 propertyRegNumber = EI_AddNonMemberLandlord.getPropertyRegNumber(prevRecordId,landLordCon.LandLord_Registration_Number__c);
                           }
                      
                       propAlloc.Landlord_Registrataion_Status__c = landLordCon.LandLord_Registration_Status__c;
                       propAlloc.Landlord_Registration_Number__c = propertyRegNumber;
                           propAllocList.add(propAlloc);
                  }
                 
                 }
                 Property__c updateProp = [Select id,Property_Owner__c from Property__c where id=: prevRecordId];
                 updateProp.Property_Owner__c = primaryLandlordId;
                 update updateProp;
                 if(!propAllocList.isEmpty()){
                     insert propAllocList;
                 }
                 
                 if(accList!= NULL && accList.size()>0){
                     delete accList;
                 }
                  return new ResponseClass(prevRecordId, 'Success','');  
               //  return prevRecordId;
             }
             else if(recordType == 'Deposit'){
                  List<Property__c> oldprop = new List<Property__c>();
                  List<Deposit__c> oldDep = [Select id from Deposit__c where id =: prevRecordId limit 1];
               if(oldDep.size()==0){
                      oldprop = [Select id,Property_Owner__c from Property__c where id=: prevRecordId limit 1];
                 }
                 system.debug('PROP '+oldprop.size());
                   ID depositRecordTypeId = Schema.SObjectType.Deposit__c.getRecordTypeInfosByDeveloperName().get('SDS_Deposit').getRecordTypeId();   
                 
                
                   dep.Rent_Amount__c = Decimal.valueOf(wrapper.RentAmount);
                   dep.Protected_Amount__c = Decimal.valueOf(wrapper.ProtectedAmount);
                     dep.Deposit_Amount__c = Decimal.valueOf(wrapper.DepositAmount);
                      dep.Start_Date__c = parseDate(wrapper.TenancyAgreementStartDate);
                      dep.Date_Deposit_Received__c = parseDate(wrapper.landlordReceivedDate);
                   
                   dep.Status__c = 'Registered (not paid)';
                 if(oldprop != NULL && oldprop.size()>0){
                      dep.Scheme__c = [select id from Scheme__c where Name = 'SafeDeposits Scotland'][0].Id; 
                     dep.Customer__c = oldprop[0].Property_Owner__c;
                    dep.Property__c = oldprop[0].Id;
                 }
                   
                   dep.WebsiteData__c = true;
                   dep.User_reference_for_the_deposit__c = wrapper.DepositReference;
                 if(oldDep != NULL && oldDep.size()>0)  {
                     dep.id = oldDep[0].id;
                     update dep;
                 }else{
                     insert dep;
                 }
                
                 dep.recordtypeId = depositRecordTypeId;
               
                    return new ResponseClass(dep.id, 'Success','');  
                //  return dep.id;
             }
             else if(recordType == 'Tenant'){
                Deposit__c oldDep;             
                 List<Account> oldAccList;
                  set<Id> depAccId = new set<Id>();
                 if(!String.isBlank(prevRecordId)){
                     oldDep = [SELECT Id,(Select id,Deposit_Holder__c from Deposit_Allocations__r) FROM Deposit__c where id =:  prevRecordId ];
                     if(oldDep.Deposit_Allocations__r.size()>0 ){
                       
                         for(Deposit_Allocation__c depAll: oldDep.Deposit_Allocations__r){
                               depAccId.add(depAll.Deposit_Holder__c);
                         }
                       oldAccList = [Select id from Account where id in: depAccId];
                      delete oldDep.Deposit_Allocations__r;
                     }
                    
                 }    
                 
                    list<Deposit_Allocation__c> depositAllocationlist = new list<Deposit_Allocation__c>();
                   list<id> tenantid = new list<id>();
                Set<String> emailIds = new Set<String>();
                Map<String,Id> mapOfemailVsAccId = new Map<String,Id>();
                 Map<String,String> mapOfemailVsAccName = new Map<String,String>();
                 
                 for(CertificateBuilderDraftWrapper.cls_Tenants tenantWrapper : tenants){
                       if(String.isnotEmpty(tenantWrapper.TenantEmail)) 
                   {   emailIds.add(tenantWrapper.TenantEmail.trim() );}
                 }
                  if(!emailIds.isEmpty()){
            for(User tentUser :  [SELECT email, Profile.Name ,Contact.AccountId,Contact.Name
                                        FROM User
                                        WHERE (email IN : emailIds ) and (Profile.Name = 'Tenant' ) and ContactId != null]){
                                            if(!mapOfemailVsAccId.containsKey(tentUser.email)) {     
                                                mapOfemailVsAccId.put(tentUser.email.trim(),tentUser.Contact.AccountId);
                                                mapOfemailVsAccName.put(tentUser.email.trim(),tentUser.Contact.Name);
                                            }
                                        }
                              
        }
                 
                 
            ID TenAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId();
            for(CertificateBuilderDraftWrapper.cls_Tenants tenantWrapper : tenants){
                  Account tenant = new Account();
                   String tenantName = tenantWrapper.TenantFirstName +' '+tenantWrapper.TenantLastName;
             if(mapOfemailVsAccId.containsKey(tenantWrapper.TenantEmail.trim()) && (mapOfemailVsAccName.get(tenantWrapper.TenantEmail.trim()) == tenantName || mapOfemailVsAccName.get(tenantWrapper.TenantEmail.trim()) == tenantWrapper.TenantEmail)){
                tenantid.add(mapOfemailVsAccId.get(tenantWrapper.TenantEmail.trim())); 
                }
                    else if (tenantWrapper.isOrguser){
                        tenant.LastName = tenantWrapper.TenantcompanyName;
                        tenant.Company_Name__c = tenantWrapper.TenantcompanyName;
                        tenant.Email__c = tenantWrapper.TenantEmail;
                        tenant.Phone_Code__pc = tenantWrapper.phoneCode;
                        tenant.Phone = tenantWrapper.TenantPhone;
                        tenant.PersonEmail = tenantWrapper.TenantEmail;
                        tenant.OwnerId = Userinfo.getUserId();
                        tenant.RecordTypeId = TenAccountRecordTypeId;
                    } else{
                        tenant.Salutation = tenantWrapper.TenantTittle;
                        tenant.FirstName = tenantWrapper.TenantFirstName;
                        tenant.LastName = tenantWrapper.TenantLastName;
                        tenant.Email__c = tenantWrapper.TenantEmail;
                        tenant.PersonEmail = tenantWrapper.TenantEmail;
                        tenant.Phone_Code__pc = tenantWrapper.phoneCode;
                        tenant.Phone = tenantWrapper.TenantPhone;
                        tenant.RecordTypeId = TenAccountRecordTypeId;
                        tenant.OwnerId = Userinfo.getUserId();
                    }
                
                  
               /* Account tenant = new Account();
                tenant.recordTypeId = personAccountRectypeId;
                
                tenant.LastName = tenantWrapper.TenantLastName;
                tenant.personemail = tenantWrapper.Tenantemail;
                tenant.phone = tenantWrapper.TenantPhone;  
                tenant.OwnerId = '0058E000006wQw2QAE'; // @todo   */
                listTenantAccount.add(tenant);
            }
                 if(!listTenantAccount.isEmpty()){
                   //   Insert listTenantAccount;
                
          Database.SaveResult[] recid = Database.insert(listTenantAccount);
          for (Database.SaveResult sr : recid){
            if (sr.isSuccess()){
                        tenantid.add(sr.getId());
            }
          }
          
                 }
              list<account> acclist = [select id, PersonContactId
                                     from Account
                                     where id in :tenantid];
                for (account Acc : acclist){
                    
                     depositAllocationlist.add(new Deposit_Allocation__c(Deposit_Holder__c = acc.id, Contact__c = acc.PersonContactId, Is_Lead__c = false, Role__c = 'Tenant', Deposit__c = prevRecordId));
                }
                    if (depositAllocationlist.size() > 0){
                        insert depositAllocationlist;
                    }
                  if(oldAccList!= NULL && oldAccList.size()>0){
                     delete oldAccList;
                 }
                String retURL = System.Label.Lightning_Component_URL+'login/SelfRegister?draftId='+prevRecordId; 
                  return new ResponseClass(prevRecordId, 'Success',retURL);  
             }else{
                 return null;
             }

            
        }catch(Exception e){
            
           /* RestResponse res = RestContext.response;
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(e.getMessage());
            
            return e.getMessage();*/
            if(e.getMessage().contains('REQUIRED_FIELD_MISSING')){
                return new ResponseClass(null, 'Please fill required fields','');  
            }else{
                return new ResponseClass(null, 'There are some issues while processing please try after some time','');  
            }
             
            
        }
    }
       private static Date parseDate(String dateStr){
        //String[] datecomps = dateStr.split('-');
        String[] datecomps = dateStr.split('/');
        
        if(dateComps.size() != 3)
            throw new AuraHandledException('Wrong Date Format!');
            
        return Date.newInstance(Integer.valueOf(datecomps[2]), Integer.valueOf(datecomps[1]), Integer.valueOf(datecomps[0]));
    }
}