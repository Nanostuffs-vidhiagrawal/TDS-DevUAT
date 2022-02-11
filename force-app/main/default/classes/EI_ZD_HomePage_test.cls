@isTest
public class EI_ZD_HomePage_test {
   /* @TestSetup
    Public static void TestSetupMethod(){
        
        
    } */
    @istest(SeeAllData=true)
    public static void testMethod1(){
        QueryLimits__c queryLimits = EI_ZD_TestDataFactory.createQueryLimit();
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
        Case_Participant__c casetenant = EI_ZD_TestDataFactory.createCaseParticipant(1,dispute.id,Tenant.id,'Tenant')[0];
        insert casetenant;
        Case_Participant__c caselandlord = EI_ZD_TestDataFactory.createCaseParticipant(1,dispute.id,Landlord.id,'Landlord')[0];
        insert caselandlord;
        Test.startTest();
        //case dispute1 = [select id,External_ID__c from case where id=:dispute];
        MemberId__c myMemberid =MemberId__c.getInstance('MemberID');
        Case_Participant__c usr= [select id,Contact__c,Contact__r.firstname,contact__r.lastname,contact__r.email,
                                                     contact__r.Phone,contact__r.Salutation,Contact__r.Account.RecordType.name
                                                     from Case_Participant__c
                                                     where Case__c=:dispute.id and Type__c='Tenant'];
           system.debug('--->>'+usr.Contact__r.Account.RecordType.name);
        
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
            u.ProfileId = [Select Id,name from profile where name = 'ZD_Tenant' limit 1].Id;
            u.TimeZoneSidKey = 'Europe/London';
            u.LocaleSidKey = 'en_GB';
            u.LanguageLocaleKey = 'en_US';
            u.ContactId = usr.Contact__c;
            u.User_Type__c='Tenant';
            u.EmailEncodingKey = 'ISO-8859-1';
        insert u;
        system.runAs(u){
            EI_ZD_HomePage.getLoginUserDetails();
            EI_ZD_HomePage.getCaseDetails(caselandlord.Access_Code__c); 
            EI_ZD_HomePage.saveDisputeLine(100.00, 102.00, 50.20, 10.20, 110.00, 100.00,'test', dispute.id, true);
            EI_ZD_HomePage.calculateWorkingDaysBetweenTwoDates(system.today(), 10);
            EI_ZD_HomePage.validateUser(usr.id,'ggj');
            EI_ZD_HomePage.validateUser(usr.id,'xyz');
            EI_ZD_CommonHeader_cc.getTenantDetails(caselandlord.Access_Code__c,'agent');
            EI_ZD_CommonHeader_cc.getTenantDetails('dksk','tenant');
            activationEmail ae = new activationEmail();
            ae.recordId = u.id;
            ae.totalClaim=100.00;
            ae.respondDate = string.valueOf(system.today());
            ae.add ='test rec';
            ae.getAddress();
            ae.getRespondDate();
            ae.getTotalclaim();
            EI_ZD_HomePage.deactivateuser();
        }
            
        
        
        
        Test.stopTest();
    }

}