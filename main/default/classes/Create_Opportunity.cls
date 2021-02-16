/*
* @Purpose: Controller class for Create_Opportunity Component.
* @Author: Saurabh Chauhan
* @CreatedDate: 01/07/2020
* @Test Class:  Create_Opportunity_Test
* @Related Code: Create_Opportunity.cmp, Create_PricingRequest.cmp
* @LastModifiedDate: 
* @LastModifiedBy: Rahul Ghaytadak
*/


public class Create_Opportunity {
    
    //To get the picklist values for State based on the States of related Utility Accounts on the Customer Record.
    @AuraEnabled
    public static List<String> getStatePicklist(Id recordId){
        Map<Id,String> statePicklistMap = new Map<Id,String>();
        Set<String> PicklistSet = new Set<String>();
        List<String> LstToReturn = new List<String>();
        List<Utility_Account__c> statePicklist = new List<Utility_Account__c>();
        
        String statesFromLabel = Label.State_Options;
        List<String> OptionsFromLabel = statesFromLabel.split(',');
        
        statePicklist = [Select Id,Utility_State__c from Utility_Account__c where Account__c=: recordId ];
        for(Utility_Account__c ua : statePicklist){
            PicklistSet.add(ua.Utility_State__c);           
        }
        for(String pklst : PicklistSet )
        {
            if(OptionsFromLabel.contains(pklst)){
                LstToReturn.add(pklst);
            }
        }
        return LstToReturn;
    }
    
    //To fetch the Utility Accounts based on selected State and to sort the Utility Account list based on sortField and sortType. 
    @AuraEnabled
    public static List<UAWrapper> getUAList(Id recordId,String State,String sortType,String sortField,List<UAWrapper> UtilitiesSelected){
        List<UAWrapper> UALstWrapper = new List<UAWrapper>();
        
        if(UtilitiesSelected.size() <= 0){
            String query = 'SELECT Id, Name,Account__c,Utility__r.Credit_Check_Required__c, Account__r.Broker__c,Utility__r.Name, Utility_State__c ,Status__c, Requested_Start_Date__c FROM Utility_Account__c where Account__c=: recordId AND Utility_State__c =:State ORDER BY '  +sortField +' '+ sortType;
            
            List<Utility_Account__c> UALst = Database.query(query);
            
            for(Utility_Account__c ua : UALst){
                UAWrapper obj = new UAWrapper();
                obj.Id = ua.Id;
                obj.UtilityName = ua.Utility__r.Name;
                obj.isSelected = true;
                obj.isSelectedStatus = true;
                obj.defaultCheckbox = true;
                ua.Requested_Start_Date__c = ua.Requested_Start_Date__c;
                obj.UAcc = ua;
                UALstWrapper.add(obj);
            }
            
            return UALstWrapper;
        }
        else{
            
            if(State=='' || State== '--None--'){
                State = UtilitiesSelected[0].UAcc.Utility_State__c;
            }
            
            List<String> FilteredUAIds = new List<String>();
            List<Id> FilteredUAId = new List<Id>();
            for(UAWrapper uA : UtilitiesSelected){
                FilteredUAIds.add(uA.UtilityName);
                FilteredUAId.add(uA.Id);
            }
            
            String query = 'SELECT Id, Name,Account__c,Account__r.Broker__c,Status__c,Utility__r.Credit_Check_Required__c, Utility__r.Name, Utility_State__c , Requested_Start_Date__c FROM Utility_Account__c where Account__c=: recordId AND Utility_State__c =:State AND Id IN:FilteredUAId AND Utility__r.Name IN:FilteredUAIds ORDER BY '  +sortField +' '+ sortType;
            List<Utility_Account__c> UALst = Database.query(query);
            
            Map<Id,Utility_Account__c> UAMap = new Map<Id,Utility_Account__c>();
            Map<Id,boolean> UACheckboxMap = new Map<Id,boolean>();
            for(UAWrapper uw : UtilitiesSelected ){
                UAMap.put(uw.Id,uw.UAcc);
                UACheckboxMap.put(uw.Id,uw.defaultCheckbox);
            }
            
            for(Utility_Account__c ua : UALst){
                
                UAWrapper obj = new UAWrapper();
                obj.Id = ua.Id;
                obj.UtilityName = ua.Utility__r.Name;
                obj.isSelected = true;
                obj.isSelectedStatus = true;
                obj.UAcc = UAMap.get(ua.Id);
                obj.defaultCheckbox = UACheckboxMap.get(ua.Id);
                UALstWrapper.add(obj);
                
            }
            
            
            return UALstWrapper;
        }
    }
    
