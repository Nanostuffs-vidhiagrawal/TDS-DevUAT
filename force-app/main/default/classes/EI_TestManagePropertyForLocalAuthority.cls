@isTest
public class EI_TestManagePropertyForLocalAuthority {
    
    
     @isTest
    public static void getpropertyforlocal(){
        
       Profile p = [SELECT Id FROM Profile WHERE Name='Local Authority']; 
    	User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, Area_Code__c = '222',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
             
Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();  
        
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'KP';
        insert a;
        
        
        /*contact c = new Contact();
         c.LastName = 'KP1';
        c.AccountId = a.Id;
         c.Sent_Via_Post__c = True;
        c.Account_Type__c ='Agent';
        insert c;*/
        
      Property__c objProperty = new Property__c();
       objProperty.City__c ='Nagpur';
       objProperty.Country__c ='India';
       objProperty.Street__c = 'Manish Nagar';
       objProperty.Property_Owner__c = a.id; 
       objProperty.Postal_Code__c = '111';
       Insert objProperty;
        
        set<Id>custid =new set<Id>();
		Property_Allocation__c b = new Property_Allocation__c();
        b.Property__c = objProperty.id;
        b.Landlord_Registration_Number__c = '111111/222/11111';
        insert b;       
          
        //string acclist = b.Landlord_Registration_Number__c;
 		List<Property__c> getResult = ManagePropertyForLocalAuthority.getBranchList();        
        System.Debug('getResult = > ' + getResult);
        System.Debug('objProperty = > ' + objProperty);
         System.Debug('objProperty = > ' +b);
        
       
        //for(Property_Allocation__c acc:[select id,Landlord_Registration_Number__c from Property_Allocation__c where id=:b.Id]){
            
                    // string acclist1 = acc.Landlord_Registration_Number__c;

        
        //}
        //acc.Landlord_Registration_Number__c = '333';
        
        
        //System.assertEquals(acc.Landlord_Registration_Number__c,'222');
        //System.assert(acc!=null);      
 
        
        
    }
    
    
     @isTest
    public static void getsearch(){
        
          
        
       /* Profile p = [SELECT Id FROM Profile WHERE Name='Local Authority']; 
    User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, Area_Code__c = '222',
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');*/
        
             
Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();  
        
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'KP';
        insert a;
        
        
        /*contact c = new Contact();
         c.LastName = 'KP1';
        c.AccountId = a.Id;
         c.Sent_Via_Post__c = True;
        c.Account_Type__c ='Agent';
        insert c;*/
        
      Property__c objProperty = new Property__c();
       objProperty.City__c ='Nagpur';
       objProperty.Country__c ='India';
       objProperty.Street__c = 'Manish Nagar';
       objProperty.Property_Owner__c = a.id; 
       objProperty.Postal_Code__c = '111';
       Insert objProperty;
        
        
	Property_Allocation__c b = new Property_Allocation__c();
         b.Property__c = objProperty.id;
        b.Landlord_Registration_Number__c = '222';
        insert b;
        
        
         List<Property__c> getSearch = ManagePropertyForLocalAuthority.myPropertyList('suyog');   
        
        
       // Property_Allocation__c acc=[select id,Landlord_Registration_Number__c from Property_Allocation__c where id=:b.id];
        
        //System.assertEquals(acc.Landlord_Registration_Number__c,'222');
 
        
        
    }

}