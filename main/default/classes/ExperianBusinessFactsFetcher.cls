public class ExperianBusinessFactsFetcher {
    
    @invocableMethod
    public static void getBusinessFacts(List<Id> AccId){
        makeCallout(AccId[0]);
    }
    
    @future(callout=true)
    public static void makeCallout(Id acctId){
        Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: acctId ];
        
        EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ];
        
        system.debug('test Account');
        Experian__c creds = [SELECT Id, Auth_URL__c,Business_Facts_URL__c, Business_Search_URL__c, Auto_Search_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
      
        reqBody body = new reqBody();
        
        body.bin = expBusiness.EXPRN__BIN__c;
        body.subcode = String.valueOf(creds.Subcode__c);
       
        ResponseWrapper ResponseWrapper ;
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Business_Facts_URL__c), token, JSON.serialize(body));
        if(response.getStatusCode() == 200){
        
            ResponseWrapper = (ResponseWrapper) System.JSON.deserialize(response.getBody(), ResponseWrapper.class);
            
        }
        System.debug('Response - >'+ResponseWrapper.results);
        results results = ResponseWrapper.results;
        
        EXPRN__Exp_Business_Info__c expBusinessInfo = [SELECT Id FROM EXPRN__Exp_Business_Info__c Where EXPRN__Account_Name__c =: acctId];
        expBusinessInfo.EXPRN__Experian_Website__c = results.businessHeader.websiteUrl;
        expBusinessInfo.EXPRN__Stock_Exchange_Symbol__c = results.stockExchange;
        expBusinessInfo.EXPRN__Years_on_File__c = String.valueOf(results.yearsOnFile);
        expBusinessInfo.EXPRN__State_Of_Incorporation__c = results.stateOfIncorporation;
        expBusinessInfo.EXPRN__Date_of_Incorporation__c = results.dateOfIncorporation;
        expBusinessInfo.EXPRN__Business_Type__c = results.businessType;
        expBusinessInfo.EXPRN__Number_of_Employees__c = String.valueOf(results.employeeSize);
        expBusinessInfo.EXPRN__SIC_Code__c = results.sicCodes[0].code;
        expBusinessInfo.EXPRN__NAICS_Code__c = results.naicsCodes[0].code;
        expBusinessInfo.EXPRN__Fortune_1000_Ranking__c = String.valueOf(results.fortune1000.rank);
        update expBusinessInfo;
        
        expBusiness.EXPRN__Exp_Business_Phone_No__c	= results.businessHeader.phone;
        expBusiness.EXPRN__Exp_Tax_ID__c = results.businessHeader.taxId;
        update expBusiness;    
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Business_Facts_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = acctId;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        Insert newIntegrationLog;
        
      //  return ResponseWrapper.results;
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
	public class sicCodes{
		public String definition{get;set;}
		public String code{get;set;}
	}
	public class results{
		public list<naicsCodes> naicsCodes{get;set;}
		public String tickerSymbol{get;set;}
		public Boolean publicIndicator{get;set;}
		public String stockExchange{get;set;}
		public Integer employeeSize{get;set;}
		public String businessType{get;set;}
		public String employeeSizeCode{get;set;}
		public String dateOfIncorporation{get;set;}
		public Integer salesRevenue{get;set;}
		public String stateOfIncorporation{get;set;}
		public String salesSizeCode{get;set;}
		public Integer yearsOnFile{get;set;}
		public fortune1000 fortune1000{get;set;}
		public Boolean nonProfitIndicator{get;set;}
		public String corporateLinkageType{get;set;}
		public list<sicCodes> sicCodes{get;set;}
		public list<executiveInformation> executiveInformation{get;set;}
		public businessHeader businessHeader{get;set;}
	}
	public class naicsCodes{
		public String definition{get;set;}
		public String code{get;set;}
	}
	public class fortune1000{
		public Integer year{get;set;}
		public Integer rank{get;set;}
	}
	public class executiveInformation{
		public String firstName{get;set;}
		public String lastName{get;set;}
		public String title{get;set;}
		public String middleName{get;set;}
	}
	public class businessHeader{
		public String websiteUrl{get;set;}
		public String taxId{get;set;}
		public String phone{get;set;}
		public String legalBusinessName{get;set;}
		public address address{get;set;}
		public list<String> dbaNames{get;set;}
		public String businessName{get;set;}
		public Boolean customerDisputeIndicator{get;set;}
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