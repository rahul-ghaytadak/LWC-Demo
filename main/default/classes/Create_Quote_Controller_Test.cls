/*
* @Purpose: Test class for Create_Quote_Controller Apex.
* @Author: Vishwanath Kodgire
* @CreatedDate: 01/17/2020
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/
@isTest
public class Create_Quote_Controller_Test {
    public static testMethod void setupMethod(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Name = 'QuoteLineItem_Trigger';
        settings.TriggerOn__c = false;
        insert settings;
        List<Id> enrollmentRecIdVal = new List<Id>();
        
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
        objOpp.Start_Date__c = system.today();
        insert objOpp;
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        objUA.Annual_Usage_kWh__c = 152000;
        insert objUA;
        List<Utility_Account__c> newUAs = new List<Utility_Account__c>{objUA};
        Utility_Account_Opportunity__c objUAO = new Utility_Account_Opportunity__c();
        objUAO.Utility_Account__c = objUA.Id;
        objUAO.Twelve_Month_Price__c = 1200;
        objUAO.Opportunity__c = objOpp.Id;
        objUAO.Status__c = 'Priced - Excluded';
        insert objUAO;
        
        Utility_Account_Opportunity__c objUAO2 = new Utility_Account_Opportunity__c();
        objUAO2.Utility_Account__c = objUA.Id;
        objUAO2.Twelve_Month_Price__c = 1200;
        objUAO2.Opportunity__c = objOpp.Id;
        objUAO2.Status__c = 'Priced - Excluded';
        insert objUAO2;
        
        Utility_Account_Opportunity__c objUAO3 = new Utility_Account_Opportunity__c();
        objUAO3.Utility_Account__c = objUA.Id;
        objUAO3.Twelve_Month_Price__c = 1200;
        objUAO3.Opportunity__c = objOpp.Id;
        objUAO3.Status__c = 'Priced';
        insert objUAO3;
        
        List<Utility_Account_Opportunity__c> UAOList = new List<Utility_Account_Opportunity__c>();
        UAOList.add(objUAO2);
        List<Utility_Account_Opportunity__c> incUAOList = new List<Utility_Account_Opportunity__c>();
        incUAOList.add(objUAO); 
       
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        Pricing_Request__c pReq = new Pricing_Request__c();
        insert pReq;
        
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Pricing_Request__c = pReq.Id;
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        pr.Product_Lookup__c = prod.Id;
        prlst.add(pr);
        insert prlst;
        
        
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
        
        
         List<Price_Summary__c> priceSumlst = new List<Price_Summary__c>();
        Price_Summary__c priceSum = new Price_Summary__c();
        priceSum.Volume_kWh__c = 4500;
        priceSum.Base_Price__c = 0.1500;
        priceSum.Price__c = pr.Id;
        priceSum.Term_months__c = 12;
        priceSum.Price_x_Vol__c = 1500;
        priceSum.Utility_Count__c = 1;
        priceSum.Cumulative_Volume__c  = 154555;
        priceSum.Load_Factor_Decimal__c = 40;
        priceSum.Month__c = 'Nov' ;
        priceSum.Year__c = 2020;
        priceSum.Tax_x_Volume__c =  10;
        priceSum.POR_x_Volume__c =  10;
        priceSumlst.add(priceSum);
        insert priceSumlst;

        Price_Summary__c priceSum2 = new Price_Summary__c();
        priceSum2.Volume_kWh__c = 4500;
        priceSum2.Base_Price__c = 0.1500;
        priceSum2.Price__c = pr.Id;
        priceSum2.Term_months__c = 12;
        priceSum2.Price_x_Vol__c = 1500;
        priceSum2.Utility_Count__c = 1;
        priceSum2.Cumulative_Volume__c  = 154555;
        priceSum2.Load_Factor_Decimal__c = 40;
        priceSum2.Month__c = 'Nov' ;
        priceSum2.Year__c = 2020;
        priceSum2.Tax_x_Volume__c =  10;
        priceSum2.POR_x_Volume__c =  10;

        
        test.startTest();
        Create_Quote_Controller.fetchAccountWrapper(objOpp.Id, 'ASC', 'Utility_Account__c', true);
        Create_Quote_Controller.getPrice(objOpp.Id);
        Create_Quote_Controller.SelectedPriceName(pr.Id);
        Create_Quote_Controller.updateUAOWithSelectedPrice(pr.Id, objOpp.Id);
        Create_Quote_Controller.updateExcludedUAO(UAOList, incUAOList, objOpp.Id,String.valueOf(pr.Id));
        insert priceSum2;
        List<Create_Quote_Controller.PSListWrapper> psRecords = Create_Quote_Controller.getPSRecords('ASC', 'Term_Months__c',objOpp.Id,pr.Id );
        Create_Quote_Controller.generateQuoteAndLineItems(psRecords, objOpp.Id, 0.2560, 0.2585, pr.Id,true,1201,0.2);
        Create_Quote_Controller.getUAs( objOpp.Id);
        Create_Quote_Controller.saveUAs(objOpp.Id, newUAs);
        Create_Quote_Controller.TotalPriceValidation(objOpp.Id,new List<Decimal>{0.1},pr.Id);
        Create_Quote_Controller.AllowNIMOValidation(objOpp.Id,new List<Decimal>{0.1},pr.Id);
        Create_Quote_Controller.getQuoteSummaryData(objOpp.Id);
        test.stopTest();
    }
}