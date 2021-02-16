/*
* @Purpose: controller of UA_OpportunityManagement component.
* @Author: Rahul Ghaytadak
* @CreatedDate: 1/18/2021
* @Related Code: 
* @Test Class: UA_OpportunityManagement_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class UA_OpportunityManagement_Handler {
    // To insert csv file data into object fields.
    @AuraEnabled
    public static UA_Response insertData(Blob strfromlex,Id recordId, String FileName,Id AccRecId){
        system.debug('AccRecId==>'+AccRecId);
        system.debug('recordId==>'+recordId);
        
        List<Utility_Account__c> utilityAccountsList = new List<Utility_Account__c>();
        List<Utility_Account_Opportunity__c> UAOLstToInsert = new List<Utility_Account_Opportunity__c>();
        List<Utility_Account_Opportunity__c> UAOLstNotExistAvailToInsert = new List<Utility_Account_Opportunity__c>();
        List<Utility_Account__c> UtilityWillBeUpdated = new List<Utility_Account__c>();
        List<Utility_Account__c> UAStateNotMatch = new List<Utility_Account__c>();
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
        List<UA_UAWithDifferentAcc> UAWithDifferentAccToAdd = new List<UA_UAWithDifferentAcc>();
        
        List<Utility_Account__c> storeUA = new List<Utility_Account__c>();
        set<Account> storeCurrAcc = new set<Account>();
        
        List<String> NewUA = new List<String>();
        String ResponseForUA = '';
        opportunity oppRec = new opportunity();
        String OpportunityState = '';
        //
        List<String> StoreUAIds = new List<String>();
        List<Utility_Account_Opportunity__c> UAOTodelete = new List<Utility_Account_Opportunity__c>();
        set<Id> UAOlstToDelete = new set<Id>();
        Map<Id, Utility_Account_Opportunity__c> UAO_MapCheck  = new Map <Id,Utility_Account_Opportunity__c>();
        List<Utility_Account_Opportunity__c> UAO = new List<Utility_Account_Opportunity__c>();
        
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
            list<Utility_Account__c> doesUAExist = [SELECT Id, Name, Account__c,Account__r.name,Utility_State__c FROM Utility_Account__c];
            
            
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
            system.debug('doesUAExist==>'+doesUAExist);
            for(Utility_Account__c UAAccToCheck : doesUAExist){
                UAIdMap.put(UAAccToCheck.Name,UAAccToCheck);
                
            }
            
            if(errList1.size() == 0){
                Set<ID> UAIds = new Set<ID>();
                Map<String, Utility_Account__c> UAO_Map  = new Map <String,Utility_Account__c>();
                oppRec = [SELECT Id, State__c FROM Opportunity Where Id =: recordId];
                OpportunityState = oppRec.State__c;
                UAO = [SELECT Id, Opportunity__c, Utility_Account__c FROM Utility_Account_Opportunity__c Where Opportunity__c =:recordId ];
                for(Utility_Account_Opportunity__c UAOInstance : UAO){
                    UAIds.add(UAOInstance.Utility_Account__c);
                }
                list<Utility_Account__c> doesUAOExist = [SELECT Id, Name, Account__c,Account__r.name ,Utility_State__c FROM Utility_Account__c Where Id=:UAIds];
                for(Utility_Account__c UAAccToCheck : doesUAOExist){
                    UAO_Map.put(UAAccToCheck.Name,UAAccToCheck);
                }
                List<Account> utilities =[select Id, Utility_Account_Number_Length__c	, Utility_Account_Number_Prefix__c, Name  from Account where Name =: UAUMap.Values() AND RecordType.Name = 'Utility'];
                for(Integer i=0; i<UAUMap.size(); i++ ){
                    system.debug('UAIdMap.get(UAList12[i])==>'+UAIdMap.get(UAList12[i]));
                    if(UAIdMap.containsKey(UAList12[i]) && UAIdMap.get(UAList12[i]).Account__c==AccRecId){
                        if(UAO_Map.containsKey(UAList12[i])){
                            
                            Utility_Account__c uaObj = new Utility_Account__c();
                            if(UAIdMap.containsKey(UAList12[i])){
                                uaObj.Id = UAIdMap.get(UAList12[i]).Id; 
                            }
                            uaObj.Account__c = AccRecId;
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
                            UtilityWillBeUpdated.add(uaObj);
                            StoreUAIds.add(UAList12[i]);
                        }
                        if(UAIdMap.get(UAList12[i]).Utility_State__c == OpportunityState && !(UAO_Map.containsKey(UAList12[i]))){
                            
                            Utility_Account_Opportunity__c ObjUAO = new Utility_Account_Opportunity__c();
                            ObjUAO.Utility_Account__c = UAIdMap.get(UAList12[i]).Id;
                            ObjUAO.Status__c = 'Not Priced';
                            ObjUAO.Opportunity__c = recordId;
                            if(UAStartDateMap.get(UAList12[i])!=''){
                                ObjUAO.Start_Date__c = Date.valueOf(UAStartDateMap.get(UAList12[i]));
                            }
                            UAOLstNotExistAvailToInsert.add(ObjUAO);                            
                        }
                         if(UAIdMap.get(UAList12[i]).Utility_State__c != OpportunityState && !(UAO_Map.containsKey(UAList12[i]))){
                            Utility_Account__c uaObj = new Utility_Account__c();
                            if(UAIdMap.containsKey(UAList12[i])){
                                uaObj.Id = UAIdMap.get(UAList12[i]).Id; 
                            }
                            uaObj.Account__c = AccRecId;
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
                            UAStateNotMatch.add(uaObj);
                        }
                        
                    }
                    else if(!(UAIdMap.containsKey(UAList12[i])) ){
                        
                        Utility_Account__c uaObj = new Utility_Account__c();
                        if(UAIdMap.containsKey(UAList12[i])){
                            uaObj.Id = UAIdMap.get(UAList12[i]).Id; 
                        }
                        uaObj.Account__c = AccRecId;
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
                    else if(UAIdMap.containsKey(UAList12[i]) && UAIdMap.get(UAList12[i]).Account__c != AccRecId){
                        storeUA.add(UAIdMap.get(UAList12[i]));
                        Account acc = new Account();
                        acc.Name = UAIdMap.get(UAList12[i]).Account__r.Name;
                        acc.Id = UAIdMap.get(UAList12[i]).Account__c;
                        storeCurrAcc.add(acc);
                    }
                    
                }
                
                UA_UAWithDifferentAcc wrap = new UA_UAWithDifferentAcc(storeCurrAcc,storeUA);
                UAWithDifferentAccToAdd.add(wrap);   
                
            }
            List<Utility_Account_Opportunity__c> UAOlstOfOpp = [SELECT Id, Opportunity__c, Utility_Account__r.Name FROM Utility_Account_Opportunity__c Where Utility_Account__r.Name =: StoreUAIds ];
            system.debug('UAOlstOfOpp==>'+UAOlstOfOpp);
            for(Utility_Account_Opportunity__c UA_Opp : UAOlstOfOpp){
                UAO_MapCheck.put(UA_Opp.Id,UA_Opp);
            }
            system.debug('UAO_MapCheck==>'+UAO_MapCheck);
            for(Utility_Account_Opportunity__c UA_Opp : UAO){
                if(!(UAO_MapCheck.containsKey(UA_Opp.Id))){
                    UAOlstToDelete.add(UA_Opp.Id);
                }
            }
            system.debug('UAOlstToDelete==>'+UAOlstToDelete);
            UAOTodelete = [SELECT Id, Opportunity__c, Utility_Account__c FROM Utility_Account_Opportunity__c Where Id =: UAOlstToDelete ];
            
        }catch(exception e){
            if(errList1.isEmpty()){
                errList1.add(e.getMessage());
            }
        }
        
        if(errList1.size() > 0){
           // ResponseForUA = 'Upload Failed, Please check the upload logs for more details.';
            ResponseForUA = errList1[0];
            system.debug('ResponseForUA'+ResponseForUA);
        }
        
        return new UA_Response(UAOTodelete, UAOLstNotExistAvailToInsert, utilityAccountsList,/*UAOLstToInsert ,*/UAWithDifferentAccToAdd,UAStateNotMatch,ResponseForUA);
    }
    public class UA_Response{
        @AuraEnabled public List<Utility_Account_Opportunity__c> UARelatedUAOWillBeInseted {get;set;}
        @AuraEnabled public List<Utility_Account__c> UtilityWillBeInserted{get;set;}
        @AuraEnabled public List<Utility_Account_Opportunity__c> UAOTodelete{get;set;}
        @AuraEnabled public List<UA_UAWithDifferentAcc> UAWithDifferentAcc {get;set;}
        @AuraEnabled public List<Utility_Account__c> UAStateNotMatch{get;set;}
        @AuraEnabled public String ResponseForUA{get;set;}
        
        
        public UA_Response(List<Utility_Account_Opportunity__c> UAOTodelete,List<Utility_Account_Opportunity__c> UARelatedUAOWillBeInseted,  List<Utility_Account__c> UtilityWillBeInserted, List<UA_UAWithDifferentAcc> UAWithDifferentAcc,List<Utility_Account__c> UAStateNotMatch,String ResponseForUA){
            this.UAOTodelete = UAOTodelete;
            this.UARelatedUAOWillBeInseted = UARelatedUAOWillBeInseted;
            this.UtilityWillBeInserted = UtilityWillBeInserted;
            this.UAWithDifferentAcc = UAWithDifferentAcc;
            this.UAStateNotMatch = UAStateNotMatch;
            this.ResponseForUA = ResponseForUA;
        }
    }
    public class UA_UAWithDifferentAcc{
        @AuraEnabled public set<Account> CustomerAcc{get;set;}
        @AuraEnabled public List<Utility_Account__c> UAWithDifferentAccount{get;set;}
        
        public UA_UAWithDifferentAcc(set<Account> CustomerAcc,List<Utility_Account__c> UAWithDifferentAccount){
            this.CustomerAcc = CustomerAcc;
            this.UAWithDifferentAccount = UAWithDifferentAccount;
        }
    }
    @AuraEnabled
    public static void insertUAandUAO(List<Utility_Account_Opportunity__c> UAOTodelete,List<Utility_Account_Opportunity__c> UARelatedUAOWillBeInseted,  List<Utility_Account__c> UtilityWillBeInserted, Id recordId, Id OppRecId){
        
        list<Utility_Account_Opportunity__c> UAOLstToInsert = new list<Utility_Account_Opportunity__c>();
        system.debug('UAOTodelete==>'+UAOTodelete);
        system.debug('UARelatedUAOWillBeInseted==>'+UARelatedUAOWillBeInseted);
        system.debug('UtilityWillBeInserted==>'+UtilityWillBeInserted);
        if(UAOTodelete.size()>0){
            delete UAOTodelete;
        }
        if(UARelatedUAOWillBeInseted.size()>0){
            insert UARelatedUAOWillBeInseted;
        }
        if(UtilityWillBeInserted.size()>0){
            
            insert UtilityWillBeInserted;
            
            for(Utility_Account__c ua : UtilityWillBeInserted){
                Utility_Account_Opportunity__c ObjUAO = new Utility_Account_Opportunity__c();
                ObjUAO.Utility_Account__c = ua.Id;
                ObjUAO.Status__c = 'Not Priced';
                ObjUAO.Opportunity__c = OppRecId;
                if(ua.Requested_Start_Date__c != null){
                    ObjUAO.Start_Date__c = ua.Requested_Start_Date__c;
                }
                UAOLstToInsert.add(ObjUAO);
            }
            insert UAOLstToInsert;
        }
        
    }
}