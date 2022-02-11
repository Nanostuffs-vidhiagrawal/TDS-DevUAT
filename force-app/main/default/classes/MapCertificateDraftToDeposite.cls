public without sharing class MapCertificateDraftToDeposite {
	 @auraEnabled
    public static string getDraftId(){
       List<User> userList = [SELECT Id, Contact.AccountId FROM USER WHERE Id =: UserInfo.getUserId()];
        Deposit__c dep = new Deposit__c();
        if(!userList.isEmpty()){
            dep = [Select id from Deposit__c where Customer__c =: userList[0].Contact.AccountId limit 1];
        }
        return dep.Id;
        
      //  return parseDraft(draft.Draft_JSON__c);
        
    }
/*    @auraEnabled
    public static Id parse(String draftRecordId){
        
        List<Certificate_Draft__c> draftList;
        
        if(String.isBlank(draftRecordId)){
            Id userId = UserInfo.getUserId();
        	draftList = [SELECT Id, Draft_JSON__c FROM Certificate_Draft__c WHERE user__c =: userId ORDER BY CreatedDate LIMIT 1];
        }else{
            draftList = [SELECT Id, Draft_JSON__c FROM Certificate_Draft__c WHERE Id =: draftRecordId LIMIT 1];
        }
        
        
        if(draftList.isEmpty()){
            throw new AuraHandledException('Draft data not found!');
        }

		Certificate_Draft__c draft = draftList[0];
        draft.User__c = UserInfo.getUserId();
        update draft;
        
        
        return parseDraft(draft.Draft_JSON__c);
        
    }
    
   private static Id parseDraft(String jsonDraft){
        try{
            // to be implemented - waiting fo input for data mapping
            CertificateBuilderDraftWrapper wrapper = (CertificateBuilderDraftWrapper) JSON.deserialize(jsonDraft, CertificateBuilderDraftWrapper.class);
            CertificateBuilderDraftWrapper.cls_Tenants[] tenants = wrapper.Tenants;
            CertificateBuilderDraftWrapper.cls_Landlords[] landlords = wrapper.Landlords;
            
            Account[] tenants_landlordsList = new List<Account>();
            // create property
            Property__c prop = new Property__c();
            prop.Street__c = wrapper.TenantAddress.street;
            prop.City__c = wrapper.TenantAddress.city;
            prop.County__c = wrapper.TenantAddress.county;
            prop.Country__c = wrapper.TenantAddress.country;
            prop.Postal_Code__c = wrapper.TenantAddress.postalcode;
            
            // insert deposite
            Deposit__c dep = new Deposit__c();
            
            if(String.isBlank(wrapper.AmountOfDipositProtected) == false){
                // dep.Amount_of_Deposit_Protected_by_TDS__c = Decimal.valueOf(wrapper.AmountOfDipositProtected);
                dep.Protected_Amount__c = Decimal.valueOf(wrapper.AmountOfDipositProtected);
            }
            if(String.isBlank(wrapper.AmountOfDipositAgreementProtected) == false){
                // dep.Amount_of_Deposit_Protected_by_TDS__c = Decimal.valueOf(wrapper.AmountOfDipositProtected);
                dep.Deposit_Amount__c = Decimal.valueOf(wrapper.AmountOfDipositAgreementProtected);  // @todo 
            }
            if(String.isBlank(wrapper.TenancyAgreementStartDate) == false)
                dep.Start_Date__c = parseDate(wrapper.TenancyAgreementStartDate); 
            if(String.isBlank(wrapper.TenancyAgreementExpected) == false)
                // dep.Expected_End_Date__c = parseDate(wrapper.TenancyAgreementExpected); 
            if(String.isBlank(wrapper.DateAgent_landlordReceived) == false)
                dep.Date_Agent_Landlord_Received_Deposit__c = parseDate(wrapper.DateAgent_landlordReceived); 
            if(String.isBlank(wrapper.DateSSDReceivedTheDeposit) == false)
                dep.Date_Deposit_Received__c = parseDate(wrapper.DateSSDReceivedTheDeposit);
            
            dep.Scheme__c = [select id from Scheme__c where Name = 'SDS'][0].Id; // @todo
            dep.Status__c = 'Registered (not paid)';
            
            // Insert tenants and Landlords as person account
            Id personAccountRectypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            
            List<Account> listTenantAccount = new List<Account>();
            for(CertificateBuilderDraftWrapper.cls_Tenants tenantWrapper : tenants){
                Account tenant = new Account();
                tenant.recordTypeId = personAccountRectypeId;
                
                tenant.LastName = tenantWrapper.TenantName;
                tenant.personemail = tenantWrapper.Tenantemail;
                tenant.phone = tenantWrapper.TenantPhone;  
                tenant.OwnerId = '0058E000006wQw2QAE'; // @todo   
                listTenantAccount.add(tenant);
            }
            
            Insert listTenantAccount;
            
            
            List<Account> listLandLordAccount = new List<Account>();  
            for(CertificateBuilderDraftWrapper.cls_Landlords landLordWrapper : landlords){
                Account landLord = new Account();
                landLord.recordTypeId = personAccountRectypeId;
                
                landLord.LastName = landLordWrapper.LandlordName;
                landLord.personemail = landLordWrapper.LandlordEmail;
                landLord.phone = landLordWrapper.LandlordPhone;  
                landLord.OwnerId = '0058E000006wQw2QAE';     // @todo
                listLandLordAccount.add(landlord);
            }
            
            Insert listLandLordAccount;
            
            
            prop.Property_Owner__c = listLandLordAccount[0].Id;// @todo
            insert prop;
            
            dep.Customer__c = getCurrentUserAccount();// @todo
            dep.Property__c = prop.Id;
            insert dep;
            
            listLandLordAccount = [select Id, PersonContactId, LastName, recordTypeId, personemail, phone, OwnerId from account where id In : listLandLordAccount]; // querying to get personcontactId
            
            List<Property_Allocation__c> propAllocList = new List<Property_Allocation__c>();
            for(Account landLord : listLandLordAccount){
                Property_Allocation__c propAlloc = new Property_Allocation__c();
                propAlloc.Contact__c = landLord.PersonContactId;
                propAlloc.Property__c = prop.id;
                
                propAllocList.add(propAlloc);
            }
            
            
            List<Deposit_Allocation__c> depAllocList = new List<Deposit_Allocation__c>();
            for(Account tenant : listTenantAccount){
                Deposit_Allocation__c depAlloc = new Deposit_Allocation__c();
                depAlloc.Contact__c = tenant.PersonContactId;
                depAlloc.deposit_holder__c = tenant.Id; //@todo
                depAlloc.Deposit__c = dep.Id;
                depAlloc.Role__c = 'Tenant';
                
                depAllocList.add(depAlloc);
            }
            
            insert depAllocList;
            insert propAllocList;
            
            return dep.Id;
        }catch(Exception e){
            System.debug(e.getlinenumber() +':'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    // expecting dd-mm-yyyy
    private static Date parseDate(String dateStr){
        //String[] datecomps = dateStr.split('-');
        String[] datecomps = dateStr.split('/');
        
        if(dateComps.size() != 3)
            throw new AuraHandledException('Wrong Date Format!');
            
        return Date.newInstance(Integer.valueOf(datecomps[2]), Integer.valueOf(datecomps[1]), Integer.valueOf(datecomps[0]));
    }
    
    private static Id getCurrentUserAccount(){
        List<User> userList = [SELECT Id, Contact.AccountId FROM USER WHERE Id =: UserInfo.getUserId()];
        
        if(userList.isEmpty())
            throw new AuraHandledException('User Account Not Found!');
        
        return userList[0].Contact.AccountId;
    }*/
}