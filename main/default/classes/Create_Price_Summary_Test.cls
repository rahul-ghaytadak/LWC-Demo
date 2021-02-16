@isTest
public class Create_Price_Summary_Test {
    
    public static testMethod void setupMethod(){
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        insert acc1;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        Contact con = new Contact();
        con.FirstName = 'Con First';
        con.LastName = 'Test Last';
        con.AccountId = acc2.Id;
        insert con;
        
        acc2.Primary_Contact__c = con.Id;
        update acc2;
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.AccountId = acc1.id;
        opp.CloseDate = system.today();
        opp.StageName ='Proposal';
        opp.Broker__c = acc2.id;
        opp.ContactId = con.Id;
        insert opp;
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = acc1.Id;
        objUA.Name = 'TST4567890';
        objUA.Utility__c = acc2.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        objUA.Annual_Usage_kWh__c = 152000;
        insert objUA;
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = opp.Id;
        prlst.add(pr);
        insert prlst;
        Utility_Account_Opportunity__c objUAO3 = new Utility_Account_Opportunity__c();
        objUAO3.Utility_Account__c = objUA.Id;
        objUAO3.Twelve_Month_Price__c = 1200;
        objUAO3.Opportunity__c = opp.Id;
        objUAO3.Status__c = 'Priced';
        insert objUAO3;
        list<id> prid = new  list<id>();
        for(Price__c pr1:[select Id,Price_Type__c from Price__c limit 1]){
            prid.add(pr1.Id);
        }
        system.debug('id-->'+prid);
        List<Term_Price__c> tp = new List<Term_price__c>();
        for(Integer i=0; i<36;i++){
            Term_Price__c tp1 = new Term_Price__c();
            tp1.Price__c = pr.Id;
            tp1.Cumulative_Volume__c = 2500;
            tp1.Base_Price__c = 1.555;
            tp1.Term__c = string.valueOf(i +1);
            tp1.Utility__c = acc2.Id;
            tp1.Volume__c = 5;
            tp1.Utility_Account_Opportunity__c = objUAO3.Id;
            tp1.Opportunity__c = opp.Id;
            tp.add(tp1);
        }
        insert tp;
        Create_Price_Summary.getTermPrice(prid);
        Create_Price_Summary_Asynchronous.getTermPriceAsync(prid);
        Call_Create_Price_Summary.getTermPriceRecords(prid,tp);
    }
}