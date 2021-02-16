/* 
* @Purpose: This class is used to create Integration Logs for HU API requests.
* @Author: Vishwanath Kodgire
* @CreatedDate: 30/01/2020
* @Related Code: 
* @Test Class: InsertIntegrationLog_Test
* @LastModifiedDate:
* @LastModifiedBy:
*/
public class InsertHUIntegrationLog implements Queueable {
    
    public List<HUDataRequestApi.IntegrationLogData> responseApiRequest;
    //public List<Integer> Code;
    public String pricingReqId;
    public String method;
    
    public InsertHUIntegrationLog(List<HUDataRequestApi.IntegrationLogData> responseApiRequest,String pricingReqId, String method){
        this.responseApiRequest = responseApiRequest;
       
        this.pricingReqId = pricingReqId;
        this.method = method;
    }
    
    //insert Integration log for the enrollment record when API called
    Public void createIntegrationLog(List<HUDataRequestApi.IntegrationLogData> responseApiRequest,String pricingReqId, String method){
        
        //variable declarations
        NamedCredential namedCred;
        String ENId = pricingReqId;
        
        //query the endpoint from the named credentials
       /* namedCred = [SELECT DeveloperName, 
                     Endpoint 
                     FROM NamedCredential
                     WHERE DeveloperName =:'HU API'];*/
        
        // query the enrollment record to update Submit_Enrollment__c field
        
        //create new instance of the Integration Log
        //Integration_Log__c newIntegrationLog = new Integration_Log__c();
        List<Integration_Log__c> newIntegrationLogLst = new List<Integration_Log__c>();
        
        //newIntegrationLog.EndPointURL__c = System.Label.HU_Endpoint_Test;
        
        for(HUDataRequestApi.IntegrationLogData responseObj : responseApiRequest ){
            Integration_Log__c newIntegrationLog = new Integration_Log__c();
            newIntegrationLog.Response_Body__c = responseObj.responsebody;
            newIntegrationLog.Status_Code__c = responseObj.Code;
            newIntegrationLog.EndPointURL__c = responseObj.Endpoint;
            newIntegrationLog.Request_Type__c = method;
            newIntegrationLog.Pricing_Request__c = ENId;
     
          
        
        //check response code is success or fail and according to the code update the value of status field of integration log
        if(responseObj.Code == 200){
            newIntegrationLog.Status__c = 'OK';
        }else if(responseObj.Code == 400){
            newIntegrationLog.Status__c = 'Bad Request';
        }
        system.debug('newIntegrationLog' + newIntegrationLog);
        newIntegrationLogLst.add(newIntegrationLog);
        }
        insert newIntegrationLogLst;
    }
    
    public void execute(QueueableContext context) { 
        createIntegrationLog(responseApiRequest,pricingReqId,method);
    }
}