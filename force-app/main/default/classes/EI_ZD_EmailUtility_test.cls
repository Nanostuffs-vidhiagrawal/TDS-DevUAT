@isTest
global class EI_ZD_EmailUtility_test {
    
    @isTest
    global static void testMethod1(){
        Scheme__c scheme= EI_ZD_TestDataFactory.createScheme();
        insert scheme;
        QueryLimits__c queryLimits = EI_ZD_TestDataFactory.createQueryLimit();
        insert queryLimits;
        account Landlord = EI_ZD_TestDataFactory.createLandlord(1)[0];
        insert Landlord;
        Property__c property= EI_ZD_TestDataFactory.createProperty(1,Landlord.id)[0];
        insert property;
        Deposit__c deposit= EI_ZD_TestDataFactory.createDeposite(1,scheme.id,Landlord.id,property.id)[0];
        insert deposit;
        case dispute = EI_ZD_TestDataFactory.createDispute(1,deposit.id)[0];
        insert dispute;
        Id ZDRecordType  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Zero Deposit Dispute').getRecordTypeId();
        case c =new Case(origin = 'Zero Deposit',status = 'new',recordtypeId = ZDRecordType);
        insert c;
        //recipient(String Email,String name,String recId
        EI_ZD_EmailUtility.recipient rec = new EI_ZD_EmailUtility.recipient('test@test.com','test','');
        //      public recipient(String Email,String name,String recId,String Link){
        List<EI_ZD_EmailUtility.recipient> recList = new list<EI_ZD_EmailUtility.recipient>();
        recList.add(rec);
        reclist.add(new  EI_ZD_EmailUtility.recipient('test@test.com','test','','qwerty'));
        reclist.add(new  EI_ZD_EmailUtility.recipient('test@test.com','test','','qwerty','qwerty','q234r5t'));
        
        map<string,String> m = new Map<String,String>();
        Test.setMock(HttpCalloutMock.class, new EmailUtilityMock());
        EI_ZD_EmailUtility.sendEmailFromActivityTab(dispute.id,'test@test.com',Landlord.id,'ZP7','test');
        m.put('asdf','qwer');
        //String subject, String recList,Map<String,String> variables,String template, String mailjet
        EI_ZD_EmailUtility.sendEmailNew('test',JSON.serialize(recList),m,'ZP7','test');
        EI_ZD_EmailUtility.mailJet_Authentication('mailjet');
        EI_ZD_EmailUtility.sendEmail('test',JSON.serialize(recList),m,'ZP7','test');
        
        EI_ZD_EmailUtility.fetchCP(c.id);
        
        //   Test.setMock(HttpCalloutMock.class, new EmailUtilityMock());
        
        
        String res='(response:[Status=null, messages=(Messages:[CustomID=, Status=success, To=(To:[Email=kapeeshtesting@gmail.com, MessageHref=https://api.mailjet.com/v3/REST/message/1152921513035664773, MessageID=1152921513035664773, MessageUUID=30820dbe-8355-4199-a8a5-76fe047cedaa])])])';
        //String resJSON,Map<String,recipient> recMap, STring Subject
        //  EI_ZD_EmailUtility.saveMessageDetails(res,recList,'test');
    }
    
    global class EmailUtilityMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('(response:[Status=null, messages=(Messages:[CustomID=, Status=success, To=(To:[Email=kapeeshtesting@gmail.com, MessageHref=https://api.mailjet.com/v3/REST/message/1152921513035664773, MessageID=1152921513035664773, MessageUUID=30820dbe-8355-4199-a8a5-76fe047cedaa])])])');
            response.setStatusCode(200);
            return response; 
        }
    }
}