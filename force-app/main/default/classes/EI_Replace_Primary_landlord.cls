public without sharing class EI_Replace_Primary_landlord {

    @AuraEnabled
    public static Map<String, SObject> createlandlord(
        String firstname ,String lastname, String email,string salutation,string phoneCode, string phone,string landlordlegistrationstatus,string LandlordRegistrationNumber,
        string companyName,string companyPhoneCode,string companyPhone, /*string companyEmail,*/boolean isOrguser,string propertyRecId,string depositId,
        string street, string city, string postcode, string country, string county)
        
        
    {
         Map<String, SObject> returnVal = new Map<String, SObject>();
        
        String fullNameForSearch = firstname.trim() + ' ' + lastname.trim();
        System.debug('fullNameForSearch ' + fullNameForSearch);
        list<user> userlistEmail = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                    from user where profile.UserLicense.Name ='Customer Community Login' 
                                    and (email =:email.trim() or username =:email.trim())];
        
        List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
                                              RETURNING Contact(ID, Name WHERE email=:email.trim()
                                              AND CreatedById = :UserInfo.getUserId() 
                                              AND (Account.RecordType.Name = 'Individual Landlord' 
                                                   OR Account.RecordType.Name = 'Corporate Landlord') )];

        if(userlistEmail.size() > 0){
            returnVal.put('Duplicate Email', userlistEmail[0]);
            return returnVal;
            //return 'Duplicate Email';
        }
        else if(searchNameList != null && searchNameList[0].size() > 0){
            returnVal.put('Duplicate Name', searchNameList[0][0]);
            return returnVal;
            //return 'Duplicate Name';
        }
        else{
            list<Property_Allocation__c> newPAlist = new list<Property_Allocation__c>();
            system.debug('line -->11' + propertyRecId);
            //list<Property_Allocation__C> PAlist =  [select id ,Property__c from Property_Allocation__C where Property__c=:Property];
            Property__c  pc = [select id,City__c, County__c,State__c, Country__c, Street__c,District__c, Is_Furnished__c, Land_registry_number__c, Land_registry_number_check__c, Local_authority_registration_details__c, Local_authority_registration_name__c, Local_authority_registration_number__c, No_of_bedrooms__c, No_of_living_rooms__c, Postal_Code__c, Property_Owner__c  from Property__c  where id=:propertyRecId];
            list<Property_Allocation__c> propalllist =[select id,Contact__c, Landlord_Registrataion_Status__c, Landlord_Registration_Number__c,Relation_to_Property__c, Property__c from Property_Allocation__c where Property__c=:propertyRecId and Relation_to_Property__c =:'Primary Landlord' limit 1  ];
            user u = [select id,accountid,account.ownerid,profile.name from user where id = :UserInfo.getUserId() ];
            system.debug('line-->14' + u.profile.name );
            Account Acc;
            contact con;
            Boolean flag;
            Id AccountRecordTypeId;
            if(!propalllist.isempty()){
                if(isOrguser)
                {
                    AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Landlord').getRecordTypeId();
                    acc = new Account(name =companyName,Phone_Code__c = companyPhoneCode, Phone =companyPhone,RecordTypeId=AccountRecordTypeId,Email__c = email,Parent_person_account__c =u.accountId,OwnerId =u.account.ownerid,
                                      BillingStreet = street,BillingCity = city,BillingPostalCode = postcode,BillingCountry = country,BillingState = county );
                    insert acc;
                    
                    con  = new contact (AccountId =Acc.id,Salutation=salutation,FirstName =firstname,Account_Status__c ='Active',
                                        lastname =lastname,email =email, Phone_Code__c = phoneCode, Phone =phone,LandLord_Registration_Status__c=landlordlegistrationstatus,LandLord_Registration_Number__c=LandlordRegistrationNumber,
                                        MailingStreet = street,MailingCity = city,MailingPostalCode = postcode,MailingCountry = country,MailingState = county);
                    insert con;
                    //  flag =true;
                    system.debug('line-->60' + con.id );
                    if( con.id !=null){
                        for( Property_Allocation__c PAL :propalllist  ){
                            Property_Allocation__c newPA = new Property_Allocation__c();
                            newPA.Id = PAL.Id;
                            //  newPA.Property__c = propertyRecId;
                            newPA.Contact__c =con.id;
                            //  newPA.Landlord_Registrataion_Status__c=landlordlegistrationstatus;
                            newPA.Landlord_Registration_Number__c=LandlordRegistrationNumber;
                            newPA.Relation_to_Property__c='Primary Landlord';
                            update newPA;
                            //newPAlist.add(newPA);
                        }
                        //  update  newPAlist;
                    }
                    
                    contact newcon = new contact();
                    newcon.Id = propalllist[0].Contact__c;
                    newcon.Account_Status__c ='Inactive';
                    update newcon;
                }
                else
                {
                    AccountRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Landlord').getRecordTypeId(); 
                    acc = new Account();
                    acc.FirstName = firstname;
                    acc.LastName = lastname;
                    acc.Salutation =salutation;
                    acc.OwnerId =u.account.ownerid;
                    acc.PersonEmail=email;
                    acc.Email__c = email;
                    acc.PersonHomePhone =phone;
                    acc.Phone_Code__pc = phoneCode;
                    acc.Phone = phone;
                    acc.LandLord_Registration_Status__pc=landlordlegistrationstatus;
                    acc.LandLord_Registration_Number__pc=LandlordRegistrationNumber;
                    acc.RecordTypeId  = AccountRecordTypeId;
                    acc.Parent_person_account__c =u.accountId;
                    acc.PersonMailingStreet = street;
                    acc.PersonMailingCity = city;
                    acc.PersonMailingCountry = postcode;
                    acc.PersonMailingCountry = country; 
                    acc.PersonMailingState = county; 
                    acc.Account_Status__pc ='Active';
                    insert acc; 
                    //flag=false;
                    
                    account akon = [select id,PersonContactId from account where id=:acc.id limit 1];
                    system.debug('line-->60' + akon.PersonContactId );
                    if(acc.id !=null){
                        for( Property_Allocation__c PAL :propalllist  ){
                            Property_Allocation__c newPA = new Property_Allocation__c();
                            newPA.Id = PAL.Id;
                            //  newPA.Property__c = propertyRecId;
                            newPA.Contact__c =akon.PersonContactId;
                            //  newPA.Landlord_Registrataion_Status__c=landlordlegistrationstatus;
                            newPA.Landlord_Registration_Number__c=LandlordRegistrationNumber;
                            newPA.Relation_to_Property__c='Primary Landlord';
                            update newPA;
                            //newPAlist.add(newPA);
                        }
                        //  update  newPAlist;
                    }
                    
                    contact newcon = new contact();
                    newcon.Id = propalllist[0].Contact__c;
                    newcon.Account_Status__c ='Inactive';
                    update newcon;
                }
            }
            else{
            }
            returnVal.put('No duplicate', propalllist[0] );
            return returnVal;
            //return propalllist[0].Id;
            
        }
    }
    
    @AuraEnabled
    public static Map<String, String> landlordRegistrationallstatusReplace()
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