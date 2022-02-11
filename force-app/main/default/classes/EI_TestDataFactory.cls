public class EI_TestDataFactory {
	public static List<case> createDispute( Integer numberOfClients,id deposit) 
    {
           id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
        List<case> Disputes = new List<case>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            case  dispute= new case(RecordTypeId=recTypeId,
                                    Amount_Paid_to_Tenant__c = 100,
                                    Amount_Paid_to_Landlord__c = 100,
                                    ChangeOver_Status__c = '',
                                    Dispute_Initiated_By__c ='Landlord',
                                    Total_Claim_Amount__c=700.00,
                                    Deposit_Account_Number__c =deposit,
                                    status ='New'
                                   );
            Disputes.add( dispute);
        }
        
        return Disputes;
    }
       public static List<Case_Participant__c> createCaseParticipant ( Integer numberOfClients,id caseid,id AccountId,string type) 
    {
        List<Case_Participant__c> caseParties = new List<Case_Participant__c>();
        id  conId=[select id,PersonContactId from Account where id =:AccountId].PersonContactId;
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Case_Participant__c  caseParti= new Case_Participant__c(Case__c =caseid,
                                                                    Account__c =AccountId,
                                                                    Type__c=type,
                                                                    contact__c =conId 
                                                                   );
            caseParties.add(caseParti);
        }
        
        return caseParties;
    }
       
    
    public static List<Account> createagent( Integer numberOfClients) 
    {
             id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Letting Agent').getRecordTypeId();
     
    
        List<Account> accounts = new List<Account>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Account account = new Account(FirstName='test',
                                          LastName='agent Name'+ i,
                                          PersonEmail='abcd'+i+'@test.com',
                                          Agent_External_ID__c ='agent'+i,
                                          PersonTitle='Mr',
                                          PersonMobilePhone='+916754343547',
                                          RecordTypeId=recTypeId);
            accounts.add( account);
        }
        return accounts;
    }
    public static List<Account> createLandlord( Integer numberOfClients) 
    {
        id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual Landlord').getRecordTypeId();
         List<Account> accounts = new List<Account>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Account account = new Account(FirstName='test',
                                          LastName='landlord Name'+ i,
                                          PersonEmail='landlord'+i+'@test.com',
                                          Landlord_External_ID__c ='landlord'+i,
                                          BillingCity='Bijnor',
                                          BillingStreet='xyz',
                                          BillingCountry='India',
                                          BillingPostalCode ='246701',
                                          Phone='+916754343547',
                                          RecordTypeId=recTypeId);
            accounts.add( account);
        }
        return accounts;
    }
    public static List<Account> createTenant( Integer numberOfClients) 
    {
      id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Tenant').getRecordTypeId();
           List<Account> accounts = new List<Account>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Account account = new Account(FirstName='test',
                                          LastName='Tenant Name'+ i,
                                          PersonEmail='tenant'+i+'@test.com',
                                          Tenant_External_ID__c ='8988'+i,
                                          Phone='+916754343547',
                                          RecordTypeId=recTypeId);
            accounts.add( account);
        }
        return accounts;
    }
    
    public static List<Property__c> createProperty( Integer numberOfClients,id ownerID) 
    {
        id recTypeId = Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('SDS Property').getRecordTypeId();
     
              List<Property__c> propperties = new List<Property__c>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Property__c property = new Property__c(City__c='xyz',
                                                   Property_status__c = 'Active',
                                                   Country__c='xyz',
                                                   Postal_Code__c='xyz',
                                                   Street__c='xyz',
                                                   Property_Owner__c =ownerID,
                                                   RecordTypeId=recTypeId);
            propperties.add( property);
        }
        return propperties;
    }
    public static List<Deposit__c> createDeposite( Integer numberOfClients,id Scheme,id customer,id property) 
    {
          id recTypeId = Schema.SObjectType.Deposit__c.getRecordTypeInfosByName().get('SDS Deposit').getRecordTypeId();
     
              List<Deposit__c> Deposits = new List<Deposit__c>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Deposit__c deposit = new Deposit__c(End_Date__c=date.today(),
                                                Scheme__c =Scheme,
                                                Deposit_Amount__c=800.00,
                                                Customer_Type__c='Landlord',
                                                Protected_Amount__c = 800.00,
                                                External_Id__c ='deposit'+i,
                                                Start_Date__c=(date.today()).addDays(-260),
                                                Customer__c =customer,
                                                Property__c=property,
                                                Deposit_Transferred__c=true,
                                                RecordTypeId=recTypeId);
            Deposits.add( deposit);
        }
        return Deposits;
    }
      public static Scheme__c createScheme() 
     {
         Scheme__c scheme = new Scheme__c(name='SafeDeposits Scotland',
                                         Region__c='Scotland');
         return scheme;
         
     }
    public static QueryLimits__c createQueryLimit() 
    {
     QueryLimits__c queryLimit = new QueryLimits__c(CheckOn__c=true,
                                                    Name = 'All Limits');
     return  queryLimit;
    }
        
    // refactored code
    
    public static Contact getContact(){
        Contact con = new Contact();
        con.FirstName ='Harry';
        con.LastName ='Smith';
        con.Email = 'harrysmith@gmail.com';
        con.Phone = '45673245689';
        con.Phone_Code__c = '+44';
        con.HomePhone = '7756432';
        con.Salutation = 'Mr.';
        con.Marketing_Agreement__c = false; 
        con.Newsletter_Subscription__c = true; 
        return con;
        
    }
        
    public static Profile getStandardUserProfile(String name){
        Profile p = [SELECT Id,Name FROM Profile WHERE Name=:name];
        return p;
    }
    
   
    
	 public static UserRole getUserRole(){
         UserRole r = new UserRole(name = 'Adjudicator Group A', PortalType='None');
         return r;
    }
    
    
    
    public static Profile getSysAdminProfile(){
        Profile sysAdminProfile = [SELECT Id,Name FROM Profile WHERE Name='System Administrator'];
        return sysAdminProfile;
    }
    
    public static User getUserWithRole(UserRole role) {
        Profile sysAdminProfile = getSysAdminProfile();
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = role.id,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = sysAdminProfile.Id, 
                                    timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        return userWithRole;
    }
     
    public static User getUserWithProfile(Profile profile){
        User user = new User(Alias = 'newUser', Email='tdstestuser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = profile.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='tdstestuser@testorg.com');
         return user;
    }
    
    public static Profile getProfile(String name){
		Profile p = [SELECT Id,Name FROM Profile WHERE Name=:name]; 
        return p;
    }
    
    public static UserRole getUserRoleWithName(String userName){
		UserRole role = new UserRole(name = userName);
        //Database.insert(r);
        return role;
    } 
    
  	public static Account getPersonAccount(User userWithRole ){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
       	return new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
    }
    
    public static Bank_Account__c getBankAccount(Account account){
       Bank_Account__c bankAccount ;  
       bankAccount = new Bank_Account__c();
       bankAccount.Account__c = account.Id;
       bankAccount.Contact__c= account.PersonContactId;
       bankAccount.Account_Number__c='HGTY6543';
       bankAccount.Bank_Name__c='testscotlandbank';
       return bankAccount;
    }
        
    public static User getTestUser(Profile profile , Account account){
        User user = new User(  FirstName = 'TestFirstName',
                            LastName = 'TestLastName',
                            Email = 'test@user.com',
                            Username = 'test@user.com',
                            Alias = 'TestPA', 
                            TimeZoneSidKey = 'GMT', 
                            LocaleSidKey = 'en_US', 
                            EmailEncodingKey = 'UTF-8', 
                            ProfileId = profile.Id, 
                            LanguageLocaleKey = 'en_US',
                            ContactId = account.PersonContactId);
         return user;
    }
    
     public static User getTestUser(Profile profile , Contact contact){
        return new User(Username = System.now().millisecond() + 'portalUser123@test.com', ProfileId = profile.Id,
                        Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'lnamemm',
                        ContactId = contact.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles',
                        LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
          
    }
    
     public static User getUserWithProfile() {
         UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
         
         Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
         User userP = new User(Username = System.now().millisecond() + 'portalUser123@test.com', ProfileId = pProfile.Id,
             UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'manish.mishra@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'l4848',
             CommunityNickname = 'chec', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
             LanguageLocaleKey = 'en_US');
         return userP;
    }
    
    public static Account getAccountByRecordTypeId(String recordTypeInfoName, User userP) {
        System.debug(' recordTypeInfoName : '+recordTypeInfoName);
    	Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeInfoName).getRecordTypeId();
        System.debug(' devRecordTypeId : '+devRecordTypeId);
        					 //Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Letting_Agent').getRecordTypeId();
        return new Account(Name = 'TestAccount', OwnerId = userP.Id, RecordTypeId = devRecordTypeId);
    }
 
}