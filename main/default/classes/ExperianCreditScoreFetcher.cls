public class ExperianCreditScoreFetcher {
    
    @invocableMethod
    public static void getCreditScores(List<Id> pricingReq){
        
        String sObjName = pricingReq[0].getSObjectType().getDescribe().getName();
        if(sObjName == 'Account'){
            makeCalloutAcc(pricingReq[0]);
        }
        else{
            system.debug('pricingReq==>'+pricingReq);
            String oppId = [SELECT Id, Opportunity__c FROM Pricing_Request__c WHERE ID IN: pricingReq LIMIT 1].Opportunity__c;
            List<Credit_Check__c> activeCCRecords = [SELECT Id FROM Credit_Check__c WHERE Opportunity__c =: oppId AND Status__c = 'Active'];
            String recordTypeName = [SELECT ID, RecordType.Name FROM Pricing_Request__c WHERE Id IN: pricingReq limit 1].RecordType.Name;
            if(activeCCRecords.isEmpty() && recordTypeName == 'Credit Check Required'){
                makeCallout(pricingReq[0], oppId);
            }
        }
    }
    @future(callout=true)
    public static void makeCallout(Id pricingReqId, Id oppId){
        system.debug('pricingReq==>'+pricingReqId);
        system.debug('oppId==>'+oppId);
        Experian__c creds = [SELECT Id, Auth_URL__c, Auto_Search_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
        system.debug('expObj==>'+creds);
        Opportunity oppRecord = [SELECT Id, Account.Name, Account.BillingPostalCode, Account.BillingStreet, Account.BillingCity, Account.BillingState FROM Opportunity WHERE Id =: oppId];
        requestPayload body = new requestPayload();
        body.name = oppRecord.Account.Name;
        body.zip = oppRecord.Account.BillingPostalCode;
        body.street = oppRecord.Account.BillingStreet;
        body.City = oppRecord.Account.BillingCity;
        body.State = oppRecord.Account.BillingState;
        body.geo = True;
        body.commercialScore = True;
        body.subcode = String.valueOf(creds.Subcode__c);
        body.fsrScore = True;
        
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Auto_Search_URL__c), token, JSON.serialize(body));
        
        Integer fsrScoreValue = 0;
        Integer ipScoreValue = 0;
        if(response.getStatusCode() == 200){
            Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(resp.get('results')));
            
            commercialScore cScore = (commercialScore) JSON.deserialize(JSON.serialize(res.get('commercialScore')), commercialScore.class);
            fsrScore fsrScore = (fsrScore) JSON.deserialize(JSON.serialize(res.get('fsrScore')), fsrScore.class);
            ipScoreValue = cScore.Score;
            fsrScoreValue = fsrScore.Score;
        }
        
        Credit_Check__c newCCRecord = new Credit_Check__c();
        if(fsrScoreValue != NULL && ipScoreValue != NULL && response.getStatusCode() == 200){
            newCCRecord.Status__c = 'Credit Check Ran';
            newCCRecord.FSR_Score__c = fsrScoreValue;
            newCCRecord.IP_Score__c = ipScoreValue;
        }
        else
            newCCRecord.Status__c = 'Rank Not Applied';
        newCCRecord.Pricing_Request__c = pricingReqId;
        newCCRecord.Opportunity__c = oppId;
        Insert newCCRecord;
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Auto_Search_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Pricing_Request__c = pricingReqId;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        Insert newIntegrationLog;
    }
    
    @future(callout=true)
    public static void makeCalloutAcc (Id AccId){
        
        system.debug('oppId==>'+AccId);
        Experian__c creds = [SELECT Id, Auth_URL__c, Auto_Search_URL__c, Auth_Body__c, Subcode__c FROM Experian__c];
        system.debug('expObj==>'+creds);
        Account accRecord = [SELECT Id, Name, BillingPostalCode, BillingStreet, BillingCity, BillingState FROM Account WHERE Id =: AccId];
        requestPayload body = new requestPayload();
        body.name = accRecord.Name;
        body.zip = accRecord.BillingPostalCode;
        body.street = accRecord.BillingStreet;
        body.City = accRecord.BillingCity;
        body.State = accRecord.BillingState;
        body.geo = True;
        body.commercialScore = True;
        body.subcode = String.valueOf(creds.Subcode__c);
        body.fsrScore = True;
        
        String token = ExperianCallout.tokenFetcher(String.valueOf(creds.Auth_URL__c), creds.Auth_Body__c);
        HttpResponse response = ExperianCallout.serchResponseFetcher(String.valueOf(creds.Auto_Search_URL__c), token, JSON.serialize(body));
        
        Integer fsrScoreValue = 0;
        Integer ipScoreValue = 0;
        if(response.getStatusCode() == 200){
            Map<String, Object> resp = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(resp.get('results')));
            
            commercialScore cScore = (commercialScore) JSON.deserialize(JSON.serialize(res.get('commercialScore')), commercialScore.class);
            fsrScore fsrScore = (fsrScore) JSON.deserialize(JSON.serialize(res.get('fsrScore')), fsrScore.class);
            ipScoreValue = cScore.Score;
            fsrScoreValue = fsrScore.Score;
            
            List<EXPRN__Exp_Business_Info__c> expBusinessInfo = [SELECT Id, EXPRN__Financial_Stability_Risk__c, EXPRN__sbcs_score__c, EXPRN__Account_Name__c
                                                                 FROM EXPRN__Exp_Business_Info__c
                                                                 WHERE EXPRN__Account_Name__c =: AccId];
            
            if(expBusinessInfo.size() > 0){
                System.debug('Socres-->'+String.valueOf(fsrScore.Score)+'-->'+String.valueOf(cScore.Score));
                expBusinessInfo[0].EXPRN__Financial_Stability_Risk__c = String.valueOf(fsrScore.Score);
                expBusinessInfo[0].EXPRN__sbcs_score__c  = String.valueOf(cScore.Score);
                update expBusinessInfo[0];
                
                Account acc = [SELECT EXPRN__Exp_Business__c FROM Account WHERE Id =: AccId ];
                EXPRN__Experian_Business__c expBusiness = [SELECT Id,EXPRN__BIN__c FROM EXPRN__Experian_Business__c where Id =: acc.EXPRN__Exp_Business__c ];
                expBusiness.EXPRN__Scoring_Model__c = cScore.modelCode;
                update expBusiness;
            }
        }
        
        
        
        
        Integration_Log__c newIntegrationLog = new Integration_Log__c();
        newIntegrationLog.EndPointURL__c = String.valueOf(creds.Auto_Search_URL__c);
        newIntegrationLog.Request_Type__c = 'Post';
        newIntegrationLog.Account__c = AccId;
        newIntegrationLog.Response_Body__c = response.getBody();
        newIntegrationLog.Status_Code__c = response.getStatusCode();
        newIntegrationLog.Status__c = response.getStatus();
        Insert newIntegrationLog;
    }
    
    
    public class riskClass{
        public String definition{get;set;}
        public Integer code{get;set;}
    }
    public class fsrScore{
        public riskClass riskClass{get;set;}
        public String modelTitle{get;set;}
        public Integer score{get;set;}
        public String modelCode{get;set;}
        public Integer percentileRanking{get;set;}
        public String recommendedCreditLimitAmount{get;set;}
    }
    public class commercialScore{
        public riskClass riskClass{get;set;}
        public Integer percentileRanking{get;set;}
        public Integer score{get;set;}
        public String customModelCode{get;set;}
        public Integer recommendedCreditLimitAmount{get;set;}
        public String modelTitle{get;set;}
        public String modelCode{get;set;}
    }
    public class requestPayload{
        public String taxId{get;set;}
        public String phone{get;set;}
        public Boolean geo{get;set;}
        public String zip{get;set;}
        public String comments{get;set;}
        public String street{get;set;}
        public String modelCode{get;set;}
        public String subcode{get;set;}
        public Integer matchReliabilityCode{get;set;}
        public String state{get;set;}
        public Boolean commercialScore{get;set;}
        public String city{get;set;}
        public Boolean fsrScore{get;set;}
        public String name{get;set;}
    }
}