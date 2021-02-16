/*
* @Purpose: Test class to cover PricingRequestForVFEmailTemplate
* @Author: Akanksha Pandharkame
* @CreatedDate: 11/21/2019
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/

@isTest
public class PricingRequestForVFEmailTemplate_Test {
    @isTest
    public static void TestMethod1(){
        
        List<Id> enrollmentRecIdVal = new List<Id>();
          HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
    
        Experian__c creds = new Experian__c();
        creds.Auth_URL__c = 'https://sandbox-us-api.experian.com/oauth2/v1/token';
        creds.Auto_Search_URL__c= 'https://sandbox-us-api.experian.com/businessinformation/businesses/v1/scores/search';
        creds.Auth_Body__c='{"username": "admin@decima.one","password": "IHz8OJ93E16G!","client_id": "W7o3bmXvo1aZCSdD3SaMLwRw3nJzg1YB","client_secret":"xpp2lyKgfJO7kl4R"}';
            creds.Subcode__c= 517614;
        insert creds;
       
        
        Account objAcc = new Account(Name = 'Account Test',Phone='1234567894');
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
        
        Product2 prod = new Product2(Name = 'Fully Fixed', 
                                     Family = 'Hardware');
        insert prod;
        
        
        PricingRequestForVFEmailTemplate obj = new PricingRequestForVFEmailTemplate();
       RecordType Dualrt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Credit_Check_Required' limit 1];
        Pricing_Request__c prObj = new Pricing_Request__c();
        prObj.RecordTypeId = Dualrt.Id;
        prObj.Opportunity__c=objOpp.Id;
        prObj.Product_Lookup__c=prod.Id;
        prObj.Invoice_billing_Type__c = 'Summary Billing';
        prObj.Status__c = 'New';
        //prObj.Request_Type__c = 'Refresh';
        prObj.Bill_Type__c = 'UCB';
        probj.Start_Date__c = Date.valueOf(System.now());
        probj.Due_Date__c = Date.valueOf(System.now()+3);
        probj.Start_Dates__c = 'Same';
        prObj.Notes__c = 'test';
        prObj.Urgent_Request__c = true;
        insert probj;
        
        List<Utility_Account__c> newUAs = new List<Utility_Account__c>{objUA};
            Utility_Account_Pricing__c objUAO = new Utility_Account_Pricing__c();
        objUAO.Utility_Account__c = objUA.Id;
        objUAO.Pricing_Request__c = probj.Id;
        objUAO.Start_Date__c = system.today();
        insert objUAO;
        
        Utility_Account_Pricing__c objUAO2 = new Utility_Account_Pricing__c();
        objUAO2.Utility_Account__c = objUA.Id;
        objUAO2.Pricing_Request__c = probj.Id;
        objUAO2.Start_Date__c = system.today();
        insert objUAO2;
        
        Utility_Account_Pricing__c objUAO3 = new Utility_Account_Pricing__c();
        objUAO3.Utility_Account__c = objUA.Id;
        objUAO3.Pricing_Request__c = probj.Id;
        objUAO3.Start_Date__c = system.today();
        insert objUAO3;
        
        List<Utility_Account_Pricing__c> UAOList = new List<Utility_Account_Pricing__c>();
        UAOList.add(objUAO2);
        List<Utility_Account_Pricing__c> incUAOList = new List<Utility_Account_Pricing__c>();
        incUAOList.add(objUAO); 
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        prlst.add(pr);
        insert prlst;
        
        
        obj.prId=prObj.id;
        
        List<Utility_Account_Pricing__c> lstAOU = obj.getlstUAOs();
        obj.setprId(prObj.id);
        obj.getprId();
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.stopTest();
        
    }
}