public class HUDataRequestAPI {
    
    @invocableMethod(Label='Send_To_HU')
    public static void CallMakeCallout(List<Id> prIds){
    
        for(Id prId:prIds ){
            makeCallout( new List<Id>{prId})  ;  
            makeCalloutAzure( new List<Id>{prId});
        }
    }
    
    @future(callout=true)
    public static void makeCallout(List<Id> prIds){
        system.debug('prIds' + prIds);
        List<Utility_Account_Pricing__c> UAPList = [SELECT Id,
                                                    Name,
                                                    Pricing_Request__r.Name,
                                                    Pricing_Request__r.Bill_Type__c,
                                                    Pricing_Request__r.Opportunity__r.AccountId,
                                                    Pricing_Request__r.Opportunity__r.Commodity__c,
                                                    Pricing_Request__r.Opportunity__r.Account.Name,
                                                    Pricing_Request__r.Opportunity__r.Account.BillingStreet,
                                                    Pricing_Request__r.Opportunity__r.Account.BillingCity,
                                                    Pricing_Request__r.Opportunity__r.Account.BillingState,
                                                    Pricing_Request__r.Opportunity__r.Account.BillingPostalCode,
                                                    Utility_Account__r.utility__r.Utility_DUNS__c,
                                                    Utility_Account__r.Name,
                                                    Credit_Check_Required__c
                                                    FROM Utility_Account_Pricing__c
                                                    WHERE Pricing_Request__c IN : prIds];
        Set<Id> utilitySet = new Set<Id>();
        for(Utility_Account_Pricing__c UAP : UAPList )
            utilitySet.add(UAP.Utility_Account__r.Utility__c);
        List<Account> utilityList = [SELECT id, Credit_Check_Required__c, Historical_Usage_Request_Type__c, Supplier_DUNS_Suffix__c, Utility_DUNS__c,Marketer_Code__c FROM Account WHERE id in: utilitySet ];
        String oppId = [SELECT Id, Opportunity__c FROM Pricing_Request__c WHERE ID IN: prIds LIMIT 1].Opportunity__c;
        List<Credit_Check__c> activeCCRecords = [SELECT Id FROM Credit_Check__c WHERE Opportunity__c =: oppId AND Status__c = 'Active'];
        List<huRequestData> huRequestDataList = new List<huRequestData>();
        if(!utilityList.isEmpty()){
            for(Account utility : utilityList){
                huRequestData buildData = new huRequestData();
                buildData.ServiceTypeCode = 'E';
                buildData.ExternalId = EncodingUtil.urlEncode(UAPList[0].Pricing_Request__r.Name + '|' + prIds[0] + '|'+ UAPList[0].Pricing_Request__r.Opportunity__r.AccountId,'UTF-8').replace('%7C','|');
                List<String> UANumbers = new List<String>();
                for(Utility_Account_Pricing__c UAP : UAPList ){
                    if(UAP.Utility_Account__r.Utility__c == utility.Id)
                        UANumbers.add(UAP.Utility_Account__r.Name);
                }
               /* if(!activeCCRecords.isEmpty())
                    buildData.CreditRiskExposureRequired = '0';
                else if(UAPList[0].Pricing_Request__r.Bill_Type__c == 'Dual')
                    buildData.CreditRiskExposureRequired = '1';
                else{
                    if(utility.Credit_Check_Required__c)
                        buildData.CreditRiskExposureRequired = '1';
                    else
                        buildData.CreditRiskExposureRequired = '0';
                }*/
                buildData.CreditRiskExposureRequired = '0';
                buildData.UtilityAccountNumber = string.join(UANumbers,',');
                buildData.Source = 'Salesforce';
                buildData.UtilityDUNS = new List<String>{utility.Utility_DUNS__c};
                buildData.AccountName = UAPList[0].Pricing_Request__r.Opportunity__r.Account.Name;
                if(utility.Supplier_DUNS_Suffix__c!= Null){
                    buildData.SupplierDUNS = '117066176'+utility.Supplier_DUNS_Suffix__c;
       
                }
                else{
                    buildData.SupplierDUNS = '117066176';
                  
                }
                if(UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingStreet != Null)
                    buildData.ServiceAddress1 = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingStreet;
                else
                    buildData.ServiceAddress1 = '';
                buildData.ServiceAddress2 = '';
                if(UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingCity != Null)
                    buildData.ServiceCity = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingCity;
                else
                    buildData.ServiceCity = '';
                // buildData.ServiceCity = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingCity;
                if(UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingState != Null)
                    buildData.ServiceStateCode = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingState;
                else
                    buildData.ServiceStateCode = '';
                
                buildData.stateCode = '';
                buildData.IsUnmetered = '';
                buildData.HistoricalUsageRequestType = utility.Historical_Usage_Request_Type__c;
                buildData.ScraperType = '2';
                String Marketer_Code = '';
                if(utility.Marketer_Code__c!=null){
                    Marketer_Code = utility.Marketer_Code__c;
                }
                buildData.MarketerCode = Marketer_Code;

             if(UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingPostalCode != Null)
                buildData.ServiceZip = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingPostalCode;
            else
                buildData.ServiceZip = '';
                huRequestDataList.add(buildData);
            }
            requestBody reqBody = new requestBody();
            reqBody.huRequestData = huRequestDataList;
            reqBody.UserId = '14';
            //Create new Http Request
            List<IntegrationLogData> responseApiRequestLst = new List<IntegrationLogData>();
            HU_Api_Call__c HuApi = [Select Call_AWS__c,Call_Azure__c from HU_Api_Call__c limit 1];
            
            System.debug(HuApi.Call_Azure__c);
            if(HuApi.Call_AWS__c == true){
                System.debug('-AWS-');
            IntegrationLogData responseApiRequest = new IntegrationLogData();    
            Http newHttp = new Http();
            HttpRequest newHttpRequest = new HttpRequest();
            //set the paramter for the api Request
            newHttpRequest.setTimeout(60000);                 
            newHttpRequest.setMethod('POST');   
            newHttpRequest.setHeader('X-Api-key', System.Label.Hu_API_Key);
            newHttpRequest.setHeader('Content-type','application/json');
            newHttpRequest.setHeader('Content-type','application/json');
            newHttpRequest.setEndpoint(System.Label.HU_Endpoint_Test);
            //newHttpRequest.setHeader('api_key','{!$Credential.Password}');
            newHttpRequest.setBody(JSON.serialize(reqBody));
            system.debug('buildData' + JSON.serialize(reqBody));
            HttpResponse newHttpResponse = newHttp.send(newHttpRequest);
            responseApiRequest.responsebody = newHttpResponse.getBody();
            responseApiRequest.Code = newHttpResponse.getStatusCode();
            responseApiRequest.Endpoint = System.Label.HU_Endpoint_Test;    
            responseApiRequestLst.add(responseApiRequest);    
            //InsertHUIntegrationLog intog = new InsertHUIntegrationLog( newHttpResponse.getBody(), newHttpResponse.getStatusCode(), prIds[0] , 'POST'); 
            //System.enqueueJob(intog);
            }
            
            
            
            
            InsertHUIntegrationLog intog = new InsertHUIntegrationLog( responseApiRequestLst, prIds[0] , 'POST');
            System.enqueueJob(intog);
        }
    }
    
