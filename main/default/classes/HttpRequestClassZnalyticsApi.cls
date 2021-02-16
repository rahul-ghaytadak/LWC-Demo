/*
* @Purpose: This class will be dynamic HTTP class where we can call different api requests as per the paramter provided
* and It will return the string as jsonbody 
* @Author: Sonali Taskar
* @CreatedDate: 11/13/2019
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/


public class HttpRequestClassZnalyticsApi {
	
    // Variable declarations
    public string responseApiRequest;
    public Integer Code;
    
    //This method will return the Json string depending upon the API request and Paramters
    Public string doPost(string method, string stringBody){
        try{
            
            //Create new Http Request
            Http newHttp = new Http();
            HttpRequest newHttpRequest = new HttpRequest();
            
            //set the paramter for the api Request
            newHttpRequest.setTimeout(60000);                 
            newHttpRequest.setMethod(method);                                                                      
            newHttpRequest.setHeader('Content-type','application/json');
            
            //set the endpoint and API key for the request
            newHttpRequest.setEndpoint('callout:Znalytics');
            newHttpRequest.setHeader('Ocp-Apim-Subscription-Key','{!$Credential.Password}');
            
            //set the body
            newHttpRequest.setBody(stringBody);
            
            //create new http response
            HttpResponse newHttpResponse = newHttp.send(newHttpRequest);
            
            //store the response in json string and return the same
            responseApiRequest = newHttpResponse.getBody();
           
            
            //get the code from the Response
            //Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(newHttpResponse.getBody());
            //Map<String, Object> statusMessage = (Map<String, Object>) mapResponse.get('messages');
            //Code = Integer.valueof(mapResponse.get('code'));
           
                
            //StubDataApiRequest.insertEnrollmentRec(responseApiRequest, Code);
            
            //return the string
            return responseApiRequest;
        }catch(Exception ex){
            return ex.getMessage();
        }
    }
}