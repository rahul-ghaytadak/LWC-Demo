trigger product_Trigger on Product2 (after update) {
    
    List<Product2> prodLstToCheck = new List<Product2>();
    String errorMsg = '';
    for( Product2 pr : trigger.new ){
        prodLstToCheck.add(pr);
    }
    
    errorMsg = product_TriggerHandler.checkDefaultProduct(prodLstToCheck[0].Family);
    
    if(errorMsg != ''){
        prodLstToCheck[0].addError(errorMsg);
    }
    
    
}