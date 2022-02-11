@isTest
global class  EI_selfresolutionsummaryviewtenantcall implements HttpCalloutMock {
  
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
      
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"messege":"from","username"}');
         //res.setBody('{"isCorrect":"true","StatusInformation":"InvalidAccountNumber","Bank":"ScotlandBank"}');
        res.setStatusCode(200);
        return res;
    }
    
 }