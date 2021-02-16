@isTest
public class CongaDocumentGenerator_Test {
    public static testMethod void setupMethod(){
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            EmailTemplate e = new EmailTemplate (developerName = 'Broker_Deal_Confirmation_HTML', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'Broker_Deal_Confirmation_HTML'); 
            e.IsActive = true;
            Insert e;
        }
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Live';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        objContact.Email = 'test@decima.com';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        objOpp.State__c = 'NY';
        insert objOpp;
        
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = objOpp.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        Insert attachment;
        
        
        SendEmailApex.values ve = new SendEmailApex.values();
        ve.recipientId = objContact.Id;
        ve.emailTemplateName = 'Broker_Deal_Confirmation_HTML'; 
        ve.recordId = objOpp.Id;
        ve.AttachAgreementFromContract = false;
        List<SendEmailApex.values> veList = new List<SendEmailApex.values>();
        veList.add(ve);
        SendEmailApex.invokeSendEmail(veList);
        MockHttpResponseGeneratorConga MRGC = new MockHttpResponseGeneratorConga();
        MRGC.attId = attachment.Id;
        Test.setMock(HttpCalloutMock.class, MRGC);
        Test.startTest();
        List<ID> oppId = new List<ID>{objOpp.id};
            CongaDocumentGenerator.values v = new CongaDocumentGenerator.values();
        v.congaTemplateId = objOpp.Customer_Agreement_Template__c;
        v.congaQuery = 'testtest';
        v.fileName = 'test';
        v.recordId = objOpp.Id;
        v.emailTemplateName = 'Broker_Deal_Confirmation_HTML'; 
        v.recipientId = objContact.Id;
        v.generateDocumentAndSendEmail = True;
        v.attachAgreementFromContract = false;
        List<CongaDocumentGenerator.values> vList = new List<CongaDocumentGenerator.values>();
        vList.add(v);
        CongaDocumentGenerator.invokeCallConga(vList);
         
        Test.stopTest();
    }
}