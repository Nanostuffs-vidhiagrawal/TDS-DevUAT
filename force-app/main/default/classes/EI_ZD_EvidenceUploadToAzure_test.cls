@isTest
public class EI_ZD_EvidenceUploadToAzure_test {
   @TestSetup
    Public static void dataSetup(){
        QueryLimits__c ql = new QueryLimits__c();
        ql.CheckOn__c=true;
        ql.Name = 'All Limits';
        insert ql;

        List<Account> accList = new List<Account>();
        List<Case_Participant__c> casePList = new List<Case_Participant__c>();
       // Deposit dep = new Deposit__c(Scheme__c = scheme1.Id, Customer__c=landlordAcc1.Id_;
         Id ZDRecordType  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        case cs = new Case(origin = 'Zero Deposit',status = 'Self-Resolution',recordtypeId = ZDRecordType);
               
       
        
        insert cs;
       
            Account tent =   new Account(FirstName='Daffy', LastName = 'Duck', PersonEmail = 'Daffy@Duck.com', PersonHomePhone = '123456789', 
                                         RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType,'Person'));
            Account AGLL =new Account(Name='Elmer Fudd', Phone = '123432234');
            insert tent;
            insert AGLL;
            //  accList.add(tent);
            // accList.add(AGLL);
            //  Contact con = new Contact(Name='Daffy')
            Case_Participant__c tenantPart2 = new Case_Participant__c(Account__c = tent.Id,
                                                                      Case__c = cs.Id,
                                                                      
                                                                      // Contact__c = tenantCon2.Id,
                                                                      Type__c = 'Tenant');
            Case_Participant__c landlordPart = new Case_Participant__c(Account__c = AGLL.Id,
                                                                       Case__c = cs.Id,
                                                                       Type__c = 'Agent');
            casePList.add(tenantPart2);
            casePList.add(landlordPart);
        
        //  insert accList;
        insert casePList;
        
        Dispute_Item__c di = new Dispute_Item__c(dispute__c = cs.id, Type__c = 'Redecoration');
        insert di;

       // Azure_Storage_Credentials_per_Scheme__mdt m = new Azure_Storage_Credentials_per_Scheme__mdt();
    }
    
    @isTest
    public static void testmethod1(){
        case c =[select id from case];
 Dispute_Item__c d =[select id from Dispute_Item__c];
        EI_ZD_EvidenceUploadToAzure.saveFile(c.id,'','','','','','2','','Tenant obligations','','','Zero Deposite');
         EI_ZD_EvidenceUploadToAzure.saveFile(c.id,'','','','','','2','','Inventorycheck in report','','','Zero Deposite');
         EI_ZD_EvidenceUploadToAzure.saveFile(c.id,'','','','','','2','','Check out report','','','Zero Deposite');
         EI_ZD_EvidenceUploadToAzure.saveFile(c.id,'','','','','','2','','Rent statement','','','Zero Deposite');
        EI_ZD_EvidenceUploadToAzure.getPicklistvalues('Evidence_Attachment__c','Evidence_Categories__c','User_Type__c');
        EI_ZD_EvidenceUploadToAzure.getDisputeItem(c.id,'Redecoration');
        EI_ZD_EvidenceUploadToAzure.getSecureURI('Zero Deposite');
          EI_ZD_EvidenceUploadToAzure.deleteFileAzure('test',d.id,'Tenant obligations',c.id,'Zero Deposite');
    }
}