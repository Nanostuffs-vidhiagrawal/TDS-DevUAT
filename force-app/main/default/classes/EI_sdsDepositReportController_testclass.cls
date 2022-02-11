//@description : Testclass for -  EI_sdsDepositReportController

@isTest
private class  EI_sdsDepositReportController_testclass{
        
        // method 1
        private static testmethod void EI_sdsDepositReportController_Test1(){
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
        Repayment_Request__c reprequest;
        Installment__c installment;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        deposit.Case_Status__c = 'Deposit closed - deposit paid in part';
        deposit.Customer__c = a.id;
        deposit.Status__c= 'Deposits repayments concluded in the last year';
        insert deposit;
        reprequest = new Repayment_Request__c();
        reprequest.Deposit__c = deposit.id;
        reprequest.Account__c = a.id;
        insert reprequest; 
        installment = new Installment__c();
        installment.Deposit__c = deposit.id;
        installment.Installment_Type__c='Payable';
        installment.Status__c='Paid'; 
        insert installment;
        system.assert(scheme!= null);
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
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
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
       
        System.runAs(us1){
        Try{
        EI_sdsDepositReportController.fetchdeposit1(system.today(),system.today()+1);
        EI_sdsDepositReportController.fetchdeposit2(system.today(),system.today()+1);
        EI_sdsDepositReportController.fetchdeposit3(system.today(),system.today()+1);      
        EI_sdsDepositReportController.fetchdeposit4();   
        }catch(System.DmlException e){}
        }
        }
        // method 2 
        private static testmethod void EI_sdsDepositReportController_Test2(){
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
        Repayment_Request__c reprequest;
        Installment__c installment;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'test@user.com');
        insert a;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        
        property= EI_TestDataFactory.createProperty(1,a.id)[0];
        insert property;
        
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,a.id,property.id)[0];
        deposit.Case_Status__c = 'Deposit closed - deposit repaid in full';
        deposit.Customer__c = a.id;
        deposit.Status__c= 'Deposits repayments concluded in the last year';
        insert deposit;
        reprequest = new Repayment_Request__c();
        reprequest.Deposit__c = deposit.id;
        reprequest.Account__c = a.id;
        insert reprequest; 
        installment = new Installment__c();
        installment.Deposit__c = deposit.id;
        installment.Installment_Type__c='Payable';
        installment.Status__c='Paid'; 
        insert installment;
        system.assert(scheme!= null);
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :a.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Agent' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
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
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
       
        System.runAs(us1){
        Try{
         
        EI_sdsDepositReportController.fetchdeposit5(system.today(),system.today()+1);
        }catch(System.DmlException e){}
        }
        
        }
        }