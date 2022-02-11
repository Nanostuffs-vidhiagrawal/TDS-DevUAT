@isTest
public class EI_testAdjudicationreviewdecisionbyparty{
    
    @isTest
    public static void Method1(){
        
         Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Letting Agent').getRecordTypeId();
         Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute SDS Custodial').getRecordTypeId();
       
        Account a = new Account();
        a.recordTypeId = RecordTypeId;
        a.LastName = 'Mishra';
        insert a;
        
        Scheme__c s = new  Scheme__c();
        s.Name='old scheme';
        insert s;
        
        Deposit__c d = new Deposit__c();
        d.Customer__c = a.Id;  
        d.Deposit_Amount__c = 5000.00;
       // d.Status__c ='Decision issued - awaiting request for review';
        d.Scheme__c = s.Id;
        insert d;        
        
        Case objcase = new Case();
        objcase.Deposit_Account_Number__c = d.id;
        objcase.RecordTypeId = devRecordTypeId;
        objcase.Dispute_Initiated_By__c = 'Agent';
        objcase.Total_Claim_Amount__c = 200;
        objcase.Origin = 'Phone';
        objcase.status = 'Review of decision requested';
        objcase.Agent_landlord_responded_on_adjudication__c = false;
        objcase.Tenant_responded_on_adjudication__c = true;
        //objcase.Days_Remaining__c = '5';
        insert objcase;
       
        list<case>caseList = new list<Case>();
         Case objcase1 = new Case();
        objcase1.Deposit_Account_Number__c = d.id;
        objcase1.RecordTypeId = devRecordTypeId;
        objcase1.Dispute_Initiated_By__c = 'Agent';
        objcase1.Total_Claim_Amount__c = 200;
        objcase1.Origin = 'Phone';
        objcase1.status = 'Review of decision requested';
        objcase1.Agent_landlord_responded_on_adjudication__c = true;
        objcase1.Tenant_responded_on_adjudication__c = true;
		objcase1.id =   objcase.id;      
        update objcase1;
        caseList.add(objcase1);
        
        EI_Adjudicationreviewdecisionbyparty.beforeupdatecaseandrelateditems(caseList);       
       
        
    }

}