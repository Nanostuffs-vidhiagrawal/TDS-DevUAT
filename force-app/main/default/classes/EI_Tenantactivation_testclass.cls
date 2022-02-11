/*
@date  :     25/10/2021
@description : Testclass for - EI_Tenantactivation

*/
@isTest

private class EI_Tenantactivation_testclass{

        // Method   1   
    
        private static testmethod void EI_Tenantactivation_Test1()
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
            
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
            insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
            LandlordId__c = 173, TenantID__c = 643);
            
            acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            system.assert(acc1!= null);
            branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            c1 = new Contact( FirstName = 'test1',Additional_Permission__c= null, Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
            Database.insert(c1);   
            
            con = new Contact( FirstName = 'test1', Lastname = 'test2', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
            Database.insert(con);

            }
            
            System.runAs(userP){
                
                Contact convar = [select id,Email,firstname,lastname,Activation_Code_Used__c,Salutation,Activation_Code__c, Phone from contact where id =:  c1.Id];
                EI_Tenantactivation.checktenantdetails(String.Valueof(convar.Activation_Code__c),'7404346033','userxrets@espire.com');
                EI_Tenantactivation.checktenantdetails('+44','7404346033','userxrets@espire.com');
                EI_Tenantactivation.checktenantdetails(String.Valueof(convar.Activation_Code__c),'7404346033','user1@espire.com');
                EI_Tenantactivation.checktenantdetails(String.Valueof(convar.Activation_Code__c),'7404346033','user1@espire.com');
            }
        }
        
         // Method   2   
    
        private static testmethod void EI_Tenantactivation_Test2()
        {
        
            UserRole portalRole = [Select Id From UserRole Where PortalType = 'none' Limit 1];
            Profile pProfile = [Select Id from Profile where name = 'System Administrator'];
            User userP = new User(Username = System.now().millisecond() + 'user1@espire.com', ProfileId = pProfile.Id,
            UserRoleId = portalRole.Id, Alias = 'al', Email = 'user1@espire.com', EmailEncodingKey = 'UTF-8', LastName = 'l',
            CommunityNickname = 'chec',Department='1062', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US');
            insert userP;   
            contact con;
            Contact c1 ;
            Account acc1; 
            
            Branch__c branch3;
            
            System.runAs(userP){
            acc1 = new Account(Name = 'test1', OwnerId = userP.Id );
            insert acc1;
            system.assert(acc1!= null);
            branch3  = new Branch__c();
            branch3.Account__c = acc1.Id;
            branch3.Branch_Name__c='branchsuman1';        
            insert branch3;
            
            c1 = new Contact( FirstName = ' ',Additional_Permission__c= null, Lastname = 'l', AccountId = acc1.Id, Email = 'as123@test.com',phone = '7404346033');
            Database.insert(c1);   
            
            
            }
            
            System.runAs(userP){
                
               
                Contact convar1 = [select id,Email,firstname,lastname,Activation_Code_Used__c,Salutation,Activation_Code__c, Phone from contact where id =:  c1.Id];
                EI_Tenantactivation.checktenantdetails(String.Valueof(convar1.Activation_Code__c),'7404346033','user1@espire.com');
            }
        
}
}