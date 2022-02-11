@isTest
global class RequestRepayDepoControllerCallout3 implements HttpCalloutMock {
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
      
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"agentAmount":"122","TenantAmount":"333","cleanNo":"78","damangeNo":"54","reDecorationNo":"67"}');
        
        res.setStatusCode(404);
        return res;
    }
    
}