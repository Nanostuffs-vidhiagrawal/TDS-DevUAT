public without sharing class  EI_manageusers {
      @AuraEnabled 
    public static user fetchUser(){
       User u = [select id,Name,Addition_Permission__c,User_Role__c from User where id =: userInfo.getUserId()];
        return u;
    }
     @AuraEnabled
    public static List<String> getUserRole(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Branch_User_Mapping__c.Job_role__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
       @AuraEnabled
    public static List<String> getUserPermission(){
        try{
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Branch_User_Mapping__c.Additional_Permission__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
        catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    Public static list<user> showusers(String branchId){
        try{
            list<User> ulist = new list<user>();  
  user u = [select id,accountid,Account.recordType.name,ContactId,profile.Name from user where id = :UserInfo.getUserId() ];
            if(branchId != null || u.Profile.Name == 'Branch User'){
                 ulist = [select id,User_Status__c,Title,Addition_Permission__c,User_Role__c,firstname,lastname,email,phone,isactive,ContactId from user where id in (Select User__c from Branch_User_Mapping__c where Branch__c =: branchId) and profile.name = 'Branch User' and accountId =:u.accountid and id !=: u.id];
                 Return ulist;
            }
       
            else{
          
            system.debug('line-->8' + u.AccountId );
            if(u.Account.recordType.name == 'Organization' || u.Account.recordType.name == 'Corporate Landlord'){
              ulist = [select id,User_Status__c,Title,Addition_Permission__c,User_Role__c,firstname,lastname,email,phone,isactive,ContactId from user where  accountId =:u.accountid and id !=: u.id];
                              
            }else{
            ulist = [select id,User_Status__c,Title,Addition_Permission__c,User_Role__c,firstname,lastname,email,phone,isactive,ContactId from user where contact.account.Parent_person_account__c =:u.accountid];
            }
            system.debug('line-->10' + ulist.size() );
            Return ulist;
            }
        } 
        catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<Map<String, String>> takesalutation(){
        try{
            List<Map<String, String>> listOFMap = new List<Map<String, String>>();
            Map<String, String> salutation = new Map<String, String>();
            Schema.DescribeFieldResult fieldResultsalutation = Account.Salutation.getDescribe();
            List<Schema.PicklistEntry> pListsalutation = fieldResultsalutation.getPicklistValues();
            for (Schema.PicklistEntry p : pListsalutation){
                salutation.put(p.getValue(), p.getLabel());
            }
            listOFMap.add(salutation);
            
            return listOFMap;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    Public static user viewdetails(string useid){
        try{
            User us = [select id,Title,firstname,lastname,email,phone from user where id=:useid ]; 
            Return us;
        } 
        catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static String format(List<String> values) {
    if (values == null) return null;
    return String.join(values, ';');
}
    @AuraEnabled
    Public static Account usercreate(string branchId, Account act,string salute,string phoneCode,string jobrole,List<String> userpermission){
        try{
           
             user ut = [select id,profileid,profile.name,contactid,account.ownerid,accountid,Account.recordType.name,Account.recordTypeId from user where id =:UserInfo.getUserId()];
            // string usrId = [select id ,email from user where email=:act.PersonEmail]?.Id; 
            if(ut.Account.recordType.name == 'Organization' || ut.Account.recordType.name == 'Corporate Landlord'){
                 User u = new User();
                Contact con = new Contact();
                con.ownerid=ut.account.ownerid;
                con.firstname=act.FirstName;
                con.lastname=act.LastName;
                con.email=act.PersonEmail;
                con.Salutation=salute;
                con.Phone_Code__c=phoneCode;
                con.phone=act.phone;
                con.accountId=ut.accountid;
                con.Job_role__c = jobrole;
              //  con.Additional_User__c = true;
              con.Additional_Permission__c = format(userpermission);
                insert con;
            
                 String fullName = con.FirstName + con.LastName;
                if (fullName.length() >= 5){
                    u.alias = fullName.substring(0, 4);
                } else{
                    u.alias = fullName;
                }
                
                // NickName Check
                String nickname = ((con.firstname != null && con.firstname.length() > 0) ? con.firstname.substring(0, 1) : '')+con.lastname.substring(0, 1);
                nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                u.CommunityNickname = nickname;
                
                // Username Check
                
                u.Title = con.Salutation;
                u.FirstName = con.FirstName;
                u.LastName = con.LastName;
                
                // Uncomment
                u.Username = con.Email;
                u.Phone = con.Phone;
                
                //u.Username = con.Email + 'abc';
                u.Email = con.Email;
                Profile branchProfileId;
                if(branchId != null){
                   branchProfileId = [Select id from Profile where name = 'Branch User'];
                    u.profileId = branchProfileId.id;
                }else{
                    u.profileId = ut.ProfileId;
                }
              //  u.ProfileId = [Select Id,name from profile where name = 'Landlord' limit 1].Id;
                  

                
                u.TimeZoneSidKey = 'Europe/London';
                u.LocaleSidKey = 'en_GB';
                u.LanguageLocaleKey = 'en_US';
                u.ContactId = con.Id;
                if(ut.Profile.name =='Landlord'){
                u.User_Type__c='Landlord';
                }
                else{
                 u.User_Type__c='Agent';   
                }
                u.EmailEncodingKey = 'ISO-8859-1';
              //  u.Addition_Permission__c = userpermission;
                u.User_Role__c = jobrole;
                insert u;
              //   Return u.Account;
            }
            else if(ut.Account.recordType.name == 'Individual Landlord' || ut.Account.recordType.name == 'Letting Agent'){
            system.debug('line-->39'+ ut);
         //   RecordType personAccountRecordType=[SELECT Id FROM RecordType WHERE Name = 'Individual Landlord' and SObjectType = 'Account'];
           // system.debug('line-->41' + personAccountRecordType);
            account acc = new account ();
            acc.ownerid=ut.account.ownerid;
            acc.firstname=act.FirstName;
            acc.lastname=act.LastName;
            acc.personemail=act.PersonEmail;
            acc.Salutation=salute;
            acc.Phone_Code__pc=phoneCode;
            acc.phone=act.phone;
            acc.Parent_person_account__c=ut.accountid;
            acc.recordtypeid =ut.Account.recordTypeId;
            insert acc;
            system.debug('line-->52' + acc.id);
            // id usercontactid =[select id,PersonContactId from Account where id =:Acc.id].PersonContactId;
            contact con = [select id,Salutation,firstname,lastname,Name,accountid,email,Phone_Code__c,phone from contact where accountid =: acc.id];
            
            if (con.Id != null){
                Contact cont = new Contact(id=con.Id);
                cont.Job_role__c = jobrole;
              //  con.Additional_User__c = true;
                      con.Additional_Permission__c = format(userpermission);
                update cont;
                
                User u = new User();
                // Alias Check
                String fullName = con.FirstName + con.LastName;
                if (fullName.length() >= 5){
                    u.alias = fullName.substring(0, 4);
                } else{
                    u.alias = fullName;
                }
                
                // NickName Check
                String nickname = ((con.firstname != null && con.firstname.length() > 0) ? con.firstname.substring(0, 1) : '')+con.lastname.substring(0, 1);
                nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
                u.CommunityNickname = nickname;
                
                // Username Check
                
                u.Title = con.Salutation;
                u.FirstName = con.FirstName;
                u.LastName = con.LastName;
                
                // Uncomment
                u.Username = con.Email;
                u.Phone = con.Phone;
                
                //u.Username = con.Email + 'abc';
                u.Email = con.Email;
              //  u.ProfileId = [Select Id,name from profile where name = 'Landlord' limit 1].Id;
                  u.profileId = ut.ProfileId;

                
                u.TimeZoneSidKey = 'Europe/London';
                u.LocaleSidKey = 'en_GB';
                u.LanguageLocaleKey = 'en_US';
                u.ContactId = con.Id;
                if(ut.Profile.name =='Landlord'){
                u.User_Type__c='Landlord';
                }
                else{
                 u.User_Type__c='Agent';   
                }
                u.EmailEncodingKey = 'ISO-8859-1';
               // u.Addition_Permission__c = userpermission;
                u.User_Role__c = jobrole;
                insert u;
                
                //---- Trigger Welcome email-------  //  
                  //  EmailTemplate templateId = [Select id,DeveloperName,Subject, HtmlValue, Body from EmailTemplate where DeveloperName  = 'RegisterationTemplateHTML'];
                    EmailTemplate templateId = [Select id,DeveloperName,Subject, HtmlValue, Body from EmailTemplate where DeveloperName  = 'welcomeemailforSDS'];
                    Messaging.SingleEmailMessage singlemail =new Messaging.SingleEmailMessage();  
                    List<Attachment> files = [SELECT Name, Body, ContentType FROM Attachment WHERE ParentId =: templateId.Id];
                    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                    for (Attachment file: files) {
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(file.Name);
                        efa.setBody(file.Body);
                        efa.setContentType(file.ContentType);
                        attachments.add(efa);
                    }
                    singlemail.setFileAttachments(attachments);
                    String htmlBody = templateId.HtmlValue;
                   /* Date dt = System.today(); //current date
                    DateTime dtime = Datetime.now();
                    Integer day = dt.Day(); //get day
                    String monthName = dtime.format('MMM');
                    Integer year = dt.Year(); //get year */
                    Date dtTodayDate = System.Today();
                    Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
                    string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                    //htmlBody = htmlBody.replace('{!NOW()}', day +' '+monthName +' '+year);
                    htmlBody = htmlBody.replace('{!Today}', strDate);
                   // htmlBody = htmlBody.replace('{!Receiving_User.Title2}', EmailSalutation);
                  //   htmlBody = htmlBody.replace('{!Receiving_User.Title}', salutation);
                   // htmlBody = htmlBody.replace('{!Receiving_User.Name}', con.Name );
                  //  htmlBody = htmlBody.replace('{!User.Name}', IndividualName );
                  //  htmlBody = htmlBody.replace('{!Receiving_User.User_Company_Name__c}', EmailAccName);
                  //  htmlBody = htmlBody.replace('{!Receiving_User.Contact}', firstname +' '+lastname);
                    System.debug('postacode 318 '+Acc.BillingPostalCode);
                  /*  if(Acc.BillingPostalCode != null ){
                        htmlBody = htmlBody.replace('{!Receiving_User.StreetCustom__c}', Acc.BillingStreet);
                        htmlBody = htmlBody.replace('{!Receiving_User.City}', Acc.BillingCity);                
                        htmlBody = htmlBody.replace('{!Receiving_User.PostalCode}', Acc.BillingPostalCode); 
                        htmlBody = htmlBody.replace('{!Receiving_User.Country}', Acc.BillingCountry);
                    }*/
                    
                    htmlBody = htmlBody.replace('{!Receiving_User.Phone}', Acc.Phone); 
                    
                   // htmlBody = htmlBody.replace('{!Receiving_User.Email}', Acc.Email__c);
                      htmlBody = htmlBody.replace('{!User.Username}', con.Email);  
                   // htmlBody = htmlBody.replace('{!Receiving_User.MemberId__c}', umember.MemberId__c); 
                    
                    singlemail.setTargetObjectId(con.Id);
                    singlemail.setTemplateId(templateId.id);
                    singlemail.setSubject('Your SafeDeposits Scotland registration');
                    singlemail.setHtmlBody(htmlBody);
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singlemail});
            }
             
            } 
            
             Return act;
        } 
        catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    Public static string makeUserInactive(String contactid){
        try{
            User ust = [Select id from User where contactId=:contactid];
            ust.IsActive=false;
            update ust;
            updateContactStatus(contactid,Label.Suspend);
            return 'User Inactive';
        } 
        catch (Exception e){
            //throw new AuraHandledException(e.getMessage());
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    Public static string reactivateUser(String contactid){
        try{
            User ust = [Select id from User where contactId=:contactid];
            ust.IsActive=true;
            update ust;
            updateContactStatus(contactid,Label.Active);
            return 'User active';
        } 
        catch (Exception e){
            //throw new AuraHandledException(e.getMessage());
            return e.getMessage();
        }
    }
    
    @future
    private static void updateContactStatus(String contactid,String contactStatus){
        Contact con = new Contact(id=contactid);
        con.User_Status__c = contactStatus;
        update con;
    }
    
    
    @AuraEnabled
    Public static User removeuser(String Uid){
        try{
            user ust = new user();
            ust.id = Uid;
            ust.IsActive=false;
            update ust;
            return ust;
        } 
        catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
   @AuraEnabled
	public static List<Map<String, String>> getJobRoles(){
		try{
			List<Map<String, String>> listOFMap = new List<Map<String, String>>();
		
			Map<String, String> hoJobRoles = new Map<String, String>();
			Schema.DescribeFieldResult fieldResulthoJobRoles = Contact.Job_role__c.getDescribe();
			List<Schema.PicklistEntry> pListhoJobRoles = fieldResulthoJobRoles.getPicklistValues();
			for (Schema.PicklistEntry p : pListhoJobRoles){
				hoJobRoles.put(p.getValue(), p.getLabel());
			}
            listOFMap.add(hoJobRoles);
     
     

			

			return listOFMap;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	} 
   @AuraEnabled
    Public static userInformation contactdetails(String conid){
     try{
         userinformation ui = new userinformation();
    	 ui.con = [select id,Salutation,User_Status__c,Firstname,lastname,email,Phone_Code__c,phone,Job_role__c,Additional_Permission__c 
         from Contact where id =: conid];   
           ui.selectedPermission =  new List<String>();
           system.debug('ui.con.Additional_Permission__c '+ui.con.Additional_Permission__c);
         if(ui.con.Additional_Permission__c != NULL ){
                List<String> splitString= ui.con.Additional_Permission__c.split(';');
            system.debug('splitString '+splitString.size());
            for(String str : splitString){
                  system.debug('str '+str);
                ui.selectedPermission.add(str);
                 system.debug('ui.selectedPermission '+ui.selectedPermission);
            }
         }else{
             String str = '';
             ui.selectedPermission.add(str);
         }
       
         return ui;
        } 
        catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }    
    }
    	public class userInformation{
		@AuraEnabled
		public Contact con{ get; set; }

         @AuraEnabled
		public List<String> selectedPermission{ get; set; }
        
	
	}
    @AuraEnabled
    Public static String updatedetails(Contact con,String jobrole,string salutation, String phoneCode,List<String> userpermission){
        try{
            
            Contact conCheck = [Select Id, firstName, lastName, email From Contact Where Id =: con.Id Limit 1];
            if(conCheck.FirstName != con.FirstName || conCheck.LastName != con.LastName){
                String fullNameForSearch = con.FirstName.trim() + ' ' + con.LastName.trim();
                List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
                                                      RETURNING Contact(ID WHERE email=:con.Email.trim()) ];
                System.Debug('searchNameList' + ' => ' + searchNameList[0].size());
                
                if(searchNameList[0].size() > 0 ){   // if Name is Changed
                    return 'Duplicate Name';
                }
            }else if(conCheck.email != con.Email){
                
                list<user> userlistEmail = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                            from user where profile.UserLicense.Name ='Customer Community Login' 
                                            and email =:con.Email.trim()];
                System.Debug('userlistEmail' + ' => ' + userlistEmail);
                
                if(userlistEmail.size() > 0 ){	
                    return 'Duplicate Email';
                }
            }
            
            con.Job_role__c = jobrole;
            con.Salutation=salutation;
            con.Phone_Code__c = phoneCode;
            con.Additional_Permission__c = format(userpermission);
            //con.Additional_User__c = true;
            update con;
            user ust = [select id,contactid,firstname,lastname,title,phone from user where contactid=:con.id];
            user us = new user();
            us.id = ust.id;
            us.title=con.Salutation;
            us.FirstName=con.FirstName;
            us.LastName =con.LastName;
            us.Phone=con.Phone;
            us.User_Role__c = jobrole;
            us.Addition_Permission__c = format(userpermission);
            update us;
            
            return 'No Duplicate';
        }catch(Exception e){
            return e.getMessage();
        }
    } 
    
    @AuraEnabled
    public static String checkDuplicateEmailForADD(String email, String firstname, String surname){
        
        String fullNameForSearch = firstname.trim() + ' ' + surname.trim();
        String currentEmail ;
        System.debug('fullNameForSearch ' + fullNameForSearch);
        list<user> userlistEmail = [select id,username,ContactId,profile.UserLicense.Name ,phone,email,name,IsActive 
                                    from user where profile.UserLicense.Name ='Customer Community Login' 
                                    and email =:email];
        System.Debug('userlistEmail' + ' => ' + userlistEmail);
        List<List<SObject>> searchNameList = [FIND :fullNameForSearch IN ALL FIELDS 
                                              RETURNING Contact(ID WHERE email=:email.trim()) ];
        System.Debug('searchNameList' + ' => ' + searchNameList[0].size());
        
        if(userlistEmail.size() > 0 ){	
            return 'Duplicate Email';
        }else if(searchNameList[0].size() > 0 ){   // if Name is Changed
            return 'Duplicate Name';
        }
        
        return 'No duplicate'; 
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