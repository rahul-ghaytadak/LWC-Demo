global class TestMockup implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');       
        res1.setBody('{"message": "Your lead was successfully created.","id": "123"}');
        res1.setStatusCode(200);
        return res1;
    }
}