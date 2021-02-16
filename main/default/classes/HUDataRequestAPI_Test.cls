@isTest
public class HUDataRequestAPI_Test {
    
    public static testMethod void setupMethod(){
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = true;
        huObj.Call_Azure__c = true;
        insert huObj;
        
        /*Experian__c expObj = new Experian__c();
         expObj.Auth_Body__c = 'a';
            expObj.Auth_URL__c ='b';
        expObj.Auto_Search_URL__c='a';
        expObj.Subcode__c = 01;
        insert expObj;*/
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
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
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
        objPR.Opportunity__c = objOpp.Id;
        Insert objPR;
        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;
        objUAP.Start_Date__c = system.today();
		Insert objUAP;  
        
        List<Id> prIds = new List<Id>();
        prIds.add(objPR.Id);
        
        //Call HttpCalloutMock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        test.startTest();
        HUDataRequestAPI.CallMakeCallout(prIds);
        test.stopTest();
    }

}