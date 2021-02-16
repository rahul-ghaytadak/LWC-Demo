public class ExperianLegalFilingSummariesFetcher {
    
    @invocableMethod
    public static void getBusinessFacts(List<Id> AccId){
        makeCallout(AccId[0]);
    }
    
    @future(callout=true)
    public static void makeCallout(Id acctId){
        
        Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: acctId ];
        
        EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ];
        
        Experian__c creds = [SELECT Id, Auth_URL__c,Legal_Filings_Summary_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
      
        reqBody body = new reqBody();
        
        body.bin = expBusiness.EXPRN__BIN__c;
        body.subcode = String.valueOf(creds.Subcode__c);
        body.legalFilingsCollectionsSummary = true;
        body.legalFilingsSummary = true;
       
        ResponseWrapper ResponseWrapper ;
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Legal_Filings_Summary_URL__c), token, JSON.serialize(body));
        if(response.getStatusCode() == 200){
        
            ResponseWrapper = (ResponseWrapper) System.JSON.deserialize(response.getBody(), ResponseWrapper.class);
            
        }
        System.debug('Response - >'+ResponseWrapper.results);
        results results = ResponseWrapper.results;
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id FROM EXPRN__Exp_Business_Info__c Where EXPRN__Account_Name__c =: acctId];
        expBusinessInfo.EXPRN__Tax_Lien_filings__c = String.valueOf(results.legalFilingsCollectionsSummary.lienCount);
        expBusinessInfo.EXPRN__Judgment_filings__c	 = String.valueOf(results.legalFilingsCollectionsSummary.judgmentCount);
        update expBusinessInfo;
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Legal_Filings_Summary_URL__c);
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
        public Boolean legalFilingsCollectionsSummary{get;set;}
        public Boolean legalFilingsSummary{get;set;}
    }
    
    //Response Wrapper class
    public class ResponseWrapper{
		public Boolean success{get;set;}
		public results results{get;set;}
		public String requestId{get;set;}
        }
	public class results{
		public legalFilingsSummary legalFilingsSummary{get;set;}
		public legalFilingsCollectionsSummary legalFilingsCollectionsSummary{get;set;}
		public businessHeader businessHeader{get;set;}
	}
	public class legalFilingsSummary{
		public Integer legalBalance{get;set;}
		public Integer legalCount{get;set;}
		public Integer derogatoryLegalCount{get;set;}
	}
	public class legalFilingsCollectionsSummary{
		public Integer lienCount{get;set;}
		public Integer lienBalance{get;set;}
		public Integer judgmentCount{get;set;}
		public Integer bankruptcyCount{get;set;}
		public Integer judgmentBalance{get;set;}
		public Boolean bankruptcyIndicator{get;set;}
		public Integer uccFilingsCount{get;set;}
		public Integer derogatoryLegalCount{get;set;}
		public Integer uccDerogatoryCount{get;set;}
		public Integer legalBalance{get;set;}
		public Integer collectionCount{get;set;}
		public Integer legalCount{get;set;}
		public Integer collectionBalance{get;set;}
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