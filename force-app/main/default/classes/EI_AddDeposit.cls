public without sharing class EI_AddDeposit {
    @AuraEnabled
    public static string insertProperties(String street,String city,String postcode,String county,String country) {
        
        string branchId = ApexPages.currentPage().getParameters().get('branchId');
        system.debug('branchId '+branchId);
        user u = [select id, accountid, name
                  from user
                  where id = :UserInfo.getUserId()];
        Property__c newProperty = new Property__c(Property_status__c = 'Active',Property_Owner__c=u.accountid,Street__c=street,City__c=city,Postal_Code__c=postcode,County__c=county,Country__c=country);
        try{
            insert newProperty;
            List<Property_Created__c> prop = [Select id,Name from Property_Created__c limit 1];
            
            prop[0].Name= newProperty.id;
            update prop;
            //updateCustomLabel(newProperty.Id);       
            return 'Successfully Created ID='+newProperty.Id+'=';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
            
        }
        
    }
    
    @AuraEnabled
    public static List<WrapperClass> getProperties(String searchField, String branchId) {
        List<WrapperClass> listwrppr = new List<WrapperClass>();
        user u = [select id, accountid, name
                  from user
                  where id = :UserInfo.getUserId()];

        string searchkey = '%' + searchField + '%';
        list<Property__c> prt = new list<Property__c>();
        if(branchId != null){
            
                    prt = [select id,Property_status__c, Name, Street__c, City__c, Town__c, No_of_bedrooms__c, Is_Furnished__c, No_of_living_rooms__c, County__c, Country__c, Property_Owner__c, Postal_Code__c, (select id, Name
                                                                                                                                                                                                     from Deposits__r
                                                                                                                                                                                                     where Active__c = true), (select id, Relation_to_Property__c, contact__c, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.phone
                                                                                                                                                                                                                               from Property_Allocations__r
                                                                                                                                                                                                                               where Relation_to_Property__c = 'Primary Landlord')
                                 from Property__c
                                 where (Branch__c =: branchId) and Property_status__c = 'Active' AND (name like :searchkey or Street__c like :searchkey or City__c like :searchkey or Postal_Code__c like :searchkey or Country__c like :searchkey or County__c like :searchkey or Town__c like :searchkey)];
        }
        else{
        prt = [select id,Property_status__c, Name, Street__c, City__c, Town__c, No_of_bedrooms__c, Is_Furnished__c, No_of_living_rooms__c, County__c, Country__c, Property_Owner__c, Postal_Code__c, (select id, Name
                                                                                                                                                                                                     from Deposits__r
                                                                                                                                                                                                     where Active__c = true), (select id, Relation_to_Property__c, contact__c, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.phone
                                                                                                                                                                                                                               from Property_Allocations__r
                                                                                                                                                                                                                               where Relation_to_Property__c = 'Primary Landlord')
                                 from Property__c
                                 where (Property_Owner__c = :u.AccountId OR CreatedById =: u.Id) and Property_status__c = 'Active' AND (name like :searchkey or Street__c like :searchkey or City__c like :searchkey or Postal_Code__c like :searchkey or Country__c like :searchkey or County__c like :searchkey or Town__c like :searchkey)];
       
        }
        if (prt.size() > 0){
            for (Property__c p : prt){
                string primeLandlord = '';
                boolean livedeposit = false;
                if (p.Deposits__r.size() > 0){
                    livedeposit = true;
                }
                if (p.Property_Allocations__r.size() > 0){
                    primeLandlord = p.Property_Allocations__r[0].contact__c;
                }

                string property = p.Street__c +  ' ' + p.City__c + ' ' + p.County__c + ' ' + p.Postal_Code__c;
                listwrppr.add(new WrapperClass(livedeposit, property, p.id, p, primeLandlord));
            }
            return listwrppr;
        } else{
            return null;
        }
    }

    @AuraEnabled
    public static List<Property__c> addNewProperty(Property__c property, user usertype, list<contact> primaryLandord, list<contact> jointlandlord) {
        try{
			 string branchId = ApexPages.currentPage().getParameters().get('branchId');
 			system.debug('branchId '+branchId);
 
            list<Property_Allocation__c> prAllocation = new list<Property_Allocation__c>();
            user u = [select id, accountid, name
                      from user
                      where id = :UserInfo.getUserId()];
            property.Property_status__c = 'Active';
            property.Property_Owner__c = u.AccountId;
            insert property;

            if (usertype.User_Type__c == 'Agent' && primaryLandord.size() > 0){
                prAllocation.add(new Property_Allocation__c(Contact__c = primaryLandord[0].id, Property__c = property.id, Relation_to_Property__c = 'Primary Landlord'));
            } else{
                prAllocation.add(new Property_Allocation__c(Contact__c = usertype.contactid, Property__c = property.id, Relation_to_Property__c = 'Primary Landlord'));
            }
            if (jointlandlord.size() > 0){
                for (contact con : jointlandlord){
                    prAllocation.add(new Property_Allocation__c(Contact__c = con.id, Property__c = property.id, Relation_to_Property__c = 'Joint Landlord'));
                }

            }

            if (prAllocation.size() > 0){
                insert prAllocation;
            }

            list<Property__c> pp = [select id, Name, Street__c, City__c, Town__c, No_of_bedrooms__c, Is_Furnished__c, No_of_living_rooms__c, County__c, Country__c, Property_Owner__c, Postal_Code__c
                                    from Property__c
                                    where id = :property.id];
            return pp;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<contact> getlandlord(String searchField) {
		String searchkey = '%' + searchField + '%';
        user u = [select id, accountid
                  from user
                  where id = :UserInfo.getUserId()];
        List<contact> conrec = [select id, Title, firstname, lastname, email, phone
                                from contact
                                where account.Parent_person_account__c = :u.accountid and (name like :searchkey or email LIKE :searchkey)];

        return conrec;
    }

    /*@AuraEnabled
    public static String savelandlord(String firstname, String lastname, String email, string salutation, string phone, string companyName, string companyPhone, string companyEmail, boolean isOrguser, string street, string city, string postcode, string country, string county){

        user u = [select id, accountid, account.ownerid
                  from user
                  where id = :UserInfo.getUserId()];
        Account Acc;
        contact con;
        Id AccountRecordTypeId;
        try{
            if (isOrguser){
                AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                Acc = new Account(name = companyName, Phone = companyPhone, RecordTypeId = AccountRecordTypeId, Email__c = email, Parent_person_account__c = u.accountId, OwnerId = u.account.ownerid, BillingStreet = street, BillingCity = city, BillingPostalCode = postcode, BillingCountry = country, BillingState = county);

                insert acc;
                con = new contact(AccountId = Acc.id, Salutation = salutation, FirstName = firstname, lastname = lastname, email = email, Phone = phone, MailingStreet = street, MailingCity = city, MailingPostalCode = postcode, MailingCountry = country, MailingState = county);
                insert con;
            } else{
                AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId();
                Acc = new Account();
                Acc.FirstName = firstname;
                Acc.LastName = lastname;
                Acc.Salutation = salutation;
                acc.OwnerId = u.account.ownerid;
                Acc.PersonEmail = email;
                Acc.Email__c = email;
                Acc.PersonHomePhone = phone;
                Acc.Phone = phone;
                Acc.RecordTypeId = AccountRecordTypeId;
                Acc.Parent_person_account__c = u.accountId;
                acc.BillingStreet = street;
                acc.BillingCity = city;
                acc.BillingPostalCode = postcode;
                acc.BillingCountry = country;
                acc.BillingState = county;
                insert acc;

            }


            return 'record inserted';
        } catch (exception e){
            return string.valueOf(e.getMessage());
        }
    }*/
    
    @AuraEnabled
    public static String savelandlord(String landlordRegNumber,Date startDate,Decimal rentAmount,String DepositId,string salutation,String firstname, String lastname, String email, string phone, string companyName, string companyPhone, string companyEmail, boolean isOrguser,string street, string city, string postcode, string country, string county){
        
        user u = [select id, accountid, account.ownerid
                  from user
                  where id = :UserInfo.getUserId()];
        Account Acc;
        contact con;
        string tenEmail;
        Id AccountRecordTypeId;
        try{
            if (isOrguser){
                AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                Acc = new Account(name = companyName, Phone = companyPhone, RecordTypeId = AccountRecordTypeId, Email__c = email, Parent_person_account__c = u.accountId, OwnerId = u.account.ownerid,BillingStreet = street,BillingCity = city,BillingPostalCode = postcode,BillingCountry = country,BillingState = county);
                
                insert acc;
                con = new contact(Account_Status__c ='Active',AccountId = Acc.id, Salutation = salutation,LandLord_Registration_Number__c=landlordRegNumber, FirstName = firstname, lastname = lastname, email = email, Phone = phone, MailingStreet = street,MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,MailingState = county);
                insert con;
            } else{
                AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId();
                Acc = new Account();
                Acc.FirstName = firstname;
                Acc.LastName = lastname;
                Acc.Salutation = salutation;
                acc.OwnerId = u.account.ownerid;
                Acc.PersonEmail = email;
                Acc.LandLord_Registration_Number__pc=landlordRegNumber;
                Acc.Email__c = email;
                Acc.PersonHomePhone = phone;
                Acc.Phone = phone;
                Acc.RecordTypeId = AccountRecordTypeId;
                Acc.Parent_person_account__c = u.accountId;
                acc.BillingStreet = street;
                acc.BillingCity = city;
                acc.BillingPostalCode = postcode;
                acc.BillingCountry = country;
                acc.BillingState = county;
                acc.Account_Status__pc ='Active';
                insert acc;
                con = [Select id from Contact where AccountId =: acc.id];
            }
            
            
            Deposit__c newdeposit;
            Property__c updateOwner;
            if(DepositId !=  null){
                
                List<Property_Created__c> prop = [Select id,Name from Property_Created__c limit 1];
                if(prop.size()>0){   
                    String pId = prop[0].Name;
                    updateOwner= [Select id,Property_Owner__c from Property__c where id=:pId]; 
                    updateOwner.Property_Owner__c=Acc.id;
                    update updateOwner;
                    
                    Property_Allocation__C propallocation = new Property_Allocation__C(Property__c = updateOwner.id,Contact__c = con.id,Relation_to_Property__c = 'Primary Landlord',Landlord_Registration_Number__c=landlordRegNumber);
                    insert propallocation;
                }
                
                
                List<Deposit__c> oldDeposit = new List<Deposit__c>();
                for(Deposit__c deposit : [Select id,Status__c,Number_of_Tenants__c,Branch__c,Rent_Amount__c,Deposit_Amount__c,Protected_Amount__c,Date_Deposit_Received__c,Start_Date__c,User_reference_for_the_deposit__c,Property__c,Customer__c,Scheme__c from Deposit__c where id =: DepositId]){
                    newdeposit = new Deposit__c(Status__c='Deposits held by scheme', Date_Deposit_Received__c = System.today(),Property__c = updateOwner.id,Number_of_Tenants__c = deposit.Number_of_Tenants__c,Branch__c=deposit.Branch__c, Rent_Amount__c = rentAmount, Deposit_Amount__c = deposit.Deposit_Amount__c, Protected_Amount__c = deposit.Protected_Amount__c, Start_Date__c = startDate, User_reference_for_the_deposit__c = deposit.User_reference_for_the_deposit__c, Customer__c = deposit.Customer__c, Scheme__c = deposit.Scheme__c);
                    deposit.Status__c = 'Deposit Closed';
                    oldDeposit.add(deposit);
                }
                update oldDeposit;
                insert newdeposit;
                List<Deposit_Allocation__c> newdepositAllocationList = new List<Deposit_Allocation__c>();
                Deposit_Allocation__c newdepositAllocation;
                for(Deposit_Allocation__c depositAllocation : [Select id,Deposit_Holder__c,Contact__c,Is_Lead__c,Role__c,Contact__r.email from Deposit_Allocation__c where Deposit__c =: DepositId]){
                    if(depositAllocation.Role__c == 'Landlord'){
                        newdepositAllocation = new Deposit_Allocation__c(Deposit_Holder__c = depositAllocation.Deposit_Holder__c, Contact__c = con.id, Is_Lead__c = depositAllocation.Is_Lead__c, Role__c = depositAllocation.Role__c, Deposit__c = newdeposit.id);
                        
                    }
                    else{
                        tenEmail = depositAllocation.Contact__r.email;
                        newdepositAllocation = new Deposit_Allocation__c(Deposit_Holder__c = depositAllocation.Deposit_Holder__c, Contact__c = depositAllocation.Contact__c, Is_Lead__c = depositAllocation.Is_Lead__c, Role__c = depositAllocation.Role__c, Deposit__c = newdeposit.id);
                        
                    }
                    newdepositAllocationList.add(newdepositAllocation);
                }
                insert newdepositAllocationList;
                
                
                
                
            }
            if(DepositId !=  null && newdeposit != null){
                Messaging.SingleEmailMessage singlemail =new Messaging.SingleEmailMessage(); 
                
                singlemail.toAddresses = new String[] { tenEmail  };
                    singlemail.setTargetObjectId(UserInfo.getUserId());
                singlemail.saveAsActivity=false;
                singlemail.plainTextBody ='We have moved your deposit from old property to new property';
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singlemail});
                return 'record inserted='+newdeposit.Id;
            }
            else{
                return 'record inserted';
            }
            
        } catch (exception e){
            return string.valueOf(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String transferDeposit(Date startDate,Decimal rentAmount,String DepositId, String PropertyId) {
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>(); 
        List<Deposit_Allocation__c> newdepositAllocationList = new List<Deposit_Allocation__c>();
        List<Deposit__c> oldDeposit = new List<Deposit__c>();
        List<Installment__c> installmentList = new List<Installment__c>();
        List<String> tenEmail = new List<String>();
        Map<String, String> emailMember = new Map<String,String>();
        System.debug('Line 287 propertytransfer');
        try{
            
            Deposit__c newdeposit;
            
            if(DepositId !=  null) {
				
                //   List<Deposit__c> oldDeposit = new List<Deposit__c>();
                List<Deposit__c> oldDepoList = [Select Id, Status__c, Number_of_Tenants__c, Name, Branch__c, Rent_Amount__c, Deposit_Amount__c, 
                                                Protected_Amount__c, Date_Deposit_Received__c, Start_Date__c, User_reference_for_the_deposit__c, Property__c, 
                                                Property_Address_WO_Country__c, Customer__c, Customer__r.name, Customer__r.email__c, Customer__r.personemail, 
                                                Scheme__c from Deposit__c where id =: DepositId];
                List<Deposit__c> newDepoListToInsert = new List<Deposit__c>();
                Map<Id, Deposit__c> oldDepoMap = new Map<Id, Deposit__c>();
                for(Deposit__c depo : oldDepoList) {
                    oldDepoMap.put(depo.Id, depo);
                }
                
                for(Deposit__c deposit : oldDepoMap.values()) 
                {
                    newdeposit = new Deposit__c(Status__c='Deposits held by scheme', Date_Deposit_Received__c = System.today(), Property__c = PropertyId, 
                                                Number_of_Tenants__c = deposit.Number_of_Tenants__c,Branch__c=deposit.Branch__c, 
                                                Rent_Amount__c = deposit.Rent_Amount__c, 
                                                Deposit_Amount__c = rentAmount,
                                                Protected_Amount__c = deposit.Protected_Amount__c, 
                                                Start_Date__c = startDate, User_reference_for_the_deposit__c = deposit.User_reference_for_the_deposit__c, 
                                                Customer__c = deposit.Customer__c, Scheme__c = deposit.Scheme__c, Old_Property_Deposit__c = deposit.Id);
                    newDepoListToInsert.add(newdeposit);
                }
                if(newDepoListToInsert.size()>0) {
                    insert newDepoListToInsert;
                }
                
                for(Deposit__c deposit : newDepoListToInsert) {
                    Deposit__c oldDepo = new Deposit__c(Id = deposit.Old_Property_Deposit__c, Status__c = 'Deposit Closed', New_Property_Deposit__c = deposit.Id);
                    oldDepoMap.get(deposit.Old_Property_Deposit__c).New_Property_Deposit__c = deposit.Id;
                    oldDeposit.add(oldDepo);
                }
                if(oldDeposit.size()>0) {
                    update oldDeposit;
                }
                 
                Deposit_Allocation__c newdepositAllocation;
                for(Deposit_Allocation__c depositAllocation : [Select Id, Deposit__r.Customer__r.PersonEmail,Deposit_Holder__c,Deposit_Holder__r.Name, 
                                                               Deposit__r.Customer__r.Email__c,Deposit__r.Customer__r.Name,Deposit__r.Customer__r.IsPersonAccount, 
                                                               Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Personcontactid,Contact__c,Is_Lead__c,Role__c, 
                                                               Contact__r.email from Deposit_Allocation__c where Deposit__c =: DepositId]) 
                {
                    tenEmail.add(depositAllocation.Deposit_Holder__r.Name);
                    emailMember.put(depositAllocation.Deposit_Holder__r.Name,depositAllocation.Deposit_Holder__r.PersonEmail);
                    if(depositAllocation.Deposit__r.Customer__r.IsPersonAccount) {
                        tenEmail.add(depositAllocation.Deposit__r.Customer__r.Name);
                        emailMember.put(depositAllocation.Deposit__r.Customer__r.Name,depositAllocation.Deposit__r.Customer__r.PersonEmail);
                        
                    } else {
                        tenEmail.add(depositAllocation.Deposit__r.Customer__r.Name);
                        emailMember.put(depositAllocation.Deposit__r.Customer__r.Name,depositAllocation.Deposit__r.Customer__r.Email__c); 
                        
                    }
                    newdepositAllocation = new Deposit_Allocation__c(Deposit_Holder__c = depositAllocation.Deposit_Holder__c, Contact__c = depositAllocation.Contact__c, 
                                                                     Is_Lead__c = depositAllocation.Is_Lead__c, Role__c = depositAllocation.Role__c, Deposit__c = newdeposit.id);             
                    newdepositAllocationList.add(newdepositAllocation);
                }
                insert newdepositAllocationList; 
                
                /*for(Installment__c installment : [Select id,X30_Days_Completion_Date__c,X30_Days_Reminder__c,X60_Days_Reminder__c,Amount__c,Bank_Account_Holder_Name__c,Bank_Account_Number__c,BIC__c,Bank_Name__c,Bank_Sort_Code__c,BLK_Number__c,Case__c,Category__c,Paid_By_Cheque__c,Cheque_Sent__c,
                                                  Contact__c,Created_At__c,Credit_Note_Reference__c,Custom_Account_Number__c,Custom_DAN__c,Deposit__c,Due_Date__c,First_Communication_Sent__c,Installment_Type__c,International_Payment__c,IsTenantChangeover__c,Is_Topup__c,Payment_Method__c,Payment_Reference__c,
                                                  Payment_type__c,Payment_type_status__c,Pay_Today__c,Reason_For_Flag__c,Reason_For_Flag_Specified__c,Second_Communication_Sent__c,Status__c,Swift_Code__c,User_Type_Custom__c from Installment__c where Deposit__c =: DepositId]) 
                {
                    Installment__c install = new Installment__c();
                    install.Deposit__c = newdeposit.Id;
                    install.X30_Days_Completion_Date__c = installment.X30_Days_Completion_Date__c;
                    install.X30_Days_Reminder__c= installment.X30_Days_Reminder__c;
                    install.X60_Days_Reminder__c = installment.X60_Days_Reminder__c;
                    install.Amount__c = installment.Amount__c;
                    install.Bank_Account_Holder_Name__c = installment.Bank_Account_Holder_Name__c;
                    install.Bank_Account_Number__c = installment.Bank_Account_Number__c;
                    install.Bank_Name__c = installment.Bank_Name__c;
                    install.BIC__c = installment.BIC__c;
                    install.BLK_Number__c = installment.BLK_Number__c;
                    install.Case__c = installment.Case__c;
                    install.Category__c = installment.Category__c;
                    install.Cheque_Sent__c = installment.Cheque_Sent__c;
                    install.Contact__c = installment.Contact__c;
                    install.Created_At__c = installment.Created_At__c;
                    install.Credit_Note_Reference__c = installment.Credit_Note_Reference__c;
                    install.Custom_Account_Number__c = installment.Custom_Account_Number__c;
                    install.Custom_DAN__c = installment.Custom_DAN__c;
                    install.Due_Date__c = installment.Due_Date__c;
                    install.Installment_Type__c = installment.Installment_Type__c;
                    install.International_Payment__c = installment.International_Payment__c;
                    install.Is_Topup__c = installment.Is_Topup__c;
                    install.IsTenantChangeover__c = installment.IsTenantChangeover__c;
                    install.Paid_By_Cheque__c = installment.Paid_By_Cheque__c;
                    install.Pay_Today__c = installment.Pay_Today__c;
                    install.Payment_Method__c = installment.Payment_Method__c;
                    install.Payment_type_status__c = installment.Payment_type_status__c;
                    install.Reason_For_Flag__c = installment.Reason_For_Flag__c;
                    install.Payment_Reference__c = installment.Payment_Reference__c;
                    install.Reason_For_Flag_Specified__c = installment.Reason_For_Flag_Specified__c;
                    install.Status__c = installment.Status__c;
                    install.Swift_Code__c = installment.Swift_Code__c;
                    install.User_Type_Custom__c = installment.User_Type_Custom__c;
                    installmentList.add(install);
                }
                if(!installmentList.isEmpty()) {
                    insert installmentList;
                }*/
                
                for(Deposit__c deposit : oldDepoMap.values()) {
                    String strResult1 = EI_UtilityClassForPayments.getPropertyTransferDeposit(null, null, null, deposit.Protected_Amount__c, 
                                                                                              System.today(), deposit.Id, null, null, true, 
                                                                                              'Paid', 'Payable', 'Final Payment', null, null, null);
                    String strResult2 = EI_UtilityClassForPayments.getPropertyTransferDeposit(null, null, null, deposit.Protected_Amount__c, 
                                                                                              System.today(), deposit.New_Property_Deposit__c, null, 
                                                                                              null, false, 'Collected', 'Receivable', 'Final Payment', 
                                                                                              System.today(), null, null);
                }
                
            }
            
           list<deposit__c> depnew = [Select id,Status__c,Number_of_Tenants__c,Name,Branch__c,Rent_Amount__c,Deposit_Amount__c,Protected_Amount__c,Date_Deposit_Received__c,Start_Date__c,User_reference_for_the_deposit__c,Property__c,Property_Address_WO_Country__c,Customer__c,Customer__r.name,Customer__r.email__c,Customer__r.personemail,Scheme__c from Deposit__c where id =: newdeposit.Id limit 1];
           List<Deposit_Allocation__c> newdepositAllocationList11 = [Select id,Deposit__r.Customer__r.PersonEmail,Deposit_Holder__c,Deposit_Holder__r.Name,Deposit__r.Customer__r.Email__c,Deposit__r.Customer__r.Name,Deposit__r.Customer__r.IsPersonAccount,Deposit_Holder__r.PersonEmail,Deposit_Holder__r.Personcontactid,Contact__c,Is_Lead__c,Role__c,Contact__r.email from Deposit_Allocation__c where Deposit__c =: DepositId and role__c='Tenant'];
            system.debug('line--> 322' + depnew);    
            if(DepositId !=  null && newdeposit != null && newdepositAllocationList11.size()>0) {
                
                for(Deposit_Allocation__c depall :newdepositAllocationList11) {
                    system.debug('line--> 326' + depall.Deposit_Holder__r.personemail);
                    MailJetService.mailfortransferdeposittenant(depall.Deposit_Holder__r.personemail,depall.Deposit_Holder__r.Name,oldDeposit[0].Name,depnew[0].Name,oldDeposit[0].Property_Address_WO_Country__c,depnew[0].Property_Address_WO_Country__c,DepositId,depall.Contact__c);
                    emailWrapperList.add(MailJetService.mailfortransferdeposittenant(depall.Deposit_Holder__r.personemail,depall.Deposit_Holder__r.Name,oldDeposit[0].Name,depnew[0].Name,oldDeposit[0].Property_Address_WO_Country__c,depnew[0].Property_Address_WO_Country__c,DepositId,depall.Contact__c)); 
                }
                
                MailJetService.mailfortransferdepositagentlandlord(oldDeposit[0].customer__r.Email__c,oldDeposit[0].customer__r.personemail,oldDeposit[0].customer__r.Name,oldDeposit[0].Name,depnew[0].Name,oldDeposit[0].Property_Address_WO_Country__c,depnew[0].Property_Address_WO_Country__c,DepositId,oldDeposit[0].customer__c);
                emailWrapperList.add(MailJetService.mailfortransferdepositagentlandlord(oldDeposit[0].customer__r.Email__c,oldDeposit[0].customer__r.personemail,oldDeposit[0].customer__r.Name,oldDeposit[0].Name,depnew[0].Name,oldDeposit[0].Property_Address_WO_Country__c,depnew[0].Property_Address_WO_Country__c,DepositId,oldDeposit[0].customer__c)); 
                if(emailWrapperList.size()>0) {
                    EI_SDS_MailJetUtilityCls.sendEmail(JSON.serialize(emailWrapperList));
                }
                /* MailJetService.mailForTranferDeposit(emailMember,tenEmail); */
                system.debug('line--> 334');
                return newdeposit.Id;
            }
            else {
                system.debug('line--> 338');
                return 'record inserted';
            }
             
        } catch (exception e) {
            system.debug('line--> 343');
            return string.valueOf(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static user getuserDetails() {
        user u = [select id, accountid, contactid, User_Type__c,Profile.Name
                  from user
                  where id = :UserInfo.getUserId()];
        return u;
    }

    @AuraEnabled
    public static List<Property_Allocation__c> getLandlordforSummery(list<Property__c> property) {
        list<Property_Allocation__c> landlord = [select id, Relation_to_Property__c, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.phone
                                                 from Property_Allocation__c
                                                 where Property__c = :property[0].id];
        if (landlord.size() > 0){
            return landlord;
        } else{
            return null;
        }
    }

    @AuraEnabled
    public static String finalSave(String branchId, String leadTenantObj, string tenantRec, Property__c property, String registerNumber, String registerstatus, string primeLandlordId, decimal rentAmount, decimal depositAmount, decimal amountToProtect, Date depositRecievedDate, Date tenancyStartDate, Integer noOfTenants, String depositReference){
        //Id branchId= apexpages.currentpage().getparameters().get('branchId');
        
        system.debug('branchId '+ branchId);
        List<Account> tenantList = new list<Account>();
        Account LeadTenant;
        Property_Allocation__c propallocation = new Property_Allocation__c();
        list<Deposit_Allocation__c> depositAllocationlist = new list<Deposit_Allocation__c>();
        user userrec = [select id, contactid, accountid, User_Type__c, contact.LandLord_Registration_Number__c, account.ownerid
                        from user
                        where id = :UserInfo.getUserId()];
        FinalWrapper LeadTenantRec = (FinalWrapper)System.JSON.deserialize(leadTenantObj, FinalWrapper.class);
        list<FinalWrapper> tenantRecList = (List<FinalWrapper>)System.JSON.deserialize(tenantRec, list<FinalWrapper>.class);
        ID depositRecordTypeId = Schema.SObjectType.Deposit__c.getRecordTypeInfosByDeveloperName().get('SDS_Deposit').getRecordTypeId();
        
        Deposit__c depositrec = new Deposit__c(recordtypeId = depositRecordTypeId,Branch__c=branchId,Number_of_Tenants__c = noOfTenants, Rent_Amount__c = rentAmount, Deposit_Amount__c = depositAmount, Protected_Amount__c = amountToProtect, Date_Deposit_Received__c = depositRecievedDate, Start_Date__c = tenancyStartDate, User_reference_for_the_deposit__c = depositReference, Property__c = property.id, Customer__c = userrec.accountid, Scheme__c = System.Label.SDSschemeId);
        
        ID AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId();
        list<Property_Allocation__c> landlordrec = [select id, Contact__c, Property__c
                                                    from Property_Allocation__c
                                                    where Property__c = :property.id and Relation_to_Property__c = 'Primary Landlord'];
        List<string> firstnamelist = new List<string>();
        List<string> lastnamelist = new List<string>();
        List<string> emailList = new List<string>();
        Set<ID> userIds = new Set<ID>();
        Set<String> emailIds = new Set<String>();
        Map<String,Id> mapOfemailVsAccId = new Map<String,Id>();
        Map<String,String> mapOfemailVsAccName = new Map<String,String>();
        list<id> tenantid = new list<id>();
        for (FinalWrapper t : tenantRecList){
            if(t.IsOrg){
                lastnamelist.add(t.companyName);
                emailList.add(t.email);
            }else{
                firstnamelist.add(t.firstName);
                lastnamelist.add(t.SurName);
                emailList.add(t.email);
            }
            if(String.isnotEmpty(t.email)) 
            {   emailIds.add(t.email.trim() );}
        }
        if(!emailIds.isEmpty() || LeadTenantRec.email != null){
            for(User tentUser :  [SELECT email, Profile.Name ,Contact.AccountId,Contact.Name
                                  FROM User
                                  WHERE (email IN : emailIds OR email = : LeadTenantRec.email) and (Profile.Name = 'Tenant' ) and ContactId != null]){
                                      if(!mapOfemailVsAccId.containsKey(tentUser.email)) {     
                                          mapOfemailVsAccId.put(tentUser.email.trim(),tentUser.Contact.AccountId);
                                          mapOfemailVsAccName.put(tentUser.email.trim(),tentUser.Contact.Name);
                                      }
                                  }
            
        }
        system.debug('<<<<<<<tenantRecList'+JSON.serialize(tenantRecList));
        List<User> existUserList = [Select id,Contact.AccountId from User where isActive = false and firstName in: firstnamelist and lastname in: lastnamelist and email in: emailList];
        if(existUserList.size() == 0){
            for (FinalWrapper t : tenantRecList){
                //
                //
                String tenantName = t.firstName +' '+t.SurName;
                if(mapOfemailVsAccId.containsKey(t.email.trim()) && (mapOfemailVsAccName.get(t.email.trim()) == tenantName || mapOfemailVsAccName.get(t.email.trim()) == t.companyName)){
                    tenantid.add(mapOfemailVsAccId.get(t.email.trim())); 
                }else{
                    if(t.IsOrg){
                        Account acc = new account();
                        acc.LastName = t.companyName;
                        //acc.FirstName = t.companyName;
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
            }
        }
        String tenantName = LeadTenantRec.firstName +' '+LeadTenantRec.SurName;
        if(mapOfemailVsAccId.containsKey(LeadTenantRec.email.trim()) && (mapOfemailVsAccName.get(LeadTenantRec.email.trim()) == tenantName || mapOfemailVsAccName.get(LeadTenantRec.email.trim()) == LeadTenantRec.companyName)){
            tenantid.add(mapOfemailVsAccId.get(LeadTenantRec.email.trim()));
        }else{
            LeadTenant = new Account();
            if (LeadTenantRec.IsOrg){
                LeadTenant.LastName = LeadTenantRec.companyName;
                LeadTenant.Company_Name__c = LeadTenantRec.companyName;
                LeadTenant.Email__c = LeadTenantRec.email;
                LeadTenant.Phone_Code__pc = LeadTenantRec.phoneCode;
                LeadTenant.Phone = LeadTenantRec.phone;
                LeadTenant.PersonEmail = LeadTenantRec.email;
                LeadTenant.OwnerId = userrec.account.ownerid;
                LeadTenant.RecordTypeId = AccountRecordTypeId;
            } else{
                LeadTenant.Salutation = LeadTenantRec.title;
                LeadTenant.FirstName = LeadTenantRec.firstName;
                LeadTenant.LastName = LeadTenantRec.SurName;
                LeadTenant.Email__c = LeadTenantRec.email;
                LeadTenant.PersonEmail = LeadTenantRec.email;
                LeadTenant.Phone_Code__pc = LeadTenantRec.phoneCode;
                LeadTenant.Phone = LeadTenantRec.phone;
                LeadTenant.RecordTypeId = AccountRecordTypeId;
                LeadTenant.OwnerId = userrec.account.ownerid;
            }
        }
        List<User> leadTenList = new List<User>();
        if(LeadTenant != NULL){
            leadTenList = [Select id,Contact.AccountId from User where isActive = false and ((firstName =: LeadTenant.FirstName and lastname =:LeadTenant.LastName and email =:LeadTenant.Email__c) OR (firstName = NULL and lastname =:LeadTenant.LastName and email =:LeadTenant.Email__c))];  
        }
        
        if (landlordrec.size() > 0){
            propallocation.id = landlordrec[0].id;
            propallocation.Landlord_Registrataion_Status__c = registerstatus;
            propallocation.Landlord_Registration_Number__c = registerNumber;
        } else{
            if (primeLandlordId != ''){
                propallocation.Contact__c = primeLandlordId;
            } else{
                propallocation.Contact__c = userrec.contactid;
            }
            propallocation.Property__c = property.id;
            propallocation.Relation_to_Property__c = 'Primary Landlord';
            propallocation.Landlord_Registrataion_Status__c = registerstatus;
            propallocation.Landlord_Registration_Number__c = registerNumber;
        }
        
        try{
            
            //    list<id> tenantid = new list<id>();
            if(existUserList.size() ==0){
                if (tenantList.size() > 0){
                    Database.SaveResult[] recid = Database.insert(tenantList);
                    for (Database.SaveResult sr : recid){
                        if (sr.isSuccess()){
                            tenantid.add(sr.getId());
                        }
                    }
                }
                
            }
            else{
                for(User u : existUserList ){
                    //u.IsActive = true;
                    userIds.add(u.Id);
                    tenantid.add(u.Contact.AccountId);
                }
                //update existUserList;
            }
            if(leadTenList.size() ==0){
                System.debug('## '+LeadTenant);
                if (LeadTenant != NULL ){
                    insert LeadTenant;
                    tenantid.add(LeadTenant.id);
                    
                }
            }
            else{
                for(User u : leadTenList ){
                    //u.IsActive = true;
                    userIds.add(u.Id);
                    tenantid.add(u.Contact.AccountId);
                }
                //update leadTenList;
            }
            if(userIds.size()>0){
                //	EI_AddDeposit.updateUser(userIds); 
            }
            upsert propallocation;
            insert depositrec;
            insert new Installment__c(RecordTypeId = Schema.SObjectType.Installment__c.getRecordTypeInfosByName().get('SDS Installment').getRecordTypeId(),Status__c = 'Pending', Deposit__c = depositrec.Id, Installment_Type__c = 'Receivable', Amount__c = depositrec.Protected_Amount__c);
            list<account> acclist = [select id, PersonContactId
                                     from Account
                                     where id in :tenantid];
            
            for (account Acc : acclist){
                if( mapOfemailVsAccId.get(LeadTenantRec.email) == Acc.id){
                    depositAllocationlist.add(new Deposit_Allocation__c(Deposit_Holder__c = acc.id, Contact__c = acc.PersonContactId, Is_Lead__c = false, Role__c = 'Tenant', Deposit__c = depositrec.id));
                } else{
                    /*   if(LeadTenant != NULL){
if (LeadTenant.id == Acc.id){
depositAllocationlist.add(new Deposit_Allocation__c(Deposit_Holder__c = acc.id, Contact__c = acc.PersonContactId, Is_Lead__c = true, Role__c = 'Tenant', Deposit__c = depositrec.id));
}
}
else{*/
                    depositAllocationlist.add(new Deposit_Allocation__c(Deposit_Holder__c = acc.id, Contact__c = acc.PersonContactId, Is_Lead__c = false, Role__c = 'Tenant', Deposit__c = depositrec.id));
                    // }
                }
                
            }
            
            
            string updatedvalue;
            
            if (userrec.contact.LandLord_Registration_Number__c != null){
                List<String> landRegNumber = userrec.contact.LandLord_Registration_Number__c.split(',');
                
                if (landRegNumber.size() > 0){
                    if (!landRegNumber.contains(registerNumber)){
                        if (registerNumber != ''){
                            updatedvalue = userrec.contact.LandLord_Registration_Number__c + ',' + registerNumber;
                        }
                        
                    }
                    
                } else{
                    if (registerNumber != ''){
                        updatedvalue = registerNumber + ',';
                    }
                    
                }
                
            } else{
                if (registerNumber != ''){
                    updatedvalue = registerNumber + ',';
                }
            }
            if (updatedvalue != null){
                contact con = new contact(id = userrec.ContactId, LandLord_Registration_Number__c = updatedvalue);
                update con;
            }
            system.debug('>>>>>>>>>depositAllocationlist'+JSON.serializePretty(depositAllocationlist));
            if (depositAllocationlist.size() > 0){
                insert depositAllocationlist;
            }
            
            //String  Depositnumber = [Select name From Deposit__c where id =: depositrec.Id ][0].Name;
            //   if(!mapOfemailVsAccId.isEmpty())
            //  notifyExistingTenant(mapOfemailVsAccId,mapOfemailVsAccName,Depositnumber);
            return depositrec.Id;
        } catch (exception e){
            return 'Error in process';
        }
    }
    
    @future(callout=true)
    public static void notifyExistingTenant(Map<String,Id> mapOfemailVsAccId,Map<String,String> mapOfemailVsAccName) {
       // String SDSEmail = 'ashish.singh1@espire.com';
        for(String email : mapOfemailVsAccId.keyset()){
                String jsonData = EI_EvidenceGatheringMails.getJBforNotifytentant(email,mapOfemailVsAccName.get(email));
                HttpRequest req = EI_mailJetServiceUtility.mailJetAuthentication();
                req.setBody(jsonData);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                System.debug(res.getBody());
        }
    }

    /* 
     * For EI_tenantDetails Component
     */
    @future
	public static void updateUser(Set<ID> userIds){
		
		List<User> userList = [Select id,IsActive from User where id =: userIds and isActive = false];
		for(User u: userList){
			u.isActive = true;
		}
		update userList;
	}
    
    // For EI_tenantDetails Component
    @AuraEnabled
    public static String checkDuplicateEmail(String email, String phone, String firstname, String surname, String type){
        try{
            if (type == 'onlyemail'){
              /*  Integer emailCount = [Select count()
                                      from Contact
                                      where email = :email and email != null];*/
                
                String message = null;
                Set<String> tenant_Email_In_Deposit = new Set<String>();
                List<User> userList = [SELECT email, Profile.Name 
                                       FROM User
                                       WHERE email = :email.trim() and IsActive = true
                                      ];
                
                if(userList.size() > 0){
                    for(User u:userList){
                        if(  u.Profile.Name == 'Branch User' || u.Profile.Name == 'Agent' 
                           || u.Profile.Name == 'Landlord' || u.Profile.Name == 'Head Office User')
                        {
                            message = 'Duplicate email';
                            return ('Duplicate email');
                           // break;
                        }else{
                            message=null;
                            return null;
                        }
                    }
                }
                
            /*    if(firstname != '' && surname != ''){
                    String fullNameForSearch = firstname.trim() + ' ' + surname.trim();
                    List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
                                                          RETURNING Contact(ID WHERE email=:email.trim()) ];
                    
                    if(searchNameList[0].size() > 0){
                        return 'Duplicate Name';
                    }
                }
             */
                
            } else if (type == 'onlyphone') {
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
    
    // For EI_addMoreTenants Component
    @AuraEnabled
    public static String checkDuplicateEmails(String email, String phone, String type, String firstname, String surname, String depositId){
        System.debug(depositId);
        try{
            if (type == 'onlyemail'){
                String message = null;
                Set<String> tenant_Email_In_Deposit = new Set<String>();
                List<User> userList = [SELECT email, Profile.Name 
                                       FROM User
                                       WHERE profile.UserLicense.Name ='Customer Community Login' 
                                       AND email = :email.trim()
                                      ];
                
                if(userList.size() > 0){
                    for(User u:userList){
                        if(u.Profile.Name == 'Branch User' || u.Profile.Name == 'Agent' 
                           || u.Profile.Name == 'Landlord' || u.Profile.Name == 'Head Office User')
                        {
                            message = 'Duplicate email';
                            break;
                        }else if(u.Profile.Name == 'Tenant' || u.Profile.Name == 'ZD_Tenant'){
                            tenant_Email_In_Deposit.add(u.Email);
                        }else{
                            message=null;
                        }
                    }
                }
                if(tenant_Email_In_Deposit.size()>0){
                    List<Deposit_Allocation__c> daList = [SELECT id, Deposit_Holder__r.PersonEmail 
                                                          FROM Deposit_Allocation__c 
                                                          WHERE Deposit__c =: depositId 
                                                          AND Deposit_Holder__r.PersonEmail IN:tenant_Email_In_Deposit];
                    System.debug('daList'+daList);
                    if (daList.size() > 0){
                        return ('Duplicate email');
                    } 
                }
                
                List<Deposit_Allocation__c> d2List = [SELECT Id, Deposit_Holder__r.PersonEmail 
                                                      FROM Deposit_Allocation__c 
                                                      WHERE Deposit__c =: depositId 
                                                      AND Deposit_Holder__r.PersonEmail=:email.trim()];
                if(d2List.size()>0){
                    return ('Duplicate email');
                }
                
             /*   if(firstname != '' && surname != ''){
                    String fullNameForSearch = firstname.trim() + ' ' + surname.trim();
                    List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
                                                          RETURNING Contact(ID WHERE email=:email.trim()) ];
                    
                    if(searchNameList[0].size() > 0){
                        return ('Duplicate Name');
                    }
                }
			*/
                
                return message;
                
            } else if (type == 'onlyphone'){
                System.debug(depositId);
                System.debug(phone);
                
                List<Deposit_Allocation__c> daList = [SELECT id, Deposit_Holder__r.PersonEmail 
                                                      FROM Deposit_Allocation__c 
                                                      WHERE Deposit__c =: depositId 
                                                      AND Deposit_Holder__r.Phone=:phone 
                                                      And Deposit_Holder__r.Phone!=null];
                System.debug('daList'+daList);
                if (daList.size() > 0){
                    return ('Duplicate Phone');
                }
            }
            return 'No Duplicate';
            
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }


    /*@What: Add the additional tenant to the deposit.
     *@Called From : EI_addMoreTenants Aura Component.
     */
     @AuraEnabled
    public static Account addAdditionalTenant(Account acc, string tenanttitle, string tenantPhoneCode, Id depositId, Boolean IsOrg){
        // System.debug('acc' + acc);
        System.debug('IsOrg' + IsOrg);
        if (!IsOrg){
            Id AccountRecordTypeId;
            user u = [select id, accountid, account.ownerid
                      from user
                      where id = :UserInfo.getUserId()];
            try{
                if(acc.PersonEmail != null){
                    List<User> userList = [SELECT Id, email, AccountId, ContactId 
                                           FROM User
                                           WHERE email =:acc.PersonEmail];
                    if(userList.size()>0){
                        Deposit_Allocation__c da = new Deposit_Allocation__c();
                        da.Deposit_Holder__c = userList[0].AccountId;
                        da.Deposit__c = depositId;
                        da.role__c = 'Tenant';
                        da.Contact__c = userList[0].ContactId;
                        insert da;
                        return [SELECT id from Account where Id =:userList[0].AccountId];
                    }
                }
                
                AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId();
                // System.debug('AccountRecordTypeId ' + AccountRecordTypeId);
                Account newPersonAccount = new Account();
                newPersonAccount.FirstName = acc.FirstName;
                newPersonAccount.LastName = acc.LastName;
                newPersonAccount.PersonEmail = acc.PersonEmail;
                newPersonAccount.Phone_Code__pc = tenantPhoneCode;
                newPersonAccount.Phone = acc.Phone;
                newPersonAccount.RecordTypeId = AccountRecordTypeId;
                newPersonAccount.OwnerId = u.Account.OwnerId;
                newPersonAccount.Salutation = tenanttitle;
                insert newPersonAccount;
                
                Contact con = [SELECT ID, firstName, lastname, Email, 
                               phone, Salutation,Activation_Code__c
                               FROM CONTACT
                               WHERE accountId = :newPersonAccount.Id];
                
                
                Deposit_Allocation__c da = new Deposit_Allocation__c();
                da.Deposit_Holder__c = newPersonAccount.Id;
                da.Deposit__c = depositId;
                da.role__c = 'Tenant';
                da.Deposit_Status__c='Validated';
                da.Contact__c = con.Id;
                insert da;
                //  EI_AddDeposit.notifyNewTenant(da.Id);
                
                if(con.Email ==null || con.Email =='' && con.phone!='' || con.phone !=null){
                    mailJetSMSService.smstotenant(con.Phone, con.Activation_Code__c);
                }else{
                    User u1 = new User();
                    // Alias Check
                    String fullName = con.FirstName + con.lastname;
                    if (fullName.length() >= 5){
                        u1.alias = fullName.substring(0, 4);
                    } else{
                        u1.alias = fullName;
                    }
                    
                    // NickName Check
                    String nickname = ((con.FirstName != null && con.FirstName.length() > 0) ? con.FirstName.substring(0, 1) : '')+con.FirstName.substring(0, 1);
                    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                    u1.CommunityNickname = nickname;
                    
                    // Username Check
                    
                    u1.Title = con.Salutation;
                    u1.FirstName = con.FirstName;
                    u1.LastName = con.lastname;
                    
                    // Uncomment
                    u1.Username = con.Email;
                    u1.Phone = con.Phone;
                    
                    //u.Username = con.Email + 'abc';
                    u1.Email = con.Email;
                    u1.ProfileId = [Select Id, name
                                    from profile
                                    where name = 'Tenant'
                                    limit 1].Id;
                    // u.profileId = ut.ProfileId;
                    
                    
                    u1.TimeZoneSidKey = 'Europe/London';
                    u1.LocaleSidKey = 'en_GB';
                    u1.LanguageLocaleKey = 'en_US';
                    u1.ContactId = con.Id;
                    u1.User_Type__c = 'Tenant';
                    u1.EmailEncodingKey = 'ISO-8859-1';
                    insert u1;
                }
                return newPersonAccount;
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        } else{
            ID AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId();
            user u = [select id, accountid, account.ownerid
                      from user
                      where id = :UserInfo.getUserId()];
            Account orgAcc = new Account();
            orgAcc.LastName = acc.Name;
            orgAcc.Company_Name__c = acc.Name;
            orgAcc.Email__c = acc.Personemail;
            orgAcc.Phone_Code__pc = tenantPhoneCode;
            orgAcc.Phone = acc.phone;
            orgAcc.PersonEmail = acc.Personemail;
            orgAcc.OwnerId = u.account.ownerId;
            orgAcc.RecordTypeId = AccountRecordTypeId;
            insert orgAcc;
            
            Contact con = [SELECT ID, firstName, lastname, Email, 
                               phone, Salutation
                               FROM CONTACT
                           WHERE accountId = :orgAcc.Id];
            
            
            Deposit_Allocation__c da = new Deposit_Allocation__c();
            da.Deposit_Holder__c = orgAcc.Id;
            da.Deposit__c = depositId;
            da.role__c = 'Tenant';
            da.Deposit_Status__c='Validated';
            da.Contact__c = con.Id;
            insert da;
          //  EI_AddDeposit.notifyNewTenant(da.Id);
            if(con.ID !=null){
           User u2 = new User();
                    // Alias Check
                    String fullName = con.FirstName + con.lastname;
                    if (fullName.length() >= 5){
                        u2.alias = fullName.substring(0, 4);
                    } else{
                        u2.alias = fullName;
                    }
                    
                    // NickName Check
                    String nickname = ((con.lastname != null && con.lastname.length() > 0) ? con.lastname.substring(0, 1) : '')+con.lastname.substring(0, 1);
                    nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                    u2.CommunityNickname = nickname;
                    
                    // Username Check
                    
                    u2.Title = con.Salutation;
                    u2.FirstName = con.FirstName;
                    u2.LastName = con.lastname;
                    
                    // Uncomment
                    u2.Username = con.Email;
                    u2.Phone = con.Phone;
                    
                    //u.Username = con.Email + 'abc';
                    u2.Email = con.Email;
                    u2.ProfileId = [Select Id, name
                                    from profile
                                    where name = 'Tenant'
                                    limit 1].Id;
                    // u.profileId = ut.ProfileId;
                    
                    
                    u2.TimeZoneSidKey = 'Europe/London';
                    u2.LocaleSidKey = 'en_GB';
                    u2.LanguageLocaleKey = 'en_US';
                    u2.ContactId = con.Id;
                    u2.User_Type__c = 'Tenant';
                    u2.EmailEncodingKey = 'ISO-8859-1';
                    insert u2;
                        }
              return orgAcc;
                }

       // }
       // return null;
    }
    
    @future(callout = true)
    public static void notifyNewTenant(Id da){
        // Perform a callout to an external service
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
        public Boolean LeadSummary{ get; set; }

        @AuraEnabled
        public Boolean IsOrg{ get; set; }

        @AuraEnabled
        public Integer item{ get; set; }

        @AuraEnabled
        public String companyName{ get; set; }
    }

    public class WrapperClass{
        @AuraEnabled
        public boolean livedeposit{ get; set; }

        @AuraEnabled
        public string proprty{ get; set; }

        @AuraEnabled
        public string primaryLandlord{ get; set; }

        @AuraEnabled
        public Property__c proprtyrec{ get; set; }

        @AuraEnabled
        public string recId{ get; set; }

        public WrapperClass(boolean isChecked, string rec, string recid, Property__c ppt, string primaryLandlord){
            this.livedeposit = isChecked;
            this.proprty = rec;
            this.proprtyrec = ppt;
            This.recId = recid;
            This.primaryLandlord = primaryLandlord;
        }
    }
    public class newTenantEmail{
        @AuraEnabled
        public String name{ get; set; }

        @AuraEnabled
        public String danNo{ get; set; }
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

    
    
}