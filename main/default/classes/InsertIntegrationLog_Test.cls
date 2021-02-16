/* 
* @Purpose: Test Class for InsertIntegrationLog
* @Author: Akanksha Pandharkame
* @CreatedDate: 12/04/2019
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/
@isTest
public class InsertIntegrationLog_Test {
    
    static testmethod void testIntegrationLog(){
        
        Account acc = new Account(NAme='test');
        Insert acc;
        
        Enrollment__c objEn = new Enrollment__c();
        objEn.Account__c = acc.Id;
        insert objEn;
        
        List<Utility_Account_Enrollment__c> uaeList = new List<Utility_Account_Enrollment__c>();
        
        String enId = objEn.Id;
        String response = '{"model":{"requestGuid":"b3ad8e43-be7e-4e1d-a190-81ec4651b109","isSucess":true,"enrollmentResultDetailList":[{"isSuccess":true,"customerId":398,"billingAccountId":434,"serviceAccountId":484,"customerProspectId":0,"billingAccountReferenceId":10001,"serviceAccountReferenceId":10001,"linkToBillingAccountNumber":"","enrollmentRequestDetailId":254,"customerNumber":"20-1000177","billingAccountNumber":"30-100000819","utilityAccountNumber":"1234567890"}],"enrollmentWarningList":null},"code":200,"messages":null}';
        
        InsertIntegrationLog objIntLog = new InsertIntegrationLog(response, 200, enId, 'POST', uaeList);
         ID jobID = System.enqueueJob(objIntLog);
        
        InsertIntegrationLog objIntLog2 = new InsertIntegrationLog(response, 400, enId, 'POST', uaeList);
        ID jobID2 = System.enqueueJob(objIntLog2);
        
    }
}