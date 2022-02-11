@isTest
public class EI_AGLLevidencegatheringTest {
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
        caseObj.Status= 'Evidence gathering AA/LL';
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
        eviAttach.Evidence_Categories__c =' Tenant obligations';
        insert eviAttach;
        
        Test.startTest();
        list<case> listCase = EI_AGLLevidencegathering.getclaimdetailsforevidence(deposit.id);
        System.assert(listCase != null);
        System.assert(listCase.size() > 0);
        System.assert(!listCase.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void getclaimdetailsforevidenceForCancel(){
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
        eviAttach.Evidence_Categories__c =' Tenant obligations';
        insert eviAttach;
        
        Test.startTest();
        list<case> listCase = EI_AGLLevidencegathering.getclaimdetailsforevidenceForCancel(deposit.id);
        System.assert(listCase != null);
        Test.stopTest();
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
        insert caseObj ;
       
        Test.startTest();
        EI_AGLLevidencegathering.updatekeyDocuments(caseObj.id,'wed4',' Yes','trr','55','wer','cddeqd');
        Test.stopTest();
    }
    
    @isTest
    public static void updateClaimAGLL(){
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
        insert caseObj ;
     
        Test.startTest();
        EI_AGLLevidencegathering.updateClaimAGLL(caseObj.id,true);
        Test.stopTest();
    }
    
    @isTest
    public static void updateAdditionalComments(){
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
        caseObj.Status= 'Evidence gathering AA/LL';
        caseObj.AccountId = acc.id;
        caseObj.Additional_comments_AGLL__c ='comments';
        caseObj.Consent_box_AGLL__c ='Yes';
        insert caseObj ;
             
        Test.startTest();
        EI_AGLLevidencegathering.updateAdditionalComments(caseObj.id,'commets','Yes');
        Test.stopTest();
    }
    
    @isTest
    public static void cancelclaim(){
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
        caseObj.Status= 'Deposit to be repaid - resolved without adjudication';
        caseObj.AccountId = acc.id;
        caseObj.Consent_box_AGLL__c='Yes';
        caseObj.AGLL_Respond_Evidance_Gathering__c = true;
        caseObj.Claim_Agreed_By__c ='Agent/Landlord';
        caseObj.Bypass_validation__c = true;
        insert caseObj ;
     
        Test.startTest();
        String message =  EI_AGLLevidencegathering.cancelclaim(caseObj.id,500);
        System.assertEquals(message, 'success');
        Test.stopTest();
    }
    
    @isTest
    public static void calculateWorkingDaysBetweenTwoDates(){
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
        caseObj.Status= 'Evidence gathering AA/LL';
        caseObj.AccountId = acc.id;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Agent';
        casePart.Account__c = acc.id;
        insert casePart;
        
        Test.startTest();
        String message =  EI_AGLLevidencegathering.cancelclaim(caseObj.id,500);
        System.assertEquals(message, 'success');
        Test.stopTest();
    }
    
    @isTest
    public static void getAgentLandlordEmailDetailsUser(){
        UserRole userRole = EI_TestDataFactory.getUserRoleWithName('Adjudicator Group A');
        insert userRole;
        
        User userWithRole = EI_TestDataFactory.getUserWithRole(userRole);
        Account personAccount = EI_TestDataFactory.getPersonAccount(userWithRole);
        System.runAs(userWithRole) { 
            insert personAccount;
        }
       
        // Create TestUser from here
        Account userAcccount = new Account();
        userAcccount = [Select PersonContactId From Account Where Id = :personAccount.Id];
        System.debug(':::UserAccount='+userAcccount);
        Profile agentProfile = [SELECT Id FROM Profile WHERE Name = 'Tenant' LIMIT 1];
        User testUser =  EI_TestDataFactory.getTestUser(agentProfile, userAcccount);
        insert testUser;
        
        QueryLimits__c querylimit = EI_TestDataFactory.createQueryLimit();
        System.runAs(userWithRole) {
           insert querylimit;
        }
        
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        System.runAs(userWithRole) {
            insert scheme;
        }
        deposit__c deposit = new deposit__c();
        //deposit.Property__c = property.id;
        deposit.Customer__c = userAcccount.Id;
        deposit.Status__c = 'Repayment process';
        deposit.Deposit_Transferred__c = true;
        deposit.Deposit_Amount__c = 800;
        deposit.Agreed_amount__c=400;
        deposit.Scheme__c = scheme.id;     
        System.runAs(userWithRole) {
            insert deposit;
        }
        
        Case caseObj = new Case();
        caseObj.Deposit_Account_Number__c = deposit.id;
        caseObj.Status= 'Evidence gathering AA/LL';
        caseObj.AccountId = userAcccount.id;
        
         System.runAs(userWithRole) {
            insert caseObj;
        }
      
        Contact testContact = new Contact();
        testContact =[select LastName,FirstName,id from Contact where id=:userAcccount.PersonContactId];  
        
        System.runAs(testUser){
        Test.StartTest();
       // Test.setMock(HttpCalloutMock.class, new TransferDepositCallout());
        String message =  EI_AGLLevidencegathering.cancelclaim(caseObj.id,500);
        System.assertEquals(message, 'success');
        Test.stopTest();
       
        }    
    }
    
    @isTest
    public static void method(){
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
        caseObj.Status= 'Evidence gathering AA/LL';
        caseObj.AccountId = acc.id;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Tenant';
        casePart.Account__c = acc.id;
        casePart.Split_percent__c =30;
        insert casePart;
        
        Installment__c install = new Installment__c();
        install.Deposit__c = deposit.id;
        install.Status__c = 'Pending processing';
        install.Case__c = caseObj.id;
        insert install;
        
        Test.startTest();
        String message =  EI_AGLLevidencegathering.cancelclaim(caseObj.id,500);
        System.assertEquals(message, 'success');
        Test.stopTest();

    }
    
    @isTest
    public static void methodForElse(){
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
        caseObj.Status= 'Evidence gathering AA/LL';
        caseObj.AccountId = acc.id;
        insert caseObj ;
        
        Case_Participant__c casePart =  new Case_Participant__c();
        casePart.Case__c =  caseObj.id;
        casePart.Type__c = 'Agent';
        casePart.Account__c = acc.id;
        insert casePart;
        
        Installment__c install = new Installment__c();
        install.Deposit__c = deposit.id;
        install.Status__c = 'Pending processing';
        install.Case__c = caseObj.id;
        insert install;
        
        Test.startTest();
        String message =  EI_AGLLevidencegathering.cancelclaim(caseObj.id,500);
        System.assertEquals(message, 'success');
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
        // String jsonstring1 = '['+String.Valueof(Json.serialize(dispList))+']';
        Test.startTest();
        
        EI_AGLLevidencegathering.updateClaimBreakdown(jsonstring1);
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
        //caseObj.Deposit_Account_Number__c = deposit.id;
       // caseObj.Status= 'Case cancelled';
       // caseObj.Close_Reason__c ='xu';
       // caseObj.AccountId = acc.id;
       // caseObj.Claim_Agreed_By__c= 'Agent/Landlord';
       // caseObj.External_ID__c ='3456';
        insert caseObj ;
        
        Test.startTest();
        Try{
        EI_AGLLevidencegathering.UpdateClaimDetails(caseObj.id,'AGLL',500,'SDS','3456');
        }catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    public static void UpdateClaimDetailsForElse(){
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
       // caseObj.Status= '';
       // caseObj.Close_Reason__c ='';
        caseObj.AccountId = acc.id;
       // caseObj.Claim_Agreed_By__c= 'Tenant';
       // caseObj.Make_Payment_By_Community__c = true;
        // caseObj.External_ID__c ='3456';
        caseObj.status='New';
        caseObj.Claim_Agreed_By__c='Tenant';
        //caseObj.Close_Reason__c='Rejected';
        caseObj.Make_Payment_By_Community__c = true;
        insert caseObj ;
        
        Test.startTest();
        Try{
        EI_AGLLevidencegathering.UpdateClaimDetails(caseObj.id,'Tenant',500,'SDS','3456');
        } catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest   
    public static void fetchErrorLabel(){
         EI_AGLLevidencegathering.fetchErrorLabel();
    }
    
    @isTest
    public static void getInstallments(){
        
    }
}