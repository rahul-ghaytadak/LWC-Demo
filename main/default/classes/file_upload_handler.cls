/***************************************************************************************************************************
* Name:        file_upload_handler 
* Description: Helper class for File_Uploader Component 
* Last Modified by : Saurabh Chauhan
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-11-07        Aress Dev             	 Import CSV file data in Price__c, Term_Price__c, Utility_Account__c
*											 and Price_Upload_Log__c.  
****************************************************************************************************************************/

public class file_upload_handler {
    
    // To insert csv file data into object fields.
    @AuraEnabled 
    public static String insertData(Blob strfromlex,Id recordId, String FileName,Boolean ToggleValue)
    {
        List<String> lStrings = new List<String>();
        String returnresponse ='';
        Pricing_Request__c PR = [Select id,Opportunity__r.StageName,Opportunity__c from Pricing_Request__c where Id =: recordId];
        List<Utility_Account_Opportunity__c> UAOlst = [SELECT id,Start_Date__c FROM Utility_Account_Opportunity__c where Opportunity__c=:PR.Opportunity__c];
        
        if(PR.Opportunity__r.StageName == 'Closed Won'){
            returnresponse = 'Upload Failed';
            lStrings.add('The file was not loaded as the Opportunity is set to Won.  If you wish to upload the file, please set the Opportunity to Quoting');
            Base_Class_Uploader.createUploadLog(recordId, lStrings,'Pricing Request');
        }
         if(!UAOlst.isEmpty()){
            for(Utility_Account_Opportunity__c UAO : UAOlst){
                if(UAO.Start_Date__c==null)
                {
                    returnresponse = 'Upload Failed , Start dates are missing on Utility Account Opportunities.';
                    break;
                }
            }
            if(returnresponse!=''){
               Base_Class_Uploader.createUploadLog(recordId, new List<String>{returnresponse},'Pricing Request');
            }
        }
        
        if(returnresponse==''){
            
            Batch_CreateCustomObjectRecord b = new Batch_CreateCustomObjectRecord(strfromlex,FileName,recordId,ToggleValue); 
            database.executebatch(b, 1001);
        }
       
    
        
       
        return returnresponse;
    }
    

    
}