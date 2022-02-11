@isTest
public class EI_PendingRepaymentRequestTest {
    
    @isTest
    public static void getLoggedInUserDetail(){
        Profile profile = EI_TestDataFactory.getProfile('Standard User');
        Contact contact = EI_TestDataFactory.getContact();
        User user = EI_TestDataFactory.getUserWithProfile(profile);
        System.runAs(user){
            String userDetails = EI_PendingRepaymentRequest.getLoggedInUserDetail();
            System.assert(userDetails != null);
        }
    }
    
    @isTest
    public static void fetchRequestedPaymentByTenant(){
        Test.startTest();
        String userDetails = EI_PendingRepaymentRequest.fetchRequestedPaymentByTenant();
        Test.stopTest();
    }
    
    @isTest
    public static void getRequestRepayment(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        
        Repayment_Request__c repayReq = new Repayment_Request__c();
        repayReq.Account__c = acc.id;
        repayReq.Deposit__c = deposit.id;
        repayReq.AL_CleaningAmt__c = 50;
        repayReq.AL_DmgPropAmt__c = 100;
        repayReq.AL_GardeningAmt__c = 50;
        repayReq.AL_Repay_Requested__c = true;
        repayReq.Total_Amount_Requested_AL__c = 300;
        repayReq.Tenant_Cleaning__c= 400;
        insert repayReq;
        
        Repayment_Request_Line__c reReqLine = new Repayment_Request_Line__c();
        reReqLine.Account__c = acc.id;
        reReqLine.Repayment_Request__c = repayReq.id;
        reReqLine.AL_ReqAmt__c=700;
        reReqLine.Tenant_ReqAmt__c = 500;
        reReqLine.Requested_By__c = 'Agent/Landlord';
        insert reReqline;
        
        Test.startTest();
        Repayment_Request__c repayreq1 = EI_PendingRepaymentRequest.getRequestRepayment(deposit.id);
        System.assertEquals(repayreq1.id, repayReq.id);
        Test.stopTest();        
    }
    
    @isTest
    public static void getRequestRepaymentforElse(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        
        Test.startTest();
        Repayment_Request__c repayreq1 = EI_PendingRepaymentRequest.getRequestRepayment(deposit.id);
        System.assert(repayreq1 == null);
        Test.stopTest();        
    }
    
