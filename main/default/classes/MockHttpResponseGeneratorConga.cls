/*
* @Purpose: HttpCalloutMock for ZnalyticsAPI_Test, to get request parameters.
* @Author: Vishwanath K
* @CreatedDate: 26/02/2020
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/
global class MockHttpResponseGeneratorConga implements HttpCalloutMock {
    // Implement this interface method
    global Id attId;
    global HTTPResponse respond(HTTPRequest req) {
              // Create a fake response
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setBody(attId);
        res1.setStatusCode(200);
        return res1;
    }
}