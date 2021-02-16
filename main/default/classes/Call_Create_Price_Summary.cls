/* 
* @Purpose: This class inserts Price Summary Records for Term Price Records
* @Author: Vishwanath Kodgire
* @CreatedDate: 20/01/2020
* @Related Code: 
* @Test Class: file_upload_handler_Test
* @LastModifiedDate: 30/06/2020
* @LastModifiedBy: Saurabh Chauhan
*/
public class Call_Create_Price_Summary {
    
    //Calculate Price summary based on the term Prices
    //Price summaries are calculated based on Start Dates on UAOs/UAPRs (staggered/same)
    
    public static void getTermPriceRecords(List<Id> priceId1, List<Term_Price__c> termpriceLst1){
        List<Price_Summary__c> pr_Sum_lst = new List<Price_Summary__c>();
        Decimal FRM_Weighted_Base_Price;
        List<Term_Price__c> termpriceLst = termpriceLst1;
        List<Term_Price__c> NewtermpriceLst = new List<Term_Price__c>();
     
        for(Integer i = 0; i< termpriceLst.size(); i++ ){
            Integer StartDateDiff = termpriceLst[0].Utility_account_opportunity__r.Start_Date__c.monthsBetween(termpriceLst[i].Utility_account_opportunity__r.Start_Date__c);
           
            if(Integer.valueOf(termpriceLst[i].Term__c) > StartDateDiff){
                NewtermpriceLst.add(termpriceLst[i]);
            }
            
        }
        
        Set<Id> Term_PriceIds = new Set<Id>();
        for(Term_Price__c tp : NewtermpriceLst){
            Term_PriceIds.add(tp.Id);
        }
        
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        for (AggregateResult result :  [SELECT COUNT(Utility_account_opportunity__c)UACount,
                                               SUM(Cumulative_Volume__c)CVSum, 
                                               SUM(Volume__c)VSum, 
                                               SUM(Load_Factor_x_Volume__c)LFSum,
                                               Sum(Tax_x_Volume__c)TaxSum, 
                                               Sum(POR_x_Volume__c)PORSum, 
                                               sum(Price_x_Vol__c)PVSum 
                                               FROM Term_Price__c 
                                               WHERE Id IN: Term_PriceIds
                                               AND Utility_Account_Opportunity__r.Status__c = 'Priced'
                                               GROUP BY Term__c 
                                               ORDER BY Sum(Cumulative_Volume__c) ASC]){
                                                   
                                                   
                    groupedResults.add(result);                               
                                  
        }
       
        for (Integer i = 0; i< groupedResults.size(); i++)  {
            Price_Summary__c priceSum = new Price_Summary__c();
            if((Integer) groupedResults[i].get('UACount')==(Integer) groupedResults[groupedResults.size()-1].get('UACount')){

            priceSum.Volume_kWh__c = (Decimal) groupedResults[i].get('VSum');
            FRM_Weighted_Base_Price = (Decimal) groupedResults[i].get('PVSum') /(Decimal) groupedResults[i].get('CVSum');
            priceSum.Base_Price__c =FRM_Weighted_Base_Price;
            priceSum.Price__c =priceId1[0];
            priceSum.Term_months__c = i+1;
            priceSum.Price_x_Vol__c = (Decimal) groupedResults[i].get('PVSum');
            priceSum.Load_Factor_x_Volume__c = (Decimal) groupedResults[i].get('LFSum');
            priceSum.Utility_Count__c = (Integer) groupedResults[i].get('UACount');
            priceSum.Cumulative_Volume__c  =(Decimal) groupedResults[i].get('CVSum');
            priceSum.Load_Factor_Decimal__c = termpriceLst[i].Load_Factor_Decimal__c;
            priceSum.Month__c = termpriceLst[i].Month__c;
            priceSum.Year__c = termpriceLst[i].Year__c;
            priceSum.Tax_x_Volume__c = (Decimal) groupedResults[i].get('TaxSum');
            priceSum.POR_x_Volume__c = (Decimal) groupedResults[i].get('PORSum');
            priceSum.Profile_On_Peak__c = termpriceLst[i].Profile_On_Peak__c;
            priceSum.Profile_Off_Peak__c = termpriceLst[i].Profile_Off_Peak__c;
            }
            // Add summary records in a price summary list
            pr_Sum_lst.add(priceSum);
        }
        
        if(!pr_Sum_lst.isEmpty())
            insert pr_Sum_lst;
    }
    
}