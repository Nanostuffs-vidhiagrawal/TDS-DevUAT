@isTest
public class EI_ZD_UpdateStatusBatch_Test {
     
    @TestSetup
    Public static void dataSetup(){
        QueryLimits__c ql = new QueryLimits__c();
        ql.CheckOn__c=true;
        ql.Name = 'All Limits';
        insert ql;
        List<Case> caseList = new List<case>();
        List<Account> accList = new List<Account>();
        List<Case_Participant__c> casePList = new List<Case_Participant__c>();
       // Deposit dep = new Deposit__c(Scheme__c = scheme1.Id, Customer__c=landlordAcc1.Id_;
         Id ZDRecordType  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        for(integer i = 0; i<16 ; i++){
            caseList.add(new Case(origin = 'Zero Deposit',status = 'new',recordtypeId = ZDRecordType));
        }
        CaseList[0].Status='Invitation to view the claim';
        caseList[0].Respond_Date__c=system.today();
        CaseList[1].Status='Self-Resolution';
        caseList[1].Respond_Date__c=system.today();
        caselist[1].Counter__c=1;
        CaseList[2].Status='Self-Resolution';
        caseList[2].IIIrd_Working_Day_SR__c=system.today();
        caseList[2].Respond_Date__c=system.today()+2;
        caselist[2].Counter__c=1;
        CaseList[3].Status='Self-Resolution';
        caseList[3].Respond_Date__c=system.today();
        caselist[3].Counter__c=1;
        caseList[3].TT_respond_Self_resolution__c= true;
        caseList[3].AGLL_Respond_Self_resolution__c = true;
        CaseList[4].Status='Self-Resolution';
        caseList[4].Respond_Date__c=system.today();
        caselist[4].Counter__c=2;
        caseList[4].TT_respond_Self_resolution__c= false;
        caseList[4].AGLL_Respond_Self_resolution__c = false;
        CaseList[5].Status='Self-Resolution';
        caseList[5].Respond_Date__c=system.today();
        caselist[5].Counter__c=2;
        caseList[5].TT_respond_Self_resolution__c= true;
        caseList[5].AGLL_Respond_Self_resolution__c = false;
        CaseList[6].Status='Self-Resolution';
        caseList[6].Respond_Date__c=system.today();
        caselist[6].Counter__c=2;
        caseList[6].AGLL_Respond_Self_resolution__c = true;
        CaseList[7].Status='Evidence gathering agent/landlord';
        caseList[7].Respond_Date__c=system.today();
        caselist[7].Counter__c=1;
        CaseList[8].Status='Evidence gathering agent/landlord';
        caseList[8].IIIrd_Working_Day_SR__c=system.today();
        caseList[8].Respond_Date__c=system.today()+2;
        caselist[8].Counter__c=1;
        CaseList[9].Status='Evidence gathering agent/landlord';
        caseList[9].Respond_Date__c=system.today();
        caselist[9].Counter__c=1;
        caseList[9].TT_respond_evidence_gathering__c= true;
        caseList[9].AGLL_Respond_Evidance_Gathering__c = true;
        CaseList[10].Status='Evidence gathering agent/landlord';
        caseList[10].Respond_Date__c=system.today();
        caselist[10].Counter__c=2;
        caseList[10].TT_respond_evidence_gathering__c= false;
        caseList[10].AGLL_Respond_Evidance_Gathering__c = false;
        CaseList[11].Status='Evidence gathering agent/landlord';
        caseList[11].Respond_Date__c=system.today();
        caselist[11].Counter__c=2;
        caseList[11].TT_respond_evidence_gathering__c= true;
        caseList[11].AGLL_Respond_Evidance_Gathering__c = false;
        CaseList[12].Status='Evidence gathering agent/landlord';
        caseList[12].Respond_Date__c=system.today();
        caselist[12].Counter__c=2;
        caseList[12].AGLL_Respond_Evidance_Gathering__c = true;
         CaseList[13].Status='Adjudication';
        caseList[13].IIIrd_Working_Day_SR__c=system.today();
        CaseList[14].Status='Evidence gathering tenant';
        caseList[14].TT_respond_evidence_gathering__c=false;
         caseList[14].IIIrd_Working_Day_SR__c=system.today();
        CaseList[15].Status='Evidence gathering tenant';
        caseList[15].TT_respond_evidence_gathering__c=true;
         caseList[15].Respond_Date__c=system.today();
        
        insert caseList;
        for(case c : caseList){
            Account tent =   new Account(FirstName='Daffy', LastName = 'Duck', PersonEmail = 'Daffy@Duck.com', PersonHomePhone = '123456789', 
                                         RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType,'Person'));
            Account AGLL =new Account(Name='Elmer Fudd', Phone = '123432234');
            insert tent;
            insert AGLL;
            //  accList.add(tent);
            // accList.add(AGLL);
            //  Contact con = new Contact(Name='Daffy')
            Case_Participant__c tenantPart2 = new Case_Participant__c(Account__c = tent.Id,
                                                                      Case__c = c.Id,
                                                                      
                                                                      // Contact__c = tenantCon2.Id,
                                                                      Type__c = 'Tenant');
            Case_Participant__c landlordPart = new Case_Participant__c(Account__c = AGLL.Id,
                                                                       Case__c = c.Id,
                                                                       Type__c = 'Agent');
            casePList.add(tenantPart2);
            casePList.add(landlordPart);
        }
        //  insert accList;
        insert casePList;
        
        
    }
    
    @isTest static void test1() {
        Test.startTest();
        //EI_ZD_UpdateStatusBatch uca = new EI_ZD_UpdateStatusBatch	();
        //Id batchId = Database.executeBatch(uca);
        EI_ZD_BatchScheduler sh1 = new EI_ZD_BatchScheduler();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1); 
        Test.stopTest();
        List<Case> c =[select id from case];
        system.debug(c.size());
        
    }
    
    
}