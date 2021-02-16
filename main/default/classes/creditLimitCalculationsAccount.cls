public class creditLimitCalculationsAccount {
    
    @invocableMethod
    public static void calculateAccCreditLimits(List<Id> pricingRequestId){
        try{
        
        Pricing_Request__c pricingReq = [SELECT Id,
                                         Pricing_Request_Credit_Limit__c,
                                         Customer__c,Bill_Type__c,
                                         Pricing_Request_Credit_Annual_Volume__c
                                         FROM Pricing_Request__c 
                                         WHERE Id =: pricingRequestId[0]];
        
        Account customerAcc = [SELECT Id,
                               Customer_Credit_Limit__c,
                               Customer_Credit_Annual_Volume__c
                               FROM Account
                               WHERE Id =:pricingReq.Customer__c];
        
        Set<Id> uaIdSet = new Set<Id>();
        
        List<Utility_Account__c> uaLst = new List<Utility_Account__c>();
        
        List<Utility_Account_Pricing__c > uaprLst = [SELECT Id,
                                                     Pricing_Request__c,
                                                     Utility_Account__c,
                                                     Status__c 
                                                     FROM Utility_Account_Pricing__c 
                                                     WHERE Pricing_Request__c =:pricingReq.id 
                                                     AND (Status__c = 'Priced' OR Status__c = 'New')];
        
        for(Utility_Account_Pricing__c uapr : uaprLst){
            uaIdSet.add(uapr.Utility_Account__c);
        }
        
        List<Utility_Account_Contract__c> uacLst = [SELECT Id,
                                                    Name, 
                                                    Contract_Name__c,
                                                    Status__c, 
                                                    Contract__c,
                                                    Contract__r.Status,
                                                    Utility_Account__c 
                                                    FROM Utility_Account_Contract__c 
                                                    WHERE Status__c = 'Contracted' 
                                                    AND Utility_Account__c NOT IN: uaIdSet
                                                    AND (Contract__r.Bill_Type__c = 'Dual' OR Contract__r.Bill_Type__c = 'UCB with Credit')
                                                    AND (Contract__r.Status = 'Pending_Live' OR Contract__r.Status = 'Live') 
                                                    AND Utility_Account__r.Account__c =: pricingReq.Customer__c ];
        
        
        for(Utility_Account_Contract__c uac : uacLst){
            uaIdSet.add(uac.Utility_Account__c);
        }
        System.debug('uaIdSet->'+uaIdSet);
        List<AggregateResult> groupedResultsPRCreditLimit = [SELECT SUM(Credit_Limit__c),SUM(Annual_Usage_Kwh__c) FROM Utility_Account__c WHERE Id IN: uaIdSet];
        
        customerAcc.Customer_Credit_Annual_Volume__c = Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr1'));
        System.debug('0-->'+Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')));
        System.debug('1-->'+Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr1')));
        Decimal aa = Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')));
        Decimal qq = aa/1000;
        System.debug('Rounded-->'+qq.setscale(0)*1000);
        customerAcc.Customer_Credit_Limit__c = qq.setscale(0)*1000;
        update customerAcc;
        }
        catch(Exception e){
            
        }
    }

}