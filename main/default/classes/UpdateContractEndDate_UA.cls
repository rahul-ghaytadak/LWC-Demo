/*
* @Purpose: Update Utility Accounts contract End Date when Account_Active_Date__c is updated.
* @Author: Rahul Ghaytadak
* @CreatedDate: 
* @Related Code: 
* @Test Class: Update_contractEndDate_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class UpdateContractEndDate_UA {
    @InvocableMethod(label='Get Utility Account' description='Update Utility Accounts contract End Date' )
    public Static void updateContractEndDate(List<Id> UA_Id){
        Set<Id> contractList = new Set<Id>();
        List<Utility_Account__c> UAListToUpdate = new List<Utility_Account__c>();
        //Retrieve Utility Account
        List<Utility_Account__c> UAList = [SELECT Id, Account_Active_Date__c, Contract_End_Date__c FROM Utility_Account__c Where Id=:UA_Id];
        //Retrieve Utility Account Contract related to Utility Account
        List<Utility_Account_Contract__c> UAC = [SELECT Id, Utility_Account__c, Contract__c,Status__c  FROM Utility_Account_Contract__c 
                                                 Where Utility_Account__c =: UA_Id AND Status__c = 'Contracted'];
        system.debug('UAC==>'+UAC);
        if(UAC.size()>0){
            for(Utility_Account_Contract__c UAC_Instance : UAC){
                contractList.add(UAC_Instance.Contract__c);
            }
            //Retrieve Contract related to Utility Account Contract
            List<Contract> contrct = [SELECT Id, StartDate, Status, ContractTerm FROM Contract Where Id=:contractList And ContractTerm != null AND Status ='Live' order by StartDate desc];
             
            if(contrct.size()>0){
                for(Utility_Account__c Ua : UAList){
                    if(Ua.Account_Active_Date__c != null && contrct[0].ContractTerm != null){
                       // Ua.Contract_End_Date__c = Ua.Account_Active_Date__c.date() + (contrct[0].ContractTerm / 12 * 365);
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