public without sharing class EI_headOfficeUtility{
    // A Visualforce controller class that creates a cookie
// used to keep track of how often a user displays a page


    public static string CookieController() {
        Cookie counter = ApexPages.currentPage().getCookies().get('counter');
    
        // If this is the first time the user is accessing the page, 
        // create a new cookie with name 'counter', an initial value of '1', 
        // path 'null', maxAge '-1', and isSecure 'true'. 
        if (counter == null) {
            counter = new Cookie('counter','1',null,-1,true);
        } else {
        // If this isn't the first time the user is accessing the page
        // create a new cookie, incrementing the value of the original count by 1
            Integer count = Integer.valueOf(counter.getValue());
            counter = new Cookie('counter', String.valueOf(count+1),null,-1,true);
        }
    
        // Set the new cookie for the page
        ApexPages.currentPage().setCookies(new Cookie[]{counter});
        String cookieCounter = String.valueOf(counter);
        return cookieCounter;
    }

    // This method is used by the Visualforce action {!count} to display the current 
    // value of the number of times a user had displayed a page. 
    // This value is stored in the cookie.


    
    
    public EI_headOfficeUtility(){
    }
    
    /********************************
*         Utility Method      *
********************************/
    //Utility Method Used by CreateUserUnderHO.cls => getAccountDetails()=> To get Account Details
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
    
    //Method to get current Date
    @AuraEnabled
    public static String getCurrentDate(){
        try{
            Date dToday = Date.today();
            String dateStr = Date.today().format();
            DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String dateStr1 = dt.format('yyyy-MM-dd');
            return dateStr1;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Method to get current Logged In User Details
    @AuraEnabled
    public static String getLoggedInUserDetail(){
        try{
            return userinfo.getName();
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Method to get current Logged In User Profile
    @AuraEnabled
    public static String getLoggedInUserProfile(){
        try{
            String profileName = [SELECT
                                  	Profile.Name
                                  FROM
                                  	User
                                  WHERE
                                  	Id=:UserInfo.getUserId()	
                                 ]?.Profile.Name;
            return profileName;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
      @AuraEnabled
    public static list<Deposit_Allocation__c> loggedintenantdeposits(){
        user userrec = [select id,FirstName, LastName, Email,AccountId, ContactId from user where id = :UserInfo.getUserId()];
        list<Deposit_Allocation__c> Depositlist =[select id,Deposit__r.Active__c,Deposit__c, Deposit_Status__c,
                        Deposit_Holder__r.personemail from Deposit_Allocation__c  
                        where Deposit_Holder__c IN (SELECT accountid from User where Id = :UserInfo.getUserId())
                                     and  Deposit_Holder__r.personemail=:userrec.Email and Deposit_Status__c=:Label.Validated] ;  
        return Depositlist; 
    }
    
    
    //Utility Method Used by CreateUserUnderHO.cls =>To fetch all the Branch under account
    @AuraEnabled
    public static getBranchList getAllBranches(String accId, Boolean isActive){
        try{
            getBranchList brList = new getBranchList();
            List<branch__c> br = [SELECT Id, Branch_Name__c
                                  FROM branch__c
                                  where Account__c = :accId and Is_Active__c = :isActive];
            if (br.size() > 0){
                brList.branchList.addAll(br);
                return brList;
            }
            return null;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Utility method to update user once contact is updated
    @AuraEnabled
    public static contactUserDetail updateUser(Contact con){
        try{
            contactUserDetail cud = new contactUserDetail();
            update con;
            cud.con = con;
            User conUsr = new User();
            for (User u : [SELECT Id
                           FROM User
                           where ContactId = :con.Id
                           LIMIT 1]){
                               u.FirstName = con.FirstName;
                               u.LastName = con.LastName;
                               u.Email = con.Email;
                              // u.Username = con.Email;
                               u.Phone = con.Phone;
                               update u;
                               cud.usr = u;
                           }
            return cud;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    // Utility method to return contact and user information of user
    // This method return user and contact information
    @AuraEnabled(cacheable = true)
    public static User fetchConUserDetails(String userId){
        try{
            
            for (User u : [SELECT Id, Contact.FirstName, Contact.LastName, contact.Email, Contact.Phone, Contact.Salutation, Contact.Job_role__c, Contact.Job_title__c, Contact.Property_Name__c, Contact.MailingStreet, Contact.MailingState, Contact.MailingPostalCode, Contact.MailingCountry, Contact.MailingCity, Contact.Marketing_Agreement__c, Contact.Prescribed_Information_Clauses__c, Contact.Newsletter_Subscription__c
                           FROM USER
                           where Id = :userId
                           LIMIT 1]){
                               return u;
                           }
            return null;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /********************************
*         Wrapper Classes      *
********************************/
    //Wrapper class used by CreateUserUnderHO.cls getUserDetails() => To get User and List of Branch User Mapping
    public class hoUserDetails{
        @AuraEnabled
        public User usr{ get; set; }
         @AuraEnabled
        public Contact con{ get; set; }
        @AuraEnabled
		public List<String> selectedPermission{ get; set; }
                @AuraEnabled
		public List<String> selectedbranchList{ get; set; }
        @AuraEnabled
        public List<Branch_User_Mapping__c> bum{ get; set; }
        
        public hoUserDetails(){
            bum = new List<Branch_User_Mapping__c>();
        }
    }
    
    // Wrapper class used by  => Data type of branch
    public class getBranchList{
        @AuraEnabled
        public List<branch__c> branchList{ get; set; }
        
        public getBranchList(){
            branchList = new List<branch__c>();
        }
    }
    
    //Wrapper class for User & Contact => Used by updateUser(Contact con) method above
    public class contactUserDetail{
        @AuraEnabled
        public Contact con{ get; set; }
        
        @AuraEnabled
        public User usr{ get; set; }
    }
    
   
     @AuraEnabled
    public static List<Deposit_Allocation__c> tenantCount( ){
        
      return  EI_TenantNotificationClass.getdepositstatus();
    }
    
      @auraEnabled
    public static List<Deposit__c> landlordCount(){
        
       return EI_LandlordAgentNotificationclass.getLandLordStatus();
      
    }
}