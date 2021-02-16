public class AlertController {
    
    @auraEnabled
    public static List<String> customerAccountAlert(Id recordId){
        Set<String> ownerNames = new Set<String>();
        String sObjName = recordId.getSObjectType().getDescribe().getName();
		if(sObjName == 'Opportunity')
            recordId = [SELECT Id, AccountId FROM Opportunity WHERE Id=: recordId].AccountId;
        List<Opportunity> customerOpps = [SELECT id, Name, Owner.Name FROM Opportunity WHERE AccountId =: recordId AND StageName != 'Closed Won' AND StageName != 'Closed Lost' AND OwnerId !=: USerInfo.getUserId()];
        for(Opportunity opp:customerOpps){
            ownerNames.add(opp.Owner.Name);
        }
        List<String> setOfOwnerNames = new List<String>(ownerNames);
        system.debug('setOfOwnerNames' +setOfOwnerNames);
        return setOfOwnerNames;
    }
}