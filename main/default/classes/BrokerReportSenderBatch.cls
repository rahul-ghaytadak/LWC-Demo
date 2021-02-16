/*
* @Purpose: Used to send broker report to internal/external user.
* @Author: Saurabh Chauhan
* @CreatedDate: 
* @Related Code: ReportSchedularController, BrokerReportsSender
* @Test Class: ReportSchedularController_Test
* @LastModifiedDate:
* @LastModifiedBy: Saurabh Chauhan
*/
global class BrokerReportSenderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    global string reportName = '';
    global String batchRunType = '';
    global String exceptionString = '';
    global Decimal numberOfDays = 0;
    global Batch_Log__c bl = new Batch_Log__c();
    global Map<Account, Attachment> accRepMap = new Map<Account,Attachment>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        bl.Run_Type__c = batchRunType;
        bl.Status__c = 'Processing';
        bl.Start_Date__c = System.now();
        Insert bl;
        if(!test.isRunningTest()){
            query = 'SELECT Id, Owner.Email, Name, (SELECT ID, Email, Account.Name, Subscribed_Reports__c FROM Contacts WHERE Subscribed_Reports__c != Null ) FROM Account WHERE Reports_Subscription__c = True';
        }
        if(test.isRunningTest()){
            query = 'SELECT Id, Owner.Email, Name, (SELECT ID, Email, Account.Name, Subscribed_Reports__c FROM Contacts WHERE Subscribed_Reports__c != Null ) FROM Account WHERE Reports_Subscription__c = True limit 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> brokerAccounts) {
        try {
            accRepMap.putAll(BrokerReportsSender.sendReports(brokerAccounts, reportName, bl, integer.valueOf(numberOfDays)));
            
        } catch(Exception e) {
            System.debug('Broker Reports Sender Batch Exception: ' + e + e.getLineNumber() + e.getStackTraceString());
            exceptionString = e.getCause() + '--' + e.getLineNumber() + '--' + e.getMessage()  ;
            bl.Status__c = 'Failed';
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        try{
            List<ContentVersion> contentVersionLst = new List<ContentVersion>();
            List<contentDocumentLink> cdLst = new List<contentDocumentLink>();
            
            String[] toAddresses = new List<String>();
            Report_Schedular__c internalUser = [Select Name,Send_Internally__c from Report_Schedular__c Where Name =: reportName];
            String InternalUserEmailIds = System.Label.InternalUserEmail;
            
            
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            
            if(internalUser.Send_Internally__c){
                bl.Recipient_Mode__c = 'Internal';
                
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                for(Account broker: accRepMap.keySet()){
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    
                    attachment.setContentType('application/vnd.ms-excel');
                    attachment.setFileName(broker.Name + ' - ' + reportName + ' - ' + system.now()+ '.xlsx');
                    if(accRepMap.get(broker) != null){
                        attachment.setBody(accRepMap.get(broker).body);
                    }
                    if(accRepMap.get(broker) != null){
                    attachments.add(attachment);
                    }
                }
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                if(attachments.size() > 0){
                message.setFileAttachments(attachments);
                }
                message.setSubject('Report - ' + reportName);
                message.setHtmlBody('The reports are attached.');
                message.setToAddresses( InternalUserEmailIds.split(','));
                emailMessages.add(message);
                if(attachments.size() > 0){
                    Messaging.sendEmail(emailMessages);
                }
            }
            else{
                bl.Recipient_Mode__c = 'External';
                for(Account broker: accRepMap.keySet()){
                    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setContentType('application/vnd.ms-excel');
                    attachment.setFileName(broker.Name + ' - ' + reportName + ' - ' + system.now() + '.xlsx');
                    attachment.setBody(accRepMap.get(broker).body);
                    attachments.add(attachment);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setFileAttachments(attachments);
                    message.setSubject('Report - ' + reportName);
                    message.setHtmlBody('The reports are attached.');
                    message.setccAddresses(new List<String>{broker.Owner.Email});
                    
                    for(Contact con: broker.Contacts){
                        if(con.Subscribed_Reports__c.split(';').contains(reportName)){
                            toAddresses.add(con.email);
                        }
                    }
                    if(toAddresses.size()>0){
                        message.setToAddresses(toAddresses);
                        emailMessages.add(message);
                    }
                }
                
                Messaging.sendEmail(emailMessages);
            }
            if(accRepMap.values().size() > 0){
                delete accRepMap.values();
            }
        }
        
        catch(Exception e){
            exceptionString = e.getCause() + '--' + e.getLineNumber() + '--' + e.getMessage()  ;
            bl.Status__c = 'Failed';
            if(e.getLineNumber() == 106){
                bl.Status__c = 'Done';
            }
        }
        
        bl.Completed_Date__c = system.Now();
        if(bl.Status__c != 'Failed'){
        	bl.Status__c = 'Done';
        }
        bl.Exception__c = exceptionString;
        Update bl;
        
    }
}