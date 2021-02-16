/***************************************************************************************************************************
* Name             : BatchPriceUploader 
* Description      : Helper class for File_Uploader Component 
* Last Modified by : Rahul Ghaytadak
* Test Class       : file_upload_handler_Test
* Version History
* Date               Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 09-11-2020         Saurabh Chauhan         Import CSV file data in Price__c, Term_Price__c, Utility_Account__c
*											 and Price_Upload_Log__c.  
****************************************************************************************************************************/

public class BatchPriceUploader {
    
    //Process CSV file data and validate the records in CSV to insert the Term Prices.
    public static Set<String> processFileChunk(List<List<String>> inputCSVLines, Id recordId, Integer rowCount,String fileCSVdata,String FileName,Id PriceId,Integer finalrows,Boolean ToggleValue){
        Price_File_Validation__c addValidation = [Select id,Validate__c from Price_File_Validation__c limit 1];
        finalrows = finalrows + 1;
        Set<String> accids = new Set<String>();
        List<Price__c> priceLst = new List<Price__c>();
        List<Price__c> priceToBeUpdatedList = new List<Price__c>();
        Set<String> errors = new Set<String>();
        Set<Id> ut_acc_lst = new Set<Id>();
        Set<Utility_Account__c> ut_acc_lst_Set = new Set<Utility_Account__c>();
        List<Utility_Account__c> UA_ToBeUpdated = new List<Utility_Account__c>();
        List<Term_Price__c> term_priceLst = new List<Term_Price__c>();
        Map<Id,UAFieldsStore> UA_ToBeUpdate = new Map<Id,UAFieldsStore>();
        Price__c price1 = new Price__c();
        Map<String, Utility_Account_Pricing__c> nameUAPRMap = new Map<String,Utility_Account_Pricing__c>(); 
        boolean checkUAPR = false;
        
        for(Utility_Account_Pricing__c uapr : [SELECT Id, Name, Pricing_Request__c, Utility_Account__r.Name, Start_Date__c FROM Utility_Account_Pricing__c where Pricing_Request__c=: recordId]){
            nameUAPRMap.put(uapr.Utility_Account__r.Name,uapr);
        }
        
        Id oppId = [SELECT 
                    Id, 
                    Opportunity__r.Id 
                    FROM Pricing_Request__c 
                    WHERE Id =: recordId].Opportunity__r.Id ;
        
        Pricing_Request__c PricingReqObj = [Select Id, Voluntary_RECs__c, Voluntary_RECs_percent__c, Treatment__c, Bill_Type__c, Product_Lookup__c, Product_Lookup__r.Name, Product_Lookup__r.Product_Id__c from Pricing_Request__c where id=: recordId];
        try{
            List<String> existingUANames = new List<String>();
            
            
            List<Utility_Account_Opportunity__c> UAOs = [SELECT Id, Opportunity__c, 
                                                         Utility_Account__c,
                                                         Utility_Account__r.Id,
                                                         Utility_Account__r.Name 
                                                         FROM Utility_Account_Opportunity__c 
                                                         WHERE Opportunity__c =: oppId];
            for(Utility_Account_Opportunity__c UAO : UAOs){
                existingUANames.add(UAO.Utility_Account__r.Name);
                
            }
            
            String SetFirstRowAsDefault;
            boolean MixedValues = false;
            boolean AddedToErrorList=false;
            boolean proceed = false;
            boolean AddedToErrorListMixedValues=false;
            if(inputCSVLines[0].size() == 27){
                for(Integer i=1; i<inputCSVLines.size(); i++ ){
                    String[] inputvaluesForAcc = new String[]{};
                        
                        inputvaluesForAcc = inputCSVLines[i];
                    
                    accids.add(inputvaluesForAcc[0]);
                    if(!existingUANames.contains(inputvaluesForAcc[0])){
                        if(!nameUAPRMap.containskey(inputvaluesForAcc[0])){
                            errors.add('Row No. '+ finalrows + '.The Account Number is missing from Opportunity and Pricing Request.');
                        }
                        else{
                            errors.add('Row No. '+ finalrows + '.The Account Number is missing from Opportunity.');
                            
                        }
                        checkUAPR = true;
                    }
                    if(!nameUAPRMap.containskey(inputvaluesForAcc[0])){
                        if(checkUAPR == false){
                            errors.add('Row No. '+ finalrows + '.The Account Number is missing from the Pricing Request.');
                        }
                    }
                    
                    String[] inputvalues2 = new String[]{};
                        inputvalues2 = inputCSVLines[i-1];
                    if(RowCount == 1){
                        inputvalues2 = inputCSVLines[i];
                    } 
                    if(i==1 && inputvalues2[19].length() > 0){
                        
                        SetFirstRowAsDefault = inputvalues2[19];
                        System.debug('SetFirstRowAsDefault' +SetFirstRowAsDefault);
                        System.debug('PricingReqObj.Product_Lookup__r.Product_Id__c' +PricingReqObj.Product_Lookup__r.Product_Id__c);
                        if(PricingReqObj.Product_Lookup__r.Product_Id__c == SetFirstRowAsDefault){
                            
                            proceed=true;
                            
                        }
                        
                    }
                    
                    if(inputvalues2[19]!=SetFirstRowAsDefault){
                        MixedValues = true;
                    }
                    
                    if(addValidation.Validate__c == false ){
                        MixedValues = false; 
                        proceed = true;
                    }
                    
                    if(MixedValues==false && proceed==true){
                        if(inputvalues2[0].length() < 1){
                            errors.add('Row No. '+ finalrows + '. Please enter valid value for Account Number.');
                            
                        }
                        else if(!inputvalues2[1].isNumeric() ){
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for Term.');
                        }
                        else if((inputvalues2[2].isNumeric()) ||(!inputvalues2[2].isNumeric() && inputvalues2[2].trim().length()>3) ){
                            errors.add('Row No. '+ finalrows + '. Please enter valid value for month like "Jan".');
                        }
                        else if((!inputvalues2[3].isNumeric()) ||(inputvalues2[3].isNumeric() && inputvalues2[2].trim().length()>5)){
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for year.');
                        }
                        else if(!inputvalues2[4].isNumeric() ){
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for Usage.');
                        }
                        else if(!Base_Class_Uploader.isNumeric(inputvalues2[5]) ){
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for Profile On-Peak.');
                        }
                        else if(!Base_Class_Uploader.isNumeric(inputvalues2[6])){
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for Profile Off-Peak.');
                        }
                        else if(!inputvalues2[7].isNumeric() ){
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for Cumulative Volume.');
                        }
                        else if(!Base_Class_Uploader.isNumeric(inputvalues2[8]) ){
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for Price Term.');
                        }
                        else if(!Base_Class_Uploader.isNumeric(inputvalues2[9]) ) {
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for Load Factor.');
                        } 
                        else if(inputvalues2[10].length() > 100 ){
                            errors.add('Row No. '+ finalrows + '. Please enter valid Street value.');
                        }
                        else if(inputvalues2[11].isNumeric() ) {
                            errors.add('Row No. '+ finalrows + '. Please enter valid City name.');
                        }
                        else if(inputvalues2[12].isNumeric() || inputvalues2[12].trim().length() > 2 ){ // for State{
                            errors.add('Row No. '+ finalrows + '. Please enter valid acronym for state like NY.');
                        }
                        else if((!inputvalues2[13].isNumeric() && inputvalues2[13].trim().length() >11) || (inputvalues2[13].isNumeric() && inputvalues2[13].trim().length() >11)){
                            errors.add('Row No. '+ finalrows + '. Please enter valid Zip value.');
                        }
                        else if(inputvalues2[14].isNumeric() || inputvalues2[14].trim().length() > 2 ){ // for Country{
                            errors.add('Row No. '+ finalrows + '. Please enter valid acronym for Country like US.');
                        }
                        else if(!Base_Class_Uploader.isNumeric(inputvalues2[15]) ){
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for POR.');
                        }
                        else if(!Base_Class_Uploader.isNumeric(inputvalues2[16]) ) {
                            errors.add('Row No. '+ finalrows + '. Please remove text and enter valid value for Tax.');
                        }
                        else if(inputvalues2[20] != PricingReqObj.Bill_Type__c ) {
                            errors.add('Row No. '+ finalrows + '. Bill type does not match.');
                        }
                        else if(inputvalues2[21] != PricingReqObj.Voluntary_RECs__c ) {
                            errors.add('Row No. '+ finalrows + '. Recs Type does not match.');
                        }
                        else if( inputvalues2[22] != '' ) {
                            if(Decimal.valueOf(inputvalues2[22]) != PricingReqObj.Voluntary_RECs_percent__c){
                                errors.add('Row No. '+ finalrows + '. Vol Recs % does not match.');
                            }
                        }
                    }
                    else {
                        if(i==inputCSVLines.size() && AddedToErrorList==false && proceed==false && MixedValues==false && AddedToErrorListMixedValues==false){
                            AddedToErrorList=true;
                            if(addValidation.Validate__c == true ){  
                                errors.add(' \'Product Code\' On Pricing Request record and CSV does not Match');
                            }
                        }
                        if(i==inputCSVLines.size() && MixedValues==true && AddedToErrorListMixedValues==false && AddedToErrorList==false){
                            AddedToErrorListMixedValues=true;
                            if(addValidation.Validate__c == true ){  
                                errors.add('You are uploading wrong csv file with Mixed or No Values');
                            }
                        }
                    }
                    
                    finalrows++;
                }
                if(AddedToErrorList==false && proceed==false && MixedValues==false && AddedToErrorListMixedValues==false){
                    AddedToErrorList=true;
                    if(addValidation.Validate__c == true ){    
                        errors.add(' \'Product Code\' On Pricing Request record and CSV does not Match');
                    }
                }
                if(MixedValues==true && AddedToErrorListMixedValues==false && AddedToErrorList==false){
                    AddedToErrorListMixedValues=true;
                    if(addValidation.Validate__c == true ){  
                        errors.add('You are uploading wrong csv file with Mixed or no Values');
                    }
                }
            }
            else {
                
                errors.add('You are uploading wrong csv file.');
            }
            
            if(errors.size() == 0 ){
                If(FileName==null || FileName==''){
                    FileName = 'test';
                }
                
                price1.Id = PriceId;
                
                price1.Price_Type__c ='Quote';
                
                price1.Bill_Type__c = PricingReqObj.Bill_Type__c;
                
                if(PricingReqObj.Product_Lookup__c!=NULL)
                {
                    price1.Product_Lookup__c = PricingReqObj.Product_Lookup__c;
                }
                
                price1.Latest_Price__c = true;
                priceLst.add(price1);
                
            } 
            
            //logic to update existing prices for this opprtunity, Latest price should be set false
            if(errors.size() == 0 ){
                List<Id> priceIdInserted = new List<Id>();
                
                for(Price__c p : priceLst){
                    priceIdInserted.add(p.id);
                }
                
                List<Price__c> priceToBeUpdated = [SELECT 
                                                   Id,
                                                   Latest_Price__c 
                                                   FROM Price__c 
                                                   WHERE Opportunity__c = :oppId
                                                   AND 
                                                   Id NOT IN :priceIdInserted ];
                
                for(Price__c pUpdate : priceToBeUpdated){
                    pUpdate.Latest_Price__c = false;
                    priceToBeUpdatedList.add(pUpdate);
                }
                priceToBeUpdatedList.add(price1);
                if(RowCount==1){
                    update priceToBeUpdatedList;
                }
                
                List<Utility_Account__c> ut_accList = [SELECT id,Name,Utility__c, Street__c, City__c, State__c, zip__c, Country__c, Service_Class__c, Zone__c, Annual_Usage_kWh__c 
                                                       FROM Utility_Account__c 
                                                       WHERE Name IN: existingUANames];
                
                Map<Id, Id> UA_UAO = new Map<ID,Id>();
                
                Map<String, Utility_Account__c> nameUAMap = new Map<String,Utility_Account__c>();
                
                for(Utility_Account__c ut_acc: ut_accList ){
                    nameUAMap.put(ut_acc.Name, ut_acc);
                }
                for(Utility_Account_Opportunity__c uao1 : [SELECT Id, Utility_Account__c FROM Utility_Account_Opportunity__c WHERE Opportunity__c =:oppId AND Utility_Account__c = :ut_accList]){
                    UA_UAO.put(uao1.Utility_Account__c, uao1.Id);
                }
                
                boolean firsttime = false;
                boolean startDateChecked = false;
                String currentUA = '';
                integer n=0;
                Decimal TwelveMonthsPrice = 0.00;
                Map<Id,Decimal> UA12Price = new Map<Id,Decimal>();
                Map<Id,string> UA1Term = new Map<Id,string>(); 
                Integer i = 0;
                String currentUAcc = '';
                boolean GetUsageValue = false;
                if(RowCount==1){
                    i=1;
                }
                for(;i<inputCSVLines.size(); i++ ){
                    
                    String[] inputvalues = new String[]{};
                        inputvalues = inputCSVLines[i];
                    Term_Price__c tp = new Term_Price__c();
                    
                    if(firsttime == false && Integer.valueOf(inputvalues[1]) != 1 && currentUA==''){
                        
                        currentUA = inputvalues[0];
                        firsttime = true;
                        startDateChecked=true;
                    }
                    if(Integer.valueOf(inputvalues[1]) == 1){
                        currentUA = inputvalues[0];
                        startDateChecked=false;
                    }
                    tp.Price__c =priceLst[0].id;  
                    if(!nameUAMap.keyset().contains(inputvalues[0])){errors.add(inputvalues[0]);}
                    if(currentUA==inputvalues[0] && startDateChecked==false && inputvalues[4]!='0'){
                        startDateChecked = true;
                        
                        Date d = nameUAPRMap.get(inputvalues[0]).Start_Date__c;
                        Datetime dt = Datetime.newInstance(d.year(), d.month(),d.day());
                        String dateString = dt.format('MMM/yyyy');
                        
                        //Get called when Align Start Dates toggle is true 
                        if(ToggleValue == true){
                            //Used to retrive the month number
                            Map<String, Integer> monthsMap = new Map<String, Integer>{
                                'Jan' => 1,
                                    'Feb' => 2,
                                    'Mar' => 3,
                                    'Apr' => 4,
                                    'May' => 5,
                                    'Jun' => 6,
                                    'Jul' => 7,
                                    'Aug' => 8,
                                    'Sep' => 9,
                                    'Oct' => 10,
                                    'Nov' => 11,
                                    'Dec' => 12
                                    };
                                        
                                        //Create new date to assign UAO 
                                        Date dtNew = date.newInstance( Integer.valueof(inputvalues[3]),monthsMap.get(inputvalues[2]),1);
                            string formattedDate = dtNew.format();
                            UA1Term.put(nameUAMap.get(currentUA).Id,formattedDate);
                            
                        }
                        
                        if(dateString != inputvalues[2] +'/'+Integer.valueOf(inputvalues[3])){
                            //errors.add('Start Dates doesn\'t match. Please check Start date of Utility Account: '+ currentUA + ' for term '+Integer.valueOf(inputvalues[1]) ); 
                        }
                    }
                    
                    tp.Utility_Account_Opportunity__c = UA_UAO.get(nameUAMap.get(inputvalues[0]).Id);
                    tp.Utility__c =nameUAMap.get(inputvalues[0]).Utility__c;
                    tp.Opportunity__c = oppId;
                    tp.Term__c = String.valueOf(Integer.valueOf(inputvalues[1]));
                    tp.Month__c = inputvalues[2];
                    tp.Year__c = Integer.valueOf(inputvalues[3]);
                    tp.Volume__c = Double.valueof(inputvalues[4]);
                    tp.Profile_On_Peak__c = Double.valueof(inputvalues[5]);
                    tp.Profile_Off_Peak__c = Double.valueof(inputvalues[6]);
                    tp.Cumulative_Volume__c = Integer.valueOf(inputvalues[7]);
                    tp.Base_Price__c = Double.valueof(inputvalues[8]);
                    tp.Load_Factor_Decimal__c = Double.valueof(inputvalues[9]);
                    
                    // Insert Utility Accounts data
                    if(nameUAMap.get(inputvalues[0]).Street__c == null && nameUAMap.get(inputvalues[0]).City__c == null && nameUAMap.get(inputvalues[0]).State__c == null && nameUAMap.get(inputvalues[0]).Zip__c == null &&  nameUAMap.get(inputvalues[0]).Country__c == null ){
                        nameUAMap.get(inputvalues[0]).Street__c = inputvalues[10];
                        nameUAMap.get(inputvalues[0]).City__c = inputvalues[11]; 
                        nameUAMap.get(inputvalues[0]).State__c = inputvalues[12];
                        nameUAMap.get(inputvalues[0]).Zip__c = inputvalues[13];
                        nameUAMap.get(inputvalues[0]).Country__c = inputvalues[14]; 
                    }
                    else{
                        
                    }
                    nameUAMap.get(inputvalues[0]).Service_Class__c = inputvalues[17];
                    nameUAMap.get(inputvalues[0]).Zone__c = inputvalues[18];
                    nameUAMap.get(inputvalues[0]).Load_Factor_Decimal__c =  Double.valueof(inputvalues[9]);
                    if(Double.valueof(inputvalues[1]) == 12.0){
                        TwelveMonthsPrice = Double.valueof(inputvalues[8]);
                        UA12Price.put(nameUAMap.get(inputvalues[0]).Id,TwelveMonthsPrice );
                        nameUAMap.get(inputvalues[0]).Annual_Usage_kWh__c = Integer.valueof(inputvalues[7]);
                    }
                    
                    if(ut_acc_lst.add(nameUAMap.get(inputvalues[0]).Id)){
                        ut_acc_lst_Set.add(nameUAMap.get(inputvalues[0]));
                        
                        UAFieldsStore newUA_Values = new UAFieldsStore();
                        newUA_Values.Capacity_Tag = inputvalues[23];
                        newUA_Values.Capacity_Tag_Future = inputvalues[24];
                        newUA_Values.NITS_Tag = inputvalues[25];
                        newUA_Values.NITS_Tag_Future = inputvalues[26];
                        
                        UA_ToBeUpdate.put(nameUAMap.get(inputvalues[0]).Id,newUA_Values);
                    }
                    
                    tp.POR__c =  Double.valueof(inputvalues[15]);
                    tp.Tax__c = Double.valueof(inputvalues[16]);
                    term_priceLst.add(tp);   
                }
                
                List<Utility_Account_Pricing__c> listUAPRToUpdateStatus = new List<Utility_Account_Pricing__c>();
                List<Utility_Account_Pricing__c> listUAPR = [SELECT Id, Utility_Account__c, Pricing_Request__c, Start_Date__c FROM Utility_Account_Pricing__c Where Utility_Account__c NOT IN :UA12Price.keySet() AND Pricing_Request__c=:recordId];
                List<Utility_Account_Pricing__c> listUAPRPriced = [SELECT Id, Utility_Account__c, Pricing_Request__c, Start_Date__c FROM Utility_Account_Pricing__c Where Utility_Account__c IN :UA12Price.keySet() AND Pricing_Request__c=:recordId];
                if(listUAPR.size()>0){
                    for(Utility_Account_Pricing__c uaprStatus : listUAPR ){
                        uaprStatus.Status__c = 'Not Priced';
                        listUAPRToUpdateStatus.add(uaprStatus);
                    }
                }
                for(Utility_Account_Pricing__c uaprStatus : listUAPRPriced ){
                    uaprStatus.Status__c = 'Priced';
                    listUAPRToUpdateStatus.add(uaprStatus);
                }
                Update listUAPRToUpdateStatus;
                
                if(ToggleValue == true){
                    // Update Start Dates
                    List<Utility_Account_Pricing__c> listUAPR_toUpdateStartDate = [SELECT Id, Utility_Account__c, Pricing_Request__c, Start_Date__c FROM Utility_Account_Pricing__c Where Utility_Account__c IN :UA1Term.keySet()];
                    
                    for(Utility_Account_Pricing__c uaprStartDate : listUAPR_toUpdateStartDate ){
                        string Start_Date = UA1Term.get(uaprStartDate.Utility_Account__c);
                        uaprStartDate.Start_Date__c = Date.parse(Start_Date);
                    }
                    Update listUAPR_toUpdateStartDate;
                }
                List<Utility_Account_Opportunity__c> listUAO_toUpdatePricee = [SELECT Id, Opportunity__c, Utility_Account__c, Status__c FROM Utility_Account_Opportunity__c where Opportunity__c =: oppId AND Utility_Account__c IN :UA12Price.keySet()];
                for(Utility_Account_Opportunity__c uaoPrice :listUAO_toUpdatePricee ){
                    uaoPrice.Twelve_Month_Price__c = UA12Price.get(uaoPrice.Utility_Account__c);
                    uaoPrice.Status__c = 'Priced';
                }
                Update listUAO_toUpdatePricee;
                
                List<Utility_Account__c> ut_acc_lst1 = new List<Utility_Account__c>();
                ut_acc_lst1.addAll(ut_acc_lst_Set);
                
                
                List<Id> priceIdList = new List<Id>();
                if(!priceLst.isEmpty()){
                    priceIdList.add(priceLst[0].id);
                }
                if(term_priceLst.size()>0 && ut_acc_lst1.size()>0 ){
                    insert term_priceLst;
                    //Changes made to call Create_Price_Summary_Asynchronous class method on insertion of Price and Term Prices records
                    
                    //SU-610 : mapped the additional Fields Capacity & NITS Tags to Utility Account
                    
                    for(Utility_Account__c Uas : ut_acc_lst1){
                        BatchPriceUploader.UAFieldsStore result = UA_ToBeUpdate.get(Uas.Id);

                        if(result.Capacity_Tag != null){
                            Uas.Capacity_Tag__c = Decimal.valueOf(result.Capacity_Tag);
                        }
                        if(result.Capacity_Tag_Future != null){
                            Uas.Capacity_Tag_Future__c = Decimal.valueOf(result.Capacity_Tag_Future);
                        }
                        if(result.NITS_Tag != null){
                            Uas.NITS_Tag__c = Decimal.valueOf(result.NITS_Tag);
                        }
                        if(result.NITS_Tag_Future != null){
                            Uas.NITS_Tag_Future__c = Decimal.valueOf(result.NITS_Tag_Future);
                        }
                        UA_ToBeUpdated.add(Uas);
                    }
                     update UA_ToBeUpdated;
                }
                
            }
        } catch(exception e){
            
            if(errors.size()==0){
                if(String.valueOf(e.getLineNumber()) == '293'){
                    errors.add('Utility Accounts are missing start dates');
                }
                else{
                    errors.add(e.getMessage());
                    errors.add('Line-> '+String.valueOf(e.getLineNumber()));    
                }
            }
            
        }
        
        return errors;
        
    }
    
    //SU-610 : mapped the additional Fields Capacity & NITS Tags to Utility Account
    public class UAFieldsStore{
        @AuraEnabled public String NITS_Tag{get; set;}
        @AuraEnabled public String NITS_Tag_Future{get; set;}
        @AuraEnabled public String Capacity_Tag{get; set;}
        @AuraEnabled public String Capacity_Tag_Future{get; set;}
    }
}