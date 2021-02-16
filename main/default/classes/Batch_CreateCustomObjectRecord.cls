/***************************************************************************************************************************
* Name:          Batch_CreateCustomObjectRecord 
* Description:   Batch class for File_Uploader Component 
* Last Modified by : Rahul Ghaytadak
* Related Code:  file_upload_handler,BatchPriceUploader,Call_Create_Price_Summary,Create_Price_Summary_Asynchronous
* Test Class:    file_upload_handler_Test
* Version History
* Date             Developer                Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 01-08-2020       Saurabh Chauhan          Import CSV file data in Price__c, Term_Price__c, Utility_Account__c
*											and Price_Upload_Log__c.  
****************************************************************************************************************************/



global class Batch_CreateCustomObjectRecord implements Database.Batchable<List<String>>, Database.Stateful,  Database.AllowsCallouts
{
    //declaring global variables required for batch processing.
    global final blob dataDocuments;
    global integer count = 0;
    global String FileName = '';
    global Id recordId;
    global List<Price__c> priceLst = new List<Price__c>();
    global Set<String> ErrorLst = new Set<String>();
    global Integer finalrows = 1;
    global Boolean ToggleValue;
   
    
    //Constructor to get the file data before batch execution (initialisation)
    global Batch_CreateCustomObjectRecord (blob dataDocuments,String FileName,Id recordId,Boolean ToggleValue)
    {
        this.recordId = recordId;
        this.dataDocuments = dataDocuments;
        this.FileName = FileName;
        this.ToggleValue = ToggleValue;
    }
    
    //Get the parsed CSV data using RT_CSVReader function at the start of Batch Execution 
    global Iterable<List<String>>  start(Database.BatchableContext BC)
    {
        Price__c price1 = new Price__c();
        insert price1;
        priceLst.add(price1);
        return new RT_CSVReader(this.dataDocuments.toString());  
    }
    
    //Process the file records (term prices) in chunks as per the Batch size Set (1001 as of now)
    global void execute(Database.BatchableContext BC, List<List<String>> inputCSVLines)
    {
        count++;
        ErrorLst.addAll(BatchPriceUploader.processFileChunk(inputCSVLines, recordId, count, dataDocuments.toString(), FileName,priceLst[0].Id,finalrows,ToggleValue));
        finalrows = inputCSVLines.size()*count;
    }
    
    //Creation of Upload Log
    //Sending Success and Failure emails/Custom Notifications based on field updates on Pricing Request and Oppty.
    //Insert the CSV which is processed in Batch class for upload.
    global void finish(Database.BatchableContext BC)
    {
        Price__c  pr = [Select id,Opportunity__c,Voluntary_RECs__c, Voluntary_RECs_percent__c, Treatment__c,Invoice_Billing_Type__c, Term_Price_Count__c,Price_Upload_Failed__c,Pricing_Request__c from Price__c  where Id =:priceLst[0].Id];
        Pricing_Request__c  prReq = [Select id,Name,Opportunity__c,Voluntary_RECs__c,Voluntary_RECs_percent__c,Treatment__c,Invoice_Billing_Type__c,Price_Upload_Failed__c from Pricing_Request__c  where Id =:recordId];
        
        List<AggregateResult> groupedResults = [SELECT COUNT(Id),Term__c,Utility_Account_Opportunity__r.Utility_Account__r.Name,Price__c
                                                FROM Term_Price__c where Price__c =: priceLst[0].Id
                                                GROUP BY Term__c,Price__c,Utility_Account_Opportunity__r.Utility_Account__r.Name HAVING COUNT(Id) > 1];
        
        
        
        for (Integer i = 0; i< groupedResults.size(); i++)  {
            if(groupedResults[i].get('expr0') == 2){
                System.debug('Duplicate Record-->'+groupedResults[i].get('Name'));
                ErrorLst.add(groupedResults[i].get('Name')+' is present in the file more than once.');
                
                break;
            }
        }
        
        if(ErrorLst.size()>0){
            List<String> lStrings = new List<String>(ErrorLst);
            delete pr;
            prReq.Price_Upload_Failed__c = true;
            update prReq;    
            Base_Class_Uploader.createUploadLog(recordId, lStrings,'Pricing Request');
            
        }
        else
        {
            List<String> lStrings = new List<String>(ErrorLst);
            Base_Class_Uploader.createUploadLog(recordId, lStrings,'Pricing Request');
            Create_Price_Summary_Asynchronous.getTermPrice2(new List<Id>{priceLst[0].Id});
            
            Opportunity Opp = [SELECT Id,Pricing_Request_Complete__c,OwnerId FROM Opportunity where Id =: prReq.Opportunity__c];
            Opp.Pricing_Request_Complete__c = true;
            pr.Pricing_Request__c = recordId;
            pr.Opportunity__c = prReq.Opportunity__c;
            pr.Invoice_Billing_Type__c = prReq.Invoice_Billing_Type__c;
            pr.Voluntary_RECs__c = prReq.Voluntary_RECs__c;
            pr.Voluntary_RECs_percent__c = prReq.Voluntary_RECs_percent__c;
            pr.Treatment__c = prReq.Treatment__c;
            ContentVersion contentVersion = new ContentVersion();

                contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
                contentVersion.PathOnClient = FileName+'.csv';
                contentVersion.Title = FileName;
                contentVersion.VersionData = dataDocuments;
                insert contentVersion;

                List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:  contentVersion.Id];
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.ContentDocumentId = cd[0].Id;
                contentDocumentLink.LinkedEntityId = recordId;
                contentDocumentLink.ShareType = 'I'; // Inferred permission
                contentDocumentLink.Visibility = 'AllUsers';
               
                Insert contentDocumentLink;
            
            update Opp;
            update pr;
            prReq.Calculate_Credit_Limits__c = true;
            update prReq;
            //Get called when Align Start Dates toggle is true 
            if(ToggleValue == TRUE){
                
				// Add the custom notification when price start date is updated.
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody('Start Dates on '+ prReq.Name +' were updated by Pricing when the Price data was loaded.  Please check the Quote Generator to see the updated Start Dates for each Utility Account.');
                notification.setTitle('Start Dates have been updated on '+ prReq.Name+'.');	
                notification.setSenderId(Userinfo.getUserId());
                CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Stat_Dates_Update_Of_UA'];
                notification.setNotificationTypeId(type.id);
                notification.setTargetId(Opp.Id); // target object id
                notification.send(new Set<String> { Opp.OwnerId });
                                
            }
        }
        
    }
}