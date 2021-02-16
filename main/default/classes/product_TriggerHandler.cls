public class product_TriggerHandler {
    
    
    public static String checkDefaultProduct(String prodFamily){
        List<Product2> prodLstToCheck = new List<Product2>();
        List<Product2> prodLst = new List<Product2>([SELECT Id,Name,Default__c FROM Product2 where Family =:prodFamily AND Default__c = true ]);
          
        if( prodLst.size() > 1 ){
            return 'There is already a default product for the family '+'"'+prodFamily+'"';
        }
        else{
            return '';
        }
        
    }

}