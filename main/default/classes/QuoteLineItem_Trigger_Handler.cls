public class QuoteLineItem_Trigger_Handler {

    public static void QLIupdate(Set<Id> QuoteIds ){
         List<QuoteLineItem> QLI_ListToUpdate = new List<QuoteLineItem>();
         Map<Id,List<QuoteLineItem>> QuoteIdQLIMap = new Map<Id,List<QuoteLineItem>>();
         List<Quote> QLIlst = [Select Id , (Select id,QuoteId,UnitPrice,Term_Months__c,Sales_Margin_per_unit__c,Total_Usage__c from QuoteLineItems ORDER BY Term_Months__c ) from Quote where Id IN:QuoteIds];
        for(Quote q : QLIlst ){
            if(!QuoteIdQLIMap.containskey(q.Id)){
                QuoteIdQLIMap.put(q.Id,q.QuoteLineItems);
            }
        }
        
        if(!QuoteIdQLIMap.isEmpty()){
            for(Id quoteId : QuoteIdQLIMap.keyset()){
                integer i = 0;
                List<QuoteLineItem> QliLstTocheck = QuoteIdQLIMap.get(quoteId);
                for(QuoteLineItem qli : QliLstTocheck){
                    
                    if(qli.Term_Months__c == 12){
                        qli.UnitPrice = qli.Total_Usage__c * qli.Sales_Margin_per_unit__c;
                        if(qli.Id!=QliLstTocheck[0].Id){
                           QliLstTocheck[0].UnitPrice = 0;
                        }
                    }
                    else{
                        qli.UnitPrice = 0;
                        if(i==0){
                           qli.UnitPrice = qli.Total_Usage__c * qli.Sales_Margin_per_unit__c;
                            System.debug('qli.UnitPrice->'+qli.UnitPrice);
                           i++; 
                        }
                    }
                   
                    QLI_ListToUpdate.add(qli);
                }
            }
        }
        
        update QLI_ListToUpdate;
    }
}