    @isTest
    public static void fetchBankDetails(){
         UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
        User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        insert testUser;
        
        Bank_Account__c bankAccount = EI_TestDataFactory.getBankAccount(userAcccount);
        System.runAs(userWithRole) {
            insert bankAccount;
        }
        
        Contact testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
            Test.startTest();
            List<Bank_Account__c>  bank = EI_PendingRepaymentRequest.fetchBankDetails();
            System.assert(bank != null);
            Test.stopTest();
      }  
    }
    
    @isTest
    public static void updateBankDetailsOfTenant(){
          User userP = EI_TestDataFactory.getUserWithProfile();
         insert userP;
         Contact c1;
       
        System.runAs(userP) {
            Account acc1 = new Account(Name = 'TestAccount', OwnerId = userP.Id);
            insert acc1;
            c1 = new Contact(FirstName = 'tt', Lastname = 'mm', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);
            
            Bank_Account__c bankAccount  = new Bank_Account__c();
            bankAccount.Account_Number__c ='1234567';
            bankAccount.Sort_Code__c ='234567';
            bankAccount.Account__c = acc1.id;
            insert bankAccount;
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Agent%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'portalUser123@test.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'lnamemm',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);   
    
        System.runAs(userd) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RequestRepayDepoControllerCalloutTrue());
            String bankdetails =  EI_PendingRepaymentRequest.updateBankDetailsOfTenant('12345','345678','testScotland','scotland');
            System.assert(bankdetails != null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateBankDetailsOfTenantforNotCorrect(){
          User userP = EI_TestDataFactory.getUserWithProfile();
         insert userP;
         Contact c1;
       
        System.runAs(userP) {
            Account acc1 = new Account(Name = 'TestAccount', OwnerId = userP.Id);
            insert acc1;
            c1 = new Contact(FirstName = 'tt', Lastname = 'mm', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);
            
            Bank_Account__c bankAccount  = new Bank_Account__c();
            bankAccount.Account_Number__c ='1234567';
            bankAccount.Sort_Code__c ='234567';
            bankAccount.Account__c = acc1.id;
            insert bankAccount;
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Agent%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'portalUser123@test.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'lnamemm',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);   
    
        System.runAs(userd) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RequestRepayDepoControllerCallout());
            String bankdetails =  EI_PendingRepaymentRequest.updateBankDetailsOfTenant('12345','345678','testScotland','scotland');
            System.assert(bankdetails != null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateBankDetailsOfTenantforElse(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        
         Bank_Account__c bankAccount  = new Bank_Account__c();
         bankAccount.Account_Number__c ='1234567';
         bankAccount.Sort_Code__c ='234567';
         bankAccount.Account__c = acc.id;
         insert bankAccount;
        
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new RequestRepayDepoControllerCalloutTrue());
         String bankdetails =  EI_PendingRepaymentRequest.updateBankDetailsOfTenant('12345','345678','testScotland','scotland');
         System.assert(bankdetails != null);
         Test.stopTest();
    }
    
    @isTest
    public static void updateIntBankDetailsOfTenant(){
         UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
        User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        insert testUser;
        
        Bank_Account__c bankAccount = EI_TestDataFactory.getBankAccount(userAcccount);
        System.runAs(userWithRole) {
            insert bankAccount;
        }
      
        Contact testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
           Test.startTest();
           String message = EI_PendingRepaymentRequest.updateIntBankDetailsOfTenant('ScotlandBank','ScotlandAddress','CityScoltand','CI5674','45673','56098IO');
           System.assertEquals(message, 'successMessage');
           Test.stopTest();
        }
    }
    
    @isTest
    public static void updateIntBankDetailsOfTenantforElse(){
        
         UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
        User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        insert testUser;
              
        Contact testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
           Test.startTest();
           String message = EI_PendingRepaymentRequest.updateIntBankDetailsOfTenant('ScotlandBank','ScotlandAddress','CityScoltand','CI5674','45673','56098IO');
           System.assertEquals(message, 'successMessage');
           Test.stopTest();
        }
    }
    
    @isTest
    public static void getBankDetail(){
         UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
        User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        insert testUser;
        
        Bank_Account__c bankAccount = EI_TestDataFactory.getBankAccount(userAcccount);
        System.runAs(userWithRole) {
            insert bankAccount;
        }
        
        Contact testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
            Test.startTest();
            Bank_Account__c bank = EI_PendingRepaymentRequest.getBankDetails();
            //System.assert(bank != null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getBankDetailisNotNull(){
         UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
        User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        insert testUser;
        
        Bank_Account__c bankAccount = EI_TestDataFactory.getBankAccount(userAcccount);
        bankAccount.Is_Active__c = true;
        System.runAs(userWithRole) {
            insert bankAccount;
        }
        
        Contact testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
            Test.startTest();
            Bank_Account__c bank = EI_PendingRepaymentRequest.getBankDetails();
            System.assert(bank != null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void addBankDetail(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.Salutation = 'Mr.';
        acc.PersonEmail = 'potter@g.com';
        acc.Phone = '222222';
        insert acc;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        deposit.Amount_of_Deposit_Protected_by_TDS__c = 400;
        insert deposit;
                  
        Repayment_Request__c repayReq = new Repayment_Request__c();
        repayReq.Account__c = acc.id;
        repayReq.Deposit__c = deposit.id;
        repayReq.AL_CleaningAmt__c = 50;
        repayReq.AL_DmgPropAmt__c = 100;
        repayReq.AL_GardeningAmt__c = 50;
        repayReq.AL_Repay_Requested__c = true;
        repayReq.Total_Amount_Requested_AL__c = 300;
        repayReq.Tenant_Cleaning__c= 400;
        insert repayReq;
        
         Test.startTest();
          try
      {
       Test.setMock(HttpCalloutMock.class, new RequestRepayDepoControllerCallout3());
        String bank = EI_PendingRepaymentRequest.addBankDetail('Scotland bank','request');
      }
      catch(exception e)
         {
        }     
        
        Test.stopTest();
    }
    
    @isTest
    public static void AgreedTorequest(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Repayment_Request__c repayReq = new Repayment_Request__c();
        repayReq.Account__c = acc.id;
        repayReq.Deposit__c = deposit.id;
        repayReq.AL_CleaningAmt__c = 50;
        insert repayReq;
        
        Bank_Account__c bankAccount  = new Bank_Account__c();
        bankAccount.Account_Number__c ='1234567';
        bankAccount.Sort_Code__c ='234567';
        bankAccount.Account__c = acc.id;
        insert bankAccount;
        
        Repayment_Request_Line__c reReqLine = new Repayment_Request_Line__c();
        reReqLine.Account__c = acc.id;
        reReqLine.Repayment_Request__c = repayReq.id;
        reReqLine.AL_ReqAmt__c=700;
        reReqLine.Tenant_ReqAmt__c = 500;
        reReqLine.Requested_By__c = 'Agent/Landlord';
        insert reReqline;
        
        Test.startTest();
        List<Repayment_Request_Line__c> repayreqList = EI_PendingRepaymentRequest.AgreedTorequest(repayReq.id,22.45,Date.newInstance(2013,11,11),true);
        System.assert(repayreqList != null);
        Test.stopTest();   
    }

    @isTest
    public static void AgreedTorequestForCaseList(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
       // con.IsPersonAccount= false;
       // con.AccountId = acc.id;
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'Deposit to be Repaid - Repayment Agreed';
        insert caseObj ;         
        
        Repayment_Request__c repayReq = new Repayment_Request__c();
        repayReq.Account__c = acc.id;
        repayReq.Deposit__c = deposit.id;
        repayReq.Case__c = caseobj.id;
        repayReq.AL_CleaningAmt__c = 50;
        insert repayReq;
        
        Bank_Account__c bankAccount  = new Bank_Account__c();
        bankAccount.Account_Number__c ='1234567';
        bankAccount.Sort_Code__c ='234567';
        bankAccount.Account__c = acc.id;
        insert bankAccount;
        
        Repayment_Request_Line__c reReqLine = new Repayment_Request_Line__c();
        reReqLine.Account__c = acc.id;
        reReqLine.Contact__c = con.id;
        reReqLine.Repayment_Request__c = repayReq.id;
        reReqLine.AL_ReqAmt__c=700;
        reReqLine.Tenant_ReqAmt__c = 500;
        reReqLine.Requested_By__c = 'Agent/Landlord';
        insert reReqline;
        
        Test.startTest();
        List<Repayment_Request_Line__c> repayreqList = EI_PendingRepaymentRequest.AgreedTorequest(repayReq.id,22.45,Date.newInstance(2013,11,11),true);
        System.assert(repayreqList != null);
        Test.stopTest();   
    }
    
    @isTest
    public static void AgreedTorequestBankAccountFalse(){    
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
       // con.IsPersonAccount= false;
       // con.AccountId = acc.id;
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'Deposit to be Repaid - Repayment Agreed';
        insert caseObj ;         
        
        Repayment_Request__c repayReq = new Repayment_Request__c();
        repayReq.Account__c = acc.id;
        repayReq.Deposit__c = deposit.id;
        repayReq.Case__c = caseobj.id;
        repayReq.AL_CleaningAmt__c = 50;
        insert repayReq;
        
        Bank_Account__c bankAccount  = new Bank_Account__c();
        bankAccount.Account_Number__c ='1234567';
        bankAccount.Sort_Code__c ='234567';
        bankAccount.Account__c = acc.id;
        insert bankAccount;
        
        Repayment_Request_Line__c reReqLine = new Repayment_Request_Line__c();
        reReqLine.Account__c = acc.id;
        reReqLine.Contact__c = con.id;
        reReqLine.Repayment_Request__c = repayReq.id;
        reReqLine.AL_ReqAmt__c=700;
        reReqLine.Tenant_ReqAmt__c = 500;
        reReqLine.Requested_By__c = 'Agent/Landlord';
        insert reReqline;
        
        Test.startTest();
        List<Repayment_Request_Line__c> repayreqList = EI_PendingRepaymentRequest.AgreedTorequest(repayReq.id,22.45,Date.newInstance(2013,11,11),false);
        //System.assert(repayreqList != null);
        Test.stopTest();  
    }
    
    @isTest
    public static void AgreedTorequestNotPersonAccount(){    
        Account acc = new Account();
        acc.LastName= 'potter';
        insert acc;
        
        Contact c = new Contact();
        c.LastName='potter';
        insert c;
            
        Property__c property= new Property__c();
        property.City__c ='nagpur';
        property.State__c = 'maharashtra';
        property.Postal_Code__c = '34567';
        property.Street__c= 'mg road';
        property.Property_Owner__c = acc.id;
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit =  new deposit__c();
        deposit.Property__c = property.id;
        deposit.Deposit_Amount__c = 700;
        deposit.Customer__c = acc.id;
        deposit.Scheme__c = scheme.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'Deposit to be Repaid - Repayment Agreed';
        insert caseObj ;         
        
        Repayment_Request__c repayReq = new Repayment_Request__c();
        repayReq.Account__c = acc.id;
        repayReq.Deposit__c = deposit.id;
        repayReq.Case__c = caseobj.id;
        repayReq.AL_CleaningAmt__c = 50;
        insert repayReq;
        
        Bank_Account__c bankAccount  = new Bank_Account__c();
        bankAccount.Account_Number__c ='1234567';
        bankAccount.Sort_Code__c ='234567';
        bankAccount.Account__c = acc.id;
        insert bankAccount;
        
        Repayment_Request_Line__c reReqLine = new Repayment_Request_Line__c();
        reReqLine.Account__c = acc.id;
        reReqLine.Contact__c = c.id;
        reReqLine.Repayment_Request__c = repayReq.id;
        reReqLine.AL_ReqAmt__c=700;
        reReqLine.Tenant_ReqAmt__c = 500;
      //  reReqLine.Requested_By__c = 'Agent/Landlord';
        insert reReqline;
        
        Test.startTest();
        List<Repayment_Request_Line__c> repayreqList = EI_PendingRepaymentRequest.AgreedTorequest(repayReq.id,22.45,Date.newInstance(2013,11,11),false);
        //System.assert(repayreqList != null);
        Test.stopTest();  
    }

    
    @isTest
    public static void CreateCreditNote(){
        Contact contactObj = new Contact();
        contactObj.LastName ='Potter';
        insert contactObj;
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Status__c ='In Progress';
        deposit.Tenant_Changeover_Deposit__c= 'deposit';
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'Tenant changeover initiated - agent/landlord';
        insert caseObj ;
               
        Bank_Account__c bankAccount  = new Bank_Account__c();
        bankAccount.Account__c = acc.id;
        bankAccount.Account_Number__c ='1234567';
        insert bankAccount;
     
        Test.StartTest();
        String message =  EI_PendingRepaymentRequest.createCreditNoteRecord('null',contactObj.id,'online',300,Date.newInstance(2021, 09, 30),deposit.id,caseObj.id,bankAccount);
        System.assertEquals('successfully Updated', message);
        Test.stopTest();
    }
    
    @isTest
    public static void CreateCreditNoteForElse(){
        Contact contactObj = new Contact();
        contactObj.LastName ='Potter';
        insert contactObj;
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Status__c ='In Progress';
        deposit.Tenant_Changeover_Deposit__c= 'deposit';
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'Tenant changeover initiated - agent/landlord';
        insert caseObj ;
       
        Bank_Account__c bankAccount  = new Bank_Account__c();
        bankAccount.Account__c = acc.id;
        bankAccount.Account_Number__c ='1234567';
        insert bankAccount;
     
        Test.StartTest();
        String message =  EI_PendingRepaymentRequest.createCreditNoteRecord('null',contactObj.id,'online',0,Date.newInstance(2021, 09, 30),deposit.id,caseObj.id,bankAccount);
        System.assertEquals('Amount should be greater than 0', message);
        Test.stopTest();
    }
    
    @isTest
    public static void closeCase(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'Repayment requested - tenant';
        insert caseObj ;
        
        Repayment_Request__c repayReq = new Repayment_Request__c();
        repayReq.Account__c = acc.id;
        repayReq.Deposit__c = deposit.id;
        repayReq.Case__c = caseObj.id;
        repayReq.AL_CleaningAmt__c = 50;
        insert repayReq;
        
        Repayment_Request_Line__c reReqLine = new Repayment_Request_Line__c();
        reReqLine.Account__c = acc.id;
        reReqLine.Contact__c = con.id;
        reReqLine.Repayment_Request__c = repayReq.id;
        reReqLine.AL_ReqAmt__c=700;
        reReqLine.Tenant_ReqAmt__c = 500;
        reReqLine.Requested_By__c = 'Tenant';
        insert reReqline;
        
        Test.StartTest();
         Test.setMock(HttpCalloutMock.class, new RequestRepayDepoControllerCallout3());
        String message =  EI_PendingRepaymentRequest.closeCase(deposit.id,repayReq.id);
        Test.stopTest();        
    }
    
    @isTest
    public static void closeCaseforElse(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'Repayment requested - tenant';
        insert caseObj ;
        
        Repayment_Request__c repayReq = new Repayment_Request__c();
        repayReq.Account__c = acc.id;
        repayReq.Deposit__c = deposit.id;
        repayReq.Case__c = caseObj.id;
        repayReq.AL_CleaningAmt__c = 50;
        insert repayReq;
        
        Repayment_Request_Line__c reReqLine = new Repayment_Request_Line__c();
        reReqLine.Account__c = acc.id;
        reReqLine.Contact__c = con.id;
        reReqLine.Repayment_Request__c = repayReq.id;
        reReqLine.AL_ReqAmt__c=700;
        reReqLine.Tenant_ReqAmt__c = 500;
        reReqLine.Requested_By__c = 'Tenant';
        insert reReqline;
        
        Test.StartTest();
        try{
        Test.setMock(HttpCalloutMock.class, new RequestRepayDepoControllerCallout3());
        String message =  EI_PendingRepaymentRequest.closeCase(reReqline.id,repayReq.id);
        }
        Catch(exception e){
            
        }
        Test.stopTest();        
    }
    
    @isTest
    public static void DisagreedTorequest(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'Repayment requested - tenant';
        insert caseObj ;
        
        Repayment_Request__c repayReq = new Repayment_Request__c();
        repayReq.Account__c = acc.id;
        repayReq.Deposit__c = deposit.id;
        repayReq.Case__c = caseObj.id;
        repayReq.AL_CleaningAmt__c = 50;
        insert repayReq;
        
        Repayment_Request_Line__c reReqLine = new Repayment_Request_Line__c();
        reReqLine.Account__c = acc.id;
        reReqLine.Contact__c = con.id;
        reReqLine.Repayment_Request__c = repayReq.id;
        reReqLine.AL_ReqAmt__c=700;
        reReqLine.Tenant_ReqAmt__c = 500;
        reReqLine.Requested_By__c = 'Tenant';
        insert reReqline;
        
        Test.StartTest();
        try{
         Test.setMock(HttpCalloutMock.class, new RequestRepayDepoControllerCallout3());
        String message =  EI_PendingRepaymentRequest.DisagreedTorequest(repayReq.id,reReqline.id,Date.newInstance(2013,11,11));
        }
        Catch(exception e){
            
        }
        Test.stopTest(); 
    }
    
    @isTest
    public static void getCurrentDate(){
         Date today1 = Date.parse('21/10/26');
         string method1res1 = EI_PendingRepaymentRequest.getCurrentDate( );
       
    }
    
    @isTest
    public static void cancelRequest(){
          EI_PendingRepaymentRequest.cancelRequest( );
       
    }

 }