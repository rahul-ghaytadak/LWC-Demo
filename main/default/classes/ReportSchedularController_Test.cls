/*
* @Purpose: Test class of ReportSchedularController.
* @Author: Vishwanath Kodgire
* @CreatedDate: 
* @Related Code: ReportSchedularController
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
@isTest
public class ReportSchedularController_Test {
    
     @isTest(SeeAllData='true')
    public static void setupMethod(){
        
       
        Report_Schedular__c rs = new Report_Schedular__c();
        rs.Name = 'test';
        rs.Send_Internally__c = true;
        rs.Report_Name__c = 'Drops';
        rs.Date_of_month__c = '1';
        rs.Day_of_week__c = 'MON';
        rs.Time__c = '21:38:46';
        rs.Days__c = 'Weekly';
        insert rs;
        
       
        
        Account objAcc = new Account(Name = 'Account Test',Reports_Subscription__c = true,Phone = '1234567890');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        
        Contact objContact = new Contact();
        objContact.Subscribed_Reports__c = 'Drops';
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        objContact.Email = 'test123@test.com';
        insert objContact;
        
       
        
         Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = objContact.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        Insert attachment;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objContact.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        
        MockHttpResponseGeneratorConga MRGC = new MockHttpResponseGeneratorConga();
        MRGC.attId = attachment.Id;
        Test.setMock(HttpCalloutMock.class, MRGC);
        
        List<String> toadds = new List<String>();
        toadds.add('test@test.com');
        List<String> ccAdds = new List<String>();
        ccAdds.add('test@test123.com');
        List<Id> addFiles = new List<Id>();
        addFiles.add(cdl.Id);
       
        ReportSchedularController.scheduleReport(RS);
        ReportSchedularController.getData();
        BrokerReportSenderBatch brep = new BrokerReportSenderBatch(); 
        brep.reportName = 'Drops';
        brep.batchRunType = 'Manual';
        database.executebatch(brep, 200);
        ReportSchedularController.getReportSchedulars();
        ReportSchedularController.toggleOff('Drops');
        ReportSchedularController.updateReport(RS);
        ReportSchedularController.toggleOff('Drops');
        ReportSchedularController.deleteReportSched(RS);
        
    }
    
    @isTest(SeeAllData='true')
    public static void setupMethod2(){
        
       
     Report_Schedular__c rs = new Report_Schedular__c();
        rs.Name = 'test';
        rs.Send_Internally__c = true;
        rs.Report_Name__c = 'Broker Enrollment Report';
        rs.Date_of_month__c = '1';
        rs.Day_of_week__c = 'MON';
        rs.Time__c = '21:38:46';
        rs.Days__c = 'Weekly';
        insert rs;
        
        Account objAcc = new Account(Name = 'Account Test',Reports_Subscription__c = true,Phone = '1234567890');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        
        Contact objContact = new Contact();
        objContact.Subscribed_Reports__c = 'Broker Enrollment Report';
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        objContact.Email = 'test123@test.com';
        insert objContact;
        
       
        
         Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = objContact.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        Insert attachment;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objContact.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        
        MockHttpResponseGeneratorConga MRGC = new MockHttpResponseGeneratorConga();
        MRGC.attId = attachment.Id;
        Test.setMock(HttpCalloutMock.class, MRGC);
        
        List<String> toadds = new List<String>();
        toadds.add('test@test.com');
        List<String> ccAdds = new List<String>();
        ccAdds.add('test@test123.com');
        List<Id> addFiles = new List<Id>();
        addFiles.add(cdl.Id);
       
        ReportSchedularController.scheduleReport(RS);
        ReportSchedularController.getData();
        BrokerReportSenderBatch brep = new BrokerReportSenderBatch(); 
        brep.reportName = 'Broker Enrollment Report';
        brep.batchRunType = 'Manual';
        database.executebatch(brep, 200);
        ReportSchedularController.getReportSchedulars();
        ReportSchedularController.toggleOff('Broker Enrollment Report');
        ReportSchedularController.updateReport(RS);
        ReportSchedularController.toggleOff('Broker Enrollment Report');
        ReportSchedularController.deleteReportSched(RS);
        
    }
    
    @isTest(SeeAllData='true')
    public static void setupMethod3(){
    
        BrokerReportSenderBatch brep = new BrokerReportSenderBatch(); 
        brep.reportName = 'Enrollment Rejections';
        brep.batchRunType = 'Manual';
        database.executebatch(brep, 200);
        
        
    }
    @isTest(SeeAllData='true')
    public static void setupMethod4(){
    
        BrokerReportSenderBatch brep = new BrokerReportSenderBatch(); 
        brep.reportName = 'Future Agreements Report';
        brep.batchRunType = 'Manual';
        database.executebatch(brep, 200);
        
        
    }
}