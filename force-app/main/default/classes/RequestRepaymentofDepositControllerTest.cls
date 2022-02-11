@isTest
public class RequestRepaymentofDepositControllerTest {
    // method 1  
    @isTest
    public static void RequestRepaymentofDepositControllerTest_test1(){
    
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username= System.now().millisecond() + 'userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Account acc;
        Bank_Account__c bankaccount;
        
        
        System.runAs(userWithRole){
        
        acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.Phone = null;
        insert acc;
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.Phone = null;
        insert a;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643); 
      
        
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        RequestRepaymentOfDepositController.removeInternationalBankDetailsInfo(string.valueof(con.id));
        
        bankaccount = new Bank_Account__c();
        bankaccount.Account__c = acc.id;
        bankaccount.Contact__c= con.id; 
        insert bankaccount;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,Phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
    
        
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = System.now().millisecond() +'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
       
        System.runAs(us1){

        RequestRepaymentOfDepositController.getBankDetails();
        RequestRepaymentOfDepositController.removeInternationalBankDetailsInfo(string.valueof(con.id));
        RequestRepaymentOfDepositController.fetchErrorLabel();    
        RequestRepaymentOfDepositController.CheckBankDetailsOfTenant();
        RequestRepaymentOfDepositController.getDepositInformation(string.valueof(deposit.id));
        RequestRepaymentOfDepositController.getLoggedInTenantInformation(string.valueof(deposit.id));
        RequestRepaymentOfDepositController.getTenantsInformation(string.valueof(deposit.id));
        RequestRepaymentOfDepositController.updateIntBankDetailsOfTenant('bankIntName','bankIntaddress','bankIntAccountName','ankIdentificationCode','bankSwiftCode','IBAN');
        
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new RequestRepayDepoControllerCallout());
        RequestRepaymentOfDepositController.updateBankDetailsOfTenant('accountNumber','sortCode','bankAccountName','bankName');
        
        test.stoptest();
        }
   
}
    
    // method 2
    @isTest
    public static void RequestRepaymentofDepositControllerTest_test2(){
    
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username= System.now().millisecond() + 'userwithrole@testorg.com');
        insert userWithRole;
        
        Map<Id,List<Account>> accMap = new Map<Id,List<Account>>();
        List<Account> acclist = new List<Account>();
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Account acc;
        Bank_Account__c bankaccount;
        
        
        System.runAs(userWithRole){
        
        acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.Phone = null;
        insert acc;
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.Phone = null;
        insert a;
        //acclist.add(a);
        acclist.add(acc);
        accMap.put(a.Id, acclist);
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643); 
      
        
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        RequestRepaymentOfDepositController.removeInternationalBankDetailsInfo(string.valueof(con.id));
        
        bankaccount = new Bank_Account__c();
        bankaccount.Account__c = acc.id;
        bankaccount.Contact__c= con.id; 
        insert bankaccount;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,Phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
    
        
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = System.now().millisecond() +'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
       
        System.runAs(us1){
        
        String values = json.serialize(acclist);
        Try{
        RequestRepaymentOfDepositController.insertRepaymentReqTenant(String.valueof(deposit.Id), String.valueof(a.Id),system.today(), values, 'customerName', 
                                                  100.00, 100.00, 50.00, 
                                                  50.00, 20.00, 40.00, 
                                                 'Tenant_Other_Reason');
        }catch(Exception e){}
        }
   
    }
