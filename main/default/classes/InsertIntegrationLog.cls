/* 
* @Purpose: This class is created to execute DML operations for StubDataApiRequest class as DML is not allowed execute within API callouts
* @Author: Akanksha Pandharkame
* @CreatedDate: 12/03/2019
* @Related Code: 
* @Test Class: InsertIntegrationLog_Test
* @LastModifiedDate:
* @LastModifiedBy:
*/
public class InsertIntegrationLog implements Queueable {
    
    public string responseApiRequest;
    public Integer Code;
    public String enrollmentId;
    public String method;
    public List<Utility_Account_Enrollment__c> sentUAEs;
    
    public InsertIntegrationLog(String responseApiRequest, Integer Code, String enrollmentId, String method,  List<Utility_Account_Enrollment__c> sentUAEs){
        this.responseApiRequest = responseApiRequest;
        this.Code =Code; 
        this.enrollmentId = enrollmentId;
        this.method = method;
        this.sentUAEs = sentUAEs;
    }
    
    //insert Integration log for the enrollment record when API called
    Public void createIntegrationLog(String responseApiRequest, Integer Code, String enrollmentId, String method, List<Utility_Account_Enrollment__c> sentUAEs){
        
        //variable declarations
        NamedCredential namedCred;
        String ENId = enrollmentId;
        
        //query the endpoint from the named credentials
        namedCred = [SELECT DeveloperName, 
                     Endpoint 
                     FROM NamedCredential
                     WHERE DeveloperName =:'Znalytics'];
        
        // query the enrollment record to update Submit_Enrollment__c field
        List<Enrollment__c> enrollmentList = [SELECT Id, Account__r.ZN_CustomerId__c, Contract__c, Submit_Enrollment__c, Stage__c 
                                              FROM Enrollment__c 
                                              WHERE Id =: enrollmentId];
        
        //create new instance of the Integration Log
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = namedCred.Endpoint;
        newIntegrationLog.Request_Type__c = method;
        newIntegrationLog.Enrollment__c = ENId;
        newIntegrationLog.Response_Body__c = responseApiRequest;
        newIntegrationLog.Status_Code__c = Code;
        
        //check response code is success or fail and according to the code update the value of status field of integration log
        
       
        for(Utility_Account_Enrollment__c uae: sentUAEs){
            if(code == 200){
                uae.Status__c = 'Enrollment Request Accepted';
            }
            else
                uae.Status__c = 'Enrollment Request Failed';
        }
        update sentUAEs;
        Boolean allAccepted = false;
        Boolean allFailed = false;
        
        List<Utility_Account_Enrollment__c> updatedUAES = [SELECT Id, Status__c FROM Utility_Account_Enrollment__c WHERE Enrollment__c =: enrollmentId];
        
        for(Utility_Account_Enrollment__c uae: updatedUAES){
            if(uae.status__c == 'Enrollment Request Accepted' )
                allAccepted = true;
            else
                allAccepted = false;
        }
        if(allAccepted){
            EnrollmentList[0].Stage__c = 'Complete';
        }
        else 
            EnrollmentList[0].Stage__c = 'In Progress';
        
        if(Code == 200){
            newIntegrationLog.Status__c = 'OK';
        }else if(Code == 400){
            newIntegrationLog.Status__c = 'Bad Request';
        }
        insert newIntegrationLog;
        
        String contractId = enrollmentList[0].Contract__c;
        if(Code != 400){
            ZnResponseWrapper ZNR = (ZnResponseWrapper)JSON.deserialize(responseApiRequest, ZnResponseWrapper.class); 
            if(ZNR.model.enrollmentResultDetailList != NULL){
                List<ZnResponseWrapper.enrollmentResultDetailList> responseEnrollmentList = new List<ZnResponseWrapper.enrollmentResultDetailList>();
                responseEnrollmentList = ZNR.model.enrollmentResultDetailList;
                List<Utility_Account_Contract__c> UACList = [SELECT id, Utility_Account__r.Name, Utility_Account__r.EOS_BillingAccountNumber__c, Utility_Account__r.EOS_BillingAccountId__c, EOS_BillingAccountNumber__c, EOS_ServiceAccountId__c, EOS_BillingAccountId__c, Utility_Account__r.EOS_ServiceAccountId__c FROM Utility_Account_Contract__c WHERE Contract__c = : contractId ];
                List<Utility_Account__c> UAToUpdate = new List<Utility_Account__c>();
                for(ZnResponseWrapper.enrollmentResultDetailList zne: responseEnrollmentList ){
                    for(Utility_Account_Contract__c UAC: UACList){
                        if(UAC.Utility_Account__r.Name == zne.utilityAccountNumber){
                            UAC.EOS_BillingAccountId__c = String.valueOf(zne.billingAccountId);
                            UAC.Utility_Account__r.EOS_BillingAccountId__c = String.valueOf(zne.billingAccountId);
                            UAC.EOS_BillingAccountNumber__c = String.valueOf(zne.billingAccountNumber);
                            UAC.Utility_Account__r.EOS_BillingAccountNumber__c = String.valueOf(zne.billingAccountNumber);
                            UAC.EOS_ServiceAccountId__c = String.valueOf(zne.serviceAccountId);
                            UAC.Utility_Account__r.EOS_ServiceAccountId__c = String.valueOf(zne.serviceAccountId);
                            if(!UAToUpdate.contains(UAC.Utility_Account__r))
                                UAToUpdate.add(UAC.Utility_Account__r);
                        }
                    }
                }
                Account EAccount = [SELECT Id, ZN_CustomerId__c, EOS_CustomerNumber__c FROM Account WHERE Id =: enrollmentList[0].Account__c ];
                EAccount.ZN_CustomerId__c = String.valueOf(responseEnrollmentList[0].customerId);
                EAccount.EOS_CustomerNumber__c = String.valueOf(responseEnrollmentList[0].customerNumber);
                update EAccount;
                update UACList;
                update UAToUpdate;
            }
        }
        enrollmentList[0].Submit_Enrollment__c = false;
        update enrollmentList;
    }
    
    public void execute(QueueableContext context) { 
        createIntegrationLog(responseApiRequest,Code,enrollmentId,method,sentUAEs);
    }
}