/*
* @Purpose: Used to Schedule broker report.
* @Author: Saurabh Chauhan
* @CreatedDate: 
* @Related Code: BrokerReportSenderBatch
* @Test Class: ReportSchedularController_Test
* @LastModifiedDate:
* @LastModifiedBy: Saurabh Chauhan
*/

public class BrokerReportsSender {
    
    public static Map<Account, Attachment> sendReports(List<Account> brokerAccounts, String reportName,Batch_Log__c bl,integer numberOfDays){
        
        if(numberOfDays == null){
            numberOfDays = 500;
        }
        
        List<ContentVersion> contentVersionLst = new List<ContentVersion>();
        List<contentDocumentLink> cdLst = new List<contentDocumentLink>();
        Map<Account, Attachment> accRepMap = new Map<Account,Attachment>();
        Map<String, List<Contact>> brokerContactMap = new Map<String, List<Contact>>();
        Map<String, Id> reportNameIdMap = new Map<String, Id>();
        String ReportFolderName = System.Label.ReportFolderName;
        List<APXTConga4__Conga_Merge_Query__c> brokerReports = [SELECT Id, Name,APXTConga4__Name__c FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c  =: reportName];
        List<APXTConga4__Conga_Template__c> ReportTemplate = [SELECT APXTConga4__Name__c, Id FROM APXTConga4__Conga_Template__c where APXTConga4__Name__c =: reportName];
        DateTime currentDate = System.today();
        Date nnDate = system.today();
        Date finalDate = nnDate.addDays(-numberOfDays);
        Datetime dt = Datetime.newInstance(finalDate.year(), finalDate.month(),finalDate.day());
        System.debug('Date filter->'+dt.format('yyyy-MM-dd'));
        
        if(!brokerReports.isEmpty()){
            Id reportId = brokerReports[0].Id;
            Id templateId = ReportTemplate[0].Id;
            Map<String, List<String>> conRepNameMap = new Map<String, List<String>>();
            for(Account broker: brokerAccounts){
                
                boolean EmptyReport = false;
                String filterParameters = '';
                String sessId = UserInfo.getSessionId();
                String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/29.0/'+UserInfo.getOrganizationId();
                
                if(brokerReports[0].APXTConga4__Name__c == 'Drops'){
                    System.debug('Broker.Name-->'+Broker.Name);
                    System.debug('numberOfDays->'+numberOfDays);
                    filterParameters = '?pv0='+broker.Id+'~pv1='+dt.format('yyyy-MM-dd');
                    List<Utility_Account_Enrollment__c > UAELst = [SELECT Id,Utility_Account__r.Name, Utility_Account__c,CreatedDate, Status__c FROM Utility_Account_Enrollment__c where (Utility_Account__r.Status__c='DACC' OR Utility_Account__r.Status__c='DCNF' OR Utility_Account__r.Status__c='DPND' OR Utility_Account__r.Status__c='DREJ') and Utility_Account__r.Account__r.Broker__r.Name =: Broker.Name AND CreatedDate >: currentDate.addDays(-numberOfDays)];
                    if(UAELst.IsEmpty()){
                        if(!test.isRunningTest()){
                            EmptyReport = true;
                            System.debug('Empty Drops');
                        }
                    }
                }
                
                if(brokerReports[0].APXTConga4__Name__c == 'Enrollment Rejections'){
                    filterParameters = '?pv0='+broker.Id+'~pv1='+dt.format('yyyy-MM-dd'); 
                    List<Utility_Account_Enrollment__c > UAELst = [SELECT Id,Utility_Account__r.Name, Utility_Account__c,CreatedDate, Status__c FROM Utility_Account_Enrollment__c where Utility_Account__r.Status__c = 'EREJ' and Utility_Account__r.Account__r.Broker__r.Name =: Broker.Name AND CreatedDate >: currentDate.addDays(-numberOfDays)];
                    if(UAELst.IsEmpty()){
                        if(!test.isRunningTest()){
                            EmptyReport = true;
                            System.debug('Empty Enrollment Rejections');
                        }
                    }
                }
                
                if(brokerReports[0].APXTConga4__Name__c == 'Future Agreements Report'){
                    filterParameters = '?pv0='+broker.Id+'~pv1='+dt.format('yyyy-MM-dd'); 
                    List<Utility_Account_Enrollment__c > UAELst = [SELECT Id,Utility_Account__r.Name, Utility_Account__c,CreatedDate, Status__c FROM Utility_Account_Enrollment__c where Status__c != 'Enrollment Request Accepted' and Utility_Account__r.Account__r.Broker__r.Name =: Broker.Name AND CreatedDate >: currentDate.addDays(-numberOfDays)];
                    system.debug('UAELst size->'+UAELst.size());
                    if(UAELst.size() == 0){
                        if(!test.isRunningTest()){
                            EmptyReport = true;
                            System.debug('Empty Broker Enrollment Report');
                        }
                    }
                }
                
                if(brokerReports[0].APXTConga4__Name__c == 'Broker Enrollment Report'){
                    filterParameters = '?pv0='+broker.Id+'~pv1='+dt.format('yyyy-MM-dd'); 
                    List<Utility_Account_Enrollment__c > UAELst = [SELECT Id,Utility_Account__r.Name, Utility_Account__c,CreatedDate, Status__c FROM Utility_Account_Enrollment__c where Status__c = 'Enrollment Request Accepted' and Utility_Account__r.Account__r.Broker__r.Name =: Broker.Name AND CreatedDate >: currentDate.addDays(-numberOfDays)];
                    if(UAELst.IsEmpty()){
                        if(!test.isRunningTest()){
                            EmptyReport = true;
                            System.debug('Empty Broker Enrollment Report');
                        }
                    }
                }
                if(EmptyReport == false){
                    System.debug('filterParameters-->'+filterParameters);
                    String url2 = 'https://composer.congamerge.com/composer8/index.html'+
                        '?sessionId='+sessId+
                        '&serverUrl='+EncodingUtil.urlEncode(servUrl, 'UTF-8')+
                        '&id=' + broker.Id+
                        '&Queryid=[Reps]'+reportId+filterParameters+
                        '&TemplateId='+templateId+
                        '&DS7=11'+
                        '&APIMode=1';
                    
                    System.debug(url2);
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(url2);
                    req.setMethod('GET');
                    req.setTimeout(60000);
                    
                    Attachment att;
                    if(!test.isRunningTest()){
                        HttpResponse res = http.send(req);
                        system.debug('::::'+ res.getStatus() + ' => ' + res.getBody());
                        
                        if(!res.getBody().contains('error')){
                            att = [Select Id,ParentId,Name, Body From Attachment Where id =: res.getBody()];
                        }
                    }
                    if(test.isRunningTest()){
                        att = [Select Id,ParentId,Name, Body From Attachment limit 1];
                    }
                    accRepMap.put(broker, att);
                    Boolean insertedFileForTHisBroker = false;
                    String[] toAddresses = new List<String>();
                    for(Contact con: broker.Contacts){
                        System.debug('subs->'+con.Subscribed_Reports__c);
                        System.debug('reportName'+reportName);
                        if(con.Subscribed_Reports__c.split(';').contains(reportName)){
                            toAddresses.add(con.email);
                            if(insertedFileForTHisBroker == false){
                                ContentVersion contentVersion = new ContentVersion();
                                
                                contentVersion.ContentLocation = 'S'; 
                                contentVersion.PathOnClient = accRepMap.get(broker).Name;
                                contentVersion.Title = accRepMap.get(broker).Name;
                                contentVersion.VersionData = accRepMap.get(broker).body;
                                contentVersionLst.add(contentVersion);
                                insertedFileForTHisBroker = true;
                            }
                        }
                    }
                    
                }
            }
            
            if(!contentVersionLst.IsEmpty()){
                insert contentVersionLst;
                for(ContentDocument cd:[SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId IN:  contentVersionLst]){
                    ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                    contentDocumentLink.ContentDocumentId = cd.Id;
                    contentDocumentLink.LinkedEntityId = bl.Id;
                    contentDocumentLink.ShareType = 'I'; 
                    contentDocumentLink.Visibility = 'AllUsers';
                    cdLst.add(contentDocumentLink);
                }
            }
            
            if(!cdLst.IsEmpty()){
                insert cdLst;
            }
        }
        return accRepMap;
    }
}