public class ExperianCallout {
    
    public static String tokenFetcher(String endpoint, String authBody){
        Http newHttp = new Http();
        HttpRequest newHttpRequest = new HttpRequest();
        newHttpRequest.setTimeout(60000);                 
        newHttpRequest.setMethod('POST');                                                                      
        newHttpRequest.setHeader('Content-type','application/json');
        newHttpRequest.setHeader('Accept','application/json');
        newHttpRequest.setHeader('Grant-type','password');
        newHttpRequest.setEndpoint(endpoint);
        newHttpRequest.setBody(authBody);
        HttpResponse newHttpResponse = newHttp.send(newHttpRequest);
        System.debug('Response->'+newHttpResponse.getBody());
        Map<String, Object> bearerResp =   (Map<String, Object>) JSON.deserializeUntyped(newHttpResponse.getBody());
        return (String)bearerResp.get('access_token');
    }
    public static HttpResponse serchResponseFetcher(String endpoint, String token, String reqBody){
        Http newHttp = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(60000);                 
        request.setMethod('POST');                                                                      
        request.setHeader('Authorization', 'Bearer ' + token);
        System.debug('token->'+token);
        request.setHeader('Content-Type','application/json');
        request.setEndpoint(endpoint);
        request.setBody(reqBody);
        HttpResponse response = newHttp.send(request);
        system.debug('resp  ' + response.getStatusCode() + response.getStatus() +  response.getBody());
        return response;
    }
}