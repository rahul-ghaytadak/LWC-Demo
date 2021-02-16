@IsTest
public class SplitOpportunity_Test {
    
    @istest
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
        
        Opportunity objOpp1 = new Opportunity();
        objOpp1.State__c = 'NY';
        objOpp1.AccountId = objAccb1.Id;
        objOpp1.ContractId = objCon.Id;
        objOpp1.Name = 'Oppo Test';
        objOpp1.StageName = 'New';
        objOpp1.CloseDate = system.today().addMonths(1);
        objOpp1.Broker__c = objAcc.id;
        objOpp1.ContactId = objContact.Id;
        objOpp1.Parent_Opportunity__c = objOpp.Id;
        insert objOpp1;
        
        
        
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
       
        
        SplitOpportunity.getUAOList(objOpp.Id);
        SplitOpportunity.createOpportunity(objAccb1.Id,objOpp.Id,UAOList);
        SplitOpportunity.splitOpptyDetails(objOpp.Id);
        SplitOpportunity.splitOpptyDetails(objOpp1.Id);
        test.stopTest();
    }

}