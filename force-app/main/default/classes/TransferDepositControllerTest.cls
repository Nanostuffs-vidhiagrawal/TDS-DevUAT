@isTest
public class TransferDepositControllerTest {
    
    @isTest
    public static void getDepositInformation(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Status__c ='Deposits held by scheme';
        insert deposit;
        
        Test.startTest();
        List<Deposit__c> depoList = TransferDepositController.getDepositInformation();
       // System.assertEquals(deposit.id, depoList[0].id);
        Test.stopTest();
    }
    
    @isTest
    public static void checkDepositAllocationTenantName(){
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
        
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        List<Id> depoAllocationIdList = new List<Id>();
       // depoAllocationIdList.add(depoAllocation.id);
        
        System.debug(':::Mydeposit Id ='+deposit.id);
        depoAllocationIdList.add(deposit.Id);
       
        Test.StartTest();
        String  message =  TransferDepositController.checkDepositAllocationTenantName(depoAllocationIdList, 'potter');
        System.assertEquals(message, 'Found');
        Test.stopTest();  
    }
    
     @isTest
    public static void checkDepositAllocationTenantNameforElse(){
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
        
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        List<Id> depoAllocationIdList = new List<Id>();
       // depoAllocationIdList.add(depoAllocation.id);
        
        System.debug(':::Mydeposit Id ='+deposit.id);
        depoAllocationIdList.add(deposit.Id);
       
        Test.StartTest();
        String  message =  TransferDepositController.checkDepositAllocationTenantName(depoAllocationIdList, 'value');
        System.assertEquals(message, 'Not Found');
        Test.stopTest();  
    }
    
    @isTest
    public static void validateTenantNameAndAccept(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.FirstName= 'HARRY';
        acc.LastName = 'POTTER';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Deposit_Transferred__c = true;
        deposit.Deposit_Transferred_to_Account__c = acc.id;
        insert deposit;
        
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        List<Id> depoAllocationIdList = new List<Id>();
       // depoAllocationIdList.add(depoAllocation.id);
       
        depoAllocationIdList.add(deposit.Id);
        depoAllocationIdList.add(depoAllocation.id);
        
        Test.StartTest();
        String  message =  TransferDepositController.validateTenantNameAndAccept(depoAllocationIdList, 'POTTER');
        Test.stopTest(); 
    }
    

    @isTest
    public static void validateTenantNameAndAcceptListNotEmpty(){
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
        deposit.Deposit_Transferred__c = false;
        deposit.Deposit_Transferred_to_Account__c = null;
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case objCase = new Case();
        objCase.Deposit_Account_Number__c = deposit.id;
        objCase.Status = 'Deposit transfer requested';
        objCase.AccountId = acc.id;
        insert objCase;
       
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        List<Id> depoAllocationIdList = new List<Id>();
        depoAllocationIdList.add(deposit.Id);
       
        Test.StartTest();
        String  message =  TransferDepositController.validateTenantNameAndAccept(depoAllocationIdList, 'potter');
        //System.assertEquals(message, 'Not Found');
        Test.stopTest();  
    }
    
    @isTest
    public static void validateTenantNameAndAcceptforElse(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.FirstName= 'HARRY';
        acc.LastName = 'POTTER';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Deposit_Transferred__c = true;
        deposit.Deposit_Transferred_to_Account__c = acc.id;
        insert deposit;
        
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        List<Id> depoAllocationIdList = new List<Id>();
       // depoAllocationIdList.add(depoAllocation.id);
       
        depoAllocationIdList.add(deposit.Id);
        depoAllocationIdList.add(depoAllocation.id);
        
        Test.StartTest();
        String  message =  TransferDepositController.validateTenantNameAndAccept(depoAllocationIdList, 'values');
        System.assertEquals(message, 'Not Found');
        Test.stopTest(); 
    } 
    
