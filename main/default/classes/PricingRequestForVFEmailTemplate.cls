/* @Purpose: This is a controller class used to get Price Request Id from GetOppDetailsComponent VF Component and query th required data of UAO.
* @Author: Akanksha Pandharkame
* @CreatedDate: 11/20/2019
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/
global with sharing class PricingRequestForVFEmailTemplate {
    
    // Declaring variables to use further in the class
    global string prIdValue {get; set;}
    global string BillType {get; set;}
    global string requestType {get; set;}
    global string product {get; set;}
    global String prId;
    global Date DueDate{get;set;}
    global Id prOppId{get; set;}
    global List<Utility_Account_Pricing__c> lstUAO {get; set;}
    global string StartDates {get; set;}
    global Pricing_Request__c prReq{get; set;}
    // Get set PrId from vf component
    global void setprId(String prIdValue){
        SYstem.debug('=== '+prIdValue);
        prId = prIdValue; 
        lstUAO = getlstUAOs();
        StartDates = getStartDates();
    } 
    
    global String getprId(){
        return prId; 
    }
    
    // Blank constructor 
   global PricingRequestForVFEmailTemplate (){
     
    }
    global String getStartDates(){
        prReq = [Select Id,Start_Dates__c,Voluntary_RECs__c,Voluntary_RECs_percent__c,Treatment__c from Pricing_Request__c where ID =: prId];
       StartDates = prReq.Start_Dates__c;
        return StartDates;
    }
    // Method used to fetch UAO ids related to the Pricing Request Id
    global List<Utility_Account_Pricing__c> getlstUAOs(){
        
        // Get Pricing Request Record of the prId and Get opportunity of the Pricing Request Record
        if(prId != Null){
            List<Pricing_Request__c> lstPriceRequest = [SELECT Id,Opportunity_Type__c , Name, Due_Date__c , Product_Lookup__r.Name,Opportunity__c,Request_Type__c,Bill_Type__c FROM Pricing_Request__c WHERE Id =: prId ];        
            prOppId = lstPriceRequest[0].Opportunity__c;
            BillType = lstPriceRequest[0].Bill_Type__c;
            List<Pricing_Request__c> ChecklstPriceRequest = [SELECT Id,Opportunity_Type__c , Name,Opportunity__r.Price_Request_Count__c, Due_Date__c , Product_Lookup__r.Name,Opportunity__c,Request_Type__c FROM Pricing_Request__c WHERE Opportunity__c =: prOppId ];
            DueDate = Date.valueOf(lstPriceRequest[0].Due_Date__c);
            requestType = 'Initial Request';
              
              if(ChecklstPriceRequest[0].Opportunity__r.Price_Request_Count__c>=2)
              {   
                 requestType = 'Refresh';
              }
             /* if(lstPriceRequest[0].Request_Type__c!='')
              {   
                 requestType = lstPriceRequest[0].Request_Type__c;
              }*/
            product = lstPriceRequest[0].Product_Lookup__r.Name;
        }
        
        // Get Utility Account Opportunities from opportunity id
        lstUAO = [SELECT Id, Name, Pricing_Request__r.Opportunity_Type__c,Pricing_Request__r.Treatment__c, Pricing_Request__r.Voluntary_RECs_percent__c, Pricing_Request__r.Voluntary_RECs__c , Pricing_Request__r.Opportunity__c, Pricing_Request__r.Opportunity__r.Opportunity_ID__c, Pricing_Request__r.Opportunity__r.Account.Name, Utility_Account__r.Name,Pricing_Request__r.Opportunity__r.Start_Date__c, Pricing_Request__r.Opportunity__r.Bill_Type__c,Pricing_Request__r.Opportunity__r.Broker__r.Name, Utility_Account__r.Utility__r.Name,Start_Date__c FROM Utility_Account_Pricing__c WHERE Pricing_Request__r.Opportunity__c =: prOppId AND Pricing_Request__c=: prId];

        return lstUAO;
        
    }
}