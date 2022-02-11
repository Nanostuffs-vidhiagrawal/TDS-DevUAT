public without sharing class EI_getBranch{
        public EI_getBranch(){
        }
    
        //Method used by ViewBranchHO.cmp
        @AuraEnabled
        public static Account orgDetails(){
            try{
                Account acc = [SELECT Id, Name
                               FROM Account
                               WHERE Associated_To__c = :UserInfo.getUserId()
                               LIMIT 1];
                return acc;
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static List<Branch__c> getBranchList(){
            User u = [Select id,Account.Associated_To__c,AccountId,profile.name,contactid from user where id =: userInfo.getUserId()];
        //	String UserId = UserInfo.getUserId();
            try{
                    List<Branch__c> branches = new List<Branch__c>();
                if(u.profile.name == 'Head Office User'){
                 branches =   [Select Account__c,Id,Name, Branch_Name__c, Address__c, Alt_telephone_no__c, Branch_ID__c, Country__c, County__c, Dispute_resolution_e_mail__c, Fax__c, Finance_e_mail__c, General_correspondence_e_mail__c, Is_Active__c, Postcode__c, Telephone_no__c, Town_City__c, Website__c
                                            from Branch__c
                                            where Account__c =:u.AccountId  and Is_Active__c = true
                                            ORDER BY Branch_Name__c];
                }
                else{
                branches = [Select Account__c,Id, Branch_Name__c,Name, Address__c, Alt_telephone_no__c, Branch_ID__c, Country__c, County__c, Dispute_resolution_e_mail__c, Fax__c, Finance_e_mail__c, General_correspondence_e_mail__c, Is_Active__c, Postcode__c, Telephone_no__c, Town_City__c, Website__c
                                            from Branch__c
                                            where id in (Select Branch__c from Branch_User_Mapping__c where User__c =: u.id) and Is_Active__c = true
                                            ORDER BY Branch_Name__c];
                }
                System.debug(branches);
                return branches;
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static Branch__c createBranch(Branch__c branch,string telephoneCode, string altphoneCode,string street,string Town,string county,string country,string postcode ){
            String UserId = UserInfo.getUserId();
             id branchRecTypeId = Schema.SObjectType.Branch__c.getRecordTypeInfosByDeveloperName().get('SDS_Branch').getRecordTypeId();
            try{
                Account acc = [Select Id
                               from Account
                               where Associated_To__c = :UserId
                               limit 1];
                branch.RecordTypeId = branchRecTypeId;
                branch.Account__c = acc.Id;
                branch.Phone_Code__c = telephoneCode;
                branch.Alt_Phone_Code__c = altphoneCode;
                branch.Address__c =street;
                branch.Town_City__c=Town;
                branch.County__c = county;
                branch.Country__c=country;
                branch.Postcode__c=postcode;
                insert branch;
                return branch;
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static Branch__c fetchBranch(String branchId){
            try{
                Branch__c branch = [SELECT Id, IsDeleted, Name, Account__c, Is_Active__c, Branch_Name__c, Branch_ID2__c, Telephone_no__c, Alt_telephone_no__c, Fax__c, Website__c, Postcode__c, Address__c, Town_City__c, County__c, Country__c, General_correspondence_e_mail__c, Dispute_resolution_e_mail__c, Finance_e_mail__c
                                    FROM branch__c
                                    where Id = :branchId];
                return branch;
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static Branch__c updateBranch(Branch__c branch, String telephoneCode, String altphoneCode){
            try{
                branch.Phone_Code__c = telephoneCode;
                branch.Alt_Phone_Code__c = altphoneCode;
                update branch;
                return branch;
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static string inactiveBranch(String branchId){
            try{
                Branch__c br = [Select Id
                                from Branch__c
                                where Id = :branchId
                                limit 1];
                br.Is_Active__c = false;
                update br;
                return 'Success';
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static string activeBranch(String branchId){
            try{
                Branch__c br = [Select Id
                                from Branch__c
                                where Id = :branchId
                                limit 1];
                br.Is_Active__c = true;
                update br;
                return 'Success';
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static List<Contact> getUsers(String branchId){
            try{
                Set<Id> contacts = new Set<Id>();
                List<Branch_User_Mapping__c> branchUserList = [Select Id, User__r.ContactId
                                                               from Branch_User_Mapping__c
                                                               where Branch__c = :branchId and user__r.id !=:userInfo.getUserId() and Job_Role__c != null];
                for (Branch_User_Mapping__c b : branchUserList){
                    contacts.add(b.User__r.ContactId);
                }
                List<Contact> conlist = [Select Id, firstName, lastName, Name, Salutation
                                         from Contact
                                         where Id in :contacts];
                System.debug(conlist);
                return conlist;
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static List<Branch__c> getfilteredBranch(String branchStatus){
            String UserId = UserInfo.getUserId();
            try{
                if (branchStatus == 'open'){
                    List<Branch__c> branches = [Select Account__c, Branch_Name__c, Address__c, Alt_telephone_no__c, Branch_ID__c, Country__c, County__c, Dispute_resolution_e_mail__c, Fax__c, Finance_e_mail__c, General_correspondence_e_mail__c, Is_Active__c, Postcode__c, Telephone_no__c, Town_City__c, Website__c
                                                from Branch__c
                                                where Account__r.Associated_To__c = :UserId and Is_Active__c = true
                                                ORDER BY Branch_Name__c];
                    System.debug(branches);
                    return branches;
                } else if (branchStatus == 'closed'){
                    List<Branch__c> branches = [Select Account__c, Branch_Name__c, Address__c, Alt_telephone_no__c, Branch_ID__c, Country__c, County__c, Dispute_resolution_e_mail__c, Fax__c, Finance_e_mail__c, General_correspondence_e_mail__c, Is_Active__c, Postcode__c, Telephone_no__c, Town_City__c, Website__c
                                                from Branch__c
                                                where Account__r.Associated_To__c = :UserId and Is_Active__c = false
                                                ORDER BY Branch_Name__c];
                    System.debug(branches);
                    return branches;
                } else if (branchStatus == 'all'){
                    List<Branch__c> branches = [Select Account__c, Branch_Name__c, Address__c, Alt_telephone_no__c, Branch_ID__c, Country__c, County__c, Dispute_resolution_e_mail__c, Fax__c, Finance_e_mail__c, General_correspondence_e_mail__c, Is_Active__c, Postcode__c, Telephone_no__c, Town_City__c, Website__c
                                                from Branch__c
                                                where Account__r.Associated_To__c = :UserId
                                                ORDER BY Branch_Name__c];
                    System.debug(branches);
                    return branches;
                } else{
                    return null;
                }
            } catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static Map<String, String> getCountries(){
            Map<String, String> options = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = Branch__c.Country__c.getDescribe();
            List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry p : pList){
                options.put(p.getValue(), p.getLabel());
            }
            return options;
        }
    
        @AuraEnabled
        public static string userEmail(){
            try{
                String UserId = UserInfo.getUserId();
                User u = [SELECT EMAIL
                          FROM User
                          where Id = :UserId];
                return u.email;
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