    //Wrapper Class for Utility Account Opportunities 
    public class UAOWrapper{
        @AuraEnabled
        public String State {get;set;}
        @AuraEnabled
        public List<Utility_Account_Opportunity__c> UAO {get;set;}
        @AuraEnabled
        public List<String> Treatment {get;set;}
        @AuraEnabled
        public List<String> RECS {get;set;}
    }
    
    //Wrapper Class for Utility Account to display on Component
    public class UAWrapper{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String UtilityName {get;set;}
        @AuraEnabled
        public boolean isSelected {get;set;}
        @AuraEnabled
        public boolean isSelectedStatus {get;set;}
        @AuraEnabled
        public boolean defaultCheckbox {get;set;}
        @AuraEnabled
        public Utility_Account__c UAcc {get;set;}
        @AuraEnabled
        public Date StartDate {get;set;}
        @AuraEnabled
        public Date DueDate {get;set;}
        @AuraEnabled
        public List<String> StatusPicklist{get;set;}
        
    }
    
    //Wrapper Class for Pricing Request
    public class PRWrapper{
        @AuraEnabled
        public String Product {get;set;}
        @AuraEnabled
        public String BillType {get;set;}
        @AuraEnabled
        public String InvoiceBillingType {get;set;}
        @AuraEnabled
        public list<Pricing_Request__c> PricingRequestList{get; set;}
        @AuraEnabled
        public String SaleType {get;set;}
        @AuraEnabled
        public String SwitchingType {get;set;}
        @AuraEnabled
        public Decimal BrokerMargin {get;set;}
        @AuraEnabled
        public boolean UrgentRequest {get;set;}
        @AuraEnabled
        public String Notes {get;set;}
        @AuraEnabled
        public Date DueDate {get;set;}
        @AuraEnabled
        public Date StartDate {get;set;}
        @AuraEnabled
        public String Treatment {get;set;}
        @AuraEnabled
        public String Voluntary_RECs {get;set;}
        @AuraEnabled
        public integer Voluntary_RECs_percent {get;set;}
        
    }
    
    //Function to return the Utility Account List
    // as more than 100 UAs cause an error on js controller (this function is called when more than 100 UAs are fetched to avoid error)
    @AuraEnabled
    public static List<UAWrapper> SetPgLst(List<UAWrapper> UAList){
        return UAList;
    }
    
    //To return all UAs which are marked selected.
    @AuraEnabled
    public static List<UAWrapper> setPgLstcheckbox(List<UAWrapper> UAList){
        List<UAWrapper> UAListToReturn = new List<UAWrapper>();
        for(UAWrapper ua : UAList){
            ua.defaultCheckbox = true;
            UAListToReturn.add(ua); 
        }
        return UAListToReturn;
    }
    
    
    
    //This Returns Filtered UA List based on Utility and Status
    
    @AuraEnabled
    public static List<UAWrapper> CreateOpptywithUAOs(List<UAWrapper> UAList,List<UAWrapper> UtilitiesSelected,List<UAWrapper> UtilitiesWithStatusFilter){
        List<UAWrapper> UALstWrapper = new List<UAWrapper>();
        List<UAWrapper> UALstWrapperFinal = new List<UAWrapper>();
        Set<String> UtilityNames = new Set<String>();
        Set<String> UtilityStatus = new Set<String>();
        
        for(UAWrapper uw : UtilitiesSelected){
            if(uw.isSelected==true){
                UtilityNames.add(uw.UtilityName);
            }
        }
        for(UAWrapper uw : UtilitiesWithStatusFilter){
            if(uw.isSelectedStatus==true){
                UtilityStatus.add(uw.UAcc.Status__c);
            }
        }
        
        for(String uName : UtilityNames){
            for(UAWrapper uwObj : UAList){
                
                if(uwObj.UtilityName == uName){
                    UALstWrapper.add(uwObj);
                }
            }
        }
        
        for(String UStatus : UtilityStatus){
            for(UAWrapper uwObj : UALstWrapper){
                if(uwObj.UAcc.Status__c == UStatus){
                    UALstWrapperFinal.add(uwObj);
                }
            }
        }
        return UALstWrapperFinal;
    }
    
    //Create Opportunity and Multiple Pricing Requests along with UAOs and UAPRs
    //Update the Customer Account Owner and Opportunity Owner as CPMUser if selected
    //Sends Pricing Request Email by invoking a flow
    //Assign Specific record type based on Bill Type of Pricing Request
    
