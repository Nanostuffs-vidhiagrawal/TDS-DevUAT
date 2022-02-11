@isTest
public class EI_ZD_TenantRespondToClaimTest {
    
    
    /*@isTest
public static void Method1(){
EI_ZD_TestDataFactory.createScheme();
EI_ZD_TestDataFactory.createQueryLimit();
EI_ZD_TestDataFactory.createPaymentCustomSetting();
EI_ZD_TestDataFactory.createagent(200);
EI_ZD_TestDataFactory.createLandlord(200);
EI_ZD_TestDataFactory.createTenant(200);
EI_ZD_TestDataFactory.createProperty(200,'a0P8E00000Aa6wsUAB') ;
EI_ZD_TestDataFactory.createDeposite(200,'a0Q8E000004riwgUAA','0018E00001SIOQRQA5','a0P8E00000Aa6wsUAB') ;
EI_ZD_TestDataFactory.createDispute(200,'a0G8E000006zKy6UAE');
EI_ZD_TestDataFactory.createCaseParticipant(100,'5008E00000JUE7FQAX','0018E00001SIe3nQAD','Tenant');
}*/
    @TestSetup    
    public static void testSetupMethod(){
        /* QueryLimits__c objQuery = new QueryLimits__c();
objQuery.CheckOn__c = true;
objQuery.Name = 'All Limits';
insert objQuery; 

Account objAccount  = new Account();
objAccount.Name = 'roshan';
objAccount.Tenant_External_ID__c = '123344';        
Insert objAccount; 

Scheme__c objScheme = new Scheme__c();
objScheme.Name = 'Home Loan';
insert objScheme;        

Deposit__c objDeposite = new Deposit__c();
objDeposite.Customer__c= objAccount.Id;
objDeposite.Deposit_Amount__c = 100;
objDeposite.Scheme__c = objScheme.Id ;
insert objDeposite;

Case objCase = new Case();
objCase.Deposit_Account_Number__c = objDeposite.id;
objCase.Origin='Phone';
objCase.Status ='New';
objCase.Total_Claim_Amount__c = 200;
objCase.On_Hold_Reason__c = 'Court order';
//objCase.Close_Reason__c = 'Non-member';
//objCase.Case_Sub_Reason__c = 'Dispute';
objCase.Dispute_Initiated_By__c = 'Agent';
objCase.Claim_Agreed_By__c='Tenant';
insert objCase;       
Account AGLL =new Account(Name='Elmer Fudd', Phone = '123432234');

insert AGLL;

Case_Participant__c landlordPart = new Case_Participant__c(Account__c = AGLL.Id,
Case__c = objCase.Id,
Type__c = 'Agent',Access_Code__c='qwerty');
insert landlordPart;
Case_Participant__c objCaseParticipant = new Case_Participant__c();
objCaseParticipant.Account__c = objAccount.id;
objCaseParticipant.Case__c = objCase.id;
objCaseParticipant.Type__c = 'Tenant';       
Insert objCaseParticipant; 

Dispute_Item__c objDisputeItem = new Dispute_Item__c();
objDisputeItem.Type__c = 'Damage';
objDisputeItem.Dispute__c = objCase.id;
Insert objDisputeItem;

Evidence_Attachment__c objEvidenceAttachment = new Evidence_Attachment__c();
objEvidenceAttachment.Dispute_Item__c = objDisputeItem.Id;
objEvidenceAttachment.Dispute__c = objCase.id;
objEvidenceAttachment.Scheme__c = 'SDS';
objEvidenceAttachment.Evidence_Categories__c = 'Damage';        
Insert objEvidenceAttachment;    
*/
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
        
        Dispute_item__c di = new Dispute_item__c(type__c='cleaning',Dispute__c=dispute.id);
        insert di;
    }    
    
