public class CongaDocumentGenerator {
    public class values{
        @invocableVariable(required=true)
        public ID congaTemplateId;
        @invocableVariable
        public String congaQuery; 
        @invocableVariable(required=true)
        public String fileName;
        @invocableVariable(required=true)
        public ID recordId;
        @invocableVariable
        public String emailTemplateName;
        @invocableVariable
        public ID recipientId;
        @invocableVariable(required=true)
        public Boolean generateDocumentAndSendEmail;
        @invocableVariable
        public Boolean attachAgreementFromContract;
        
    }
    
    @invocableMethod(label = 'invokeConga')
    public static void invokeCallConga(List<values> v){
        system.debug('v' + v);
        callConga(v[0].recordId, v[0].congaTemplateId, v[0].congaQuery, v[0].fileName, v[0].emailTemplateName, v[0].recipientId, v[0].generateDocumentAndSendEmail, v[0].attachAgreementFromContract);
    }
    
    @future(callout=true)
    public static void callConga(Id recordId, Id templateId, String congaQuery, string fileName, String emailTemplateName, Id recipientId, Boolean generateDocumentAndSendEmail, Boolean attachAgreementFromContract){
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
        congaQuery = congaQuery.replaceAll(' ', '');      
        String ofn = fileName.replaceAll(' ', '%7D%20');
        String url2 = 'https://composer.congamerge.com/composer8/index.html'+
            '?sessionId='+sessId+
            '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
            '&id=' + recordId+
            '&QueryId='+ congaQuery+
            '&TemplateId='+templateId+
            '&OFN=' +EncodingUtil.urlEncode(ofn, 'UTF-8') +
            '&DS7=11'+
            '&DefaultPDF=1&APIMode=1';
        
        System.debug(url2);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url2);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        // Send the request, and return a response
        HttpResponse res = http.send(req);
        system.debug('::::'+ res.getStatus() + ' => ' + res.getBody());
        if(!res.getBody().contains('error')){
            Attachment att = [Select Name, Body From Attachment Where id =: res.getBody()];
            att.Name = att.Name.replaceAll('}', '');
            update att;
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = att.Name;
            contentVersion.Title = att.Name;
            contentVersion.VersionData = att.Body;
            insert contentVersion;
            List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:  contentVersion.Id];
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = cd[0].Id;
            contentDocumentLink.LinkedEntityId = recordId;
            contentDocumentLink.ShareType = 'I'; // Inferred permission
            contentDocumentLink.Visibility = 'AllUsers';
            Insert contentDocumentLink;
            List<ID> docIds = new List<ID>();
            docIds.add(att.Id);
            if(generateDocumentAndSendEmail){
                if(attachAgreementFromContract == FALSE)
                    SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId );
                else{
                    List<Contract> cRecord = [SELECT Id, Signed_Agreement__c FROM Contract WHERE Id =: recordId];
                    if(cRecord[0].Signed_Agreement__c != NULL){
                        List<Attachment> signerAgreementAttachment = [Select Name, Body From Attachment Where parentId =: cRecord[0].Signed_Agreement__c ORDER BY CreatedDate Desc LIMIT 1];
                        if(!signerAgreementAttachment.isEmpty()){ docIds.add(signerAgreementAttachment[0].Id); }
                        SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId );
                    }
                }
            }
        }
    }
    
    @future(callout=true)
    public static void callCongaMultipleAgreements(Id recordId, Id templateId, String congaQuery, string fileName, String emailTemplateName, Id recipientId, Boolean generateDocumentAndSendEmail, Boolean attachAgreementFromContract,Integer term){
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
        congaQuery = congaQuery.replaceAll(' ', '');      
        String ofn = fileName.replaceAll(' ', '%7D%20');
        String url2 = 'https://composer.congamerge.com/composer8/index.html'+
            '?sessionId='+sessId+
            '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
            '&id=' + recordId+
            '&QueryId='+ congaQuery+','+'[OppLineItem]a06f000000FNjS0AAL?pv0='+recordId+'~pv1='+term+
            '&TemplateId='+templateId+
            '&OFN=' +EncodingUtil.urlEncode(ofn, 'UTF-8') +
            '&DS7=11'+
            '&DefaultPDF=1&APIMode=1';
        
        System.debug(url2);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url2);
        req.setMethod('GET');
        req.setTimeout(60000);
        
        // Send the request, and return a response
        HttpResponse res = http.send(req);
        system.debug('::::'+ res.getStatus() + ' => ' + res.getBody());
        if(!res.getBody().contains('error')){
            Attachment att = [Select Name, Body From Attachment Where id =: res.getBody()];
            att.Name = att.Name.replaceAll('}', '');
            update att;
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = att.Name;
            contentVersion.Title = att.Name;
            contentVersion.VersionData = att.Body;
            insert contentVersion;
            List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:  contentVersion.Id];
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = cd[0].Id;
            contentDocumentLink.LinkedEntityId = recordId;
            contentDocumentLink.ShareType = 'I'; // Inferred permission
            contentDocumentLink.Visibility = 'AllUsers';
            Insert contentDocumentLink;
            List<ID> docIds = new List<ID>();
            docIds.add(att.Id);
            if(generateDocumentAndSendEmail){
                if(attachAgreementFromContract == FALSE)
                    SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId );
                else{
                    List<Contract> cRecord = [SELECT Id, Signed_Agreement__c FROM Contract WHERE Id =: recordId];
                    if(cRecord[0].Signed_Agreement__c != NULL){
                        List<Attachment> signerAgreementAttachment = [Select Name, Body From Attachment Where parentId =: cRecord[0].Signed_Agreement__c ORDER BY CreatedDate Desc LIMIT 1];
                        if(!signerAgreementAttachment.isEmpty()){ docIds.add(signerAgreementAttachment[0].Id); }
                        SendEmailApex.sendEmail(docIds, emailTemplateName, recipientId, recordId );
                    }
                }
            }
        }
    }
}