    @AuraEnabled
    public static void CreatePR(List<Utility_Account_Opportunity__c> UAList,PRWrapper PricingRequest,User CPMUser,Id Opp,Boolean checkRequestType,String contractId){
        System.debug('UAList->'+UAList.size());
        date strtdateList = UAList[0].Start_Date__c;
        boolean setStartdate;
        for(Utility_Account_Opportunity__c uao : UAList){
            if(uao.Start_Date__c == strtdateList){
                setStartdate = true;              
            }
            else{
                setStartdate = false;   
                break;
            }
        }
        
        Id rt;
        Id gr;
        
        RecordType Dualrt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Credit_Check_Required' limit 1];
        Group Dualgr = [select Id from Group where  Type = 'Queue' AND NAME = 'Credit Team' LIMIT 1];
        
        Group PORgr = [select Id from Group where  Type = 'Queue' AND NAME = 'Pricing Team' limit 1];
        RecordType PORrt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        
        boolean PORwithRecourse = false;
        Opportunity getAccId = [Select Id,OwnerId,AccountId,Existing_Contract__c from Opportunity where Id=:Opp];
        
        if(contractId != null && contractId != ''){
            getAccId.Existing_Contract__c = contractId;
            System.debug('contractId->'+contractId);
            Contract contr = [SELECT Id,Renewal_Opportunity__c FROM Contract WHERE Id =: contractId];
            contr.Renewal_Opportunity__c = getAccId.Id;
            update contr;
        }
        
        if(CPMUser!=NULL){
            Account accToUpdateOwner = [Select Id,OwnerId from Account where id =:getAccId.AccountId];
            accToUpdateOwner.OwnerId = CPMUser.Id;
            getAccId.OwnerId = CPMUser.Id;
            update accToUpdateOwner;
            
        }
        update getAccId;
        list<Pricing_Request__c> prlistNew = new list<Pricing_Request__c>();
        for(Pricing_Request__c PReqList : PricingRequest.PricingRequestList){
            
            if(PReqList.Bill_Type__c == 'POR & Dual'){
                Pricing_Request__c prObj1 = new Pricing_Request__c();
                prObj1.Bill_Type__c = 'Dual';
                prObj1.Notes__c = PricingRequest.Notes;
                prObj1.Urgent_Request__c = PricingRequest.UrgentRequest;
                prObj1.Product_Lookup__c = PReqList.Product_Lookup__c;
                prObj1.Opportunity__c = Opp;
                prObj1.Invoice_billing_Type__c = PReqList.Invoice_billing_Type__c;
                prObj1.Customer__c = getAccId.AccountId;
                prObj1.Status__c = 'New';
                prObj1.Due_Date__c = PricingRequest.DueDate;
                prObj1.RecordTypeId = Dualrt.Id;
                //prObj1.OwnerId = Dualgr.Id;
                prObj1.OwnerId =UserInfo.getUserId();
                if(setStartdate == true){
                    prObj1.Start_Dates__c = 'Same';
                }
                else{
                    prObj1.Start_Dates__c = 'Staggered';
                }
                prlistNew.add(prObj1);
                PReqList.Bill_Type__c = 'UCB';
            }
            if(PReqList.Bill_Type__c == 'Dual' || PORwithRecourse == true || PReqList.Bill_Type__c == 'UCB with Credit'){
                rt = Dualrt.id;
                // gr = Dualgr.id;
                gr = UserInfo.getUserId();
            }
            else{
                gr = PORgr.Id;
                rt = PORrt.Id;
            }
            
            Pricing_Request__c prObj = new Pricing_Request__c();
            prObj.Bill_Type__c = PReqList.Bill_Type__c;
            prObj.Voluntary_RECs__c =PReqList.Voluntary_RECs__c;
            if(prObj.Voluntary_RECs__c != 'NA'){
                if(PReqList.Voluntary_RECs_percent__c != null){
                    prObj.Voluntary_RECs_percent__c = PReqList.Voluntary_RECs_percent__c;
                }
                else{
                    prObj.Voluntary_RECs_percent__c = 100;
                }
                prObj.Treatment__c = PReqList.Treatment__c;
            }
            prObj.Notes__c = PricingRequest.Notes;
            prObj.Urgent_Request__c = PricingRequest.UrgentRequest;
            prObj.Product_Lookup__c = PReqList.Product_Lookup__c;
            prObj.Opportunity__c = Opp;
            if(PReqList.Bill_Type__c == 'UCB'){
                prObj.Invoice_billing_Type__c = 'None';
            }
            else{
                prObj.Invoice_billing_Type__c = PReqList.Invoice_billing_Type__c;
            }
            prObj.Customer__c = getAccId.AccountId;
            prObj.Status__c = 'New';
            prObj.Due_Date__c = PricingRequest.DueDate;
            prObj.RecordTypeId = rt;
            prObj.OwnerId = gr;
            if(setStartdate == true){
                prObj.Start_Dates__c = 'Same';
            }
            else{
                prObj.Start_Dates__c = 'Staggered';
            }
            //SU-608: Update request Type
            if(checkRequestType == true){
                prObj.Pricing_Quote_Comments__c = PReqList.Pricing_Quote_Comments__c;
                prObj.Request_Type__c = 'Refresh';
            }else{
                prObj.Request_Type__c = 'Initial Request';
            }
            prlistNew.add(prObj);
        }
        insert prlistNew;
        
        for(Pricing_Request__c PRnew : prlistNew ){
            List<Utility_Account_Pricing__c> UAPRLst = new List<Utility_Account_Pricing__c>();
            
            for(Utility_Account_Opportunity__c uao : UAList){
                Utility_Account_Pricing__c ObjUAPR = new Utility_Account_Pricing__c();
                ObjUAPR.Utility_Account__c = uao.Utility_Account__c;
                ObjUAPR.Start_Date__c = uao.Start_Date__c;
                ObjUAPR.Pricing_Request__c = PRnew.Id;
                System.debug('Start Date->'+uao.Start_Date__c);
                UAPRLst.add(ObjUAPR);
            }
            insert UAPRLst;
            if(PRnew.Bill_Type__c  == 'UCB'){
                Flow.Interview flow = new Flow.Interview.Send_HU_Pricing_Emails(new map<String,String> {'VAR_Price_Request_ID' => PRnew.Id});     
                flow.start();
            }
        }
    }
    
