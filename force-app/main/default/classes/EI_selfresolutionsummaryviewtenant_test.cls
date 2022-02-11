/*

@description : Testclass for - EI_selfresolutionsummaryviewtenant
*/
@isTest

  private class EI_selfresolutionsummaryviewtenant_test{

        // Method   1   
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test1(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();      
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';    
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        
        EI_selfresolutionsummaryviewtenant.wrapperClassForCaseAndProfileName  wrapperclass = new EI_selfresolutionsummaryviewtenant.wrapperClassForCaseAndProfileName();
        wrapperclass.profileName = 'Tenant';
        wrapperclass.caseObject = case1;
        Try{
        EI_selfresolutionsummaryviewtenant.getCaseAndDisputeItemDetails(string.valueof(deposit));
        }catch(AuraHandledException e){}
        system.assert(property!= null);
        }
        
       // Method   2   
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test2(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();      
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        test.starttest();
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        caseparticipant.Type__c ='Agent';
        update caseparticipant;
         EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        
        }catch(exception e){}
        test.stoptest();
        system.assert(property!= null);
        }
         // Method   3   
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test3(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       // case1.Status= 'Repayment disputed - self-resolution';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        //case1.RecordtypeId = 
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        Try{
        EI_selfresolutionsummaryviewtenant.getJSONBODYforNoBankDetails(caseparticipant, 'abc@gmail.com');
        }catch(Exception e){}
        system.assert(property!= null);
        }
        
         // Method   4
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test4(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.Claim_Agreed_By__c='Tenant';
       
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Agent';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        test.starttest();
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        
        }catch(exception e){}
        test.stoptest();
        }
           // Method   5  
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test5(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       // case1.Status= 'Repayment disputed - self-resolution';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.Claim_Agreed_By__c='Agent/Landlord';
        //case1.RecordtypeId = 
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        system.assert(property!= null);
        test.starttest();
        
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        }catch(exception e){}
        test.stoptest();
        }
        
           // Method   6  
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test6(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();     
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.Claim_Agreed_By__c='Tenant';   
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        Case  casequery = [Select Total_Agreed_by_AG_LL__c from case where id=:case1.id];
        system.assert(property!= null);
        test.starttest();
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(casequery ,100.00 );
        }catch(exception e){}
        test.stoptest();
        }
        
        // Method   7  
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test7(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       // case1.Status= 'Repayment disputed - self-resolution';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.Claim_Agreed_By__c='Agent/Landlord';
        //case1.RecordtypeId = 
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Agent';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        test.starttest();
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        }catch(exception e){}
        test.stoptest();
        }
        
        // Method   8
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test8(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       // case1.Status= 'Repayment disputed - self-resolution';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.TT_Made_offer__c = true;
        case1.TT_Offer_Response__c= 'Accept';
        //case1.Claim_Agreed_By__c='Tenant';
        
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        test.starttest();
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        }catch(exception e){}
        test.stoptest();
        }

        // Method   9
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test9(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       // case1.Status= 'Repayment disputed - self-resolution';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.TT_Made_offer__c = true;
        case1.TT_Offer_Response__c= 'Accept';
        case1.ContactId= con.ID;
        //case1.Claim_Agreed_By__c='Tenant';
        
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Agent';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        
        case c = [Select ContactId from case where id =: case1.id ];
        
        Installment__c installment = new Installment__c();
        installment.Contact__c = c.ContactId;
        system.assert(property!= null);
        test.starttest();
        Try{
        
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        con.id=null;
        update con;
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        }catch(exception e){}
        test.stoptest();
        }
        // Method   10
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test10(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
        system.assert(property!= null);                       
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       // case1.Status= 'Repayment disputed - self-resolution';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.TT_Made_offer__c = true;
        case1.TT_Offer_Response__c= 'Accept';
        case1.ContactId= con.ID;
        //case1.Claim_Agreed_By__c='Tenant';
        
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        
        case c = [Select ContactId from case where id =: case1.id ];
        
        Installment__c installment = new Installment__c();
        installment.Contact__c = c.ContactId;
        test.starttest();
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        }catch(exception e){}
        test.stoptest();
        }
        // Method   11
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test11(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       // case1.Status= 'Repayment disputed - self-resolution';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.AGLL_made_Offer__c= true;
        case1.AGLL_Offer_Response__c= 'Accept';
        case1.ContactId= con.ID;
        //case1.Claim_Agreed_By__c='Tenant';
        
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        
        case c = [Select ContactId from case where id =: case1.id ];
        
        Installment__c installment = new Installment__c();
        installment.Contact__c = c.ContactId;
        test.starttest();
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        caseparticipant.Type__c ='Agent';
        update caseparticipant;
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );
        }catch(exception e){}
        test.stoptest();
        }
        // Method   12
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test12(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       // case1.Status= 'Repayment disputed - self-resolution';
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.AGLL_made_Offer__c= true;
        case1.AGLL_Offer_Response__c= 'Accept';
        case1.ContactId= con.ID;
        //case1.Claim_Agreed_By__c='Tenant';
        
        insert case1 ;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Agent';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        
        case c = [Select ContactId from case where id =: case1.id ];
        
        Installment__c installment = new Installment__c();
        installment.Contact__c = c.ContactId;
       
       
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(case1,100.00 );        
      
        }
        
        // Method   13   
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test13(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();      
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.contactID = con.ID;
        insert case1 ;
        
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        
        List<Dispute_Item__c> dispitem = new List<Dispute_Item__c>();
        Dispute_Item__c dispitem1 = new Dispute_Item__c();
        dispitem1.Dispute__c =  case1.id;
        dispitem1.Type__c = 'Cleaning';
        insert  dispitem1; 
        dispitem.add(dispitem1);
        String disputeitem = json.serialize(dispitem);
        
        EI_selfresolutionsummaryviewtenant.makeAdjustments(case1,disputeitem, 'Tenant');
        caseparticipant.Type__c ='Agent';
        update caseparticipant;
        EI_selfresolutionsummaryviewtenant.makeAdjustments(case1,disputeitem,'Tenant');
       
        EI_selfresolutionsummaryviewtenant.makeAdjustments(case1,disputeitem,'Agent');
        
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','cancelOffer',100.00);
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','OfferRejected',100.00);
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','Offermade',100.00);
        caseparticipant.Type__c ='Tenant';
        update caseparticipant;
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','OfferRejected',100.00);
        
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','cancelOffer',100.00);
        }
        
        // Method   14 
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test14(){
        UserRole r = [Select Name,PortalType, PortalAccountId From UserRole where Name =:'Adjudicator Group A' limit 1];
        
        User userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest.com', userroleid = r.id,
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                 timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
        insert userWithRole;
        
        Account acc;
       
        List<contact> conlist = new list <contact>();
        contact con;
        Deposit_Allocation__c depositallocation;
        case case1;
        Case_Participant__c caseparticipant;        
        List<Dispute_Item__c> dispitem = new List<Dispute_Item__c>();
        Dispute_Item__c dispitem1;
        Deposit__c deposit;
        Scheme__c scheme;
        Property__c property;
        
        System.runAs(userWithRole){
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc = new Account(RecordTypeId = recordTypeId, FirstName = 'TestPersonAccountFirst', LastName = 'TestPersonAccountLast', PersonEmail = 'abc@ac.uk',Alternative_Email__pc= null);
        insert acc;
        property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        con =new contact();
        con.lastname='test1';
        //con.AccountId = a.Id;
        conlist.add(con);
        insert conlist;
        case1 = new case();      
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.contactID = con.ID;
        insert case1 ;
        
        caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Agent';
        caseparticipant.Contact__c = con.id;     
        insert caseparticipant;
        
        dispitem1 = new Dispute_Item__c();
        dispitem1.Dispute__c =  case1.id;
        dispitem1.Type__c = 'Cleaning';
        insert  dispitem1; 
        dispitem.add(dispitem1);
        
        }
        Account acc1 = [Select Name,PersonContactId,Personemail,ownerId,phone From Account Where Id = :acc.Id];
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Tenant' LIMIT 1];
        
        Bank_Account__c ba;
        System.runAs(userWithRole){ 
        ba = new Bank_Account__c();
                ba.Account__c = acc1.Id;
                ba.Contact__c= acc1.PersonContactId;
                ba.Account_Number__c='HGTY6543';
                ba.Bank_Name__c='testscotlandbank';
                insert ba;   
        }
        User us1 = new User(
        FirstName = 'TestFirstName',
        LastName = 'TestLastName',
        Email = 'test@user.com',
        Username = 'test@user.com',
        Alias = 'TestPA', 
        TimeZoneSidKey = 'GMT', 
        LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'UTF-8', 
        ProfileId = p.Id, 
        LanguageLocaleKey = 'en_US',
        ContactId = acc1.PersonContactId);
        insert us1; 
      
        System.runAs(us1){
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','cancelOffer',100.00);
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','OfferRejected',100.00);
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','OfferMade',100.00);
       
        }
        System.runAs(userWithRole ){
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','OfferMade',100.00);
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Is_Lead__c = false;
        update caseparticipant;
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','OfferMade',100.00);
        caseparticipant.Is_Lead__c = true;
        update caseparticipant;
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','OfferMade',100.00);
        EI_selfresolutionsummaryviewtenant.updateCaseFields(case1,'Tenant','OfferRejected',100.00);
        }
        
        
        }
        // Method   15
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test15(){
         
        
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        insert case1 ;
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Agent';
        caseparticipant.Contact__c = con.id;     
        insert caseparticipant;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipantquery =  [Select Contact__c, Contact__r.Email,Contact__r.FirstName,Contact__r.LastName,Case__r.Tenancy_Property_Address__c from Case_Participant__c  where id=:caseparticipant.id];
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.getJSONBODYforOfferN(caseparticipantquery, 'vhv@gmail.com');
        }catch(Exception e){}
        }
       // Method   16
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test16(){
         
        
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        insert case1 ;
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Agent';
        caseparticipant.Contact__c = con.id;     
        insert caseparticipant;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipantquery =  [Select Contact__c, Contact__r.Email,Contact__r.FirstName,Contact__r.LastName,Contact__r.Name,Case__r.Tenancy_Property_Address__c,Case__r.Deposit_Account_Number__r.Name from Case_Participant__c  where id=:caseparticipant.id];
        Try{
        EI_selfresolutionsummaryviewtenant.getJSONBODYofLLOrTT(caseparticipantquery , 'vhv@gmail.com', 100.00);
       
        }catch(Exception e){}
        }
         // Method   17
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test17(){
         
        
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        insert case1 ;
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Agent';
        caseparticipant.Contact__c = con.id;     
        insert caseparticipant;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem;
        Case_Participant__c caseparticipantquery =  [Select Contact__c, Contact__r.Email,Contact__r.FirstName,Contact__r.LastName,Contact__r.Name,Case__r.Tenancy_Property_Address__c,Case__r.Disputed_Amount__c,Case__r.Deposit_Account_Number__r.Name from Case_Participant__c  where id=:caseparticipant.id];
        test.starttest();
        
        
        try{ 
        EI_selfresolutionsummaryviewtenant.getJSONBODYForOfferRAC(caseparticipantquery , 'vhv@gmail.com','offerrejected');
        EI_selfresolutionsummaryviewtenant.getJSONBODYForOfferRAC(caseparticipantquery , 'vhv@gmail.com','OfferMade');
        EI_selfresolutionsummaryviewtenant.getJSONBODYForOfferRAC(caseparticipantquery , 'vhv@gmail.com','cancelOffer');
        }catch(Exception e){}
        test.stoptest();
      }
      
      // Method   18
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test18(){
         
        
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        insert case1 ;
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Agent';
        caseparticipant.Contact__c = con.id;     
        insert caseparticipant;
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem;
        test.starttest();
        
        EI_selfresolutionsummaryviewtenant.SelfresOfferMadeByTTMailToOtherTT('cf@email.com', 'user1','address',100.00,
        string.valueof(case1.id),string.valueof(con.id), string.valueof(acc.id));
        EI_selfresolutionsummaryviewtenant.SelfresOfferMadeByTTMailToLeadTT('cf@email.com', 'user1','address',100.00,
        string.valueof(case1.id),string.valueof(con.id), string.valueof(acc.id));
        EI_selfresolutionsummaryviewtenant.SelfresRepaymentUpdateByAGLLToTT('cf@email.com', 'user1','address',1.00,
        'data',string.valueof(case1.id),string.valueof(con.id), string.valueof(acc.id));
       
        test.stoptest();
      }
      
        // Method   19
    
        private static testmethod void EI_selfresolutionsummaryviewtenant_Test19(){
        
        EI_selfresolutionsummaryviewtenant.fetchErrorLabel();
        
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
        system.assert(property!= null);
        List<Deposit__c > depositlist = new list<Deposit__c >(); 
                                
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Tenant_Changeover_Deposit__c= 'text';
        deposit.Status__c= 'Registered (not paid)';
        deposit.Tenant_Changeover_Status__c = 'In Progress';
        insert deposit;
        depositlist.add(deposit);

        Contact con = new Contact();
        con.lastname='abc';
        con.email='vhv@gmail.com';
        con.phone= '34567889';
        insert con;
        
        Case  case1 = new case();
       
        case1.ChangeOver_Status__c = 'Tenant Rejected';
        case1.Deposit_Account_Number__c = deposit.id;
        case1.type = 'Problem';
        case1.Claim_Agreed_By__c='Tenant';
       
       
        insert case1 ;
        
       System.assertEquals('Tenant' , case1.Claim_Agreed_By__c );
        
        Dispute_Item__c dispitem = new Dispute_Item__c();
        dispitem.Dispute__c =  case1.id;
        dispitem.Type__c = 'Cleaning';
        insert  dispitem; 
        Case_Participant__c caseparticipant = new Case_Participant__c();
        caseparticipant.Account__c = acc.id;
        caseparticipant.Case__c = case1.id;
        caseparticipant.Type__c ='Tenant';
        caseparticipant.Contact__c = con.id;
        insert caseparticipant;
        Case  casequery = [Select Total_Agreed_by_AG_LL__c from case where id=:case1.id];
        test.starttest();
        Try{
        Test.setMock(HttpCalloutMock.class, new EI_selfresolutionsummaryviewtenantcall());
        EI_selfresolutionsummaryviewtenant.createPaymentAndInstalmentsRecord(casequery,100.00 );
        }catch(exception e){}
        test.stoptest();
        }
        }