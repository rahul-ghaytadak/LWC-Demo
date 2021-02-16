public class ExperianFraudShieldsFetcher {
    
    @invocableMethod
    public static void getBusinessFacts(List<Id> AccId){
        makeCallout(AccId[0]);
    }
    
    @future(callout=true)
    public static void makeCallout(Id acctId){
        
        Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: acctId ];
        
        EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ];
        
        
        Experian__c creds = [SELECT Id, Auth_URL__c,Fraud_Shields_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
      
        reqBody body = new reqBody();
        
        body.bin = expBusiness.EXPRN__BIN__c;
        body.subcode = String.valueOf(creds.Subcode__c);
       
        ResponseWrapper ResponseWrapper ;
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Fraud_Shields_URL__c), token, JSON.serialize(body));
        if(response.getStatusCode() == 200){
        
            ResponseWrapper = (ResponseWrapper) System.JSON.deserialize(response.getBody(), ResponseWrapper.class);
            
        }
        System.debug('Response - >'+ResponseWrapper.results);
        results results = ResponseWrapper.results;
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id FROM EXPRN__Exp_Business_Info__c Where EXPRN__Account_Name__c =: acctId];
        expBusinessInfo.EXPRN__Active_Business_Indicator__c = results.activeBusinessIndicator;
        if(results.businessVictimStatementIndicator == true){
            expBusinessInfo.EXPRN__Business_Victim_Statement__c = 'Yes';
        }
        expBusinessInfo.EXPRN__Verification_Triggers__c = results.businessRiskTriggersStatement;
        update expBusinessInfo;
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Fraud_Shields_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = acctId;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        Insert newIntegrationLog;
    }
 
 
    
    //Request Wrapper class
    public class reqBody{
         @AuraEnabled 
		public String bin{get;set;}
         @AuraEnabled 
		public String subcode{get;set;}
    }
    
    //Response Wrapper class
    public class ResponseWrapper{
		public Boolean success{get;set;}
		public results results{get;set;}
		public String requestId{get;set;}
    }
	public class results{
		public Boolean businessVictimStatementIndicator{get;set;}
		public ofacMatchWarning ofacMatchWarning{get;set;}
		public Boolean businessRiskTriggersIndicator{get;set;}
		public Boolean activeBusinessIndicator{get;set;}
		public String businessRiskTriggersStatement{get;set;}
		public String matchingBusinessAddress{get;set;}
		public Boolean nameAddressVerificationIndicator{get;set;}
		public String bin{get;set;}
	}
	public class ofacMatchWarning{
		public String detailStatement{get;set;}
		public Integer code{get;set;}
		public String definition{get;set;}
	}



}