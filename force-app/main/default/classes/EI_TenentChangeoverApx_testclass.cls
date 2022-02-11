/*
@date  :     21/10/2021
@description : Testclass for - EI_TenentChangeoverApx

*/
@isTest
private class EI_TenentChangeoverApx_testclass{
        
        
         // Method   1 
          
        private static testmethod void EI_TenentChangeoverApx_Test1()
         
        {
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.PersonEmail = 'landlord@gmail.com';
        insert acc;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        system.assert(scheme!= null);
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
       List<Deposit_Allocation__c > dalist = new list<Deposit_Allocation__c >();
       
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = acc.id;
        depositallocation.Istenantmoved__c= true;
        insert depositallocation;
       
        
        dalist.add(depositallocation );
   
        
        EI_TenentChangeoverApx.getdeposittenantdetails(string.valueof(deposit.id),'true');
        
        Case  case1 = new case();
        case1.Status= 'Tenant changeover';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        insert case1 ;
       
      
        EI_TenentChangeoverApx.tenancyinitiatedemaildetails(string.valueof(deposit.id),dalist);
       
        
        EI_TenentChangeoverApx.FinalWrapper wrap1  = new EI_TenentChangeoverApx.FinalWrapper();
        EI_TenentChangeoverApx.getKey();
        wrap1.firstname= 'sdff';
        wrap1.SurName='sdfg';          
        wrap1.email ='sffg@gmail.com';         
        wrap1.phoneCode  ='+44';
        wrap1.phone='765424567889';
        wrap1.title='mr';  
        wrap1.IsOrg= true; 
        wrap1.companyName= 'espire';
        EI_TenentChangeoverApx.depositwrapper wrap2 = new EI_TenentChangeoverApx.depositwrapper(deposit);
        EI_TenentChangeoverApx.depositwrapper wrap3 = new EI_TenentChangeoverApx.depositwrapper(depositallocation);
        
        
       
        EI_TenentChangeoverApx.getLoggedInUserAccountId(); 
        EI_TenentChangeoverApx.checkDuplicateEmail('email', '34567889', 'onlyphone', 'firstname','surname');
        EI_TenentChangeoverApx.getOutstandingCases();
        
        
       
        }
       
         // Method   2
          
        private static testmethod void EI_TenentChangeoverApx_Test2()
         
        {
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.PersonEmail = 'landlord@gmail.com';
        insert acc;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        system.assert(scheme!= null);
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);                          
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        
        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
       
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = acc.id;
        depositallocation.Role__c= 'Tenant';
        insert depositallocation;
        EI_TenentChangeoverApx.checkDuplicateEmail('vhv@gmail.com', '34567889', 'onlyemail', 'firstname','surname');
        
