/*
* @Purpose: Test class for UA contract End date updation.
* @Author: Rahul Ghaytadak
* @CreatedDate: 
* @Related Code: Trigger_UpdateContractEndDate,Trigger_UpdateContractEndDate,UpdateContractEndDate_UA
* @Test Class: 
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
@isTest
public class Update_contractEndDate_Test {
    public static testMethod void setupMethod(){
        List<Contract> contList = new List<Contract>();
        List<Id> UA_List = new List<Id>();
        
        Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today();
        objCon.AccountId = objAcc.Id;
        objCon.Status = 'Pending_Live';
        contList.add(objCon);
        insert contList;
        
        contList[0].Status = 'Live';
        update contList;
        
        Opportunity objOpp = new Opportunity();
        objOpp.State__c = 'NY';
        objOpp.AccountId = objAcc.Id;
        objOpp.ContractId = contList[0].Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
       // objOpp.ContactId = objContact.Id;
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
        UA_List.add(objUA.Id);
        
        
        Utility_Account_Contract__c uac = new Utility_Account_Contract__c();
        uac.Utility_Account__c = objUA.Id;
        uac.Contract__c = contList[0].Id;
        insert uac;
        
        test.startTest();
        UpdateContractEndDate_UA.updateContractEndDate(UA_List);
        Trigger_UpdateContractEndDateHandler.updateContractEndDate(contList);
        delete objCon;
        
        test.stopTest();
    }
}