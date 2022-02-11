@isTest
public class EI_TestsdsDepositReportController {
    
 @isTest
 public static void getreport1(){
        
       Profile p = [SELECT Id FROM Profile WHERE Name='Local Authority']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, Area_Code__c = '222',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
             
Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Letting Agent').getRecordTypeId();  
        
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'XYZ';
        insert a;
     
     	Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
                
        Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;  
        d.Scheme__c = s.Id;
        insert d;
            
         Date startDate = Date.parse('8/8/2021');
        Date endDate = Date.parse('10/8/2021');
 		List<Deposit__c> getReport = EI_sdsDepositReportController.fetchdeposit1(startDate, endDate);        
        System.Debug('getResult = > ' + getReport);
               
        
    }
    
    @isTest
 public static void getreport2(){
        
       Profile p = [SELECT Id FROM Profile WHERE Name='Local Authority']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, Area_Code__c = '222',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
             
Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Letting Agent').getRecordTypeId();  
        
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'XYZ';
        insert a;
     
     	Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
                
        Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;  
        d.Scheme__c = s.Id;
        insert d;
            
         Date startDate = Date.parse('8/8/2021');
        Date endDate = Date.parse('10/8/2021');
 		List<Deposit__c> getReport = EI_sdsDepositReportController.fetchdeposit2(startDate, endDate);        
        System.Debug('getResult = > ' + getReport);
               
        
    }
    
     @isTest
 public static void getreport3(){
        
       Profile p = [SELECT Id FROM Profile WHERE Name='Local Authority']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, Area_Code__c = '222',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
             
Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Letting Agent').getRecordTypeId();  
        
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'XYZ';
        insert a;
     
     	Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
                
        Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;  
        d.Scheme__c = s.Id;
        insert d;
            
         Date startDate = Date.parse('8/8/2021');
        Date endDate = Date.parse('10/8/2021');
 		List<Deposit__c> getReport = EI_sdsDepositReportController.fetchdeposit3(startDate, endDate);        
        System.Debug('getResult = > ' + getReport);
               
        
    }
    
     @isTest
 public static void getreport4(){
        
       Profile p = [SELECT Id FROM Profile WHERE Name='Local Authority']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, Area_Code__c = '222',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
             
Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Letting Agent').getRecordTypeId();  
        
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'XYZ';
        insert a;
     
     	Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
                
        Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;  
        d.Scheme__c = s.Id;
        insert d;
            
         Date startDate = Date.parse('8/8/2021');
        Date endDate = Date.parse('10/8/2021');
 		List<Deposit__c> getReport = EI_sdsDepositReportController.fetchdeposit4(startDate, endDate);        
        System.Debug('getResult = > ' + getReport);
               
        
    }
    
    
     @isTest
 public static void getreport5(){
        
       Profile p = [SELECT Id FROM Profile WHERE Name='Local Authority']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, Area_Code__c = '222',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
             
Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Letting Agent').getRecordTypeId();  
        
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'XYZ';
        insert a;
     
     	Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
                
        Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;  
        d.Scheme__c = s.Id;
        insert d;
            
         Date startDate = Date.parse('8/8/2021');
        Date endDate = Date.parse('10/8/2021');
 		List<Deposit__c> getReport = EI_sdsDepositReportController.fetchdeposit5(startDate, endDate);        
        System.Debug('getResult = > ' + getReport);
               
        
    }
    
    
    
    

}