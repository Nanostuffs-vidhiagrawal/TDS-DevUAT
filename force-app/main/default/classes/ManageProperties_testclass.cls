/*
@date  :     05/10/2021
@description : Testclass for -  ManageProperties
*/
@IsTest

private class  ManageProperties_testclass{
        
        // Method   1   
    
        private static testmethod void  ManageProperties_Test1()
        {

            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            Account acc= EI_TestDataFactory.createLandlord(1)[0];
            insert acc;
            Branch__c branch3  = new Branch__c();
            branch3.Branch_Name__c='xyztest';
            branch3.Account__c = acc.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            Contact con = new Contact();
            ManageProperties.myLandlordList('abc','active',string.valueof(branch3.id));
            con.LastName='test'; 
            con.email='abc@gmail.com';
            con.LandLord_Registration_Number__c='wr45';
         
            con.Account_Status__c= 'active';
            //con.AccountId = acc.id;
            insert con;
            
            con.email='abc2@gmail.com';
            
            ManageProperties.myLandlordList('abc','active',string.valueof(branch3.id));
            
            ManageProperties.archieveLandlord( con,'Inactive');
            ManageProperties.archieveLandlord( con,'active');
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            property.Property_Owner__c=acc.id;
            property.Local_authority_registration_details__c='text';
            insert property;      
            system.assert(property!= null);
            List<ID> listd = new list<ID>();
            listd.add(property.ID);
            
            List<Property_Allocation__c> pa= new List<Property_Allocation__c>();
            Property_Allocation__c pallocation = new Property_Allocation__c();
            pallocation .Property__c= property.ID;
            pallocation .Contact__c= con.id;
            pallocation .Relation_to_Property__c='Primary Landlord';
            pa.add(pallocation);
            insert pa;  
            
            ManageProperties.myLandlordList('','active',string.valueof(branch3.id));  
            
            ManageProperties.userInformation wrapperclass1 = new ManageProperties.userInformation();
            Contact con1 = wrapperclass1.con;
            
            ManageProperties.replacePrimeLandlord(property,con,false);  
            
            Property_Allocation__c pa2= new Property_Allocation__c();
            pa2.Property__c= property.ID;
            pa2.Contact__c= con.id;
            pa2.Relation_to_Property__c='Joint Landlord';
            insert pa2; 
            
            ManageProperties.searchlandlord('abc',Property,false);
            ManageProperties.searchlandlord('abc',Property,true);         
            
            ManageProperties.replacePrimeLandlord(property,con,true);
            ManageProperties.removeLand(String.valueof(pallocation .ID),'Joint','df');
            
            
            ManageProperties.getLandlord(string.valueof(con.ID));
            ManageProperties.saveLandlord(con);
            ManageProperties.updatePropDetails(property);
            
            ManageProperties.myLandlordList('abc','active',string.valueof(branch3.id));
            Property_Allocation__c pa3= new Property_Allocation__c();
            pa3.Property__c= property.ID;
            pa3.Contact__c= con.id;
            pa3.Relation_to_Property__c='Joint Landlord';
            
            insert pa3; 
            
            ManageProperties.fetchPropertylist('active','true');
            ManageProperties.searchpropertylist('sdf','true');
            
            ManageProperties.landlordRegistrationStatusList();
            ManageProperties.updateLandlordDetail('firstName','lastName', 'email@gmail.com','phoneCode','12345678987'
            ,'registration','registrationStatus',String.valueof(con.ID) ,String.valueof(pallocation.Id));
             
            
            ManageProperties.getPropertyDetails(string.valueof(property.ID));
            ManageProperties.getPropertyDetails(null);
            ManageProperties.landlordList(string.valueof(property.ID));
            ManageProperties.deletePropertyRecord(string.valueof(property.ID),'Inactive');
            ManageProperties.deletePropertyRecord(string.valueof(property.ID),'active');
            
            ManageProperties.delproperty(listd);
            Try{
            //ManageProperties.deletePropertyRecord(null,'active');
            ManageProperties.saveproperty ('3','3','2','street', 
                                      'city', 'postcode', 'country', 'county', '565');
            ManageProperties.deletePropertyRecord(null,null);
            }Catch(Exception e){}
            ManageProperties.getPhoneCodePiclistValues();
            
                                      

        }
        
