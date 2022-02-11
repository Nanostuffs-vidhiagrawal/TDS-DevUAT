@isTest
public class EI_TenantevidencegatheringclassTest {
	
    @isTest
    public static void getclaimdetailsforevidence(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'On Hold';
        caseObj.On_Hold_Reason__c = 'Court order';
        caseObj.On_Hold_Start_Date__c = date.newInstance(2021,10,12);
        caseObj.On_Hold_End_Date__c = date.newInstance(2021,10,23);
        caseObj.PreviousStatus__c = 'Evidence Gathering TT';
        caseObj.AccountId = acc.id;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Agent';
        casePart.Account__c = acc.id;
        insert casePart;
        
        Dispute_Item__c desp = new Dispute_Item__c();
        desp.Adjustment_Percentage_by_AGLL__c = 68;
        desp.Dispute__c = caseObj.id;
        desp.Type__c = 'Cleaning';
        insert desp;        
        
        Evidence_Attachment__c eviAttach = new Evidence_Attachment__c();
        eviAttach.Dispute_Item__c = desp.id;
        eviAttach.Dispute__c = caseObj.id;
        eviAttach.Evidence_Categories__c ='	Tenant obligations';
        insert eviAttach;
        
        Test.startTest();
        list<case> listCase = EI_Tenantevidencegatheringclass.getclaimdetailsforevidence(deposit.id);
        System.assert(listCase != null);
        Test.stopTest();
    }
    
    @isTest
    public static void getClaimDetails(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Agent';
        casePart.Account__c = acc.id;
        insert casePart;
        
        Dispute_Item__c desp = new Dispute_Item__c();
        desp.Adjustment_Percentage_by_AGLL__c = 68;
        desp.Dispute__c = caseObj.id;
        desp.Type__c = 'Cleaning';
        insert desp;        
        
        Evidence_Attachment__c eviAttach = new Evidence_Attachment__c();
        eviAttach.Dispute_Item__c = desp.id;
        eviAttach.Dispute__c = caseObj.id;
        eviAttach.Evidence_Categories__c ='	Tenant obligations';
        insert eviAttach;
        
        Test.startTest();
        list<case> listCase = EI_Tenantevidencegatheringclass.getClaimDetails(caseObj.id);
        System.assert(listCase != null);
        Test.stopTest();
    
    }
    
    @isTest
    public static void getCurrentDate(){
         Date today1 = Date.parse('21/10/26');
         string method1res1 = EI_Tenantevidencegatheringclass.getCurrentDate( );
       
    }
    
    @isTest
    public static void UpdateDisputeItemSelfResolution(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
       // acc.LastName = 'potter';
       // acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.External_ID__c ='2345';
        caseObj.AGLL_Respond_Self_resolution__c = true;
        caseObj.Claim_Agreed_By__c = 'Agent/Landlord';
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Agent';
        casePart.Account__c = acc.id;
        insert casePart;
        
        List<Dispute_Item__c> dispList = new List<Dispute_Item__c>();
        Dispute_Item__c desp = new Dispute_Item__c();
        desp.Adjustment_Percentage_by_AGLL__c = 68;
        desp.Dispute__c = caseObj.id;
        desp.Type__c = 'Cleaning';
        dispList.add(desp); 
        
        String jsonstring1 = String.Valueof(Json.serialize(dispList));
        // String jsonstring1 = '['+String.Valueof(Json.serialize(dispList))+']';
        Test.startTest();
        
        String message = EI_Tenantevidencegatheringclass.UpdateDisputeItemSelfResolution(jsonstring1,'AGLL',caseObj.id);
        Test.stopTest();
    }
    
    @isTest
    public static void fetchErrorLabel(){
        Test.startTest();
        EI_Tenantevidencegatheringclass.fetchErrorLabel();
        Test.stopTest();
    }
    
    @isTest
    public static void getclaimdetailsforevidenceNoConsent(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
       // acc.LastName = 'potter';
       // acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.External_ID__c ='2345';
        caseObj.AGLL_Respond_Self_resolution__c = true;
        caseObj.Date_claim_notified__c = System.today();
        insert caseObj ;
        
        try{
       // EI_Tenantevidencegatheringclass.wrapper  wrap1 = new   EI_Tenantevidencegatheringclass.wrapper();
        EI_Tenantevidencegatheringclass.getclaimdetailsforevidenceNoConsent(String.valueOf(deposit.id));
        }Catch(Exception e){}
       
    }
    
