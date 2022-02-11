public class EI_SDS_BulkImportDepositsBatchHelper {
    
    public static List<API_Service__mdt> metaDataListbyLabel(String metaDataLabel){
        List<API_Service__mdt> metaDataList = [SELECT EndPoint_URL__c, Username__c, Password__c, From_Name__c, From_Address__c,
                                               Template_Id__c, Scheme_Signatory__c, Scheme_Address__c,Scheme_Bank_Account_Number__c,
                                               Scheme_Sort_Code__c,Scheme_Bank_Name__c, Label
                                               FROM API_Service__mdt 
                                               WHERE QualifiedApiName=:metaDataLabel];
        return metaDataList;
    }
    
    public static List<contact> savelandlord(String branchId,String salutation, String firstname, String lastname, String email,
                                             string phoneCode, string phone, string companyName, string companyPhoneCode, string companyPhone,
                                             String landlinePhone, boolean isOrguser,
                                             string street, string city, string postcode, string country,
                                             string county, string LandRegNumber, String LandRegStatus, user userrec)
    {
        Account Acc;
        contact con;
        List<contact> contactlist = new List<contact>();
        string contactid;
        //string name;
        Id AccountRecordTypeId;
        
        String fullNameForSearch = firstName.trim() +' '+ lastName.trim();
        Account duplicateAccount ;
        Contact duplicateContact ;
        boolean isCreateContactOnly = false;
        if(isOrguser){
            AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
            List<List<Account>> accSearchList = [FIND :companyName IN 
                                                 ALL FIELDS 
                                                 RETURNING  
                                                 Account(ID, Name, recordtypeId WHERE Email__c=:email.trim() OR PersonEmail=:email.trim()) ];
            
            List<List<Contact>> conSearchList = [FIND :fullNameForSearch IN 
                                                 ALL FIELDS 
                                                 RETURNING  
                                                 Contact(ID, Name, Account.recordtypeId, AccountId WHERE Email=:email.trim()) ];
            
            if(accSearchList[0].size() > 0){ // check duplicate Account size
                List<Account> accList = accSearchList[0];
                duplicateAccount = accList[0];
                
                if(duplicateAccount.recordtypeId == AccountRecordTypeId){ // compare recordtype of duplicate and new Account
                    if(conSearchList[0].size() > 0){  // check duplicate Contact size
                        List<Contact> conList = conSearchList[0];
                        duplicateContact = conList[0];
                        
                        if(duplicateContact.Account.recordtypeId == AccountRecordTypeId){ // compare recordtype of duplicate and new Account
                            if(duplicateAccount.Id == duplicateContact.AccountId){ // check duplicate Acc and con are related to each other or not
                                duplicateAccount = [Select Id, PersonContactId, name, Associated_To__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, Phone, Email__c, PersonEmail
                                                    From Account Where Id =:accList[0].Id limit 1];

                                duplicateContact  = [Select Id, AccountId, Salutation, FirstName, lastname, email, Phone_Code__c, Phone, MailingStreet, MailingCity, MailingPostalCode, MailingCountry, MailingState
                                                    From Contact Where Id =:conList[0].Id limit 1];
                            }
                        }else{ 
                            duplicateAccount = [Select Id, PersonContactId, name, Associated_To__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, Phone, Email__c, PersonEmail
                                                From Account Where Id =:accList[0].Id limit 1];
                            
                            isCreateContactOnly = true;
                        }
                    }
                    else{
                        duplicateAccount = [Select Id, PersonContactId, name, Associated_To__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, Phone, Email__c, PersonEmail
                                            From Account Where Id =:accList[0].Id limit 1];
                        
                        isCreateContactOnly = true;
                    }
                }
                if(isCreateContactOnly){
                    con = new contact(AccountId = duplicateAccount.id, Salutation = salutation, FirstName = firstname,Account_Status__c= 'Active',
                                      lastname = lastname, email = email, Phone_Code__c = phoneCode, Phone = phone, MailingStreet = street,
                                      MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,
                                      MailingState = county, LandLord_Registration_Number__c = LandRegNumber, 
                                      LandLord_Registration_Status__c = LandRegStatus,Branch__c = branchId);
                    insert con;
                }
             } 
            else{
                Acc = new Account(name = companyName, Phone_Code__c = companyPhoneCode, Phone = companyPhone, RecordTypeId = AccountRecordTypeId, Email__c = email,
                                  Parent_person_account__c = userrec.accountId, OwnerId = userrec.account.ownerid,BillingStreet = street,
                                  BillingCity = city,BillingPostalCode = postcode,BillingCountry = country,BillingState = county);
                
                insert acc;
                con = new contact(AccountId = Acc.id, Salutation = salutation, FirstName = firstname,Account_Status__c= 'Active',
                                  lastname = lastname, email = email, Phone_Code__c = phoneCode, Phone = phone, MailingStreet = street,
                                  MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,
                                  MailingState = county, LandLord_Registration_Number__c = LandRegNumber, 
                                  LandLord_Registration_Status__c = LandRegStatus,Branch__c = branchId);
                insert con;
            }
        }
        else{
            AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId();
            List<List<Contact>> searchList = [FIND :fullNameForSearch IN 
                                              ALL FIELDS 
                                              RETURNING  
                                              Contact(ID, Name, Account.recordtypeId WHERE Email=:email.trim()) ];                        
            if(searchList[0].size() > 0){ 
                List<Contact> conList = searchList[0];
                duplicateContact = conList[0];
                
                if(duplicateContact.Account.recordtypeId == AccountRecordTypeId){
                    System.debug('searchList => ' + duplicateContact);
                    
                    duplicateContact  = [Select Id, AccountId, Salutation, FirstName, lastname, email, Phone_Code__c, Phone, MailingStreet, MailingCity, MailingPostalCode, MailingCountry, MailingState
                                                    From Contact Where Id =:conList[0].Id limit 1];
                    
                    duplicateAccount = [Select Id, PersonContactId, name, Associated_To__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, Phone, Email__c, PersonEmail
                                        From Account Where PersonContactId =:duplicateContact.Id limit 1];
                }
                else{
                    Acc = new Account();
                    Acc.FirstName = firstname;
                    Acc.LastName = lastname;
                    Acc.Salutation = salutation;
                    acc.OwnerId = userrec.account.ownerid;
                    Acc.PersonEmail = email;
                    Acc.Email__c = email;
                    Acc.PersonHomePhone = landlinePhone;
                    Acc.Phone_Code__pc = phoneCode;
                    Acc.Phone = phone;
                    Acc.RecordTypeId = AccountRecordTypeId;
                    Acc.Parent_person_account__c = userrec.accountId;
                    acc.BillingStreet = street;
                    acc.BillingCity = city;
                    acc.BillingPostalCode = postcode;
                    acc.BillingCountry = country;
                    acc.BillingState = county;
                    acc.PersonMailingStreet = street;
                    acc.PersonMailingCity = city;
                    acc.PersonMailingPostalCode = postcode;
                    acc.PersonMailingCountry = country;
                    acc.PersonMailingState = county;
                    acc.LandLord_Registration_Number__pc = LandRegNumber;
                    acc.LandLord_Registration_Status__pc = LandRegStatus;
                    acc.Account_Status__pc= 'Active';
                    acc.Branch__pc = branchId;
                    insert acc;
                    con = [Select id,Branch__c,AccountId,firstName,MailingStreet,MailingCity,MailingCountry,MailingState,MailingPostalCode,Phone,Email, lastName from Contact where AccountId =: acc.id];
                }
            }
        }
            
        try{
            if (isOrguser){
                AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                Acc = new Account(name = companyName, Phone_Code__c = companyPhoneCode, Phone = companyPhone, RecordTypeId = AccountRecordTypeId, Email__c = email,
                                  Parent_person_account__c = userrec.accountId, OwnerId = userrec.account.ownerid,BillingStreet = street,
                                  BillingCity = city,BillingPostalCode = postcode,BillingCountry = country,BillingState = county);
                
                insert acc;
                con = new contact(AccountId = Acc.id, Salutation = salutation, FirstName = firstname,Account_Status__c= 'Active',
                                  lastname = lastname, email = email, Phone_Code__c = phoneCode, Phone = phone, MailingStreet = street,
                                  MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,
                                  MailingState = county, LandLord_Registration_Number__c = LandRegNumber, 
                                  LandLord_Registration_Status__c = LandRegStatus,Branch__c = branchId);
                insert con;
                contactid = con.id;
            } 
            else{
                AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId();
                Acc = new Account();
                Acc.FirstName = firstname;
                Acc.LastName = lastname;
                Acc.Salutation = salutation;
                acc.OwnerId = userrec.account.ownerid;
                Acc.PersonEmail = email;
                Acc.Email__c = email;
                Acc.PersonHomePhone = landlinePhone;
                Acc.Phone_Code__pc = phoneCode;
                Acc.Phone = phone;
                Acc.RecordTypeId = AccountRecordTypeId;
                Acc.Parent_person_account__c = userrec.accountId;
                acc.BillingStreet = street;
                acc.BillingCity = city;
                acc.BillingPostalCode = postcode;
                acc.BillingCountry = country;
                acc.BillingState = county;
                acc.PersonMailingStreet = street;
                acc.PersonMailingCity = city;
                acc.PersonMailingPostalCode = postcode;
                acc.PersonMailingCountry = country;
                acc.PersonMailingState = county;
                acc.LandLord_Registration_Number__pc = LandRegNumber;
                acc.LandLord_Registration_Status__pc = LandRegStatus;
                acc.Account_Status__pc= 'Active';
                acc.Branch__pc = branchId;
                insert acc;
                con = [Select id,Branch__c,AccountId,firstName,MailingStreet,MailingCity,MailingCountry,MailingState,MailingPostalCode,Phone,Email, lastName from Contact where AccountId =: acc.id];
                
                //   update con;
                //   contactid = [select id,PersonContactId from Account where id=:acc.id].PersonContactId;
                
            }
            contactlist.add(con);
            return contactlist;
        } catch (exception e){
            return null;
        }
    }
    
    public static string getPropertyRegNumber(string PropertyId,string allLandlordRegNumber)
    {
        string propertyRegNumber ='';
        Property__c propRecord =[select id,name,Local_Authority_Area__c,Postal_Code__c,City__c,County__c
                                 from Property__c where id=:PropertyId];
        list<Area_Code_For_Landlord__mdt> metadataList = [select id,MasterLabel,Local_Authority_Area__c,Postal_Code__c,Identifying_Code__c
                                                          from Area_Code_For_Landlord__mdt];
        Map<string,string> metadataMapLable = new map<string,string>();
        Map<string,string> metadataMapAdminArea = new map<string,string>();
        for(Area_Code_For_Landlord__mdt mdt : metadataList )
        {
            metadataMapLable.put(mdt.MasterLabel,mdt.Identifying_Code__c);
            metadataMapAdminArea.put(mdt.Local_Authority_Area__c,mdt.Identifying_Code__c);            
        }
        
        
        if(allLandlordRegNumber =='')
        {
            return propertyRegNumber;
        }
        else
        {
            string identificationCode ='';
            if(metadataMapAdminArea.containsKey(propRecord.Local_Authority_Area__c))
            {
                identificationCode= String.valueOf(metadataMapAdminArea.get(propRecord.Local_Authority_Area__c));
            }
            else if(metadataMapLable.containsKey(propRecord.Local_Authority_Area__c))
            {
                identificationCode= String.valueOf(metadataMapLable.get(propRecord.Local_Authority_Area__c));
            }
            else if(metadataMapAdminArea.containsKey(propRecord.City__c))
            {
                identificationCode= String.valueOf(metadataMapAdminArea.containsKey(propRecord.City__c));                
            }
            else if(metadataMapLable.containsKey(propRecord.City__c))
            {
                identificationCode= String.valueOf(metadataMapLable.containsKey(propRecord.City__c)); 
            }
            
            if(identificationCode =='')
            {
                propertyRegNumber ='';
            }
            else
            {
               list<string> landRegList = allLandlordRegNumber.split(',');
                for(string s:landRegList)
                {
                    if(s.contains(identificationCode))
                    {
                        propertyRegNumber = s;
                    }
                }
            }
            
        }
        return propertyRegNumber;
    }
    
    public static Property__c checkDuplicateProperty(Property__c property){
        
        List<Property__c> propertyList = [select id,Name,Property_Owner__c ,Street__c,City__c,County__c,Postal_Code__c,Country__c,
                (select id,Name, Property__r.Street__c,Property__r.City__c,Property__r.County__c,Property__r.Postal_Code__c,
                 Property__r.Country__c,Property__c,Relation_to_Property__c,Contact__r.name,Property_Address__c 
                 from Property_Allocations__r ) //where Relation_to_Property__c='Primary Landlord'
            from Property__c  where createdById = :UserInfo.getUserId() 
            AND Street__c =: property.Street__c AND City__c =: property.City__c AND Postal_Code__c =: property.Postal_Code__c ];
        
        if(propertyList.size() > 0){
            return propertyList[0];
        }else{
            return null;    
        }	
    }
    
    public static Property__c addNewProperty(String HouseNo, string street, string city, string postcode, string country, string county,
                                             String LocalAuthorityArea, String branchId, list<contact> primaryLandord, list<contact> jointlandlord, user userrec)
    {
        Property__c property = new Property__c();
        try{
            property.House_No__c = HouseNo;
            property.Street__c = street;
            property.City__c = city;
            property.Postal_Code__c = postcode;
            property.Country__c = country;
            property.County__c = county;
            
            if(branchId != null){
                property.Branch__c =   branchId;
            }
            List<Contact> primaryLand = new List<Contact>();
            List<Contact> jointLand = new List<Contact>();
            
            if(primaryLandord.size()>0){
                primaryLand= [Select AccountId,Landlord_Registration_Number__c,LandLord_Registration_Status__c from Contact where id in: primaryLandord];
            }
            if(jointlandlord.size()>0){
                jointLand= [Select id,AccountId,Landlord_Registration_Number__c,LandLord_Registration_Status__c from Contact where id in: jointlandlord];
            }
            
            if (userrec.User_Type__c == 'Agent'){
                property.Property_Owner__c = primaryLandord[0].AccountId;
            }else{
                property.Property_Owner__c = userrec.AccountId; 
            }
            
            Map<String, String> pstAreaCode=  new Map<String, String>();
            for(Area_Code_For_Landlord__mdt areCode : [select id,Local_Authority_Area__c, Postal_Code__c from Area_Code_For_Landlord__mdt where Postal_Code__c=: property.Postal_Code__c]){
                pstAreaCode.put(areCode.Postal_Code__c, areCode.Local_Authority_Area__c);
            }
            property.Property_status__c = 'Active';
            if(LocalAuthorityArea == '' || LocalAuthorityArea == null){
                property.Local_Authority_Area__c = pstAreaCode.get(property.Postal_Code__c);
            }
            
            insert property;
            
            list<Property_Allocation__c> prAllocation = new list<Property_Allocation__c>();
            if (userrec.User_Type__c == 'Agent'){
                prAllocation.add(new Property_Allocation__c(Contact__c = primaryLand[0].id, Property__c = property.id, Relation_to_Property__c = 'Primary Landlord'));
            } else{
                prAllocation.add(new Property_Allocation__c(Contact__c = userrec.contactid,
                                                            Landlord_Registrataion_Status__c =userrec.contact.LandLord_Registration_Status__c,
                                                            Landlord_Registration_Number__c='', 
                                                            Property__c = property.id, Relation_to_Property__c = 'Primary Landlord'));
            }
            if (jointlandlord.size() > 0){
                prAllocation.add(new Property_Allocation__c(Contact__c = jointLand[0].id,Landlord_Registrataion_Status__c =jointLand[0].LandLord_Registration_Status__c,Landlord_Registration_Number__c='', Property__c = property.id, Relation_to_Property__c = 'Joint Landlord'));
            }
            
            if (prAllocation.size() > 0){
                insert prAllocation;
            }
            
            return property;
        }catch(Exception e){
            return null;
        }
    }
    
    public static string getBulkNumber(){
        String memberid;
        MemberId__c myMemberid = MemberId__c.getInstance('MemberID');
        string mbrid =string.valueof(myMemberid.BulkNumber__c);
        mbrid = mbrid.substringBeforeLast('.');
        integer needaddzero = 5-mbrid.length();
        string prefix ='0';
        for(integer i =1; i<needaddzero;i++){
            prefix = prefix+'0';
        }
        memberid = 'BLK'+prefix+mbrid;
        String BulkNumber = memberid+'SDS';
        updateBulkNumberSetting(BulkNumber);
        return BulkNumber;
    }

    public static void updateBulkNumberSetting(String referenceNumber){
        Integer BLKNumber;
        if(String.isNotBlank(referenceNumber)){
            referenceNumber = referenceNumber.replace('BLK','');
            referenceNumber = referenceNumber.replace('SDS','');
            BLKNumber = Integer.valueOf(referenceNumber);
            MemberId__c myMemberid = MemberId__c.getInstance('MemberID');
            myMemberid.BulkNumber__c = BLKNumber+1;
            update myMemberid;
        }
    }
                
    public static deposit__c addNewDeposit(String branchId, Integer noOfTenants, Decimal rentAmount, Decimal depositAmount, Decimal amountToProtect, 
                                           Date depositRecievedDate, Date tenancyStartDate, property__c property, String BulkNumber, user userrec)
    {
        try{
            ID depositRecordTypeId = Schema.SObjectType.Deposit__c.getRecordTypeInfosByDeveloperName().get('SDS_Deposit').getRecordTypeId();
            
            Deposit__c depositrec = new Deposit__c(recordtypeId = depositRecordTypeId,Branch__c=branchId,Number_of_Tenants__c = noOfTenants, 
                                                   Rent_Amount__c = rentAmount, Deposit_Amount__c = depositAmount, Protected_Amount__c = amountToProtect, 
                                                   Date_Deposit_Received__c = depositRecievedDate, Start_Date__c = tenancyStartDate, 
                                                   Property__c = property.id, Customer__c = userrec.accountid, Scheme__c = System.Label.SDSschemeId);
            insert depositrec;
            
            insert new Installment__c(Status__c = 'Pending', Deposit__c = depositrec.Id, Installment_Type__c = 'Receivable', 
                                      Amount__c = depositrec.Protected_Amount__c, BLK_Number__c = BulkNumber);
            
            if(String.isNotBlank(BulkNumber) && BulkNumber.contains('BLK')){
                updateBulkNumberSetting(BulkNumber);
            }
            return depositrec;   
        }catch (exception e){
            return null;
        }
    }
    
    public static list<Deposit_Allocation__c> addtenantList(List<Account> tenantList, Set<String> emailIds){ //, Deposit__c depositrec
        try{
            List<Account> accListToInsert = new List<Account>();
            Map<String,Id> mapOfemailVsAccId = new Map<String,Id>();
            Map<String,String> mapOfemailVsAccName = new Map<String,String>();
            List<Id> tenantid = new List<Id>();
            list<Deposit_Allocation__c> depositAllocationlist = new list<Deposit_Allocation__c>();
            
            if(!emailIds.isEmpty() ){
                for(User tentUser :  [SELECT email, Profile.Name ,Contact.AccountId,Contact.Name
                                      FROM User WHERE email IN : emailIds and Profile.Name = 'Tenant' and ContactId != null])
                {
                    if(!mapOfemailVsAccId.containsKey(tentUser.email)) {     
                        mapOfemailVsAccId.put(tentUser.email.trim(),tentUser.Contact.AccountId);
                        mapOfemailVsAccName.put(tentUser.email.trim(),tentUser.Contact.Name);
                    }
                }
                
            }            
            
            if (tenantList.size() > 0){
                for(Account acc : tenantList){
                    String tenantName = acc.firstName +' '+acc.lastname;
                    //System.debug(mapOfemailVsAccId.get(acc.email__c.trim()) + ' => ' + tenantName);
                    if(mapOfemailVsAccId.size() > 0 && mapOfemailVsAccName.size() > 0 && mapOfemailVsAccId.containsKey(acc.email__c.trim()) && mapOfemailVsAccName.get(acc.email__c.trim()) == tenantName){
                        //if(mapOfemailVsAccId.containsKey(acc.email__c.trim()) && mapOfemailVsAccName.get(acc.email__c.trim()) == tenantName){
                            System.debug('if true' + mapOfemailVsAccId.get(acc.email__c.trim()));
                            tenantid.add(mapOfemailVsAccId.get(acc.email__c.trim())); 
                        //}
                    }else{
                        System.debug('else true' + acc);
                        accListToInsert.add(acc); 
                    }
                }
            }
            System.debug('accListToInsert => ' + accListToInsert);
            if(accListToInsert.size() > 0){   
                Database.SaveResult[] recid = Database.insert(accListToInsert);
                for (Database.SaveResult sr : recid){
                    if (sr.isSuccess()){
                        System.debug('accListToInsert sr => ' + sr.getId());
                        tenantid.add(sr.getId());
                    }
                }
            }
            System.debug('tenantid => ' + tenantid);
            list<account> acclist = [select id, PersonContactId
                                     from Account
                                     where id in :tenantid];
            
            System.debug('acclist => ' + acclist);
            
            id depositId ;
            for (Account acc : acclist){
               // depositAllocationlist.add(new Deposit_Allocation__c(Deposit_Holder__c = acc.id, Contact__c = acc.PersonContactId, 
               //                                                     Is_Lead__c = false, Role__c = 'Tenant', Deposit__c = depositrec.id));            
               System.debug('depositId => ' + depositId);
                depositAllocationlist.add(new Deposit_Allocation__c(Deposit_Holder__c = acc.id, Contact__c = acc.PersonContactId, 
                                                                    Is_Lead__c = false, Role__c = 'Tenant', Deposit__c = depositId));            
                System.debug('depositAllocationlist => ' + depositAllocationlist);
            }
            //insert depositAllocationlist;
            return depositAllocationlist;
        }catch (exception e){
            System.debug('exception error msg => ' + e.getMessage() + ' line no => ' + e.getLineNumber());
            return null;
        }
    }
    
    
    public class propertyWrapper{
        @AuraEnabled
        public String HouseNo{ get; set; }
        @AuraEnabled
        public String street{ get; set; }
        @AuraEnabled
        public String city{ get; set; }
        @AuraEnabled
        public String postcode{ get; set; }
        @AuraEnabled
        public String country{ get; set; }
        @AuraEnabled
        public String county{ get; set; }
        @AuraEnabled
        public String LocalAuthorityArea{ get; set; }
        @AuraEnabled
        public String primaryLandordID{ get; set; }
        @AuraEnabled
        public String jointLandlordId{ get; set; }
        @AuraEnabled
        public String userType{ get; set; }
        @AuraEnabled
        public String userAccountId{ get; set; }
        @AuraEnabled
        public String userContactId{ get; set; }
        @AuraEnabled
        public String user{ get; set; }
    }
    public class depositWrapper{
        @AuraEnabled
        public String branchId{ get; set; }
        @AuraEnabled
        public Integer noOfTenants{ get; set; }
        @AuraEnabled
        public Decimal rentAmount{ get; set; }
        @AuraEnabled
        public Decimal depositAmount{ get; set; }
        @AuraEnabled
        public Decimal amountToProtect{ get; set; }
        @AuraEnabled
        public Date depositRecievedDate{ get; set; }
        @AuraEnabled
        public Date tenancyStartDate{ get; set; }
        @AuraEnabled
        public Id propertyId{ get; set; }
        @AuraEnabled
        public String BulkNumber{ get; set; }
        @AuraEnabled
        public Id userAccountId{ get; set; }
    }

    /*public static String storageName = '';
    public static String storageContainer = '';
    public static String storageKey = '';
    public static String storageUrl = '';
    public static String blobName = '';
    public static String requestURL = '';
    public static String sharedKey = '';
    public static String fileLength = '';
    public static String fileType = 'data:text/csv;charset=utf-8';
    public static String timestamp;
    public static String formattedDate;
    */
    
    public final static string VERSION = '2015-12-11';
    public final static string BLOB_TYPE = 'BlockBlob';
    
    public static Boolean isRunningOnSandbox() {
        Boolean isRunningOnSandbox = [SELECT IsSandbox FROM Organization].IsSandbox;
        return isRunningOnSandbox;
    }
    
    public static Azure_Storage_Credentials_per_Scheme__mdt getAzureMetadata(String scheme) {
        Azure_Storage_Credentials_per_Scheme__mdt settings;
        try {
            settings = [
                    SELECT Account_Name_Production__c,
                            Account_Name_Sandbox__c,
                			Container_Name_Production__c,
                			Container_Name_Sandbox__c,
                            Endpoint_Production__c,
                            Endpoint_Sandbox__c,
                            Secure_URI_Production__c,
                            Secure_URI_Sandbox__c,
                            Storage_Key_Production__c,
                            Storage_Key_Sandbox__c
                    FROM Azure_Storage_Credentials_per_Scheme__mdt
                    WHERE Label = :scheme
            ];
        }
        catch(QueryException exc) {
            //throw new AzureFunctionFileUploadServiceException('No Azure Upload Function Credentials found for scheme: ');
        }
        return settings;
    }
    
    public static string  generateSASToken(string filename,string signedpermissions,string scheme, String timestamp){
        Azure_Storage_Credentials_per_Scheme__mdt settings = getAzureMetadata(scheme);
        Boolean isRunningOnSandbox = isRunningOnSandbox();
        String storageName = isRunningOnSandbox ? settings.Account_Name_Sandbox__c : settings.Account_Name_Production__c;
        String storageContainer = isRunningOnSandbox ? settings.Container_Name_Sandbox__c : settings.Container_Name_Production__c;
        String storageKey = isRunningOnSandbox ? settings.Storage_Key_Sandbox__c : settings.Storage_Key_Production__c;
        String storageUrl = isRunningOnSandbox ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c;
        String blobName = '/'+storageName+'/'+storageContainer+'/'+fileName;
        
        Datetime sasExpiry = Datetime.now();
        sasExpiry = sasExpiry.addMinutes(15);
        Datetime sasStart = Datetime.now();
        sasStart = sasStart.addMinutes(-5);
        
        //string signedpermissions = 'd';
        String signedstart = sasStart.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        //string signedexpiry = sasExpiry.formatGMT('YYYY-MM-dd\'T\'HH:mm:ss\'Z\'');
        string signedexpiry ='2031-09-02T15:44:13Z';
        system.debug(' signedexpiry '+signedexpiry);
        string signedservice = 'c';
        String canonicalizedresource = '/blob/'+storageName+'/'+storageContainer+'/'+filename;
        string signedidentifier = '';
        string signedIP = '';
        string signedProtocol = '';
        string signedversion = '2020-08-04';
        string rscc='';
        string rscd='';
        string rsce='';
        string rscl='';
        string rsct='';
        string signedResource ='b';
        string signedSnapshotTime ='';
        
        string stringToSign = signedpermissions + '\n' +  
            signedstart + '\n' +  
            signedexpiry + '\n' +  
            canonicalizedResource + '\n' +  
            signedIdentifier + '\n' +  
            signedIP + '\n' +  
            signedProtocol + '\n' +  
            signedVersion + '\n' +  
            signedResource + '\n' +
            signedSnapshotTime + '\n' +
            rscc + '\n' +  
            rscd + '\n' +  
            rsce + '\n' +  
            rscl + '\n' +  
            rsct;
        string signedExpiryEncode = EncodingUtil.urlEncode(signedexpiry, 'UTF-8'); 
        string signedStartEncode = EncodingUtil.urlEncode(signedstart, 'UTF-8'); 
        String sasToken = '';
        Blob unicodeKey = EncodingUtil.base64Decode(storageKey);
        Blob data = Crypto.generateMac('HMACSHA256', Blob.valueOf(stringToSign), unicodeKey);
        system.debug(':::::data--->'+data);
        sasToken = EncodingUtil.base64Encode(data);
        system.debug(':::::sasToken--->'+sasToken);
        sasToken = EncodingUtil.urlEncode(sasToken, 'UTF-8'); 
        system.debug(':::::sasToken1--->'+data);
        String sasTokenString= '?sv=' + signedversion + '&se=' + signedexpiry +'&st='+signedstart+'&sr='+signedservice+'&sp=' + signedpermissions + '&sig=' + sasToken+ '&spr=https';
       
        //string sasURL = 'https://'+storageName+'.blob.core.windows.net/'+storageContainer+'/'+filename+'?'+sasTokenString;
        string sasURL = 'https://'+storageName+'.blob.core.windows.net/'+storageContainer+'/'+timestamp+'-'+filename;
        system.debug('sasURL==>>'+sasURL);
        return sasURL;
    }
    
    public static String getBlobSharedKey(String fileName, String fileLength, String fileType, String formattedDate, String timestamp, 
                                          Azure_Storage_Credentials_per_Scheme__mdt settings, Boolean isRunningOnSandbox )
    {
        System.debug('getBlobSharedKey--->Start');
        String storageName = isRunningOnSandbox ? settings.Account_Name_Sandbox__c : settings.Account_Name_Production__c;
        String storageContainer = isRunningOnSandbox ? settings.Container_Name_Sandbox__c : settings.Container_Name_Production__c;
        String storageKey = isRunningOnSandbox ? settings.Storage_Key_Sandbox__c : settings.Storage_Key_Production__c;
        String blobName = '/'+storageName+'/'+storageContainer+'/'+timestamp+'-'+fileName;
        String signature;

        String stringToSign = 'PUT\n\n\n'+fileLength+'\n\n'+fileType+'\n\n\n\n\n\n\nx-ms-blob-type:BlockBlob\nx-ms-date:'+formattedDate+'\nx-ms-version:2015-12-11\n'+blobName;

        Blob unicodeKey = EncodingUtil.base64Decode(storageKey);
        
        Blob data = Crypto.generateMac('HMACSHA256', Blob.valueOf(stringToSign), unicodeKey);
        signature = EncodingUtil.base64Encode(data);
       
        String sharedKey = 'SharedKey '+storageName+':' + signature;
        return sharedKey;
    }
    
    public static String insertNewBulkImport(String fileName, String azureFileName, String azureLink, 
                                             Integer totalTenancies, Integer totalTenants, Integer totalLandlords, Integer totalFailures, 
                                             String statusOfValidate, 
                                             String contactId, String accountID)  //, List<object> ListOfTenancies
    {
        try { 
            //system.debug('dffff => ' + ListOfTenancies);
            Bulk_Import__c bulkImp = new Bulk_Import__c(Validated_or_Imported_Date__c=System.today(), Is_Validated_Only__c=false, 
                                                        File_Name__c=fileName, 
                                                        Azure_File_Name__c = azureFileName,
                                                        Azure_File_Link__c = azureLink,
                                                        Total_tenancies__c= totalTenancies, 
                                                        Total_Tenants__c = totalTenants,
                                                        Total_Landlords__c = totalLandlords,
                                                        Total_failures__c=totalFailures, Status__c=statusOfValidate, 
                                                        Contact__c=contactId, Account__c=accountID);
            insert bulkImp; 
            System.debug('bulkImp ' + bulkImp);
        } catch(Exception e) {
            System.debug('catch apex ');
            String strError = 'The following exception has occurred: '+e.getMessage();
            System.debug('The following exception has occurred: ' + e.getMessage());
            return strError;
        }
        
        return 'Successful';
    }
    
    public static string uploadURLtoAzure(Blob fileBody, String fileName, String fileLength, String fileType,
                                       Integer totalTenancies, Integer totalTenants, Integer totalLandlords, Integer totalFailures, 
                                       String statusOfValidate, String contactId, String accountID)
    {
        Azure_Storage_Credentials_per_Scheme__mdt settings = getAzureMetadata('SDS');
        Boolean isRunningOnSandbox = isRunningOnSandbox();
        String storageUrl = isRunningOnSandbox ? settings.Secure_URI_Sandbox__c : settings.Secure_URI_Production__c;
        
        fileName = fileName.replaceAll(' ', '');
        Datetime dt = Datetime.now();
        String timestamp = String.valueOf(dt.getTime());
        String formattedDate = dt.formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        
        String requestURL = storageUrl.substringBefore('?')+'/'+timestamp+'-'+fileName;
        String sharedKey = getBlobSharedKey(fileName, fileLength, fileType, formattedDate, timestamp, settings, isRunningOnSandbox);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setHeader('x-ms-blob-type', BLOB_TYPE);
        req.setHeader('x-ms-version', VERSION);
        req.setHeader('x-ms-date', formattedDate);
        req.setHeader('Authorization', sharedKey);
        req.setHeader('Content-Type', fileType);
        req.setHeader('Content-Length', fileLength);
        
        req.setEndpoint(requestURL);
        
        req.setBodyAsBlob(fileBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('Response Body--->'+res.getBody());
        System.debug('Status--->'+res.getStatus());
        system.debug('Data-->'+res.getStatusCode());
        
        string sasTokenString = storageUrl.substringAfter('?');
        system.debug(' sasTokenString '+sasTokenString);
        String azureLink = requestURL+'?'+sasTokenString;
        system.debug(' azureLink '+azureLink);
        String azureFileName = timestamp +'-'+filename;
        system.debug(' azureFileName '+azureFileName);
        return azureLink;
        //insertNewBulkImport(FileName, azureFileName, azureLink, totalTenancies, totalTenants, totalLandlords, totalFailures, 
        //                    statusOfValidate, contactId, accountID);
    }
}