trigger PricingRequestTrigger on Pricing_Request__c (before update) {
    Set<Id> parentIds = new Set<Id>();
    List<ID> HUCompleted = new List<ID>();
    List<ID> creditCheck = new List<ID>();
    for(Pricing_Request__c cc: Trigger.New){
        parentIds.add(cc.Opportunity__c);
        if(cc.Status__c == 'HU Complete'){
            HUCompleted.add(cc.Id);
        }
        else if(cc.Status__c == 'Credit Check')
            creditCheck.add(cc.Id);
    }
    List<Credit_Check__c> getCCRecords = [SELECT Id, Credit_Check_Outcome__c, Opportunity__c, Status__c FROM Credit_Check__c WHERE Opportunity__c IN:parentIds AND Credit_Check_Outcome__c = 'Passed'  ];
    if(getCCRecords.isEmpty()){
        Id recordTypeId = Schema.SObjectType.Pricing_Request__c.getRecordTypeInfosByName().get('Credit Check Required').getRecordTypeId();
        for(Pricing_Request__c pr: Trigger.New){
            if(pr.RecordTypeId == recordTypeId && (pr.Status__c == 'Pricing' || pr.Status__c == 'Complete' ))
                pr.addError('Passed Credit Check is required to proceed!');
        }
    }
    if(!HUCompleted.isEmpty()){
                system.debug(' getCCRecords ' + getCCRecords);
        getCCRecords = [SELECT Id, Credit_Check_Outcome__c, Opportunity__c, Status__c FROM Credit_Check__c WHERE Opportunity__c IN:parentIds AND Status__c = 'Active'  ];
            for(Pricing_Request__c pr: Trigger.New ){
                if(HUCompleted.contains(pr.Id)){
                    if(pr.Record_Type_Name__c == 'Credit Check Required'){
                        if(!getCCRecords.isEmpty())
                            pr.Status__c = 'Ready For Pricing';
                    }
                    else
                        pr.Status__c = 'Ready For Pricing';           
                }
            }
    }
    if(!creditCheck.isEmpty()){
        getCCRecords = [SELECT Id, Credit_Check_Outcome__c, Opportunity__c, Status__c FROM Credit_Check__c WHERE Pricing_Request__c IN:Trigger.Newmap.keySet() ];
        if(getCCRecords.isEmpty()){
            for(Pricing_Request__c pr: Trigger.New ){
                if(pr.Record_Type_Name__c == 'Credit Check Required'){
                    if(pr.Status__c == 'Credit Check' || pr.Status__c == 'Pricing' || pr.Status__c == 'Complete'){
                        pr.addError('Credit Scores are not recieved from Experian yet. Please try again after some time.');
                    }
                }
            }
        }
    }
}