    @isTest
    public static void updatekeyDocuments(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.Consent_box_AGLL__c='Yes';
        caseObj.AGLL_Respond_Evidance_Gathering__c = true;
        caseObj.Tenant_obligations__c = 'Yes';
        insert caseObj ;
       
        Test.startTest();
        EI_Tenantevidencegatheringclass.updatekeyDocuments(caseObj.id,'wed4','Yes','55','wer','cddeqd');
        Test.stopTest();
    }
    
    @isTest
    public static void UpdateClaimDetails(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
      //  caseObj.Status= 'Case cancelled';
        caseObj.AccountId = acc.id;
        caseObj.Consent_box_AGLL__c='Yes';
        caseObj.AGLL_Respond_Evidance_Gathering__c = true;
        caseObj.Tenant_obligations__c = 'Yes';
       // caseObj.Close_Reason__c ='Case Closed';
        caseObj.Claim_Agreed_By__c = 'Agent/Landlord';
        insert caseObj ;
       
        Test.startTest();
        string message =  EI_Tenantevidencegatheringclass.UpdateClaimDetails(caseObj.id,'Agent/Landlord',400.00,'SDS','1234');
        Test.stopTest();
    }
    
    @isTest
    public static void UpdateClaimDetailsforElse(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.Consent_box_AGLL__c='Yes';
        caseObj.AGLL_Respond_Evidance_Gathering__c = true;
        caseObj.Tenant_obligations__c = 'Yes';
        caseObj.Claim_Agreed_By__c = 'Agent/Landlord';
        insert caseObj ;
       
        Test.startTest();
        string message =  EI_Tenantevidencegatheringclass.UpdateClaimDetails(caseObj.id,'Tenant',400.00,'SDS','1234');
        Test.stopTest();
    }
    
