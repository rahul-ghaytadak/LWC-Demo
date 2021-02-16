/***************************************************************************************************************************
* Name:        file_upload_handler_Test 
* Description: Test class of file_upload_handler class.
* 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-11-04       Aress Dev  				To testing the functionality of class.   	  
****************************************************************************************************************************/

@IsTest
public class file_upload_handler_Test {
    
    public static testMethod void setupMethod(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        Price_File_Validation__c addValidation = new Price_File_Validation__c();
        addValidation.Validate__c = true;
        insert addValidation;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        Contact con = new Contact();
        con.FirstName = 'Con First';
        con.LastName = 'Test Last';
        con.AccountId = acc2.Id;
        insert con;
        
        acc2.Primary_Contact__c = con.Id;
        update acc2;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = acc1.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.AccountId = acc2.id;
        opp.ContractId = objCon.Id;
        opp.CloseDate = system.today().addMonths(1);
        opp.StageName ='New';
        opp.Broker__c = acc2.id;
        opp.ContactId = con.Id;
        opp.Price_Request_Count__c = 2;
        insert opp;
        system.debug('opp======='+opp);
        
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        
     /*   RecordType rtToinsert = new RecordType();
        rtToinsert.SobjectType = 'Pricing_Request__c';
        rtToinsert.Name = 'Default_Pricing_Request';
        insert rtToinsert;*/
        
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'Dual';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c = 100;
        insert pr;
        Date myDate = date.newInstance(2020,01,17);
         Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '1234567890';
        ua1.Account__c = acc1.Id;
        ua1.Utility__c = acc2.Id;
        insert ua1;
        
         Utility_Account_Pricing__c uapr = new Utility_Account_Pricing__c();
         uapr.Pricing_Request__c = pr.Id;
       
        uapr.Start_Date__c = myDate;
        uapr.Utility_Account__c = ua1.Id;
        
        insert uapr;
        
        system.debug('pr======='+pr);
        Utility_Account__c ua = new Utility_Account__c();
        ua.Name = '1234567891';
        ua.Account__c = acc1.Id;
        ua.Utility__c = acc2.Id;
        ua.Street__c ='street 43';
        ua.City__c ='Test';
        ua.State__c = 'NY';
        ua.zip__c ='343438';
        ua.Country__c = 'US';
        //ua.Service_Address__c = '';
        ua.Zone__c = 'E';
        insert ua;
        
        Utility_Account_Opportunity__c uao = new Utility_Account_Opportunity__c();
        uao.Opportunity__c = opp.Id;
        uao.Utility_Account__c = ua1.Id;
        uao.Start_Date__c = myDate;
        uao.Status__c = 'Priced';
        insert uao;
        
      
        
        // To test correct data by inserting csv file with correct data
        StaticResource sr = [select body from StaticResource where name='file_upload_csv'];
        blob csvfile = sr.body;
        
            Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
            file_upload_handler.insertData(csvfile,pr.Id,'file.csv',true);
        
        // To test incorrect data by inserting csv file with incorrect data
        StaticResource sr1 = [select body from StaticResource where name='final_upload_err'];
        blob csvfile1 = sr1.body;
             Boolean isnum2 = Base_Class_Uploader.isNumeric('s');
            Boolean isDate2 = Base_Class_Uploader.isDate('21/02/2019');
            file_upload_handler.insertData(csvfile1,pr.Id,'file1.csv',true);
            
     test.stopTest();
    }
    
    public static testMethod void setupMethod1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
         Price_File_Validation__c addValidation = new Price_File_Validation__c();
        addValidation.Validate__c = true;
        insert addValidation;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        Contact con = new Contact();
        con.FirstName = 'Con First';
        con.LastName = 'Test Last';
        con.AccountId = acc2.Id;
        insert con;
        
        acc2.Primary_Contact__c = con.Id;
        update acc2;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = acc1.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.AccountId = acc2.id;
        opp.ContractId = objCon.Id;
        opp.CloseDate = system.today().addMonths(1);
        opp.StageName ='New';
        opp.Broker__c = acc2.id;
        opp.ContactId = con.Id;
        opp.Price_Request_Count__c = 2;
        insert opp;
        system.debug('opp======='+opp);
        
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        
     /*   RecordType rtToinsert = new RecordType();
        rtToinsert.SobjectType = 'Pricing_Request__c';
        rtToinsert.Name = 'Default_Pricing_Request';
        insert rtToinsert;*/
        
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'UCB';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        pr.Voluntary_RECs__c = 'Any';
        pr.Voluntary_RECs_percent__c=50;
        insert pr;
        Date myDate = date.newInstance(2020,05,17);
         Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '1234567890';
        ua1.Account__c = acc1.Id;
        ua1.Utility__c = acc2.Id;
        insert ua1;
        
         Utility_Account_Pricing__c uapr = new Utility_Account_Pricing__c();
         uapr.Pricing_Request__c = pr.Id;
       
        uapr.Start_Date__c = myDate;
        uapr.Utility_Account__c = ua1.Id;
        
        insert uapr;
        
        system.debug('pr======='+pr);
        Utility_Account__c ua = new Utility_Account__c();
        ua.Name = '1234567891';
        ua.Account__c = acc1.Id;
        ua.Utility__c = acc2.Id;
        ua.Street__c ='street 43';
        ua.City__c ='Test';
        ua.State__c = 'NY';
        ua.zip__c ='343438';
        ua.Country__c = 'US';
        //ua.Service_Address__c = '';
        ua.Zone__c = 'E';
        insert ua;
        
