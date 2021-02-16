/***************************************************************************************************************************
* Name:        file_upload_handler 
* Description: Helper class for Account_File_Uploader Component 
* Related Code:UA_UploadQueue
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-11-07        Aress Dev             	Import CSV file data in Utility_Account__c and Price_Upload_Log__c .
* 2020-13-02  		Aress Dev				De-Duplication and Refactorting
* 2020-20-10  		Saurabh Chauhan			Allow inserting of start dates and upserting of Utility Accounts,
                                            if present on same Account.
****************************************************************************************************************************/
public class Account_File_Uploader_Handler {
    // To insert csv file data into object fields.
    @AuraEnabled
    public static string insertData(Blob strfromlex,Id recordId, String FileName){
       
        List<Utility_Account__c> utilityAccountsList = new List<Utility_Account__c>();
        String returnresponse ='';
        Upload_Log__c pul = new Upload_Log__c();
        List<String> inputvalues2 = new List<String>();
        String fileData =strfromlex.toString();
        List<String> errList1 = new List<String>();
        // To split rows of csv files
        List<String> csvFileLines = new List<String>(fileData.split('\n'));
        // To check the column size of csv
        Map<String, String> UAUMap  = new Map <String,String>();
        Map<String, Utility_Account__c> UAIdMap  = new Map <String,Utility_Account__c>();
        Map<String, String> UAStartDateMap  = new Map <String,String>();
        //
        Map<String, String> UAStreetMap  = new Map <String,String>();
        Map<String, String> UAStreet2Map  = new Map <String,String>();
        Map<String, String> UACityMap  = new Map <String,String>();
        Map<String, String> UAStateMap  = new Map <String,String>();
        Map<String, String> UAZipMap  = new Map <String,String>();
        Map<String, String> UACountryMap  = new Map <String,String>();
        //
        try{
        for(Integer i=1, j=csvFileLines.size(); i<j; i++ ){
            inputvalues2 = Base_Class_Uploader.columns_Splitter(csvFileLines[i]);
            UAUMap.put(inputvalues2[0], inputvalues2[1]);
            UAStartDateMap.put(inputvalues2[0],inputvalues2.size() > 2 ? inputvalues2[2] : '');
            UAStreetMap.put(inputvalues2[0],inputvalues2.size() > 3 ? inputvalues2[3] : '');
            UAStreet2Map.put(inputvalues2[0],inputvalues2.size() > 4 ? inputvalues2[4] : '');
            UACityMap.put(inputvalues2[0],inputvalues2.size() > 5 ? inputvalues2[5] : '');
            UAStateMap.put(inputvalues2[0],inputvalues2.size() > 6 ? inputvalues2[6] : '');
            UAZipMap.put(inputvalues2[0],inputvalues2.size() > 7 ? inputvalues2[7] : '');
            UACountryMap.put(inputvalues2[0],inputvalues2.size() > 8 ? inputvalues2[8] : '');    
        }
        
        //State Validation
        if(inputvalues2.size() > 5){
                if(inputvalues2[6].length() > 2){
                    errList1.add('Please enter state in 2-letter format ex.(NY)');
                }
            } 
        
        List<String> UAList12 = new List<String>(UAUMap.keySet());
        list<Utility_Account__c> doesUAExist = [SELECT Id, Name, Account__c,Account__r.name FROM Utility_Account__c];
        
      
        if(inputvalues2.size() <= 9){
            List<Account> utilities =[SELECT Id, Utility_Account_Number_Length__c, Utility_Account_Number_Prefix__c, Name  FROM Account WHERE Name =: UAUMap.Values() AND RecordType.Name = 'Utility'];
            if(!utilities.isEmpty()){
                for(Integer i=0; i<UAUMap.size(); i++){
                    for(account a: utilities ){
                        if(UAUMAP.values()[i] == a.Name){
                            if(a.Utility_Account_Number_Prefix__c != NULL){
                                if(UAList12[i].length() > a.Utility_Account_Number_Length__c || UAList12[i].startsWith(a.Utility_Account_Number_Prefix__c) == false || UAList12[i].length() < a.Utility_Account_Number_Length__c) // for Account Number
                                {
                                    errList1.add(' Validation has failed for account number '+ UAList12[i] +' for Utility: ' +a.Name + ' , format should be: ' + a.Utility_Account_Number_Prefix__c+' as Prefix with length' +a.Utility_Account_Number_Length__c +'.' );
                                }
                                else if(UAUMAP.values()[i].length() > 80 || UAUMAP.values()[i].length() < 1 )
                                {
                                    errList1.add(' Row No. '+ i + '. Please enter valid Utility value.');
                                }
                            }
                            else{
                                if(UAList12[i].length() > a.Utility_Account_Number_Length__c || UAList12[i].length() < a.Utility_Account_Number_Length__c) // for Account Number
                                {
                                    errList1.add(' Validation has failed for account number '+ UAList12[i] +' for Utility ' +a.Name + ' , format should be account number with length  '  +a.Utility_Account_Number_Length__c+ '.'  );
                                    
                                }
                                else if( UAUMAP.values()[i].length() > 80 ||  UAUMAP.values()[i].length() < 1 )
                                {
                                    errList1.add(' Row No. '+ i + '. Please enter valid Utility value.');
                                }
                            }
                           
                            
                        }
                    }
                }
            }
        }
        else {
            errList1.add('You are uploading wrong csv file.');
        }
        
        for(Utility_Account__c UAAccToCheck : doesUAExist){
            UAIdMap.put(UAAccToCheck.Name,UAAccToCheck);
            
        }
        
        if(errList1.size() == 0){
            
            List<Account> utilities =[select Id, Utility_Account_Number_Length__c	, Utility_Account_Number_Prefix__c, Name  from Account where Name =: UAUMap.Values() AND RecordType.Name = 'Utility'];
            for(Integer i=0; i<UAUMap.size(); i++ ){
                
                if(UAIdMap.containsKey(UAList12[i]) && UAIdMap.get(UAList12[i]).Account__c!=recordId){  
                                    errList1.add('The file was not loaded because Utility Account- '+UAList12[i]+' is already in the system on Account- '+UAIdMap.get(UAList12[i]).Account__r.name);
                                    returnresponse = 'A Utility Account is already in the system. Please check the Upload Logs for more details.';
                                }
                
                Utility_Account__c uaObj = new Utility_Account__c();
                if(UAIdMap.containsKey(UAList12[i])){
                   uaObj.Id = UAIdMap.get(UAList12[i]).Id; 
                }
                uaObj.Account__c = recordId;
                uaObj.Name = UAList12[i];
                uaObj.Street__c = UAStreetMap.get(UAList12[i]);
                uaObj.Street_2__c = UAStreet2Map.get(UAList12[i]);
                uaObj.City__c = UACityMap.get(UAList12[i]);
                uaObj.State__c = UAStateMap.get(UAList12[i]);
                uaObj.Zip__c = UAZipMap.get(UAList12[i]);
                uaObj.Country__c = UACountryMap.get(UAList12[i]);     
                if(!test.isRunningTest()){
                    if(UAStartDateMap.get(UAList12[i])!=''){
                        uaObj.Requested_Start_Date__c = Date.valueOf(UAStartDateMap.get(UAList12[i]));
                    }
                }
                for(account a: utilities ){
                    if(UAUMap.Values()[i] == a.Name)
                        uaObj.Utility__c = a.id;
                }
                
                utilityAccountsList.add(uaObj);
            }
            if(errList1.size() == 0){
                 upsert utilityAccountsList;
            }
        } 
        
    
        }catch(exception e){
            if(errList1.isEmpty()){
                errList1.add(e.getMessage());
            }
        }
        
       
          UA_UploadQueue intog = new UA_UploadQueue(recordId,errList1,strfromlex,FileName);
            System.enqueueJob(intog);
        if(errList1.size() > 0){
            returnresponse = 'Upload Failed, Please check the upload logs for more details.';
        }
        return returnresponse;
    }
    
}