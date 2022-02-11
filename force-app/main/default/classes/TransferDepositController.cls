public without sharing class TransferDepositController {
    
    @Auraenabled
    public static List<Deposit__c> getDepositInformation() {
        List<Deposit__c> depositList = new List<Deposit__c>();
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;        
        depositList = [SELECT Id,Name,Property_Address__c,Protected_Amount__c,Customer__c,Customer__r.Name 
                       from Deposit__c where Customer__c =:accountid and Status__c=:Label.Deposits_held_by_SafeDeposits_Scotland
                      and Deposit_Transferred__c=false limit 1000];
        system.debug('+++++++depositList++'+depositList);
        return depositList;
    }
    
    @Auraenabled
    public static String checkDepositAllocationTenantName(List<Id> listDepositId,String tenantValue) {
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
      
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit_Holder__r.LastName from Deposit_Allocation__c where Deposit__c IN:     listDepositId AND Role__c='Tenant' limit 1000]){
            system.debug('+++++++1111++'+depositAllocation.Deposit_Holder__r.LastName.trim().toLowercase());
            system.debug('+++++++2222++'+tenantValue.trim().toLowercase());
            if((depositAllocation.Deposit_Holder__r.LastName).trim().toLowercase().equals(tenantValue.trim().toLowercase())){
                depositAllocationList.add(depositAllocation);
            }
        }
        if(!depositAllocationList.isEmpty()){
           return 'Found'; 
        }
        else{
            return 'Not Found';
        }
    }
    
    @Auraenabled
    public static String validateTenantNameAndAccept(List<Id> listDepositId,String tenantValue) {
          User currentUser = [Select id,Contact.AccountId,ContactId,profile.Name from User where id=:Userinfo.getUserId()];
   
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        system.debug('+++++++listDepositId++'+listDepositId);
        String tenantTextValue = '%' + String.escapeSingleQuotes(tenantValue.trim()) + '%';
        system.debug('+++++++tenantTextValue++'+tenantTextValue);
        List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
        List<Id> listDepositIds = new List<Id>();
        List<Case> listCaseToUpdate = new List<Case>();
        for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit_Holder__r.LastName from Deposit_Allocation__c where Deposit__c IN:listDepositId AND Role__c='Tenant' limit 1000]){
            system.debug('+++++++1111++'+depositAllocation.Deposit_Holder__r.LastName.trim().toLowercase());
            system.debug('+++++++2222++'+tenantTextValue.toLowercase());
            if((depositAllocation.Deposit_Holder__r.LastName).trim().toLowercase().equals(tenantValue.trim().toLowercase())){
                depositAllocationList.add(depositAllocation);
            }
        }
        
        if(!depositAllocationList.isEmpty()){
            try{
                system.debug('listDepositId>>>>>'+listDepositId);
                List<Deposit__c> updateDeposit = new List<Deposit__c>(); 
                  set<Id> getProp = new set<Id>(); 
                List<Property__c> propList = new List<Property__c>();
                 List<Property_Allocation__c> propAllocations = new List<Property_Allocation__c>();
                for(Deposit__c deposit : [SELECT Id,Property__c,(Select id,Deposit__c,Deposit__r.Name,Deposit_Holder__r.Name,Deposit__r.Property_Address_WO_Country__c,Deposit__r.Deposit_Transferred_to_Account__r.Name,Deposit_Holder__r.Personemail,Deposit_Holder__r.PersonContactId,Role__C from Deposit_Allocations__r where Deposit__c IN:listDepositId and Role__C='Tenant'), Name,Deposit_Transferred__c,Customer__c,Customer__r.Personcontactid,Customer__r.Name,Property_Address_WO_Country__c,Customer__r.Email__c,Customer__r.Personemail,Deposit_Transferred_to_Account__c,Deposit_Transferred_to_Account__r.Email__c,Deposit_Transferred_to_Account__r.Personemail,Deposit_Transferred_to_Account__r.Name,Deposit_Transferred_to_Account__r.Personcontactid
                               from Deposit__c where Id IN :listDepositId //and Status__c=:Label.Deposits_held_by_SafeDeposits_Scotland 
                               and Deposit_Transferred__c=true
                                   Limit 1000]){
                                       getProp.add(deposit.Property__c);
                                       for(Deposit_Allocation__c Depall :deposit.Deposit_Allocations__r){
                                           DepositTransferAccpetedTenants(Depall.Deposit_Holder__r.Personemail,Depall.Deposit_Holder__r.Name,Depall.Deposit__r.Deposit_Transferred_to_Account__r.Name,Depall.Deposit__r.Property_Address_WO_Country__c, 
                                                                          Depall.Deposit__c,Depall.Deposit_Holder__r.PersonContactId,Depall.Deposit__r.Name);      
                                           emailWrapperList.add(DepositTransferAccpetedTenants(Depall.Deposit_Holder__r.Personemail,Depall.Deposit_Holder__r.Name,Depall.Deposit__r.Deposit_Transferred_to_Account__r.Name,Depall.Deposit__r.Property_Address_WO_Country__c, 
                                                                                               Depall.Deposit__c,Depall.Deposit_Holder__r.PersonContactId,Depall.Deposit__r.Name));   
                                       } 	
                                       
                   depositTransferAcceptEmailToPreviousLandlord(deposit.Customer__r.Personemail,deposit.Customer__r.Email__c,deposit.Customer__r.Name,deposit.Deposit_Transferred_to_Account__r.Name,deposit.Property_Address_WO_Country__c,deposit.Id,deposit.Customer__r.Personcontactid,deposit.Customer__c); 
               emailWrapperList.add(depositTransferAcceptEmailToPreviousLandlord(deposit.Customer__r.Personemail,deposit.Customer__r.Email__c,deposit.Customer__r.Name,deposit.Deposit_Transferred_to_Account__r.Name,deposit.Property_Address_WO_Country__c,deposit.Id,deposit.Customer__r.Personcontactid,deposit.Customer__c));
               
               depositTransferAcceptEmailToNewLandlord(deposit.Deposit_Transferred_to_Account__r.personemail,deposit.Deposit_Transferred_to_Account__r.Email__c,deposit.Deposit_Transferred_to_Account__r.Name,deposit.Customer__r.name,deposit.Property_Address_WO_Country__c,deposit.Id,deposit.Deposit_Transferred_to_Account__r.Personcontactid,deposit.Deposit_Transferred_to_Account__c,deposit.Name); 
               emailWrapperList.add(depositTransferAcceptEmailToNewLandlord(deposit.Deposit_Transferred_to_Account__r.personemail,deposit.Deposit_Transferred_to_Account__r.Email__c,deposit.Deposit_Transferred_to_Account__r.Name,deposit.Customer__r.name,deposit.Property_Address_WO_Country__c,deposit.Id,deposit.Deposit_Transferred_to_Account__r.Personcontactid,deposit.Deposit_Transferred_to_Account__c,deposit.Name));                        
               
                                       
                    deposit.Customer__c = deposit.Deposit_Transferred_to_Account__c;
                    deposit.Deposit_Transferred__c = false;
                    deposit.Deposit_Transferred_to_Account__c = null;
                    listDepositIds.add(deposit.id);
                    updateDeposit.add(deposit);
                  } 
                if(!getProp.isEmpty()){
                    if(currentUser.Profile.Name == 'Landlord'){
                         propList = [Select id,Property_Owner__c,(Select id,Relation_to_Property__c from Property_Allocations__r) from Property__c where id in: getProp];
                       
                        for(Property__c prop : propList){
                            prop.Property_Owner__c = currentUser.Contact.AccountId;
                            for(Property_Allocation__c propAll : prop.Property_Allocations__r){
                                 if(propAll.Relation_to_Property__c == 'Primary Landlord'){
                               		 propAll.Contact__c = currentUser.ContactId;
                                     propAllocations.add(propAll);
                           		 }
                            }
                           
                        }
                      
                    }
                   
                }
                system.debug(propList+' ** '+propAllocations);
                if(!propList.isEmpty()){
                    update propList;
                }
                 if(!propAllocations.isEmpty()){
                    update propAllocations;
                }
                if(emailWrapperList.size()>0){
                    EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
                }
                system.debug('updateDeposit>>>>>'+updateDeposit);
                If(!updateDeposit.isEmpty()){
                    update updateDeposit;
                    system.debug('updateDeposit>>>>>'+updateDeposit);
                    System.debug(':::QueryResult='+[Select id,Status from Case ]);
                    for(Case cs :  [Select id,Status from Case where Deposit_Account_Number__c IN:listDepositIds and (Status=:Label.Deposit_transfer_requested OR status=:Label.Deposit_transfer_cancelled OR status=:Label.Deposit_transfer_rejected) Order by LastModifiedDate DESC limit 1]){
                        cs.status = Label.Deposit_transfer_accepted;
                        listCaseToUpdate.add(cs);
                    }
                    if(!listCaseToUpdate.isEmpty()){
                        update listCaseToUpdate;
                    }
                }
                List<Case> caseList = [Select id,Type,Evidence_Target_Date__c from Case where Deposit_Account_Number__c IN :listDepositId and Status Not IN ('Closed','Self-Resolution') Order by LastModifiedDate DESC limit 1];
                system.debug('caseList>>>>>'+caseList);
                if(caseList == null || caseList.isEmpty()){
                    return 'Deposit updated and no case exist'; 
                }else{
                    return 'Deposit updated and case exist';
                }
            }
            catch(Exception e){
                return e.getMessage();
            }
        }
        else{
            return 'Not Found';
        }
    }
    
    @Auraenabled
    public static String checkDepositAllocationMultipleTenantName(List<Id> listDepositId,String values,String depositsList) {
        system.debug('+++++++listDepositId++'+listDepositId);
        system.debug('+++++++values++'+values);
        system.debug('+++++++depositsList++'+depositsList);
        List<Object> results = (List<Object>) JSON.deserializeUntyped(values);
        List<Object> depositResults = (List<Object>) JSON.deserializeUntyped(depositsList);
        Map<String, Object> m = new Map<String, Object>();
        Map<String, Object> mapDeposit = new Map<String, Object>();
        Map<String, String> mapDepositIdTenantValue = new Map<String, String>();
        Map<Id, String> mapDepositIdTenantFound = new Map<Id, String>();
        Map<Id, String> mapDepositIdTenantNotFound = new Map<Id, String>();
        List<Id> listDepositIdSelected = new List<Id>();
        List<Id> listDepositIds = new List<Id>();
        List<Case> listCaseToUpdate = new List<Case>();
        String DANNumber='';
        Boolean blank=false;
        String message ='Please complete the required value for ';
        
        if(results!=null && !results.isEmpty()){
          for (Object obj: results) {
            m = (Map<String, Object>)obj;
            mapDepositIdTenantValue.put((String)m.get('key'),(String)m.get('value'));
            System.debug('++++++++++++++'+mapDepositIdTenantValue);
            System.debug('++++++++++++++'+(Map<String, Object>)obj);
          }
        }
        
        system.debug('+++++++mapDepositIdTenantValue++'+mapDepositIdTenantValue);
        
        if(depositResults!=null && !depositResults.isEmpty()){
          for (Object obj: depositResults) {
            mapDeposit = (Map<String, Object>)obj;
            listDepositIdSelected.add((String)mapDeposit.get('key'));
            System.debug('++++++++++++++'+listDepositIdSelected);
            System.debug('++++++++++++++'+(Map<String, Object>)obj);
          }
        }
        
        
        if(mapDepositIdTenantValue.isEmpty()){
            return 'all blank';
        }
        else{
            List<Deposit_Allocation__c> depositAllocationList = new List<Deposit_Allocation__c>();
                for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit_Holder__r.LastName,Deposit__c,Deposit__r.Name from Deposit_Allocation__c where Deposit__c IN:listDepositIdSelected AND Role__c='Tenant']){
                System.debug('++++++4444444444444++++++++'+mapDepositIdTenantValue.get(depositAllocation.Deposit__c));
                if(mapDepositIdTenantValue.get(depositAllocation.Deposit__c)==null){
                  System.debug('++++++inside iggggggggggggg++++++++');
                  DANNumber = depositAllocation.Deposit__r.Name + ' , ' +DANNumber;
                  blank = true;
                  break;
                }
                else{
                    System.debug('++++++inside else++++++++');
                    System.debug('++++++555555++++++++'+mapDepositIdTenantValue.get(depositAllocation.Deposit__c).toLowercase());
                    System.debug('++++++6666666++++++++'+depositAllocation.Deposit_Holder__r.LastName.toLowercase());
                    if((mapDepositIdTenantValue.get(depositAllocation.Deposit__c)).trim().toLowercase().equals(depositAllocation.Deposit_Holder__r.LastName.trim().toLowercase()) ){
                        mapDepositIdTenantFound.put(depositAllocation.Deposit__c,depositAllocation.Deposit__r.Name);
                    }
                    else{
                        mapDepositIdTenantNotFound.put(depositAllocation.Deposit__c,depositAllocation.Deposit__r.Name);
                    }
                }
                
            }
            
            if(!mapDepositIdTenantFound.isEmpty()){
                for (String key : mapDepositIdTenantFound.keySet()){
                    if(!mapDepositIdTenantNotFound.isEmpty() && mapDepositIdTenantNotFound.containsKey(key)){
                        mapDepositIdTenantNotFound.remove(key);
                    }
                }
            }
            
            System.debug('++++++mapDepositIdTenantNotFound++++++++'+mapDepositIdTenantNotFound);  
            if(blank){
                DANNumber = DANNumber.removeEnd(' , ');
                message = message + DANNumber;
                return message;
            }
            else{
                if(mapDepositIdTenantNotFound.isEmpty()){
                    List<Deposit__c> updateDeposit = new List<Deposit__c>(); 
                    for(Deposit__c deposit : [SELECT Id,Name,Deposit_Transferred__c,Customer__c,Deposit_Transferred_to_Account__c 
                           from Deposit__c where Id IN :listDepositId //and Status__c=:Label.Deposits_held_by_SafeDeposits_Scotland 
                           and Deposit_Transferred__c=true
                             Limit 1000]){
                        deposit.Customer__c = deposit.Deposit_Transferred_to_Account__c;
                        deposit.Deposit_Transferred__c = false;
                        deposit.Deposit_Transferred_to_Account__c = null;
                        listDepositIds.add(deposit.id);
                        updateDeposit.add(deposit);
                    } 
                    system.debug('updateDeposit>>>>>'+updateDeposit);
                    if(!updateDeposit.isEmpty()){
                        update updateDeposit;
                        system.debug('updateDeposit>>>>>'+updateDeposit);
                        
                        for(Case cs :  [Select id,Status from Case where Deposit_Account_Number__c IN:listDepositIds and Status=:Label.Deposit_transfer_requested Order by LastModifiedDate DESC limit 1]){
                            cs.status = Label.Deposit_transfer_accepted;
                            listCaseToUpdate.add(cs);
                        }
                        if(!listCaseToUpdate.isEmpty()){
                            update listCaseToUpdate;
                        }
                    }
                    List<Case> caseList = [Select id,Type,Evidence_Target_Date__c from Case where Deposit_Account_Number__c IN :listDepositId and Status Not IN ('Closed','Self-Resolution') Order by LastModifiedDate DESC limit 1];
                    if(caseList == null || caseList.isEmpty()){
                        return 'Deposit updated and no case exist'; 
                    }else{
                        return 'Deposit updated and case exist';
                    }
                }
                else{
                    for(Id depositId : mapDepositIdTenantNotFound.keyset()){
                        DANNumber = mapDepositIdTenantNotFound.get(depositId) + ' , ' +DANNumber;
                    }
                    DANNumber = DANNumber.removeEnd(' , ');
                    return DANNumber;
                }        
            }
        }
    }
    
    @AuraEnabled
    public static List<depositListWrapper> getDepositInformationTransferred(){     
        List<depositListWrapper> lstdepositListWrapper = new List<depositListWrapper>(); 
      
        Id accountid = [Select id,Contact.AccountId from User where id=:Userinfo.getUserId()].Contact.AccountId;
    
        for(Deposit__c deposit : [SELECT Id,Customer_Name__c,Name,Property_Address__c,Protected_Amount__c,Customer__c,Customer__r.Name 
                        from Deposit__c where Deposit_Transferred_to_Account__c =:accountid and Status__c=:Label.Deposits_held_by_SafeDeposits_Scotland 
                       and Deposit_Transferred__c=true
                           Limit 1000]){
                               // by default checkbox should be false 
                               lstdepositListWrapper.add(new depositListWrapper(false,deposit));
                           } 
        // return the 'lstdepositListWrapper' list 
        return lstdepositListWrapper; 
    }
    
    
    //Handle Single Deposit
    @AuraEnabled
    public static Case processAcceptDeposit(List<String> depositId){
        try{
            system.debug('depositId>>>>>'+depositId);
            String formerEmailValue;
            String newEmailValue;
            String formerCustomerName;
            String newCustomerName;
            List<Deposit__c> updateDeposit = new List<Deposit__c>(); 
            for(Deposit__c deposit : [SELECT Id,Name,Deposit_Transferred__c,Customer__c,Deposit_Transferred_to_Account__c,Property_Address__c,
                            Deposit_Transferred_to_Account__r.Name,Customer_Name__c,Customer__r.PersonEmail,Customer__r.Email__c,
                            Deposit_Transferred_to_Account__r.PersonEmail,Deposit_Transferred_to_Account__r.Email__c,Scheme_Name__c
                           from Deposit__c where Id IN :depositId //and Status__c=:Label.Deposits_held_by_SafeDeposits_Scotland 
                           and Deposit_Transferred__c=true  Limit 1000]){
                // former customer information             
                if(String.IsnotBlank(deposit.Customer__r.Email__c)){
                    formerEmailValue =  deposit.Customer__r.Email__c;
                }
                else{
                    formerEmailValue =  deposit.Customer__r.PersonEmail;
                }
                
                //new customer information
                if(String.IsnotBlank(deposit.Deposit_Transferred_to_Account__r.Email__c)){
                    newEmailValue =  deposit.Deposit_Transferred_to_Account__r.Email__c;
                }
                else{
                    newEmailValue =  deposit.Deposit_Transferred_to_Account__r.PersonEmail;
                }
                formerCustomerName = deposit.Customer_Name__c;
                newCustomerName = deposit.Deposit_Transferred_to_Account__r.Name;
                deposit.Customer__c = deposit.Deposit_Transferred_to_Account__c;
                deposit.Deposit_Transferred__c = false;
                deposit.Deposit_Transferred_to_Account__c = null;
                updateDeposit.add(deposit);
            }
            
            //Send email to former customer
            EmailMailJetService.formerCustomerEmail(formerEmailValue,formerCustomerName,updateDeposit[0].Name,newCustomerName,updateDeposit[0].Property_Address__c);
            
            //Send email to new customer
            EmailMailJetService.newCustomerEmail(newEmailValue,newCustomerName,updateDeposit[0].Name,formerCustomerName,updateDeposit[0].Property_Address__c,updateDeposit[0].Scheme_Name__c);
            
            //Send email to tenants - Deposit transfer accepted
            String fromAddress,fromName,jsonData,SchemeSignatory;
            Integer mailJetTemplateId;
            String TDate = String.valueOf(System.today().format());
            
            HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
            
            List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
            List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('DepositTransferAccpetedTenants');             
            fromAddress = mailJetSettings[0].From_Address__c;
            fromName  = mailJetSettings[0].From_Name__c;
            mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
            SchemeSignatory = templateId[0].Scheme_Signatory__c;
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();    
            gen.writeFieldName('Messages'); 
            gen.writeStartArray();
            
            for(Deposit_Allocation__c depositAllocation : [SELECT Id,Deposit_Holder__r.Name,Deposit__r.Name,Deposit_Holder__r.PersonEmail,
                                                    Deposit__r.Property_Address__c,Deposit__r.Scheme_Name__c
                                                    from Deposit_Allocation__c where Deposit__c IN:depositId AND Role__c='Tenant' limit 1000]){
                                                     
                list<string> flaglist = new list<string>();
                if(flaglist.size() > 0 &&  !(flaglist.contains(depositAllocation.id))){
                    gen.writeString(','); 
                }
                system.debug('Line 50');
                
                gen.writeStartObject(); 
                gen.writeFieldName('From');
                gen.writeStartObject();
                gen.writeStringField('Email', fromAddress);
                gen.writeStringField('Name', fromName);
                gen.writeEndObject();
                
                gen.writeFieldName('To');
                gen.writeStartArray();
                gen.writeStartObject(); 
                gen.writeStringField('Email', depositAllocation.Deposit_Holder__r.PersonEmail); 
                gen.writeStringField('Name', depositAllocation.Deposit_Holder__r.Name);
                gen.writeEndObject();      
                gen.writeEndArray();
                
                gen.writeNumberField('TemplateID', mailJetTemplateId); 
                gen.writeBooleanField('TemplateLanguage', true);
                gen.writeStringField('Subject', 'Reference: '+depositAllocation.Deposit__r.Name+' Deposit transfer accepted'); 
                   
                gen.writeFieldName('Variables');       
                gen.writeStartObject();
                gen.writeStringField('Date', TDate);
                gen.writeStringField('name', depositAllocation.Deposit_Holder__r.Name);
                gen.writeStringField('DAN', depositAllocation.Deposit__r.Name);
                gen.writeStringField('Address', depositAllocation.Deposit__r.Property_Address__c);
                gen.writeStringField('customerName', newCustomerName);                                       
                gen.writeStringField('Scheme', depositAllocation.Deposit__r.Scheme_Name__c);
                gen.writeStringField('schemeSignature', SchemeSignatory);
                gen.writeEndObject(); 
                gen.writeEndObject(); 
                flaglist.add(depositAllocation.id);
            }
            
            gen.writeEndArray();
            gen.writeEndObject();
            jsonData =gen.getAsString();
            system.debug('jsonData-->>'+jsonData);
            req.setBody(jsonData);
            Http http = new Http();
            system.debug('req-->>'+req.getBody());
            //HTTPResponse res = http.send(req);
            //System.debug(res.getBody());
                                                    
            system.debug('updateDeposit>>>>>'+updateDeposit);
            If(!updateDeposit.isEmpty()){
                update updateDeposit;
                system.debug('updateDeposit>>>>>'+updateDeposit);
            }
            List<Case> caseList = [Select id,Type,Evidence_Target_Date__c,Deadline_Date__c from Case where Deposit_Account_Number__c = :depositId and Status Not IN ('Closed','Self-Resolution')];
            if(caseList == null || caseList.isEmpty()){
                return null; 
            }else{
                return caseList[0];
            }
        }
        catch(Exception e){
            system.debug('exception>>>>>'+e);
        }
        return null; 
    }
    
    @AuraEnabled
    public static Map<Id,Deposit__c> processMultipleAcceptDeposit(List<String> depositId){
        Map<Id,Deposit__c> mapDepositIdDeposit = new Map<Id,Deposit__c>();
        Map<Id,Id> mapCustomerIdDepositId = new Map<Id,Id>(); 
       
        for(Deposit__c deposit : [SELECT Id,Name,Property_Address__c,Deposit_Transferred__c,Customer__c,Deposit_Transferred_to_Account__c 
                       from Deposit__c where Id IN :depositId //and Status__c=:Label.Deposits_held_by_SafeDeposits_Scotland 
                       and Deposit_Transferred__c=true
                           Limit 1000]){
            if(!mapCustomerIdDepositId.isEmpty() && mapCustomerIdDepositId.containskey(deposit.Customer__c)
                        && mapCustomerIdDepositId.get(deposit.Customer__c)!=null 
                        ){
                mapCustomerIdDepositId.put(deposit.Customer__c,deposit.Id);  
            }
            else{
                mapCustomerIdDepositId.put(deposit.Customer__c,deposit.Id);
                mapDepositIdDeposit.put(deposit.Id,deposit);                
            }
        }system.debug('++++++++++mapCustomerIdDepositId+++++++++'+mapCustomerIdDepositId);
        system.debug('++++++++++mapDepositIdDeposit+++++++++'+mapDepositIdDeposit);
        return mapDepositIdDeposit; 
    }
    
    @AuraEnabled
    public static String processRejectDeposit(List<String> depositIds){ 
         List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        system.debug('depositId>>>>>'+depositIds);
        String emailValueUser;
        List<Id> listDepositIds = new List<Id>();
        List<Case> listCaseToUpdate = new List<Case>();
        List<Deposit__c> updateDeposit = new List<Deposit__c>(); 
        for(Deposit__c deposit : [SELECT Id,Name,Property_Address__c,Property_Address_WO_Country__c,Deposit_Transferred__c,Customer__c,Deposit_Transferred_to_Account__r.email__c,Deposit_Transferred_to_Account__r.personemail,Deposit_Transferred_to_Account__c,
                                Scheme_Name__c,Customer_Name__c,Customer__r.Email__c,Customer__r.PersonEmail,Deposit_Transferred_to_Account__r.Name
                       from Deposit__c where Id IN :depositIds //and Status__c=:Label.Deposits_held_by_SafeDeposits_Scotland 
                       and Deposit_Transferred__c=true
                           Limit 1000]){
            deposit.Deposit_Transferred__c = false;
            deposit.Deposit_Transferred_to_Account__c = null;
            listDepositIds.add(deposit.id);
            updateDeposit.add(deposit);
        }
        
        if(depositIds.size()==1){
            if(String.IsnotBlank(updateDeposit[0].Customer__r.Email__c)){
                emailValueUser =  updateDeposit[0].Customer__r.Email__c;
            }
            else{
                emailValueUser =  updateDeposit[0].Customer__r.PersonEmail;
            }
          //  EmailMailJetService.rejectTransfers(emailValueUser,updateDeposit[0].Customer_Name__c,updateDeposit[0].Name,
           //                             updateDeposit[0].Deposit_Transferred_to_Account__r.Name,updateDeposit[0].Property_Address_WO_Country__c,
           //                             updateDeposit[0].Scheme_Name__c);

         EmailMailJetService.rejectTransfers(updateDeposit[0].Deposit_Transferred_to_Account__r.email__c,updateDeposit[0].Deposit_Transferred_to_Account__r.personemail,updateDeposit[0].Deposit_Transferred_to_Account__r.name,updateDeposit[0].Name,
                                    updateDeposit[0].Property_Address_WO_Country__c,updateDeposit[0].Customer_Name__c,
                                    updateDeposit[0].Deposit_Transferred_to_Account__c,updateDeposit[0].Id);
         emailWrapperList.add(EmailMailJetService.rejectTransfers(updateDeposit[0].Deposit_Transferred_to_Account__r.email__c,updateDeposit[0].Deposit_Transferred_to_Account__r.personemail,updateDeposit[0].Deposit_Transferred_to_Account__r.name,updateDeposit[0].Name,
                                    updateDeposit[0].Property_Address_WO_Country__c,updateDeposit[0].Customer_Name__c,
                                    updateDeposit[0].Deposit_Transferred_to_Account__c,updateDeposit[0].Id));
            
         EmailMailJetService.rejectTransfersmailtosender(emailValueUser,updateDeposit[0].Customer_Name__c,updateDeposit[0].Name,
                                    updateDeposit[0].Property_Address_WO_Country__c,updateDeposit[0].Deposit_Transferred_to_Account__r.Name,updateDeposit[0].Scheme_Name__c,
                                    updateDeposit[0].customer__c,updateDeposit[0].Id);
        
        emailWrapperList.add(EmailMailJetService.rejectTransfersmailtosender(emailValueUser,updateDeposit[0].Customer_Name__c,updateDeposit[0].Name,
                                    updateDeposit[0].Property_Address_WO_Country__c,updateDeposit[0].Deposit_Transferred_to_Account__r.Name,updateDeposit[0].Scheme_Name__c,
                                    updateDeposit[0].customer__c,updateDeposit[0].Id)); 
          
        }
                                                    
        system.debug('updateDeposit>>>>>'+updateDeposit);
        If(!updateDeposit.isEmpty()){
            update updateDeposit;
            system.debug('updateDeposit>>>>>'+updateDeposit);
            
            for(Case cs :  [Select id,Status from Case where Deposit_Account_Number__c IN:listDepositIds and Status=:Label.Deposit_transfer_requested]){
                cs.status = Label.Deposit_transfer_rejected;
                listCaseToUpdate.add(cs);
            }
            if(!listCaseToUpdate.isEmpty()){
                update listCaseToUpdate;
            }
             if(emailWrapperList.size()>0){
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
            }
        }
        return 'Deposit Successfully Rejected';        
    }
    
    /* wrapper class */  
    public class depositListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Deposit__c objDeposit{get;set;}
        public depositListWrapper(boolean isChecked, Deposit__c objDeposit){
            this.isChecked = isChecked;
            this.objDeposit = objDeposit;
        }
    }
    
    @Auraenabled
    public static String getAgentLandlordEmailDetails(String emailValue,List<Id> listDepositId) {
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        user logindetails = [Select id,Email,ContactId,User.Name,AccountId,Contact.Account.Email__c,Profile.Name,Contact.Account.Name from User where Id=: UserInfo.getUserId() and Isactive=true limit 1];
        //String emailValueUser = '%' + String.escapeSingleQuotes(emailValue.trim()) + '%';
        String emailValueUser;
        List<User> listUser = new List<User>();
        listUser = [Select id,Email,ContactId,User.Name,AccountId,Contact.Account.Email__c,Profile.Name,Contact.Account.Name from User where Email =:emailValue and (Profile.Name=:Label.Agent_Profile_Name OR Profile.Name=:Label.Landlord_Profile_Name) and Isactive=true limit 1];
        system.debug('+++++++++++++listUser+++++'+listUser);
        
        List<Deposit__c> listDeposit = new List<Deposit__c>();
        List<Case> listCase = new List<Case>();
        List<Deposit__c> listDepositToupdate = new List<Deposit__c>();
        listDeposit = [SELECT Id,Name,Deposit_Transferred_to_Account__c,Property_Address__c,customer__r.Name,Protected_Amount__c,Customer__c,Customer_Name__c,Property_Address_WO_Country__c,Scheme_Name__c,Deposit_Transferred__c from Deposit__c where Id IN:listDepositId];
        system.debug('+++++++++++++listUser+++++'+listUser);
        system.debug('+++++++++++++listDeposit+++++'+listDeposit);
        
       Id caseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Support_Case).getRecordTypeId();
      //  List<Messaging.SingleEmailMessage> email = new List<Messaging.SingleEmailMessage>();
        
        if(listUser.isEmpty()){
            for(Deposit__C  Depo:listDeposit){
            TransferdepositemailtoNocustomer(emailValue,Depo.customer__r.Name,Depo.Property_Address_WO_Country__c,Depo.Id);
            emailWrapperList.add(TransferdepositemailtoNocustomer(emailValue,Depo.customer__r.Name,Depo.Property_Address_WO_Country__c,Depo.Id));
            /*Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            string htmlBody = date.today().format()+'<br/><br/>';
            htmlBody+= 'Dear '+emailValue+'<br/><br/>';
            htmlBody+= 'This is a test email. Please provide any links that you may need to test to this template.<br/><br/>';
            htmlBody+= 'Kind regards,';
            htmlBody+= '[Scheme salutation]';
            message.setReplyTo('no-reply@company.com');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false);
            message.setHtmlBody(htmlBody);
            message.setSubject('Test email template');
            message.setToAddresses(new String[] { emailValue});
            email.add(message); 
            */
            for(Deposit__c deposit : listDeposit){
                deposit.Deposit_Transferred__c = true;
                deposit.New_Customer_Email__c = emailValue;
                listDepositToupdate.add(deposit);
                
                Case newCase = new Case(RecordTypeId = caseRecordType,Deposit_Account_Number__c = deposit.Id,OwnerId =  UserInfo.getUserId() ,Origin= Label.Web,Status=Label.Deposit_transfer_requested,Scheme__c=Label.EW_Custodial,Subject = Label.Deposit_transfer_requested+' for '+emailValue,Description=Label.Deposit_transfer_requested+' for '+emailValue);
                listCase.add(newCase);              
            }  

         }   
        }
        if(!listUser.isEmpty()){
            if(!listDeposit.iSEmpty() && listDepositId.size()==1){ 
                if(listUser[0].Profile.Name==Label.Agent_Profile_Name){
                    if(String.IsnotBlank(listUser[0].Contact.Account.Email__c)){
                        emailValueUser =  listUser[0].Contact.Account.Email__c;
                    }
                    else{
                        emailValueUser =  emailValue;
                    }
                }
                if(listUser[0].Profile.Name==Label.Landlord_Profile_Name){
                    if(String.IsnotBlank(listUser[0].Contact.Account.Email__c)){
                        emailValueUser =  listUser[0].Contact.Account.Email__c;
                    }
                    else{
                        emailValueUser =  emailValue;
                    }
                }
                EmailMailJetService.singleDepositTransferToCustomer(emailValueUser,listUser[0].Contact.Account.Name,listDeposit[0].Name,
                                                    listDeposit[0].Property_Address_WO_Country__c,listDeposit[0].Scheme_Name__c,listDeposit[0].Customer_Name__c,listDeposit[0].Customer__c,listDeposit[0].Id);
                emailWrapperList.add(EmailMailJetService.singleDepositTransferToCustomer(emailValueUser,listUser[0].Contact.Account.Name,listDeposit[0].Name,
                                                    listDeposit[0].Property_Address_WO_Country__c,listDeposit[0].Scheme_Name__c,listDeposit[0].Customer_Name__c,listDeposit[0].Customer__c,listDeposit[0].Id));
            }
            else{                
                if(listUser[0].Profile.Name==Label.Agent_Profile_Name){
                    if(String.IsnotBlank(listUser[0].Contact.Account.Email__c)){
                        emailValueUser =  listUser[0].Contact.Account.Email__c;
                    }
                    else{
                        emailValueUser =  emailValue;
                    }
                }
                if(listUser[0].Profile.Name==Label.Landlord_Profile_Name){
                    if(String.IsnotBlank(listUser[0].Contact.Account.Email__c)){
                        emailValueUser =  listUser[0].Contact.Account.Email__c;
                    }
                    else{
                        emailValueUser =  emailValue;
                    }
                }
                EmailMailJetService.multipleDepositTransferToCustomer(emailValueUser,listUser[0].Contact.Account.Name,
                                                    listDeposit[0].Scheme_Name__c,listDeposit[0].Customer_Name__c,listDepositId.size(),listDeposit[0].Customer__c,listDeposit[0].Id);
                emailWrapperList.add(EmailMailJetService.multipleDepositTransferToCustomer(emailValueUser,listUser[0].Contact.Account.Name,
                                                    listDeposit[0].Scheme_Name__c,listDeposit[0].Customer_Name__c,listDepositId.size(),listDeposit[0].Customer__c,listDeposit[0].Id));
         
            }
            EmailMailJetService.DepositTransfertoAGLLMailToTransferee(logindetails.Email,logindetails.Name,listUser[0].Contact.Account.Name,listDeposit[0].Property_Address_WO_Country__c,logindetails.ContactId,listDeposit[0].Id);
             emailWrapperList.add(EmailMailJetService.DepositTransfertoAGLLMailToTransferee(logindetails.Email,logindetails.Name,listUser[0].Contact.Account.Name,listDeposit[0].Property_Address_WO_Country__c,logindetails.ContactId,listDeposit[0].Id));
        /*    Messaging.SingleEmailMessage messageTransferringAgentLandlord = new Messaging.SingleEmailMessage();
            string htmlBody1 = date.today().format()+'<br/><br/>';
            htmlBody1+= 'Dear '+UserInfo.getFirstName()+'  '+UserInfo.getLastName() +'<br/><br/>';
            htmlBody1+= 'This is a test email. Please provide any links that you may need to test to this template.<br/><br/>';
            htmlBody1+= 'Kind regards,';
            htmlBody1+= '[Scheme salutation]';
            messageTransferringAgentLandlord.setReplyTo('no-reply@company.com');
            messageTransferringAgentLandlord.setUseSignature(false); 
            messageTransferringAgentLandlord.setBccSender(false); 
            messageTransferringAgentLandlord.setSaveAsActivity(false);
            messageTransferringAgentLandlord.setHtmlBody(htmlBody1);
            messageTransferringAgentLandlord.setSubject('Test email template');
            messageTransferringAgentLandlord.setToAddresses(new String[] { UserInfo.getUserEmail()});
            email.add(messageTransferringAgentLandlord);*/
            
            for(Deposit__c deposit : listDeposit){
                deposit.Deposit_Transferred__c = true;
                deposit.Deposit_Transferred_to_Account__c = listUser[0].AccountId;
                listDepositToupdate.add(deposit);
                
                Case newCase = new Case(RecordTypeId = caseRecordType,AccountId=listUser[0].AccountId,Deposit_Account_Number__c = deposit.Id,OwnerId =  UserInfo.getUserId() ,Origin= Label.Web,Status=Label.Deposit_transfer_requested,Scheme__c=Label.EW_Custodial,Subject = Label.Deposit_transfer_requested+' for '+listUser[0].Contact.Account.Name,Description=Label.Deposit_transfer_requested+' for '+listUser[0].Contact.Account.Name);
                listCase.add(newCase);
            }
        }
                    if(emailWrapperList.size()>0){
            EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
            }

       // system.debug('+++++++++++++email+++++'+email);
        if(!listDepositToupdate.IsEmpty()){
            update listDepositToupdate;
        }
        
        if(!listCase.IsEmpty()){
            insert listCase;
        }
        
        //List<Contact> listContact = [Select id,Email, Account.PersonEmail from Contact 
                                     //where Email=:emailValue or Account.PersonEmail=:emailValue limit 1];
        return 'transferred';
    }
    
    @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }
    
    
    // When Deposit transfer Accepted Mail to previous Landlord 
    public static EI_SDS_MailJetUtilityCls.EmailWrapper depositTransferAcceptEmailToPreviousLandlord(string personemail,string useremail,string username,String newusername,String propaddress, 
                                                                                                  string depositid,string contactid,string accountid) 
    { 
         system.debug('667');  
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit transfer complete';
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('FormerCustomerMail');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){   
        CustomerId =  contactid;   
        }
        else{
        CustomerId = accountid;    
        }
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, CustomerId));
        variableMap.put('Date', tdstr);
        variableMap.put('name', username);
        variableMap.put('Address', propaddress);
        variableMap.put('newCustomer', newusername);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'FormerCustomerMail', emailsubject);    
        return EmailWrapper;
        
    }

        // When Deposit transfer Accepted Mail to New Landlord 
    public static EI_SDS_MailJetUtilityCls.EmailWrapper depositTransferAcceptEmailToNewLandlord(string personemail,string useremail,string username,String oldcustomername,String propaddress, 
                                                                                          string depositid,string contactid,string accountid,String DAN) 
    { 
         system.debug('713');  
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit transfer complete';
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('NewCustomerMail');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        if(contactid !=null){   
        CustomerId =  contactid;   
        }
        else{
        CustomerId = accountid;    
        }
        
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();
        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, CustomerId));
        variableMap.put('Date', tdstr);
        variableMap.put('name', username);
        variableMap.put('DAN', DAN);
        variableMap.put('Address', propaddress);
        variableMap.put('formerCustomer', oldcustomername);
      //  variableMap.put('offer_details', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'NewCustomerMail', emailsubject);    
        return EmailWrapper;
        
    }
    
    // When Deposit transfer Accepted Mail to all tenants 
    public static EI_SDS_MailJetUtilityCls.EmailWrapper DepositTransferAccpetedTenants(string useremail,string username,String customername,String propaddress, 
                                                                                          string depositid,string contactid,String DAN) 
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
        String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Updated deposit details - '+propaddress +' ';
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('DepositTransferAccpetedTenants');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        toName =username;
        toAddress = useremail;
        CustomerId = contactid;    
    
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, toName, depositid, CustomerId));
        variableMap.put('Date', tdstr);
        variableMap.put('name', username);
        variableMap.put('DAN', DAN);
        variableMap.put('Address', propaddress);
        variableMap.put('customerName', customername);
      //  variableMap.put('offer_details', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'DepositTransferAccpetedTenants', emailsubject);    
        return EmailWrapper;
        
    }
    
         // When Deposit transfer email to No customer  
    public static EI_SDS_MailJetUtilityCls.EmailWrapper TransferdepositemailtoNocustomer(string useremail,String oldcustomername,String propaddress,string depositid) 
                                                                                           
    { 
        string message = 'mail send';
        
        HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
        
        String fromAddress;
        String toName;
        string toAddress;
       // String CustomerId;
        String fromName;
        String SchemeSignatory;
        Integer mailJetTemplateId;
        string emailsubject = 'Deposit transfer pending - please create your Safedeposits account ';
        List<API_Service__mdt> mailJetSettings = EI_CustomMetadataUtility.metaDataList('mailJet');
        List<API_Service__mdt> templateId = EI_CustomMetadataUtility.metaDataList('TransferdepositemailtoNocustomer');          
        fromAddress = mailJetSettings[0].From_Address__c;
        fromName  = mailJetSettings[0].From_Name__c;
        mailJetTemplateId  = Integer.valueof(templateId[0].Template_Id__c);
        SchemeSignatory = templateId[0].Scheme_Signatory__c;
        //toName =username;
        toAddress = useremail;
        string signuplink = '<a href="https://uat-thedisputeservice.cs87.force.com/Sds/s">link to create an account</a>';
        Date todaydate = System.today(); 
        string tdstr = todaydate.day()+'/'+todaydate.month()+'/'+todaydate.year();

        /* Newly added code for adding recipients, variables, template name, Subject START */
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        Map<String, String> variableMap = new Map<String, String>();
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(toAddress, '', depositid, ''));
        variableMap.put('Date', tdstr);
        variableMap.put('sign_up_link', signuplink);
        variableMap.put('prop_add', propaddress);
        variableMap.put('sending_customer', oldcustomername);
      //  variableMap.put('offer_details', string.valueof(offeramount));
        // variableMap.put('Address', propaddress);
        // variableMap.put('Tenant_changeover_details', changeoverdetails);*/
        // variableMap.put('scheme_signatory', schemeSignatory);
        EI_SDS_MailJetUtilityCls.EmailWrapper EmailWrapper = new  EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                                                        'TransferdepositemailtoNocustomer', emailsubject);    
        return EmailWrapper;
        
    }

    
}