// method 3
    @isTest
    public static void RequestRepaymentofDepositControllerTest_test3(){
    
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username= System.now().millisecond() + 'userwithrole@testorg.com');
        insert userWithRole;
        
        Map<Id,List<Account>> accMap = new Map<Id,List<Account>>();
        List<Account> acclist = new List<Account>();
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Account acc;
        Bank_Account__c bankaccount;
        Repayment_Request__c req;
        
        System.runAs(userWithRole){
        
        acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.Phone = null;
        insert acc;
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.Phone = null;
        insert a;
        //acclist.add(a);
        acclist.add(acc);
        accMap.put(a.Id, acclist);
        req = new Repayment_Request__c ();
        req.Account__c = a.id;
        insert req;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643); 
      
        
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        RequestRepaymentOfDepositController.removeInternationalBankDetailsInfo(string.valueof(con.id));
        
        bankaccount = new Bank_Account__c();
        bankaccount.Account__c = acc.id;
        bankaccount.Contact__c= con.id; 
        insert bankaccount;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,Phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
    
        
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = System.now().millisecond() +'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
       
        System.runAs(us1){
        
        String values = json.serialize(acclist);
        Try{
        RequestRepaymentOfDepositController.insertRepaymentReq(String.valueof(deposit.Id), 100.00, 20.00, 30.00, 30.00, 
                                           100.00, 50.00, 'othReason', 200.00, String.valueof(a.Id),
                                            'btnTxt', 2, system.today(), 'values', 
                                            string.valueof(req.id), String.valueof(con.Id));
        }catch(Exception e){}
        }
   
     }   
     // method 4
    @isTest
    public static void RequestRepaymentofDepositControllerTest_test4(){
    
    
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username= System.now().millisecond() + 'userwithrole@testorg.com');
        insert userWithRole;
        
        Map<Id,List<Account>> accMap = new Map<Id,List<Account>>();
        List<Account> acclist = new List<Account>();
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Account acc;
        Bank_Account__c bankaccount;
        Repayment_Request__c req;
        Deposit_Allocation__c depoallocation;
        case case1;
        Repayment_Request_Line__c reqline;
        
        System.runAs(userWithRole){
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643); 
        
        acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.Phone = null;
        insert acc;
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.Phone = null;
        insert a;
        
        
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        
        
        //acclist.add(a);
        acclist.add(acc);
        accMap.put(a.Id, acclist);
        
        req = new Repayment_Request__c ();
        req.Account__c = a.id;
        req.Deposit__c = deposit.id;
        insert req;
      
        
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        
        depoallocation = new Deposit_Allocation__c();
        depoallocation.Deposit__c =  deposit.id;
        depoallocation.Role__c = 'Tenant';
        depoallocation.Deposit_Holder__c = a.id;
        depoallocation.Is_Lead__c = true;
        insert depoallocation ;
        
        bankaccount = new Bank_Account__c();
        bankaccount.Account__c = a.id;
        bankaccount.Contact__c= con.id; 
        insert bankaccount;
        
        case1 = new case();
        case1.AccountId = a.id;
        case1.status = 'Repayment requested - agent/landlord';
        case1.Deposit_Account_Number__c = deposit.id;
        insert case1;
       
       
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,Phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = System.now().millisecond() +'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
       
        System.runAs(us1){
        
        String values = json.serialize(acclist);
        Try{
        RequestRepaymentOfDepositController.insertRepaymentReq(String.valueof(deposit.Id), null, null, null, null, 
                                           null, null, null, 200.00, String.valueof(a.Id),
                                            'btnTxt', 2, system.today(), values, 
                                            null, String.valueof(con.Id));
                                            
         RequestRepaymentOfDepositController.insertRepaymentReq(String.valueof(deposit.Id), null, null, null, null, 
                                           null, null, null, 200.00, String.valueof(a.Id),
                                            'btnTxt', 2, system.today(), values, 
                                           String.valueof(req.Id), String.valueof(con.Id)); 
         RequestRepaymentOfDepositController.getRepaymentRequestLineDetails(String.valueof(con.Id)); 
          RequestRepaymentOfDepositController.submitRepaymentRequestDetails(String.valueof(req.Id));       
         RequestRepaymentOfDepositController.deleteDetailsOfRepaymentRequest(String.valueof(req.Id));                        
        }catch(Exception e){}
        }
   
 }
 // method 5
    @isTest
    public static void RequestRepaymentofDepositControllerTest_test5(){
    
    
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username= System.now().millisecond() + 'userwithrole@testorg.com');
        insert userWithRole;
        
        Map<Id,List<Account>> accMap = new Map<Id,List<Account>>();
        List<Account> acclist = new List<Account>();
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Account acc;
        Bank_Account__c bankaccount;
        Repayment_Request__c req;
        Deposit_Allocation__c depoallocation;
        case case1;
        Repayment_Request_Line__c reqline;
        
        System.runAs(userWithRole){
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643); 
        
        acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.Phone = null;
        insert acc;
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Tenant').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.Phone = null;
        insert a;
        
        
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        
        
        //acclist.add(a);
        acclist.add(acc);
        accMap.put(a.Id, acclist);
        
        req = new Repayment_Request__c ();
        req.Account__c = a.id;
        req.Deposit__c = deposit.id;
        insert req;
      
        
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        
        depoallocation = new Deposit_Allocation__c();
        depoallocation.Deposit__c =  deposit.id;
        depoallocation.Role__c = 'Tenant';
        depoallocation.Deposit_Holder__c = a.id;
        depoallocation.Is_Lead__c = true;
        insert depoallocation ;
        
        bankaccount = new Bank_Account__c();
        bankaccount.Account__c = a.id;
        bankaccount.Contact__c= con.id; 
        insert bankaccount;
        
        case1 = new case();
        case1.AccountId = a.id;
        case1.status = 'Repayment requested - agent/landlord';
        case1.Deposit_Account_Number__c = deposit.id;
        insert case1;
       
        reqline = new Repayment_Request_Line__c();
        reqline.Repayment_Request__c = req.id;
        reqline.Account__c = a.id;
        insert reqline;
        
      
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,Phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = System.now().millisecond() +'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
       
        System.runAs(us1){
        
        String values = json.serialize(acclist);
        Try{
      
          RequestRepaymentOfDepositController.submitRepaymentRequestDetails(String.valueof(req.Id));       
                         
        }catch(Exception e){}
        }
   
 }
    // method 6
    @isTest
    public static void RequestRepaymentofDepositControllerTest_test6(){
    
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username= System.now().millisecond() + 'userwithrole@testorg.com');
        insert userWithRole;
        
        Account a;
        Property__c property;
        Scheme__c scheme;
        Deposit__c deposit;
        List<contact> conlist = new list <contact>();
        contact con;
        Account acc;
        Bank_Account__c bankaccount;
        
        
        System.runAs(userWithRole){
        
        acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.Phone = null;
        insert acc;
        
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        a.Phone = null;
        insert a;
        
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643); 
      
        
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        RequestRepaymentOfDepositController.removeInternationalBankDetailsInfo(string.valueof(con.id));
        
        
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        insert deposit;
        system.assert(deposit!= null );
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,Phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
    
        bankaccount = new Bank_Account__c();
        bankaccount.Account__c = acc.id;
        bankaccount.Contact__c= acc1.PersonContactId; 
        insert bankaccount;
        }
        
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = System.now().millisecond() +'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
        
        //Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,Phone From Bank_Account__c Where Id = :a.Id];
       
        System.runAs(us1){
    
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new RequestRepayDepoControllerCallout());
        RequestRepaymentOfDepositController.CheckBankDetailsOfTenant();
        RequestRepaymentOfDepositController.updateIntBankDetailsOfTenant('bankIntName','bankIntaddress','bankIntAccountName','ankIdentificationCode','bankSwiftCode','IBAN');
        
        test.stoptest();
        }
   }
   }