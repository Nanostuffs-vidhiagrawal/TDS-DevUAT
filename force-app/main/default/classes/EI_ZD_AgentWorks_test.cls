@isTest
public class EI_ZD_AgentWorks_test {
    @istest(SeeAllData=true)
    public static void testMethod1(){
       /* QueryLimits__c queryLimits = EI_ZD_TestDataFactory.createQueryLimit();
        queryLimits.CheckOn__c= false;
        //insert queryLimits;
        Scheme__c scheme= EI_ZD_TestDataFactory.createScheme();
        insert scheme;
        account Landlord = EI_ZD_TestDataFactory.createLandlord(1)[0];
        insert Landlord;
        account Tenant = EI_ZD_TestDataFactory.createTenant(1)[0];
        insert Tenant;
        Property__c property= EI_ZD_TestDataFactory.createProperty(1,Landlord.id)[0];
        insert property;
        Deposit__c deposit= EI_ZD_TestDataFactory.createDeposite(1,scheme.id,Landlord.id,property.id)[0];
        insert deposit;
        case dispute = EI_ZD_TestDataFactory.createDispute(1,deposit.id)[0];
        insert dispute;
        dispute.Status='Evidence review complete';
        update dispute;
        Case_Participant__c casetenant = EI_ZD_TestDataFactory.createCaseParticipant(1,dispute.id,Tenant.id,'Tenant')[0];
        insert casetenant;
        Case_Participant__c caselandlord = EI_ZD_TestDataFactory.createCaseParticipant(1,dispute.id,Landlord.id,'Landlord')[0];
        insert caselandlord;
       // Test.startTest();
        MemberId__c myMemberid =MemberId__c.getInstance('MemberID');
        Case_Participant__c usr= [select id,Contact__c,Contact__r.firstname,contact__r.lastname,contact__r.email,
                                  contact__r.Phone,contact__r.Salutation
                                  from Case_Participant__c
                                  where Case__c=:dispute.id and Type__c='Tenant'];
        
        User u = new User();
        String fullName = usr.Contact__r.firstname + usr.contact__r.lastname;
        if (fullName.length() >= 5){
            u.alias = fullName.substring(0, 4);
        } else{
            u.alias = fullName;
        }
        String nickname ='test';
        u.CommunityNickname = nickname;
        u.Title = usr.Contact__r.Salutation;
        u.FirstName = usr.Contact__r.FirstName;
        u.LastName = usr.Contact__r.lastname;
        u.Username = usr.Contact__r.Email;
        u.Phone = usr.Contact__r.Phone;
        u.Email = usr.Contact__r.Email;
        u.ProfileId = [Select Id,name from profile where name = 'System Administrator' limit 1].Id;
        u.TimeZoneSidKey = 'Europe/London';
        u.LocaleSidKey = 'en_GB';
        u.LanguageLocaleKey = 'en_US';
        u.User_Type__c='Tenant';
        u.EmailEncodingKey = 'ISO-8859-1';
        insert u;
        ID SChannelId= [SELECT Id FROM ServiceChannel Where DeveloperName='Disputes' Limit 1].Id;
        user usr1 =[select id from user where id='0058E000008MxiS'];*/
        
        List<AgentWork> agentWorks = [SELECT Id FROM AgentWork LIMIT 1];
        Test.startTest();
        update agentWorks;
        Test.stopTest(); 

       // Test.stopTest();
    }
    
}