    @future(callout=true)
    public static void makeCalloutAzure(List<Id> prIds){
        system.debug('prIds' + prIds);
        List<Utility_Account_Pricing__c> UAPList = [SELECT Id,
                                                    Name,
                                                    Pricing_Request__r.Name,
                                                    Pricing_Request__r.Bill_Type__c,
                                                    Pricing_Request__r.Opportunity__r.AccountId,
                                                    Pricing_Request__r.Opportunity__r.Commodity__c,
                                                    Pricing_Request__r.Opportunity__r.Account.Name,
                                                    Pricing_Request__r.Opportunity__r.Account.BillingStreet,
                                                    Pricing_Request__r.Opportunity__r.Account.BillingCity,
                                                    Pricing_Request__r.Opportunity__r.Account.BillingState,
                                                    Pricing_Request__r.Opportunity__r.Account.BillingPostalCode,
                                                    Utility_Account__r.utility__r.Utility_DUNS__c,
                                                    Utility_Account__r.Name,
                                                    Credit_Check_Required__c
                                                    FROM Utility_Account_Pricing__c
                                                    WHERE Pricing_Request__c IN : prIds];
        Set<Id> utilitySet = new Set<Id>();
        for(Utility_Account_Pricing__c UAP : UAPList )
            utilitySet.add(UAP.Utility_Account__r.Utility__c);
        List<Account> utilityList = [SELECT id, Credit_Check_Required__c, Historical_Usage_Request_Type__c, Supplier_DUNS_Suffix__c, Utility_DUNS__c,Marketer_Code__c FROM Account WHERE id in: utilitySet ];
        String oppId = [SELECT Id, Opportunity__c FROM Pricing_Request__c WHERE ID IN: prIds LIMIT 1].Opportunity__c;
        List<Credit_Check__c> activeCCRecords = [SELECT Id FROM Credit_Check__c WHERE Opportunity__c =: oppId AND Status__c = 'Active'];
        List<huRequestData> huRequestDataList = new List<huRequestData>();
        if(!utilityList.isEmpty()){
            for(Account utility : utilityList){
                huRequestData buildData = new huRequestData();
                buildData.ServiceTypeCode = 'E';
                buildData.ExternalId = EncodingUtil.urlEncode(UAPList[0].Pricing_Request__r.Name + '|' + prIds[0] + '|'+ UAPList[0].Pricing_Request__r.Opportunity__r.AccountId,'UTF-8').replace('%7C','|');
                List<String> UANumbers = new List<String>();
                for(Utility_Account_Pricing__c UAP : UAPList ){
                    if(UAP.Utility_Account__r.Utility__c == utility.Id)
                        UANumbers.add(UAP.Utility_Account__r.Name);
                }
                /*if(!activeCCRecords.isEmpty())
                    buildData.CreditRiskExposureRequired = '0';
                else if(UAPList[0].Pricing_Request__r.Bill_Type__c == 'Dual')
                    buildData.CreditRiskExposureRequired = '1';
                else{
                    if(utility.Credit_Check_Required__c)
                        buildData.CreditRiskExposureRequired = '1';
                    else
                        buildData.CreditRiskExposureRequired = '0';
                }*/
                buildData.CreditRiskExposureRequired = '0';
                buildData.UtilityAccountNumber = string.join(UANumbers,',');
                buildData.Source = 'Salesforce';
                buildData.UtilityDUNS = new List<String>{utility.Utility_DUNS__c};
                buildData.AccountName = UAPList[0].Pricing_Request__r.Opportunity__r.Account.Name;
                if(utility.Supplier_DUNS_Suffix__c!= Null){
                    buildData.SupplierDUNS = '117066176'+utility.Supplier_DUNS_Suffix__c;
                }
                else{
                    buildData.SupplierDUNS = '117066176';
                }
                if(UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingStreet != Null)
                    buildData.ServiceAddress1 = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingStreet;
                else
                    buildData.ServiceAddress1 = '';
                buildData.ServiceAddress2 = '';
                if(UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingCity != Null)
                    buildData.ServiceCity = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingCity;
                else
                    buildData.ServiceCity = '';
                // buildData.ServiceCity = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingCity;
                if(UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingState != Null)
                    buildData.ServiceStateCode = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingState;
                else
                    buildData.ServiceStateCode = '';
                
                buildData.stateCode = '';
                buildData.IsUnmetered = '';
                buildData.HistoricalUsageRequestType = utility.Historical_Usage_Request_Type__c;
                buildData.ScraperType = '2';
                String Marketer_Code = '';
                if(utility.Marketer_Code__c!=null){
                    Marketer_Code = utility.Marketer_Code__c;
                }
                buildData.MarketerCode = Marketer_Code;

             if(UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingPostalCode != Null)
                buildData.ServiceZip = UAPList[0].Pricing_Request__r.Opportunity__r.Account.BillingPostalCode;
            else
                buildData.ServiceZip = '';
                huRequestDataList.add(buildData);
            }
            requestBody reqBody = new requestBody();
            reqBody.huRequestData = huRequestDataList;
            reqBody.UserId = '14';
            //Create new Http Request
            List<IntegrationLogData> responseApiRequestLst = new List<IntegrationLogData>();
            HU_Api_Call__c HuApi = [Select Call_AWS__c,Call_Azure__c from HU_Api_Call__c limit 1];
            
            System.debug(HuApi.Call_Azure__c);
            //Azure Api Call
            
            if(HuApi.Call_Azure__c == true){
            System.debug('-Azure-');  
            IntegrationLogData responseApiRequest = new IntegrationLogData();    
            Http newHttp = new Http();
            HttpRequest newHttpRequest = new HttpRequest();
            //set the paramter for the api Request
            newHttpRequest.setTimeout(60000);                 
            newHttpRequest.setMethod('POST');   
            newHttpRequest.setHeader('x-functions-key', System.Label.HU_Azure_Api_Key);
            newHttpRequest.setHeader('Content-type','application/json');
            newHttpRequest.setHeader('Content-type','application/json');
            newHttpRequest.setEndpoint(System.Label.HU_Azure_Endpoint);
            //newHttpRequest.setHeader('api_key','{!$Credential.Password}');
            newHttpRequest.setBody(JSON.serialize(reqBody));
            system.debug('buildData' + JSON.serialize(reqBody));
                HttpResponse newHttpResponse;
                try{
             newHttpResponse = newHttp.send(newHttpRequest);
                }catch(Exception e){
                    System.debug('Exception'+e.getMessage());
                     newHttpResponse = newHttp.send(newHttpRequest);
                }
            //InsertHUIntegrationLog intog = new InsertHUIntegrationLog( newHttpResponse.getBody(), newHttpResponse.getStatusCode(), prIds[0] , 'POST'); 
            responseApiRequest.responsebody = newHttpResponse.getBody();
            responseApiRequest.Code = newHttpResponse.getStatusCode();
            responseApiRequest.Endpoint = System.Label.HU_Azure_Endpoint;
            responseApiRequestLst.add(responseApiRequest);    
            }
            InsertHUIntegrationLog intog = new InsertHUIntegrationLog( responseApiRequestLst, prIds[0] , 'POST');
            System.enqueueJob(intog);
        }
    }
    
    public class IntegrationLogData{
		public String responsebody{get;set;}
        public Integer Code{get;set;}
        public String Endpoint{get;set;}
        
    }
    
    public class requestBody{
		public String UserId{get;set;}
        public list<huRequestData> huRequestData{get;set;}
        
    }
    public class huRequestData{
        public String ServiceStateCode{get;set;}
		public String ServiceCity{get;set;}
		public String ServiceAddress2{get;set;}
		public String ServiceZip{get;set;}
		public String ServiceAddress1{get;set;}
		public String ExternalId{get;set;}
		public String IsUnmetered{get;set;}
		public String Source{get;set;}
		public String ScraperType{get;set;}
		public String StateCode{get;set;}
		public String AccountName{get;set;}
		public String HistoricalUsageRequestType{get;set;}
		public String UtilityAccountNumber{get;set;}
		public String ServiceTypeCode{get;set;}
		public String MarketerCode{get;set;}
		public list<String> UtilityDUNS{get;set;}
		public String CreditRiskExposureRequired{get;set;}
		public String SupplierDUNS{get;set;}
    }
}