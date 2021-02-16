/*
* @Purpose: Test class for PricingRequestTrigger trigger.
* @Author: Aress Software
* @CreatedDate: 05/11/2020
* @Related Code: 
* @LastModifiedDate:
* @LastModifiedBy:
*/

@isTest
public class PricingRequestTrigger_test {
    @testSetup
    public static void setupMethod(){
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        Account objAccb = new Account(Name = 'Account Test',State__c = 'NY',Credit_Check_Required__c = true,Phone='1234567894');
        insert objAccb;
        Account objAccb1 = new Account(Name = 'Account Test',State__c = 'NY',Credit_Check_Required__c = true,Phone='1234567894');
        objAccb1.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Customer'].Id;
        insert objAccb1;
        Account objAcc = new Account(Name = 'Account Test',State__c = 'NY',Credit_Check_Required__c = true,Broker__c = objAccb.Id,Phone='1234567894' );
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
        objOpp.State__c = 'NY';
        objOpp.AccountId = objAccb1.Id;
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
        
        List<Utility_Account__c> newUAs = new List<Utility_Account__c>{objUA};
            Utility_Account_Opportunity__c objUAO = new Utility_Account_Opportunity__c();
        objUAO.Utility_Account__c = objUA.Id;
        objUAO.Twelve_Month_Price__c = 1200;
        objUAO.Opportunity__c = objOpp.Id;
        objUAO.Status__c = 'Priced - Excluded';
        objUAO.Start_Date__c = system.today();
        insert objUAO;
        
        Utility_Account_Opportunity__c objUAO2 = new Utility_Account_Opportunity__c();
        objUAO2.Utility_Account__c = objUA.Id;
        objUAO2.Twelve_Month_Price__c = 1200;
        objUAO2.Opportunity__c = objOpp.Id;
        objUAO2.Status__c = 'Priced - Excluded';
        objUAO2.Start_Date__c = system.today();
        insert objUAO2;
        
        Utility_Account_Opportunity__c objUAO3 = new Utility_Account_Opportunity__c();
        objUAO3.Utility_Account__c = objUA.Id;
        objUAO3.Twelve_Month_Price__c = 1200;
        objUAO3.Opportunity__c = objOpp.Id;
        objUAO3.Status__c = 'Priced';
        objUAO3.Start_Date__c = system.today();
        insert objUAO3;
        
        List<Utility_Account_Opportunity__c> UAOList = new List<Utility_Account_Opportunity__c>();
        UAOList.add(objUAO2);
        
        List<Utility_Account_Opportunity__c> incUAOList = new List<Utility_Account_Opportunity__c>();
        incUAOList.add(objUAO); 
        
        Product2 prod = new Product2(Name = 'Fully Fixed', 
                                     Family = 'Fixed',State__c = 'NY');
        insert prod;
        
        
        List<Create_Opportunity.UAWrapper> UALstWrapper = new List<Create_Opportunity.UAWrapper>();
        List<Create_Opportunity.UAWrapper> UALstWrapperNew = new List<Create_Opportunity.UAWrapper>();
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        UALstWrapperNew = Create_Opportunity.getUAList(objUA.Account__c, 'NY', 'ASC', 'Name', UALstWrapper);
        Create_Opportunity.getUAList(objUA.Account__c, 'NY', 'ASC', 'Name', UALstWrapperNew);
        Create_Opportunity.getStatePicklist(objUA.Id);
        Create_Opportunity.SaleType();
        Create_Opportunity.GetStatusPicklist();
        Create_Opportunity.ProductFamily();
        Create_Opportunity.GetProducts('Fixed', 'NY');
        Create_Opportunity.GetUAOsandState(objOpp.Id);
        Create_Opportunity.CreateOpptywithUAOs(UALstWrapperNew, UALstWrapperNew, UALstWrapperNew);
        Create_Opportunity.SetPgLst(UALstWrapperNew);
        Create_Opportunity.setPgLstcheckbox(UALstWrapperNew);
        
        test.stopTest();
    }
    
    @isTest
    public static void TestMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        
        List<Utility_Account__c> newUAs = new List<Utility_Account__c>([Select Id, Name,Account__c,Account__r.Broker__c,Status__c,Utility__r.Credit_Check_Required__c, Utility__r.Name, Utility_State__c , Supply_Start_Date__c from Utility_Account__c]);
        List<Utility_Account_Opportunity__c> UAOList = [Select Id,Utility_Account__c,Start_Date__c,Twelve_Month_Price__c,Status__c,Opportunity__c from Utility_Account_Opportunity__c ];
        Id objOpp = UAOList[0].Opportunity__c;
        User userObj = [Select Id,Name from User where Id =: UserInfo.getUserId()];
        Product2 ProductId = [Select Id,Name from Product2 where name = 'Fully Fixed'];
        list <Pricing_Request__c> pr1 = new list<Pricing_Request__c>();
        list<Account> acc = [Select Id, Name From Account];
        list<Contact> con = [Select Id, Name From Contact];
        
        //Create_PricingRequest.PRWrapper obj1 = new Create_PricingRequest.PRWrapper();            
        Pricing_Request__c prObj= new Pricing_Request__c();
        prObj.Bill_Type__c='UCB';
        prObj.Invoice_Billing_Type__c='	';
        prObj.Product_Lookup__c= ProductId.Id;
        prObj.Status__c = 'Ready For Pricing';
        prObj.Opportunity__c = objOpp;
        prObj.RecordTypeId = Schema.SObjectType.Pricing_Request__c.getRecordTypeInfosByName().get('Default Pricing Request').getRecordTypeId();
        insert prObj;
        prObj.Status__c = 'HU Complete';
        update prObj;
        
        Credit_Check__c creditCheckRecord = new Credit_Check__c(Customer__c = acc[0].Id,Pricing_REquest__c = prObj.Id, Opportunity__c = objOpp, Status__c = 'Active', Credit_Check_Outcome__C = 'Passed', FSR_Score__c = 19, IP_Score__c = 9);
        Insert creditCheckRecord;
        
        test.stopTest();
        
    }
    
}