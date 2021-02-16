public class ExperianBusinessSearchFetcher {
 
     @AuraEnabled 
    public static list<results> makeCallout(Account accRec, Boolean geo, String comment, String txtId){
        system.debug('test Account');
        Experian__c creds = [SELECT Id, Auth_URL__c, Business_Search_URL__c, Auto_Search_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
      
        reqBody body = new reqBody();
        body.name = accRec.Name;
        body.zip = accRec.BillingPostalCode;
        body.street = accRec.BillingStreet;
        body.City = accRec.BillingCity;
        body.State = accRec.BillingState;
        body.phone = String.valueOf(accRec.phone);
        body.geo = True;
        body.taxId = txtId;
        body.comments = comment;
        //body.commercialScore = True;
        body.subcode = String.valueOf(creds.Subcode__c);
        //body.fsrScore = True;
        BusinessParser BusinessParser ;
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Business_Search_URL__c), token, JSON.serialize(body));
        if(response.getStatusCode() == 200){
        
            BusinessParser = (BusinessParser) System.JSON.deserialize(response.getBody(), BusinessParser.class);
            
        }
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Business_Search_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = accRec.Id;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        Insert newIntegrationLog;
        return BusinessParser.results;
    }
    
    @AuraEnabled
    public static void CreateAccount(List<results> AccResult,Account accRec,Id Acccid){
        results results;
        results = AccResult[0];
        RecordType rt = [Select id,Name from RecordType where Name = 'Customer'];
        RecordType rtExp = [Select id,Name from RecordType where Name = 'Experian Business'];
        RecordType rtCredit = [Select id,Name from RecordType where Name = 'Business Owner Profile'];
        Account acc = new Account();
        acc.RecordTypeId = rt.Id;
        acc.Registered_City__c = acc.BillingCity = results.address.city;
        acc.Registered_State_Province__c = acc.BillingState = results.address.state;
        acc.Registered_Street__c = acc.BillingStreet = results.address.street;
        acc.Registered_Zip_Postal_Code__c = acc.BillingPostalCode = results.address.zip;
        acc.Name = results.businessName;
        acc.Phone = results.phone;
        acc.Broker__c = Acccid;
        insert acc;
        
        EXPRN__Experian_Business__c Exp_Business = new EXPRN__Experian_Business__c();
        Exp_Business.Name = results.businessName;
        Exp_Business.EXPRN__BIN__c = results.bin;
        Exp_Business.EXPRN__Exp_Business_Phone_No__c = results.phone;
        Exp_Business.EXPRN__Exp_Street_Address1__c = results.address.street;
        Exp_Business.EXPRN__Exp_City_Name__c = results.address.city;
        Exp_Business.EXPRN__Exp_STATE__c = results.address.state;
        Exp_Business.EXPRN__Exp_ZIP__c = results.address.zip;
        Exp_Business.EXPRN__NumberOfTradeLines__c = String.valueOf(results.numberOfTradelines);
        if(results.matchingNameAndAddress != null){
        Exp_Business.EXPRN__MatchingBusinessName__c = results.matchingNameAndAddress.businessName;
        Exp_Business.EXPRN__MatchingStreetAddress__c = results.matchingNameAndAddress.address.street;
        Exp_Business.EXPRN__MatchingCity__c = results.matchingNameAndAddress.address.city;
        Exp_Business.EXPRN__MatchingState__c =  results.matchingNameAndAddress.address.state;
        Exp_Business.EXPRN__MatchingZip__c  =   results.matchingNameAndAddress.address.zip;
        }
        Exp_Business.RecordTypeId = rtExp.id;
        insert Exp_Business;
        
        EXPRN__Exp_Business_Info__c Exp_BusinessInfo = new EXPRN__Exp_Business_Info__c();
        Exp_BusinessInfo.Name = results.businessName;
        Exp_BusinessInfo.EXPRN__Account_Name__c = acc.Id;
        Exp_BusinessInfo.EXPRN__Exp_Business__c = Exp_Business.Id;
        insert Exp_BusinessInfo;
        
        EXPRN__Credit_Report__c Exp_CreditReport = new EXPRN__Credit_Report__c();
        Exp_CreditReport.Name = results.businessName;
        Exp_CreditReport.EXPRN__Experian_Business__c  = Exp_Business.Id;
        Exp_CreditReport.RecordTypeId = rtCredit.Id;
        Exp_CreditReport.EXPRN__Report_Type__c = 'Business Profile';
        insert Exp_CreditReport;
        System.debug('recordId->'+Acccid);
        Account accCustRec = [SELECT Id,Name,EXPRN__Exp_Business__c FROM Account Where Id =: acc.Id];
        accCustRec.EXPRN__Exp_Business__c = Exp_Business.Id;
        update accCustRec;
        
        
    }
     
    @AuraEnabled
    public static Account initMethod(Id Accid){
        Account acc = [Select id,Name,Phone,BillingPostalCode,BillingStreet,BillingCity,BillingState from Account where id =: Accid];
        acc.Name = '';
        return acc;
    }
    
    
    
    //Wrapper class
    public class BusinessParser{
         @AuraEnabled 
		public Boolean success{get;set;}
         @AuraEnabled 
		public String comments{get;set;}
         @AuraEnabled 
		public list<results> results{get;set;}
         @AuraEnabled 
		public String requestId{get;set;}
    }
	public class results{
         @AuraEnabled 
		public Boolean inquiryIndicator{get;set;}
         @AuraEnabled 
		public Boolean bankDataIndicator{get;set;}
         @AuraEnabled 
		public Boolean keyFactsIndicator{get;set;}
         @AuraEnabled 
		public Boolean governmentDataIndicator{get;set;}
         @AuraEnabled 
		public Boolean financialStatementIndicator{get;set;}
         @AuraEnabled 
		public Boolean executiveSummaryIndicator{get;set;}
         @AuraEnabled 
		public Integer numberOfTradelines{get;set;}
         @AuraEnabled 
		public Boolean uccIndicator{get;set;}
         @AuraEnabled 
		public address address{get;set;}
         @AuraEnabled 
		public matchingNameAndAddress matchingNameAndAddress{get;set;}
         @AuraEnabled 
		public Decimal reliabilityCode{get;set;}
         @AuraEnabled 
		public String businessName{get;set;}
         @AuraEnabled 
		public String bin{get;set;}
         @AuraEnabled 
		public String phone{get;set;}
         @AuraEnabled 
		public businessGeocode businessGeocode{get;set;}
	}
   
	public class businessGeocode{
         @AuraEnabled 
		public Decimal longitude{get;set;}
         @AuraEnabled 
		public String censusTractCode{get;set;}
         @AuraEnabled 
		public String censusBlkGrpCode{get;set;}
         @AuraEnabled 
		public Boolean cottageIndicator{get;set;}
         @AuraEnabled 
		public String msaCode{get;set;}
         @AuraEnabled 
		public String congressionalDistrictCode{get;set;}
         @AuraEnabled 
		public Decimal latitude{get;set;}
         @AuraEnabled 
		public String dateLastReported{get;set;}
         @AuraEnabled 
		public String latitudeLongitudeLevel{get;set;}
	}
	public class address{
         @AuraEnabled 
		public String zipExtension{get;set;}
         @AuraEnabled 
		public String state{get;set;}
         @AuraEnabled 
		public String city{get;set;}
         @AuraEnabled 
		public String zip{get;set;}
         @AuraEnabled 
		public String street{get;set;}
     
	}
    public class reqBody{
         @AuraEnabled 
		public String zip{get;set;}
         @AuraEnabled 
		public String street{get;set;}
         @AuraEnabled 
		public String phone{get;set;}
         @AuraEnabled 
		public String subcode{get;set;}
         @AuraEnabled 
		public String taxId{get;set;}
         @AuraEnabled 
		public String state{get;set;}
         @AuraEnabled 
		public Boolean geo{get;set;}
         @AuraEnabled 
		public String city{get;set;}
         @AuraEnabled 
		public String comments{get;set;}
         @AuraEnabled 
		public String name{get;set;}
      }
    
    public class matchingNameAndAddress{
        @AuraEnabled 
		public address address{get;set;}
        @AuraEnabled 
		public String businessName{get;set;}
	}

}