    @isTest
    public static void testMethod1(){         
        Case objCase = [Select id,External_Id__c from Case Limit 1];
        Deposit__c dep = [Select id from Deposit__c Limit 1];
        List<dispute_item__c> di = [Select id,Dispute__c from dispute_item__c Limit 1];      
        Case_Participant__c cp = [select id from Case_Participant__c where Type__c='tenant' limit 1];
        objCase.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        //objCase.External_ID__c = 
        update objCase;
        EI_ZD_TenantRespondToClaim.updateAdditionalComments(objCase.id,'qwerty','Yes');
        EI_ZD_TenantRespondToClaim.checkLeadTenant(objCase.id, cp.id);
        
        EI_ZD_TenantRespondToClaim.getClaimDetails(objCase.Id);      
        EI_ZD_TenantRespondToClaim.TTMadeOffers(objCase.Id,'Accepted',10);
        EI_ZD_TenantRespondToClaim.TTMadeOffers(objCase.Id,'Rejected',10);
        EI_ZD_TenantRespondToClaim.TTMadeOffers(objCase.Id,'New Offer',10);
        EI_ZD_TenantRespondToClaim.TTMadeOffers(objCase.Id,'New 123',10);
        EI_ZD_TenantRespondToClaim.getClaimDetailsByAccessCode('qwerty');
        EI_ZD_TenantRespondToClaim.UpdateDisputeItemSelfResolutionAgreement('qwerty',objCase.id);
        EI_ZD_TenantRespondToClaim.UpdateDisputeItemSelfResolutionAgreementTT('qwerty',objCase.id);
        EI_ZD_TenantRespondToClaim.AgreedByAgent(objCase.id);                           
        EI_ZD_TenantRespondToClaim.updateClaimTT(objCase.Id,true);
        EI_ZD_TenantRespondToClaim.updateAdditionalCommentsTT(objCase.id,'qwerty');
        EI_ZD_TenantRespondToClaim.getCurrentDate();
        EI_ZD_TenantRespondToClaim.AGLLMadeOffers(objCase.Id,'Accepted',10);
        EI_ZD_TenantRespondToClaim.AGLLMadeOffers(objCase.Id,'Rejected',10);
        EI_ZD_TenantRespondToClaim.AGLLMadeOffers(objCase.Id,'New Offer',10);
        Test.startTest();
        EI_ZD_TenantRespondToClaim.UpdateClaimDetails(objCase.Id,'AGLL',10,'','');
        
        EI_ZD_TenantRespondToClaim.UpdateClaimDetails(objCase.Id,'TT',10,'','');        
        EI_ZD_TenantRespondToClaim.UpdateDisputeItem(JSON.serialize(di),Dep.Id,system.today(),cp.id);
        EI_ZD_TenantRespondToClaim.UpdateDisputeItemSelfResolution(JSON.serialize(di),'AGLL',objCase.id);
        EI_ZD_TenantRespondToClaim.UpdateDisputeItemSelfResolution(JSON.serialize(di),'tenant',objCase.id);
        EI_ZD_TenantRespondToClaim.updatekeyDocuments(objCase.Id,'Yes','Yes','Yes','Yes','hdkkdkdhddhdk');
        EI_ZD_TenantRespondToClaim.updateClaimBreakdown(JSON.serialize(di));
        EI_ZD_TenantRespondToClaim.updateAdditionalComments(objCase.Id,'dhkhkkhdkd','yes');
        EI_ZD_TenantRespondToClaim.updateClaimItemTT(JSON.serialize(di),objCase.Id,true);
        test.stopTest();
    }    
    
    /*	@isTest
public static void testMethod2(){

Case objCase = [Select id,Status,Claim_Agreed_By__c from Case Limit 1];         
objCase.Status ='Case cancelled';
//objCase.Close_Reason__c ='Complaints';
objCase.Claim_Agreed_By__c='Agent/Landlord';
Update objCase;

//EI_ZD_TenantRespondToClaim.EI_ZD_TenantRespondToClaim(objCase.id,'AGLL',100,'SDS2345','SDFGHY12345');

Case objCase1 = [Select id,Status,Claim_Agreed_By__c from Case Limit 1];         
objCase1.Status ='Case closed - agreement reached';
//objCase.Close_Reason__c ='Complaints';
objCase1.Claim_Agreed_By__c='Tenant';
Update objCase1;
//   EI_ZD_TenantRespondToClaim.EI_ZD_TenantRespondToClaim(objCase1.id,'TL',100,'SDS2345','SDFGHY12345'); 

}

@isTest
public static void testMethod3(){  

Case objCase1 = [Select id,Status,Claim_Agreed_By__c from Case Limit 1];         
objCase1.Status ='Case closed - agreement reached';
//objCase.Close_Reason__c ='Complaints';
objCase1.Claim_Agreed_By__c='Tenant';
Update objCase1;
//    EI_ZD_TenantRespondToClaim.EI_ZD_TenantRespondToClaim(objCase1.id,'TL',100,'SDS2345','SDFGHY12345'); 

} 

@isTest
public static void testMethod4(){

Case objCase = [Select id,Status,Claim_Agreed_By__c from Case Limit 1];     
User objUser =[Select id from User Limit 1] ;
System.assertequals(objUser.id,'');
EI_ZD_TenantRespondToClaim.MakePayment(objCase.Id,'TL',500,'SDS2345','objUser.id');

}

@isTest
public static void testMethod5(){
Case objCase = [Select id,Status,Claim_Agreed_By__c from Case Limit 1];       

EI_ZD_TenantRespondToClaim.AGLLMadeOffers(objCase.id, 'Accepted', 500);   
}

@isTest
public static void testMethod6(){
Case objCase = [Select id,Status,Claim_Agreed_By__c from Case Limit 1];        

EI_ZD_TenantRespondToClaim.AGLLMadeOffers(objCase.id, 'Rejected', 500);   
}

@isTest
public static void testMethod7(){
Case objCase = [Select id,Status,Claim_Agreed_By__c from Case Limit 1];        

EI_ZD_TenantRespondToClaim.AGLLMadeOffers(objCase.id, ' ', 500);   
}

@isTest
public static void testMethod8(){
Date dp = system.today();      
EI_ZD_TenantRespondToClaim.getCurrentDate();   
}

@isTest
public static void testMethod9(){
Case_Participant__c objCaseParticipant =[Select id from Case_Participant__c ];
Savepoint sp = null;
EI_ZD_TenantRespondToClaim.UpdateDisputeItem('ieeii112','123wed', date.today(), objCaseParticipant.id);

Deposit__c objDeposite =[Select id from Deposit__c Limit 1];
Deposit__c objDis = new Deposit__c(); 
objDis.id = objDeposite.Id;
update objDis;


}
*/       
    
    
}