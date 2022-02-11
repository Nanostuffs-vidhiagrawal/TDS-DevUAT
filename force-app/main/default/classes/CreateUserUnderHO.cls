public without sharing class CreateUserUnderHO{
	public CreateUserUnderHO(){
	}

	//Method used by manageHOUsersController.js => To get Account Details
	@AuraEnabled
	public static Account getAccountDetails(){
		try{
			Account acc = EI_headOfficeUtility.orgDetails();
			return acc;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static string contactCreateHO(Contact con){
		try{
			con.AccountId = '0013H0000086Yp4';
			//con.OwnerId = UserInfo.getUserId();
			insert con;

			User u = new User();
			u.FirstName = con.FirstName;
			u.LastName = con.LastName;
			u.Alias = u.FirstName + u.LastName;
			u.Username = con.Email + 'abc';
			u.Email = con.Email;
			u.ProfileId = [Select Id
			               from profile
			               where Id = '00e3H000000LyOHQA0'
			               limit 1].Id;
			u.CommunityNickname = u.Alias;
			u.TimeZoneSidKey = 'Europe/London';
			u.LocaleSidKey = 'en_GB';
			u.LanguageLocaleKey = 'en_US';
			u.ContactId = con.Id;
			u.EmailEncodingKey = 'ISO-8859-1';
			//     insert u;
			//     return u.Id;
			return con.Id;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}
public static String format(List<String> values) {
    if (values == null) return null;
    return String.join(values, ';');
}
	// Create  User under branch
	@AuraEnabled
	public static String createBranchUser(Contact con, List<String> branchList, String salutation, String contactPhoneCode, String jobRole,List<String> permissions){
		system.debug(permissions+' @@ '+branchList);
      
        try{
            List<Branch_User_Mapping__c> branchUserList = new List<Branch_User_Mapping__c>();
			List<Branch__c> br = [Select Id, Account__c
			                      from Branch__c
			                      where Branch_Name__c in:branchList];
           
			if (br.size() > 0){
				con.AccountId = br[0].Account__c;
				con.Salutation = salutation;
                con.Phone_Code__c = contactPhoneCode;
                con.Job_role__c = jobRole;
                con.Additional_Permission__c = format(permissions);
             //   con.Additional_User__c = true;
				insert con;
            
				if (con.Id != null){

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


					u.FirstName = con.FirstName;
					u.LastName = con.LastName;

					// Uncomment
					u.Username = con.Email;
					//u.Username = con.Email + 'abc';
					u.Email = con.Email;

					// Fetch Profile of BranchUser
					//String BranchUserProfileId = Label.BranchUserProfileId;
					u.ProfileId = [Select Id
					               from profile
					               where Name ='Branch User'
					               limit 1].Id;

					u.TimeZoneSidKey = 'Europe/London';
					u.LocaleSidKey = 'en_GB';
					u.LanguageLocaleKey = 'en_US';
					u.ContactId = con.Id;
					u.EmailEncodingKey = 'ISO-8859-1';
					u.User_Type__c = 'Agent';
					u.Business_Type__c = 'Head Office User';
                    u.User_Role__c = jobRole;
                   
                  
					insert u;
					
                    system.debug('@@user '+u);
					if (u.Id != null){
                        for(Branch__c branch : br){
                            Branch_User_Mapping__c bum = new Branch_User_Mapping__c();
                            bum.Branch__c = branch.Id;
                            bum.User__c = u.Id;
                            bum.Job_role__c = jobRole;
                            bum.Additional_Permission__c = format(permissions);
                        	branchUserList.add(bum);
                   		 }
                        if(branchUserList.size()>0){
                            insert branchUserList;
                              system.debug('@@branchUserList '+branchUserList);
                        }
						
					}
                    
                   
				}
				
			}
			return 'SUCCESS';
		} catch (Exception e){
            return e.getMessage();
			//throw new AuraHandledException(e.getMessage());
		}
            
	}

	// Method used by userCreateHOCOntroller.js => To get all the branches under HO
	@AuraEnabled
	public static Map<String, String> getHObranches(String accountId){
		try{
			Map<String, String> branchMap = new Map<String, String>();
			List<branch__c> branchList = [SELECT Id, Branch_Name__c
			                              FROM branch__c
			                              where Account__c = :accountId and Is_Active__c = true];
			if (!branchList.isEmpty()){
				for (branch__c br : branchList){
					branchMap.put(br.Id, br.Branch_Name__c);
				}
			}
			return branchMap;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

    @AuraEnabled
	public static List<Branch__c> getBranches(){
		return EI_getBranch.getBranchList();
	}
    
	@AuraEnabled
	public static List<Map<String, String>> getJobRoles(){
		try{
			List<Map<String, String>> listOFMap = new List<Map<String, String>>();
			Map<String, String> jobRoles = new Map<String, String>();
			Schema.DescribeFieldResult fieldResultjobRoles = Branch_User_Mapping__c.Job_role__c.getDescribe();
			List<Schema.PicklistEntry> pListjobRoles = fieldResultjobRoles.getPicklistValues();
			for (Schema.PicklistEntry p : pListjobRoles){
				jobRoles.put(p.getValue(), p.getLabel());
			}
			listOFMap.add(jobRoles);
			Map<String, String> salutation = new Map<String, String>();
			Schema.DescribeFieldResult fieldResultsalutation = Contact.Salutation.getDescribe();
			List<Schema.PicklistEntry> pListsalutation = fieldResultsalutation.getPicklistValues();
			for (Schema.PicklistEntry p : pListsalutation){
				salutation.put(p.getValue(), p.getLabel());
			}
			listOFMap.add(salutation);

			Map<String, String> hoJobRoles = new Map<String, String>();
			Schema.DescribeFieldResult fieldResulthoJobRoles = Contact.Job_role__c.getDescribe();
			List<Schema.PicklistEntry> pListhoJobRoles = fieldResulthoJobRoles.getPicklistValues();
			for (Schema.PicklistEntry p : pListhoJobRoles){
				hoJobRoles.put(p.getValue(), p.getLabel());
			}
            listOFMap.add(hoJobRoles);
            Map<String, String> hopermission = new Map<String, String>();
			Schema.DescribeFieldResult fieldResulthoPermission = Contact.Additional_Permission__c.getDescribe();
			List<Schema.PicklistEntry> pListhopermission = fieldResulthoPermission.getPicklistValues();
			for (Schema.PicklistEntry p : pListhopermission){
				hopermission.put(p.getValue(), p.getLabel());
			}
            
            listOFMap.add(hopermission);

			

			return listOFMap;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	// Method to UPDATE user in Branch
	@AuraEnabled
	public static userInformation updateBranchUser(Contact con, List<String> branchList, String salutation, String contactPhoneCode, String jobRole, List<String> permissions){
		try{
			userInformation ui = new userInformation();
            con.Additional_Permission__c = format(permissions);
            con.Job_role__c = jobRole;
			con.Salutation = salutation;
            con.Phone_Code__c = contactPhoneCode;
           // con.Additional_User__c = true;
			UPDATE con;
            List<String> branchIdList = new List<String>();
			if (con.Id != null){
               /* for(string key: branchList){
                    string branchId = key.split('-')[0];
                    branchIdList.add(branchId.deleteWhitespace());
                }*/
                List<Branch_User_Mapping__c> newBranchMap = new List<Branch_User_Mapping__c>();
                List<Branch__c> branches= [Select id,Branch_Name__c from Branch__c where Branch_Name__c in:branchList];
				List<Branch_User_Mapping__c> bum = [SELECT Id,Branch__r.Branch_Name__c,User__r.Id, Job_role__c, Job_title__c, User__c, User__r.FirstName, User__r.LastName, User__r.Email
				                              FROM Branch_User_Mapping__c WHERE User__c IN (SELECT ID FROM User WHERE contactId =:con.Id)];
                
               
                for(Branch__c brnch: branches){
                  Branch_User_Mapping__c branchmap = new Branch_User_Mapping__c();
                    branchmap.Job_role__c = jobRole;
                    branchmap.Branch__c = brnch.Id;
                    branchmap.User__c = bum[0].User__r.Id;
                    branchmap.Additional_Permission__c = format(permissions);
                   // branchmap.Branch
                      newBranchMap.add(branchmap);
                }
             
                
                insert newBranchMap;
				   delete bum;
			
			
				
				User u = new User(Id = newBranchMap[0].User__c,User_Role__c=jobRole,FirstName = con.FirstName, LastName = con.LastName, Email = con.Email);

				update u;
				//ui.con = con;
				//ui.bum = bum;


			}

			return ui;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	//Method to inactivate User in Branch
	@AuraEnabled
	public static Boolean inactiveBranchUser(String userId){
		try{
			User u = [Select Id
			          from User
			          where Id = :userId];
			u.IsActive = false;
			update u;
			return u.IsActive;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}
    
    //Method to inactivate User in Branch
	@AuraEnabled
	public static Boolean inactiveUser(String userId){
		try{
			User u = [Select Id
			          from User
			          where ContactId = :userId];
			u.IsActive = false;
			update u;
			return u.IsActive;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	//Method to reactivate User in Branch
	@AuraEnabled
	public static Boolean reactiveBranchUser(String userId){
		try{
			User u = [Select Id
			          from User
			          where Id = :userId];
			u.IsActive = true;
			update u;
			return u.IsActive;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}
    
    //Method to reactivate User in Branch
	@AuraEnabled
	public static Boolean reactiveUser(String userId) {
		try{
			User u = [Select Id
			          from User
			          where ContactId = :userId];
			u.IsActive = true;
			update u;
			return u.IsActive;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static userInformation getSelectedBranchUser(String userId){
		try{
			userInformation ui = new userInformation();
			ui.con = [SELECT Id, firstName, lastName, email, phone_Code__c, phone, salutation, Job_role__c,Additional_Permission__c
			          FROM CONTACT
			          where Id = :userId];
            System.debug('ui.con='+ui.con);
            ui.selectedPermission =  new List<String>();
              if(ui.con.Additional_Permission__c != NULL ){
                 List<String> splitString= ui.con.Additional_Permission__c.split(';');
                system.debug('splitString '+splitString.size());
                for(String str : splitString){
                      system.debug('str '+str);
                    ui.selectedPermission.add(str);
                     system.debug('ui.selectedPermission '+ui.selectedPermission);
                }
              }
            ui.selectedbranchList =  new List<String>();
            ui.allbranchList = new List<String>();
                for(Branch_User_Mapping__c selectedBranch:[SELECT id,Branch__r.name,Branch__r.id,Branch__r.Branch_Name__c FROM Branch_User_Mapping__c WHERE User__r.ContactId = :userId])
            {
                system.debug('@@ '+selectedBranch.Branch__r.Branch_Name__c);
                String branchName = selectedBranch.Branch__r.Branch_Name__c;
                ui.selectedbranchList.add(branchName);
            }
			//ui.bum = [SELECT Branch__r.Branch_Name__c FROM Branch_User_Mapping__c WHERE User__r.ContactId = :userId];
			ui.branchList = EI_getBranch.getBranchList();
            for(Branch__c branch : ui.branchList){
                  String branchName = branch.Branch_Name__c;
                ui.allbranchList.add(branchName);
            }
			ui.us = [SELECT Id, IsActive
			         FROM User
			         where contactId = :userId];
			return ui;
		} catch (Exception e){
            
			throw new AuraHandledException(e.getMessage());
		}
	}

	// Create Head Office User used by userCreateHO method
	@AuraEnabled
	public static Contact createHOUser(Contact con,string jobRole,string salutation,string phoneCode,List<string> additionPermission, List<String> selectedValues){
		try{

			Account acc = [SELECT Id
			               FROM Account
			               WHERE Associated_To__c = :UserInfo.getUserId()
			               LIMIT 1];
			con.AccountId = acc.Id;
//con.Additional_User__c = true;
            con.Salutation=salutation;
            con.Phone_Code__c=phoneCode;
            con.Additional_Permission__c = format(additionPermission);
            con.Job_role__c=jobRole;
			insert con;

			if (con.Id != null){
				Id profileId = userinfo.getProfileId();
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
				u.Title=con.Salutation;
				u.FirstName = con.FirstName;
				u.LastName = con.LastName;

				u.User_Type__c = 'Agent';
				u.Business_Type__c = 'Head Office User';

				// Uncomment
				u.Username = con.Email;
				//u.Username = con.Email + 'abc';
				u.Email = con.Email;
				u.ProfileId = [Select Id
				               from profile
				               where Id = :profileId
				               limit 1].Id;

				u.TimeZoneSidKey = 'Europe/London';
				u.LocaleSidKey = 'en_GB';
				u.LanguageLocaleKey = 'en_US';
				u.ContactId = con.Id;
                u.User_Role__c = con.Job_role__c;
               // u.Addition_Permission__c = con.Additional_Permission__c;
				u.EmailEncodingKey = 'ISO-8859-1';
				insert u;
				if (u.Id != null){
					if (!selectedValues.isEmpty()){
						List<Branch_User_Mapping__c> bumList = new List<Branch_User_Mapping__c>();
						for (String s : selectedValues){
							Branch_User_Mapping__c bum = new Branch_User_Mapping__c();
							bum.Branch__c = s;
							bum.User__c = u.Id;
							bum.Job_Role_HO__c = con.Job_role__c;
                            bum.Additional_Permission__c = con.Additional_Permission__c;
							bumList.add(bum);
						}
						insert bumList;
					}
				}
			}
			return con;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	// Update Head Office User used by EI_userEditHOController.js
	@AuraEnabled
	public static String updateHOUser(Contact con, string phoneCode, List<String> userpermission, string jobrole, string salutation){
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
			// Update con;
		/*	EI_headOfficeUtility.contactUserDetail cud = new EI_headOfficeUtility.contactUserDetail();
            con.Phone_Code__c = phoneCode;
			cud = EI_headOfficeUtility.updateUser(con);
			if (selectedValues.size() > 0){
				User u = [Select Id
				          from user
				          where ContactId = :con.Id];

				List<Branch_User_Mapping__c> insertListofBum = new List<Branch_User_Mapping__c>();
				List<Branch_User_Mapping__c> updateListofBum = new List<Branch_User_Mapping__c>();

				List<Branch_User_Mapping__c> listofBum = [SELECT Id, Branch__c, Is_Active__c,Job_role__c,Additional_Permission__c
				                                          FROM Branch_User_Mapping__c
				                                          where user__c = :u.Id and Branch__c in :selectedValues];

				Map<ID, Branch_User_Mapping__c> bumMap = new Map<ID, Branch_User_Mapping__c>();


				for (Branch_User_Mapping__c b : listofBum){
					bumMap.put(b.branch__c, b);
				}

				if (listofBum.size() > 0){
					for (String s : selectedValues){
						if (bumMap.containsKey(s)){
							if (bumMap.get(s).Is_Active__c){
								updateListofBum.add(new Branch_User_Mapping__c(Id = bumMap.get(s).Id, Is_Active__c = false));
							} else{
								updateListofBum.add(new Branch_User_Mapping__c(Id = bumMap.get(s).Id, Is_Active__c = true));
							}
						} else{
							insertListofBum.add(new Branch_User_Mapping__c(user__c = u.Id, branch__c = s));
						}
					}
				} else{
					for (String s : selectedValues){
						insertListofBum.add(new Branch_User_Mapping__c(user__c = u.Id, branch__c = s));
					}
				}
				if (updateListofBum.size() > 0){
					update updateListofBum;
				}

				if (insertListofBum.size() > 0){
					insert insertListofBum;
				}
			}
			return cud;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		} */
	}

	// For manageHOUsers lightning Component
	@AuraEnabled
	public static List<User> getHeadOfficeUsers(){
		try{
			List<User> headOfficeUserList = [SELECT Id, FirstName, LastName, Email, IsActive, ContactId,Contact.User_Status__c,Contact.Phone_Code__c, Contact.Phone,Contact.Job_role__c, Contact.Email, Contact.FirstName, Contact.LastName, Contact.Salutation
			                                 FROM User
			                                 where Id !=: UserInfo.getUserId() and profileId =: Userinfo.getProfileId() and Account.Associated_To__c = :UserInfo.getUserId()];
			return headOfficeUserList;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	/*
	 Wrapper Class for getHeadOfficeUsers method
	 public class headOfficeUsers{
	 @AuraEnabled
	 public List<Contact> conList{ get; set; }
	 @AuraEnabled
	 public List<User> userList{ get; set; }
	 } */
	// Wrapper Class for getSelectedBranchUser method
	public class userInformation{
		@AuraEnabled
		public Contact con{ get; set; }

         @AuraEnabled
		public List<String> selectedPermission{ get; set; }
        
		@AuraEnabled
		public List<Branch_User_Mapping__c> bum{ get; set; }
        
         @AuraEnabled
		public List<String> allbranchList{ get; set; }
        
        @AuraEnabled
		public List<Branch__c> branchList{ get; set; }
		 @AuraEnabled
		public List<String> selectedbranchList{ get; set; }
		@AuraEnabled
		public User us{ get; set; }
	}

	//Method used by EI_userEditHOController.js => To retrive User and its branch Mapping
	@AuraEnabled
	public static EI_headOfficeUtility.hoUserDetails getUserDetails(String userId){
		try{
			EI_headOfficeUtility.hoUserDetails ut = new EI_headOfficeUtility.hoUserDetails();
			if (String.isNotBlank(userId)){
				ut.selectedPermission =  new List<String>();

				ut.usr = [SELECT Id, IsActive,Addition_Permission__c,User_Role__c, Contact.FirstName,Contact.Additional_Permission__c ,Contact.LastName, contact.Email, Contact.Phone_COde__c, Contact.Phone, Contact.Salutation, Contact.Job_role__c, Contact.Job_title__c
				          FROM USER
				          where Id = :userId
				          LIMIT 1];
                 system.debug(ut.usr+'  ## ' +ut.usr.Contact.Job_role__c +'ut.usr.Contact.Additional_Permission__c '+ut.usr.Contact.Additional_Permission__c);
               if(ut.usr.Contact.Additional_Permission__c != NULL ){
                            List<String> splitString= ut.usr.Contact.Additional_Permission__c.split(';');
                        system.debug('splitString '+splitString.size());
                        for(String str : splitString){
                              system.debug('str '+str);
                            ut.selectedPermission.add(str);
                             system.debug('ut.selectedPermission '+ut.selectedPermission);
                        }
                     }else{
                         String str = '';
                         ut.selectedPermission.add(str);
                     }
				List<Branch_User_Mapping__c> bumList = [SELECT Id, User__c,Additional_Permission__c,Job_role__c, User__r.Name, Branch__c, Branch__r.Branch_Name__c
				                                        FROM Branch_User_Mapping__c
				                                        where User__c = :userId and Is_Active__c = true];
				if (bumList.size() > 0)
					ut.bum.addAll(bumList);
			}
			return ut;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	// Method used by EI_userEditHOController.js => To fetch all the Branch under account
	@AuraEnabled
	public static EI_headOfficeUtility.getBranchList getBranchesUnderAccount(String accountId){
		Boolean isActive = true;
		try{
			EI_headOfficeUtility.getBranchList branches = new EI_headOfficeUtility.getBranchList();
			branches = EI_headOfficeUtility.getAllBranches(accountId, isActive);
			return branches;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	// This method return User info including his contact details
	@AuraEnabled(cacheable = true)
	public static User getHOdetails(){
		try{
			String logged_In_User_Id = UserInfo.getUserId();
			if (String.isNotBlank(logged_In_User_Id)){
				User u = EI_headOfficeUtility.fetchConUserDetails(logged_In_User_Id);
				return u;
			}
			return null;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	// This method return User info including his contact details
	@AuraEnabled
	public static EI_headOfficeUtility.contactUserDetail updateHOuser(Contact con){
		try{
			EI_headOfficeUtility.contactUserDetail cu = new EI_headOfficeUtility.contactUserDetail();
			cu = EI_headOfficeUtility.updateUser(con);
			return cu;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}
    
    @AuraEnabled
    public static List<String> getPhoneCodePiclistValues(){
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