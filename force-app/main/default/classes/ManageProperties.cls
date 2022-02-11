public without sharing class ManageProperties {  
    @AuraEnabled
    public static Contact archieveLandlord(Contact landlordRec, String status){ 
        system.debug('Status '+Status);
        Contact con = [Select id,Name,LandLord_Registration_Number__c,MailingStreet,MailingCity,MailingPostalCode,MailingState,MailingCountry,Email,Phone from Contact where id =: landlordRec.Id limit 1];
        if(Status == 'Inactive'){
             con.Account_Status__c = 'Inactive';
        }
        else if(Status == 'Active'){
             con.Account_Status__c = 'Active';
        }
    	update con;
	return con;    
    }
      @AuraEnabled
    public static string replacePrimeLandlord(Property__c propRec, Contact conRec, Boolean status){
        try{
              Property_Allocation__c propAll = [Select id,Contact__r.Id,Contact__c from Property_Allocation__c where Property__r.id =: propRec.id and Relation_to_Property__c = 'Primary Landlord'];
        propAll.Contact__c = conRec.Id;
            if(status == false){
       			 update propAll;
           
            
            }
            else{
                   Property_Allocation__c delProp = [Select id,Relation_to_Property__c,Contact__c from Property_Allocation__c where Contact__r.id =: conRec.Id and Relation_to_Property__c != 'Primary Landlord'];
      				delete delProp;
          
                	 update propAll;
            }
            return 'Success';
        }
        catch(DMLException e){
            return e.getMessage();
        }
        
    }
      @AuraEnabled
    public static Property_Allocation__c getJointLand(Property__c propRec){
        List<Property_Allocation__c> conList = new List<Property_Allocation__c>();
        for(Property_Allocation__c prop : [Select id,Relation_to_Property__c,Contact__r.Name,Contact__r.id,Contact__c from Property_Allocation__c where Property__c =: propRec.Id and Relation_to_Property__c != 'Primary Landlord']){
            conList.add(prop);
        }
        
      return conList[0];
    }
    
     @AuraEnabled
    public static string removeLand(String propAllocationid, String relation, String jointLandlordId){
          Property_Allocation__c prop = [Select id,Relation_to_Property__c,Contact__c from Property_Allocation__c where id =: propAllocationid];
        try{
        if(relation == 'Joint'){
            delete prop;
           
        }
        else if(relation == 'Prime'){
                Property_Allocation__c delProp = [Select id,Relation_to_Property__c,Contact__c from Property_Allocation__c where Contact__r.id =: jointLandlordId and Relation_to_Property__c != 'Primary Landlord'];
      		delete delProp;
            prop.Contact__c = jointLandlordId;
            update prop;
        }
            return 'Success';
        }
         catch(DMLException e){
            return e.getMessage();
        }
        
        
    }
      @AuraEnabled
	public static List<contact> searchlandlord(String searchField, Property__c propRec, Boolean status){
	
set<Id> conList = new set<Id>();
		string searchkey = '%' + searchField + '%';
        if(status == false){
        for(Property_Allocation__c propALL : [Select id,Property__c,Contact__c,Contact__r.Id from Property_Allocation__c where Property__c =: propRec.Id]){
            conList.add(propALL.Contact__r.Id);
        }
        }else if(status == true){
            for(Property_Allocation__c propALL : [Select id,Property__c,Relation_to_Property__c,Contact__c,Contact__r.Id from Property_Allocation__c where Property__c =: propRec.Id and Relation_to_Property__c = 'Primary Landlord']){
            conList.add(propALL.Contact__r.Id);
            }
        }
		user u = [select id, accountid
		          from user
		          where id = :UserInfo.getUserId()];
		List<contact> conrec = [select id, Title, firstname, lastname, email, phone
		                        from contact
		                        where id Not in: conList and account.recordtype.name = 'Individual Landlord'  and account.Parent_person_account__c = :u.accountid and (name like :searchkey or email LIKE :searchkey)];
			return conrec;
	}
     @AuraEnabled
    public static Contact getLandlord(String landlordRecId){ 
    	List<Contact> con = [select id,Salutation ,Number_of_properties__c,Number_of_Deposits__c,Name,Account_Status__c,LandLord_Registration_Number__c,MailingStreet,MailingCity,MailingPostalCode,MailingState,MailingCountry,Email,Phone_Code__c,Phone from Contact  where id =: landlordRecId LIMIT 1];

	return con[0];    
    }
     @AuraEnabled
    public static Map<String, SObject> saveLandlord(Contact landlordRec){ 
        Map<String, SObject> returnVal = new Map<String, SObject>();
        
       
          try{
        Contact con = [Select id,Name,LandLord_Registration_Number__c,MailingStreet,MailingCity,MailingPostalCode,MailingState,MailingCountry,Email,Phone_Code__c,Phone from Contact where id =: landlordRec.Id limit 1];
        if(con.email != landlordRec.email){ 
            list<user> userlistEmail = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                        from user where profile.UserLicense.Name ='Customer Community Login' 
                                        and (email =:landlordRec.email.trim() or username =:landlordRec.email.trim())];
            if(userlistEmail.size() > 0){
                returnVal.put('Duplicate Email', userlistEmail[0]);
                return returnVal;
                //return 'Duplicate Email';
            }
        }
        
        if(con.email != landlordRec.email){
            List<List<SObject>> searchNameList = [FIND :con.Name IN ALL FIELDS 
                                                  RETURNING Contact(ID, Name WHERE email=:landlordRec.email.trim()
                                                                    AND CreatedById = :UserInfo.getUserId() 
                                                                    AND (Account.RecordType.Name = 'Individual Landlord' 
                                                                         OR Account.RecordType.Name = 'Corporate Landlord') )];
            if(searchNameList != null && searchNameList[0].size() > 0){
                returnVal.put('Duplicate Name', searchNameList[0][0]);
                return returnVal;
                //return 'Duplicate Name';
            }
        }

      
            con.LandLord_Registration_Number__c=landlordRec.LandLord_Registration_Number__c;
            con.MailingStreet=landlordRec.MailingStreet;
            con.MailingCity=landlordRec.MailingCity;
            con.MailingPostalCode=landlordRec.MailingPostalCode;
            con.Phone_Code__c = landlordRec.Phone_Code__c;
            con.Phone = landlordRec.Phone;
            con.Email = landlordRec.Email;
            con.MailingCountry = landlordRec.MailingCountry;
            update con;
            
            returnVal.put('updated', con);
            return returnVal;
            //return con;    
            }catch(Exception ex){
                returnVal.put(ex.getmessage(), new User() );
                return returnVal;
            }
    }
    
    @AuraEnabled
    public static string updatePropDetails( Property__c updtProperty){
        try{
            update updtProperty;
            return 'Success';
        }
     	catch(DMLException e){
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static List<Contact> myLandlordList(String searchVar, String status, String branchId){     
        List<Contact> listlandlord = new List<Contact>();
        Map<Id,Contact> setCon = new Map<Id,Contact>();
          set<Id> conIdSet = new set<Id>();
         List<Contact> listCon = new List<Contact>();
        Map<Id,Integer> conmap = new Map<Id,Integer>();
         Map<Id,Id> idMap = new Map<Id,Id>();
       List<Property_Allocation__c> propAll = new List<Property_Allocation__c>();
          QueryLimits__c querylimit = QueryLimits__c.getValues('All Limits'); 
        Integer noOfLandlord = Integer.valueOf(querylimit.LandlordLimit__c);
       
       // user u  = [select id,accountid,name from user where id = :UserInfo.getUserId()];
        
        //for(Property__c acc : [select id,name,City__c,County__c,No_of_bedrooms__c  ,Is_Furnished__c,No_of_living_rooms__c,Town__c, Country__c, Property_Owner__c, Postal_Code__c from Property__c 
         //                      where Property_Owner__c = :u.AccountId   LIMIT 500])
      String searchTxt;
        searchTxt = '%' + searchVar + '%';
        system.debug('searchVar '+searchVar);
        if(searchVar != ''){
            List<Contact> conList1 = new List<Contact>();
			if(branchId == NULL){
				conList1 = [select id ,Salutation,Number_of_Deposits__c,Number_of_properties__c,FirstName,LastName,Account_Status__c ,Phone,Email,LandLord_Registration_Number__c,LandLord_Registration_Status__c,AddressFormula__c,Account.Deposit_Protections__c,Account.Number_of_Properties__c from Contact  where Account_Status__c =: status and CreatedById = :UserInfo.getUserId() and (Account.RecordType.Name = 'Individual Landlord' OR Account.RecordType.Name = 'Corporate Landlord') LIMIT : noOfLandlord];
			}else{
				conList1 = [select id ,Salutation,Number_of_Deposits__c,Number_of_properties__c,FirstName,LastName,Account_Status__c ,Phone,Email,LandLord_Registration_Number__c,LandLord_Registration_Status__c,AddressFormula__c,Account.Deposit_Protections__c,Account.Number_of_Properties__c from Contact  where Account_Status__c =: status and Branch__c=: branchId and (Account.RecordType.Name = 'Individual Landlord' OR Account.RecordType.Name = 'Corporate Landlord') LIMIT : noOfLandlord];
			}
            for(Contact con : conList1)
            { 
                if(con.LandLord_Registration_Number__c != null){
                    string landRegNo = con.LandLord_Registration_Number__c;
                    if(landRegNo.contains(searchVar) ){
                        listlandlord.add(con);   
                    }   
                }       
            }  
            if(listlandlord.size() == 0){
                List<Contact> conList2 = new List<Contact>();
				if(branchId == NULL){
				conList2 = [select id ,Salutation,Number_of_Deposits__c,Number_of_properties__c,FirstName,LastName,Account_Status__c ,Phone,Email,LandLord_Registration_Number__c,LandLord_Registration_Status__c,AddressFormula__c,Account.Deposit_Protections__c,Account.Number_of_Properties__c from Contact where Account_Status__c =: status and (name like : searchTxt OR Email like : searchTxt OR AddressFormula__c like : searchTxt OR Phone like : searchTxt) and CreatedById = :UserInfo.getUserId() and (Account.RecordType.Name = 'Individual Landlord' OR Account.RecordType.Name = 'Corporate Landlord')  LIMIT : noOfLandlord];
			}else{
				conList2 = [select id ,Salutation,Number_of_Deposits__c,Number_of_properties__c,FirstName,LastName,Account_Status__c ,Phone,Email,LandLord_Registration_Number__c,LandLord_Registration_Status__c,AddressFormula__c,Account.Deposit_Protections__c,Account.Number_of_Properties__c from Contact  where Account_Status__c =: status and (name like : searchTxt OR Email like : searchTxt OR AddressFormula__c like : searchTxt OR Phone like : searchTxt) and Branch__c=: branchId and (Account.RecordType.Name = 'Individual Landlord' OR Account.RecordType.Name = 'Corporate Landlord')  LIMIT : noOfLandlord];
			}
                for(Contact con : conList2){
                    listlandlord.add(con);        
                } 
            }
            return listlandlord;
        }else{
            Integer numberOfProp =0;
            Integer numberOfDeposit =0;
            List<Contact> conList3 = new List<Contact>();
				if(branchId == NULL){
				conList3 = [select id ,(Select id,Property__r.NoOfDeposit__c from Property_Allocations__r),Salutation,Number_of_Deposits__c,Number_of_properties__c,FirstName,LastName,Account_Status__c ,Phone,Email,LandLord_Registration_Number__c,LandLord_Registration_Status__c,AddressFormula__c,Account.Deposit_Protections__c,Account.Number_of_Properties__c from Contact  where CreatedById = :UserInfo.getUserId()  and (Account.RecordType.Name = 'Individual Landlord' OR Account.RecordType.Name = 'Corporate Landlord') LIMIT :noOfLandlord];
			}else{
				 conList3 = [select id ,(Select id,Property__r.NoOfDeposit__c from Property_Allocations__r),Salutation,Number_of_Deposits__c,Number_of_properties__c,FirstName,LastName,Account_Status__c ,Phone,Email,LandLord_Registration_Number__c,LandLord_Registration_Status__c,AddressFormula__c,Account.Deposit_Protections__c,Account.Number_of_Properties__c from Contact  where Branch__c=: branchId and (Account.RecordType.Name = 'Individual Landlord' OR Account.RecordType.Name = 'Corporate Landlord') LIMIT :noOfLandlord];
			}
            for(Contact con : conList3)
            {
                Contact newCon = new Contact();
                newCon.id = con.id;
                if(con.Property_Allocations__r.size() >0){
                    numberOfProp = con.Property_Allocations__r.size();
                    propAll.addall(con.Property_Allocations__r);
                    Integer noOfDep = 0;
                    for(Property_Allocation__c pAllocation : con.Property_Allocations__r){
                        if(pAllocation.Property__r.NoOfDeposit__c != null){
                            noOfDep = noOfDep+Integer.valueOf(pAllocation.Property__r.NoOfDeposit__c);
                        }
                        newCon.Number_of_properties__c = String.ValueOf(numberOfProp);
                        newCon.Number_of_Deposits__c = String.ValueOf(noOfDep);
                    }  
                }
                else{
                    newCon.Number_of_properties__c = '0';
                    newCon.Number_of_Deposits__c = '0';
                }
                
                idMap.put(newCon.id,newCon.id);
                
                listlandlord.add(newCon); 
            }
            
            system.debug('Map@ '+idMap);
            /*   for(Property__c prop: [Select id,(Select id,Contact__r.Number_of_Deposits__c from Property_Allocations__r),(Select id from Deposits__r where (Status__c != 'Registered (not paid)' OR Status__c != 'Awaiting payment' OR Status__c != 'Deposit Closed')) from Property__c where id in (Select Property__c from Property_Allocation__c where id =: propAll)]){
numberOfDeposit = 0;
if(prop.Deposits__r.size()>0){
numberOfDeposit = prop.Deposits__r.size();
for(Property_Allocation__c pAllocation : prop.Property_Allocations__r){
if(idMap.containsKey(pAllocation.Contact__c)){
Contact newCon = new Contact();
system.debug('pAllocation@ '+pAllocation);
newCon.id = idMap.get(pAllocation.Contact__c);
Integer totalval =0;
if(pAllocation.Contact__r.Number_of_Deposits__c != null){

totalval = Integer.valueOf(pAllocation.Contact__r.Number_of_Deposits__c ) +numberOfDeposit;

}else{
totalval = numberOfDeposit;

}
newCon.Number_of_Deposits__c = string.valueOf(totalval);
//  setCon.add(newCon);  
listlandlord.add(newCon);  
}
}
}
}*/
            for(Contact c : listlandlord){
                setCon.put(c.id,c); 
            }
            if(listlandlord.size()>0){
                update setCon.values();
                
                listCon = [select id,Number_of_properties__c,Number_of_Deposits__c,Salutation,FirstName,LastName,Account_Status__c ,Phone,Email,LandLord_Registration_Number__c,LandLord_Registration_Status__c,AddressFormula__c,Account.Deposit_Protections__c,AccountId,Account.Number_of_Properties__c from Contact where id in: listlandlord and Account_Status__c=:status];
                return listCon;
            }
            else{ return null; }
        }
       
    }
    public class userInformation{
		@AuraEnabled
		public Contact con{ get; set; }
        
    }
    @AuraEnabled
    public static List<Property_Allocation__c> fetchPropertylist(String status, String branchId){  
       //  QueryLimits__c querylimit = [Select id,LandlordLimit__c,PropertiesLimit__c from QueryLimits__c where name = 'All Limits'];
       QueryLimits__c querylimit = QueryLimits__c.getValues('All Limits'); 
        Integer noOfProp = Integer.valueOf(querylimit.PropertiesLimit__c);
        List<Property_Allocation__c> listPropertyAllocations = new List<Property_Allocation__c>();
                user u  = [select id,accountid,name,contactId from user where id = :UserInfo.getUserId()];
        
        //for(Property__c acc : [select id,name,City__c,County__c,No_of_bedrooms__c  ,Is_Furnished__c,No_of_living_rooms__c,Town__c, Country__c, Property_Owner__c, Postal_Code__c from Property__c 
         //                      where Property_Owner__c = :u.AccountId   LIMIT 500])
        if(branchId != NULL){
            for(Property__c property : [select id,Property_Owner__c ,Street__c,City__c,County__c,Postal_Code__c,Country__c,(select id,Property__r.Street__c,Property__r.City__c,Property__r.County__c,Property__r.Postal_Code__c,Property__r.Country__c,Property__c,Relation_to_Property__c,Contact__r.name,Property_Address__c from Property_Allocations__r where Relation_to_Property__c='Primary Landlord') from Property__c  where Property_status__c=:status and Branch__c=:branchId  LIMIT: noOfProp]){
           
             listPropertyAllocations.addall(property.Property_Allocations__r);        
        }
        }
        else{
            for(Property__c property : [select id,Property_Owner__c ,Street__c,City__c,County__c,Postal_Code__c,Country__c,(select id,Property__r.Street__c,Property__r.City__c,Property__r.County__c,Property__r.Postal_Code__c,Property__r.Country__c,Property__c,Relation_to_Property__c,Contact__r.name,Property_Address__c from Property_Allocations__r where Relation_to_Property__c='Primary Landlord') from Property__c  where Property_status__c=:status and (createdById = :UserInfo.getUserId() OR Property_Owner__c=: u.accountId) LIMIT: noOfProp]){
           
             listPropertyAllocations.addall(property.Property_Allocations__r);        
        }
        }
       
        return listPropertyAllocations;
    }
    
    
    @AuraEnabled
    public static List<Property_Allocation__c> searchpropertylist(string searchtext, string status){
        String search= '%'+searchtext+'%';
        
        List<Property_Allocation__c> listPropertyAllocations = new List<Property_Allocation__c>();
        user u  = [select id,accountid,name from user where id = :UserInfo.getUserId()];
        for(Property__c property : [select id,name,City__c,Town__c,County__c,Property_Owner__r.Name, Country__c, Property_Owner__c, Postal_Code__c,(select id,Property__r.Street__c,Property__r.City__c,Property__r.County__c,Property__r.Postal_Code__c,Property__r.Country__c,Relation_to_Property__c,Property__c,Contact__r.name,Property_Address__c from Property_Allocations__r where Relation_to_Property__c='Primary Landlord') from Property__c where
                               (Property_Owner__c =:u.AccountId OR CreatedById =: u.Id) AND Property_status__c=: status AND
                               (City__c LIKE : search  
                                OR Property_Owner__r.Name Like : search
                                OR Postal_Code__c LIKE : search 
                                OR Country__c LIKE : search
                                 OR  County__c LIKE : search 
                                OR Street__c LIKE : search 
                                OR County__c LIKE : search
                                  OR Town__c LIKE : search  ) LIMIT 500 ])
            // OR  County__c : search 
            // OR Town__c : search
            
        {
            listPropertyAllocations.addall(property.Property_Allocations__r);           
        }
        return listPropertyAllocations;
    }
    
    @AuraEnabled
    public static Void delproperty (List<id> dellist){
        system.debug('getids--> 44' + dellist);
        List<Property__c> proplist = [select id,name,City__c,Town__c,No_of_bedrooms__c  ,Is_Furnished__c,County__c, Country__c, Property_Owner__c, Postal_Code__c from Property__c where id in : dellist ];
        delete proplist;
        
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
    public static Property_Allocation__c getLandlordDetails(String landlordId){
        List<Property_Allocation__c> listPropertyAllocations = new List<Property_Allocation__c>();
        listPropertyAllocations = [Select id,Contact__c,Contact__r.LastName,Contact__r.Email,Contact__r.FirstName, Contact__r.Landlord_Registration_Number__c,Landlord_Registration_Number__c,Landlord_Registrataion_Status__c,
                                       Contact__r.Phone_Code__c, Contact__r.Phone from Property_Allocation__c where id=:landlordId limit 1];
        return listPropertyAllocations[0];                              
        
    }
    
    @AuraEnabled
    public static Map<String, SObject> updateLandlordDetail(String firstName,String lastName,String email,String phoneCode,String mobile,String registration,String registrationStatus,
                                            String contactid,String propAllocationId){
                                                
		Map<String, SObject> returnVal = new Map<String, SObject>();
        try{              
            String fullNameForSearch = firstName.trim() + ' ' + lastName.trim();
            System.debug('fullNameForSearch ' + fullNameForSearch);
            
            Contact conCheck = [Select Id, firstName, lastName, email From Contact Where Id =: contactid Limit 1];
            if(conCheck.email != email){ 
                list<user> userlistEmail = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                            from user where profile.UserLicense.Name ='Customer Community Login' 
                                            and (email =:email.trim() or username =:email.trim())];
                if(userlistEmail.size() > 0){
                    returnVal.put('Duplicate Email', userlistEmail[0]);
                    return returnVal;
                    //return 'Duplicate Email';
                }
            }
            
            if(conCheck.FirstName != firstname || conCheck.LastName != lastName || conCheck.email != email){
                List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
                                                      RETURNING Contact(ID, Name WHERE email=:email.trim()
                                                                        AND CreatedById = :UserInfo.getUserId() 
                                                                        AND (Account.RecordType.Name = 'Individual Landlord' 
                                                                             OR Account.RecordType.Name = 'Corporate Landlord') )];
                if(searchNameList != null && searchNameList[0].size() > 0){
                    returnVal.put('Duplicate Name', searchNameList[0][0]);
                    return returnVal;
                    //return 'Duplicate Name';
                }
            }

            Property_Allocation__c propAllocation = new Property_Allocation__c(id=propAllocationId);
            propAllocation.Landlord_Registration_Number__c = registration;
            propAllocation.Landlord_Registrataion_Status__c = registrationStatus;
            update propAllocation;
            
            Contact con = new Contact(id=contactid);
            con.FirstName = firstName;
            con.LastName = lastName;
            con.Email = email;
            con.Phone_Code__c = phoneCode;
            con.Phone = mobile;
            update con;
            
            updateLandlordDetail(contactid,firstName,lastName,email,phoneCode,mobile);
            
            returnVal.put('updated', new User() );
            return returnVal;
            //return 'updated';
            
        }
        catch(Exception ex){
            returnVal.put(ex.getmessage(), new User() );
                return returnVal;
           // return ex.getmessage();
        }
    }
    
    @future
    public static void updateLandlordDetail(String contactid,String firstName,String lastName,String email,String phoneCode,String mobile){
        try{ 
            List<User> listUpdateUser = new List<User>();
            List<User> listUser = [Select id,FirstName,LastName,Email,Username,MobilePhone from User where ContactId=:contactid limit 1];
            if(listUser!=null && !listUser.isEmpty()){
                listUser[0].FirstName = firstName;
                listUser[0].LastName = lastName;
                listUser[0].Email = email;
                listUser[0].Username = email;
                listUser[0].MobilePhone = mobile;
                listUpdateUser.add(listUser[0]);
            }
            
            if(!listUpdateUser.isEmpty()){
                update listUpdateUser;
            }            
        }
        catch(Exception ex){
            
        }
    }
    
    
    @AuraEnabled
    Public static void saveproperty (String noOfBedroom,String noOfLivingBedroom,String selectedValue,String street, 
                                     String city, String postcode, String country, String county, string LocalAreaCode){ 
        user u  = [select id,accountid,name from user where id = :UserInfo.getUserId()];
        Property__c prop = new Property__c();
        prop.No_of_bedrooms__c = Integer.valueOf(noOfBedroom);
        prop.No_of_living_rooms__c = Integer.valueOf(noOfLivingBedroom);
        prop.Is_Furnished__c = Boolean.valueOf(selectedValue);    
        prop.Property_Owner__c = u.AccountId;
        prop.Street__c = street;
        prop.City__c = city;
        prop.Postal_Code__c = postcode;
        prop.Country__c = country;
        prop.County__c = county;
        prop.Local_Authority_Area__c = LocalAreaCode;                                 
        insert prop;                                 
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
        List<Property__c> oldpropertyRec = [Select id,NoOfDeposit__c,(Select id from Property_Allocations__r),Property_status__c,Local_authority_registration_details__c,House_No__c,City__c,Country__c,County__c,District__c,State__c,Street__c,Town__c,Name,Postal_Code__c
                                                    from Property__c where Id =:propertyId limit 1];
    
        
        if(propertyId!=null ){
            if(oldpropertyRec[0].Property_Allocations__r.size()>0){
                 
                oldpropertyRec[0].Local_authority_registration_details__c = '';
                update oldpropertyRec;        
                
            for(Property_Allocation__c prc : [Select id,Property__r.NoOfDeposit__c,Property__r.Property_status__c,Property__r.Local_authority_registration_details__c,Landlord_Registration_Number__c, Property__r.id,Property__r.House_No__c,Property__r.City__c,Property__r.Country__c,Property__r.County__c,Property__r.District__c,Property__r.State__c,Property__r.Street__c,Property__r.Town__c,Property__r.Name,Property__r.Postal_Code__c from Property_Allocation__c where Property__r.id =: propertyId]){
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
    public static list<Property_Allocation__c> landlordList(string propertyId){
        list<Property_Allocation__c> propertyRec = [select id,Relation_to_Property__c,Contact__c,Contact__r.FirstName,Contact__r.LastName,
                                                    Contact__r.Email,Contact__r.Phone,Contact__r.Landlord_Registration_Number__c,
                                                    Landlord_Registration_Number__c,Landlord_Registrataion_Status__c,Property__r.House_No__c,Property__r.City__c,Property__r.Country__c,Property__r.County__c,Property__r.District__c,Property__r.State__c,Property__r.Street__c,Property__r.Town__c,Property__r.Name
                                                    from Property_Allocation__c where Property__c =:propertyId];
        return propertyRec;
    }
    
    @AuraEnabled
    public static string deletePropertyRecord(String propertyRec, String status){
        Property__c property = [Select id,name,Property_status__c from Property__c where id =:propertyRec];
        try{
            if(status == 'Inactive'){
                 property.Property_status__c = 'Inactive';
               update property;
            return 'Inactive';
            }
            else if(status == 'Active'){
                  property.Property_status__c = 'Active';
                 update property;
            return 'Active';
            }
            return '';
           
        }
        catch(Exception ex){
            String message = ex.getmessage();
            return message;
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