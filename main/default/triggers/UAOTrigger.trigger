trigger UAOTrigger on Utility_Account_Opportunity__c (after insert) {
    Set<Id> parentIds = new Set<Id>();
    for(Utility_Account_Opportunity__c uao: Trigger.new){
        parentIds.add(uao.Opportunity__c);
    }
    List<Credit_Check__c> getCCRecords = [SELECT Id, Opportunity__c, Status__c FROM Credit_Check__c WHERE Opportunity__c IN: parentIds ];
    if(!getCCRecords.isEmpty()){
        for(Credit_Check__c cc: getCCRecords)
            cc.Status__c = 'Expired';
        Update getCCRecords;
    }
}