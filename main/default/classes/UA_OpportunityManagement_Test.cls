/*
* @Purpose: Test class for UA_OpportunityManagement_Handler.
* @Author: Rahul Ghaytadak
* @CreatedDate: 1/18/2021
* @Related Code: UA_OpportunityManagement_Handler
* @LastModifiedDate: 2/10/2021
* @LastModifiedBy: Rahul Ghaytadak
*/
@IsTest
public class UA_OpportunityManagement_Test {
    public static testMethod void setupMethod(){
        list<Utility_Account_Opportunity__c> UAO_lst= new list<Utility_Account_Opportunity__c> ();
        list<Utility_Account__c> UA_lst= new list<Utility_Account__c> ();
        
         Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc1= new Account();
        acc1.Name = 'PPL';
        acc1.RecordTypeId = id1;
       // acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = acc1.Id;
        //objCon.Status = 'Live';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = acc1.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        Opportunity objOpp = new Opportunity();
        objOpp.State__c = 'NY';
        objOpp.AccountId = acc1.Id;
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = acc1.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Utility_Account__c ua = new Utility_Account__c();
        ua.Name = '0776033008';
        ua.Account__c = acc1.Id;
        ua.Utility__c = acc1.Id;
        ua.Street__c ='street 43';
        ua.City__c ='Test';
        ua.State__c = 'NY';
        ua.zip__c ='343438';
        ua.Country__c = 'US';
        //ua.Service_Address__c = '';
        ua.Zone__c = 'E';
        UA_lst.add(ua);
        insert UA_lst;
        
        StaticResource sr = [select body from StaticResource where name='UA_Account_File_ForTest'];
        blob csvfile = sr.body;
        List<String> errorLog1 = new List<String>();
        errorLog1.add('error 1');
        errorLog1.add('error 2');
        
        try{
            Base_Class_Uploader.createUploadLog(acc1.Id, errorLog1,'Account');
            Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
			UA_OpportunityManagement_Handler.insertData(csvfile,objOpp.Id,'file.csv',acc1.Id);     
            UA_OpportunityManagement_Handler.insertUAandUAO(UAO_lst,UAO_lst, UA_lst, acc1.Id, objOpp.Id);
            
        }catch(Exception e){}

    }     
    
    public static testMethod void setupMethod1(){
        list<Utility_Account_Opportunity__c> UAO_lst= new list<Utility_Account_Opportunity__c> ();
        list<Utility_Account__c> UA_lst= new list<Utility_Account__c> ();
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc1= new Account();
        acc1.Name = 'PPL';
        acc1.Utility_Account_Number_Length__c  =10;
        acc1.RecordTypeId = id1;
        insert acc1;
        
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        acc2.State__c = 'NY';
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;

        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = acc1.Id;
        //objCon.Status = 'Live';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = acc1.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        Opportunity objOpp = new Opportunity();
        objOpp.State__c = 'NY';
        objOpp.AccountId = acc1.Id;
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = acc1.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Utility_Account__c ua = new Utility_Account__c();
        ua.Name = '0776033008';
        ua.Account__c = acc1.Id;
        ua.Utility__c = acc2.Id;
        ua.Street__c ='street 43';
        ua.City__c ='Test';
        ua.State__c = 'NY';
        ua.zip__c ='343438';
        ua.Country__c = 'US';
        //ua.Service_Address__c = '';
        ua.Zone__c = 'E';
        UA_lst.add(ua);
        insert UA_lst;
        
        Date myDate = date.newInstance(2020,01,17);
        Utility_Account_Opportunity__c uao = new Utility_Account_Opportunity__c();
        uao.Opportunity__c = objOpp.Id;
        uao.Utility_Account__c = ua.Id;
        uao.Start_Date__c = myDate;
        uao.Status__c = 'Priced';
        UAO_lst.add(uao);
        insert UAO_lst;
        
        
        
        // To test correct data by inserting csv file with correct data 
        StaticResource sr1 = [select body from StaticResource where name='UA_Account_File_ForTest'];
        blob csvfile1 = sr1.body;
        
        List<String> errorLog = new List<String>();
        test.startTest();
        try{
            Base_Class_Uploader.createUploadLog(acc1.Id, errorLog,'Account');
             Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
            UA_OpportunityManagement_Handler.insertData(csvfile1,objOpp.Id,'file.csv',acc1.Id);     
            UA_OpportunityManagement_Handler.insertUAandUAO(UAO_lst,UAO_lst, UA_lst, acc1.Id, objOpp.Id);

        }catch(Exception e){}
        test.stopTest();
    }
    
}