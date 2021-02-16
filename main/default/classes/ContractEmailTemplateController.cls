global with sharing class ContractEmailTemplateController {
    global String oppIdValue{get;set;}
    global String oppId;
    global opportunity oppRecord{get;set;}
    global void setoppId(String oppIdValue){
        System.debug('contrIdValue'+oppIdValue);
        oppId = oppIdValue; 
        getData();
    } 
    global String getoppId(){
        System.debug('contrId'+oppId);
        return oppId; 
    }
    
    global void getData(){
        if(oppId != NULL){
            oppRecord = [SELECT id, Account_Name__c, Start_Date__c, Account.Customer_ID__c,  (SELECT Id, Term_Months__c, Sales_Margin_per_unit__c, Broker_Margin_per_unit__c, Total_Unit_Price__c, Volume_kWh__c, Product2.Name FROM OpportunityLineItems) FROM Opportunity WHERE Id =: oppId];
            system.debug('oppRecord' + oppRecord);
        }
    }
}