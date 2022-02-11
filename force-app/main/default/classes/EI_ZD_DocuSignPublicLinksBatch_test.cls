@isTest
global class EI_ZD_DocuSignPublicLinksBatch_test {
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
        
        List<Adjudication_Report__c> adjList = new List<Adjudication_Report__c>();
        for(integer i=0; i<10; i++){
            adjList.add(new Adjudication_Report__c(Dispute__c = cs.id,User_Type__c='Adjudicator',Adjudication_Report_URL__c='wert.com'+i));
        }
        insert adjList;
        
        SpringCM_Settings__c ss = new SpringCM_Settings__c(Auth_Endpoint__c='get.qwerty.com',
                                                           API_User_Client_Id__c='qwerty',
                                                           API_User_Client_Secret__c='qwerty',
                                                          Sharelinks_Endpoint__c='get.werty.com');
        insert ss;
            
          
    }
    
@isTest
    public static void testmethod1(){
        Test.setMock(HttpCalloutMock.class, new testMock());
        List<Adjudication_Report__c> adjList = [select id,Adjudication_Report_URL__c from Adjudication_Report__c];
        database.executeBatch(new EI_ZD_DocuSignPublicLinksBatch(adjList));
    }
      global class testMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            Map<String,String> testMap = new  Map<String,String> ();
            testMap.put('access_token','123456');
            response.setHeader('Content-Type', 'application/json');
            response.setBody(JSON.serialize(testMap));
            response.setStatusCode(200);
            return response; 
        }
    }
}