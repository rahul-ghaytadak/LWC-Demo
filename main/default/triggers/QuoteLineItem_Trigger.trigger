trigger QuoteLineItem_Trigger on QuoteLineItem (after insert,after update) {
    
    Trigger_Settings__c settings = Trigger_Settings__c.getInstance('QuoteLineItem_Trigger');
    Boolean triggerOn = settings.TriggerOn__c;
    
    if(RecursiveTriggerHandler.isFirstTime && triggerOn){
        RecursiveTriggerHandler.isFirstTime = false;
        Set<Id> QuoteIds = new Set<Id>(); 
        for(QuoteLineItem qli: Trigger.New){
            QuoteIds.add(qli.QuoteId);
        }
        if(trigger.isAfter && trigger.isUpdate || trigger.isAfter && trigger.isInsert ){
            QuoteLineItem_Trigger_Handler.QLIupdate(QuoteIds);
        }
    }
}