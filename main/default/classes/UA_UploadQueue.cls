/* 
* @Purpose: This class is used to create/upsert Utility Account records.
* @Author: Saurabh Chauhan
* @CreatedDate: 20/10/2020
* @Related Code: 
* @Test Class: Account_File_Uploader_Handler_Test
* @LastModifiedDate:
* @LastModifiedBy:
*/
public class UA_UploadQueue implements Queueable {
    
    public Id recordId;
    public List<String> errList1;
    public blob strfromlex;
    public String FileName;
    public UA_UploadQueue(Id recordId,List<String> errList1,blob strfromlex,String FileName){
        this.recordId = recordId;
        this.errList1 = errList1;
        this.strfromlex = strfromlex;
        this.FileName = FileName;
    }
    
    
    Public void createIntegrationLog(Id recordId,List<String> errList1){
        
        Base_Class_Uploader.createUploadLog(recordId, errList1,'Account');
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
        contentVersion.PathOnClient = FileName;
        contentVersion.Title = FileName;
        contentVersion.VersionData = strfromlex;
        insert contentVersion;
        List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:  contentVersion.Id];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = cd[0].Id;
        contentDocumentLink.LinkedEntityId = recordId;
        contentDocumentLink.ShareType = 'I'; // Inferred permission
        contentDocumentLink.Visibility = 'AllUsers';
        Insert contentDocumentLink;
         if(errList1.size() != 0){
            contentVersion.Title = FileName + ' - HAS ERRORS';
            update ContentVersion;
        }
    }
    
    public void execute(QueueableContext context) { 
        createIntegrationLog(recordId,errList1);
    }
}