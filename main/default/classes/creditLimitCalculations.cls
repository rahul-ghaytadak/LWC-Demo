public class creditLimitCalculations {
    
    @invocableMethod
    public static void calculatePRCreditLimits(List<Id> pricingRequestId){
        try{
            Pricing_Request__c pricingReq = [SELECT Id,Pricing_Request_Credit_Limit__c,Bill_Type__c,Pricing_Request_Credit_Annual_Volume__c FROM Pricing_Request__c WHERE Id =: pricingRequestId[0]];
            if(pricingReq.Bill_Type__c == 'Dual' || pricingReq.Bill_Type__c == 'UCB with Credit'){
                List<AggregateResult> groupedResultsPRCreditLimit = [SELECT SUM(Utility_Account__r.Credit_Limit__c ),SUM(Utility_Account__r.Annual_Usage_Kwh__c ) FROM Utility_Account_Pricing__c WHERE Pricing_Request__c =: pricingRequestId AND Status__c ='Priced'];
                
                pricingReq.Pricing_Request_Credit_Annual_Volume__c = Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr1'));
                Decimal aa = Decimal.valueOf(Integer.valueOf(groupedResultsPRCreditLimit[0].get('expr0')));
                Decimal qq = aa/1000;
                pricingReq.Pricing_Request_Credit_Limit__c = qq.setscale(0)*1000;    
                
                update pricingReq;
                creditLimitCalculationsAccount.calculateAccCreditLimits(pricingRequestId);    
            }
        }catch(Exception e){
            
        }
    }
    
}