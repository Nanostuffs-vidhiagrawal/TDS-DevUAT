/*
@date  :     29/09/2021
@description : Testclass for - EI_AddNonMemberLandlord
*/
@IsTest

private class EI_AddNonMemberLandlord_testclass{
        
        // Method   1   
    
        private static testmethod void EI_AddNonMemberLandlord_Test1()
        {
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
         EI_AddNonMemberLandlord.getPropertyRegNumber(String.valueof(property.id), '35dhhj');
         EI_AddNonMemberLandlord.getPropertyRegNumber(String.valueof(property.id), '');
         EI_AddNonMemberLandlord.getPropertyDetails(String.valueof(property.id));
         EI_AddNonMemberLandlord.landlordList(String.valueof(property.id));
         EI_AddNonMemberLandlord.landlordRegistrationStatusList();
         EI_AddNonMemberLandlord.checkDuplicateRecord('abc@gmail.com','test1','lastname');
         EI_AddNonMemberLandlord.checkDuplicateRecord('xyz@xyz.com','test','test');   
         EI_AddNonMemberLandlord.getPhoneCodePiclistValues();    
        }
        // Method   2   
    
        private static testmethod void EI_AddNonMemberLandlord_Test2()
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
        Deposit__c deposit;       
        MemberId__c myMember;
        Branch__c branch3;
        Property__c property;
        
        System.runAs(userP){
            Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            
            property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
            property.Landlord_Registration_Number__c= 'er566';
            property.Local_Authority_Area__c = 'Edinburgh';
            property.City__c = 'Edinburgh';
            insert property;
            
            branch3  = new Branch__c();
            branch3.Branch_Name__c='xyztest';
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;
            
            deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
            insert deposit;        

            c1 = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
            Database.insert(c1);   
            
            Property_Allocation__c pa= new Property_Allocation__c();
            pa.Property__c= property.ID;
            pa.Contact__c= c1.id;
            pa.Landlord_Registration_Number__c='text';
            pa.Landlord_Registrataion_Status__c='Landlord is not registered';
            insert pa;        
            
        }
        
        Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
        User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
                              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
                              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
        Database.insert(userd);

        Test.StartTest();
        
        

        System.runAs(userd){
        
        EI_AddNonMemberLandlord.getPropertyRegNumber(String.valueof(property.id), '35dhhj');
        EI_AddNonMemberLandlord.getPropertyDetails(String.valueof(property.id));
        EI_AddNonMemberLandlord.savelandlord(String.valueof(branch3.Id) ,'Mr','firstname','lastname','avj@gmail.com',
                                     '+44','1355677','companyname1','+44','556778',true,
                                    'street','city','DD566','country',
                                   'county','4rg','LandRegNumber','Landlord is not registered');
        // boolean value false                        
                                   
        EI_AddNonMemberLandlord.savelandlord(String.valueof(branch3.Id) ,'Mr','firstname','lastname','avj@gmail.com',
         '+44','1355677','companyname1','+44','556778',false,
        'street','city','DD566','country',
        'county','4rg','LandRegNumber','Landlord is not registered');
        
        
        }
        Test.stoptest();
        }
        }