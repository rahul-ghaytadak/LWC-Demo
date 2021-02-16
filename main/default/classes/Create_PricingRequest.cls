/*
* @Purpose: Controller class for Create_PricingRequest Component.
* @Author: Saurabh Chauhan
* @CreatedDate: 01/07/2020
* @Test Class:  Create_PricingRequest_Test
* @Related Code: Create_PricingRequest1.cmp, Create_PricingRequest.cmp
* @LastModifiedDate: 
* @LastModifiedBy:Rahul Ghaytadak
*/


//To get the picklist values for State based on the States of related Utility Accounts on the Customer Record.
public class Create_PricingRequest {
    @AuraEnabled
    public static List<String> getStatePicklist(Id recordId){
        List<String> LstToReturn = new List<String>();
        Opportunity Opp = [Select Id,State__c from Opportunity where Id =:recordId]; 
        LstToReturn.add(Opp.State__c);
        return LstToReturn;
    }
    
    //To fetch the Utility Accounts based on selected State and to sort the Utility Account list based on sortField and sortType. 
    @AuraEnabled
    public static List<UAWrapper> getUAList(Id recordId,String State,String sortType,String sortField,List<UAWrapper> UtilitiesSelected){
        List<UAWrapper> UALstWrapper = new List<UAWrapper>();
        
        if(UtilitiesSelected.size() <= 0){
            String query = 'SELECT Id, Name,Utility_Account__r.Utility__c,Utility__c,Utility_Account__r.Name,Status__c, Start_Date__c FROM Utility_Account_Opportunity__c where Opportunity__c=: recordId ORDER BY '  +sortField +' '+ sortType;
            
            List<Utility_Account_Opportunity__c> UALst = Database.query(query);
            
            
            
            for(Utility_Account_Opportunity__c ua : UALst){
                UAWrapper obj = new UAWrapper();
                obj.Id = ua.Id;
                obj.UtilityName = ua.Utility__c;
                obj.isSelected = true;
                obj.isSelectedStatus = true;
                
                obj.defaultCheckbox = true;
                
                // ua.Start_Date__c = null;
                obj.UAcc = ua;
                UALstWrapper.add(obj);
            }
            
            return UALstWrapper;
        }
        else{
            
            
            
            List<String> FilteredUAIds = new List<String>();
            List<Id> FilteredUAId = new List<Id>();
            for(UAWrapper uA : UtilitiesSelected){
                FilteredUAIds.add(uA.UtilityName);
                FilteredUAId.add(uA.Id);
            }
            
            String query = 'SELECT Id, Name,Status__c, Utility__c,Utility_Account__r.Utility__c,Utility_Account__r.Name, Start_Date__c FROM Utility_Account_Opportunity__c where Opportunity__c=: recordId AND Id IN:FilteredUAId AND Utility__c IN:FilteredUAIds ORDER BY '  +sortField +' '+ sortType;
            List<Utility_Account_Opportunity__c> UALst = Database.query(query);
            
            Map<Id,Utility_Account_Opportunity__c> UAMap = new Map<Id,Utility_Account_Opportunity__c>();
            Map<Id,boolean> UACheckboxMap = new Map<Id,boolean>();
            for(UAWrapper uw : UtilitiesSelected ){
                UAMap.put(uw.Id,uw.UAcc);
                UACheckboxMap.put(uw.Id,uw.defaultCheckbox);
            }
            
            for(Utility_Account_Opportunity__c ua : UALst){
                
                UAWrapper obj = new UAWrapper();
                obj.Id = ua.Id;
                obj.UtilityName = ua.Utility__c;
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
        public List<Utility_Account_Pricing__c> UAO {get;set;}
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
        public Utility_Account_Opportunity__c UAcc {get;set;}
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
        public String SaleType {get;set;}
        
        @AuraEnabled
        public list<Pricing_Request__c> PricingRequestList{get; set;}
        
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
    
    
    
    //To return all UAs which are marked selected.
    
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
    
    
    //Create Multiple Pricing Requests along UAPRs
    //Update the Customer Account Owner and Opportunity Owner as CPMUser if selected
    //Sends Pricing Request Email by invoking a flow
    //Assign Specific record type based on Bill Type of Pricing Request
    @AuraEnabled
    public static void CreatePR(List<Utility_Account_Opportunity__c> UAList,PRWrapper PricingRequest,User CPMUser,Id Opp,Boolean checkRequestType, String contractId){
        
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
        
        Date EarliestDate;
        boolean SetEarliestDate = false;
        Id rt;
        Id gr;
        
        RecordType Dualrt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Credit_Check_Required' limit 1];
        //Group Dualgr = [select Id from Group where  Type = 'Queue' AND NAME = 'Credit Team' LIMIT 1];
        
        Group PORgr = [select Id from Group where  Type = 'Queue' AND NAME = 'Pricing Team' limit 1];
        RecordType PORrt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        
        boolean PORwithRecourse = false;
        Opportunity getAccId = [Select Id,OwnerId,AccountId,Start_Date__c from Opportunity where Id=:Opp];
        
        if(CPMUser!=NULL){
            Account accToUpdateOwner = [Select Id,OwnerId from Account where id =:getAccId.AccountId];
            accToUpdateOwner.OwnerId = CPMUser.Id;
            getAccId.OwnerId = CPMUser.Id;
            update accToUpdateOwner;
            //update getAccId; 
        }
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
                //gr = Dualgr.id;
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
            prObj.Invoice_billing_Type__c = PReqList.Invoice_billing_Type__c;
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
            if(PReqList.Bill_Type__c == 'UCB'){
                prObj.Invoice_billing_Type__c = 'None';
            }
            else{
                prObj.Invoice_billing_Type__c = PReqList.Invoice_billing_Type__c;
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
                UAPRLst.add(ObjUAPR);
                
                if(SetEarliestDate == false){
                    EarliestDate = uao.Start_Date__c;
                    SetEarliestDate = true;
                }
                if(EarliestDate > uao.Start_Date__c){
                    EarliestDate = uao.Start_Date__c;
                }
            }
            insert UAPRLst;
            
            if(contractId != null && contractId != ''){
                getAccId.Existing_Contract__c = contractId;
                System.debug('contractId->'+contractId);
                Contract contr = [SELECT Id,Renewal_Opportunity__c FROM Contract WHERE Id =: contractId];
                contr.Renewal_Opportunity__c = getAccId.Id;
                update contr;
            }
            
            
            getAccId.Start_Date__c = EarliestDate;
            update getAccId;
            if(PRnew.Bill_Type__c  == 'UCB'){
                Flow.Interview flow = new Flow.Interview.Send_HU_Pricing_Emails(new map<String,String> {'VAR_Price_Request_ID' => PRnew.Id});     
                flow.start();
            }
            
        }
        
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
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        
        return options;
    }
    
    //Returns Products based on the Product Status and Product Family selected( returns Active only)
    @AuraEnabled
    public static List<String> GetProducts(String ProductFamily,String State){
        List<String> options = new List<String>();
        List<Product2> productLst = new List<Product2>([Select Name from Product2 where Family=:ProductFamily and State__c includes(:State)]);
        for(Product2 p : productLst){
            options.add(p.Name);
        }
        return options;
    }
    
    //Fetch the picklist values of Status field on Utility Account
    @AuraEnabled
    public static List<String> GetStatusPicklist(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Utility_Account_Opportunity__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        
        return options;
    }
    
    //Get the Bill type based on Utility Account
    @AuraEnabled
    public static list<String> getBillType(List<Utility_Account_Opportunity__c> UAList){
        system.debug('UAList====>'+UAList);
        set<Id> utilityAcc = new set<Id>();
        String multiselectValues;
        set<String> FinalBillType =  new set<String>();
        set<String> RemovableBillType =  new set<String>();
        List<String> lStrings =  new List<String>();
        List<Id> UAOIds = new List<Id>();
        try{
            for(Utility_Account_Opportunity__c  uao : UAList){
                UAOIds.add(uao.Id);
            }
            List<Utility_Account_Opportunity__c> UAOLst = [SELECT Id, Utility_Account__r.Utility__c FROM Utility_Account_Opportunity__c where Id=:UAOIds]; 
            for(Utility_Account_Opportunity__c  uao : UAOLst){
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
        }
        catch(Exception ex){
            return lStrings;
        }
        
    }  
    
}