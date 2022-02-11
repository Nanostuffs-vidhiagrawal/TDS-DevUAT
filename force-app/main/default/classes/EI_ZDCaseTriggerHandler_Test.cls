@isTest
public class EI_ZDCaseTriggerHandler_Test {
    @TestSetup
    Public static void dataSetup(){
        QueryLimits__c ql = new QueryLimits__c();
        ql.CheckOn__c=true;
        ql.Name = 'All Limits';
        insert ql;
        List<Case> caseList = new List<case>();
        List<Account> accList = new List<Account>();
        List<Case_Participant__c> casePList = new List<Case_Participant__c>();

         Id ZDRecordType  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
      
          case c =new Case(origin = 'Zero Deposit',status = 'new',recordtypeId = ZDRecordType);
        
       
        
       insert c;
            Account tent =   new Account(FirstName='Daffy', LastName = 'Duck', PersonEmail = 'Daffy@Duck.com', PersonHomePhone = '123456789', 
                                         RecordTypeId = FC_RecordTypeUtils.getRecordTypeIdByDeveloperName(Account.SObjectType,'Person'));
            Account AGLL =new Account(Name='Elmer Fudd', Phone = '123432234');
            insert tent;
            insert AGLL;

            Case_Participant__c tenantPart2 = new Case_Participant__c(Account__c = tent.Id,
                                                                      Case__c = c.Id,
                                                                      
                                                                      // Contact__c = tenantCon2.Id,
                                                                      Type__c = 'Tenant');
            Case_Participant__c landlordPart = new Case_Participant__c(Account__c = AGLL.Id,
                                                                       Case__c = c.Id,
                                                                       Type__c = 'Agent');
            casePList.add(tenantPart2);
            casePList.add(landlordPart);
     
        //  insert accList;
        insert casePList;
        
        
    }
    @istest
    public static void testMethod1(){
        case c = [select id from case];
        test.startTest();
        c.Status='Invitation to view the claim';
            update c;
        /*c.Status='Self-resolution';
            update c;
        c.Status='Evidence gathering agent/landlord';
            update c;
        c.Status='Evidence gathering tenant';
            update c;*/
        test.stopTest();
    }
    @istest
    public static void testMethod2(){
        case c = [select id from case];
        test.startTest();
     c.Status='Self-resolution';
            update c;
      
        test.stopTest();
    }
    @istest
    public static void testMethod3(){
        case c = [select id from case];
        test.startTest();
     c.Status='Evidence gathering agent/landlord';
            update c;
      
        test.stopTest();
    }
     @istest
    public static void testMethod4(){
        case c = [select id from case];
        test.startTest();
     c.Status='Evidence gathering tenant';
            update c;
      
        test.stopTest();
    }
        @istest
    public static void testMethod5(){
        case c = [select id from case];
        test.startTest();
     c.Status='Closed';
            update c;
      
        test.stopTest();
    }
      @istest
    public static void testMethod6(){
        case c = [select id from case];
        test.startTest();
     c.Status='Case cancelled';
            update c;
      
        test.stopTest();
    }
      @istest
    public static void testMethod7(){
        case c = [select id from case];
        test.startTest();
     c.Status='Adjudication';
       
            update c;
      
        test.stopTest();
    }
}