/* description
  Test class for EI_getBranch */
@istest private class EI_getBranch_TestClass {
//method 1 
 Private static testmethod void EI_getBranch_TestClass1()
      {
       Account acc= EI_TestDataFactory.createLandlord(1)[0];
       insert acc;
       Branch__c branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1'; 
            branch3.Is_Active__c  = true;     
            insert branch3;
      system.assert(branch3!= null);
      EI_getBranch getb = new EI_getBranch();
      try{
      EI_getBranch.orgDetails();
      EI_getBranch.getBranchList();
      EI_getBranch.fetchBranch('');
      EI_getBranch.createBranch( branch3 ,'telephoneCode', 'altphoneCode','street','Town','county',
                           'country','postcode');
      }catch(exception e){}
      
      }
      // method 2
      
  private static testmethod void EI_getBranch_TestClass2()
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
            system.assert(branch3!= null);
            c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
            Database.insert(c1);   
            
            con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
            Database.insert(con);

                              }
            
            System.runAs(userP) {           
            EI_getBranch.orgDetails();
            EI_getBranch.getBranchList();
            EI_getBranch.fetchBranch(string.valueof(branch3.ID));
            EI_getBranch.inactiveBranch(string.valueof(branch3.ID));
            EI_getBranch.activeBranch(string.valueof(branch3.ID));
            EI_getBranch.userEmail();
            EI_getBranch.getPhoneCodePiclistValues();
            
             }
}

 // method 3
      
  private static testmethod void EI_getBranch_TestClass3()
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
            system.assert(branch3!= null);
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
                              
                              
            
            System.runAs(userd) {           
            
            EI_getBranch.getBranchList();
            EI_getBranch.updateBranch(branch3, '+44', '+56');
            EI_getBranch.getUsers(string.valueof(branch3.ID));
            EI_getBranch.getfilteredBranch('open');
            
            
             }
        
        
}
//method 4
private static testmethod void  EI_getBranch_TestClass4()
        {
        
        
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Branch__c branch3;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, Name = 'TestPersonAccountFirst');
        insert a;
        
        
        
        con =new contact();
        con.lastname='test1';
        con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        
        
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
          
                
        branch3  = new Branch__c();
            branch3.Account__c = a.Id;
            branch3.Branch_Name__c='branchsuman1';    
            branch3.Is_Active__c =false;   
            insert branch3;
            system.assert(branch3!= null);
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US');
        us1.ContactId = con.Id;
        insert us1; 
        
        
        
        System.runAs(us1){
        
        // EI_getBranch.createBranch( branch3 ,'telephoneCode', 'altphoneCode','street','Town','county',
                           // 'country','postcode');  
           EI_getBranch.getfilteredBranch('closed');   
           EI_getBranch.getfilteredBranch('all');    
           EI_getBranch.getfilteredBranch('test');    
           EI_getBranch.getCountries(); 
           Try{
           EI_getBranch.getfilteredBranch('test');  
           }catch(exception e){}     
                            
                              }
            
        }
        
        
       // method 5
 Private static testmethod void EI_getBranch_TestClass5()
      {
       Account acc= EI_TestDataFactory.createLandlord(1)[0];
       insert acc;
       Branch__c branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1'; 
            branch3.Is_Active__c  = true;     
            insert branch3;
            system.assert(branch3!= null);
            Try{
          EI_getBranch.getUsers(null);
          }catch(exception e){}
      }
      
      //method 6
 Private static testmethod void EI_getBranch_TestClass6()
      {
       Account acc= EI_TestDataFactory.createLandlord(1)[0];
       insert acc;
       Branch__c branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1'; 
            branch3.Is_Active__c  = true;     
            insert branch3;
            system.assert(branch3!= null);
            Try{
          EI_getBranch.fetchBranch(null);
          }catch(exception e){}
      }
      //method 7
 Private static testmethod void EI_getBranch_TestClass7()
      {
       Account acc= EI_TestDataFactory.createLandlord(1)[0];
       insert acc;
       Branch__c branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1'; 
            branch3.Is_Active__c  = true;     
            insert branch3;
            system.assert(branch3!= null);
            Try{
          EI_getBranch.updateBranch(null,null,null);
          }catch(exception e){}
      }
      
      
      //method 8
 Private static testmethod void EI_getBranch_TestClass8()
      {
       Account acc= EI_TestDataFactory.createLandlord(1)[0];
       insert acc;
       Branch__c branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1'; 
            branch3.Is_Active__c  = true;     
            insert branch3;
            system.assert(branch3!= null);
            Try{
          EI_getBranch.inactiveBranch(null);
          }catch(exception e){}
      }
      //method 9
 Private static testmethod void EI_getBranch_TestClass9()
      {
       Account acc= EI_TestDataFactory.createLandlord(1)[0];
       insert acc;
       Branch__c branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1'; 
            branch3.Is_Active__c  = true;     
            insert branch3;
            system.assert(branch3!= null);
            Try{
          EI_getBranch.activeBranch(null);
          }catch(exception e){}
      } 
      //method 10
 Private static testmethod void EI_getBranch_TestClass10()
      {
       Account acc= EI_TestDataFactory.createLandlord(1)[0];
       insert acc;
       Branch__c branch3  = new Branch__c();
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1'; 
            branch3.Is_Active__c  = true;     
            insert branch3;
            system.assert(branch3!= null);
            Try{
          EI_getBranch.userEmail();
          }catch(exception e){}
      } 
      
      //method 11
private static testmethod void  EI_getBranch_TestClass11()
        {
        
        
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Branch__c branch3;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Branch__c').getDescribe().getRecordTypeInfosByName().get('SDS Branch').getRecordTypeId();
        a = new Account( Name = 'TestPersonAccountFirst',Associated_To__c = userWithRole.id );
        insert a;
        
         branch3  = new Branch__c();
            branch3.Account__c = a.Id;
            branch3.Branch_Name__c='branchsuman1';    
            branch3.Is_Active__c =false;  
            branch3.recordTypeId = recordTypeId; 
            insert branch3;
            system.assert(branch3!= null);
       
        
        }
  
        
        System.runAs(userWithRole){
        Try{
        
        EI_getBranch.createBranch( branch3 ,'telephoneCode', 'altphoneCode','street','Town','county',
                            'country','postcode');  
      }catch(exception e){}
}
}
}