public class CallCongaReports {
    
    @future(callout=true)
    public static void callConga(Id recordId, Id templateId, String congaQuery, string fileName, String emailTemplateName, Id recipientId, Boolean generateDocumentAndSendEmail, Boolean attachAgreementFromContract){
        templateId = 'a0Ef000000N5sZ5EAJ' ;
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
        congaQuery = congaQuery.replaceAll(' ', '');      
        String ofn = fileName.replaceAll(' ', '%7D%20');
        String url2 = 'https://composer.congamerge.com/composer8/index.html'+
            '?sessionId='+sessId+
            '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
            '&id=' + recordId+
            '&Reportid='+ congaQuery+
            '&TemplateId='+templateId+
            '&DS7=11'+
            '&APIMode=1';
        
        System.debug(url2);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url2);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        // Send the request, and return a response
        HttpResponse res = http.send(req);
        system.debug('::::'+ res.getStatus() + ' => ' + res.getBody());
        Attachment att;
        if(!res.getBody().contains('error')){
             att = [Select Name, Body From Attachment Where id =: res.getBody()];
        }
       
    }
}