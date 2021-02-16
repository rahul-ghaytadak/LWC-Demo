/*
* @Purpose: Update Utility Accounts End Date when Contract is Created/updated.
* @Author: Rahul Ghaytadak
* @CreatedDate: 
* @Related Code: Trigger_UpdateContractEndDate
* @Test Class: Update_contractEndDate_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class Trigger_UpdateContractEndDateHandler {
	@InvocableMethod(label='Get Contracts' description='Update Utility Accounts contract End Date' )
    public Static void updateContractEndDate(List<Contract> Contract_Id){
        Set<Id> contractList = new Set<Id>();
        Set<Id> UAIds = new Set<Id>();
        Set<Id> Cont_Ids = new Set<Id>();
        for(Contract cont : Contract_Id){
            Cont_Ids.add(cont.Id);
        }
        List<Utility_Account__c> UAListToUpdate = new List<Utility_Account__c>();
        //Retrieve Utility Account Contracts related to Contracts
        List<Utility_Account_Contract__c> UAC = [SELECT Id, Utility_Account__c, Contract__c,Status__c  FROM Utility_Account_Contract__c 
                                                 Where Contract__c =: Cont_Ids];
        if(UAC.size()>0){
            for(Utility_Account_Contract__c Ua_cont : UAC){
                UAIds.add(Ua_cont.Utility_Account__c);
            }
            //Retrieve Utility Account related to Contracts
            List<Utility_Account__c> UAList = [SELECT Id, Account_Active_Date__c, Contract_End_Date__c FROM Utility_Account__c Where Id=:UAIds];
            //Retrieve Contracts
            List<Contract> contrct = [SELECT Id, StartDate, Status, ContractTerm FROM Contract Where Id=:Cont_Ids And ContractTerm != null order by StartDate desc];
            if(contrct.size()>0){
                for(Utility_Account__c Ua : UAList){
                    if(Ua.Account_Active_Date__c != null && contrct[0].ContractTerm != null){
                        //Ua.Contract_End_Date__c = Ua.Account_Active_Date__c.date() + (contrct[0].ContractTerm / 12 * 365);
                        decimal divideValue = decimal.valueOf(contrct[0].ContractTerm).divide(12, 2) * 365;
                        Ua.Contract_End_Date__c = Ua.Account_Active_Date__c.date() + divideValue.round(System.RoundingMode.UP);
                        UAListToUpdate.add(Ua);  
                    }
                }
                if(UAListToUpdate.size()>0){
                    update UAListToUpdate;
                }
            }
        }            
    }
}