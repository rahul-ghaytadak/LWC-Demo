@isTest
public class PrepareForContractController_Test {
    public static testMethod void setupMethod(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Name = 'QuoteLineItem_Trigger';
        settings.TriggerOn__c = false;
        insert settings;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId = UserInfo.getUserId(), TemplateType= 'Text', Name = 'test'); 
            e.IsActive = true;
            Insert e;
        }
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        prod.IsActive = true;
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Account objAcc1 = new Account(Name = 'Account Test1');
        insert objAcc1;
        
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
        objContact.Email = 'test123@test.com';
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
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc1.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
       
        objUA.Annual_Usage_kWh__c = 152000;
        insert objUA;
        
        
        Utility_Account_Opportunity__c uaoToInsert = new Utility_Account_Opportunity__c();
        uaoToInsert.Opportunity__c = objOpp.Id;
        uaoToInsert.Utility_Account__c = objUA.Id;
        uaoToInsert.Status__c = 'Priced';
        insert uaoToInsert;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = objContact.Id;
        ocr.Role = 'Evaluator';
        ocr.OpportunityId = objOpp.Id;
        Insert ocr;
        
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        Insert pr;
        String PricebookEntryId = standardPrice.Id;
        String product2Id = prod.Id;
        Quote newQuoteRecord = new Quote();
        newQuoteRecord.Name = 'New Quote';
        newQuoteRecord.Price__c = pr.Id;
        newQuoteRecord.Pricebook2Id = pricebookId;
        newQuoteRecord.OpportunityId = objOpp.Id;
        insert newQuoteRecord;
        
         Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = objOpp.Id;
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
        cdl.LinkedEntityId = objOpp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        
        QuoteLineItem qliRecord = new QuoteLineItem();
        qliRecord.POR_Tax_Adjustment__c = 1.01;
        qliRecord.QuoteId = newQuoteRecord.Id;
        qliRecord.PricebookEntryID = pricebookEntryId;
        qliRecord.Product2Id = product2Id;
        qliRecord.Term_Months__c = 12;
        qliRecord.Base_Price__c = 0.0450;
        qliRecord.UnitPrice = 500;
        qliRecord.Total_Usage__c = 34000;
        qliRecord.Sales_Margin_per_unit__c = 0.0125;
        qliRecord.Broker_Margin_per_unit__c = 0.0125;
        qliRecord.Quantity = 1;
        Insert qliRecord;
        
        MockHttpResponseGeneratorConga MRGC = new MockHttpResponseGeneratorConga();
        MRGC.attId = attachment.Id;
        Test.setMock(HttpCalloutMock.class, MRGC);
        PrepareForContractController.getQLIs(newQuoteRecord.Id, false);
        PrepareForContractController.getQLIs(newQuoteRecord.Id, true);
        PrepareForContractController.fetchLookUpValues('Test', 'contact', objAcc.Id, true,'');
        PrepareForContractController.fetchLookUpValues('Test', 'contact', objAcc.Id, false,'');
        PrepareForContractController.getCreatedContact(objAcc.Id);
        PrepareForContractController.getQuoteOptions(objOpp.Id);
        PrepareForContractController.getEmailTemplate('test', objOpp.Id,1);
        PrepareForContractController.updateContactRoles(objContact.Id, ocr, objOpp.Id, 'Evaluator');
        PrepareForContractController.updateContactRoles(objContact.Id, null, objOpp.Id, 'Evaluator');
        PrepareForContractController.updateQuote(new List<quotelineItem>{qliRecord});
        PrepareForContractController.getCustomerContacts(objOpp.Id);
        List<String> toadds = new List<String>();
        toadds.add('test@test.com');
        List<String> ccAdds = new List<String>();
        ccAdds.add('test@test123.com');
        List<Id> addFiles = new List<Id>();
        addFiles.add(cdl.Id);
        PrepareForContractController.sendMailMethod(objContact.Id, objOpp.Id, 'test', 'test', new List<ContentDocumentLink>{cdl}, toadds, ccAdds, addFiles);
        PrepareForContractController.Acc_contractValidation(objOpp.Id,'option1',true);
        PrepareForContractController.Acc_contractValidation(objOpp.Id,'option2',false);
        //PrepareForContractController.secondScreenExit(objOpp.Id);
    }
}