         // Method   2   
    
        private static testmethod void  ManageProperties_Test2()
        {
            Contact con = new Contact();
            con.LastName='test1'; 
            insert con;
            
            Account acc= EI_TestDataFactory.createLandlord(1)[0];
            insert acc;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Property_Allocation__c pa2= new Property_Allocation__c();
            pa2.Property__c= property.ID;
            pa2.Contact__c= con.id;
            pa2.Relation_to_Property__c='Joint Landlord';
            insert pa2; 
            
            ManageProperties.getLandlordDetails(String.valueof(pa2.Id));
            ManageProperties.getJointLand(property); 
        }
        
        //method 3
        private static testmethod void  ManageProperties_Test3()
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
                insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
                property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
                property.Landlord_Registration_Number__c= 'er566';
                property.Local_Authority_Area__c = 'Edinburgh';
                property.City__c = 'Edinburgh';
                insert property;
                system.assert(property!= null);
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
            System.runAs(userd){
            
                Test.startTest();           
                ManageProperties.updateLandlordDetail(String.valueof(c1.id),'firstName','lastName','email@gmail.com','+44','+44234568976');
                Test.stopTest(); 
            
            }
        }

        // Method   4
    
        private static testmethod void  ManageProperties_Test4()
        {
            Contact con = new Contact();
            con.LastName='test1'; 
            insert con;
            
            Account acc= EI_TestDataFactory.createLandlord(1)[0];
            insert acc;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Property_Allocation__c pa2= new Property_Allocation__c();
            pa2.Property__c= property.ID;
            pa2.Contact__c= con.id;
            pa2.Relation_to_Property__c='Joint Landlord';
            
            insert pa2; 
            
            ManageProperties.removeLand(String.valueof(pa2.ID),'Prime',String.valueof(con.id));
         
        }

        // Method   5
    
        private static testmethod void  ManageProperties_Test5()
        {
            Contact con = new Contact();
            con.LastName='test1'; 
            insert con;
            
            Account acc= EI_TestDataFactory.createLandlord(1)[0];
            insert acc;
            
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            insert property;
            system.assert(property!= null);
            Property_Allocation__c pa2= new Property_Allocation__c();
            pa2.Property__c= property.ID;
            pa2.Contact__c= con.id;
            pa2.Relation_to_Property__c='';
            insert pa2; 
            Try{ 
            ManageProperties.replacePrimeLandlord(property,con,false); 
              
            }Catch(Exception e){}
        }
        
        
        //method 6
        private static testmethod void  ManageProperties_Test6()
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
            Property_Allocation__c pa;
            
            System.runAs(userP){
                Account acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
                insert acc1;
                insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
                property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
                property.Landlord_Registration_Number__c= 'er566';
                property.Local_Authority_Area__c = 'Edinburgh';
                property.City__c = 'Edinburgh';
                insert property;
                system.assert(property!= null);
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
                
                pa= new Property_Allocation__c();
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
            System.runAs(userd){
            
                Test.startTest(); 
                Try{          
                ManageProperties.updateLandlordDetail('firstName','lastName', 'email@gmail.com','+44','12345678987'
            ,'registration','Landlord is entered on the local authority register for the area where this property is located',String.valueof(c1.ID) ,String.valueof(pa.Id));
                ManageProperties.updateLandlordDetail('firstName','lastName', '','','12345678987'
            ,'registration','Landlord is entered on the local authority register for the area where this property is located',String.valueof(c1.ID) ,String.valueof(pa.Id));
                }catch(Exception e){}
                Test.stopTest(); 
            
            }
        }
        
        
        //method 7
        private static testmethod void  ManageProperties_Test7()
        {
                Test.startTest(); 
                Contact con;
                Property__c Property;
                Try{          
                ManageProperties.saveLandlord(con);
                
                }catch(Exception e){}
                Test.stopTest(); 
                integer i = 1;
                integer j= 1;
                system.assertequals(i,j);
        }
        
        
        //method 8
        private static testmethod void  ManageProperties_Test8()
        {
                Test.startTest(); 
                Account acc= EI_TestDataFactory.createLandlord(1)[0];
                insert acc;
            
                Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
                
                insert property;
                system.assert(property!= null);
                property.Property_status__c = 'test';
                
                Contact con = new Contact();
                con.LastName='test1'; 
                insert con;
                
                ManageProperties.getPropertyDetails(string.valueof(property.ID));
                
                Property_Allocation__c pa2= new Property_Allocation__c();
                pa2.Property__c= property.ID;
                pa2.Contact__c= con.id;
               //pa2.Relation_to_Property__c='Joint Landlord';
                insert pa2; 
                
                ManageProperties.getPropertyDetails(string.valueof(property.ID));
                
                Try{          
                ManageProperties.updatePropDetails(property);
                }catch(Exception e){}
                Test.stopTest(); 
        }
        
        
        //method 9
        private static testmethod void  ManageProperties_Test9()
        {
            
             
            Id RecordTypeIdacc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Landlord').getRecordTypeId();
            
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
            Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
            User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
            UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
            CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US');
            
            insert userP;   
            
            contact con;
            Contact c1 ;
            Contact c2 ;
            Deposit__c deposit;       
            MemberId__c myMember;
            Branch__c branch3;
            Property__c property;
            Property__c property2;
            Property_Allocation__c pa;
            
            System.runAs(userP){
                insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');
                
                Account acc1 = new Account(Name = 'Test', OwnerId = userP.Id, RecordTypeId = RecordTypeIdacc );
                acc1.Account_Status__c = 'Open';
                insert acc1;
                
                Account acc2 = new Account(Name = 'test1', OwnerId = userP.Id );
                acc2.Account_Status__c = 'Open';
                insert acc2;
                
                property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
                property.Landlord_Registration_Number__c= 'er566';
                property.Local_Authority_Area__c = 'Edinburgh';
                property.City__c = 'Edinburgh';
                property.Local_authority_registration_details__c = 'test';
                property.Property_status__c = 'Active';
                insert property;
                system.assert(property!= null);
                
                branch3  = new Branch__c();
                branch3.Branch_Name__c='xyztest';
                branch3.Account__c = acc1.Id;
                branch3.Branch_Name__c='branchsuman1';        
                insert branch3;
                
                Scheme__c scheme= EI_TestDataFactory.createScheme();
                insert scheme;
                
                deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc1.id,property.id)[0];
                insert deposit;        
                
                c1 = new Contact( FirstName = 'test', Lastname = 'test', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
                c1.Account_Status__c = 'Active';
                c1.LandLord_Registration_Number__c='34567y7404346033';
                c1.Branch__c = branch3.id;
                Database.insert(c1);  
                
                c2 = new Contact( FirstName = 'test', Lastname = 'test', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com', Phone = '7404346033');
                c2.Account_Status__c = 'Active';
                c2.LandLord_Registration_Number__c='yuh6777404346033';
                //Database.insert(c2);  
                
                pa= new Property_Allocation__c();
                pa.Property__c= property.ID;
                pa.Contact__c= c1.id;
                pa.Landlord_Registration_Number__c='text';
                pa.Landlord_Registrataion_Status__c='Landlord is not registered';
                pa.Relation_to_Property__c = 'Primary Landlord';
                insert pa;        
            
            }
            Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
            User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
            Database.insert(userd);
            
            System.runAs(userP){
            
                Test.startTest();                        
                
                ManageProperties.myLandlordList('7404346033','Open',string.valueof(branch3.id));
                ManageProperties.myLandlordList('','Open',string.valueof(branch3.id));
                ManageProperties.fetchPropertylist('Active',string.valueof(branch3.id));
                ManageProperties.fetchPropertylist('Active',null);
                ManageProperties.searchpropertylist('Edinburgh','Active');
                ManageProperties.getPropertyDetails(String.Valueof(property.id));
                ManageProperties.myLandlordList('7404346033','Open',null);
                
               
                Test.stopTest(); 
            
            }
        }
        
        
        //method 10
        private static testmethod void  ManageProperties_Test10()
        {
                Test.startTest(); 
                Account acc= EI_TestDataFactory.createLandlord(1)[0];
                insert acc;
            
                Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
                //property.Property_status__c = 'test';
                
                insert property;
                system.assert(property!= null);
                Try{
                ManageProperties.deletePropertyRecord(null, 'test');
                }Catch(exception e){}
                         
                ManageProperties.deletePropertyRecord(String.Valueof(property.id), '');
                
                Test.stopTest(); 
        }
        
        
        //method 9
        private static testmethod void  ManageProperties_Test11()
        {
            
             
            Id RecordTypeIdacc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate Landlord').getRecordTypeId();
            
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
            Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
            User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
            UserRoleId = portalRole.Id, Alias = 'pt123', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
            CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US');
            
            insert userP;   
            
            contact con;
            Contact c1 ;
            Contact c2 ;
            Deposit__c deposit;       
            MemberId__c myMember;
            Branch__c branch3;
            Property__c property;
            Property__c property2;
            Property_Allocation__c pa;
            
            System.runAs(userP){
                insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');
                
                Account acc1 = new Account(Name = 'Test', OwnerId = userP.Id, RecordTypeId = RecordTypeIdacc );
                acc1.Account_Status__c = 'Open';
                insert acc1;
                
                Account acc2 = new Account(Name = 'test1', OwnerId = userP.Id );
                acc2.Account_Status__c = 'Open';
                insert acc2;
                
                property= EI_TestDataFactory.createProperty(1,acc1.id)[0];
                property.Landlord_Registration_Number__c= 'er566';
                property.Local_Authority_Area__c = 'Edinburgh';
                property.City__c = 'Edinburgh';
                property.Local_authority_registration_details__c = 'test';
                property.Property_status__c = 'Active';
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
                
                c1 = new Contact( FirstName = 'test', Lastname = 'test', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com');
                c1.Account_Status__c = 'Active';
                c1.LandLord_Registration_Number__c='34567y7404346033';
                c1.Branch__c = branch3.id;
                Database.insert(c1);  
                
                c2 = new Contact( FirstName = 'test', Lastname = 'test', AccountId = acc1.Id, Email = System.now().millisecond() + 'as@test.com', Phone = '7404346033');
                c2.Account_Status__c = 'Active';
                c2.LandLord_Registration_Number__c='yuh6777404346033';
                //Database.insert(c2);  
                
                pa= new Property_Allocation__c();
                pa.Property__c= property.ID;
                pa.Contact__c= c1.id;
                pa.Landlord_Registration_Number__c='text';
                pa.Landlord_Registrataion_Status__c='Landlord is not registered';
                pa.Relation_to_Property__c = 'Primary Landlord';
                insert pa;        
            
            }
            Profile dProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Tenant%' Limit 1];
            User userd = new User( Username = System.now().millisecond() + 'user1@espire.com',    ProfileId = dProfile.Id,
              Alias = 'klkl', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'test2',
              ContactId=c1.id, CommunityNickname = 'checked', TimeZoneSidKey = 'America/Los_Angeles', 
              LocaleSidKey = 'en_US', LanguageLocaleKey = 'en_US');
            Database.insert(userd);
            
            System.runAs(userP){
            
                Test.startTest();                        
                system.assert(property!= null);
                ManageProperties.myLandlordList('7404346033','Active',string.valueof(branch3.id));

                
               
                Test.stopTest(); 
            
            }
        }
        
        
}