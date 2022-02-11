/* @Who : Ashish Singh
 * @When : 15-03-2021
 * @What : Property Managment Module
 */

public without sharing class EI_Properties {
    
/*@What : Get Current Logged In User
 * 
 */    
    
 /*   @AuraEnabled
    public static user getuserDetails(){ 
        try{
            EI_GlobalVariables globalVariables = new EI_GlobalVariables();
            globalVariables.userContact currentUser = EI_GlobalVariables.currentLoggedInUser();
             return currentUser.usr;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
       
    } */
        @AuraEnabled
        public static List<String> getPostCode(){
            List<String> options = new List<String>();
            Schema.DescribeFieldResult fieldResult = Property__c.SDS_PropertyPostCodes__c.getDescribe();
            List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p : pList){
                options.add(p.getValue());
            }
            return options;
        }
    @AuraEnabled
	public static user getuserDetails(){
		user u = [select id, accountid, contactid,contact.LandLord_Registration_Number__c, User_Type__c
		          from user
		          where id = :UserInfo.getUserId()];
		return u;
	}
    
    @AuraEnabled
    public static Property__c checkDuplicateProperty(Property__c property){
        system.debug(UserInfo.getUserId() +' property '+property.Street__c);
        List<Property__c> propertyList = [select id,Name,Property_Owner__c ,Street__c,City__c,County__c,Postal_Code__c,Country__c,
                (select id,Name, Property__r.Street__c,Property__r.City__c,Property__r.County__c,Property__r.Postal_Code__c,
                 Property__r.Country__c,Property__c,Relation_to_Property__c,Contact__r.name,Property_Address__c 
                 from Property_Allocations__r where Relation_to_Property__c='Primary Landlord') 
            from Property__c  where createdById = :UserInfo.getUserId() AND Street__c =: property.Street__c AND City__c =: property.City__c AND Postal_Code__c =: property.Postal_Code__c ];
        
        if(propertyList.size() > 0){
            return propertyList[0];
        }else{
            return null;    
        }	
    }
       
    @AuraEnabled
    public static List<Property__c> addNewProperty(String branchId, Property__c property, user usertype, list<contact> primaryLandord, list<contact> jointlandlord){
        Boolean checkPostCode = EI_Properties.contains(property.Postal_Code__c);
        if(checkPostCode){

        try{
            if(branchId != null){
             property.Branch__c =   branchId;
            }
            List<Contact> primaryLand = new List<Contact>();
             List<Contact> jointLand = new List<Contact>();
            Id AccId ;
            if(primaryLandord.size()>0){
                primaryLand= [Select AccountId,LandLord_Registration_Number__c,LandLord_Registration_Status__c from Contact where id in: primaryLandord];
                AccId = primaryLand[0].AccountId;
                
            }
             if(jointlandlord.size()>0){
                jointLand= [Select id,AccountId,LandLord_Registration_Number__c,LandLord_Registration_Status__c from Contact where id in: jointlandlord];
            //    AccId = primaryLand[0].AccountId;
                
            }
             
            
            Map<String, String> pstAreaCode=  new Map<String, String>();
            for(Area_Code_For_Landlord__mdt areCode : [select id,Local_Authority_Area__c, Postal_Code__c from Area_Code_For_Landlord__mdt where Postal_Code__c=: property.Postal_Code__c]){
                pstAreaCode.put(areCode.Postal_Code__c, areCode.Local_Authority_Area__c);
            }
            list<Property_Allocation__c> prAllocation = new list<Property_Allocation__c>();
            user u = [select id, accountid, name
                      from user
                      where id = :UserInfo.getUserId()];
             if (usertype.User_Type__c == 'Agent' && primaryLandord.size() > 0){
                  if(primaryLandord[0].AccountId == null){
               
                       property.Property_Owner__c = AccId;
            }
                 else{
                      property.Property_Owner__c = primaryLandord[0].AccountId;
                 }
              
             }
            else{
               property.Property_Owner__c = usertype.AccountId; 
            }
            property.Property_status__c = 'Active';
            if(property.Local_Authority_Area__c == '' || property.Local_Authority_Area__c == null){
                property.Local_Authority_Area__c = pstAreaCode.get(property.Postal_Code__c);
            }
            insert property;
            
            if (usertype.User_Type__c == 'Agent' && primaryLandord.size() > 0){
                   String propertyRegNumber = '';
                if(primaryLand[0].LandLord_Registration_Number__c != null){
                    propertyRegNumber = EI_AddNonMemberLandlord.getPropertyRegNumber(property.id,primaryLand[0].LandLord_Registration_Number__c);
                }
               
                prAllocation.add(new Property_Allocation__c(Contact__c = primaryLandord[0].id,Landlord_Registrataion_Status__c =primaryLand[0].LandLord_Registration_Status__c ,Landlord_Registration_Number__c=propertyRegNumber, Property__c = property.id, Relation_to_Property__c = 'Primary Landlord'));
            } else{
                  String propertyRegNumber = '';
              //  Contact loggedInContact = 
                if(usertype.contact.LandLord_Registration_Number__c != null){
                    propertyRegNumber = EI_AddNonMemberLandlord.getPropertyRegNumber(property.id,usertype.contact.LandLord_Registration_Number__c);
                }
           		 prAllocation.add(new Property_Allocation__c(Contact__c = usertype.contactid,Landlord_Registrataion_Status__c =usertype.contact.LandLord_Registration_Status__c,Landlord_Registration_Number__c=propertyRegNumber, Property__c = property.id, Relation_to_Property__c = 'Primary Landlord'));
            }
            if (jointlandlord.size() > 0){
                
                for (contact con : jointLand){
                      String propertyRegNumber = '';
                    if(con.LandLord_Registration_Number__c != null){
                        propertyRegNumber = EI_AddNonMemberLandlord.getPropertyRegNumber(property.id,con.LandLord_Registration_Number__c);
                    }
                   //   String propertyRegNumber = EI_AddNonMemberLandlord.getPropertyRegNumber(property.id,con.LandLord_Registration_Number__c);
                    prAllocation.add(new Property_Allocation__c(Contact__c = con.id,Landlord_Registrataion_Status__c =con.LandLord_Registration_Status__c,Landlord_Registration_Number__c=propertyRegNumber, Property__c = property.id, Relation_to_Property__c = 'Joint Landlord'));
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
        else{
            return null;
        }
    }
    
   
    public static Boolean contains(String postcode)
    {
        Schema.DescribeFieldResult fieldResult = Property__c.SDS_PropertyPostCodes__c.getDescribe();
	    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry t : ple)
        {
            if(postcode.startsWith(t.getValue()))
            {
                system.debug('@@ match');
                return true;
            }
        }
    
        return false;
    }
    @AuraEnabled
	public static List<Property_Allocation__c> getLandlordforSummery(String branchId, list<Property__c> property){
        
		list<Property_Allocation__c> landlord = [select id, Relation_to_Property__c, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.phone
		                                         from Property_Allocation__c
		                                         where Property__c = :property[0].id ];
		if (landlord.size() > 0){
			return landlord;
		} else{
			return null;
		}
	}
    
    @AuraEnabled
    public static String transferDepositwithProperty(Property__c property, user usertype, list<contact> primaryLandord, list<contact> jointlandlord,Date startDate,Decimal rentAmount,String DepositId){
        
        
        List<String> tenEmail = new List<String>();
        List<Installment__c> installmentList = new List<Installment__c>();
        Map<String, String> emailMember = new Map<String,String>();
        try{
            
            // Property Creation with landlord
            
            list<Property_Allocation__c> prAllocation = new list<Property_Allocation__c>();
            user u = [select id, accountid, name
                      from user
                      where id = :UserInfo.getUserId()];
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
            
            // Deposit Creation
            Deposit__c newdeposit;
            
            if(DepositId !=  null) {
                
                List<Deposit__c> oldDeposit = new List<Deposit__c>();
                List<Deposit__c> oldDepoList = [Select id,Status__c,Number_of_Tenants__c,Branch__c,Rent_Amount__c,Deposit_Amount__c,Protected_Amount__c,
                                                Date_Deposit_Received__c,Start_Date__c,User_reference_for_the_deposit__c,Property__c,Customer__c,Scheme__c 
                                                from Deposit__c where id =: DepositId];
                List<Deposit__c> newDepoListToInsert = new List<Deposit__c>();
                Map<Id, Deposit__c> oldDepoMap = new Map<Id, Deposit__c>();
                for(Deposit__c depo : oldDepoList) {
                    oldDepoMap.put(depo.Id, depo);
                }
                
                for(Deposit__c deposit : oldDepoMap.values()) {
                    newdeposit = new Deposit__c(Status__c='Deposits held by scheme', Date_Deposit_Received__c = System.today(),Property__c = property.id, 
                                                Number_of_Tenants__c = deposit.Number_of_Tenants__c,Branch__c=deposit.Branch__c,
                                                Rent_Amount__c = deposit.Rent_Amount__c, 
                                                Deposit_Amount__c =  rentAmount, 
                                                Protected_Amount__c = deposit.Protected_Amount__c, 
                                                Start_Date__c = startDate, User_reference_for_the_deposit__c = deposit.User_reference_for_the_deposit__c, 
                                                Customer__c = deposit.Customer__c, Scheme__c = deposit.Scheme__c, Old_Property_Deposit__c = deposit.Id);
                    newDepoListToInsert.add(newdeposit);
                    //deposit.Status__c = 'Deposit Closed';
                    //oldDeposit.add(deposit);
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
                //update oldDeposit;
                //insert newdeposit;
                
                List<Deposit_Allocation__c> newdepositAllocationList = new List<Deposit_Allocation__c>();
                Deposit_Allocation__c newdepositAllocation;
                for(Deposit_Allocation__c depositAllocation : [Select id,Deposit__r.Customer__r.PersonEmail,Deposit_Holder__r.Name,Deposit__r.Customer__r.Email__c,Deposit__r.Customer__r.Name,Deposit__r.Customer__r.IsPersonAccount,Deposit_Holder__r.PersonEmail,Contact__c,Is_Lead__c,Role__c,Contact__r.email from Deposit_Allocation__c where Deposit__c =: DepositId]){
                    
                    tenEmail.add(depositAllocation.Deposit_Holder__r.Name);
                    emailMember.put(depositAllocation.Deposit_Holder__r.Name,depositAllocation.Deposit_Holder__r.PersonEmail);
                    if(depositAllocation.Deposit__r.Customer__r.IsPersonAccount){
                        tenEmail.add(depositAllocation.Deposit__r.Customer__r.Name);
                        emailMember.put(depositAllocation.Deposit__r.Customer__r.Name,depositAllocation.Deposit__r.Customer__r.PersonEmail); 
                    }else{
                        tenEmail.add(depositAllocation.Deposit__r.Customer__r.Name);
                        emailMember.put(depositAllocation.Deposit__r.Customer__r.Name,depositAllocation.Deposit__r.Customer__r.Email__c); 
                        
                    }
                    newdepositAllocation = new Deposit_Allocation__c(Deposit_Holder__c = depositAllocation.Deposit_Holder__c, Contact__c = depositAllocation.Contact__c, Is_Lead__c = depositAllocation.Is_Lead__c, Role__c = depositAllocation.Role__c, Deposit__c = newdeposit.id);             
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
                if(!installmentList.isEmpty()){
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
            if(DepositId !=  null && newdeposit != null){
                
                MailJetService.mailForTranferDeposit(emailMember,tenEmail);
                /*      Messaging.SingleEmailMessage singlemail =new Messaging.SingleEmailMessage(); 

singlemail.toAddresses = new String[] { tenEmail  };
singlemail.setTargetObjectId(UserInfo.getUserId());
singlemail.saveAsActivity=false;
singlemail.plainTextBody ='We have moved your deposit from old property to new property';
Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singlemail}); */
                string propertyAddress;
                if(property.Town__c!=null){
                propertyAddress = property.Street__c + ' ' + property.Town__c + ' ' + property.City__c + ' ' + property.County__c + ' ' + property.Postal_Code__c;
                }
                else{
                propertyAddress = property.Street__c  + ' ' + property.City__c + ' ' + property.County__c + ' ' + property.Postal_Code__c;     
                }
                return newdeposit.Id+'='+propertyAddress;
            }
            else{
                return 'record inserted';
            }
            
        } catch (exception e){
            return string.valueOf(e.getMessage());
        }
    }

    @AuraEnabled
	public static List<contact> getlandlord(String branchId, String searchField){


		string searchkey = '%' + searchField + '%';
		user u = [select id, accountid
		          from user
		          where id = :UserInfo.getUserId()];
        List<contact> conrec = new List<Contact>();
        if(branchId != null){
            conrec = [select id, Title, firstname,Branch__c,LandLord_Registration_Number__c, lastname, email, phone
		                        from contact
		                        where (Branch__c =: branchId) and account.recordtype.name like '%Landlord%' and (name like :searchkey or email LIKE :searchkey)];

        }
        else{ conrec = [select id, Title, firstname,LandLord_Registration_Number__c, lastname, email, phone
		                        from contact
		                        where (account.Parent_person_account__c = :u.accountid) and account.recordtype.name like '%Landlord%' and (name like :searchkey or email LIKE :searchkey)];
            }
		return conrec;
	}
    
    @AuraEnabled
    public static List<Error_Message__mdt> fetchErrorLabel(){
        List<Error_Message__mdt> allError = [SELECT MasterLabel,Error_Message__c FROM Error_Message__mdt ];
        return allError;
    }
    
     

    
}