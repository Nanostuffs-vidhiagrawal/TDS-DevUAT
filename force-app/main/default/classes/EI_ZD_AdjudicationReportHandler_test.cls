@isTest
global class EI_ZD_AdjudicationReportHandler_test {
    @TestSetup
    Public static void TestSetupMethod(){
        Scheme__c scheme= EI_ZD_TestDataFactory.createScheme();
        insert scheme;
        QueryLimits__c queryLimits = EI_ZD_TestDataFactory.createQueryLimit();
        queryLimits.CheckOn__c = false;
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
        Dispute_Item__c cleaning = createDisputeItem(1,dispute.id,'Cleaning')[0];
        insert cleaning;
        Adjudication_Report__c adReport = createAdjudicationReport(1,dispute.id)[0];
        insert adReport;
        
        
    }
    @istest
    public static void testMethod1(){
        Test.startTest();
        system.debug('');
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        Adjudication_Report__c adrRecords = [select id,Dispute__c,Status__C from Adjudication_Report__c limit 1];
        adrRecords.Webhook_Report_Link__c ='dhhdkkdd';
        adrRecords.Status__C='Published';
        update adrRecords;
        Test.stopTest();
    }
    
    
    
    public static list<Dispute_Item__c> createDisputeItem(Integer numberOfClients,id caseID,string Type )
    {
        List<Dispute_Item__c> disputeItems = new List<Dispute_Item__c>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Dispute_Item__c disputeItem = new Dispute_Item__c(Dispute__c =caseID,
                                                              Type__c=Type,
                                                              Claimed_by_Landlord__c =400.00,
                                                              Tenant_Response__c=240.00 );
            
            disputeItems.add(disputeItem);
        }
        return disputeItems;
    }
    public static list<Adjudication_Report__c> createAdjudicationReport(Integer numberOfClients,id caseID)
    {
        List<Adjudication_Report__c> AdjudicationReports = new List<Adjudication_Report__c>();
        for ( Integer i = 0 ; i < numberOfClients ; i++ ) 
        {
            Adjudication_Report__c AdjudicationReport = new Adjudication_Report__c(Dispute__c =caseID,
                                                                                   Decision_Type__c='Adjudication',
                                                                                   Status__C='Draft'
                                                                                  );
            
            AdjudicationReports.add(AdjudicationReport);
        }
        return AdjudicationReports;
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