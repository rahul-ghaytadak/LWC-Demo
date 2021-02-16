/*
* @Purpose: HttpCalloutMock for ZnalyticsAPI_Test, to get request parameters.
* @Author: Sonali Taskar
* @CreatedDate: 11/20/2019
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
              // Create a fake response
        HttpResponse res1 = new HttpResponse();
        res1.setHeader('Content-Type', 'application/json');
        res1.setBody('{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}');
        res1.setStatusCode(200);
        return res1;
    }
}