    @isTest
    public static void getDepositInformationTransferred(){
      /*  Contact con = new Contact();
        con.LastName = 'Potter';
        insert con;
        
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
    	deposit.Property__c = property.id;
       // deposit.Customer__c = acc.Id;
        deposit.Deposit_Transferred_to_Account__c= acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        insert deposit;*/

   		UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
		User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        System.debug(':::UserAccount='+userAcccount);
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        insert testUser;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        System.runAs(userWithRole) {
           insert querylimit;
        }        

        Scheme__c scheme= EI_TestDataFactory.createScheme();
        System.runAs(userWithRole) {
            insert scheme;
        }
        Deposit__c deposit = new Deposit__c();
        deposit.Customer__c = userAcccount.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        deposit.Scheme__c = scheme.id;
        deposit.Deposit_Amount__c = 999;
       
        System.runAs(userWithRole) {            
            insert deposit;            
        }
        
        Contact testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
        Test.StartTest();
        List<TransferDepositController.depositListWrapper> wrapListDepo =  TransferDepositController.getDepositInformationTransferred();
        //System.assertEquals(message, 'Not Found');
        Test.stopTest(); 
        }
    }        
               
    @isTest
    public static void processAcceptDeposit(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.Email__c = 'test@g.com';
        acc.LastName= 'Potter';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        List<string> depoList = new List<string>();
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Deposit_Transferred__c = true;
        deposit.Customer__c = acc.id;
        deposit.Scheme__c = scheme.id;
        deposit.Deposit_Transferred_to_Account__c = acc.id;
        insert deposit;
        depoList.add(deposit.id);
        
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        Case  objCase =  TransferDepositController.processAcceptDeposit(depoList);
        Test.stopTest(); 
    }
    
    @isTest
    public static void processAcceptDepositforPersonEmail(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.PersonEmail = 'persontest@g.com';
        acc.LastName= 'Potter';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        List<string> depoList = new List<string>();
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Deposit_Transferred__c = true;
        deposit.Customer__c = acc.id;
        deposit.Scheme__c = scheme.id;
        deposit.Deposit_Transferred_to_Account__c = acc.id;
        insert deposit;
        depoList.add(deposit.id);
        
        Case objCase = new Case();
        objCase.Deposit_Account_Number__c = deposit.id;
      	objCase.Type = 'Problem';
        insert objCase;
        
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        Case  objCase1 =  TransferDepositController.processAcceptDeposit(depoList);
        Test.stopTest(); 
    }
    
    @isTest
    public static void processMultipleAcceptDeposit(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.Email__c = 'test@g.com';
        acc.PersonEmail = 'mypersonemail@g.com';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        Case objCase = new Case();
        objCase.Description = 'my description';
        insert objCase;        
         
        List<string> depoList = new List<string>();
          
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Deposit_Transferred__c = true;
        deposit.Customer__c = acc.id;
        deposit.Deposit_Transferred_to_Account__c =  acc.id;
        depoList.add(deposit.id);        
           
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHTTPChangeMyDetails());
         Map<Id,Deposit__c>  mapdeposit =  TransferDepositController.processMultipleAcceptDeposit(depoList);
        Test.stopTest();    
    }
    
    @isTest
    public static void  processRejectDeposit(){
        
         Contact con = new Contact();
        con.LastName = 'Potter';
        insert con;
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'Potter';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Customer__c = acc.Id;
        deposit.Deposit_Transferred_to_Account__c= acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        insert deposit;
        List<String> depoList  = new List<String>();
        depoList.add(deposit.id);
        
         Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.processRejectDeposit(depoList);
        Test.stopTest();   
    }
    
     @isTest
    public static void  processRejectDepositforEmail(){
       
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'Potter';
        acc.Email__c= 'test@g.com';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
              
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Customer__c = acc.Id;
        deposit.Deposit_Transferred_to_Account__c= acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        insert deposit;
        List<String> depoList  = new List<String>();
        depoList.add(deposit.id);
        
        Case objCase = new Case();
        objCase.Deposit_Account_Number__c = deposit.id;
        objCase.Status = 'Deposit transfer requested';
        objCase.AccountId = acc.id;
        insert objCase;
        
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.processRejectDeposit(depoList);
        Test.stopTest();   
    }
    
    @isTest
    public static void getAgentLandlordEmailDetails(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'Potter';
        acc.Email__c= 'test@g.com';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
              
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Customer__c = acc.Id;
        deposit.Deposit_Transferred_to_Account__c= acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        insert deposit;
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
        
        Case objCase = new Case();
        objCase.Deposit_Account_Number__c = deposit.id;
        objCase.Status = 'Deposit transfer requested';
        objCase.AccountId = acc.id;
        insert objCase;
        
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.getAgentLandlordEmailDetails('test@g.com',depoList);
        System.assertEquals(myString, 'transferred');
        Test.stopTest();
    }
    
    @isTest
    public static void getAgentLandlordEmailDetailsUser(){
        UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
		User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = new Account();
        userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        System.debug(':::UserAccount='+userAcccount);
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        insert testUser;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        System.runAs(userWithRole) {
           insert querylimit;
        }
        
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        System.runAs(userWithRole) {
            insert scheme;
        }
        deposit__c deposit = new deposit__c();
    	//deposit.Property__c = property.id;
        deposit.Customer__c = userAcccount.Id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        deposit.Deposit_Amount__c = 800;
        deposit.Scheme__c = scheme.id;
       
       
        System.runAs(userWithRole) {
            insert deposit;
        }
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
        Contact testContact = new Contact();
        testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.getAgentLandlordEmailDetails('test@g.com',depoList);
        System.assertEquals(myString, 'transferred');
        Test.stopTest();
       
        }
    }
    
    @isTest
    public static void getAgentLandlordEmailDetailsUserLandlord(){
        UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
		User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        System.debug(':::UserAccount='+userAcccount);
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Landlord' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        testUser.IsActive = true;
        testUser.Email ='test@g.com';
        insert testUser;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        System.runAs(userWithRole) {
           insert querylimit;
        }        
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        System.runAs(userWithRole) {
            insert scheme;
        }
        deposit__c deposit = new deposit__c();
    	//deposit.Property__c = property.id;
        deposit.Customer__c = userAcccount.Id;
        deposit.Deposit_Transferred_to_Account__c= userAcccount.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        deposit.Deposit_Amount__c = 800;
        deposit.Scheme__c = scheme.id;
       
       
        System.runAs(userWithRole) {
            insert deposit;
        }
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
        Contact testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.getAgentLandlordEmailDetails('test@g.com',depoList);
        System.assertEquals(myString, 'transferred');
        Test.stopTest();
        }
    }
    
    @isTest
    public static void getAgentLandlordEmailDetailsUserAgent(){
        UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
		User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        System.debug(':::UserAccount='+userAcccount);
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        testUser.IsActive = true;
        testUser.Email ='test@g.com';
        insert testUser;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        System.runAs(userWithRole) {
           insert querylimit;
        }        
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        System.runAs(userWithRole) {
            insert scheme;
        }
        deposit__c deposit = new deposit__c();
    	//deposit.Property__c = property.id;
        deposit.Customer__c = userAcccount.Id;
        deposit.Deposit_Transferred_to_Account__c= userAcccount.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        deposit.Deposit_Amount__c = 800;
        deposit.Scheme__c = scheme.id;
       
       
        System.runAs(userWithRole) {
            insert deposit;
        }
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
        Contact testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.getAgentLandlordEmailDetails('test@g.com',depoList);
        System.assertEquals(myString, 'transferred');
        Test.stopTest();
        }
    }
    
    @isTest
    public static void getAgentLandlordEmailDetailsforElseLandlord(){
        UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
		User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        System.debug(':::UserAccount='+userAcccount);
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        testUser.IsActive = true;
        testUser.Email ='test@g.com';
        insert testUser;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        System.runAs(userWithRole) {
           insert querylimit;
        }        
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        System.runAs(userWithRole) {
            insert scheme;
        }
        
         deposit__c deposit = new deposit__c();
    	//deposit.Property__c = property.id;
        deposit.Customer__c = userAcccount.Id;
        deposit.Deposit_Transferred_to_Account__c= userAcccount.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        deposit.Deposit_Amount__c = 800;
        deposit.Scheme__c = scheme.id;
        
        System.runAs(userWithRole) {
            insert deposit;
        }
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
        
        Contact testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.getAgentLandlordEmailDetails('test@g.com',depoList);
        System.assertEquals(myString, 'transferred');    
        Test.stopTest();
        }
    }
    
    @isTest
    public static void getAgentLandlordEmailDetailsUserAgentforElse(){
        UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
		User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = new  Account();
        userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        System.debug(':::UserAccount='+userAcccount);
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Landlord' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        testUser.IsActive = true;
        testUser.Email ='test@g.com';
        insert testUser;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        System.runAs(userWithRole) {
           insert querylimit;
        }        
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        System.runAs(userWithRole) {
            insert scheme;
        }
        
        deposit__c deposit = new deposit__c();
    	deposit.Customer__c = userAcccount.Id;
        deposit.Deposit_Transferred_to_Account__c= userAcccount.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        deposit.Deposit_Amount__c = 800;
        deposit.Scheme__c = scheme.id;
        
        System.runAs(userWithRole) {
            insert deposit;
        }
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
       
        Contact testContact = new Contact();
        testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        System.runAs(testUser){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.getAgentLandlordEmailDetails('test@g.com',depoList);
        System.assertEquals(myString, 'transferred');
        Test.stopTest();
        }
    }

    @isTest
    public static void checkDepositAllocationMultipleTenantName(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'Potter';
        acc.Email__c= 'test@g.com';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
              
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Customer__c = acc.Id;
        deposit.Deposit_Transferred_to_Account__c= acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        insert deposit;
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
        
        Case objCase = new Case();
        objCase.Deposit_Account_Number__c = deposit.id;
        objCase.Status = 'Deposit transfer requested';
        objCase.AccountId = acc.id;
        insert objCase;
        
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.checkDepositAllocationMultipleTenantName(depoList,'[{"K1":"100"},{"K2":"200"}]','[{"K1":"100"},{"K2":"200"}]');
        System.assertEquals(myString, 'Deposit updated and case exist');
        Test.stopTest();        
    }
    
    @isTest
    public static void checkDepositAllocationMultipleTenantNameCaseNull(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'Potter';
        acc.Email__c= 'test@g.com';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
              
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Customer__c = acc.Id;
        deposit.Deposit_Transferred_to_Account__c= acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        insert deposit;
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
  
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.checkDepositAllocationMultipleTenantName(depoList,'[{"K1":"100"},{"K2":"200"}]','[{"K1":"100"},{"K2":"200"}]');
        System.assertEquals(myString, 'Deposit updated and no case exist');
        Test.stopTest();        
    }
    
    @isTest
    public static void checkDepositAllocationMultipleTenantNameValueNull(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'Potter';
        acc.Email__c= 'test@g.com';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
              
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Customer__c = acc.Id;
        deposit.Deposit_Transferred_to_Account__c= acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        insert deposit;
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
  
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        depoAllocation.Istenantmoved__c = true;
        depoAllocation.Tenencychangeoveramount__c = 300;
        insert depoAllocation;
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.checkDepositAllocationMultipleTenantName(depoList,'null','[{"K1":"100"},{"K2":"200"}]');
        System.assertEquals(myString, 'all blank');
        Test.stopTest();        
    }
    
    @isTest
    public static void checkDepositAllocationMultipleTenantNameValueNull1(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'Potter';
        acc.Email__c= 'test@g.com';
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
              
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
    	deposit.Property__c = property.id;
        deposit.Customer__c = acc.Id;
        deposit.Deposit_Transferred_to_Account__c= acc.id;
        deposit.Status__c = 'Deposits held by scheme';
        deposit.Deposit_Transferred__c = true;
        insert deposit;
        List<Id> depoList  = new List<Id>();
        depoList.add(deposit.id);
  
        Deposit_Allocation__c depoAllocation = new Deposit_Allocation__c();
        depoAllocation.Deposit_Holder__c = acc.id;
        depoAllocation.Deposit__c =deposit.id;
        depoAllocation.Role__c = 'Tenant';
        insert depoAllocation;
        List<Id> depoAllocationList  = new List<Id>();
        depoAllocationList.add(deposit.id);
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String myString =  TransferDepositController.checkDepositAllocationMultipleTenantName(depoList,'[{"K1":"100"},{"K2":"200"}]','[{"K1":"100"},{"K2":"200"}]');
        System.assertEquals(myString, 'Deposit updated and no case exist');
        Test.stopTest();        
    }
    
     @isTest   
    public static void fetchErrorLabel(){
         TransferDepositController.fetchErrorLabel();
    }
}