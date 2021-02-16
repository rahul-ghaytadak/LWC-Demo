/*
* @Purpose: Test class to cover VFBrokerSalesConfirmationController
* @Author: Vishwanath Kodgire
* @CreatedDate: 30/01/2020
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/

@isTest
public class VFBrokerSalesConfirmationController_Test {

    public static testMethod void setupMethod(){
        VFBrokerSalesConfirmationController obj = new VFBrokerSalesConfirmationController();
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
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
         String Pricebook2Id = [select id, name from pricebook2].Id;
        PricebookEntry pricebookEntryRecord = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: Pricebook2Id ];
        String PricebookEntryId = pricebookEntryRecord.Id;
        String product2Id = pricebookEntryRecord.Product2Id;
        Quote newQuoteRecord = new Quote();
        newQuoteRecord.Name = 'New Quote';
        newQuoteRecord.Pricebook2Id = Pricebook2Id;
        newQuoteRecord.OpportunityId = objOpp.Id;
        //newQuoteRecord.IsSyncing = true;
        insert newQuoteRecord;
        objOpp.SyncedQuoteId = newQuoteRecord.Id;
        update objOpp;
        QuoteLineItem qliRecord = new QuoteLineItem();
        qliRecord.QuoteId = newQuoteRecord.Id;
        qliRecord.PricebookEntryID = pricebookEntryId;
        qliRecord.Product2Id = product2Id;
        qliRecord.Term_Months__c = 12;
        qliRecord.Base_Price__c = 500;
        qliRecord.UnitPrice = 0.004;
        qliRecord.Total_Usage__c = 123;
        qliRecord.Sales_Margin_per_unit__c = 00.22;
        qliRecord.Broker_Margin_per_unit__c = 0.222;
        qliRecord.Quantity = 1;
        insert qliRecord;
        obj.oppIdValue = objOpp.Id;
        obj.oppId = objOpp.Id;
        obj.setoppId(objOpp.Id);
        obj.getoppId();
        
        List<Utility_Account_Quote__c> lstAOU = obj.getData();
    }
}