/*
* @Purpose: Test class to check the Functionality of znalyics API
* @Author: Akanksha Pandharkame
* @CreatedDate: 11/20/2019
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/

@isTest
public class ZnalyticsAPI_Test {
    
    public static testMethod void setupMethod(){
        
        List<Id> enrollmentRecIdVal = new List<Id>();
        
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
        insert objUA;
        
        Enrollment__c objEN = new Enrollment__c();
        objEN.Contract__c = objCon.Id;
        objEn.Account__c = objAcc.Id;
        insert objEN;
        
        Utility_Account_Enrollment__c objUAE = new Utility_Account_Enrollment__c();
        objUAE.Enrollment__c = objEN.Id;
        objUAE.Utility_Account__c = objUA.Id;
        insert objUAE;
        List<Utility_Account_Enrollment__c> selectedUAEs = new List<Utility_Account_Enrollment__c>{objUAE};
        
        Utility_Account_Contract__c objUAC = new Utility_Account_Contract__c();
        objUAC.Utility_Account__c = objUA.Id;
        objUAC.Contract__c = objCon.Id;
        Insert objUAC;
        enrollmentRecIdVal.add(objEN.Id);
        
        //Call to StubDataApiRequest
        //Wrapper_Znalytics_Enrollment 
        //Call HttpCalloutMock
        
        String APIstring = '{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        HttpRequestClassZnalyticsApi obj = new HttpRequestClassZnalyticsApi();
        String responseStr = obj.doPost('POST', APIstring);
        SubmitEnrollment.submitEnrollment(objEN.Id, selectedUAEs);
        SubmitEnrollment.getUAEs(objEN.Id);
        SubmitEnrollment.saveUAE(selectedUAEs);
        SubmitEnrollment.getProgramCodes(objEN.Id, new List<Id>{objUA.Id});
        test.stopTest();
    }
}