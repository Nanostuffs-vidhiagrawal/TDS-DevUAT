@isTest
global class TransferDepositCallout implements HttpCalloutMock {
  
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
      
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Email__c":"test@g.com","PersonEmail":"persontest@g.com"}');
        res.setStatusCode(200);
        return res;
    }
    
 }