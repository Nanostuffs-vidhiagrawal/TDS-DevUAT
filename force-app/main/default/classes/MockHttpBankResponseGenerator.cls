@isTest
global class MockHttpBankResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "IsCorrect": true,"Bank":"National Westminster Bank plc"}');
        res.setStatusCode(200);
        return res;
    }
}