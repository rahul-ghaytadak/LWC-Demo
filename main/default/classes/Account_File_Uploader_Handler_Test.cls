/***************************************************************************************************************************
* Name:        Account_File_Uploader_Handler_Test 
* Description: Test class of Account_File_Uploader_Handler class.
* 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-11-04       Aress Dev  				To testing the functionality of class.   
* 2020-22-10       Saurabh Chauhan			To test the functionality of class.   
****************************************************************************************************************************/
@IsTest
public class Account_File_Uploader_Handler_Test {
    public static testMethod void setupMethod(){
         Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc1= new Account();
        acc1.Name = 'Aress Utility';
        acc1.RecordTypeId = id1;
        acc1.Utility_Account_Number_Prefix__c  = 'TST';
        insert acc1;
        
        StaticResource sr = [select body from StaticResource where name='acc_file_uploader'];
        blob csvfile = sr.body;
        List<String> errorLog1 = new List<String>();
        errorLog1.add('error 1');
        errorLog1.add('error 2');
        
        try{
            Base_Class_Uploader.createUploadLog(acc1.Id, errorLog1,'Account');
            Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
            Account_File_Uploader_Handler.insertData(csvfile,acc1.Id,'file.csv');
            
        }catch(Exception e){}

    }     
    
    public static testMethod void setupMethod1(){
        Id id1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Utility').getRecordTypeId();
        Account acc1= new Account();
        acc1.Name = 'Aress Utility';
        acc1.Utility_Account_Number_Length__c  = 3;
        acc1.RecordTypeId = id1;
        insert acc1;

        // To test correct data by inserting csv file with correct data 
        StaticResource sr1 = [select body from StaticResource where name='acc_file_uploader'];
        blob csvfile1 = sr1.body;
        
        List<String> errorLog = new List<String>();
        test.startTest();
        try{
            Base_Class_Uploader.createUploadLog(acc1.Id, errorLog,'Account');
             Boolean isnum = Base_Class_Uploader.isNumeric('s');
            Boolean isDate = Base_Class_Uploader.isDate('21/02/2019');
            Account_File_Uploader_Handler.insertData(csvfile1,acc1.Id,'file.csv');     

        }catch(Exception e){}
        test.stopTest();
    }
    
}