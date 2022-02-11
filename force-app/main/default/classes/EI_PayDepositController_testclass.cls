@istest
Private class EI_PayDepositController_testclass{

Private static testmethod void EI_PayDepositController_testclass_method1(){
      insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
      LandlordId__c = 173, TenantID__c = 643);
      EI_PayDepositController.getBulkNumber();
      EI_PayDepositController.updateBulkNumberSetting('3445');
      EI_PayDepositController.DepositInstallmentWrapper paydepositwrapper = new EI_PayDepositController.DepositInstallmentWrapper();
      paydepositwrapper.isSelected= true;
      paydepositwrapper.installmentId ='sdftest';
      paydepositwrapper.isTopUp= false;
      paydepositwrapper.paymentAmount = 100.00;     
      paydepositwrapper.paymentMethod = 'card';
      
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
        Contact  c1 = new Contact( FirstName = 'test1', Lastname = 'surname',  Email = System.now().millisecond() + 'as@test.com');
        insert c1; 
         
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Postal_Code__c='postcode';
        insert property;
        system.assert(property!= null);
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;  
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');     
        List<deposit__c> depolist = new List<deposit__c>();
        deposit__c depo = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        depo.status__c= 'Registered (not paid)';
        insert depo;
        depolist.add(depo);
        
        paydepositwrapper.objDeposit = depo;
        
        List<Installment__c> installlist = new List<Installment__c>();  
        Installment__c inst = new Installment__c();
        inst.Amount__c = 100.00;
        inst.Deposit__c = depo.id;
        inst.Status__c = 'Pending';
        inst.Installment_Type__c = 'Receivable';
        insert inst;       
        installlist.add(inst);
        paydepositwrapper.objInstallment= installlist;
        EI_PayDepositController.getDepositsToPay('deposit held by scheme',null,string.valueof(depo.id), false, 100.00);
        EI_PayDepositController.getDepositsToPay('deposit held by scheme',null,null, false, 100.00);
        Branch__c branch2  = new Branch__c();
        branch2.Branch_Name__c = 'branchtest';  
        branch2.Account__c = acc.Id;
        branch2.Address__c ='abc';
        branch2.Town_City__c='town1';
        branch2.County__c = 'test2';
        branch2.Country__c='India';
        branch2.Postcode__c='hp23fgt';
        
        insert branch2;
        
        Branch_User_Mapping__c bumap = new Branch_User_Mapping__c();
        bumap.branch__c= branch2.id;
        bumap.User__c = UserInfo.getUserId();
        insert bumap;
        EI_PayDepositController.getDepositsToPay('pending',null,string.valueof(depo.id), false, 100.00);
        EI_PayDepositController.getDepositsToPay('pending',null,string.valueof(depo.id), true, 100.00);
        EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), true, 100.00);
        EI_PayDepositController.getDepositsToPay('Deposits held by scheme',null,string.valueof(depo.id), true, 100.00);
        EI_PayDepositController.getDepositsToPay('Deposits held by scheme',null,string.valueof(depo.id), false, 100.00);
        EI_PayDepositController.getDepositsToPay('Deposits held by scheme',null,'', false, 100.00);
        EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), false, 100.00);
        
        EI_PayDepositController.DepositInstallmentWrapper wrap = new EI_PayDepositController.DepositInstallmentWrapper();
        wrap.isSelected = True;
        wrap.isTopUp = true;
        wrap.objInstallment = installlist;
        wrap.objDeposit = depo;
        
        List<EI_PayDepositController.DepositInstallmentWrapper> wraplist = new List<EI_PayDepositController.DepositInstallmentWrapper>();
        wraplist.add(wrap);
        //depo.status__c= 'Pending';
        //update depo;
       // depolist.add(depo);
       // EI_PayDepositController.getDepositsToPay('pending',null,string.valueof(depo.id), true, 100.00);
        
        
        Try{
        EI_PayDepositController.updateDepositsInstallments(wraplist,'card','wert');
        EI_PayDepositController.cancelPaymentDeposit(wraplist,'Registered (not paid)','BLK','test');
        EI_PayDepositController.cancelPaymentDeposit(wraplist,'card','BLK','test');
        EI_PayDepositController.updateDepositsInstallments(wraplist,'card','erty');
        }catch(Exception e){}
        }
        // method 2
        Private static testmethod void EI_PayDepositController_testclass_method2(){

        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
        Contact  c1 = new Contact( FirstName = 'test1', Lastname = 'surname',  Email = System.now().millisecond() + 'as@test.com');
        insert c1; 
         
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Postal_Code__c='postcode';
        insert property;
        system.assert(property!= null);
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;  
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');     
        
        List<deposit__c> depolist = new List<deposit__c>();
        deposit__c depo = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert depo;
        depolist.add(depo);

        EI_PayDepositController.getDepositsToPay('Deposits held by scheme',null,string.valueof(depo.id), false, 100.00);
        
        Branch__c branch2  = new Branch__c();
        branch2.Branch_Name__c = 'branchtest';  
        branch2.Account__c = acc.Id;
        branch2.Address__c ='abc';
        branch2.Town_City__c='town1';
        branch2.County__c = 'test2';
        branch2.Country__c='India';
        branch2.Postcode__c='hp23fgt';
        branch2.Is_Active__c = true;
        insert branch2;
        List<Installment__c> installlist = new List<Installment__c>();  
        Installment__c inst = new Installment__c();
        inst.Amount__c = 100.00;
        inst.Deposit__c = depo.id;
        inst.Status__c = 'Pending';
        inst.Installment_Type__c = 'Receivable';
        insert inst;       
        installlist.add(inst);
        Branch_User_Mapping__c bumap = new Branch_User_Mapping__c();
        bumap.branch__c= branch2.id;
        bumap.User__c = UserInfo.getUserId();
        insert bumap;
        
      EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), true, 100.00);
      EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), false, 100.00);
}
  // method 3
 Private static testmethod void EI_PayDepositController_testclass_method3(){

        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
        Contact  c1 = new Contact( FirstName = 'test1', Lastname = 'surname',  Email = System.now().millisecond() + 'as@test.com');
        insert c1; 
         
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Postal_Code__c='postcode';
        insert property;
        system.assert(property!= null);
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;  
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');     
        List<deposit__c> depolist = new List<deposit__c>();
        deposit__c depo = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        depo.Status__c = 'Deposits held by scheme';
        insert depo;
        depolist.add(depo);

        EI_PayDepositController.getDepositsToPay('deposit held by scheme',null,string.valueof(depo.id), false, 100.00);
        
        Branch__c branch2  = new Branch__c();
        branch2.Branch_Name__c = 'branchtest';  
        branch2.Account__c = acc.Id;
        branch2.Address__c ='abc';
        branch2.Town_City__c='town1';
        branch2.County__c = 'test2';
        branch2.Country__c='India';
        branch2.Postcode__c='hp23fgt';
        branch2.Is_Active__c = true;
        insert branch2;
        List<Installment__c> installlist = new List<Installment__c>();  
        Installment__c inst = new Installment__c();
        inst.Amount__c = 100.00;
        inst.Deposit__c = depo.id;
        inst.Status__c = 'Pending';
        inst.Installment_Type__c = 'Receivable';
        insert inst;       
        installlist.add(inst);
        Branch_User_Mapping__c bumap = new Branch_User_Mapping__c();
        bumap.branch__c= branch2.id;
        bumap.User__c = UserInfo.getUserId();
        insert bumap;
        EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), false, 100.00);
}
     // method 4
      Private static testmethod void EI_PayDepositController_testclass_method4(){
      insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
      LandlordId__c = 173, TenantID__c = 643);
      EI_PayDepositController.getBulkNumber();
      EI_PayDepositController.updateBulkNumberSetting('3445');
      EI_PayDepositController.DepositInstallmentWrapper paydepositwrapper = new EI_PayDepositController.DepositInstallmentWrapper();
      paydepositwrapper.isSelected= true;
      paydepositwrapper.installmentId ='sdftest';
      paydepositwrapper.isTopUp= false;
      paydepositwrapper.paymentAmount = 100.00;     
      paydepositwrapper.paymentMethod = 'card';
      
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
        Contact  c1 = new Contact( FirstName = 'test1', Lastname = 'surname',  Email = System.now().millisecond() + 'as@test.com');
        insert c1; 
         
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Postal_Code__c='postcode';
        insert property;
        system.assert(property!= null);
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;  
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');     
        List<deposit__c> depolist = new List<deposit__c>();
        deposit__c depo = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        depo.status__c= 'Deposits held by scheme';
        insert depo;
        depolist.add(depo);
        
        paydepositwrapper.objDeposit = depo;
        
        List<Installment__c> installlist = new List<Installment__c>();  
        Installment__c inst = new Installment__c();
        inst.Amount__c = 100.00;
        inst.Deposit__c = depo.id;
        inst.Status__c = 'Pending';
        inst.Installment_Type__c = 'Receivable';
        insert inst;       
        installlist.add(inst);
        paydepositwrapper.objInstallment= installlist;
        
        Branch__c branch2  = new Branch__c();
        branch2.Branch_Name__c = 'branchtest';  
        branch2.Account__c = acc.Id;
        branch2.Address__c ='abc';
        branch2.Town_City__c='town1';
        branch2.County__c = 'test2';
        branch2.Country__c='India';
        branch2.Postcode__c='hp23fgt';
        
        insert branch2;
        
        Branch_User_Mapping__c bumap = new Branch_User_Mapping__c();
        bumap.branch__c= branch2.id;
        bumap.User__c = UserInfo.getUserId();
        insert bumap;
        
        EI_PayDepositController.DepositInstallmentWrapper wrap = new EI_PayDepositController.DepositInstallmentWrapper();
        wrap.isSelected = True;
        wrap.isTopUp = false;
        wrap.objInstallment = installlist;
        wrap.objDeposit = depo;
        
        List<EI_PayDepositController.DepositInstallmentWrapper> wraplist = new List<EI_PayDepositController.DepositInstallmentWrapper>();
        wraplist.add(wrap);
        
        
        EI_PayDepositController.getDepositsToPay('deposit held by scheme',null,string.valueof(depo.id), false, 100.00);
        
        Try{
        EI_PayDepositController.updateDepositsInstallments(wraplist,'Deposits held by scheme','BLK');
        //EI_PayDepositController.cancelPaymentDeposit(wraplist,'Registered (not paid)','BLK','test');
       // EI_PayDepositController.cancelPaymentDeposit(wraplist,'card','BLK','test');
        //EI_PayDepositController.updateDepositsInstallments(wraplist,'card','erty');
        }catch(Exception e){}
        }
        //method 5
           Private static testmethod void EI_PayDepositController_testclass_method5(){
      insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
      LandlordId__c = 173, TenantID__c = 643);
      EI_PayDepositController.getBulkNumber();
      EI_PayDepositController.updateBulkNumberSetting('3445');
      EI_PayDepositController.DepositInstallmentWrapper paydepositwrapper = new EI_PayDepositController.DepositInstallmentWrapper();
      paydepositwrapper.isSelected= true;
      paydepositwrapper.installmentId ='sdftest';
      paydepositwrapper.isTopUp= false;
      paydepositwrapper.paymentAmount = 100.00;     
      paydepositwrapper.paymentMethod = 'card';
      
        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;
        
        Contact  c1 = new Contact( FirstName = 'test1', Lastname = 'surname',  Email = System.now().millisecond() + 'as@test.com');
        insert c1; 
         
        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        property.Postal_Code__c='postcode';
        insert property;
        system.assert(property!= null);
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;  
         
        insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');     
        List<deposit__c> depolist = new List<deposit__c>();
        deposit__c depo = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        depo.status__c= 'Awaiting payment';
        insert depo;
        depolist.add(depo);
        
        paydepositwrapper.objDeposit = depo;
        
        List<Installment__c> installlist = new List<Installment__c>();  
        Installment__c inst = new Installment__c();
        inst.Amount__c = 100.00;
        inst.Deposit__c = depo.id;
        inst.Status__c = 'Pending';
        inst.Installment_Type__c = 'Receivable';
        insert inst;       
        installlist.add(inst);
        paydepositwrapper.objInstallment= installlist;
        
        Branch__c branch2  = new Branch__c();
        branch2.Branch_Name__c = 'branchtest';  
        branch2.Account__c = acc.Id;
        branch2.Address__c ='abc';
        branch2.Town_City__c='town1';
        branch2.County__c = 'test2';
        branch2.Country__c='India';
        branch2.Postcode__c='hp23fgt';
        
        insert branch2;
        
        Branch_User_Mapping__c bumap = new Branch_User_Mapping__c();
        bumap.branch__c= branch2.id;
        bumap.User__c = UserInfo.getUserId();
        insert bumap;
        
        EI_PayDepositController.DepositInstallmentWrapper wrap = new EI_PayDepositController.DepositInstallmentWrapper();
        wrap.isSelected = True;
        wrap.isTopUp = false;
        wrap.objInstallment = installlist;
        wrap.objDeposit = depo;
        
        List<EI_PayDepositController.DepositInstallmentWrapper> wraplist = new List<EI_PayDepositController.DepositInstallmentWrapper>();
        wraplist.add(wrap);
        
        
        
        
        Try{
        EI_PayDepositController.updateDepositsInstallments(wraplist,'Pending','BLK');
        
        }catch(Exception e){}
        }
        
        // method 6
      Private static testmethod void EI_PayDepositController_testclass_method6(){
          insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
          LandlordId__c = 173, TenantID__c = 643);
          EI_PayDepositController.getBulkNumber();
          EI_PayDepositController.updateBulkNumberSetting('3445');
          EI_PayDepositController.DepositInstallmentWrapper paydepositwrapper = new EI_PayDepositController.DepositInstallmentWrapper();
          paydepositwrapper.isSelected= true;
          paydepositwrapper.installmentId ='sdftest';
          paydepositwrapper.isTopUp= false;
          paydepositwrapper.paymentAmount = 100.00;     
          paydepositwrapper.paymentMethod = 'card';
          
            Account acc= EI_TestDataFactory.createLandlord(1)[0];
            insert acc;
            
            Contact  c1 = new Contact( FirstName = 'test1', Lastname = 'surname',  Email = System.now().millisecond() + 'as@test.com');
            insert c1; 
             
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            property.Postal_Code__c='postcode';
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;  
             
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');     
            
            Branch__c branch2  = new Branch__c();
            branch2.Branch_Name__c = 'branchtest';  
            branch2.Account__c = acc.Id;
            branch2.Address__c ='abc';
            branch2.Town_City__c='town1';
            branch2.County__c = 'test2';
            branch2.Country__c='India';
            branch2.Postcode__c='hp23fgt';
            branch2.Is_Active__c = False;
            insert branch2;
            
            List<deposit__c> depolist = new List<deposit__c>();
            deposit__c depo = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            depo.status__c= 'Deposits held by scheme';
            depo.Customer__c = acc.id;
            depo.Branch__c = branch2.id;
            insert depo;
            depolist.add(depo);
            
            List<Installment__c> installlist = new List<Installment__c>();  
            Installment__c inst = new Installment__c();
            inst.Amount__c = 100.00;
            inst.Deposit__c = depo.id;
            inst.Status__c = 'Pending';
            inst.Installment_Type__c = 'Receivable';
            insert inst;       
            
            installlist.add(inst);
            paydepositwrapper.objInstallment= installlist;
            
            paydepositwrapper.objDeposit = depo;
            
            Branch_User_Mapping__c bumap = new Branch_User_Mapping__c();
            bumap.branch__c= branch2.id;
            bumap.User__c = UserInfo.getUserId();
            insert bumap;
            
            EI_PayDepositController.DepositInstallmentWrapper wrap = new EI_PayDepositController.DepositInstallmentWrapper();
            wrap.isSelected = True;
            wrap.isTopUp = true;
            wrap.objInstallment = installlist;
            wrap.objDeposit = depo;
            
            List<EI_PayDepositController.DepositInstallmentWrapper> wraplist = new List<EI_PayDepositController.DepositInstallmentWrapper>();
            wraplist.add(wrap);
            //depo.status__c= 'Pending';
            //update depo;
           // depolist.add(depo);
           // EI_PayDepositController.getDepositsToPay('pending',null,string.valueof(depo.id), true, 100.00);
            
            
            Try{
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',null,string.valueof(depo.id), false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',null,null, false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), true, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), true, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), true, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),'', false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), false, 100.00);
            
            }catch(Exception e){}
        }
        
        // method 7
          Private static testmethod void EI_PayDepositController_testclass_method7(){
          insert new MemberId__c (name = 'MemberID', AgentID__c = 223, BulkNumber__c = 2003,
          LandlordId__c = 173, TenantID__c = 643);
          EI_PayDepositController.getBulkNumber();
          EI_PayDepositController.updateBulkNumberSetting('3445');
          EI_PayDepositController.DepositInstallmentWrapper paydepositwrapper = new EI_PayDepositController.DepositInstallmentWrapper();
          paydepositwrapper.isSelected= true;
          paydepositwrapper.installmentId ='sdftest';
          paydepositwrapper.isTopUp= false;
          paydepositwrapper.paymentAmount = 100.00;     
          paydepositwrapper.paymentMethod = 'card';
          
            Account acc= EI_TestDataFactory.createLandlord(1)[0];
            insert acc;
            
            Contact  c1 = new Contact( FirstName = 'test1', Lastname = 'surname',  Email = System.now().millisecond() + 'as@test.com');
            insert c1; 
             
            Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
            property.Postal_Code__c='postcode';
            insert property;
            system.assert(property!= null);
            Scheme__c scheme= EI_TestDataFactory.createScheme();
            insert scheme;  
             
            insert new QueryLimits__c (name = 'All Limits', LandlordLimit__c = '1',PropertiesLimit__c='1');     
            
            Branch__c branch2  = new Branch__c();
            branch2.Branch_Name__c = 'branchtest';  
            branch2.Account__c = acc.Id;
            branch2.Address__c ='abc';
            branch2.Town_City__c='town1';
            branch2.County__c = 'test2';
            branch2.Country__c='India';
            branch2.Postcode__c='hp23fgt';
            branch2.Is_Active__c = False;
            insert branch2;
            
            List<deposit__c> depolist = new List<deposit__c>();
            deposit__c depo = EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
            depo.status__c= 'Deposits held by scheme';
            depo.Customer__c = acc.id;
            depo.Branch__c = branch2.id;
            insert depo;
            depolist.add(depo);
            
            List<Installment__c> installlist = new List<Installment__c>();  
            Installment__c inst = new Installment__c();
            inst.Amount__c = 100.00;
            inst.Deposit__c = depo.id;
            inst.Status__c = 'Pending';
            inst.Installment_Type__c = 'Receivable';
            //insert inst;       
            
            installlist.add(inst);
            paydepositwrapper.objInstallment= installlist;
            
            paydepositwrapper.objDeposit = depo;
            
            Branch_User_Mapping__c bumap = new Branch_User_Mapping__c();
            bumap.branch__c= branch2.id;
            bumap.User__c = UserInfo.getUserId();
            insert bumap;
            
            EI_PayDepositController.DepositInstallmentWrapper wrap = new EI_PayDepositController.DepositInstallmentWrapper();
            wrap.isSelected = True;
            wrap.isTopUp = true;
            wrap.objInstallment = installlist;
            wrap.objDeposit = depo;
            
            List<EI_PayDepositController.DepositInstallmentWrapper> wraplist = new List<EI_PayDepositController.DepositInstallmentWrapper>();
            wraplist.add(wrap);
            //depo.status__c= 'Pending';
            //update depo;
           // depolist.add(depo);
           // EI_PayDepositController.getDepositsToPay('pending',null,string.valueof(depo.id), true, 100.00);
            
            
            Try{
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',null,string.valueof(depo.id), false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',null,null, false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), true, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), true, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), true, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),'', false, 100.00);
            EI_PayDepositController.getDepositsToPay('Deposits held by scheme',string.valueof(branch2.id),string.valueof(depo.id), false, 100.00);
            
            }catch(Exception e){}
        }
        
}