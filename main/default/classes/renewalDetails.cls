public class renewalDetails {
    
    @AuraEnabled
    public static Contract getDetails(Id oppId){
        
        Opportunity opp = [SELECT Id,
                           Existing_Contract__c
                           FROM Opportunity
                           WHERE Id =: oppId];
        
        Contract contractToReturn = [SELECT Id,
                                     StartDate,
                                     ContractTerm,
                                     Output_Total_Unit_Price__c,
                                     Opportunity__r.Point_of_Sale_SEUS_Margin__c,
                                     Opportunity__r.Broker_Margin_per_unit__c
                                     FROM Contract
                                     WHERE Id =: opp.Existing_Contract__c];
        return contractToReturn;
        
    }

}