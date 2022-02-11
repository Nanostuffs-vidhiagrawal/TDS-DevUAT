/*
@date  :     10/09/2021
@description : Testclass for - ViewDepositController

*/
@isTest
private class EI_ViewDepositController_TestClass{
        
    // Method   1  
    private static testmethod void EI_ViewDepositController_Test1(){
   
        id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Letting Agent').getRecordTypeId();
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        insert acc;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
                                  
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        insert deposit;
 
        Branch__c branch1  = new Branch__c();
        branch1.Account__c = acc.Id;
        branch1.Branch_Name__c='testabc';
        branch1.Address__c ='abc';
        branch1.Town_City__c='town1';
        branch1.County__c = 'test2';
        branch1.Country__c='India';
        branch1.Postcode__c='hp23fgt';
        
        insert branch1;
        
        QueryLimits__c querylimit = new QueryLimits__c();
        querylimit.CheckOn__c = True;
        querylimit.Name = 'All Limits';
        insert querylimit;

        case c1= EI_TestDataFactory.createDispute( 1,deposit.id)[0];
        c1.status='Tenant changeover initiated - tenant';
        c1.ChangeOver_Status__c='Tenant Initiate';
        c1.ownerId=UserInfo.getUserId();
        insert c1; 

        Test.StartTest();
        
        ViewDepositController.getChangeOverDetails();
        ViewDepositController.getAllTransferredDeposits();
        ViewDepositController.getDeposit(null);                               
        ViewDepositController.getDeposit(branch1.id);
        ViewDepositController.getDepositsByStatus('Deposits held by scheme', branch1.id);  
        ViewDepositController.getDepositsByStatus('Deposits held by scheme', null); 
        ViewDepositController.getDepositRecordsBySearchText('landlord@gmail.com',branch1.id);
        ViewDepositController.getDepositRecordsBySearchText('landlord@gmail.com',null);
        
        Test.StopTest();       
   
   }
   
   
  // Method   2  
    private static testmethod void EI_ViewDepositController_Test2(){
   
        id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Letting Agent').getRecordTypeId();
        
        Scheme__c scheme= EI_TestDataFactory.createScheme();
        insert scheme;

        Account acc= EI_TestDataFactory.createLandlord(1)[0];
        acc.PersonEmail = 'landlord@gmail.com';
        insert acc;

        Property__c property= EI_TestDataFactory.createProperty(1,acc.id)[0];
        insert property;
                                  
        Deposit__c deposit= EI_TestDataFactory.createDeposite(1,scheme.id,acc.id,property.id)[0];
        deposit.Deposit_Transferred_to_Account__c=acc.id;
        deposit.Deposit_Transferred__c=true;
       
        //deposit.Property_Address_Without_Country__c='testfj';
        deposit.Status__c='Awaiting payment';
        //deposit.PersonEmail = 'landlord@gmail.com';
        insert deposit;
        
 
        Branch__c branch1  = new Branch__c();
        branch1.Account__c = acc.Id;
        branch1.Address__c ='abc';
        branch1.Town_City__c='town1';
        branch1.County__c = 'test2';
        branch1.Country__c='India';
        branch1.Postcode__c='hp23fgt';
        branch1.Branch_Name__c='testabc1';
        
        insert branch1;
        
        
        Deposit_Allocation__c depositallocation =new Deposit_Allocation__c();
        depositallocation.Deposit__c = deposit.Id;
        depositallocation.Deposit_Holder__c = acc.id;
        insert depositallocation;
        
        Property_Allocation__c pac=new Property_Allocation__c();
        pac.Landlord_Registration_Number__c='landlord@gmail.com';
        pac.Property__c = property.id;
        insert pac;
        
        Branch_User_Mapping__c branchusermapping =new Branch_User_Mapping__c();
        branchusermapping.Is_Active__c = true;
        branchusermapping.User__c = UserInfo.getUserId();
        branchusermapping.branch__c=branch1.id;
        insert branchusermapping;
        
        
        Test.StartTest();
        
        ViewDepositController.getChangeOverDetails();
        ViewDepositController.getAllTransferredDeposits();
        ViewDepositController.getDeposit(null);                               
        ViewDepositController.getDeposit(branch1.id);
        ViewDepositController.getDepositsByStatus('Deposits held by scheme', branch1.id);  
        ViewDepositController.getDepositsByStatus('Deposits held by scheme', null); 
        ViewDepositController.getDepositRecordsBySearchText('landlord@gmail.com',branch1.id);
        ViewDepositController.getDepositRecordsBySearchText('landlord@gmail.com',null);
        
        Test.StopTest();       
   
   }
   
}