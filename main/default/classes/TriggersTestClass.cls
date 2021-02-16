@isTest
public class TriggersTestClass {

    public static testmethod void method1(){
        Id testGroupID;
        Id testGroup2ID;
        System.runAs(new User(Id=UserInfo.getUserId())){
            Group testGroup = new Group(Name='Pricing_Team', Type='Queue');
            insert testGroup;
            QueueSobject q1 = new QueueSobject(QueueId = testGroup.Id, sObjectType='Pricing_Request__c');
            Insert q1;
            testGroupID = testGroup.Id;
            Group testGroup2 = new Group(Name='Credit_Team', Type='Queue');
            insert testGroup2;
            QueueSobject q2 = new QueueSobject(QueueId = testGroup2.Id, sObjectType='Pricing_Request__c');
            Insert q2;
            testGroup2ID = testGroup2.Id;
        }
                Account objAcc = new Account(Name = 'Account Test');
        objAcc.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where DeveloperName = 'Utility'].Id;
        insert objAcc;
        
        Contract objCon = new Contract();
        objCon.ContractTerm = 4;
        objCon.StartDate = system.today().addMonths(-1);
        objCon.AccountId = objAcc.Id;
        //objCon.Status = 'Live';
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
        objOpp.ContractId = objCon.Id;
        objOpp.Name = 'Oppo Test';
        objOpp.StageName = 'New';
        objOpp.CloseDate = system.today().addMonths(1);
        objOpp.Broker__c = objAcc.id;
        objOpp.ContactId = objContact.Id;
        insert objOpp;
        
        Pricing_Request__c prObj = new Pricing_Request__c();
        prObj.Opportunity__c=objOpp.Id;
        prObj.Request_Type__c = 'Refresh';
        probj.Start_Date__c = Date.valueOf(System.now());
        probj.OwnerId = testGroupID;
        probj.Due_Date__c = Date.valueOf(System.now()+3);
        probj.RecordTypeId = Schema.SObjectType.Pricing_Request__c.getRecordTypeInfosByName().get('Credit Check Required').getRecordTypeId();
        insert probj;
        
        Pricing_Request__c prObj2 = new Pricing_Request__c();
        prObj2.Opportunity__c= objOpp.Id;
        prObj2.Request_Type__c = 'Refresh';
        probj.OwnerId = testGroup2ID;
        prObj2.Start_Date__c = Date.valueOf(System.now());
        prObj2.Due_Date__c = Date.valueOf(System.now()+3);
        prObj2.RecordTypeId = Schema.SObjectType.Pricing_Request__c.getRecordTypeInfosByName().get('Default Pricing Request').getRecordTypeId();
        insert prObj2;
        
        Credit_Check__c cc = new Credit_Check__c(Opportunity__c = objOpp.Id, Pricing_Request__c = probj.Id, Status__c = 'Active', Credit_Check_Outcome__c = 'Passed');
        Insert cc;
        
        Test.startTest();
        probj.Status__c = 'Pricing';
        Update probj;
        prObj2.Status__c = 'HU Complete';
        Update prObj2;
        Credit_Check__c cc2 = new Credit_Check__c(Opportunity__c = objOpp.Id, Pricing_Request__c = probj.Id, Status__c = 'Active', Credit_Check_Outcome__c = 'Passed');
        Insert cc2;
        Test.stopTest();
    }
}