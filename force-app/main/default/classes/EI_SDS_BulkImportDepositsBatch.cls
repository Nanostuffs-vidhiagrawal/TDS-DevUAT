public class EI_SDS_BulkImportDepositsBatch implements Database.Batchable<Object> , Database.AllowsCallouts, Database.Stateful {
    public String branchId = '';
    public list<object> csvFileRecords;
    public Boolean isValidateOnly;
    public String FileName = '';
    public Integer totalTenancies;
    public Integer totalFailures;
    public Integer totalTenants;
    public Integer totalLandlords;
    public String statusOfValidate = '';
    public String contactId = '';
    public String accountID = '';
    public String BulkNumber = '';
    public String csvHeaders = '';
    public list<String> rowKeyMap = new List<String>();
    public list<String> rowKeyMapList = new list<String>();
    public Map<String, String> generatedCSVRowMap = new Map<String, String>();
    public Map<String, String> generatedCSVErrorMap = new Map<String, String>();
    public String generatedCSVFile = '';
    public User currentUser = new User();
    
    public EI_SDS_BulkImportDepositsBatch(String BranchId, list<object> csvFileRecords, Boolean isValidateOnly, String FileName, Integer totalTenants, Integer totalLandlords, 
                                  String statusOfValidate, String contactId, String accountID)
    {
        this.branchId = BranchId;
        this.csvFileRecords = csvFileRecords;
        this.isValidateOnly = isValidateOnly;
		this.FileName = FileName;
		this.totalTenants = totalTenants;
        this.totalLandlords = totalLandlords;
        this.statusOfValidate = statusOfValidate;
        this.contactId = contactId;
        this.accountID = accountID;
        this.BulkNumber = EI_SDS_BulkImportDepositsBatchHelper.getBulkNumber();
    }
         
    public list<object> start(Database.BatchableContext context) {
        return csvFileRecords;
    }
    
    public void execute(Database.BatchableContext context, list<object> scope) {
        
        System.debug('rowKeyMapList => ' + rowKeyMapList);
        
        user userrec = [select id, name, contactid, accountid, User_Type__c, contact.LandLord_Registration_Number__c, account.ownerid, email
                        from user 
                        where id = :UserInfo.getUserId()];
        System.debug('userrec => ' + userrec); 
        System.debug('rowKeyMapList => ' + rowKeyMapList); 
        currentUser = userrec;
        ID depositRecordTypeId = Schema.SObjectType.Deposit__c.getRecordTypeInfosByDeveloperName().get('SDS_Deposit').getRecordTypeId();
        System.debug('depositRecordTypeId => ' + depositRecordTypeId); 
        //Savepoint sp;
       	List<Property__c> propertyList = new List<Property__c>();
        List<Deposit__c> depositList = new List<Deposit__c>();
        Map<String, List<Deposit_Allocation__c>> rowDepositAllocationsMap = new Map<String, list<Deposit_Allocation__c>>();
        list<String> rowKeyMap = new List<String>();
        Map<String, Id> primaryLLRowandIdMap = new Map<String, Id>();
        Map<String, Id> jointLLRowandIdMap = new Map<String, Id>();
        Map<String, Id> propertyRowandIdMap = new Map<String, Id>();
        Map<String, Id> depositRowandIdMap = new Map<String, Id>();
        
        Map<String, Map<Id, List<Property_Allocation__c>>> propAllocRowIdObjListMap = new Map<String, Map<Id, List<Property_Allocation__c>>>();
        
        csvHeaders = 'primary_landlord_title ,primary_landlord_first_name, primary_landlord_surname, primary_landlord_company, primary_landlord_building_name_or_number, primary_landlord_street, primary_landlord_town, primary_landlord_county, primary_landlord_postcode, primary_landlord_country, primary_landlord_mobile, primary_landlord_landline_phone, primary_landlord_email,'+
            'joint_landlord_title, joint_landlord_first_name, joint_landlord_surname, joint_landlord_company, joint_landlord_building_name_or_number, joint_landlord_street, joint_landlord_town, joint_landlord_county, joint_landlord_postcode, joint_landlord_country, joint_landlord_mobile, joint_landlord_email,'+ 
            'tenancy_building_name_or_number, tenancy_street, tenancy_town, tenancy_administrative_area, tenancy_postcode,' +
            'tenancy_start_date, tenancy_end_date, deposit_amount, deposit_amount_to_protect, rent_amount, deposit_received_date, number_of_tenants';
        
        for(object obj : scope){
            String Errors = '';
            String fileRow = '';
            Map<String, Object> mapObj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            system.debug('o.get' + mapObj);
            List<String> keyList = new List<String>();
            keyList.addAll(mapObj.keySet());
            
            system.debug('branchId' + branchId );
            system.debug('keyList' + keyList );
            system.debug(' ***** KEY ***** ' + mapObj.get('key') );
            system.debug(' ***** VALUE ***** ' + mapObj.get('value') );
            
            Map<String, Object> rowDataMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(mapObj.get('value') ));
            
            rowKeyMap.add(String.valueOf(mapObj.get('key')));
            rowKeyMapList.add(String.valueOf(mapObj.get('key')));
            
            String PLsalutation = String.valueOf(rowDataMap.get('primary_landlord_title'));
            String PLfirstname = String.valueOf(rowDataMap.get('primary_landlord_first_name'));
            String PLlastname = '';
            if (rowDataMap.get('primary_landlord_surname') == ''){
                System.debug('primary_landlord_surname is Blank');
                PLlastname = String.valueOf(rowDataMap.get('primary_landlord_company'));
            }else{
                PLlastname = String.valueOf(rowDataMap.get('primary_landlord_surname'));
            }
            String PLemail = String.valueOf(rowDataMap.get('primary_landlord_email'));
            string PLphoneCode = '';
            string PLphone = String.valueOf(rowDataMap.get('primary_landlord_mobile'));
            string PLcompanyName = String.valueOf(rowDataMap.get('primary_landlord_company'));
            string PLcompanyPhoneCode = '';
            string PLcompanyPhone = String.valueOf(rowDataMap.get('primary_landlord_mobile'));
            string PLlandlinePhone = String.valueOf(rowDataMap.get('primary_landlord_landline_phone')); 
            boolean PLisOrguser = false;
            if(rowDataMap.get('primary_landlord_company')=='' || rowDataMap.get('primary_landlord_company')==null){
                PLisOrguser = false;
            }else{
                PLisOrguser = true;
            }
            string PLstreet = String.valueOf(rowDataMap.get('primary_landlord_building_name_or_number')) + ', ' + 
                String.valueOf(rowDataMap.get('primary_landlord_street'));
            string PLcity = String.valueOf(rowDataMap.get('primary_landlord_town'));
            string PLpostcode = String.valueOf(rowDataMap.get('primary_landlord_postcode'));
            string PLcountry = String.valueOf(rowDataMap.get('primary_landlord_country'));
            string PLcounty = String.valueOf(rowDataMap.get('primary_landlord_county'));
            string PLlandRegNumber='';
            String PLlandRegStatus='';
            
            String fullNameForSearch = PLfirstname.trim() +' '+ PLlastname.trim();
            Account duplicateAccount ;
            Contact duplicateContact ;
            boolean isCreateContactOnly = false;
            Id PLaccId;
            Id PLconId;
            Id PLAccountRecordTypeId;
            
            if (PLisOrguser){
                PLAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                
                List<Account> accSearchList = [SELECT ID, Name, recordtypeId FROM Account 
                                               WHERE Name =:PLcompanyName AND (Email__c=:PLemail.trim() OR PersonEmail=:PLemail.trim() )
                                               AND recordtypeId =:PLAccountRecordTypeId ];
                List<Contact> conSearchList = [SELECT ID, Name, Account.recordtypeId, AccountId FROM Contact
                                               WHERE Name =:fullNameForSearch AND Email=:PLemail.trim() 
                                               AND Account.recordtypeId =:PLAccountRecordTypeId];
				if(accSearchList.size() > 0){ // check duplicate Account size 
                    duplicateAccount = accSearchList[0]; 
                    PLaccId = duplicateAccount.Id;
                    
                    if(duplicateAccount.recordtypeId == PLAccountRecordTypeId){ // compare recordtype of duplicate and new Account
                        if(conSearchList.size() > 0){  // check duplicate Contact size
                            duplicateContact = conSearchList[0]; 
                            
                            if(duplicateContact.Account.recordtypeId == PLAccountRecordTypeId){ // compare recordtype of duplicate and new Account
                                if(duplicateAccount.Id == duplicateContact.AccountId){ // check duplicate Acc and con are related to each other or not
                                    PLaccId = duplicateAccount.Id;
                                    PLconId = duplicateContact.Id;
                                }
                                else{ 
                                    PLaccId = duplicateAccount.Id;
                                    isCreateContactOnly = true;
                                }
                            }else{ 
                                PLaccId = duplicateAccount.Id;
                                isCreateContactOnly = true;
                            }
                        }
                        else{
                            PLaccId = duplicateAccount.Id;
                            isCreateContactOnly = true;
                        }
                    }
                    if(isCreateContactOnly){
                        Contact con = new contact(AccountId = PLaccId, Salutation = PLsalutation, FirstName = PLfirstname, Account_Status__c= 'Active',
                                                  lastname = PLlastname, email = PLemail, Phone_Code__c = PLphoneCode, Phone = PLphone, MailingStreet = PLstreet,
                                                  MailingCity = PLcity,MailingPostalCode = PLpostcode,MailingCountry = PLcountry,
                                                  MailingState = PLcounty, LandLord_Registration_Number__c = PLlandRegNumber, 
                                                  LandLord_Registration_Status__c = PLlandRegStatus,Branch__c = branchId);
                        //insert con;
                        Database.SaveResult conSR = Database.insert(con, false);
                        if (conSR.isSuccess()) {
                            System.debug('Successfully inserted Primary landlord Contact ID: ' + conSR.getId() );
                            PLconId = conSR.getId();
                        }else{
                            for(Database.Error err : conSR.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Contact fields that affected this error: ' + err.getFields());
                                Errors = Errors + ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                            }
                        }
                    }
                } 
                else{
                    System.debug('if acc not searched => ');
                    Account acc = new Account(name = PLcompanyName, Phone_Code__c = PLcompanyPhoneCode, Phone = PLcompanyPhone, RecordTypeId = PLAccountRecordTypeId, Email__c = PLemail,
                                              Parent_person_account__c = userrec.accountId, OwnerId = userrec.account.ownerid,BillingStreet = PLstreet,
                                              BillingCity = PLcity,BillingPostalCode = PLpostcode,BillingCountry = PLcountry,BillingState = PLcounty);
                    
                    Database.SaveResult accSR = Database.insert(acc, false);
                    if (accSR.isSuccess()) {
                        System.debug('Successfully inserted Primary landlord Account ID: ' + accSR.getId() );
                        PLaccId = accSR.getId();
                        Contact con = new contact(AccountId = accSR.getId(), Salutation = PLsalutation, FirstName = PLfirstname, Account_Status__c= 'Active',
                                                  lastname = PLlastname, email = PLemail, Phone_Code__c = PLphoneCode, Phone = PLphone, MailingStreet = PLstreet,
                                                  MailingCity = PLcity,MailingPostalCode = PLpostcode,MailingCountry = PLcountry,
                                                  MailingState = PLcounty, LandLord_Registration_Number__c = PLlandRegNumber, 
                                                  LandLord_Registration_Status__c = PLlandRegStatus,Branch__c = branchId);
                        //insert con;
                        Database.SaveResult conSR = Database.insert(con, false);
                        if (conSR.isSuccess()) {
                            System.debug('Successfully inserted Primary landlord Contact ID: ' + conSR.getId() );
                            PLconId = conSR.getId();
                        }else{
                            for(Database.Error err : conSR.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Contact fields that affected this error: ' + err.getFields());
                                Errors = Errors + ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                            }
                        }
                    }
                    else{             
                        for(Database.Error err : accSR.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Contact fields that affected this error: ' + err.getFields());
                            Errors = Errors + ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                        }
                    }
                }
            } 
            else{
                PLAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId();
                
                List<Contact> searchList = [SELECT ID, Name, Account.recordtypeId, AccountId FROM Contact
                                            WHERE Name =:fullNameForSearch AND Email=:PLemail.trim() 
                                            AND Account.recordtypeId =:PLAccountRecordTypeId];
                System.debug('PL searchList => ' + searchList);
                if(searchList.size() > 0){ 
                    duplicateContact = searchList[0];
                    if(duplicateContact.Account.recordtypeId == PLAccountRecordTypeId){
                        PLconId = duplicateContact.Id;
                        PLaccId = duplicateContact.AccountId;
                        System.debug('duplicateContact PLaccId => ' + PLconId);
                    }
                }
                else{
                    Account Acc = new Account();
                    Acc.FirstName = PLfirstname;
                    Acc.LastName = PLlastname;
                    Acc.Salutation = PLsalutation;
                    acc.OwnerId = userrec.account.ownerid;
                    Acc.PersonEmail = PLemail;
                    Acc.Email__c = PLemail;
                    Acc.PersonHomePhone = PLlandlinePhone;
                    Acc.Phone_Code__pc = PLphoneCode;
                    Acc.Phone = PLphone;
                    Acc.RecordTypeId = PLAccountRecordTypeId;
                    Acc.Parent_person_account__c = userrec.accountId;
                    acc.BillingStreet = PLstreet;
                    acc.BillingCity = PLcity;
                    acc.BillingPostalCode = PLpostcode;
                    acc.BillingCountry = PLcountry;
                    acc.BillingState = PLcounty;
                    acc.PersonMailingStreet = PLstreet;
                    acc.PersonMailingCity = PLcity;
                    acc.PersonMailingPostalCode = PLpostcode;
                    acc.PersonMailingCountry = PLcountry;
                    acc.PersonMailingState = PLcounty;
                    acc.LandLord_Registration_Number__pc = PLlandRegNumber;
                    acc.LandLord_Registration_Status__pc = PLlandRegStatus;
                    acc.Account_Status__pc= 'Active';
                    acc.Branch__pc = branchId;
                    
                    Database.SaveResult accSR = Database.insert(acc, false);
                    if (accSR.isSuccess()) {
                        System.debug('Successfully inserted Primary landlord Account ID: ' + accSR.getId() );
                        PLaccId = accSR.getId();
                        Contact con = [Select id,Branch__c,AccountId,firstName,MailingStreet,MailingCity,MailingCountry,MailingState,MailingPostalCode,Phone,Email, lastName from Contact where AccountId =: accSR.getId()];
                        PLconId = con.Id;
                    }
                    else {             
                        for(Database.Error err : accSR.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                            Errors = Errors + ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                        }
                    } 
                }
            }
            
            primaryLLRowandIdMap.put(String.valueOf(mapObj.get('key')), PLconId);
                System.debug('primaryLLRowandIdMap => ' + primaryLLRowandIdMap);
            String JLsalutation = String.valueOf(rowDataMap.get('joint_landlord_title'));
            String JLfirstname = String.valueOf(rowDataMap.get('joint_landlord_first_name'));
            String JLlastname = '';
            if (rowDataMap.get('joint_landlord_surname') == ''){
                System.debug('joint_landlord_surname is Blank');
                JLlastname = String.valueOf(rowDataMap.get('joint_landlord_company'));
            }else{
                JLlastname = String.valueOf(rowDataMap.get('joint_landlord_surname'));
            }
            String JLemail = String.valueOf(rowDataMap.get('joint_landlord_email'));
            string JLphoneCode = '';
            string JLphone = String.valueOf(rowDataMap.get('joint_landlord_mobile'));
            string JLcompanyName = String.valueOf(rowDataMap.get('joint_landlord_company'));
            string JLcompanyPhoneCode = '';
            string JLcompanyPhone = String.valueOf(rowDataMap.get('joint_landlord_mobile'));
            string JLlandlinePhone = String.valueOf(rowDataMap.get('joint_landlord_mobile'));
            boolean JLisOrguser = false;
            
            if(rowDataMap.get('joint_landlord_company')=='' || rowDataMap.get('joint_landlord_company')==null){
                JLisOrguser = false;
            }else{
                JLisOrguser = true;
            }
            string JLstreet = String.valueOf(rowDataMap.get('joint_landlord_building_name_or_number')) + ', ' + 
                String.valueOf(rowDataMap.get('joint_landlord_street'));
            string JLcity = String.valueOf(rowDataMap.get('joint_landlord_town'));
            string JLpostcode = String.valueOf(rowDataMap.get('joint_landlord_postcode'));
            string JLcountry = String.valueOf(rowDataMap.get('joint_landlord_country'));
            string JLcounty = String.valueOf(rowDataMap.get('joint_landlord_county'));
            string JLlandRegNumber='';
            String JLlandRegStatus='';

            if(JLlastname != ''){
                String JLfullNameForSearch = JLfirstname.trim() +' '+ JLlastname.trim();
                Account duplicateJLAccount ;
                Contact duplicateJLContact ;
                boolean isCreateJLContactOnly = false;
                Id JLaccId;
                Id JLconId;
                Id JLAccountRecordTypeId;
                
                if (JLisOrguser){
                    JLAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                    List<Account> accSearchList = [SELECT ID, Name, recordtypeId FROM Account 
                                                   WHERE Name =:JLcompanyName AND (Email__c=:JLemail.trim() OR PersonEmail=:JLemail.trim() )
                                                   AND recordtypeId =:JLAccountRecordTypeId ];
                    
                    List<Contact> conSearchList = [SELECT ID, Name, Account.recordtypeId, AccountId FROM Contact
                                                   WHERE Name =:JLfullNameForSearch AND Email=:JLemail.trim() 
                                                   AND Account.recordtypeId =:JLAccountRecordTypeId];
                    
                    if(accSearchList.size() > 0){ // check duplicate Account size 
                        duplicateAccount = accSearchList[0]; 
                        JLconId = duplicateAccount.Id;
                        
                        if(duplicateAccount.recordtypeId == JLAccountRecordTypeId){ // compare recordtype of duplicate and new Account
                            if(conSearchList.size() > 0){  // check duplicate Contact size
                                duplicateContact = conSearchList[0]; //conList[0];
                                
                                if(duplicateContact.Account.recordtypeId == JLAccountRecordTypeId){ // compare recordtype of duplicate and new Account
                                    if(duplicateAccount.Id == duplicateContact.AccountId){ // check duplicate Acc and con are related to each other or not
                                        JLaccId = duplicateAccount.Id;
                                        JLconId = duplicateContact.Id;
                                    }else{ 
                                        JLaccId = duplicateAccount.Id;
                                        isCreateJLContactOnly = true;
                                    }
                                }else{ 
                                    JLaccId = duplicateAccount.Id;
                                    isCreateJLContactOnly = true;
                                }
                            }
                            else{
                                JLaccId = duplicateAccount.Id;
                                isCreateJLContactOnly = true;
                            }
                        }
                        if(isCreateJLContactOnly){
                            Contact con = new contact(AccountId = JLaccId, Salutation = JLsalutation, FirstName = JLfirstname, Account_Status__c= 'Active',
                                                      lastname = JLlastname, email = JLemail, Phone_Code__c = JLphoneCode, Phone = JLphone, MailingStreet = JLstreet,
                                                      MailingCity = JLcity,MailingPostalCode = JLpostcode,MailingCountry = JLcountry,
                                                      MailingState = JLcounty, LandLord_Registration_Number__c = JLlandRegNumber, 
                                                      LandLord_Registration_Status__c = JLlandRegStatus,Branch__c = branchId);
                            //insert con;
                            Database.SaveResult conSR = Database.insert(con, false);
                            if (conSR.isSuccess()) {
                                System.debug('Successfully inserted Primary landlord Account ID: ' + conSR.getId() );
                                JLconId = conSR.getId();
                            }else{
                                for(Database.Error err : conSR.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                    Errors = Errors + ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                                }
                            }
                        }
                    } 
                    else{
                        Account acc = new Account(name = JLcompanyName, Phone_Code__c = JLcompanyPhoneCode, Phone = JLcompanyPhone, RecordTypeId = JLAccountRecordTypeId, Email__c = JLemail,
                                                  Parent_person_account__c = userrec.accountId, OwnerId = userrec.account.ownerid,BillingStreet = JLstreet,
                                                  BillingCity = JLcity,BillingPostalCode = JLpostcode,BillingCountry = JLcountry,BillingState = JLcounty);
                        
                        Database.SaveResult accSR = Database.insert(acc, false);
                        if (accSR.isSuccess()) {
                            System.debug('Successfully inserted Primary landlord Account ID: ' + accSR.getId() );
                            JLaccId = accSR.getId();
                            Contact con = new contact(AccountId = accSR.getId(), Salutation = JLsalutation, FirstName = JLfirstname, Account_Status__c= 'Active',
                                                      lastname = JLlastname, email = JLemail, Phone_Code__c = JLphoneCode, Phone = JLphone, MailingStreet = JLstreet,
                                                      MailingCity = JLcity,MailingPostalCode = JLpostcode,MailingCountry = JLcountry,
                                                      MailingState = JLcounty, LandLord_Registration_Number__c = JLlandRegNumber, 
                                                      LandLord_Registration_Status__c = JLlandRegStatus,Branch__c = branchId);
                            //insert con;
                            Database.SaveResult conSR = Database.insert(con, false);
                            if (conSR.isSuccess()) {
                                System.debug('Successfully inserted Primary landlord Contact ID: ' + conSR.getId() );
                                JLconId = conSR.getId();
                            }else{
                                for(Database.Error err : conSR.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                    Errors = Errors + ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                                }
                            }
                        }
                        else{             
                            for(Database.Error err : accSR.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                                Errors = Errors + ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                            }
                        }
                    }
                } 
                else{
                    JLAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId(); 
                    List<Contact> searchList = [SELECT ID, Name, Account.recordtypeId, AccountId FROM Contact
                                                WHERE Name =:JLfullNameForSearch AND Email=:JLemail.trim() 
                                                AND Account.recordtypeId=:JLAccountRecordTypeId];
                    
                    if(searchList.size() > 0){ 
                        duplicateContact = searchList[0]; 
                        
                        if(duplicateContact.Account.recordtypeId == JLAccountRecordTypeId){
                            System.debug('searchList => ' + duplicateContact);
                            JLconId = duplicateContact.Id;
                            JLaccId = duplicateContact.AccountId;
                        }
                    }
                    else{
                        Account Acc = new Account();
                        Acc.FirstName = JLfirstname;
                        Acc.LastName = JLlastname;
                        Acc.Salutation = JLsalutation;
                        acc.OwnerId = userrec.account.ownerid;
                        Acc.PersonEmail = JLemail;
                        Acc.Email__c = JLemail;
                        Acc.PersonHomePhone = JLlandlinePhone;
                        Acc.Phone_Code__pc = JLphoneCode;
                        Acc.Phone = PLphone;
                        Acc.RecordTypeId = JLAccountRecordTypeId;
                        Acc.Parent_person_account__c = userrec.accountId;
                        acc.BillingStreet = JLstreet;
                        acc.BillingCity = JLcity;
                        acc.BillingPostalCode = JLpostcode;
                        acc.BillingCountry = JLcountry;
                        acc.BillingState = JLcounty;
                        acc.PersonMailingStreet = JLstreet;
                        acc.PersonMailingCity = JLcity;
                        acc.PersonMailingPostalCode = JLpostcode;
                        acc.PersonMailingCountry = JLcountry;
                        acc.PersonMailingState = JLcounty;
                        acc.LandLord_Registration_Number__pc = JLlandRegNumber;
                        acc.LandLord_Registration_Status__pc = JLlandRegStatus;
                        acc.Account_Status__pc= 'Active';
                        acc.Branch__pc = branchId;
                        
                        Database.SaveResult accSR = Database.insert(acc, false);
                        if (accSR.isSuccess()) {
                            System.debug('Successfully inserted Primary landlord Account ID: ' + accSR.getId() );
                            JLaccId = accSR.getId();
                            Contact con = [Select id,Branch__c,AccountId,firstName,MailingStreet,MailingCity,MailingCountry,MailingState,MailingPostalCode,Phone,Email, lastName from Contact where AccountId =: accSR.getId()];
                            JLconId = con.Id;
                        }
                        else {             
                            for(Database.Error err : accSR.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                                Errors = Errors + ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                            }
                        } 
                    }
                }
                
                jointLLRowandIdMap.put(String.valueOf(mapObj.get('key')), JLconId);
            }
            String propHouseNo = String.valueOf(rowDataMap.get('tenancy_building_name_or_number'));
            string propStreet = String.valueOf(rowDataMap.get('tenancy_street')); 
            string propCity = String.valueOf(rowDataMap.get('tenancy_town'));
            string propPostcode = String.valueOf(rowDataMap.get('tenancy_postcode'));
            string propCountry = 'UK';
            string propCounty = '';
            string propLocalAuthorityArea = String.valueOf(rowDataMap.get('tenancy_administrative_area'));
            String propOwner = '';
            if (userrec.User_Type__c == 'Agent'){
                propOwner = PLaccId;
                System.debug('PLaccId : ' + PLaccId );
            }else{
                propOwner = userrec.AccountId; 
                System.debug('userrec : ' + userrec );
            }
            System.debug('propOwner : ' + propOwner );
            Property__c insertProperty = new Property__c(House_No__c=propHouseNo, Street__c=propStreet, City__c=propCity, Postal_Code__c=propPostcode,
                                                         Country__c=propCountry, County__c=propCounty, 
                                                         Local_Authority_Area__c=propLocalAuthorityArea, Branch__c=branchId, 
                                                         Property_status__c = 'Active', Property_Owner__c = propOwner);
            Property__c duplicateProp = EI_SDS_BulkImportDepositsBatchHelper.checkDuplicateProperty(insertProperty);
            if(duplicateProp != null){
                insertProperty = duplicateProp;
                propertyList.add(insertProperty);
            }else{
                Database.SaveResult propertySR = Database.insert(insertProperty, false);
                if (propertySR.isSuccess()) {
                    System.debug('Successfully inserted Property : ' + propertySR.getId() );
                    insertProperty.Id = propertySR.getId();
                    propertyList.add(insertProperty);
                }
                else {             
                    for(Database.Error err : propertySR.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Property fields that affected this error: ' + err.getFields());
                        Errors = Errors + ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                    }
                }
            }
             
            String startDateSTR = String.valueOf(rowDataMap.get('tenancy_start_date'));
           	List<String> startDateList = startDateSTR.split('[-/]');
            Date depstStartDate = date.newInstance(Integer.valueOf(startDateList[2]), Integer.valueOf(startDateList[1]), Integer.valueOf(startDateList[0]));
            String endDateSTR = String.valueOf(rowDataMap.get('tenancy_end_date'));
            Date depstEndDate;
            if(endDateSTR != null && endDateSTR != ''){
                List<String> endDateList = endDateSTR.split('[-/]');
                depstEndDate = date.newInstance(Integer.valueOf(endDateList[2]), Integer.valueOf(endDateList[1]), Integer.valueOf(endDateList[0]));
            }
            String receivedDateSTR = String.valueOf(rowDataMap.get('deposit_received_date'));
            Date depstReceivedDate;
            if(receivedDateSTR != null && receivedDateSTR != ''){
                List<String> receivedDateList = receivedDateSTR.split('[-/]');
                depstReceivedDate = date.newInstance(Integer.valueOf(receivedDateList[2]), Integer.valueOf(receivedDateList[1]), Integer.valueOf(receivedDateList[0]));
            }
            Decimal depstAmount = Decimal.valueOf(String.valueOf(rowDataMap.get('deposit_amount')).replaceAll('[^\\.|\\d]', '')); 
            Decimal depstProtectedAmount = Decimal.valueOf(String.valueOf(rowDataMap.get('deposit_amount_to_protect')).replaceAll('[^\\.|\\d]', ''));
            Decimal depstRentAmount = 0;
            if (rowDataMap.get('rent_amount') != ''){
                System.debug('rent_amount is Blank');
                depstRentAmount = Decimal.valueOf(String.valueOf(rowDataMap.get('rent_amount')).replaceAll('[^\\.|\\d]', ''));
            }
            Integer noOfTenants = Integer.valueOf(String.valueOf(rowDataMap.get('number_of_tenants')));
            
            Deposit__c insertDeposit = new Deposit__c(recordtypeId = depositRecordTypeId,Branch__c=branchId,Number_of_Tenants__c = noOfTenants, 
                                                      Rent_Amount__c = depstRentAmount, Deposit_Amount__c = depstAmount, Protected_Amount__c = depstProtectedAmount, 
                                                      Date_Deposit_Received__c = depstReceivedDate, Start_Date__c = depstStartDate, 
                                                      Property__c = insertProperty.Id,
                                                      Customer__c = userrec.accountid, Scheme__c = System.Label.SDSschemeId);
            depositList.add(insertDeposit);
            
            fileRow = PLsalutation+', '+ PLfirstname+', '+ PLlastname+', '+ PLcompanyName+', '+ PLstreet+', '+ PLcity+', '+ PLcounty+', '+ PLpostcode+', '+ PLcountry+', '+ PLphone+', '+ PLlandlinePhone+', '+ PLemail+', '+ JLsalutation+', '+ JLfirstname+', '+ JLlastname+', '+ JLcompanyName+', '+ JLstreet+', '+ JLcity+', '+ JLcounty+', '+ JLpostcode+', '+ JLcountry+', '+ JLphone+', '+ JLemail+', '+ propHouseNo+', '+ propStreet+', '+ propCity+', '+ propLocalAuthorityArea+', '+ propPostcode+', '+ depstStartDate+', '+ depstEndDate+', '+ depstAmount+', '+ depstProtectedAmount+', '+ depstRentAmount+', '+ depstReceivedDate+', '+ noOfTenants;
            
            List<Account> tenantList = new List<Account>();
            Set<String> emailIds = new Set<String>();
            for(integer t=1; t<=noOfTenants; t++){
                String tenantTitle = '';
                String tenantFName = '';
                String tenantLName = '';
                String tenantPhone = '';
                String tenantEmail = '';
                if(t==1){
                    tenantTitle = 'tenant_'+t+'_lead'+'_title';
                    tenantFName = 'tenant_'+t+'_lead'+'_first_name';
                    tenantLName = 'tenant_'+t+'_lead'+'_surname';
                    tenantPhone = 'tenant_'+t+'_lead'+'_mobile';
                    tenantEmail = 'tenant_'+t+'_lead'+'_email';
                }else{
                    tenantTitle = 'tenant_'+t+'_joint'+'_title';
                    tenantFName = 'tenant_'+t+'_joint'+'_first_name';
                    tenantLName = 'tenant_'+t+'_joint'+'_surname';
                    tenantPhone = 'tenant_'+t+'_joint'+'_mobile';
                    tenantEmail = 'tenant_'+t+'_joint'+'_email';
                }
                if(!csvHeaders.contains(tenantTitle)){
                    csvHeaders += ', '+ tenantTitle;
                }
                if(!csvHeaders.contains(tenantFName)){
                    csvHeaders += ', '+ tenantFName;
                }
                if(!csvHeaders.contains(tenantLName)){
                    csvHeaders += ', '+ tenantLName;
                }
                if(!csvHeaders.contains(tenantPhone)){
                    csvHeaders += ', '+ tenantPhone;
                }
                if(!csvHeaders.contains(tenantEmail)){
                    csvHeaders += ', '+ tenantEmail;
                }
                fileRow += ', '+tenantTitle + ', '+tenantFName +', '+tenantLName + ', '+tenantPhone + ', '+tenantEmail;
                String tnntTitle = String.valueOf(rowDataMap.get(tenantTitle));
                string tnntFirstName = String.valueOf(rowDataMap.get(tenantFName)); 
                string tnntLastName = String.valueOf(rowDataMap.get(tenantLName));
                string tnntPhone = String.valueOf(rowDataMap.get(tenantPhone));
                string tnntEmail = String.valueOf(rowDataMap.get(tenantEmail));
                
                Account DAacc = new account();
                DAacc.Salutation = tnntTitle;
                DAacc.FirstName = tnntFirstName;
                DAacc.LastName = tnntLastName;
                DAacc.Email__c = tnntEmail;
                DAacc.PersonEmail = tnntEmail;
                DAacc.Phone_Code__pc = '';
                DAacc.Phone = tnntPhone;
                DAacc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Tenant').getRecordTypeId();
                DAacc.OwnerId = userrec.account.ownerid;
                
                if(String.isnotEmpty(tnntEmail)) {
                    emailIds.add(tnntEmail.trim() );
                }
                
                tenantList.add(DAacc);
            }
            
            generatedCSVErrorMap.put(String.valueOf(mapObj.get('key')), Errors);
            generatedCSVRowMap.put(String.valueOf(mapObj.get('key')), fileRow);
            System.debug('generatedCSVErrorMap => ' + generatedCSVErrorMap);
            System.debug('generatedCSVRowMap => ' + generatedCSVRowMap);
            
            list<Deposit_Allocation__c> insertDepositAllocations = EI_SDS_BulkImportDepositsBatchHelper.addtenantList(tenantList, emailIds);
            System.debug('insertDepositAllocations => ' + insertDepositAllocations);
            rowDepositAllocationsMap.put(String.valueOf(mapObj.get('key')), insertDepositAllocations);
        } 
    	
        Map<id, Property_Allocation__c> prAllocationToDelete = new Map<Id, Property_Allocation__c>();
        Map<id, Property_Allocation__c> prAllocationToUpdate = new Map<Id, Property_Allocation__c>();
        //list<Property_Allocation__c> prAllocation = new list<Property_Allocation__c>();
        Map<id, Property_Allocation__c> prAllocationMap = new Map<Id, Property_Allocation__c>();
        list<Deposit_Allocation__c> dpAllocation = new list<Deposit_Allocation__c>();
        Installment__c newInstallment = new Installment__c();
        list<Installment__c> installmentList = new list<Installment__c>();
        
        /*
        // insert  Properties
        integer i=0;
        Database.UpsertResult[] propSRList = Database.upsert(propertyList, false); //Database.SaveResult[] = Database.insert(propertyList, false);
        // Iterate through each returned result
        for (Database.UpsertResult sr : propSRList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Property. Property ID: ' + sr.getId());
                propertyRowandIdMap.put(rowKeyMap[i], sr.getId());
                depositList[i].Property__c = sr.getId();
                
                if (userrec.User_Type__c == 'Agent'){
                    prAllocation.add(new Property_Allocation__c(Contact__c=primaryLLRowandIdMap.get(rowKeyMap[i]), Property__c=sr.getId(), Relation_to_Property__c='Primary Landlord'));
                } else{
                    prAllocation.add(new Property_Allocation__c(Contact__c=userrec.contactid, Property__c=sr.getId(), Relation_to_Property__c='Primary Landlord'));
                }
                if (jointLLRowandIdMap.get(rowKeyMap[i]) != null){
                    prAllocation.add(new Property_Allocation__c(Contact__c=jointLLRowandIdMap.get(rowKeyMap[i]), Property__c=sr.getId(), Relation_to_Property__c='Joint Landlord'));
                }
            }
            else {
                // Operation failed, so get all errors  
                String Errors = generatedCSVErrorMap.get(rowKeyMap[i]);              
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                    Errors += ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                }
                generatedCSVErrorMap.put(rowKeyMap[i], Errors);
            }
            i++;
        }
        */
        
        // insert Property Allocations
        Integer i=0;
        for(property__c prop : propertyList){
            Boolean isPrimaryPropAllocDuplicate = false;
            Boolean isJoinPropAllocDuplicate = false;
            
            if(!prop.Property_Allocations__r.isEmpty()){
                for(Property_Allocation__c propAlloc : prop.Property_Allocations__r){
                    System.debug('propAlloc.Contact => ' + propAlloc.Contact__c);
                    System.debug('primaryLLRowandIdMap.Contact => ' + primaryLLRowandIdMap.get(rowKeyMap[i]));
                    if(propAlloc.Contact__c == primaryLLRowandIdMap.get(rowKeyMap[i])){
                        propAlloc.Relation_to_Property__c='Primary Landlord';
                        prAllocationToUpdate.put(propAlloc.Id, propAlloc);
                        isPrimaryPropAllocDuplicate = true;
                        if(prAllocationToDelete.containsKey(propAlloc.Id)){
                            prAllocationToDelete.remove(propAlloc.Id);
                        }
                    }
                    
                    if(jointLLRowandIdMap.get(rowKeyMap[i]) != null){
                        System.debug('jointLLRowandIdMap.Contact => ' + jointLLRowandIdMap.get(rowKeyMap[i]));
                        if(propAlloc.Contact__c == jointLLRowandIdMap.get(rowKeyMap[i])){
                            if(primaryLLRowandIdMap.get(rowKeyMap[i]) != jointLLRowandIdMap.get(rowKeyMap[i])){
                                propAlloc.Relation_to_Property__c='Joint Landlord';
                            }
                            prAllocationToUpdate.put(propAlloc.Id, propAlloc);
                            isJoinPropAllocDuplicate = true;
                        }
                    }
                }
            }
            
            if(!isPrimaryPropAllocDuplicate){
                if(!prAllocationMap.containsKey(primaryLLRowandIdMap.get(rowKeyMap[i])) || 
                   (prAllocationMap.containsKey(primaryLLRowandIdMap.get(rowKeyMap[i])) && 
                  prAllocationMap.get(primaryLLRowandIdMap.get(rowKeyMap[i])).Relation_to_Property__c != 'Primary Landlord'))
                {
                    if (userrec.User_Type__c == 'Agent'){
                        prAllocationMap.put(primaryLLRowandIdMap.get(rowKeyMap[i]), new Property_Allocation__c(Contact__c=primaryLLRowandIdMap.get(rowKeyMap[i]), Property__c= prop.Id, Relation_to_Property__c='Primary Landlord'));
                        //prAllocation.add(new Property_Allocation__c(Contact__c=primaryLLRowandIdMap.get(rowKeyMap[i]), Property__c= prop.Id, Relation_to_Property__c='Primary Landlord'));
                    } else{
                        prAllocationMap.put(userrec.contactid, new Property_Allocation__c(Contact__c=userrec.contactid, Property__c= prop.Id, Relation_to_Property__c='Primary Landlord'));
                        //prAllocation.add(new Property_Allocation__c(Contact__c=userrec.contactid, Property__c= prop.Id, Relation_to_Property__c='Primary Landlord'));
                    }
                }
                   
                if(!prop.Property_Allocations__r.isEmpty()){
                    for(Property_Allocation__c propAlloc : prop.Property_Allocations__r){
                        System.debug('propAlloc => ' + propAlloc);
                        if(propAlloc.Relation_to_Property__c == 'Primary Landlord'){
                            prAllocationToDelete.put(propAlloc.Id, propAlloc);
                        }
                    }
                }
            }
            
            if(!isJoinPropAllocDuplicate){
                if (jointLLRowandIdMap.get(rowKeyMap[i]) != null){
                    if(!prAllocationMap.containsKey(jointLLRowandIdMap.get(rowKeyMap[i]))){
                        prAllocationMap.put(jointLLRowandIdMap.get(rowKeyMap[i]), new Property_Allocation__c(Contact__c=jointLLRowandIdMap.get(rowKeyMap[i]), Property__c= prop.Id, Relation_to_Property__c='Joint Landlord'));
                    }
                    //prAllocation.add(new Property_Allocation__c(Contact__c=jointLLRowandIdMap.get(rowKeyMap[i]), Property__c= prop.Id, Relation_to_Property__c='Joint Landlord'));
                }
            }
            
            i++;
        }
        System.debug('prAllocationToUpdate => ' + prAllocationToUpdate);
        System.debug('prAllocationToDelete => ' + prAllocationToDelete);
        System.debug('prAllocationMap => ' + prAllocationMap);
        if (prAllocationToUpdate.size() > 0){
            update prAllocationToUpdate.values();
        }
        
        if (prAllocationToDelete.size() > 0){
            delete prAllocationToDelete.values();
        }
        
        if (prAllocationMap.size() > 0){
            insert prAllocationMap.values();
        }
        
        // insert Deposit
        i=0;
        Database.SaveResult[] depoSRList = Database.insert(depositList, false);
        List<Id> depoIDListForPI = new List<Id>();
        // Iterate through each returned result
        for (Database.SaveResult sr : depoSRList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Desposit. Deposit ID: ' + sr.getId() );
                System.debug(rowKeyMap[i] + '=> rowDepositAllocationsMap: ' + rowDepositAllocationsMap.get(rowKeyMap[i]));
                
                newInstallment = new Installment__c(Status__c = 'Pending', Deposit__c = sr.getId(), Installment_Type__c = 'Receivable', 
                                  Amount__c = depositList[i].Protected_Amount__c, BLK_Number__c = BulkNumber);
                installmentList.add(newInstallment);
                //depositRowandIdMap.put(rowKeyMap[i], sr.getId());
                for(Deposit_Allocation__c da : rowDepositAllocationsMap.get(rowKeyMap[i]) ){
                    da.Deposit__c = sr.getId();
                    System.debug(rowKeyMap[i] + '=> Deposit Allocations =>' + da);
                    dpAllocation.add(da);
                }
                depoIDListForPI.add(sr.getId());
            } 
            else {
                // Operation failed, so get all errors      
                String Errors = generatedCSVErrorMap.get(rowKeyMap[i]);           
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('deposit fields that affected this error: ' + err.getFields());
                    Errors += ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                }
                generatedCSVErrorMap.put(rowKeyMap[i], Errors);
            }
            i++;
        }
        
        // update deposit Id in Deposit Allocations
        if (dpAllocation.size() > 0){
            //insert dpAllocation;
            i=0;
            Database.SaveResult[] depoAllocSRList = Database.insert(dpAllocation, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : depoAllocSRList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors      
                    String Errors = generatedCSVErrorMap.get(rowKeyMap[i]);           
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('deposit Allocation fields that affected this error: ' + err.getFields());
                        Errors += ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                    }
                    generatedCSVErrorMap.put(rowKeyMap[i], Errors);
                }
                i++;
            }
        }
        
        //insert Installment records
        if(installmentList.size() > 0){
            //insert installmentList;
            i=0;
            Database.SaveResult[] installmentSRList = Database.insert(installmentList, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : installmentSRList) {
                if (!sr.isSuccess()){
                    // Operation failed, so get all errors      
                    String Errors = generatedCSVErrorMap.get(rowKeyMap[i]);           
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('installment fields that affected this error: ' + err.getFields());
                        Errors += ', ' + err.getFields() + '[ ' + err.getMessage() + ' ]';
                    }
                    generatedCSVErrorMap.put(rowKeyMap[i], Errors);
                }
                i++;
            }
        }
        
        // call queueable for PI form send to azure
        System.debug('depoIDListForPI => ' + depoIDListForPI);
        System.enqueueJob( new EI_PICetificateToAzureQueueable(depoIDListForPI) );
    }
    
    public void finish(Database.BatchableContext context) {
        generatedCSVFile = csvHeaders + ', Errors \n';
        totalTenancies = csvFileRecords.size();
        totalFailures = 0;
        String fileRow = '';
        List<API_Service__mdt> templateMetaData;
        Integer templateId ;
        String customMetaDataLabel ;
        String subject ;
        System.debug('csvHeaders => ' + csvHeaders);
        System.debug('csvFileRecords => ' + csvFileRecords);
        System.debug('rowKeyMapList => ' + rowKeyMapList);
        System.debug('generatedCSVRowMap => ' + generatedCSVRowMap);
        System.debug('generatedCSVErrorMap => ' + generatedCSVErrorMap);
        
        for(integer i=0; i<rowKeyMapList.size(); i++){
            fileRow = '';
            System.debug('rowKeyMapList['+i+'] => ' + rowKeyMapList[i]);
            System.debug('generatedCSVRowMap['+i+'] => ' + generatedCSVRowMap.get(rowKeyMapList[i]));
            System.debug('generatedCSVErrorMap['+i+'] => ' + generatedCSVErrorMap.get(rowKeyMapList[i]));
            fileRow = generatedCSVRowMap.get(rowKeyMapList[i]) +','+ generatedCSVErrorMap.get(rowKeyMapList[i]);
            generatedCSVFile = generatedCSVFile + fileRow + '\n';
            if(generatedCSVErrorMap.get(rowKeyMapList[i]) != ''){
                System.debug('');
                totalFailures++;
            }
        }
        System.debug('generatedCSVFile => ' + generatedCSVFile);
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        System.debug('csvBlob => ' + csvBlob);
        System.debug('csvBlob length=> ' + csvBlob.size());
        System.debug('csvBlob Base64 => ' + EncodingUtil.base64Encode(csvBlob));
        String errorsStr = String.valueOf(generatedCSVErrorMap.values()).replaceAll(', ' , '');
        System.debug('generatedCSVErrorMap.values()Boolean => ' + errorsStr + (errorsStr == '()'));
        System.debug('generatedCSVErrorMap.values().size() => ' + generatedCSVErrorMap.values().size());

        System.debug('totalFailures => ' + totalFailures);
        if(totalFailures == 0){ //errorsStr == '()'
            //templateMetaData = EI_SDS_BulkImportDepositsBatchHelper.metaDataListbyLabel('BulkUploadSucessful');
            templateId = 3312812; //Integer.valueof(templateMetaData[0].Template_Id__c);
            customMetaDataLabel = 'BulkUploadSucessful';
            subject = 'Bulk Upload Sucessful';
            statusOfValidate = 'Successful';
        }
        else if(totalFailures > 0 && totalFailures != totalTenancies){ 
            //templateMetaData = EI_SDS_BulkImportDepositsBatchHelper.metaDataListbyLabel('BulkUploadFailed');
            templateId = 3312885; // Integer.valueof(templateMetaData[0].Template_Id__c);
            customMetaDataLabel = 'BulkUploadFailed';
            subject = 'Bulk Upload Failed';
            statusOfValidate = 'Partial success';
        }
        else if(totalFailures == totalTenancies){
            //templateMetaData = EI_SDS_BulkImportDepositsBatchHelper.metaDataListbyLabel('BulkUploadFailed');
            templateId = 3312885; //Integer.valueof(templateMetaData[0].Template_Id__c);
            customMetaDataLabel = 'BulkUploadFailed';
            subject = 'Bulk Upload Failed';
            statusOfValidate = 'Failed';
        }
        
        /*
        HttpRequest req = new HttpRequest();
        //List<API_Service__mdt> mailJetSettings = EI_SDS_BulkImportDepositsBatchHelper.metaDataListbyLabel('mailJetSDS'); 
        String endPoint = 'https://api.mailjet.com/v3.1/send'; //String endPoint = mailJetSettings[0].EndPoint_URL__c;
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setHeader('Content-Type','application/text'); 
        String username = '149e22044add6860160c56c12a500708';  // String username = mailJetSettings[0].Username__c; 
        String password = '3bc9ecf441468a0dee61982308eb7fb7';  // String password = mailJetSettings[0].Password__c;
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);       
        System.debug('authorizationHeader : ' + authorizationHeader);
        req.setHeader('Authorization', authorizationHeader); 
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();     
        gen.writeFieldName('Messages');
        gen.writeStartArray();
        gen.writeStartObject(); 
        
        gen.writeFieldName('From');
        gen.writeStartObject();
        gen.writeStringField('Email', 'adr@safedepositsscotland.com' ); // String.valueof(templateMetaData[0].From_Address__c)
        gen.writeStringField('Name', 'SafeDeposit Scotland' );
        gen.writeEndObject();
        
        gen.writeFieldName('To');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('Email', currentUser.Email);
        gen.writeStringField('Name', currentUser.Name);
        gen.writeEndObject();      
        gen.writeEndArray();
        
        gen.writeNumberField('TemplateID', templateId);
        gen.writeBooleanField('TemplateLanguage', true);
        gen.writeStringField('Subject', subject);
        
        gen.writeFieldName('Variables');       
        gen.writeStartObject();  
        gen.writeStringField('date', Datetime.now().format('dd-MM-yyyy'));
        gen.writeStringField('name', currentUser.Name);
        gen.writeStringField('Bulk_payment_reference_number', BulkNumber);
        gen.writeStringField('Number_of_deposits_in_upload', String.valueOf(csvFileRecords.size()));
        gen.writeStringField('Upload_Name', FileName);
        gen.writeEndObject(); 
        
        gen.writeFieldName('Attachments');
        gen.writeStartArray();
        gen.writeStartObject(); 
        gen.writeStringField('ContentType', 'data:text/csv;charset=utf-8'); 
        gen.writeStringField('Filename', 'TenantsInserted.csv');
        gen.writeStringField('Base64Content', EncodingUtil.base64Encode(csvBlob));
        gen.writeEndObject();
        gen.writeEndArray();
        
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonData = gen.getAsString(); 
        System.debug('jsonData- ' + jsonData);
        
        req.setBody(jsonData);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody()); 
        */
        
        String azureLink = EI_SDS_BulkImportDepositsBatchHelper.uploadURLtoAzure(csvBlob, FileName, String.valueOf(csvBlob.size()), 'data:text/csv;charset=utf-8',
                                                              totalTenancies, totalTenants, totalLandlords, totalFailures, 
                                                              statusOfValidate, contactId, accountID);
        String azureFileName = azureLink.substringBetween('evidence/', '?');
        
        // Newly added code for Utility mailjet START 
        List<EI_SDS_MailJetUtilityCls.EmailWrapper> emailWrapperList = new List<EI_SDS_MailJetUtilityCls.EmailWrapper>();
        Date todayDate = System.today();
        String todayStr = todayDate.day()+'/'+todayDate.month()+'/'+todayDate.year();
        // Newly added code for Utility mailjet END 
        
        // Newly added code for adding recipients, variables, template name, Subject START 
        List<EI_SDS_MailJetUtilityCls.recipient> emailRecipientList = new List<EI_SDS_MailJetUtilityCls.recipient>();
        List<EI_SDS_MailJetUtilityCls.attachmentWrapper> attachmentWrapperList = new List<EI_SDS_MailJetUtilityCls.attachmentWrapper>();
        Map<String, String> variableMap = new Map<String, String>();
        
        emailRecipientList.add(new EI_SDS_MailJetUtilityCls.recipient(currentUser.Email, currentUser.Name, 
                                                                       currentUser.contactId, currentUser.contactId));
        
        attachmentWrapperList.add(new EI_SDS_MailJetUtilityCls.attachmentWrapper('data:text/csv;charset=utf-8',FileName, EncodingUtil.base64Encode(csvBlob)));
        
        variableMap.put('date',todayStr);
        variableMap.put('name',currentUser.Name);
        variableMap.put('Bulk_payment_reference_number',BulkNumber);
        variableMap.put('Number_of_deposits_in_upload',String.valueOf(csvFileRecords.size()));
        variableMap.put('Upload_Name',FileName);
        
        emailWrapperList.add(new EI_SDS_MailJetUtilityCls.EmailWrapper(JSON.serialize(emailRecipientList), variableMap, 
                                                                        customMetaDataLabel, subject
                                                                       ));
        
        // Newly added code for adding recipients, variables, template name, Subject END 
        
        // Newly added code for Sending Email through MailJet Utility Class START
        if(emailWrapperList.size()>0) {
            EI_SDS_MailJetUtilityCls.sendEmailFromBatchWithAttachments(JSON.serialize(emailWrapperList), attachmentWrapperList); 	  
        } 
        
        EI_SDS_BulkImportDepositsBatchHelper.insertNewBulkImport(FileName, azureFileName, azureLink, totalTenancies, totalTenants, totalLandlords, totalFailures, 
                            statusOfValidate, contactId, accountID);
        
        // Newly added code for Sending Email through MailJet Utility Class END
        
       /* Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        //Blob csvBlob = blob.valueOf(generatedCSVFile);
        String csvName = 'sentCSVofTenants.csv';
        csvAttachment.setFileName(csvName);
        csvAttachment.setBody(csvBlob);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'vidhiagrawal29@gmail.com'};
        String subject = 'Tenants Inserted contained in CSV';
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody('Hello \n PFA of CSV data inserted. \n Regards Vidhi');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
		*/
    }
    
}