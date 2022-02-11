@isTest
public class CreateUserUnderHOTest {
    @isTest
    
    public static void getHObranches(){
        
      
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        branch__c branch = new branch__c();
        branch.Account__c = acc.id;
        branch.Address__c = 'scotland address';
        branch.Is_Active__c =true;
        branch.Branch_Name__c ='scoltand branch';
        insert branch;
        
        List<Branch_User_Mapping__c> brmaplist = new List<Branch_User_Mapping__c>();
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        insert branchMap;
        brmaplist.add(branchmap); 
       
        CreateUserUnderHO.userInformation wrapper = new CreateUserUnderHO.userInformation();
        wrapper.bum = brmaplist;
        
        CreateUserUnderHO obj = new CreateUserUnderHO();
        Test.StartTest();
        Map<String, String> stringMap =  CreateUserUnderHO.getHObranches(acc.id);
        System.assert(!stringMap.isEmpty()); 
        Try{
        CreateUserUnderHO.updateHOUser(null);
          
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    public static void getAccountDetails(){
           
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);  
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
       }
        System.runAs(userP) {           
        Account accId = CreateUserUnderHO.getAccountDetails();
        System.assert(accId!=null);
        }
    }
    
    @isTest
    public static void getBranches(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);    
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd); 
        System.runAs(userP) {    
        List<Branch__c> branchList  = CreateUserUnderHO.getBranches();
        System.assert(branchList!=null);
       
      }
    }
    
    @isTest
    public static void getJobRoles(){
        Test.startTest();
        List<Map<String, String>> options =  CreateUserUnderHO.getJobRoles();
        System.assert(!options.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void updateBranchUser(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        List<String> branchList = new List<String>();
        List<string> branchMapList = new List<String>();
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
        branchList.add(branch3.Branch_Name__c);
        
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch3.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        insert branchMap;  
        branchMapList.add(branchMap.Additional_Permission__c);
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);  
          
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= 'Submit evidence', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd); 
        System.runAs(userd) {  
        try{
        CreateUserUnderHO.updateBranchUser(con,branchList,'Mr.','+44','View only Access',branchMapList);  
         }Catch(Exception e){}
      }
    }
    
    @isTest
    public static void inactiveBranchUser(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
            
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
       }  
        try{
        Boolean value = CreateUserUnderHO.inactiveBranchUser(userP.id);
        System.assertEquals(value, false);
         Boolean value1 = CreateUserUnderHO.inactiveBranchUser(c1.id);
         System.assertEquals(value1, true);
        }Catch(Exception e){}
    }
    
    @isTest
    public static void inactiveUser(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        Branch_User_Mapping__c branchmapp ;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
       
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd); 
        System.runAs(userP) {   
        try{   
        Boolean value = CreateUserUnderHO.inactiveUser(c1.id);
        System.assertEquals(value, false);
        Boolean value1 = CreateUserUnderHO.inactiveUser(userP.id); 
        System.assertEquals(value, true);    
        }Catch(Exception e){}
        }
    }
    
    @isTest
    public static void reactiveBranchUser(){
         UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
    
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);  
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
       }
        try{  
        Boolean value = CreateUserUnderHO.reactiveBranchUser(userP.id);
        System.assertEquals(value, true);
        Boolean value1 = CreateUserUnderHO.reactiveBranchUser(c1.id);
        System.assertEquals(value, false);   
        }Catch(Exception e){}
        
    }
    
    @isTest
    public static void reactiveUser(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);    
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
            
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',isActive = true);
        Database.insert(userd); 
        System.runAs(userP) {   
        try{   
        Boolean value = CreateUserUnderHO.reactiveUser(c1.id);
        System.assertEquals(value, true);
        Boolean value1 = CreateUserUnderHO.reactiveUser(userP.id);
        System.assertEquals(value, false);   
            }Catch(Exception e){}
        }
    }
    
    @isTest
    public static void getSelectedBranchUserforException(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        Branch_User_Mapping__c branchmapp;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);   
        
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= 'Submit evidence', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',isActive = true);
        Database.insert(userd); 
         branchmapp = new Branch_User_Mapping__c();
        branchmapp.Additional_Permission__c = 'Submit evidence';
        branchmapp.Branch__c = branch3.id;
        branchmapp.User__c = userd.id;
        System.runAs(userd){
        insert branchmapp;
        }
        System.runAs(userd) {   
        try{   
        CreateUserUnderHO.getSelectedBranchUser(userd.id);
        }Catch(Exception e){}
        }
    }
    
    @isTest
    public static void getSelectedBranchUser(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        Branch_User_Mapping__c branchmapp;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
            
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643); 
            
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= 'Submit evidence', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
            
           
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',isActive = true);
        Database.insert(userd); 
        
        branchmapp = new Branch_User_Mapping__c();
        branchmapp.Additional_Permission__c = 'Submit evidence';
        branchmapp.Branch__c = branch3.id;
        branchmapp.User__c = userd.id;
        System.runAs(userd){
        insert branchmapp;
        }
        System.runAs(userd) {   
        try{   
        CreateUserUnderHO.getSelectedBranchUser(c1.id);
        }Catch(Exception e){}
        }
    }
    
     @isTest
    public static void createBranchUser(){       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
         List<String> branchList = new List<String>();
        List<string> branchMapList = new List<String>();
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
       insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
          
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert  branch3;
        branchList.add(branch3.Branch_Name__c);
        
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch3.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        insert  branchMap;  
        branchMapList.add(branchMap.Additional_Permission__c);
          
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
       // Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
       // Database.insert(con);
       }
        System.runAs(userP) {      
        try{
        String message = CreateUserUnderHO.createBranchUser(con,branchList,'Mr.','+44','View only Access',branchMapList); 
        System.debug('message='+message);
        String message1 = CreateUserUnderHO.createBranchUser(null,branchList,'Mr.','+44','View only Access',branchMapList); 
        }Catch(Exception e){
        }
    }
    } 
    
    @isTest
    public static void getHeadOfficeUsers(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        
        contact con;
        Contact c1 ;
        Account acc1; 
        List<String> branchList = new List<String>();
        List<string> branchMapList = new List<String>();
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);     
        c1 = new Contact( FirstName = 'test11',Additional_Permission__c= 'Submit evidence', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
        branchList.add(c1.Additional_Permission__c); 
         
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd); 
        System.runAs(userP) {  
        try{
        List<User> userList = CreateUserUnderHO.getHeadOfficeUsers(); 
        System.assert(userList!=null);    
         }Catch(Exception e){
         }
    }
    }
    
    @isTest
    public static void getPhoneCodePiclistValues(){
        Test.startTest();
        List<String> options =  CreateUserUnderHO.getPhoneCodePiclistValues();
        System.assert(!options.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void updateHOuser(){
       
        Contact contact = EI_TestDataFactory.getContact();
        insert contact;
        Profile standardUserProfile = EI_TestDataFactory.getProfile('Standard User');
        User user = EI_TestDataFactory.getUserWithProfile(standardUserProfile);
        insert user;
        System.runAs(user) {
            EI_headOfficeUtility.contactUserDetail obj =  CreateUserUnderHO.updateHOuser(contact);
           
    }
}
    
    @isTest
    public static void getHOdetails(){
        Contact contact = EI_TestDataFactory.getContact();
        insert contact;
        Profile standardUserProfile = EI_TestDataFactory.getProfile('Standard User');
        User user = EI_TestDataFactory.getUserWithProfile(standardUserProfile);
        insert user;
        System.runAs(user) {
       
        CreateUserUnderHO.getHOdetails();
       
    }
    }
    
    @isTest
    public static void getBranchesUnderAccount(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        branch__c branch = new branch__c();
        branch.Account__c = acc.id;
        branch.Address__c = 'scotland address';
        branch.Is_Active__c =true;
        branch.Branch_Name__c ='scoltand branch';
        insert branch;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        Test.StartTest();
        CreateUserUnderHO.getBranchesUnderAccount(acc.id);
       // System.assert(!stringMap.isEmpty()); 
        Test.stopTest();
    }
    
    @isTest
    public static void getUserDetails(){
         UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);    
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= 'Submit evidence', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
            
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch3.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        branchMap.User__c =  userP.id;
        branchMap.Is_Active__c = true;    
        insert  branchMap;  
             
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',isActive = true);
        Database.insert(userd); 
        System.runAs(userd) {   
        try{   
         CreateUserUnderHO.getUserDetails(userd.id);
       
         
            }Catch(Exception e){}
        }
    }
    
    @isTest
    public static void getUserDetailsforElse(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
            
       
            
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);    
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch3.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        branchMap.User__c =  userP.id;
        branchMap.Is_Active__c = true;    
        insert  branchMap;  
             
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US',isActive = true);
        Database.insert(userd); 
        System.runAs(userd) {   
        try{   
         CreateUserUnderHO.getUserDetails(userd.id);
             CreateUserUnderHO.getUserDetails(c1 .id);
        }Catch(Exception e){}
        }
    }
        
     @isTest
    public static void contactCreateHO(){
      UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
         List<String> branchList = new List<String>();
        List<string> branchMapList = new List<String>();
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert  branch3;
        branchList.add(branch3.Branch_Name__c);
        
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch3.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        insert  branchMap;  
        branchMapList.add(branchMap.Additional_Permission__c);
         insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);   
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
       // Database.insert(c1);   
            
        con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
       // Database.insert(con);
       }
        System.runAs(userP) {  
             
         Test.startTest();   
         try{   
         String message = CreateUserUnderHO.contactCreateHO(c1);
         }catch(Exception e){}
         Test.stopTest();
        }
    }   
    @isTest
    public static void createHOUser(){
         UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
         insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);  
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
       // Database.insert(c1);   
            
        con = new Contact( FirstName = 'test11', Lastname = 'test21', AccountId = acc1.Id, Email = 'as1231@test.com',phone = '17404346033');
       // Database.insert(con);
     }
       
        System.runAs(userP) {  
            try{   
        Contact con1  = CreateUserUnderHO.createHOUser(con,'View only Access','Mr.','+44',null,null);
            }Catch(Exception e){}
      }
    }
    
    @isTest
    public static void updateHOUser1(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        List<string> branchMapList = new List<String>();
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch3.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        insert  branchMap;  
        branchMapList.add(branchMap.Additional_Permission__c);
            
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test11', Lastname = 'test21', AccountId = acc1.Id, Email = 'as1231@test.com',phone = '17404346033');
        Database.insert(con);
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd); 
        System.runAs(userP) {  
        try{   
        c1.FirstName= 'test3';
        c1.Email='abc@gmail.com';
        String con1  = CreateUserUnderHO.updateHOUser(c1,'+44',null,'View only Access','Mr.');    
        }Catch(Exception e){}
      }
    }
     @isTest
    public static void createBranchUser2(){       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
         List<String> branchList = new List<String>();
        List<string> branchMapList = new List<String>();
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert  branch3;
        branchList.add(branch3.Branch_Name__c);
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch3.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        insert  branchMap;  
        branchMapList.add(branchMap.Additional_Permission__c);
            
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
      // Database.insert(c1);   
            
        con = new Contact( FirstName = 'tf', Lastname = 'tl', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(con);
       }
        System.runAs(userP) {      
        try{
        String message = CreateUserUnderHO.createBranchUser(con,branchList,'Mr.','+44','View only Access',branchMapList); 
       
        System.debug('message='+message);
        }Catch(Exception e){
        }
    }
    }
    @isTest
    public static void updateHOUser2(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        List<string> branchMapList = new List<String>();
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch3.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        insert  branchMap;  
        branchMapList.add(branchMap.Additional_Permission__c);
            
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test11', Lastname = 'test21', AccountId = acc1.Id, Email = 'as1231@test.com',phone = '17404346033');
        Database.insert(con);
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd); 
        System.runAs(userd) {  
        try{   
        String con1  = CreateUserUnderHO.updateHOUser(con,'+44',null,'View only Access','Mr.');    
        }Catch(Exception e){}
      }
    }
     @isTest
    public static void updateHOUser3(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
        UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
        CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Account acc1; 
        Branch__c branch3;
        List<string> branchMapList = new List<String>();
        System.runAs(userP){
        acc1 = new Account(Name = 'test1', OwnerId = userP.Id, Associated_To__c = String.valueof(userP.ID));
        insert acc1;
            
        branch3  = new Branch__c();
        branch3.Account__c = acc1.Id;
        branch3.Branch_Name__c='branchsuman1'; 
        branch3.Is_Active__c  = true;     
        insert branch3;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);
        Branch_User_Mapping__c branchMap = new Branch_User_Mapping__c();
        branchMap.Branch__c = branch3.id;
        branchMap.Job_role__c = 'View only Access';
        branchMap.Additional_Permission__c ='Submit evidence';
        insert  branchMap;  
        branchMapList.add(branchMap.Additional_Permission__c);
            
        c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
        Database.insert(c1);   
            
        con = new Contact( FirstName = 'test11', Lastname = 'test21', AccountId = acc1.Id, Email = 'as1231@test.com',phone = '17404346033');
        Database.insert(con);
     }
        Profile dProfile = [SELECT Id FROM Profile WHERE Name = 'Head Office User' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd); 
        System.runAs(userP) {  
        try{         
        c1.Email='abc@gmail.com';
        String con1  = CreateUserUnderHO.updateHOUser(c1,'+44',null,'View only Access','Mr.');    
        }Catch(Exception e){}
      }
      }
    }