@isTest
global  class ChangeMyDetailsMockResponse2 implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
      
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"isCorrect":"false","StatusInformation":"UnknownSortCode","Bank":"ScotlandBank"}');
        res.setStatusCode(200);
        return res;
    }

}