        Utility_Account_Opportunity__c uao = new Utility_Account_Opportunity__c();
        uao.Opportunity__c = opp.Id;
        uao.Utility_Account__c = ua1.Id;
        uao.Start_Date__c = myDate;
        insert uao;
        
      
        
        // To test correct data by inserting csv file with correct data
        StaticResource sr = [select body from StaticResource where name='final_upload_err'];
        blob csvfile = sr.body;
        
            Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
            file_upload_handler.insertData(csvfile,pr.Id,'file.csv',true);
        
        // To test incorrect data by inserting csv file with incorrect data
        StaticResource sr1 = [select body from StaticResource where name='final_upload_err'];
        blob csvfile1 = sr1.body;
             Boolean isnum2 = Base_Class_Uploader.isNumeric('s');
            Boolean isDate2 = Base_Class_Uploader.isDate('21/02/2019');
            file_upload_handler.insertData(csvfile1,pr.Id,'file1.csv',true);
            RT_CSVReader.read(String.valueOf(csvfile1));
     test.stopTest();
    }
    public static testMethod void setupMethod2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        Account acc1= new Account();
        acc1.Name = 'Test Acc';
        //acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        Price_File_Validation__c addValidation = new Price_File_Validation__c();
        addValidation.Validate__c = true;
        insert addValidation;
        
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc2= new Account();
        acc2.Name = 'Test Acc1';
        acc2.RecordTypeId =id1;
        //acc2.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc2;
        
        Contact con = new Contact();
        con.FirstName = 'Con First';
        con.LastName = 'Test Last';
        con.AccountId = acc2.Id;
        insert con;
        
        acc2.Primary_Contact__c = con.Id;
        update acc2;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = acc1.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Opportunity opp = new Opportunity();
        opp.Name='Test Opp';
        opp.AccountId = acc2.id;
        opp.ContractId = objCon.Id;
        opp.CloseDate = system.today().addMonths(1);
        opp.StageName ='New';
        opp.Broker__c = acc2.id;
        opp.ContactId = con.Id;
        opp.Price_Request_Count__c = 2;
        insert opp;
        system.debug('opp======='+opp);
        
        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Product2 prodObj = new Product2(Name='Fully Fixed',ProductCode = '0',Product_Id__c = '0');
        insert prodObj;
        
     /*   RecordType rtToinsert = new RecordType();
        rtToinsert.SobjectType = 'Pricing_Request__c';
        rtToinsert.Name = 'Default_Pricing_Request';
        insert rtToinsert;*/
        
        RecordType rt = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'Pricing_Request__c' AND DeveloperName = 'Default_Pricing_Request' limit 1];
        Pricing_Request__c pr = new Pricing_Request__c();
        pr.Opportunity__c = opp.Id;
        pr.Notes__c = 'Hello';
        pr.Status__c = 'Complete';
        pr.Bill_Type__c = 'UCB';
        pr.RecordTypeId = rt.Id;
        pr.Product_Lookup__c = prodObj.Id;
        insert pr;
        Date myDate = date.newInstance(2020,01,17);
         Utility_Account__c ua1 = new Utility_Account__c();
        ua1.Name = '1234567890';
        ua1.Account__c = acc1.Id;
        ua1.Utility__c = acc2.Id;
        insert ua1;
        
         Utility_Account_Pricing__c uapr = new Utility_Account_Pricing__c();
         uapr.Pricing_Request__c = pr.Id;
       
        uapr.Start_Date__c = myDate;
        uapr.Utility_Account__c = ua1.Id;
        
        insert uapr;
        
        system.debug('pr======='+pr);
        Utility_Account__c ua = new Utility_Account__c();
        ua.Name = '1234567891';
        ua.Account__c = acc1.Id;
        ua.Utility__c = acc2.Id;
        ua.Street__c ='street 43';
        ua.City__c ='Test';
        ua.State__c = 'NY';
        ua.zip__c ='343438';
        ua.Country__c = 'US';
        //ua.Service_Address__c = '';
        ua.Zone__c = 'E';
        insert ua;
        
        Utility_Account_Opportunity__c uao = new Utility_Account_Opportunity__c();
        uao.Opportunity__c = opp.Id;
        uao.Utility_Account__c = ua1.Id;
       // uao.Start_Date__c = myDate;
        uao.Status__c = 'Priced';
        insert uao;
        
      
        
        // To test correct data by inserting csv file with correct data
        StaticResource sr = [select body from StaticResource where name='file_upload_csv'];
        blob csvfile = sr.body;
        
            Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
            file_upload_handler.insertData(csvfile,pr.Id,'file.csv',true);
        
        // To test incorrect data by inserting csv file with incorrect data
        StaticResource sr1 = [select body from StaticResource where name='final_upload_err'];
        blob csvfile1 = sr1.body;
             Boolean isnum2 = Base_Class_Uploader.isNumeric('s');
            Boolean isDate2 = Base_Class_Uploader.isDate('21/02/2019');
            file_upload_handler.insertData(csvfile1,pr.Id,'file1.csv',true);
            
     test.stopTest();
    }
    
    
}