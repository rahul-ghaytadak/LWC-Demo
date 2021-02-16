public class salesRenewal {
    
    public class pricingWrapper{
        @AuraEnabled
        public Id DefaultProductLookup {get;set;}
        @AuraEnabled
        public String BillTypeVal {get;set;}
        @AuraEnabled
        public String productFamily {get;set;}
        @AuraEnabled
        public List<Product2> DefaultProduct {get;set;}
        @AuraEnabled
        public List<String> VoluntaryRECs {get;set;}
        @AuraEnabled
        public List<String> Treatment {get;set;}
        @AuraEnabled
        public Decimal voluntaryPercent {get;set;}
        @AuraEnabled
        public List<String> prodFamily {get;set;}
    }
    
    public class UAWrapper{
        @AuraEnabled
        public String State {get;set;}
        @AuraEnabled
        public Utility_Account__c UAcc {get;set;}
        @AuraEnabled
        public Account broker {get;set;}
        @AuraEnabled
        public Contact selectedCon {get;set;}
        @AuraEnabled
        public Contract selectedContract {get;set;}
        @AuraEnabled
        public Id CustomerId {get;set;}
        @AuraEnabled
        public Id productId {get;set;}
        @AuraEnabled
        public pricingWrapper prToPass  {get;set;}
    }
    
    @AuraEnabled
    public static List<UAWrapper> getUAs(Id recordId){
        List<UAWrapper> UAsToPass = new List<UAWrapper>();
        List<String> treatmentLst = new List<String>();
        List<String> VoluntaryRECsLst = new List<String>();
        List<Product2> DefaultProduct = new List<Product2>();
        List<String> prodfamilyTopass = new List<String>();
        Set<Id> uaIds = new Set<Id>();
        Map<Id,Date> UAstartDateMap = new Map<Id,Date>();
        
        List<Utility_Account_Contract__c> uacLst = [SELECT Utility_Account__c,
                                                    Start_date__c 
                                                    FROM Utility_Account_Contract__c
                                                    WHERE Contract__c =: recordId];
        
        Contract contr = [SELECT Id,
                          AccountId,
                          Account.Broker__c,
                          Opportunity__c,
                          Opportunity__r.State__c,
                          Opportunity__r.SyncedQuoteId,
                          Opportunity__r.Broker_Margin_per_unit__c ,
                          Product__c,
                          Voluntary_RECs__c,
                          Treatment__c,
                          Voluntary_RECs_percent__c
                          FROM Contract
                          WHERE Id =: recordId];
        
        Account brokerAcc = [SELECT Id
                             FROM Account
                             WHERE Id =: contr.Account.Broker__c];
        
        List<OpportunityContactRole> evaluatorContact = [SELECT Contact.FirstName,Contact.Id 
                                                         FROM OpportunityContactRole
                                                         WHERE OpportunityId =: contr.Opportunity__c
                                                         AND Role = 'Evaluator'];
        Contact selectedCon = new Contact();
        if(evaluatorContact.size() > 0){
            selectedCon = [Select Id,Name
                           FROM Contact
                           WHERE Id =: evaluatorContact[0].Contact.Id];                        
        }
        
        for(Utility_Account_Contract__c uac : uacLst){
            uaIds.add(uac.Utility_Account__c);
            UAstartDateMap.put(uac.Utility_Account__c,uac.Start_Date__c);
        }
        
        List<Utility_Account__c> ualst = [SELECT Id,Name,
                                          Account__c,
                                          Utility_State__c,
                                          Requested_Start_Date__c
                                          FROM Utility_Account__c 
                                          WHERE Id IN: uaIds ];
        
        Quote syncedQuote = [SELECT Id,
                             Voluntary_RECs_percent__c,
                             Treatment__c,
                             Voluntary_RECs__c,
                             Bill_Type__c,
                             Product__c,
                             Product__r.Family
                             FROM Quote WHERE Id =: contr.Opportunity__r.SyncedQuoteId];
        
        Product2 selectedProduct = [SELECT Id,
                                    Name,
                                    Family,
                                    Voluntary_RECs__c,
                                    Voluntary_RECS_Treatment__c
                                    FROM Product2
                                    WHERE Id =: syncedQuote.Product__c];
        
        prodfamilyTopass.add(selectedProduct.Family);
        
        for(String s : Create_Opportunity.ProductFamily()){
            if(!prodfamilyTopass.contains(s)){
                prodfamilyTopass.add(s);
            }
        }
        
        DefaultProduct.add(selectedProduct);
        DefaultProduct.addAll([SELECT Id,
                               Name,
                               Voluntary_RECs__c,
                               Voluntary_RECS_Treatment__c
                               FROM Product2
                               WHERE Id !=: syncedQuote.Product__c 
                               AND Family =: syncedQuote.Product__r.Family]);
        
        VoluntaryRECsLst.add(syncedQuote.Voluntary_RECs__c);
        treatmentLst.add(syncedQuote.Treatment__c);
            
        List<String> rECsLst = Create_Opportunity.getselectOption('Product2','Voluntary_RECs__c');
        List<String> treatLst = Create_Opportunity.getselectOption('Product2','Voluntary_RECS_Treatment__c');
        
        for(String s : rECsLst){
            if(!VoluntaryRECsLst.contains(s)){
                VoluntaryRECsLst.add(s);
            }
        }
        
        for(String s : treatLst){
            if(!treatmentLst.contains(s)){
                treatmentLst.add(s);
            }
        }
        
        pricingWrapper pr = new pricingWrapper();
        pr.DefaultProductLookup = syncedQuote.Product__c;
        pr.DefaultProduct = DefaultProduct;
        pr.BillTypeVal  =  syncedQuote.Bill_Type__c;
        pr.VoluntaryRECs = VoluntaryRECsLst;
        pr.Treatment = treatmentLst;
        pr.voluntaryPercent = syncedQuote.Voluntary_RECs_percent__c;
        pr.productFamily = syncedQuote.Product__r.Family;
        pr.prodFamily = prodfamilyTopass;
        
        for(Utility_Account__c ua : ualst){
            UAWrapper uaw = new UAWrapper();
            uaw.State = contr.Opportunity__r.State__c;
            ua.Requested_Start_Date__c = UAstartDateMap.get(ua.Id);
            uaw.UAcc = ua;
            uaw.broker = brokerAcc;
            uaw.CustomerId = contr.AccountId;
            uaw.productId = contr.Product__c;
            uaw.selectedContract = contr;
            if(selectedCon != NULL){
                uaw.selectedCon = selectedCon;
            }
            
            if(UAsToPass.size()==0){
                uaw.prToPass = pr;
            }
            
            UAsToPass.add(uaw);
        }
        
        System.debug('UAsToPass->'+UAsToPass);
        
        return UAsToPass;
    }

}