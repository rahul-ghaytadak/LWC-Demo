/*
* @Purpose: Controller Class for Quote Generator Component
* @Author: Vishwanath Kodgire
* @CreatedDate: 01/17/2020
* @Related Code: 
* @Test Class: Create_Quote_Controller_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class Create_Quote_Controller {
    
    //Fetch Utility Accounts and create a accountListWrapper and return the list to component.
    
    @AuraEnabled 
    public static List<accountListWrapper> fetchAccountWrapper(Id oppId, String sortType,String sortField, Boolean isInit){  
        system.debug('isinit' + isInit);
        List<accountListWrapper> lstaccountListWrapper = new List<accountListWrapper>();
        // query account records and create 'accountListWrapper' class instance for each record. 
        if(isInit){
            List<Price__c> price = [SELECT Id FROM Price__c WHERE Opportunity__c =: oppId AND CreatedDate = TODAY ORDER BY CreatedDate DESC];
            if(!price.isEmpty())
                updateUAOWithSelectedPrice(price[0].Id, oppId);
        }
        String query =  'SELECT Id, Name, Utility_Account__r.Load_Factor_Display__c, Utility_Account__r.Utility__c , Utility_Account__r.Utility__r.Name,Start_Date__c,Twelve_Month_Price__c, Utility_Account__c, Opportunity__c,Opportunity__r.Start_Date__c, Status__c,Utility_Account__r.Annual_Usage_kWh__c,Utility_Account__r.Name, Utility_Account__r.Load_Factor__c FROM Utility_Account_Opportunity__c where Opportunity__c =: oppId ORDER BY '  +sortField +' '+ sortType;
        system.debug('query ' + query);
        List<Utility_Account_Opportunity__c> UAOs = Database.query(query);
        for(Utility_Account_Opportunity__c acc : UAOs){
            if(acc.Status__c == 'Priced - Excluded')
                lstaccountListWrapper.add(new accountListWrapper(false,acc));
            if(acc.Status__c == 'Not Priced')
                lstaccountListWrapper.add(new accountListWrapper(false,acc));
            if(acc.Status__c == NULL)
                lstaccountListWrapper.add(new accountListWrapper(false,acc));
            else if(acc.Status__c == 'Priced')
                lstaccountListWrapper.add(new accountListWrapper(true,acc));
        } 
        return lstaccountListWrapper; 
    }
    /* wrapper class */  
    public class accountListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Utility_Account_Opportunity__c objAccount{get;set;}
        public accountListWrapper(boolean isChecked, Utility_Account_Opportunity__c objAccount){
            this.isChecked = isChecked;
            this.objAccount = objAccount;
        }
        public accountListWrapper() {
            
        }
    }
    
    //Populate the Select Price picklist on Quote Generator 1st Screen based on Price Age , Day of Week(Monday).
    //display Older Prices for the users included in Permission set 'QuoteGenerator_ShowAllPrices'.
    @AuraEnabled 
    public static List<priceWrapper> getPrice(Id oppId){     
        List<priceWrapper> prices = new List<priceWrapper>();
        Datetime dt = System.now();
        List<Price__c> priceRecord = new List<Price__c>();
        List<PermissionSetAssignment> PSA = [SELECT Id, PermissionSetId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'QuoteGenerator_ShowAllPrices' AND AssigneeId =: UserInfo.getUserId()];
        if(!PSA.isEmpty()){
            priceRecord  = [SELECT id,Name,Pricing_Request__r.Name,Product_Lookup__r.Name,Product_Lookup__r.family,CreatedDate FROM Price__c WHERE Opportunity__c =: oppId AND Pricing_Request__c != NULL ORDER BY CreatedDate DESC ];
        }
        else{
            String day = dt.format('EEEE');
            if(day != 'Monday')
                priceRecord  = [SELECT id,Name,Pricing_Request__r.Name,Product_Lookup__r.Name,Product_Lookup__r.family,CreatedDate FROM Price__c WHERE Opportunity__c =: oppId AND Pricing_Request__c != NULL AND ( createdDate = TODAY OR CreatedDate = YESTERDAY) ORDER BY CreatedDate DESC];
            else{
                Date d = Date.valueOf(dt.addDays(-3));
                priceRecord = [SELECT id,Name,Pricing_Request__r.Name,Product_Lookup__r.Name,Product_Lookup__r.family,CreatedDate FROM Price__c WHERE Opportunity__c =: oppId AND Pricing_Request__c != NULL AND ( createdDate = TODAY OR CreatedDate =: d) ORDER BY CreatedDate DESC];
            }
        }
        Date todayDate = System.today();
        string td = todayDate.format();
        
        
        for(Price__c p: priceRecord){
            Date d = Date.valueOf(p.CreatedDate);
            string createDate = d.format();
            
            Integer PriceAge = d.daysBetween(todayDate);
            boolean TwoDaysOld = false;
            
            if(PriceAge > = 2 ){
                TwoDaysOld = true;
            }
            
            if(createDate == td)
                prices.add(new priceWrapper(true, p.Id, p.Pricing_Request__r.Name, createDate,p.Product_Lookup__r.Name,p.Product_Lookup__r.family,TwoDaysOld ));
            else
                prices.add(new priceWrapper(false, p.Id, p.Pricing_Request__r.Name, createDate,p.Product_Lookup__r.Name,p.Product_Lookup__r.family,TwoDaysOld ));
            
        }
        return prices;
    }
    
    //Wrapper class
    public class priceWrapper {
        @AuraEnabled public boolean isLatest {get;set;}
        @AuraEnabled public Id priceId{get;set;}
        @AuraEnabled public String priceName{get;set;}
        @AuraEnabled public string createdDate{get;set;}
        @AuraEnabled public string productName{get;set;}
        @AuraEnabled public string productfamily{get;set;}
        @AuraEnabled public boolean TwoDaysOld {get;set;}
        public priceWrapper(boolean isLatest, String priceId,String priceName, string createdDate,string productName,String productfamily,boolean TwoDaysOld){
            this.isLatest = isLatest;
            this.priceId = priceId;
            this.priceName = priceName;
            this.createdDate = createdDate;
            this.productName = productName;
            this.productfamily = productfamily;
            this.TwoDaysOld = TwoDaysOld;
        }
    }
    
    //Update utility Account Status and Start Date based on selected Price records and its related UAPR's start dates 
    @AuraEnabled
    public static void updateUAOWithSelectedPrice(Id priceId, Id oppId){     
        Set<String> UAOs = new Set<String>();
        List<Term_Price__c> termPriceRecords = [SELECT Id, Utility_Account_Opportunity__c FROM Term_Price__c where Price__r.Id =: priceId ];
        List<Price_Summary__c> PriceSummary = [SELECT Id, Price__c, Term_months__c, Base_Price__c FROM Price_Summary__c WHERE Price__c =: priceId AND Term_months__c = 12 limit 1];
        Price__c p = [Select Id,Pricing_Request__c From Price__c where Id =:priceId ];
        Map<String,Date> UADateMap = new Map<String,Date>();
        
        for(Utility_Account_Pricing__c uapr:[SELECT Id,Utility_Account__r.Name,Start_Date__c from Utility_Account_Pricing__c where Pricing_Request__c=:p.Pricing_Request__c] ){
            UADateMap.put(uapr.Utility_Account__r.Name,uapr.Start_Date__c);
        }
        System.debug('Start Dates->'+UADateMap.values());
        For(Term_Price__c tp: termPriceRecords )
            UAOs.add(tp.Utility_Account_Opportunity__c);
        List<Utility_Account_Opportunity__c> UAORecords = [Select Id,Name,Utility_Account__r.name, Status__c,Start_Date__c FROM Utility_Account_Opportunity__c WHERE Opportunity__c =: oppId];
        for(Utility_Account_Opportunity__c acc : UAORecords ){
            if(UAOs.contains(acc.Id)){
                acc.Status__c = 'Priced';
                System.debug('Start Dates->'+UADateMap.get(acc.Utility_Account__r.name));
                acc.Start_Date__c = UADateMap.get(acc.Utility_Account__r.name);
            }
            else{
                acc.Status__c = 'Not Priced';
            }
            
            if(PriceSummary.size() > 0 && acc.Status__c == 'Priced'){
               acc.Twelve_Month_Price__c = PriceSummary[0].Base_Price__c;     
            }
        }
        Update UAORecords;
    }
    
    //Create Price Summaries based on the Priced UAOs and selected Price.
    @AuraEnabled 
    public static void updateExcludedUAO(List<Utility_Account_Opportunity__c> UAOList, List<Utility_Account_Opportunity__c> incUAOList, Id oppId,Id ChangedPriceId ){     
        List<Utility_Account_Opportunity__c> lstUAOUpdated = new List<Utility_Account_Opportunity__c>();
        for(Utility_Account_Opportunity__c acc : UAOList ){
            acc.Status__c = 'Priced - Excluded';
            lstUAOUpdated.add(acc);
        } 
        for(Utility_Account_Opportunity__c acc : incUAOList ){
            if(acc.Status__c == 'Priced - Excluded')
                acc.Status__c = 'Priced';
            lstUAOUpdated.add(acc);
        } 
        update lstUAOUpdated; 
        
        List<Price_Summary__c> psRecords = [SELECT Id, Term_months__c, Base_Price__c, Cumulative_Volume__c FROM Price_Summary__c WHERE Price__c =: ChangedPriceId ];
        if(!psRecords.isEmpty())
            Delete psRecords;
        Create_Price_Summary.getTermPrice(new List<Id>{ChangedPriceId});
    }
    
    //Display Price Summaries on Quote Generator second Screen by passing it in a wrapper list and return to component.
    @AuraEnabled 
    public static List<PSListWrapper> getPSRecords( String sortType,String sortField, String recordId,String changedPriceId){
        
        List<PSListWrapper> lstPSListWrapper = new List<PSListWrapper>();
        
        string priceId = Id.valueOf(changedPriceId);
        String query =  'SELECT Id, Term_months__c, POR_x_Volume__c, Price__c, TAX_x_Volume__c, Base_Price__c, POR_Factor__c, Tax_Factor__c, Cumulative_Volume__c FROM Price_Summary__c WHERE  price__c =:priceId ORDER BY '  +sortField +' '+ sortType;
        system.debug('query ' + query);
        Opportunity oppRecord = [SELECT Id, Broker_Margin__c FROM Opportunity WHERE Id =: recordId];
        List<Price_Summary__c> PSs = Database.query(query);
        Decimal brokerMargin = 0.0000;
        if(oppRecord != NULL)
            if(oppRecord.Broker_Margin__c != NULL)
            brokerMargin = oppRecord.Broker_Margin__c;
        system.debug('pss ' + PSs);
        system.debug('brokerMargin ' + brokerMargin);
        system.debug('oppRecord ' + oppRecord);
        
        List<Integer> previousTermMonths = new List<Integer>();
        List<Quote> quoteRecordList = [SELECT Id, (Select Id, Term_Months__c FROM QuoteLineItems) FROM Quote WHERE OpportunityId=: recordId ORDER BY CreatedDate DESC LIMIT 1];
        
        if(!quoteRecordList.isEmpty()){
            for(QuoteLineItem qli: quoteRecordList[0].QuoteLineItems )
                previousTermMonths.add(Integer.valueOf(qli.Term_Months__c));
        }
        system.debug('previousTermMonths ' + previousTermMonths);
        for(Price_Summary__c ps : PSs){
            if ( ps.Term_months__c == 6 || ps.Term_months__c == 12 || ps.Term_months__c == 18 || ps.Term_months__c == 24 || ps.Term_months__c == 30 || ps.Term_months__c == 36 || previousTermMonths.contains(Integer.valueOf(ps.Term_months__c)) )
                lstPSListWrapper.add(new PSListWrapper(true,ps, 0.0035, brokerMargin, 0, 0.0000));
            else
                lstPSListWrapper.add(new PSListWrapper(false,ps, 0.0035, brokerMargin, 0, 0.000));
        } 
        return lstPSListWrapper; 
    }
    /* wrapper class */  
    public class PSListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public Decimal salesMargin {get;set;}
        @AuraEnabled public Decimal brokerMargin {get;set;}
        @AuraEnabled public Decimal totalPrice {get;set;}
        @AuraEnabled public Decimal newSalesMargin {get;set;}
        @AuraEnabled public  Price_Summary__c objAccount{get;set;}
        public PSListWrapper(boolean isChecked, Price_Summary__c objAccount, Decimal salesMargin, Decimal brokerMargin, Decimal totalPrice, Decimal newSalesMargin  ){
            this.isChecked = isChecked;
            this.objAccount = objAccount;
            this.salesMargin = salesMargin;
            this.brokerMargin = brokerMargin;
            this.totalPrice = totalPrice;
            this.newSalesMargin = newSalesMargin;
        }
        public PSListWrapper(){}
    }
    
    //To generate Quote and QLIs along with Utility Account Quote based on terms selected from the 2nd and 3rd Screen of Quote Generator.
    @AuraEnabled 
    public static String generateQuoteAndLineItems(List<PSListWrapper> psRecords, Id recordId, Decimal salesMargin, Decimal brokerMargin, Id selectedPriceId,boolean Capacity,Integer StoreVolumnOfTerm,Decimal AverageLoadFactor/*Decimal totalPrice*/){     
        try{
            String Pricebook2Id = [SELECT id, name FROM pricebook2].Id;
            Price__c selectedPriceRecord = [SELECT Id, Invoice_Billing_Type__c,Pricing_Request__c,Voluntary_RECs__c, Voluntary_RECs_percent__c, Treatment__c, Bill_Type__c, Product_Lookup__c FROM Price__c WHERE Id =:selectedPriceId ];
            Pricing_Request__c prReq = [SELECT Id, Quoted__c, Pricing_Quote_Comments__c FROM Pricing_Request__c Where Id=: selectedPriceRecord.Pricing_Request__c ];
            prReq.Quoted__c = true;
            update prReq;
            
            String product2Id = '';
            String PricebookEntryId = '';
            if(selectedPriceRecord.Product_Lookup__c != NULL){
                PricebookEntry pricebookEntryRecord = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: Pricebook2Id AND Product2Id =: selectedPriceRecord.Product_Lookup__c ];
                PricebookEntryId = pricebookEntryRecord.Id;
                product2Id = pricebookEntryRecord.Product2Id;
            }
            else{
                PricebookEntry pricebookEntryRecord = [SELECT Id, Product2Id, Pricebook2Id FROM PricebookEntry WHERE Pricebook2Id =: Pricebook2Id LIMIT 1 ];
                PricebookEntryId = pricebookEntryRecord.Id;
                product2Id = pricebookEntryRecord.Product2Id;
            }
            
            Quote newQuoteRecord = new Quote();
            newQuoteRecord.Name = 'New Quote';
            newQuoteRecord.Bill_Type__c = selectedPriceRecord.Bill_Type__c;
            newQuoteRecord.Invoice_Billing_Type__c = selectedPriceRecord.Invoice_Billing_Type__c;
            newQuoteRecord.Price__c = selectedPriceId;
            newQuoteRecord.Voluntary_RECs__c = selectedPriceRecord.Voluntary_RECs__c;
            newQuoteRecord.Voluntary_RECs_percent__c = selectedPriceRecord.Voluntary_RECs_percent__c;
            newQuoteRecord.Treatment__c = selectedPriceRecord.Treatment__c;     
            newQuoteRecord.Pricebook2Id = Pricebook2Id;
            newQuoteRecord.OpportunityId = recordId;
            newQuoteRecord.Product__c = product2Id;
            newQuoteRecord.Average_Load_Factor__c = AverageLoadFactor;
            newQuoteRecord.Pricing_Quote_Comments__c = prReq.Pricing_Quote_Comments__c;
            
            insert newQuoteRecord;
            Date EarliestDate;
            boolean SetEarliestDate = false;
            List<Utility_Account_Opportunity__c> UAOs = [SELECT id, Utility_Account__c,Start_Date__c,Status__c FROM Utility_Account_Opportunity__c WHERE Opportunity__c =: recordId ];
            List<Utility_Account_Quote__c> UAQInserts = new List<Utility_Account_Quote__c>();
            For(Utility_Account_Opportunity__c UA: UAOs){
                if(UA.Status__c == 'Priced'){
                    if(SetEarliestDate == false){
                        EarliestDate = UA.Start_Date__c;
                        SetEarliestDate = true;
                    }
                    if(EarliestDate > UA.Start_Date__c){
                        EarliestDate = UA.Start_Date__c;
                    }
                }
                
                Utility_Account_Quote__c UAQ = new Utility_Account_Quote__c();
                UAQ.Quote__c = newQuoteRecord.Id;
                UAQ.Utility_Account__c = UA.Utility_Account__c;
                UAQ.Start_Date__c = UA.Start_Date__c;
                if(UA.Status__c == NULL || UA.Status__c == '')
                    UAQ.Status__c = 'Not Priced';
                else
                    UAQ.Status__c = UA.Status__c;
                UAQInserts.add(UAQ);
            }
            Insert UAQInserts;
            Opportunity oppRecord = [SELECT Id, SyncedQuoteId,Start_Date__c FROM Opportunity WHERE Id =: recordId];
            oppRecord.SyncedQuoteId = newQuoteRecord.Id;
            oppRecord.StageName = 'Quoting';
            oppRecord.Start_Date__c = EarliestDate;
            Update oppRecord;
            Decimal minSalesMargin = 10000;
            List<QuoteLineItem> newQLIRecords = new List<QuoteLineItem>();
            for(PSListWrapper ps : psRecords){
                
                if(ps.salesMargin < minSalesMargin){
                    minSalesMargin = ps.salesMargin;
                }
                
                newQuoteRecord.Annual_Volume_kWh__c = StoreVolumnOfTerm;
                
                QuoteLineItem qliRecord = new QuoteLineItem();
                qliRecord.POR_Tax_Adjustment__c = ps.objAccount.POR_Factor__c + ps.objAccount.TAX_Factor__c -1;
                qliRecord.QuoteId = newQuoteRecord.Id;
                qliRecord.PricebookEntryID = pricebookEntryId;
                qliRecord.Product2Id = selectedPriceRecord.Product_Lookup__c;
                qliRecord.Term_Months__c = ps.objAccount.Term_months__c;
                qliRecord.Base_Price__c = ps.objAccount.Base_Price__c;
                qliRecord.Tax_Factor__c = ps.objAccount.Tax_Factor__c;
                qliRecord.UnitPrice = ps.objAccount.Cumulative_Volume__c * ps.salesMargin;
                qliRecord.Total_Usage__c = ps.objAccount.Cumulative_Volume__c;
                qliRecord.Sales_Margin_per_unit__c = ps.salesMargin;
                qliRecord.Broker_Margin_per_unit__c = ps.brokerMargin;
                qliRecord.Quantity = 1;
                newQLIRecords.add(qliRecord);
                
            }
            if(!newQLIRecords.isEmpty()){
                if(minSalesMargin < 0.001)
                    newQuoteRecord.Low_Margin_Acknowledged__c = True;
                insert newQLIRecords;
                update newQuoteRecord;
            }
            return newQuoteRecord.Id;
        }
        catch(exception e){
            system.debug('Exception ' + e.getLineNumber() + e.getMessage());
            return 'Exception';
        }
    }
    
    //fetch Utility Accounts which are not present on opportunity 
    //This is used for 'Add Utility Accounts' button on Quote Generator to add more Utility Accounts to Opportunity as UAOs
    @auraEnabled
    public static List<utilityAccountListWrapper> getUAs(Id recordId){
        List<Utility_Account__c> utilityAccounts = new List<Utility_Account__c>();
        List<utilityAccountListWrapper> lstaccountListWrapper = new List<utilityAccountListWrapper>();
        List<Id> existingUAs = new List<Id>();
        Opportunity oppRecord = [SELECT id,AccountId, Name, State__c,(SELECT Id, utility_Account__c FROM Utility_Account_Opportunities__r) FROM Opportunity WHERE Id =: recordId];
        for(Utility_Account_Opportunity__c UAO : oppRecord.Utility_Account_Opportunities__r){
            existingUAs.add(UAO.utility_Account__c);
        }
        utilityAccounts = [SELECT id, Name, Utility__r.Name, service_address__c, load_factor__c, Annual_Usage_kWh__c, utility_state__c FROM utility_Account__c WHERE utility_state__c =: oppRecord.State__c AND Id NOT IN : existingUAs AND Account__c =: oppRecord.AccountId];
        system.debug('utilityAccounts' + utilityAccounts.size() + utilityAccounts );
        for(Utility_Account__c acc:utilityAccounts )
            lstaccountListWrapper.add(new utilityAccountListWrapper(false,acc));
        return lstaccountListWrapper;
    }
    
    /* wrapper class */  
    public class utilityAccountListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Utility_Account__c objAccount{get;set;}
        public utilityAccountListWrapper(boolean isChecked, Utility_Account__c objAccount){
            this.isChecked = isChecked;
            this.objAccount = objAccount;
        }
    }
    
    //Save newly added UAs as UAOs added from 'Add Utility Account' Button 
    @auraEnabled
    public static void saveUAs(Id recordId, List<Utility_Account__c> newUAs){
        List<Utility_Account_Opportunity__c> insertUAOs = new List<Utility_Account_Opportunity__c>();
        for(Utility_Account__c UA : newUAs){
            
            Utility_Account_Opportunity__c UAO = new Utility_Account_Opportunity__c();
            UAO.Opportunity__c = recordId;
            UAO.Utility_Account__c = UA.Id;
            UAO.Start_Date__c = UA.Supply_Start_Date__c;
            UAO.Status__c = 'Not Priced';
            insertUAOs.add(UAO);
        }
        Insert insertUAOs;
        
    }
    
    //Wrapper class
    public class SelectedPriceWrapper {
        @AuraEnabled public String productName {get;set;}
        
        @AuraEnabled public String productfamily {get;set;}
        public SelectedPriceWrapper(String productName,String productfamily){
            this.productName = productName;
            
            this.productfamily = productfamily;            
        }
    }
    
    //Pass selected price with productName and family to Component
    @auraEnabled
    public static SelectedPriceWrapper SelectedPriceName(Id priceId){
        String ProductName = '';
        String family = '';
        boolean Capacity = false;
        Price__c PriceObj = [SELECT Id,Product_Lookup__r.Name,Product_Lookup__r.family FROM Price__c where id =:priceId];
        
        if(PriceObj.Product_Lookup__r.Name!=NULL){
            ProductName = PriceObj.Product_Lookup__r.Name;
        }
        
        if(PriceObj.Product_Lookup__r.family!=NULL){
            family = PriceObj.Product_Lookup__r.family;
        }
        return (new SelectedPriceWrapper(ProductName,family));
    }
    
    //Total Price Validation for NIMO.
    //1.Total Price should have '4' or '9' as 4th decimal.
    //2.Total Price should have '0' as the 5th decimal.
    @AuraEnabled
    public static boolean TotalPriceValidation(Id OpptyId,List<Decimal> TotalPriceLst,Id selectedPriceId){
        Boolean Validated = true;
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>([SELECT Id, Name,Start_Date__c,Status__c, Opportunity__c, Utility__c FROM Utility_Account_Opportunity__c where Opportunity__c=:OpptyId AND Utility__c LIKE 'National Grid%' AND Status__c = 'Priced']);
        List<Price__c> pr = [SELECT Id,Bill_Type__c,Pricing_Request__r.Bill_Type__c FROM Price__c Where Id =: selectedPriceId AND (Bill_Type__c = 'Dual' OR Pricing_Request__r.Bill_Type__c = 'Dual')];
        system.debug('pr'+pr);
        if(pr.size()>0){
            Validated = true;
        }
        else{
            if(UAOLst.size()>0 && TotalPriceLst.size()>0){
                for(Decimal TotalPrice : TotalPriceLst ){
                    
                    if((String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '9' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0') || (String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '4' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0')){
                        if(Validated != false){ 
                            Validated = true;
                        }
                    }
                    else{
                        Validated = false;
                    }
                }
            }
        }
        system.debug('Validation->'+Validated);
        return Validated;
    }
    
    @AuraEnabled
    public static boolean AllowNIMOValidation(Id OpptyId,List<Decimal> TotalPriceLst,Id selectedPriceId){
        Boolean Validated = true;
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>([SELECT Id, Name,Start_Date__c,Status__c, Opportunity__c, Utility__c FROM Utility_Account_Opportunity__c where Opportunity__c=:OpptyId AND Utility__c LIKE 'National Grid%' AND Status__c = 'Priced']);
        List<Price__c> pr = [SELECT Id,Bill_Type__c,Pricing_Request__r.Bill_Type__c FROM Price__c Where Id =: selectedPriceId AND (Bill_Type__c = 'Dual' OR Pricing_Request__r.Bill_Type__c = 'Dual')];
        system.debug('pr'+pr);
        if(pr.size()>0){
            Validated = true;
        }
        else{
            if(UAOLst.size()>0 && TotalPriceLst.size()>0){
                for(Decimal TotalPrice : TotalPriceLst ){
                    
                    if((String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '9' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0') || (String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '4' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0')){
                        if(Validated != false){ 
                            Validated = true;
                        }
                    }
                    else{
                        Validated = false;
                    }
                }
            }
        }
        List<PermissionSetAssignment> PSA = [SELECT Id, PermissionSetId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'NIMO_Quote_Validation_Override' AND AssigneeId =: UserInfo.getUserId()];
        if(!PSA.isEmpty()){
            Validated = true;
        }
        return Validated;
    }
    
    //Unused as of now
    @AuraEnabled
    public static boolean updateStartDates(List<accountListWrapper> UAOLst,Id recordId,Id priceId){
        
        
        boolean showPklst = true;
        integer counter = 0;
        List<Utility_Account_Opportunity__c> PreviousUAOLst = [Select id,Start_date__c,Status__c from Utility_Account_Opportunity__c where Opportunity__c =: recordId];
        List<Utility_Account_Opportunity__c> UAOLstToUpdate = new List<Utility_Account_Opportunity__c>();
        List<Utility_Account_Opportunity__c> UAOLstToUpdatefinal = new List<Utility_Account_Opportunity__c>();
        Map<Id,Utility_Account_Opportunity__c> UAOMap = new Map<Id,Utility_Account_Opportunity__c>();
        
        for(Utility_Account_Opportunity__c uao : PreviousUAOLst){
            UAOMap.put(uao.id,uao);
        }
        
        for(accountListWrapper uaoWrapper : UAOLst){
            Utility_Account_Opportunity__c ObjUao = new Utility_Account_Opportunity__c();
            ObjUao = uaoWrapper.objAccount;
            
            if(ObjUao.Start_Date__c != UAOMap.get(ObjUao.Id).Start_Date__c){
                
                UAOLstToUpdate.add(objUao);
            }
            
        }
        
        
        if(UAOLstToUpdate.size()>0){
            
            update UAOLstToUpdate;
            
        }
        return showPklst;
    }
    
    @AuraEnabled
    public static QuoteSummary getQuoteSummaryData(Id recordId){
        String CustomerName = '';
        String objUAQ= '';
        String Product= '';
        String CustomerNumber= '';
        String StartDate;
        Decimal TermMonths;
        Decimal TermVolume;
        Decimal ContractedPrice;
        Decimal SEUSmargin;
        Decimal BrokerMargin;
        String Commission= '';
        List<String> objUA = new List<String>();
        Quote Quo = new Quote();
        Product2 pro = new  Product2();
        AggregateResult agr;
        QuoteLineItem QLI = new QuoteLineItem();
        List<Utility_Account_Quote__c> UAQ = new List<Utility_Account_Quote__c>();
        Decimal term;
        String duplicateUA = '';
        Opportunity oppRecord = [SELECT Id, Account.Name,Account.Customer_ID__c,Final_SEUS_Margin__c, Commission_Type__c,Broker_Margin__c, SyncedQuoteId, Start_Date__c FROM Opportunity WHERE Id =: recordId];
        if(oppRecord.SyncedQuoteId != null){
            Quo = [SELECT Id, Product__c,Annual_Volume_kWh__c FROM Quote Where Id =: oppRecord.SyncedQuoteId ];
            if( Quo.Product__c !=  null){
                pro = [SELECT Id, Name FROM Product2 Where Id =: Quo.Product__c];
                Product = pro.Name;
            }else{
                Product = '';
            }
            agr = [SELECT Max(Term_Months__c)term,QuoteId,SUM(Total_Unit_Price__c)tot FROM QuoteLineItem Where QuoteId =: oppRecord.SyncedQuoteId Group By QuoteId];
            term = (Decimal)agr.get('term');
            QLI = [SELECT Term_Months__c,Total_Usage__c,Broker_Margin_per_unit__c,Sales_Margin_per_unit__c,Total_Unit_Price__c,QuoteId FROM QuoteLineItem Where Term_Months__c =: term AND QuoteId =: oppRecord.SyncedQuoteId];
            UAQ = [SELECT Id, Utility__c, Name, Quote__c FROM Utility_Account_Quote__c Where Quote__c =: oppRecord.SyncedQuoteId];
            for(Utility_Account_Quote__c UA : UAQ){
                if(UA.Utility__c != duplicateUA){
                    duplicateUA = UA.Utility__c;
                    objUA.add(UA.Utility__c);
                }
            }
            objUAQ = string.join(objUA,', ');
            TermMonths =  (Decimal)agr.get('term');
            TermVolume = QLI.Total_Usage__c; 
            ContractedPrice = QLI.Total_Unit_Price__c;
            SEUSmargin= QLI.Sales_Margin_per_unit__c;
            BrokerMargin = QLI.Broker_Margin_per_unit__c;
        }
        else{
            objUAQ = '';
            Product = '';
            TermMonths =  null;
            TermVolume =null; 
            ContractedPrice = null;
            SEUSmargin= null;
            BrokerMargin = null;
        }
        CustomerName = oppRecord.Account.Name ;
        Commission =  oppRecord.Commission_Type__c;
        CustomerNumber = oppRecord.Account.Customer_ID__c;
        if(oppRecord.Start_Date__c != null){
        StartDate = (oppRecord.Start_Date__c).format();
        }
        
        return new QuoteSummary(CustomerName, objUAQ, Product, CustomerNumber, StartDate, TermMonths, TermVolume, ContractedPrice, SEUSmargin, BrokerMargin, Commission );
    }
    public class QuoteSummary {
        @AuraEnabled public String CustomerName {get;set;}
        @AuraEnabled public String objUA{get;set;}
        @AuraEnabled public String Product{get;set;}
        @AuraEnabled public String CustomerNumber{get;set;}
        @AuraEnabled public String StartDate{get;set;}
        @AuraEnabled public Decimal TermMonths{get;set;}
        @AuraEnabled public Decimal TermVolume{get;set;}
        @AuraEnabled public Decimal ContractedPrice{get;set;}
        @AuraEnabled public Decimal SEUSmargin{get;set;}
        @AuraEnabled public Decimal BrokerMargin{get;set;}
        @AuraEnabled public String Commission{get;set;}
        public QuoteSummary(String CustomerName, String objUA, String Product, String CustomerNumber, String StartDate, Decimal TermMonths, Decimal TermVolume, Decimal ContractedPrice, Decimal SEUSmargin, Decimal BrokerMargin, String Commission ){
            this.CustomerName = CustomerName;
            this.objUA = objUA;
            this.Product = Product;
            this.CustomerNumber = CustomerNumber;
            this.StartDate = StartDate;
            this.TermMonths = TermMonths;
            this.TermVolume = TermVolume;
            this.ContractedPrice = ContractedPrice;
            this.SEUSmargin = SEUSmargin;
            this.BrokerMargin = BrokerMargin;
            this.Commission = Commission;
        }
    }
}