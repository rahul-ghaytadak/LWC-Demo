public class Create_Price_Summary {
    @invocableMethod(Label='Create_Price_Summary')
    public static void getTermPrice(List<Id> priceId){
        
        List<Term_Price__c> termpriceLst =[SELECT Id, Term__c, Volume__c,Utility__c, Base_Price__c,Tax_x_Volume__c, POR_x_Volume__c,Profile_On_Peak__c,	Profile_Off_Peak__c,
                                           Price_x_Vol__c,Cumulative_Volume__c, Load_Factor_Decimal__c, Month__c, Load_Factor_x_Volume__c, Year__c, Utility_Account_Opportunity__c,
                                           Utility_Account_Opportunity__r.Status__c,Utility_Account_Opportunity__r.Start_Date__c
                                           FROM Term_Price__c where Price__r.Id IN : priceId AND Utility_Account_Opportunity__r.Status__c = 'Priced'];
       
        
        if(!termpriceLst.isEmpty()){
                Call_Create_Price_Summary.getTermPriceRecords(priceId, termpriceLst);
        }
    }
}