    //Get the Bill type based on Utility Account
    @AuraEnabled
    public static list<String> getBillType(List<Utility_Account_Opportunity__c> UAList){
        system.debug('UAList====>'+UAList);
        set<Id> utilityAcc = new set<Id>();
        set<String> FinalBillType =  new set<String>();
        set<String> RemovableBillType =  new set<String>();
        List<String> lStrings =  new List<String>();
        String multiselectValues;
        try{
            for(Utility_Account_Opportunity__c  uao : UAList){
                utilityAcc.add(uao.Utility_Account__r.Utility__c);
            }
            system.debug('utilityAcc====>'+utilityAcc);
            List<Account> acc = [Select Id,Bill_Type__c from Account Where Id=:utilityAcc];
            if(acc.size()>0){
                multiselectValues = acc[0].Bill_Type__c; 
                list<String> individualSelections = multiselectValues.split(';');
                for(String s: individualSelections){
                    for(Account ac : acc){
                        if(ac.Bill_Type__c.contains(s)){
                            FinalBillType.add(s);
                        }else{
                            RemovableBillType.add(s);
                            break;
                        }
                    }
                }
                FinalBillType.removeAll(RemovableBillType);
            }
            lStrings = new List<String>(FinalBillType);
            return lStrings;
        }catch(Exception ex){
            return lStrings;
        }        
    }  
    //Create Opportunity along with UAOs
    //Update the Customer Account Owner and Opportunity Owner as CPMUser if selected
    
    public class OppIdExceptionWrapper{
        @AuraEnabled
        public Id OppId {get;set;}
        @AuraEnabled
        public String exceptionMsg {get;set;}
    }
    
