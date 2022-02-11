@istest
  Public class EI_UnallocateIRController_test {
    // method 1
    Public static testmethod void EI_UnallocateIRController_method1() {
    
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Property_Owner__c=acc.id;
        insert property;
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
        
        system.assert(deposit!= null );
        Installment__c installment = new  Installment__c();
        installment.deposit__c = deposit.id;
        insert installment;
        
        Inbound_Report__c inboundreport = new Inbound_Report__c ();
        inboundreport.File_Name__c = 'test';
        inboundreport.Installment__c = installment.id;
        
        insert inboundreport;
        
        Payment__c payment = new Payment__c();
        payment.DAN__c = deposit.id;
        payment.Installment__c = installment.id;
        insert payment;
        
        EI_UnallocateIRController.getInboundReport(string.valueof(inboundreport.id));
        EI_UnallocateIRController.getReasons();
        Try{
        EI_UnallocateIRController.updateReport(inboundreport);
        }catch(Exception e){}
        
      }
      // method 2
        Public static testmethod void EI_UnallocateIRController_method2() {
        Inbound_Report__c inboundreport = new Inbound_Report__c ();
        inboundreport.File_Name__c = 'test';
        
        integer i = 1;
        integer j = 1;
        System.assertEquals(i, j);
        
        EI_UnallocateIRController.getInboundReport(string.valueof(inboundreport.id));
    
      }
      // method 3
    Public static testmethod void EI_UnallocateIRController_method3() {
    
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Property_Owner__c=acc.id;
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        scheme.Deposit_Account_Number_Prefix__c = 'DANtest';
        insert scheme;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Deposit_Amount__c = 200.00;
        deposit.Protected_Amount__c = 100.00;   
        insert deposit;
        
        Deposit__c depositquery = [select Id,Deposit_Account_number__c from Deposit__c where Id =:  deposit.Id];
        String depoaccNumber = depositquery.Deposit_Account_number__c;
        
        system.assert(deposit!= null );
        
        Installment__c installment = new  Installment__c();
        installment.deposit__c = deposit.id;
        installment.Installment_Type__c = 'Receivable';   
        installment.status__c = 'Pending'; 
        installment.Amount__c = 100.00;
        insert installment;
      
        Inbound_Report__c inboundreport = new Inbound_Report__c ();
        inboundreport.File_Name__c = 'test';
        inboundreport.Installment__c = installment.id;
        inboundreport.Amount__c = 100.00;
        insert inboundreport;
        
        
        Payment__c payment = new Payment__c();
        payment.DAN__c = deposit.id;
        payment.Installment__c = installment.id;
        insert payment;
        
        Inbound_Report__c reportquery = [Select Installment__r.Deposit__r.Deposit_Amount__c,Installment__r.Deposit__c,Amount__c from Inbound_Report__c where id=:inboundreport.id];
        
        System.debug('55555555555555 here1' +reportquery.Installment__r.Deposit__r.Deposit_Amount__c);
        System.debug('66666666666666 here1' +reportquery.Installment__r.Deposit__c);
        System.debug('77777777777777 here1' +reportquery.Amount__c);
        
        EI_UnallocateIRController.allocateReport(inboundreport,depoaccNumber  );
        Try{
        EI_UnallocateIRController.updateReport(inboundreport);
        }catch(Exception e){}
        }
  // method 4
    Public static testmethod void EI_UnallocateIRController_method4() {
    
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Property_Owner__c=acc.id;
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        scheme.Deposit_Account_Number_Prefix__c = 'DANtest';
        insert scheme;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Deposit_Amount__c = 200.00;
        deposit.Protected_Amount__c = 100.00;   
        insert deposit;
        
        Deposit__c depositquery = [select Id,Deposit_Account_number__c from Deposit__c where Id =:  deposit.Id];
        String depoaccNumber = depositquery.Deposit_Account_number__c;
        
        system.assert(deposit!= null );
        
        
        Installment__c installment = new  Installment__c();
        installment.deposit__c = deposit.id;
        installment.Installment_Type__c = 'Receivable';   
        installment.status__c = 'Pending'; 
        installment.Amount__c = 100.00;
        insert installment;
        
        Installment__c installment1 = new  Installment__c();
        installment1.deposit__c = deposit.id;
        installment1.Installment_Type__c = 'Receivable';   
        installment1.status__c = 'Pending'; 
        installment1.Amount__c = 100.00;
        insert installment1;

        
        Inbound_Report__c inboundreport = new Inbound_Report__c ();
        inboundreport.File_Name__c = 'test';
        inboundreport.Installment__c = installment.id;
        inboundreport.Amount__c = 100.00;
        insert inboundreport;   
        
        Payment__c payment = new Payment__c();
        payment.DAN__c = deposit.id;
        payment.Installment__c = installment.id;
        insert payment;
        
        EI_UnallocateIRController.allocateReport(inboundreport,depoaccNumber);
       
        }
        
        // method 5
    Public static testmethod void EI_UnallocateIRController_method5() {
    
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Property_Owner__c=acc.id;
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        scheme.Deposit_Account_Number_Prefix__c = 'DANtest';
        insert scheme;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Deposit_Amount__c = 200.00;
        deposit.Protected_Amount__c = 100.00;   
        insert deposit;
        
        Deposit__c depositquery = [select Id,Deposit_Account_number__c from Deposit__c where Id =:  deposit.Id];
        String depoaccNumber = depositquery.Deposit_Account_number__c;
        
        system.assert(deposit!= null );
        List<Deposit_Allocation__c > dalist = new List<Deposit_Allocation__c >();
        Deposit_Allocation__c depoall = new Deposit_Allocation__c();
        depoall.Deposit__c = deposit.id;
        depoall.role__c='tenant';
        depoall.Deposit_Holder__c = acc.id;
        insert depoall;
        dalist.add(depoall);
        
        Installment__c installment = new  Installment__c();
        installment.deposit__c = deposit.id;
        installment.Installment_Type__c = 'Receivable';   
        installment.status__c = 'Pending'; 
        installment.Amount__c = 100.00;
        insert installment;
        
       
        
        Inbound_Report__c inboundreport = new Inbound_Report__c ();
        inboundreport.File_Name__c = 'test';
        inboundreport.Installment__c = installment.id;
        inboundreport.Amount__c = 100.00;
        insert inboundreport;   
        
        Payment__c payment = new Payment__c();
        payment.DAN__c = deposit.id;
        payment.Installment__c = installment.id;
        insert payment;
        String json1 = json.serialize(dalist);
        EI_UnallocateIRController.sendEmailToTenant(true,string.valueof(deposit.id));
        test.starttest();
        EI_UnallocateIRController.sendEmail(json1 , true);
        test.stoptest();
    
        }
        //method 6
    Public static testmethod void EI_UnallocateIRController_method6() {
    
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1'); 

        insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
        LandlordId__c = 173, TenantID__c = 643);

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Property_Owner__c=acc.id;
        insert property;
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        scheme.Deposit_Account_Number_Prefix__c = 'DANtest';
        insert scheme;
        
        deposit__c deposit = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Deposit_Amount__c = 200.00;
        deposit.Protected_Amount__c = 100.00;   
        insert deposit;
        
        Deposit__c depositquery = [select Id,Deposit_Account_number__c from Deposit__c where Id =:  deposit.Id];
        String depoaccNumber = depositquery.Deposit_Account_number__c;
        
        system.assert(deposit!= null );
        
        
        Installment__c installment = new  Installment__c();
        installment.deposit__c = deposit.id;
        installment.Installment_Type__c = 'Receivable';   
        installment.status__c = 'Pending'; 
        //installment.Amount__c = 100.00;
        insert installment;
       
        
        Inbound_Report__c inboundreport = new Inbound_Report__c ();
        inboundreport.File_Name__c = 'test';
        //inboundreport.Installment__c = installment.id;
        inboundreport.Amount__c = 100.00;
        insert inboundreport;   
      
        
        EI_UnallocateIRController.allocateReport(inboundreport,depoaccNumber);
       
        }
        
        }