    @isTest
    public static void AGLLMadeOffers(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.Consent_box_AGLL__c='Yes';
        caseObj.AGLL_Respond_Evidance_Gathering__c = true;
        caseObj.Tenant_obligations__c = 'Yes';
        caseObj.Claim_Agreed_By__c = 'Agent/Landlord';
        caseObj.AGLL_Offer_Response__c = 'Accept';
        insert caseObj ;
       
        Test.startTest();
        try{
        EI_Tenantevidencegatheringclass.AGLLMadeOffers(caseObj.id,'Accepted',400);
        }Catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    public static void AGLLMadeOffersForRejected(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.Consent_box_AGLL__c='Yes';
        caseObj.AGLL_Respond_Self_resolution__c = true;
        caseObj.Tenant_obligations__c = 'Yes';
        caseObj.Claim_Agreed_By__c = 'Agent/Landlord';
        caseObj.AGLL_Offer_Response__c = 'Reject';
        insert caseObj ;
       
        Test.startTest();
        EI_Tenantevidencegatheringclass.AGLLMadeOffers(caseObj.id,'Rejected',400);
        Test.stopTest();
    }
    
    @isTest
    public static void AGLLMadeOffersForRejectedForCounterOffer(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.Consent_box_AGLL__c='Yes';
        caseObj.AGLL_Respond_Self_resolution__c = true;
        caseObj.Tenant_obligations__c = 'Yes';
        caseObj.Claim_Agreed_By__c = 'Agent/Landlord';
        caseObj.AGLL_Offer_Response__c = 'Counter Offer';
        insert caseObj ;
       
        Test.startTest();
        EI_Tenantevidencegatheringclass.AGLLMadeOffers(caseObj.id,'Counter Offer',400);
        Test.stopTest();
    }
    
    @isTest
    public static void TTMadeOffers(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.Tenant_obligations__c = 'Yes';
        caseObj.Claim_Agreed_By__c = 'Tenant';
        caseObj.TT_Offer_Response__c = 'Accept';
        insert caseObj ;
       
        Test.startTest();
        try{
        EI_Tenantevidencegatheringclass.TTMadeOffers(caseObj.id,'Accepted',400.88);
        }Catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    public static void TTMadeOffersForNewOffer(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_Self_resolution__c = true;
        caseObj.Claim_Agreed_By__c = 'Tenant';
        caseObj.TT_Offer_Response__c = 'Reject';
        insert caseObj ;
       
        Test.startTest();
        EI_Tenantevidencegatheringclass.TTMadeOffers(caseObj.id,'Rejected',400.88);
        Test.stopTest();
    }
    
    @isTest
    public static void TTMadeOffersForRejected(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_Self_resolution__c = true;
        caseObj.TT_Made_offer__c = true;
        caseObj.TT_Offer_Response__c = 'Reject';
        insert caseObj ;
       
        Test.startTest();
        EI_Tenantevidencegatheringclass.TTMadeOffers(caseObj.id,'New Offer',400.88);
        Test.stopTest();
    }
    
    @isTest
    public static void TTMadeOffersForRejectedForCounterOffer(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.Consent_box_AGLL__c='Yes';
        caseObj.TT_Made_offer__c = true;
        caseObj.Tenant_obligations__c = 'Yes';
        caseObj.Claim_Agreed_By__c = 'Agent/Landlord';
        caseObj.AGLL_Offer_Response__c = 'Counter Offer';
        insert caseObj ;
       
        Test.startTest();
        EI_Tenantevidencegatheringclass.TTMadeOffers(caseObj.id,'Counter Offer',400);
        Test.stopTest();
    }
    
    @isTest
    public static void getClaimDetailsByAccessCode(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Agent';
        casePart.Account__c = acc.id;
        casePart.Access_Code__c = '3456';
        insert casePart;
        
        Test.startTest();
        List<Case> caseList = EI_Tenantevidencegatheringclass.getClaimDetailsByAccessCode('3456');
        System.assert(caseList != null);
        Test.stopTest();
	}
    
    @isTest
    public static void AgreedByAgent(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_Self_resolution__c = true;
        caseObj.Claim_Agreed_By__c = 'Agent/Landlord';
        insert caseObj ;
       
        Test.startTest();
        try{
        EI_Tenantevidencegatheringclass.AgreedByAgent(caseObj.id);
        }Catch(Exception e){}
        Test.stopTest();
    }
    
     @isTest
    public static void updateClaimBreakdown(){
		Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.External_ID__c ='2345';
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Agent';
        casePart.Account__c = acc.id;
        insert casePart;
        
        List<Dispute_Item__c> dispList = new List<Dispute_Item__c>();
        Dispute_Item__c desp = new Dispute_Item__c();
        desp.Adjustment_Percentage_by_AGLL__c = 68;
        desp.Dispute__c = caseObj.id;
        desp.Type__c = 'Cleaning';
        insert desp;
        dispList.add(desp); 
        
        String jsonstring1 = String.Valueof(Json.serialize(dispList));
      
        Test.startTest();
        EI_Tenantevidencegatheringclass.updateClaimBreakdown(jsonstring1);
        Test.stopTest();
    }
    
    @isTest
    public static void updateAdditionalComments(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.Additional_comments_AGLL__c = 'I am agll';
        caseObj.Consent_box_AGLL__c ='Yes';
        caseObj.Claim_Agreed_By__c = 'Agent/Landlord';
        caseObj.Consent_box_TT__c ='Yes';
        caseObj.Additional_comments_TT__c = 'tenant comment';
        insert caseObj ;
       
        Test.startTest();
        EI_Tenantevidencegatheringclass.updateAdditionalComments(caseObj.id,'I am agll','Yes');
        EI_Tenantevidencegatheringclass.updateClaimTT(caseObj.id,true);
        EI_Tenantevidencegatheringclass.updateAdditionalCommentsTT(caseObj.id,'tenant comment');
        Test.stopTest();
    }
    
    @isTest
    public static void updateClaimItemTT(){
		Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_evidence_gathering__c = true;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Agent';
        casePart.Account__c = acc.id;
        insert casePart;
        
        List<Dispute_Item__c> dispList = new List<Dispute_Item__c>();
        Dispute_Item__c desp = new Dispute_Item__c();
        desp.Adjustment_Percentage_by_AGLL__c = 68;
        desp.Dispute__c = caseObj.id;
        desp.Type__c = 'Cleaning';
        insert desp;
        dispList.add(desp); 
        
        String jsonstring1 = String.Valueof(Json.serialize(dispList));
       
        Test.startTest();
        EI_Tenantevidencegatheringclass.updateClaimItemTT(jsonstring1,caseObj.id, true);
        EI_Tenantevidencegatheringclass.updateClaimItemTT(jsonstring1,caseObj.id, false);
        Test.stopTest();
    }
    
    @isTest
    public static void proceedWithNoConsent(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_evidence_gathering__c = true;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Tenant';
        casePart.Account__c = acc.id;
        casePart.Is_Lead__c = true;
        insert casePart;
      
        Test.startTest();
        EI_Tenantevidencegatheringclass.proceedWithNoConsent(caseObj.id);
        Test.stopTest();
    }
    
    @isTest
    public static void proceedWithNoConsentIsNotTenant(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_evidence_gathering__c = true;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Agent';
        casePart.Account__c = acc.id;
        casePart.Is_Lead__c = false;
        insert casePart;
      
        Test.startTest();
        EI_Tenantevidencegatheringclass.proceedWithNoConsent(caseObj.id);
        Test.stopTest();
    }
    
    @isTest
    public static void proceedWithNoConsentIsLeadFalse(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_evidence_gathering__c = true;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Tenant';
        casePart.Account__c = acc.id;
        casePart.Is_Lead__c = false;
        insert casePart;
      
        Test.startTest();
        EI_Tenantevidencegatheringclass.proceedWithNoConsent(caseObj.id);
        Test.stopTest();
    }
    
    @isTest
    public static void checkLeadTenant(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_evidence_gathering__c = true;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Tenant';
        casePart.Account__c = acc.id;
        casePart.Is_Lead__c = false;
        insert casePart;
        
        Test.startTest();
        boolean value = EI_Tenantevidencegatheringclass.checkLeadTenant(caseObj.id);
        System.assertEquals(value, true);
        Test.stopTest();
    }
    
    @isTest
    public static void checkLeadTenantLeadTrue(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.LastName = 'potter';
        acc.PersonEmail ='myEmail@gmail.com';
        insert acc;
        
        Contact con = new Contact();
        con.LastName='potter';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_evidence_gathering__c = true;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Tenant';
        casePart.Account__c = acc.id;
        casePart.Is_Lead__c = true;
        insert casePart;
        
        Test.startTest();
        boolean value = EI_Tenantevidencegatheringclass.checkLeadTenant(caseObj.id);
        System.assertEquals(value, false);
        Test.stopTest();
    }
    
    @isTest
    public static void calculateWorkingDaysBetweenTwoDates(){
        Holiday holiday = new Holiday();
        holiday.Description = 'my holiday';
        holiday.EndTimeInMinutes = 6;
        holiday.Name ='potter';
        holiday.StartTimeInMinutes = 4;
        holiday.ActivityDate = Date.newInstance(2021, 11,1);
        insert holiday;
        
        Date value = EI_Tenantevidencegatheringclass.calculateWorkingDaysBetweenTwoDates(Date.newInstance(2021,10,21),3);
    }
    
    @isTest
    public static void getJSONBODYforTT_SR(){
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
        Contact con = new Contact();
        con.FirstName='harruy';
        con.LastName='potter';
        con.Email = 'test@t.com';
        insert con;
        
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        insert querylimit;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Customer__c = acc.id;
        insert deposit;
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        //caseObj.Status= 'Evidence gathering TT';
        caseObj.AccountId = acc.id;
        caseObj.TT_respond_evidence_gathering__c = true;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Tenant';
        casePart.Account__c = acc.id;
        casePart.Is_Lead__c = false;
        casePart.Contact__c = con.id;

        insert casePart;
      
        Test.startTest();
        try{
        String message = EI_Tenantevidencegatheringclass.getJSONBODYforTT_SR(casePart,'test@t.com');
        }Catch(Exception e){}
        Test.stopTest();
        
   
    }
}