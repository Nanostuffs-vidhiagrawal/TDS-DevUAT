public without sharing  class EI_AddNonMemberLandlord {
    
    @AuraEnabled
    public static List<contact> savelandlord(String branchId,String salutation, String firstname, String lastname, String email,
                                      string phoneCode, string phone, string companyName,
                                      string companyPhoneCode, string companyPhone, /*string companyEmail,*/ boolean isOrguser,
                                      string street, string city, string postcode, string country,
                                      string county,string propertyRecId,string LandRegNumber, String LandRegStatus){
                                          user u = [select id, accountid, account.ownerid
                                                    from user
                                                    where id = :UserInfo.getUserId()];
                                          Account Acc;
                                          List<contact> conlist = new List<contact>();
                                          contact con;
                                          string contactid;
                                          string name;
                                          Id AccountRecordTypeId;
                                          try{
                                              if (isOrguser){
                                                  AccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                                                  Acc = new Account(name = companyName, Phone_Code__c = companyPhoneCode, Phone = companyPhone, RecordTypeId = AccountRecordTypeId, Email__c = email,
                                                                    Parent_person_account__c = u.accountId, OwnerId = u.account.ownerid,BillingStreet = street,
                                                                    BillingCity = city,BillingPostalCode = postcode,BillingCountry = country,BillingState = county);
                                                  
                                                  insert acc;
                                                  con = new contact(AccountId = Acc.id, Salutation = salutation, FirstName = firstname,Account_Status__c= 'Active',
                                                                    lastname = lastname, email = email, Phone_Code__c = phoneCode, Phone = phone, MailingStreet = street,
                                                                    MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,
                                                                    MailingState = county, LandLord_Registration_Number__c = LandRegNumber, 
                                                                    LandLord_Registration_Status__c = LandRegStatus,Branch__c = branchId);
                                                  insert con;
                                                  contactid = con.id;
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
                                                  Acc.Phone_Code__pc = phoneCode;
                                                  Acc.Phone = phone;
                                                  Acc.RecordTypeId = AccountRecordTypeId;
                                                  Acc.Parent_person_account__c = u.accountId;
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
                                              conlist.add(con);
                                              if(propertyRecId != null){
                                             String propertyRegNumber = getPropertyRegNumber(propertyRecId,LandRegNumber);
                                              Property_Allocation__c pall = new Property_Allocation__c(Contact__c =con.id,Property__c =propertyRecId,
                                                                                                       Landlord_Registration_Number__c =propertyRegNumber,Landlord_Registrataion_Status__c=LandRegStatus);
                                              insert pall;
                                              }
                                             // Property__c pro = new Property__c(id=propertyRecId,Landlord_Registration_Number__c =propertyRegNumber);
                                              //update pro;
                                              
                                              return conlist;
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
    @AuraEnabled
    public static Property__c getPropertyDetails(string propertyId){
     /*   List<Property__c> propertyRec = [Select id,Local_authority_registration_details__c,(Select id,Property__r.Local_authority_registration_details__c,Landlord_Registration_Number__c from Property_Allocations__r),House_No__c,City__c,Country__c,County__c,District__c,State__c,Street__c,Town__c,Name,Postal_Code__c
                                                    from Property__c where Id =:propertyId limit 1];
        if(propertyRec!=null && !propertyRec.isEmpty()){                                            
       
            return propertyRec[0];
        }
        else{
            return null;
        }*/
        
         List<Property__c> propertyRec = new List<Property__c>();
        List<Property__c> oldpropertyRec = [Select id,(Select id from Property_Allocations__r),Local_authority_registration_details__c,House_No__c,City__c,Country__c,County__c,District__c,State__c,Street__c,Town__c,Name,Postal_Code__c
                                                    from Property__c where Id =:propertyId limit 1];
	
        
        if(propertyId!=null ){
            if(oldpropertyRec[0].Property_Allocations__r.size()>0){
                 
            	oldpropertyRec[0].Local_authority_registration_details__c = '';
                update oldpropertyRec;        
                
            for(Property_Allocation__c prc : [Select id,Property__r.Local_authority_registration_details__c,Landlord_Registration_Number__c, Property__r.id,Property__r.House_No__c,Property__r.City__c,Property__r.Country__c,Property__r.County__c,Property__r.District__c,Property__r.State__c,Property__r.Street__c,Property__r.Town__c,Property__r.Name,Property__r.Postal_Code__c from Property_Allocation__c where Property__r.id =: propertyId]){
                if(prc.Property__r.Local_authority_registration_details__c == null){
                     prc.Property__r.Local_authority_registration_details__c =  prc.Landlord_Registration_Number__c;
                }
                else{
                     prc.Property__r.Local_authority_registration_details__c = prc.Property__r.Local_authority_registration_details__c +', '+ prc.Landlord_Registration_Number__c;
                }
                propertyRec.add(prc.Property__r);
            }
            system.debug('@@'+propertyRec[0]);
            update propertyRec[0];
            return propertyRec[0];
            }
            else{
                return oldpropertyRec[0];
            }
        }
         else{
            return null;
        }
    }
    
    @AuraEnabled
    public static list<Property_Allocation__c> landlordList(string propertyId)
    {
        list<Property_Allocation__c> propertyRec = [select id,Contact__c,Contact__r.FirstName,Contact__r.LastName,
                                                    Contact__r.Email,Contact__r.Phone,Contact__r.LandLord_Registration_Number__c,
                                                    Landlord_Registration_Number__c
                                                    from Property_Allocation__c where Property__c =:propertyId];
        return propertyRec;
    }
    
    @AuraEnabled
    public static Map<String, String> landlordRegistrationStatusList()
    {
        Map<String, String> lanRegStatusList = new Map<String, String>();
        Schema.DescribeFieldResult fieldResultRegStatus = Account.LandLord_Registration_Status__pc.getDescribe();
        List<Schema.PicklistEntry> regStatusValues = fieldResultRegStatus.getPicklistValues();
        for (Schema.PicklistEntry p : regStatusValues){
            lanRegStatusList.put(p.getValue(), p.getLabel());
        }
        return lanRegStatusList;
    }
    
    @AuraEnabled
    public static Map<String, SObject> checkDuplicateRecord(String email, String firstname, String surname){
        Map<String, SObject> returnVal = new Map<String, SObject>();
        
        String fullNameForSearch = firstname.trim() + ' ' + surname.trim();
        System.debug('fullNameForSearch ' + fullNameForSearch);
        list<user> userlistEmail = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                    from user where profile.UserLicense.Name ='Customer Community Login' 
                                    and (email =:email.trim() or username =:email.trim()) ];
        
        List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
                                              RETURNING Contact(ID, Name WHERE email=:email.trim()
                                              AND CreatedById = :UserInfo.getUserId() 
                                              AND (Account.RecordType.Name = 'Individual Landlord' OR Account.RecordType.Name = 'Corporate Landlord') 
                                                               ) ];
		
        if(userlistEmail.size() > 0){
            returnVal.put('Duplicate Email', userlistEmail[0]);
            return returnVal;
            //return 'Duplicate Email';
        }else if(searchNameList[0].size() > 0){
            returnVal.put('Duplicate Name', searchNameList[0][0]);
            return returnVal;
            //return String.valueOf(searchNameList[0]);
        }else{
            User obj = new User();
            returnVal.put('No duplicate', obj );
            return returnVal;
            //return 'No duplicate';
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
}