    @AuraEnabled
    public static OppIdExceptionWrapper CreateUAccs(List<Utility_Account__c> UAList,PRWrapper PricingRequest,Boolean CreatePricingReq,User CPMUser,String AccId,String ContactId,String contractId)
    {
        String errMsg='';
        List<String> errLst = new List<String>();
        OppIdExceptionWrapper oppExcepWrapper = new OppIdExceptionWrapper();
        Opportunity Opp = new Opportunity();
        try{
            
            Date EarliestDate;
            boolean SetEarliestDate = false;
            
            
            if(CPMUser!=NULL)
            {
                if(CPMUser.Id!=NULL){
                    Opp.OwnerId = CPMUser.Id;
                }
            }
            Opp.AccountId = UAList[0].Account__c ;
            Opp.Broker_Margin__c = PricingRequest.BrokerMargin;
            Opp.Broker__c = AccId;
            Opp.CloseDate = System.TODAY().addDays(7);
            Opp.Name = 'New';
            Opp.StageName = 'New';
            Opp.Start_Date__c = System.TODAY();
            System.debug('State-->'+UAList[0].Utility_State__c);
            Opp.State__c = UAList[0].Utility_State__c;
            Opp.Type=PricingRequest.SaleType;
            Opp.Commission_Type__c = 'Residual';    
            Opp.Switching_Type__c=PricingRequest.SwitchingType;
            System.debug('contractId->'+contractId);
            if(contractId != null && contractId != ''){
                Opp.Existing_Contract__c = contractId;
                System.debug('contractId->'+contractId);
            }
            Insert Opp;
            
            if(contractId != null && contractId != ''){
                Contract contr = [SELECT Id,Renewal_Opportunity__c FROM Contract WHERE Id =: contractId];
                contr.Renewal_Opportunity__c = Opp.Id;
                update contr;
            }
            if(ContactId != null){
                OpportunityContactRole contactRoleNew = new OpportunityContactRole();
                contactRoleNew.ContactId = ContactId;
                contactRoleNew.OpportunityId = Opp.Id ;
                contactRoleNew.Role = 'Evaluator';
                Insert contactRoleNew;
            }
            Account custAccount = [Select Id, Status__c, OwnerId, (SELECT Id FROM Opportunities) from Account where id =: UAList[0].Account__c];
            
            if(custAccount.Opportunities.size() == 1 && custAccount.Status__c == 'New')
                custAccount.Status__c = 'Prospect';
            if(CPMUser!=NULL){
                custAccount.OwnerId = CPMUser.Id;
            }
            Update custAccount;
            
            List<Utility_Account_Opportunity__c> UAOLstToInsert = new List<Utility_Account_Opportunity__c>();
            List<Utility_Account_Pricing__c> UAPRLstToInsert = new List<Utility_Account_Pricing__c>();
            Pricing_Request__c prObj = new Pricing_Request__c();
            boolean PORwithRecourse = false;
            RecordType rt;
            Group gr;
            
            for(Utility_Account__c ua : UAList){
                if(ua.Utility__r.Credit_Check_Required__c == true){
                    PORwithRecourse = true;
                }
                
                if(contractId != null && contractId != ''){
                    ua.Requested_Start_Date__c = ua.Requested_Start_Date__c.addDays(1);
                }
                
                if(SetEarliestDate == false){
                    EarliestDate = ua.Requested_Start_Date__c;
                    SetEarliestDate = true;
                }
                if(EarliestDate > ua.Requested_Start_Date__c){
                    EarliestDate = ua.Requested_Start_Date__c;
                }
                
                Utility_Account_Opportunity__c ObjUAO = new Utility_Account_Opportunity__c();
                Utility_Account_Pricing__c ObjUAPR = new Utility_Account_Pricing__c();
                
                ObjUAO.Utility_Account__c = ua.Id;
                ObjUAO.Status__c = 'Not Priced';
                ObjUAO.Opportunity__c = Opp.Id;
                ObjUAO.Start_Date__c = ua.Requested_Start_Date__c;
                UAOLstToInsert.add(ObjUAO);
            }
            insert UAOLstToInsert;
            
            if(EarliestDate!= null){
                Opp.Start_Date__c = EarliestDate;
            }
            if( CreatePricingReq == true ){    
                Opp.StageName = 'Pricing';    
            }    
            
            update Opp;
        }
        catch(Exception e){
            errMsg = e.getMessage();
            errLst = errMsg.split(':');
            //delete Opp;
        }
        oppExcepWrapper.OppId = Opp.Id;
        if(!errLst.isEmpty()){
            oppExcepWrapper.exceptionMsg = errLst[1];
        }
        else{
            oppExcepWrapper.exceptionMsg = errMsg;
        }
        return oppExcepWrapper;
    }
    
    //Return the Sale Type picklist values of Opportunity
    @AuraEnabled
    public static List<String> SaleType(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Type.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        
        return options;
    }
    
