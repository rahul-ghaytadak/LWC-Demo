/*
* @Purpose: Controller class for SplitOppCMP Component.
* @Author: Saurabh Chauhan
* @CreatedDate: 17/11/2020
* @Test Class:  SplitOpportunity_Test
* @Related Code: SplitOppCMP.cmp
* @LastModifiedDate: 12/01/2021
* @LastModifiedBy: Saurabh Chauhan
*/


public with sharing class SplitOpportunity {
    
    public class UAOWrapper{
        @AuraEnabled
        public boolean isSelected {get;set;}
        @AuraEnabled
        public boolean isSelectedfilter {get;set;}
        @AuraEnabled
        public Utility_Account_Opportunity__c UAO {get;set;}
        @AuraEnabled
        public Account Acc {get;set;}
    }
    
    public class splitDetails{
        @AuraEnabled
        public List<Opportunity> parentOppty {get;set;}
        @AuraEnabled
        public List<Opportunity> siblingOpptys {get;set;}
        @AuraEnabled
        public List<Opportunity> childOpptys {get;set;}
       
    }
    
    @AuraEnabled
    public static List<UAOWrapper> getUAOList(Id recordId){
        
        List<Utility_Account_Opportunity__c> uaoLst = new List<Utility_Account_Opportunity__c>();
        List<UAOWrapper> uaoLstWrapper = new List<UAOWrapper>();
        
        Opportunity Opp = [SELECT Id,
                                  Split_Opportunity__c,
                           		  Parent_Opportunity__c,
                                  AccountId
                                  FROM Opportunity
                                  WHERE Id =: recordId];
        
        if(Utility_Account_Opportunity__c.SObjectType.getDescribe().isAccessible()){ 
            uaoLst = [SELECT Id,
                      Opportunity__c,
                      Utility_Account__c,
                      Start_Date__c,
                      Utility_Account__r.Name, 
                      Address__c,
                      Utility__c 
                      FROM Utility_Account_Opportunity__c
                      WHERE Opportunity__c =: recordId];
        }
        
        List<Account> accLst = [SELECT id,
                                       Name,
                                       RecordTypeId
                                       FROM Account
                                       WHERE Id =: Opp.AccountId ];
        
        for( Utility_Account_Opportunity__c uao : uaoLst){
            UAOWrapper uaObj = new UAOWrapper();
            uaObj.UAO = uao;
            uaObj.isSelectedfilter = true;
            uaoLstWrapper.add(uaObj);
        }
        if(accLst.size() > 0 && uaoLstWrapper.size() > 0){
            uaoLstWrapper[0].Acc = accLst[0];
        }
        return uaoLstWrapper;
    }
    
    @AuraEnabled
    public static Id createOpportunity(Id customerAccountid, Id recordId, List<Utility_Account_Opportunity__c> uaoLst) {
        
        Date EarliestDate;
        boolean SetEarliestDate = false;
        
        Set<Id> uaIds = new Set<Id>();
        List<Utility_Account__c> uaLstToUpdate = new List<Utility_Account__c>();
        
        Opportunity parentOpp;
        List<Opportunity> oppLstToUpdate = new List<Opportunity>();
        List<Utility_Account_Opportunity__c> uaoLstToUpdate = new List<Utility_Account_Opportunity__c>();
        Account customerAcc = new Account();
        
        if(customerAccountid != null){
            customerAcc = [SELECT Id,
                                  Broker__c 
                                  FROM Account
                                  WHERE Id =:customerAccountid];
        }
        
        if(Opportunity.SObjectType.getDescribe().isAccessible()){ 
            parentOpp = [SELECT  Id,
                         AccountId,
                         Broker_Margin__c,
                         Name,StageName,
                         Start_Date__c,
                         Split_Opportunity__c,
                         Parent_Opportunity__c,
                         State__c,
                         Broker__c,
                         Type,
                         Switching_Type__c
                         FROM Opportunity
                         WHERE Id =:recordId];
        }
        Opportunity oppToinsert = new Opportunity();
        oppToinsert.AccountId = customerAccountid ;
        oppToinsert.Broker_Margin__c = parentOpp.Broker_Margin__c;
        
        if(customerAcc.Broker__c != null){
            oppToinsert.Broker__c = customerAcc.Broker__c;
        }
        else{
            oppToinsert.Broker__c = parentOpp.Broker__c;
            customerAcc.Broker__c = parentOpp.Broker__c;
            update customerAcc;
        }
        
        oppToinsert.CloseDate = System.TODAY().addDays(7);
        oppToinsert.Name = 'New';
        oppToinsert.Commission_Type__c = 'Residual';
        oppToinsert.StageName = 'New';
        oppToinsert.Start_Date__c = System.TODAY();
        oppToinsert.State__c = parentOpp.State__c;
        oppToinsert.Type = parentOpp.Type;
        oppToinsert.Parent_Opportunity__c = parentOpp.Id;
        oppToinsert.Split_Opportunity__c = true;
        oppToinsert.Switching_Type__c = parentOpp.Switching_Type__c;
        Insert oppToinsert;
        
        for(Utility_Account_Opportunity__c uao : uaoLst){
            
            if(SetEarliestDate == false){
                EarliestDate = uao.Start_Date__c;
                SetEarliestDate = true;
            }
            if(EarliestDate > uao.Start_Date__c){
                EarliestDate = uao.Start_Date__c;
            }
            uao.Status__c = 'Not Priced';
            uao.Opportunity__c = oppToinsert.Id;
            uaoLstToUpdate.add(uao);
            uaIds.add(uao.Utility_Account__c);
        }
        
        if(EarliestDate != null){
            oppToinsert.Start_Date__c = EarliestDate;
            oppLstToUpdate.add(oppToinsert);
        }
        
        update uaoLstToUpdate;
        
        List<Utility_Account_Opportunity__c> uaOLstsize = [ SELECT Id
                                                            FROM Utility_Account_Opportunity__c 
                                                            WHERE Opportunity__c =: recordId];
        
        if(uaOLstsize.size() == 0){
            parentOpp.StageName = 'Closed Lost';
            parentOpp.Loss_Reason__c = 'Other';
            
        }
        parentOpp.Split_Opportunity__c = true;
        oppLstToUpdate.add(parentOpp);
        
        for(Utility_Account__c ua : [SELECT Id,
                                     Account__c 
                                     FROM Utility_Account__c 
                                     WHERE id IN: uaIds ]){
                                         
            ua.Account__c = customerAccountid;
            uaLstToUpdate.add(ua);
        }
        update uaLstToUpdate;
        update oppLstToUpdate;
        
        return oppToinsert.Id;
    }
    
    @AuraEnabled
    public static splitDetails splitOpptyDetails(Id recordId){
        
        splitDetails spDetails = new splitDetails();
        try{
        List<Opportunity> parentOppty = [  SELECT Id,
                                           Name,
                                           Parent_Opportunity__c
                                           FROM Opportunity
                                           WHERE Id =: recordId
                                           AND Split_Opportunity__c = true]; 
        
        if(parentOppty[0].Parent_Opportunity__c != null){
            
            List<Opportunity> parentOpptylookup = [  SELECT Id,
                                           Name,
                                           Parent_Opportunity__c
                                           FROM Opportunity
                                           WHERE Id =: parentOppty[0].Parent_Opportunity__c];
            
            spDetails.parentOppty = parentOpptylookup;
        }
        
        List<Opportunity> siblingOpptys = [SELECT Id,
                                           Name 
                                           FROM Opportunity
                                           WHERE Parent_Opportunity__c =: parentOppty[0].Parent_Opportunity__c
                                           AND Split_Opportunity__c = true
                                           AND Id != : recordId];
        
        if(parentOppty[0].Parent_Opportunity__c != NULL)        {
        spDetails.siblingOpptys = siblingOpptys;
        }
                
       
                    
            
            List<Opportunity> childOpptys = [SELECT Id,
                                             Name 
                                             FROM Opportunity
                                             WHERE Split_Opportunity__c = true
                                             AND Parent_Opportunity__c =: recordId];
            
            
            spDetails.childOpptys = childOpptys;
        }catch(Exception e){
            
        }
        return spDetails;
    }
}