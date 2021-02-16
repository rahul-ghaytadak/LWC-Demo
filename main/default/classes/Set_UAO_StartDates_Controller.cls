public class Set_UAO_StartDates_Controller {
    
    public class UAOListWrapper {
        @AuraEnabled public Id UAOId {get;set;}
        @AuraEnabled public String Utility_Account {get;set;}
        @AuraEnabled public  Date Start_Date{get;set;}
        public UAOListWrapper(Id UAOId,String Utility_Account, Date Start_Date){
            this.UAOId = UAOId;
            this.Utility_Account = Utility_Account;
            this.Start_Date = Start_Date;
        }
        public UAOListWrapper(){}
    }
   
    @AuraEnabled 
    public static List<UAOListWrapper> fetchUAOList(Id oppId,List<Id> SelectedUAOs){  
        List<UAOListWrapper> UAOWrapperLst = new List<UAOListWrapper>();
        
        List<Utility_Account__c> UAOLst=[Select Id,Name,Utility__c,Supply_Start_Date__c  from Utility_Account__c where Id IN:SelectedUAOs]; 
        for(Utility_Account__c UAO : UAOLst){
            UAOWrapperLst.add(new UAOListWrapper(UAO.Id,UAO.Name,UAO.Supply_Start_Date__c ));
            
        }
        
        return UAOWrapperLst;
    }
   
    @AuraEnabled
    public static void SaveNewStartDates(List<UAOListWrapper> UAOlst){
        System.debug('UAOLst1-->'+UAOlst[0]);
        System.debug('UAOLst2-->'+UAOlst[1]);
    }
    
}