    //Returns Product Family based on the Product Status( returns Active only) 
    @AuraEnabled
    public static List<String> ProductFamily(){
        List<String> optionsToadd = new List<String>();
        for(Product2 prod: [Select Id,Name,IsActive,Family FROM Product2 Where Family != null]){
            if(prod.IsActive == true ){
                optionsToadd.add(prod.Family);
            }  
        }
        
        set<String> options = new set<String>();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry p: pList) {
            for(String s : optionsToadd){
                if(p.getLabel().contains(s)){
                    options.add(p.getLabel());
                }
            }
        }
        List<String> lStrings = new List<String>(options);
        return lStrings;
    }
    
    //Returns Products based on the Product Status and Product Family selected( returns Active only)
    @AuraEnabled
    public static List<Product2> GetProducts(String ProductFamily,String State){
        List<String> options = new List<String>();
        List<Product2> productLst = new List<Product2>();
        try{
            Product2 productvar = [Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c from Product2 Where IsActive = true and default__c = true and Family=:ProductFamily and State__c includes(:State)];
            if(productvar!=null){
                productLst.add(productvar);
            }
            productLst.addAll([Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c  from Product2 Where IsActive = true and default__c = false and Family=:ProductFamily and State__c includes(:State) order by Name ASC]);
        }catch(Exception e){
            productLst.addAll([Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c  from Product2 Where IsActive = true and default__c = false and Family=:ProductFamily and State__c includes(:State) order by Name ASC]);
        }
        return productLst;
    }
    
    //Fetch the picklist values of Status field on Utility Account
    @AuraEnabled
    public static List<String> GetStatusPicklist(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Utility_Account__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }
    
    //Fetch the Utility Account Opportunities along with the State on its related Oppty (Used in Create Pricing Request Component)
    @AuraEnabled
    public static UAOWrapper GetUAOsandState(Id recordId){
        
        List<UAOWrapper> UAOWrapperLst = new List<UAOWrapper>();
        List<Utility_Account_Opportunity__c> UAOLst = [SELECT Id, Utility_Account__r.Utility__c,Opportunity__c,Opportunity__r.State__c,Utility_Account__c ,Start_Date__c FROM Utility_Account_Opportunity__c where Opportunity__c=:recordId]; 
        UAOWrapper uaoWrapperObj = new UAOWrapper();
        uaoWrapperObj.State = UAOLst[0].Opportunity__r.State__c;
        uaoWrapperObj.UAO = UAOLst;
        
        try{
            Product2 productvar = [Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c from Product2 Where Name = 'Fully Fixed' ];
            uaoWrapperObj.RECS = productvar.Voluntary_RECs__c.split(';');
            if(productvar.Voluntary_RECs__c.split(';')[0] == 'NA'){
                //uaoWrapperObj.Treatment = new List<String>();
            }
            else{
                uaoWrapperObj.Treatment = productvar.Voluntary_RECS_Treatment__c.split(';');
            }
        }
        catch(Exception e){
            uaoWrapperObj.Treatment = new List<String>();
            uaoWrapperObj.RECS = new List<String>();
        }
        return uaoWrapperObj;
    }
    
    //Generic Function to get picklist values based on objectType and fieldName 
    @AuraEnabled        
    public static List<String> getselectOption(String objectType, String fieldName){
        
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getValue());
        }     
        return pickListValuesList;
    }
    
    public class VolGreenListWrapp{
        @AuraEnabled
        public List<String> Treatment {get;set;}
        @AuraEnabled
        public List<String> RECS {get;set;}
    }
    
    @AuraEnabled
    public static VolGreenListWrapp getPicklists(Id recordId, Id SelectedProduct){
        VolGreenListWrapp VG = new VolGreenListWrapp();
        
        System.debug('recordId-->'+recordId);
        System.debug('SelectedProduct-->'+SelectedProduct);
        
        try{
            Product2 productvar = [Select Id, Name, Voluntary_RECs__c, Voluntary_RECS_Treatment__c from Product2 Where Id =: SelectedProduct ];
            VG.RECS = productvar.Voluntary_RECs__c.split(';');
            VG.Treatment = productvar.Voluntary_RECS_Treatment__c.split(';');
        }
        catch(Exception e){
            VG.Treatment = new List<String>();
            VG.RECS = new List<String>();
        }
        System.debug('Treatment-->'+VG.Treatment);
        System.debug('RECS-->'+VG.RECS);
        return VG;
    }
    //SU-608: Retrive Existing PR
    @AuraEnabled
    public static List<Pricing_Request__c> getExistingPR(Id Opp){
        return [SELECT Id, Name, Pricing_Quote_Comments__c , Bill_Type__c,Invoice_Billing_Type__c, Voluntary_RECs__c, Voluntary_RECs_percent__c, Treatment__c, Product_Lookup__c, Opportunity__c, Product_Lookup__r.Name, Product_Lookup__r.Family FROM Pricing_Request__c Where Opportunity__c =: Opp order by Name desc];
        
    }
    
}