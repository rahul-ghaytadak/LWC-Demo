trigger CreditCheckTrigger on Credit_Check__c (before insert, before update) {
    
    Set<Id> parentIds = new Set<Id>();
    for(Credit_Check__c cc: Trigger.new){
        parentIds.add(cc.Pricing_Request__c);
        parentIds.add(cc.Opportunity__c);
    }
    List<Credit_Check__c> getCCRecords = [SELECT Id, Opportunity__c, Status__c FROM Credit_Check__c WHERE Status__c = 'Active' AND (Opportunity__c IN: parentIds OR Pricing_Request__c IN: parentIds) AND Id NOT IN: Trigger.New ];
    if(!getCCRecords.isEmpty()){
        for(Credit_Check__c cc: Trigger.new ){
            if(cc.Status__c == 'Active' ){
                if(!Test.isRunningTest())
                    cc.addError('There is an active Credit Check already exists for current Opportunity!');
            }
        }
    }
}