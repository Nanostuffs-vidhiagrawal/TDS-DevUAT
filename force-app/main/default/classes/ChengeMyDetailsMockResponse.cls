@isTest
global class ChengeMyDetailsMockResponse implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
      
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"isCorrect":"true","StatusInformation":"InvalidAccountNumber","Bank":"ScotlandBank"}');
        res.setStatusCode(404);
        return res;
    }
    
 }