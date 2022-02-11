/*
@date  :     28/09/2021
@description : Testclass for - EI_Properties

*/
@isTest

private class EI_Properties_testclass{
        
        
         // Method   1 
          
        private static testmethod void EI_Properties_Test1()
         
        {
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        EI_Properties.fetchErrorLabel();
    
        EI_Properties.checkDuplicateProperty(property);
        EI_Properties.getuserDetails();  
        EI_Properties.contains('HP456FG');
        
        
        
        }
        
        
        // Method   2
          
        private static testmethod void EI_Properties_Test2()
        {
        
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
    
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        List<Property__c> pro= New List<Property__c>();
        Pro.add(property);
        
        Branch__c branch2  = new Branch__c();
        branch2.Account__c = acc.Id;
        branch2.Branch_Name__c='xyztest';
        branch2.Branch_Name__c='dgfjbk';
        
        insert branch2;
        
        EI_Properties.getLandlordforSummery(String.valueof(branch2.Id), pro);
        
        Property_Allocation__c pa= new Property_Allocation__c();
        pa.Property__c= pro[0].ID;
        insert pa;
        
        EI_Properties.getLandlordforSummery(String.valueof(branch2.Id), pro);
        EI_Properties.getlandlord(String.valueof(branch2.Id), 'dh');
        EI_Properties.getlandlord(null, 'dh');
        }             
     
       // Method   3
          
        private static testmethod void EI_Properties_Test3()
        {
            Test.StartTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;
        List<Contact> conlist = new List<Contact>();   
        contact con;
        Contact c1 ;
        Deposit__c deposit;
        //MemberId__c myMember;
        Branch__c branch2;
        Property__c property;
        Area_Code_For_Landlord__mdt metadata;
        System.runAs(userP) {   
        Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            
            property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            property.Postal_Code__c = 'DD11 2DJ';
            insert property;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        

            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', PrimaryLandlord__c= true,AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
             
            conlist.add(c1);
               
            //metadata= new Area_Code_For_Landlord__mdt ();
            //metadata.Postal_Code__c= property.Postal_Code__c;
           //insert metadata;
           
           //Insert new Area_Code_For_Landlord__mdt(Postal_Code__c=property.Postal_Code__c);
            
            branch2  = new Branch__c();
            branch2.Account__c = acc1.Id;
            branch2.Branch_Name__c='xyztest1';
            branch2.Address__c ='abc';
            branch2.Town_City__c='town1';
            branch2.County__c = 'test2';
            branch2.Country__c='India';
            branch2.Postcode__c='hp23fgt';
            branch2.Branch_Name__c='dghjkhbjbk';
            
            insert branch2;
            Try{
            EI_Properties.addNewProperty(String.valueof(branch2.Id) , property, userp , conlist, conlist);
            EI_Properties.transferDepositwithProperty(property,userp , conlist,conlist,System.Today(), 200.00,String.valueof(deposit.Id));
            }catch(Exception e){}
        }
        
        
        }
     
        // Method   4
          
        private static testmethod void EI_Properties_Test4(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP; 
        List<Contact> conlist = new List<Contact>();     
        contact con;
        Contact c1 ;
        Deposit__c deposit;       
        Branch__c branch3;
        Property__c property;
        System.runAs(userP){
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            
            property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            property.Postal_Code__c = 'DD11 2DJ';
            //insert property;
            
            branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        

            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);
            conlist.add(c1);   
            
            insert new MemberId__c(Name='test class', AgentID__c=100, BulkNumber__c = 100,LandlordId__c = 100,TenantID__c = 100);
            
            
                 
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);

        Test.StartTest();
        

        System.runAs(userd){
        Try{
        EI_Properties.addNewProperty(String.valueof(branch3.Id) , property, userd, conlist, conlist);
        }catch(Exception e){}
        }
        
        
        }
       
        
        // Method   5
          
        private static testmethod void EI_Properties_Test5(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP; 
        List<Contact> conlist = new List<Contact>();     
        contact con;
        Contact c1 ;
        Deposit__c deposit;       
        Branch__c branch3;
        Property__c property;
        Property__c property2;
        System.runAs(userP){
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            
            property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            property.Postal_Code__c = 'DD11 2DJ';
            //insert property;
            
            property2= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            property2.Postal_Code__c = 'HP11 2DJ';
            //insert property;
            
            branch3  = new Branch__c();
            branch3.Branch_Name__c='xyztest2';
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        

            con = new Contact( FirstName = 'test1', Lastname = 'test9',LandLord_Registration_Number__c='test1',AccountId = acc1.Id,PrimaryLandlord__c=true, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(con);
            //c1 = new Contact( FirstName = 'test1', Lastname = 'test2',AccountId = acc1.Id, PrimaryLandlord__c=false, Email = System.now().millisecond() + 'as@test.com');
            //Database.insert(c1);
            
            //conlist.add(c1);
            conlist.add(con); 
              
            insert new MemberId__c(Name='test class', AgentID__c=100, BulkNumber__c = 100,LandlordId__c = 100,TenantID__c = 100);
            
                 
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Agent%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=con.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US', User_Type__c = 'Agent');
        Database.insert(userd);

        Test.StartTest();

        System.runAs(userd){
        Try{
        EI_Properties.checkDuplicateProperty(property);
        EI_Properties.addNewProperty(String.valueof(branch3.Id) , property2, userd, conlist, conlist);
        EI_Properties.addNewProperty(String.valueof(branch3.Id) , property, userd, conlist, conlist);
        }catch(Exception e){}
        }
        

        
        
    }
        
        // Method   6
          
        private static testmethod void EI_Properties_Test6(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP; 
        List<Contact> conlist = new List<Contact>();     
        contact con;
        Contact c1 ;
        Deposit__c deposit;           
        Branch__c branch3;
        Property__c property;
        Property__c property2;
        System.runAs(userP){
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            
            property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            property.Postal_Code__c = 'DD11 2DJ';
            //insert property;
            
            property2= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            property2.Postal_Code__c = 'HP11 2DJ';
            //insert property;
            
            branch3  = new Branch__c();
            branch3.Branch_Name__c='xyztest2';
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        

            con = new Contact( FirstName = 'test1', Lastname = 'test9',LandLord_Registration_Number__c='test1',AccountId = acc1.Id,PrimaryLandlord__c=true, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(con);
            //c1 = new Contact( FirstName = 'test1', Lastname = 'test2',AccountId = acc1.Id, PrimaryLandlord__c=false, Email = System.now().millisecond() + 'as@test.com');
            //Database.insert(c1);
            
            //conlist.add(c1);
            conlist.add(con); 
              
            insert new MemberId__c(Name='test class', AgentID__c=100, BulkNumber__c = 100,LandlordId__c = 100,TenantID__c = 100);
 
                 
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Agent%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=con.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);

        Test.StartTest();

        System.runAs(userd){
        Try{
        //EI_Properties.transferDepositwithProperty(property,userp , conlist,conlist,System.Today(), 200.00,String.valueof(deposit.Id));
        EI_Properties.transferDepositwithProperty(property,userp , conlist,conlist,System.Today(), 200.00,null);
        
        }catch(Exception e){}
        }
        
        userd.User_Type__c = 'Agent';
        update userd;
        
        System.runAs(userd){
        Try{
        //EI_Properties.transferDepositwithProperty(property,userp , conlist,conlist,System.Today(), 200.00,String.valueof(deposit.Id));
        EI_Properties.transferDepositwithProperty(property,userd, conlist,conlist,System.Today(), 200.00,null);
        
        }catch(Exception e){}
        }

        
        
    }
        
}