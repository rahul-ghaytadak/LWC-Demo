global with sharing class VFBrokerSalesConfirmationController {
    
    global String oppIdValue{get;set;}
    global String oppId;
    global String BillType{get;set;}
    global String BrokerName{get;set;}
    global Date dateToday{get;set;}
    global String startDate{get;set;}
    global Decimal cRate{get;set;}
    global Decimal TermMonths{get;set;}
    global Decimal BrokerMargin{get;set;}
    global String custName{get;set;}
    global opportunity oppRecord{get;set;}
    global List<Utility_Account_Quote__c> UAQRecords{get;set;}
    global List<Utility_Account_Opportunity__c> UAORecords{get;set;}
    global List<Utility_Account_Opportunity__c> UAORecordsExtras{get;set;}
    
    global void setoppId(String oppIdValue){
        System.debug('contrIdValue'+oppIdValue);
        oppId = oppIdValue; 
        UAQRecords = getData();
        
        //showUAoppList = getUAoppList();
    } 
    global String getoppId(){
        System.debug('contrId'+oppId);
        return oppId; 
    }
     /*global VFBrokerSalesConfirmationController(){
         system.debug('oppIdValue'+oppIdValue);
         system.debug('oppIdValue'+oppId);
         setOppId(oppIdValue);
        UAQRecords = getData();
           System.debug('contrIdValue 23'+oppId);
        } */
        global List<Utility_Account_Quote__c> getData(){
            if(oppId != NULL){
                oppRecord = [SELECT id, Commodity__c, Contract_Term__c,Broker_Margin__c, Commission_Type__c, Expected_end_date__c, start_Month__c, broker__r.Name, Account_Name__c, Bill_Type__c, (SELECT Id, Term_Months__c, Broker_Margin_per_unit__c, Total_Unit_Price__c, Volume_kWh__c, Product2.Name FROM OpportunityLineItems) FROM Opportunity WHERE id =: oppId];
                Quote quoteRecord = [SELECT id, name, (SELECT id FROM QuoteLineItems) FROM Quote WHERE isSyncing = true AND OpportunityId =: oppId];
                UAQRecords = [SELECT id, Utility_Account__r.Name, Utility_Account__r.Utility__r.Name, Utility_Account__r.Annual_Usage_kWh__c , Utility_Account__r.Service_Address__c, Utility_Account__r.Commodity__c FROM Utility_Account_Quote__c WHERE Quote__c =: quoteRecord.Id ];
                UAORecords = [SELECT id, Utility_Account__r.Name, Utility_Account__r.Utility__r.Name, Utility_Account__r.Annual_Usage_kWh__c , Utility_Account__r.Service_Address__c, Utility_Account__r.Commodity__c FROM Utility_Account_Opportunity__c WHERE Opportunity__c =: OppId ];
                BrokerName = oppRecord.Broker__r.Name;
                BillType = oppRecord.Bill_Type__c;
                startDate = oppRecord.Start_Month__c;
                //BrokerMargin = quoteRecord.QuoteLineItems[0].Broker_Margin_per_unit__c;
                TermMonths = oppRecord.OpportunityLineItems[0].Term_Months__c;
                cRate = oppRecord.OpportunityLineItems[0].total_unit_price__c;
                dateToday = system.today();
                custName = oppRecord.Account_Name__c;
                if(UAORecords.size()>9){
                    UAORecordsExtras = new List<Utility_Account_Opportunity__c>();
                    for(integer i=9; i<UAORecords.size();i++){
                        system.debug('UAORecords: ' + i + UAORecords[9] );
                        UAORecordsExtras.add(UAORecords[i]);
                        UAORecords.remove(i);
                    }
                }

            }
          
            return UAQRecords;
        }
}