        EI_TenentChangeoverApx.getPhoneCodePiclistValues();
        EI_TenentChangeoverApx.fetchErrorLabel();
        EI_TenentChangeoverApx.getdeposittenantdetails(string.valueof(deposit.id),'false');
        }
       
        // method 3
        
       private static testmethod void EI_TenentChangeoverApx_Test3(){
       
        EI_TenentChangeoverApx.FinalWrapper wrap1  = new EI_TenentChangeoverApx.FinalWrapper();
        EI_TenentChangeoverApx.getKey();
        wrap1.firstname= 'sdff';
        wrap1.SurName='sdfg';          
        wrap1.email ='sffg@gmail.com';         
        wrap1.phoneCode  ='+44';
        wrap1.phone='765424567889';
        wrap1.title='mr';  
        wrap1.IsOrg= true; 
        wrap1.companyName= 'espire';
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        System.runAs(userP){
        
            Account acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
           insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            ba = new Bank_Account__c();
                ba.Account__c = acc.Id;
                ba.Contact__c= acc.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
           
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
           
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            insert deposit; 
            depositlist.add(deposit);       

            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
             case1 = new case();
             case1 .Status= 'Tenant changeover';
             case1.AccountId = acc.ID;
             case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
           depositallocation =new Deposit_Allocation__c();
           depositallocation.Deposit__c = deposit.Id;
           depositallocation.Deposit_Holder__c = acc.id;
           depositallocation.Istenantmoved__c = true;
           depositallocation.Tenencychangeoveramount__c = 10;
           insert depositallocation;
           depolist.add(depositallocation);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
       System.runAs(userd){
     
        
        EI_TenentChangeoverApx.checkDuplicateEmail('email', '34567889', 'onlyphone', 'firstname','surname');      
        EI_TenentChangeoverApx.getTenantAndDepositDetails(String.valueof(deposit.Id));
        
        EI_TenentChangeoverApx.alltenantlist(string.valueof(deposit.id));
        EI_TenentChangeoverApx.displayBankDetails();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());
        EI_TenentChangeoverApx.updateBankDetailsOfTenant('13354647', '560003','TestABC','testscotlandbank','','');
      
            
        Test.stopTest();
           
        EI_TenentChangeoverApx.getselectedDeposit('dg');
        EI_TenentChangeoverApx.getDeposit('dfvv', 'dffcc');
        EI_TenentChangeoverApx.changeovertenantlist(acclist,String.valueof(deposit.Id));
        EI_TenentChangeoverApx.updatechchangeoverdetails(depolist ); 
        String jsonstring3 = String.Valueof(Json.serialize(deposit));
        String jsonstring2 = '['+String.Valueof(Json.serialize(wrap1))+']';
        String jsonstring =  '['+String.Valueof(Json.serialize(depolist))+']';
        String jsonstring1 = '['+String.Valueof(Json.serialize(depositallocation))+']';
       
        EI_TenentChangeoverApx.changeoverrequest3(string.valueof(deposit.id), 300, 2, system.today(), jsonstring1,jsonstring2 ,'cvf');
        
        EI_TenentChangeoverApx.tenancyinitiatedemaildetails(String.valueof(deposit.Id),depolist);
        EI_TenentChangeoverApx.getChangeOverCase();
        
        EI_TenentChangeoverApx.CreateNewCreditNote('abc','abc1', 200.0,String.valueof(deposit.Id),system.today(), string.valueof(case1.ID),c1,ba);
        
        
        Try{
        EI_TenentChangeoverApx.changeoverrequest2(String.valueof(deposit.Id),jsonstring,jsonstring3 ,'true');
        }catch(Exception e){}
                         
        }
        
        }
 
        // Method   4 
          
        private static testmethod void EI_TenentChangeoverApx_Test4()
         
        {
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.PersonEmail = 'landlord@gmail.com';
        insert acc;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        system.assert(scheme!= null);
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        depositlist.add(deposit);
        
        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
       List<Deposit_Allocation__c > dalist = new list<Deposit_Allocation__c >();
       
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = acc.id;
        //depositallocation.Istenantmoved__c=true;
        depositallocation.Istenantmoved__c=false;
        insert depositallocation;
        
        
        EI_TenentChangeoverApx.submitCaseOnChangeOver((String.valueof(deposit.Id)), 'AgentId', depositallocation );
        
        }
        
         // method 5
        
       private static testmethod void EI_TenentChangeoverApx_Test5(){
       
        EI_TenentChangeoverApx.FinalWrapper wrap1  = new EI_TenentChangeoverApx.FinalWrapper();
        EI_TenentChangeoverApx.getKey();
        wrap1.firstname= 'sdff';
        wrap1.SurName='sdfg';          
        wrap1.email ='sffg@gmail.com';         
        wrap1.phoneCode  ='+44';
        wrap1.phone='765424567889';
        wrap1.title='mr';  
        wrap1.IsOrg= true; 
        wrap1.companyName= 'espire';
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        System.runAs(userP){
        Insert new QueryLimits__c(CheckOn__c =  false, name = 'test');
            Account acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
           insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            ba = new Bank_Account__c();
                ba.Account__c = acc.Id;
                ba.Contact__c= acc.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
           
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
           
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            insert deposit; 
            depositlist.add(deposit);       

            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
             case1 = new case();
             case1 .Status= 'Tenant changeover';
             case1.AccountId = acc.ID;
             case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
           depositallocation =new Deposit_Allocation__c();
           depositallocation.Deposit__c = deposit.Id;
           depositallocation.Deposit_Holder__c = acc.id;
           depositallocation.Istenantmoved__c = true;
           insert depositallocation;
           depolist.add(depositallocation);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
       System.runAs(userd){
       
        
        EI_TenentChangeoverApx.checkDuplicateEmail('email', '34567889', 'onlyphone', 'firstname','surname');      
        EI_TenentChangeoverApx.getTenantAndDepositDetails(String.valueof(deposit.Id));
        
        EI_TenentChangeoverApx.alltenantlist(string.valueof(deposit.id));
        EI_TenentChangeoverApx.displayBankDetails();
       
      Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());   
      EI_TenentChangeoverApx.rejectChangeOver(String.valueof(case1.Id));
           
           Test.stopTest();
           
        EI_TenentChangeoverApx.getselectedDeposit('dg');
        EI_TenentChangeoverApx.getDeposit('dfvv', 'dffcc');
        EI_TenentChangeoverApx.changeovertenantlist(acclist,String.valueof(deposit.Id));
        EI_TenentChangeoverApx.updatechchangeoverdetails(depolist ); 
        String jsonstring3 = '['+String.Valueof(Json.serialize(deposit))+']';
        String jsonstring2 = '['+String.Valueof(Json.serialize(wrap1))+']';
        String jsonstring =  String.Valueof(Json.serialize(depolist));
        String jsonstring1 = '['+String.Valueof(Json.serialize(depositallocation))+']';
        EI_TenentChangeoverApx.updatedetailstenantchangeover((String.valueof(deposit.Id)), String.valueof(c1.Id), jsonstring );
       
        EI_TenentChangeoverApx.tenancyinitiatedemaildetails(String.valueof(deposit.Id),depolist);
        EI_TenentChangeoverApx.getChangeOverCase();
        
        EI_TenentChangeoverApx.CreateNewCreditNote('abc','abc1', 200.0,String.valueof(deposit.Id),system.today(), string.valueof(case1.ID),c1,ba);
                         
         }
        
        }
         // method 6
        
       private static testmethod void EI_TenentChangeoverApx_Test6(){
       
      
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        
        System.runAs(userP){
            Insert new QueryLimits__c(CheckOn__c =  false, name = 'test');
            Account acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            ba = new Bank_Account__c();
            ba.Account__c = acc.Id;
            ba.Contact__c= acc.PersonContactId;
            ba.Account_Number__c='HGTY6543';
            ba.Bank_Name__c='testscotlandbank';
            insert ba;   
            
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];           
            insert deposit; 
            deposit.Tenant_Changeover_Deposit__c= string.valueof(deposit.id);
            deposit.Protected_Amount__c = 100;
            //deposit.Change_Overamount_Sum__c = 10;
            update deposit;
            depositlist.add(deposit);       
            
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
            case1 = new case();
            case1 .Status= 'Tenant changeover';
            case1.AccountId = acc.ID;
            case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            depositallocation =new Deposit_Allocation__c();
            depositallocation.Deposit__c = deposit.Id;
            depositallocation.Deposit_Holder__c = acc.id;
            depositallocation.Istenantmoved__c = true;
            depositallocation.Tenencychangeoveramount__c = 10;
            insert depositallocation;
            depolist.add(depositallocation);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
       System.runAs(userp){
       
      Try{
      
      EI_TenentChangeoverApx.approveChangeOver(string.valueof(case1 .id));
    
      } Catch(Exception e){}
                         
        }
        
        }
         
         // Method   7
          
        private static testmethod void EI_TenentChangeoverApx_Test7()
         
        {
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.PersonEmail = 'landlord@gmail.com';
        insert acc;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        system.assert(scheme!= null);
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
       List<Deposit_Allocation__c > dalist = new list<Deposit_Allocation__c >();
       
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = acc.id;
        depositallocation.Istenantmoved__c= true;
        insert depositallocation;
    
        
        dalist.add(depositallocation );
      
        
        EI_TenentChangeoverApx.getdeposittenantdetails(string.valueof(deposit.id),'true');
        
        Case  case1 = new case();
        case1.Status= 'Tenant changeover';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        insert case1 ;
       
       
        
        EI_TenentChangeoverApx.tenancyinitiatedemaildetails(string.valueof(deposit.id),dalist);
       test.starttest();
         Try{
         
         Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());
         EI_TenentChangeoverApx.rejectChangeOverbyagent(string.valueof(deposit.id));
         
         }catch(Exception e){}
         test.stoptest();
        } 
         // Method   8
          
        private static testmethod void EI_TenentChangeoverApx_Test8()
         
        {
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.PersonEmail = 'landlord@gmail.com';
        insert acc;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        system.assert(scheme!= null);
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
       List<Deposit_Allocation__c > dalist = new list<Deposit_Allocation__c >();
       
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = acc.id;
        depositallocation.Istenantmoved__c= true;
        insert depositallocation;
    
        
        dalist.add(depositallocation );
      
        
        EI_TenentChangeoverApx.getdeposittenantdetails(string.valueof(deposit.id),'true');
        
        Case  case1 = new case();
        case1.Status= 'Tenant changeover';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        insert case1 ;
       
       
        
        EI_TenentChangeoverApx.tenancyinitiatedemaildetails(string.valueof(deposit.id),dalist);
       
             
         Try{
         test.starttest();
         Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());
         EI_TenentChangeoverApx.updateCase(string.valueof(deposit.id)); 
         test.stoptest();
         }catch(Exception e){}
         
        } 
              // Method   9
          
        private static testmethod void EI_TenentChangeoverApx_Test9()
         
        {
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.PersonEmail = 'landlord@gmail.com';
        insert acc;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        system.assert(scheme!= null);
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
       List<Deposit_Allocation__c > dalist = new list<Deposit_Allocation__c >();
       
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = acc.id;
        depositallocation.Istenantmoved__c= true;
        insert depositallocation;
        
        Deposit_Allocation__c depositallocation1 =new Deposit_Allocation__c();
        depositallocation1.Deposit__c = deposit.Id;
        depositallocation1.Deposit_Holder__c = acc.id;
        depositallocation1.Istenantmoved__c= true;
        depositallocation1.Role__c ='Tenant';
        insert depositallocation1;
    
        
        dalist.add(depositallocation );
      
        
        EI_TenentChangeoverApx.getdeposittenantdetails(string.valueof(deposit.id),'true');
        
        Case  case1 = new case();
        case1.Status= 'Tenant changeover';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        insert case1 ;
        
        String jsonstring1 = '['+String.Valueof(Json.serialize(depositallocation))+']';
        
        EI_TenentChangeoverApx.createnewdeposit(String.valueof(deposit.Id),200,2, system.today(), jsonstring1,'change');
         Try{
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());
        EI_TenentChangeoverApx.updateIntBankDetailsOfTenant('13354647', 'abc','TestABC','testscotlandbank','chgt67','IBAN', string.valueof(acc.id),string.valueof(con.id));      
         test.stoptest();
         }catch(System.DmlException e){}
         }
         
         
        // Method   10
          
        private static testmethod void EI_TenentChangeoverApx_Test10()
        {
     
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        Account acc;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        System.runAs(userP){
        
            acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            
            
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            insert deposit; 
            depositlist.add(deposit);       
            
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
            ba = new Bank_Account__c();
            ba.Account__c = acc.Id;
            ba.Contact__c= c1.id;
            ba.Account_Number__c='HGTY6543';
            ba.Bank_Name__c='testscotlandbank';
            insert ba;  
            
            case1 = new case();
            case1 .Status= 'Tenant changeover';
            case1.AccountId = acc.ID;
            case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            depositallocation =new Deposit_Allocation__c();
            depositallocation.Deposit__c = deposit.Id;
            depositallocation.Deposit_Holder__c = acc.id;
            depositallocation.Istenantmoved__c = true;
            insert depositallocation;
            depolist.add(depositallocation);
            
            
        }
       
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Agent%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
        System.runAs(userd){
     
        Test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());
        //EI_TenentChangeoverApx.submitCaseOnChangeOver((String.valueof(deposit.Id)), string.valueof(acc.id), depositallocation );
        EI_TenentChangeoverApx.updateBankDetailsOfTenant('13354647', '560003','TestABC','testscotlandbank','','');
       
        Test.stoptest();
        }
        }
        
        // Method   11
          
        private static testmethod void EI_TenentChangeoverApx_Test11()
        {
     
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;  
        Account acc; 
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        System.runAs(userP){
        Insert new QueryLimits__c(CheckOn__c =  false, name = 'test');
             acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
           insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            ba = new Bank_Account__c();
                ba.Account__c = acc.Id;
                ba.Contact__c= acc.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
           
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
           
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            insert deposit; 
            depositlist.add(deposit);       

            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
             case1 = new case();
             case1 .Status= 'Tenant changeover';
             case1.AccountId = acc.ID;
             case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
           depositallocation =new Deposit_Allocation__c();
           depositallocation.Deposit__c = deposit.Id;
           depositallocation.Deposit_Holder__c = acc.id;
           depositallocation.Istenantmoved__c = true;
           insert depositallocation;
           depolist.add(depositallocation);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
       System.runAs(userd){
       
       test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());
        //EI_TenentChangeoverApx.updateIntBankDetailsOfTenant('13354647', 'abc','TestABC','testscotlandbank','chgt67','IBAN', null ,null); 
        EI_TenentChangeoverApx.updateIntBankDetailsOfTenant('13354647', 'abc','TestABC','testscotlandbank','chgt67','IBAN', '','');           
         test.stoptest();
       
         }
         }
         
          // Method   12
          
        private static testmethod void EI_TenentChangeoverApx_Test12()
        {
     
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;  
        Account acc; 
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        System.runAs(userP){
        Insert new QueryLimits__c(CheckOn__c =  false, name = 'test');
             acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
           insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            ba = new Bank_Account__c();
                ba.Account__c = acc.Id;
                ba.Contact__c= acc.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
           
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
           
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            insert deposit; 
            depositlist.add(deposit);       

            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
             case1 = new case();
             case1 .Status= 'Tenant changeover';
             case1.AccountId = acc.ID;
             case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
           depositallocation =new Deposit_Allocation__c();
           depositallocation.Deposit__c = deposit.Id;
           depositallocation.Deposit_Holder__c = acc.id;
           depositallocation.Istenantmoved__c = true;
           insert depositallocation;
           depolist.add(depositallocation);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
       System.runAs(userd){
       
       test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());
        EI_TenentChangeoverApx.updateIntBankDetailsOfTenant('13354647', 'abc','TestABC','testscotlandbank','chgt67','IBAN', null ,null); 
        //EI_TenentChangeoverApx.updateIntBankDetailsOfTenant('13354647', 'abc','TestABC','testscotlandbank','chgt67','IBAN', '','');           
         test.stoptest();
       
         }
         }
         
         
         
         // Method   13
          
        private static testmethod void EI_TenentChangeoverApx_Test13()
         
        {
        Account acc = new Account(Name = 'test1');
        //acc.PersonEmail = 'landlord@gmail.com';
        insert acc;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        system.assert(scheme!= null);
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        List<Deposit_Allocation__c > dalist = new list<Deposit_Allocation__c >();
       
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = acc.id;
        depositallocation.Istenantmoved__c= true;
        insert depositallocation;
    
        
        dalist.add(depositallocation );
      
        
        EI_TenentChangeoverApx.getdeposittenantdetails(string.valueof(deposit.id),'true');
        
        Case  case1 = new case();
        case1.Status= 'Tenant changeover';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        insert case1 ;
       
       
        
        EI_TenentChangeoverApx.tenancyinitiatedemaildetails(string.valueof(deposit.id),dalist);
        test.starttest();
        Try{
        
        //Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());
        EI_TenentChangeoverApx.rejectChangeOverbyagent(string.valueof(deposit.id));
        EI_TenentChangeoverApx.updateCase(string.valueof(deposit.id)); 
        }catch(Exception e){}
        test.stoptest();
        }
        
        
        // Method   14
          
        private static testmethod void EI_TenentChangeoverApx_Test14()
        {
     
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        Account acc;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        System.runAs(userP){
        
            acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            
            
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            insert deposit; 
            depositlist.add(deposit);       
            
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
            ba = new Bank_Account__c();
            ba.Account__c = acc.Id;
            ba.Contact__c= c1.id;
            ba.Account_Number__c='HGTY6543';
            ba.Bank_Name__c='testscotlandbank';
            insert ba;  
            
            case1 = new case();
            case1 .Status= 'Tenant changeover';
            case1.AccountId = acc.ID;
            case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            depositallocation =new Deposit_Allocation__c();
            depositallocation.Deposit__c = deposit.Id;
            depositallocation.Deposit_Holder__c = acc.id;
            depositallocation.Istenantmoved__c = true;
            insert depositallocation;
            depolist.add(depositallocation);
            
            
        }
       
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Agent%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
        System.runAs(userd){
     
        Test.starttest();
        
        EI_TenentChangeoverApx.submitCaseOnChangeOver((String.valueof(deposit.Id)), string.valueof(acc.id), depositallocation );
        
        Test.stoptest();
        }
        }
        
        
        
        // method 15
        
        private static testmethod void EI_TenentChangeoverApx_Test15(){
       
        EI_TenentChangeoverApx.FinalWrapper wrap1  = new EI_TenentChangeoverApx.FinalWrapper();
        EI_TenentChangeoverApx.getKey();
        wrap1.firstname= 'sdff';
        wrap1.SurName='sdfg';          
        wrap1.email ='sffg@gmail.com';         
        wrap1.phoneCode  ='+44';
        wrap1.phone='765424567889';
        wrap1.title='mr';  
        wrap1.IsOrg= true; 
        wrap1.companyName= 'espire';
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        System.runAs(userP){
        
                Insert new QueryLimits__c(CheckOn__c =  false, name = 'test');
                Account acc = new Account(Name = 'test1', OwnerId = userP.Id );
                insert acc;
                acclist.add(String.valueof(acc.id));
                
                insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
                
                ba = new Bank_Account__c();
                ba.Account__c = acc.Id;
                ba.Contact__c= acc.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
                
                branch3  = new Branch__c();
                branch3.Account__c = acc.Id;
                branch3.Branch_Name__c='branchsuman1';        
                insert branch3;
                
                Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
                insert property;
                system.assert(property!= null);
                Scheme__c scheme= EI_TestDataFactory.createScheme();
                insert scheme;
                system.assert(scheme!= null);
                deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
                insert deposit; 
                depositlist.add(deposit);       
                
                c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
                Database.insert(c1); 
                
                case1 = new case();
                case1 .Status= 'Tenant changeover';
                case1.AccountId = acc.ID;
                case1.status='Tenant changeover initiated - agent/landlord';
                case1 .ChangeOver_Status__c = 'Agent Approved';
                case1.Deposit_Account_Number__c = string.valueof(deposit.id);
                insert case1 ;  
                
                insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
                
                depositallocation =new Deposit_Allocation__c();
                depositallocation.Deposit__c = deposit.Id;
                depositallocation.Deposit_Holder__c = acc.id;
                depositallocation.Istenantmoved__c = true;
                depositallocation.Tenencychangeoveramount__c = 10;
                insert depositallocation;
                depolist.add(depositallocation);
                
                
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
        System.runAs(userd){

        //String jsonstring3 = '['+String.Valueof(Json.serialize(deposit))+']';
        //String jsonstring2 = '['+String.Valueof(Json.serialize(wrap1))+']';
        String jsonstring =  String.Valueof(Json.serialize(depolist));
        //String jsonstring1 = '['+String.Valueof(Json.serialize(depositallocation))+']';
        EI_TenentChangeoverApx.updatedetailstenantchangeover((String.valueof(deposit.Id)), String.valueof(c1.Id), jsonstring );
       
              
        } 
    }
        
     
     // method 16
        
       private static testmethod void EI_TenentChangeoverApx_Test16(){
       
        EI_TenentChangeoverApx.FinalWrapper wrap1  = new EI_TenentChangeoverApx.FinalWrapper();
        EI_TenentChangeoverApx.getKey();
        wrap1.firstname= 'sdff';
        wrap1.SurName='sdfg';          
        wrap1.email ='sffg@gmail.com';         
        wrap1.phoneCode  ='+44';
        wrap1.phone='765424567889';
        wrap1.title='mr';  
        wrap1.IsOrg= false; 
        wrap1.companyName= 'espire';
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit_Allocation__c depositallocation1 ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        System.runAs(userP){
        
            Account acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            ba = new Bank_Account__c();
            ba.Account__c = acc.Id;
            ba.Contact__c= acc.PersonContactId;
            ba.Account_Number__c='HGTY6543';
            ba.Bank_Name__c='testscotlandbank';
            insert ba;   
            
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            insert deposit; 
            depositlist.add(deposit);       
            
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
            case1 = new case();
            case1 .Status= 'Tenant changeover';
            case1.AccountId = acc.ID;
            case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            depositallocation =new Deposit_Allocation__c();
            depositallocation.Deposit__c = deposit.Id;
            depositallocation.Deposit_Holder__c = acc.id;
            depositallocation.Istenantmoved__c = true;
            depositallocation.Tenencychangeoveramount__c = 10;
            insert depositallocation;
            
            
            depositallocation1 =new Deposit_Allocation__c();
            depositallocation1.Deposit__c = deposit.Id;
            depositallocation1.Deposit_Holder__c = acc.id;
            depositallocation1.Istenantmoved__c = true;
            depositallocation1.Tenencychangeoveramount__c = 10;
            depositallocation1.Role__c='Tenant';
            insert depositallocation1;
            
            depolist.add(depositallocation);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
       System.runAs(userd){
     
        //Test.stopTest();
           
        String jsonstring3 = String.Valueof(Json.serialize(deposit));
        String jsonstring2 = '['+String.Valueof(Json.serialize(wrap1))+']';
        String jsonstring =  '['+String.Valueof(Json.serialize(depolist))+']';
        String jsonstring1 = '['+String.Valueof(Json.serialize(depositallocation))+']';
        String jsonstring4 =  String.Valueof(Json.serialize(depositlist));
       
        EI_TenentChangeoverApx.changeoverrequest3(string.valueof(deposit.id), 300, 2, system.today(), jsonstring1,jsonstring2 ,'cvf');
       
        //EI_TenentChangeoverApx.changeoverrequest2(String.valueof(deposit.Id),jsonstring,jsonstring4 ,'false');
                         
        }
        }
     
        
        
        // method 17
        
       private static testmethod void EI_TenentChangeoverApx_Test17(){
       
      
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        
        System.runAs(userP){
            Insert new QueryLimits__c(CheckOn__c =  false, name = 'test');
            Account acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            ba = new Bank_Account__c();
            ba.Account__c = acc.Id;
            ba.Contact__c= acc.PersonContactId;
            ba.Account_Number__c='HGTY6543';
            ba.Bank_Name__c='testscotlandbank';
            //insert ba;   
            
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];           
            insert deposit; 
            deposit.Tenant_Changeover_Deposit__c= string.valueof(deposit.id);
            deposit.Protected_Amount__c = 100;
            //deposit.Change_Overamount_Sum__c = 10;
            update deposit;
            depositlist.add(deposit);       
            
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
            case1 = new case();
            case1 .Status= 'Tenant changeover';
            case1.AccountId = acc.ID;
            case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            depositallocation =new Deposit_Allocation__c();
            depositallocation.Deposit__c = deposit.Id;
            depositallocation.Deposit_Holder__c = acc.id;
            depositallocation.Istenantmoved__c = true;
            depositallocation.Tenencychangeoveramount__c = 10;
            insert depositallocation;
            depolist.add(depositallocation);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
        System.runAs(userp){
       
          Try{
      
          EI_TenentChangeoverApx.approveChangeOver(string.valueof(case1 .id));
    
          } Catch(Exception e){}
                         
        }
        
    }
    
    
    
    
    // method 18
        
       private static testmethod void EI_TenentChangeoverApx_Test18(){
       
        EI_TenentChangeoverApx.FinalWrapper wrap1  = new EI_TenentChangeoverApx.FinalWrapper();
        EI_TenentChangeoverApx.getKey();
        wrap1.firstname= 'sdff';
        wrap1.SurName='sdfg';          
        wrap1.email ='sffg@gmail.com';         
        wrap1.phoneCode  ='+44';
        wrap1.phone='765424567889';
        wrap1.title='mr';  
        wrap1.IsOrg= true; 
        wrap1.companyName= 'espire';
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        
        System.runAs(userP){
            Insert new QueryLimits__c(CheckOn__c =  false, name = 'test');
            Account acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            ba = new Bank_Account__c();
            ba.Account__c = acc.Id;
            ba.Contact__c= acc.PersonContactId;
            ba.Account_Number__c='HGTY6543';
            ba.Bank_Name__c='testscotlandbank';
            insert ba;   
            
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            insert deposit; 
            depositlist.add(deposit);       
            system.assert(deposit!= null);
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
            case1 = new case();
            case1 .Status= 'Tenant changeover';
            case1.AccountId = acc.ID;
            case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            depositallocation =new Deposit_Allocation__c();
            depositallocation.Deposit__c = deposit.Id;
            depositallocation.Deposit_Holder__c = acc.id;
            depositallocation.Istenantmoved__c = true;
            insert depositallocation;
            depolist.add(depositallocation);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
        System.runAs(userd){
       

       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());   
        
        String jsonstring3 = '['+String.Valueof(Json.serialize(deposit))+']';
        String jsonstring2 = '['+String.Valueof(Json.serialize(wrap1))+']';
        String jsonstring =  String.Valueof(Json.serialize(depolist));
        String jsonstring4 =  String.Valueof(Json.serialize(depositlist));
        String jsonstring1 = '['+String.Valueof(Json.serialize(depositallocation))+']';
        Try{
        EI_TenentChangeoverApx.changeoverrequest2(String.valueof(deposit.Id),jsonstring,jsonstring4 ,'false');
        
        } Catch(Exception e){}
        Test.stopTest();
               
        }
        
        }
        
        
        // Method   19
          
        private static testmethod void EI_TenentChangeoverApx_Test19()
         
        {
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.PersonEmail = 'landlord@gmail.com';
        insert acc;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        system.assert(scheme!= null);
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        deposit.Customer__c = acc.Id;
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        List<Deposit_Allocation__c > dalist = new list<Deposit_Allocation__c >();
       
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = acc.id;
        depositallocation.Istenantmoved__c= true;
        insert depositallocation;
    
        
        dalist.add(depositallocation );
      
        Case  case1 = new case();
        case1.Status= 'Tenant changeover';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        insert case1 ;

        test.starttest();

        Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());
        
        Try{
        EI_TenentChangeoverApx.rejectChangeOver(String.valueof(case1.Id));

        }catch(Exception e){}
        test.stoptest();
        }
        
        
        
        // method 20
        
       private static testmethod void EI_TenentChangeoverApx_Test20(){
       
        EI_TenentChangeoverApx.FinalWrapper wrap1  = new EI_TenentChangeoverApx.FinalWrapper();
        EI_TenentChangeoverApx.getKey();
        wrap1.firstname= 'sdff';
        wrap1.SurName='sdfg';          
        wrap1.email ='sffg@gmail.com';         
        wrap1.phoneCode  ='+44';
        wrap1.phone='765424567889';
        wrap1.title='mr';  
        wrap1.IsOrg= true; 
        wrap1.companyName= 'espire';
        
       
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
        Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
        User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
                              UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US');
        insert userP;   
        contact con;
        Contact c1 ;
        Deposit_Allocation__c depositallocation ; 
        Deposit_Allocation__c depositallocation1 ; 
        Deposit__c deposit;
        Bank_Account__c ba;
        Branch__c branch3;
        List<String> acclist = new list<String>();
        List<Deposit_Allocation__c> depolist = new list<Deposit_Allocation__c>();
        Case  case1;
        List<deposit__c> depositlist= new list<deposit__c>();
        
        System.runAs(userP){
            Insert new QueryLimits__c(CheckOn__c =  false, name = 'test');
            Account acc = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc;
            acclist.add(String.valueof(acc.id));
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            ba = new Bank_Account__c();
            ba.Account__c = acc.Id;
            ba.Contact__c= acc.PersonContactId;
            ba.Account_Number__c='HGTY6543';
            ba.Bank_Name__c='testscotlandbank';
            insert ba;   
            
            branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            system.assert(scheme!= null);
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            insert deposit; 
            depositlist.add(deposit);       
            
            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1); 
            
            case1 = new case();
            case1 .Status= 'Tenant changeover';
            case1.AccountId = acc.ID;
            case1.status='Tenant changeover initiated - agent/landlord';
            case1 .ChangeOver_Status__c = 'Agent Approved';
            case1.Deposit_Account_Number__c = string.valueof(deposit.id);
            insert case1 ;  
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            
            depositallocation =new Deposit_Allocation__c();
            depositallocation.Deposit__c = deposit.Id;
            depositallocation.Deposit_Holder__c = acc.id;
            depositallocation.Istenantmoved__c = true;
            insert depositallocation;
            
            depositallocation1 =new Deposit_Allocation__c();
            depositallocation1.Deposit__c = deposit.Id;
            depositallocation1.Deposit_Holder__c = acc.id;
            depositallocation1.Istenantmoved__c = true;
            depositallocation1.Role__c='Tenant';
            insert depositallocation1;
            
            depolist.add(depositallocation);
            
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user7@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US' );
        Database.insert(userd);
     
       
        System.runAs(userd){
       

       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpBankResponseGenerator());   
        
        String jsonstring3 = '['+String.Valueof(Json.serialize(deposit))+']';
        String jsonstring2 = '['+String.Valueof(Json.serialize(wrap1))+']';
        String jsonstring =  String.Valueof(Json.serialize(depolist));
        String jsonstring4 =  String.Valueof(Json.serialize(depositlist));
        String jsonstring1 = '['+String.Valueof(Json.serialize(depositallocation))+']';
        Try{
        EI_TenentChangeoverApx.changeoverrequest2(String.valueof(deposit.Id),jsonstring,jsonstring4 ,'false');
        
        } Catch(Exception e){}
        Test.stopTest();
               
        }
        
        }
        
}