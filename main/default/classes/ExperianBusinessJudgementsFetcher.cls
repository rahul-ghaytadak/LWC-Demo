public class ExperianBusinessJudgementsFetcher {
    
    @invocableMethod
    public static void getBusinessFacts(List<Id> AccId){
        makeCallout(AccId[0]);
    }
    
    @future(callout=true)
    public static void makeCallout(Id acctId){
        
        Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: acctId ];
        
        EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ];
        
        Experian__c creds = [SELECT Id, Auth_URL__c,Judgments_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
      
        reqBody body = new reqBody();
        
        body.bin = expBusiness.EXPRN__BIN__c;
        body.subcode = String.valueOf(creds.Subcode__c);
        body.judgmentSummary = true;
        body.judgmentDetail = true;
       
        ResponseWrapper ResponseWrapper ;
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Judgments_URL__c), token, JSON.serialize(body));
        if(response.getStatusCode() == 200){
        
            ResponseWrapper = (ResponseWrapper) System.JSON.deserialize(response.getBody(), ResponseWrapper.class);
            
        }
        results results = ResponseWrapper.results;
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id FROM EXPRN__Exp_Business_Info__c Where EXPRN__Account_Name__c =: acctId];
        expBusinessInfo.EXPRN__Experian_No_Judgments__c = String.valueOf(results.judgmentSummary.judgmentCount);
        expBusinessInfo.EXPRN__Experian_Judgment_Bal__c = String.valueOf(results.judgmentSummary.judgmentBalance);
        update expBusinessInfo;
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Judgments_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = acctId;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        Insert newIntegrationLog;
    }
 
 
    
    //Request Wrapper class
    public class reqBody{
		public String bin{get;set;}
		public String subcode{get;set;}
        public Boolean judgmentSummary{get;set;}
        public Boolean judgmentDetail{get;set;}
    }
    
    //Response Wrapper class
    public class ResponseWrapper{
		public Boolean success{get;set;}
		public results results{get;set;}
		public String requestId{get;set;}
    }
	public class results{
		public judgmentSummary judgmentSummary{get;set;}
		public list<judgmentDetail> judgmentDetail{get;set;}
		public businessHeader businessHeader{get;set;}
	}
	public class judgmentSummary{
		public Integer judgmentBalance{get;set;}
		public Integer judgmentCount{get;set;}
	}
	public class judgmentDetail{
		public String legalAction{get;set;}
		public String filingLocation{get;set;}
		public String documentNumber{get;set;}
		public String owner{get;set;}
		public String legalType{get;set;}
		public Integer liabilityAmount{get;set;}
		public String dateFiled{get;set;}
		public String plaintiffName{get;set;}
	}
	public class businessHeader{
		public Boolean customerDisputeIndicator{get;set;}
		public String taxId{get;set;}
		public String phone{get;set;}
		public String websiteUrl{get;set;}
		public address address{get;set;}
		public String legalBusinessName{get;set;}
		public String businessName{get;set;}
		public list<String> dbaNames{get;set;}
		public String bin{get;set;}
	}
	public class address{
		public String zipExtension{get;set;}
		public String state{get;set;}
		public String city{get;set;}
		public String zip{get;set;}
		public String street{get;set;}
	}



}