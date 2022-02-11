@isTest
global class EI_ZD_PaymentAPI_test {
    
    @TestSetup
    Public static void TestSetupMethod(){
        Scheme__c scheme= EI_ZD_TestDataFactory.createScheme();
        insert scheme;
        QueryLimits__c queryLimits = EI_ZD_TestDataFactory.createQueryLimit();
        insert queryLimits;
        ZD_Payment_API__c payment=EI_ZD_TestDataFactory.createPaymentCustomSetting();
        insert payment;
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
        
        
    }
    @istest
    public static void testMethod1(){
        Test.startTest();
        case dispute = [select id,External_ID__c from case];
        account Tenant = [select id,Tenant_External_ID__c from Account where LastName ='Tenant Name0'];
        Scheme__c scheme = [select id from Scheme__c];
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        EI_ZD_PaymentAPI.getperformcallout(dispute.id,dispute.External_ID__c,'Tenant',145.00,'Zero Deposite',Tenant.Tenant_External_ID__c);
        EI_ZD_PaymentAPI.getperformcalloutTrigger(dispute.id,dispute.External_ID__c,'Tenant',145.00,'Zero Deposite',Tenant.Tenant_External_ID__c,'Tenant');
        EI_ZD_MileStone.getCaseDetails(dispute.id);
        Test.stopTest();
    }
    
    global class AnimalLocatorMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{"tenant": 3527,"url": "https://uat-app.zerodeposit.com/tenants/repayment/start/MzYwODI:1m3wsg:E9ESeABkI9KL_loBu57naySfRd2JuT-TiR8X5sNx0zc/"}]');
            response.setStatusCode(201);
            return response; 
        }
    }
}