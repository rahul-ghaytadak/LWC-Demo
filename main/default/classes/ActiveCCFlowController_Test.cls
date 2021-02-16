/*
* @Purpose: Test class of ActiveCCFlowController.
* @Author: 
* @CreatedDate: 
* @Related Code: ActiveCCFlowController
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
@isTest
public class ActiveCCFlowController_Test {
    public static testMethod void setupMethod(){

        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Account objAcc = new Account(Name = 'Aramark Food',Marketer_Code__c= '123',Utility_DUNS__c = '117066176',BillingStreet= '',BillingCity='Philadelphia',BillingState='PA',BillingPostalCode='0517614');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;

        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Commodity__c = '';
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
       	objPR.Bill_Type__c = 'Dual';
        objPR.Opportunity__c = objOpp.Id;
        objPR.Status__c = 'New';
        Insert objPR;

        Credit_Check__c cc = new Credit_Check__c();
        cc.Pricing_Request__c = objPR.Id;
        cc.Customer__c = objAcc.Id;
        cc.Status__c = 'Active';
        cc.FSR_Score__c=10;
            cc.IP_Score__c=6;
        cc.Opportunity__c =objOpp.Id;
        insert cc;

        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;  
        objUAP.Start_Date__c= system.today();
		Insert objUAP;
        
        
        
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        prlst.add(pr);
        insert prlst;
        
        
        test.startTest();
        ActiveCCFlowController.getCcId(objOpp.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        ActiveCCFlowController.getPremiums(cc.Id);
        ActiveCCFlowController.getCcheckId(objPR.Id);
        test.stopTest();
    }
    public static testMethod void setupMethod1(){

        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Account objAcc = new Account(Name = 'Aramark Food',Marketer_Code__c= '123',Utility_DUNS__c = '117066176',BillingStreet= '',BillingCity='Philadelphia',BillingState='PA',BillingPostalCode='0517614');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;

        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Commodity__c = '';
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
       	objPR.Bill_Type__c = 'Dual';
        objPR.Opportunity__c = objOpp.Id;
        objPR.Status__c = 'New';
        Insert objPR;

        Credit_Check__c cc = new Credit_Check__c();
        cc.Pricing_Request__c = objPR.Id;
        cc.Customer__c = objAcc.Id;
        cc.Status__c = 'Active';
        cc.FSR_Score__c=11;
            cc.IP_Score__c=40;
        cc.Opportunity__c =objOpp.Id;
        insert cc;

        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;  
        objUAP.Start_Date__c= system.today();
		Insert objUAP;
        
        
        
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        prlst.add(pr);
        insert prlst;
        
        
        test.startTest();
        ActiveCCFlowController.getCcId(objOpp.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        ActiveCCFlowController.getPremiums(cc.Id);
        ActiveCCFlowController.getCcheckId(objPR.Id);
        test.stopTest();
    }
    public static testMethod void setupMethod2(){

        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Account objAcc = new Account(Name = 'Aramark Food',Marketer_Code__c= '123',Utility_DUNS__c = '117066176',BillingStreet= '',BillingCity='Philadelphia',BillingState='PA',BillingPostalCode='0517614');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;

        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Commodity__c = '';
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
       	objPR.Bill_Type__c = 'Dual';
        objPR.Opportunity__c = objOpp.Id;
        objPR.Status__c = 'New';
        Insert objPR;

        Credit_Check__c cc = new Credit_Check__c();
        cc.Pricing_Request__c = objPR.Id;
        cc.Customer__c = objAcc.Id;
        cc.Status__c = 'Active';
        cc.FSR_Score__c=40;
            cc.IP_Score__c=40;
        cc.Opportunity__c =objOpp.Id;
        insert cc;

        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;  
        objUAP.Start_Date__c= system.today();
		Insert objUAP;
        
        
        
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        prlst.add(pr);
        insert prlst;
        
        
        test.startTest();
        ActiveCCFlowController.getCcId(objOpp.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        ActiveCCFlowController.getPremiums(cc.Id);
        ActiveCCFlowController.getCcheckId(objPR.Id);
        test.stopTest();
    }
    public static testMethod void setupMethod3(){

        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Account objAcc = new Account(Name = 'Aramark Food',Marketer_Code__c= '123',Utility_DUNS__c = '117066176',BillingStreet= '',BillingCity='Philadelphia',BillingState='PA',BillingPostalCode='0517614');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;

        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Commodity__c = '';
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
       	objPR.Bill_Type__c = 'Dual';
        objPR.Opportunity__c = objOpp.Id;
        objPR.Status__c = 'New';
        Insert objPR;

        Credit_Check__c cc = new Credit_Check__c();
        cc.Pricing_Request__c = objPR.Id;
        cc.Customer__c = objAcc.Id;
        cc.Status__c = 'Active';
        cc.FSR_Score__c=53;
            cc.IP_Score__c=60;
        cc.Opportunity__c =objOpp.Id;
        insert cc;

        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;  
        objUAP.Start_Date__c= system.today();
		Insert objUAP;
        
        
        
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        prlst.add(pr);
        insert prlst;
        
        
        test.startTest();
        ActiveCCFlowController.getCcId(objOpp.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        ActiveCCFlowController.getPremiums(cc.Id);
        ActiveCCFlowController.getCcheckId(objPR.Id);
        test.stopTest();
    }
    public static testMethod void setupMethod4(){

        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Account objAcc = new Account(Name = 'Aramark Food',Marketer_Code__c= '123',Utility_DUNS__c = '117066176',BillingStreet= '',BillingCity='Philadelphia',BillingState='PA',BillingPostalCode='0517614');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;

        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Commodity__c = '';
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
       	objPR.Bill_Type__c = 'Dual';
        objPR.Opportunity__c = objOpp.Id;
        objPR.Status__c = 'New';
        Insert objPR;

        Credit_Check__c cc = new Credit_Check__c();
        cc.Pricing_Request__c = objPR.Id;
        cc.Customer__c = objAcc.Id;
        cc.Status__c = 'Active';
        cc.FSR_Score__c=100;
            cc.IP_Score__c=100;
        cc.Opportunity__c =objOpp.Id;
        insert cc;

        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;  
        objUAP.Start_Date__c= system.today();
		Insert objUAP;
        
        
        
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        prlst.add(pr);
        insert prlst;
        
        
        test.startTest();
        ActiveCCFlowController.getCcId(objOpp.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        ActiveCCFlowController.getPremiums(cc.Id);
        ActiveCCFlowController.getCcheckId(objPR.Id);
        test.stopTest();
    }
    public static testMethod void setupMethod5(){

        HU_Api_Call__c huObj = new HU_Api_Call__c();
        huObj.Call_AWS__c = false;
        huObj.Call_Azure__c = false;
        insert huObj;
        
        Account objAcc = new Account(Name = 'Aramark Food',Marketer_Code__c= '123',Utility_DUNS__c = '117066176',BillingStreet= '',BillingCity='Philadelphia',BillingState='PA',BillingPostalCode='0517614');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;

        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Draft';
        insert objCon;
        
        Contact objContact = new Contact();
        objContact.LastName = 'Test Lastname';
        objContact.AccountId = objAcc.Id;
        objContact.Phone = '1234567890';
        insert objContact;
        
        objAcc.Primary_Contact__c = objContact.Id;
        update objAcc;
        
        Opportunity objOpp = new Opportunity();
        objOpp.AccountId = objAcc.Id;
        objOpp.Commodity__c = '';
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Utility_Account__c objUA = new Utility_Account__c();
        objUA.Account__c = objAcc.Id;
        objUA.Name = '1234567890';
        objUA.Utility__c = objAcc.Id;
        objUA.Street__c = 'Street';
        objUA.City__c = 'City';
        objUA.State__c = 'NY';
        objUA.Country__c = 'US';
        objUA.Zip__c = '123456';
        Insert objUA;
        
        Pricing_Request__c objPR = new Pricing_Request__c();
       	objPR.Bill_Type__c = 'Dual';
        objPR.Opportunity__c = objOpp.Id;
        objPR.Status__c = 'New';
        Insert objPR;

        Credit_Check__c cc = new Credit_Check__c();
        cc.Pricing_Request__c = objPR.Id;
        cc.Customer__c = objAcc.Id;
        cc.Status__c = 'Active';
        cc.FSR_Score__c=70;
            cc.IP_Score__c=70;
        cc.Opportunity__c =objOpp.Id;
        insert cc;

        
        Utility_Account_Pricing__c objUAP = new Utility_Account_Pricing__c();
        objUAP.Utility_Account__c = objUA.Id;
        objUAP.Pricing_Request__c = objPR.Id;  
        objUAP.Start_Date__c= system.today();
		Insert objUAP;
        
        
        
        
        List<Price__c> prlst = new List<Price__c>();
        Price__c pr = new Price__c();
        pr.Price_Type__c = 'Quote';
        pr.Opportunity__c = objOpp.Id;
        prlst.add(pr);
        insert prlst;
        
        
        test.startTest();
        ActiveCCFlowController.getCcId(objOpp.Id);
        ActiveCCFlowController.getPremiums1(objPR.Id);
        ActiveCCFlowController.getPremiums(cc.Id);
        ActiveCCFlowController.getCcheckId(objPR.Id);
        test.stopTest();
    }
    
}