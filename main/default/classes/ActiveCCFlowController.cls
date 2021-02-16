/*
* @Purpose: controller of ActiveCreditCheckFlow and DisaplayCreditPremiums component.
* @Author: Vishwanath Kodgire
* @CreatedDate: 
* @Related Code: 
* @Test Class: ActiveCCFlowController_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class ActiveCCFlowController {
    @auraEnabled
    public static String getCcId(Id oppId){
        String ccId = '';
        //retrive the Active status credit check records
        Credit_Check__c cc = [SELECT Id, Credit_Rank_Formula__c, Pricing_Request__c FROM Credit_Check__c WHERE opportunity__c =: oppId AND Status__c = 'Active'];
        if(cc != NULL)
            ccId = cc.Id;
        return ccId;
        
    }
    @auraEnabled
    public static Map<String,Decimal> getPremiums(Id ccId){
        Map<String,Decimal> utilityPremiumMap = new Map<String,Decimal>();
        Credit_Check__c ccRecord = [SELECT Id, Credit_Rank_Formula__c, Pricing_Request__c FROM Credit_Check__c WHERE Id =: ccId];
        if(ccRecord != NULL){
            String rank = ccRecord.Credit_Rank_Formula__c;
            system.debug('rank==>'+rank);
            List<AggregateResult> agResult = [SELECT Utility_Account__r.Utility__r.name  FROM Utility_Account_Pricing__c WHERE pricing_request__c =: ccRecord.Pricing_Request__c GROUP BY Utility_Account__r.Utility__r.name];
            Set<String> utilities = new Set<String>();
            for(AggregateResult aggr:agResult){
                utilities.add((String)aggr.get('Name'));
            }
            system.debug('utilities==>'+utilities);
            String queryField;
            if(rank != null){
                queryField =','+ rank+ '__c';
            }
            else{
               queryField = ''; 
            }
            List<Account> sobjList = Database.query('SELECT Id, Name' + queryField + ' FROM Account WHERE Name IN: utilities');
            For(Account acc: sobjList){
                if(rank == 'S1')
                    utilityPremiumMap.put(acc.Name, acc.S1__c);
                else if(rank == 'S2')
                    utilityPremiumMap.put(acc.Name, acc.S2__c);
                else if(rank == 'S3')
                    utilityPremiumMap.put(acc.Name, acc.S3__c);
                else if(rank == 'S4')
                    utilityPremiumMap.put(acc.Name, acc.S4__c);
                else if(rank == 'S5')
                    utilityPremiumMap.put(acc.Name, acc.S5__c);
                else if(rank == 'S6')
                    utilityPremiumMap.put(acc.Name, acc.S6__c);
                else if(rank == 'S7')
                    utilityPremiumMap.put(acc.Name, acc.S7__c);
            }
            system.debug('utilityPremiumMap ' + utilityPremiumMap);
        }
        return utilityPremiumMap;
    }
    @auraEnabled
    public static List<AccWrapper> getPremiums1(Id prId){
        List<AccWrapper> utilityPremiumMap = new List<AccWrapper>();
        Pricing_Request__c ccRecord = [SELECT Id,Credit_Details__r.Credit_Rank_Formula__c FROM Pricing_Request__c WHERE Id =: prId ];
        if(ccRecord != NULL){
            String rank = ccRecord.Credit_Details__r.Credit_Rank_Formula__c;
            List<AggregateResult> agResult = [SELECT Utility_Account__r.Utility__r.name  FROM Utility_Account_Pricing__c WHERE pricing_request__c =: prId GROUP BY Utility_Account__r.Utility__r.name];
            Set<String> utilities = new Set<String>();
            for(AggregateResult aggr:agResult){
                utilities.add((String)aggr.get('Name'));
            }
            String queryField;
            if(rank != null){
                queryField =','+ rank+ '__c';
            }
            else{
               queryField = ''; 
            }
            
            List<Account> sobjList = Database.query('SELECT Id, Name,POR_Rate__c ' + queryField + ' FROM Account WHERE Name IN: utilities');
            For(Account acc: sobjList){
                //insert records in Wrapper class fields to display credit premiums
                AccWrapper obj = new AccWrapper();
                if(rank == 'S1'){
                    obj.Name= acc.Name;
                    obj.SValue=acc.S1__c;
                    obj.POR_Rate=acc.POR_Rate__c;
                    utilityPremiumMap.add(obj);
                }
                else if(rank == 'S2')
                {
                    obj.Name= acc.Name;
                    obj.SValue=acc.S2__c;
                    obj.POR_Rate=acc.POR_Rate__c;
                    utilityPremiumMap.add(obj);
                }  
                else if(rank == 'S3')
                {
                    obj.Name= acc.Name;
                    obj.SValue=acc.S3__c;
                    obj.POR_Rate=acc.POR_Rate__c;
                    utilityPremiumMap.add(obj);
                }  
                else if(rank == 'S4')
                {
                    obj.Name= acc.Name;
                    obj.SValue=acc.S4__c;
                    obj.POR_Rate=acc.POR_Rate__c;
                    utilityPremiumMap.add(obj);
                }  
                else if(rank == 'S5')
                {
                    obj.Name= acc.Name;
                    obj.SValue=acc.S5__c;
                    obj.POR_Rate=acc.POR_Rate__c;
                    utilityPremiumMap.add(obj);
                }  
                else if(rank == 'S6')
                {
                    obj.Name= acc.Name;
                    obj.SValue=acc.S6__c;
                    obj.POR_Rate=acc.POR_Rate__c;
                    utilityPremiumMap.add(obj);
                }  
                else if(rank == 'S7')
                {
                    obj.Name= acc.Name;
                    obj.SValue=acc.S7__c;
                    obj.POR_Rate=acc.POR_Rate__c;
                    utilityPremiumMap.add(obj);
                }  
            }
            system.debug('utilityPremiumMap ' + utilityPremiumMap);
        }
        return utilityPremiumMap;
    }
    @auraEnabled
    public static String getCcheckId(Id prId){
        String ccId = '';
        Pricing_Request__c cc = [SELECT Id,Credit_Details__c FROM Pricing_Request__c WHERE Id =: prId ];
        if(cc != NULL)
            ccId = cc.Credit_Details__c;
        return ccId;
        
    }
    //Wrapper class to display credit premiums
    public class AccWrapper{
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Decimal POR_Rate {get;set;}
        @AuraEnabled
        public Decimal SValue {get;set;}
        
    }
}