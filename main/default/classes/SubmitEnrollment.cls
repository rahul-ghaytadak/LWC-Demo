/*
* @Purpose: controller of Enrollment Submit component.
* @Author: Aress Dev
* @CreatedDate: 
* @Related Code: 
* @Test Class: ZnalyticsAPI_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/
public class SubmitEnrollment { 
    
    @auraEnabled
    public static String callZnalyticsAPI(Id enrollmentRecId, List<Utility_Account_Enrollment__c> selectedUAEs){
        String Code;
        List<String> Errors = new List<String>();
        if(enrollmentRecId != NULL){
            try{
                //variable Declarations
                string UAEId;
                String accId;
                String conId;
                String contractOppId;
                string OppId;
                String strPhone; 
                String strPhoneAreaCode = '';
                String enrollmentId;
                
                List<Opportunity> oppList;
                list<Utility_Account__c> utilityAccList = new list<Utility_Account__c>();
                list<Utility_Account_Opportunity__c> utilityAccOpportunityList = new list<Utility_Account_Opportunity__c>();
                List<Contact> contactList;
                list<Utility_Account_Enrollment__c> UAEList = new list<Utility_Account_Enrollment__c>();
                List<Id> Uacc = new List<Id>();
                List<Id> utilityIdList = new List<Id>();
                
                List<Enrollment__c> enrollmentList = [SELECT Contract__c, Tax_Exempt__c, Tax_Exempt_Code__c, Tax_Exempt_Certificate_Number__c, Effective_Date__c, Percentage__c, Invoice_Billing_Type__c, Account__r.ZN_CustomerId__c, Account__r.EOS_CustomerNumber__c, Sale_Type__c, Source_System__c, Langauge_Code__c, Customer_Type_Code__c, Company_Name__c, Bill_Format_Code__c, Bill_Type__c,
                                                      Contract_Source_Code__c, Sold_Date__c, Account__c, Contract_Start__c, Contract_Type_Code__c, Contract_Term__c, Name, Id, Rate_Schedule_Name__c, 
                                                      Rate_Amount__c, Contract_Signed_Date__c, Utility_Code__c, Contract__r.Opportunity__c
                                                      FROM Enrollment__c 
                                                      WHERE Id =: enrollmentRecId];
                if(enrollmentList.isEmpty()){
                    Errors.add('Enrollment');
                }
                
                String contractId = enrollmentList[0].Contract__c;
                
                Contract contractList = [SELECT Id, Opportunity_Id__c, AccountId, Pricebook2Id, StartDate, EndDate, BillingStreet, BillingCity, ShippingAddress, BillingState, 
                                         BillingPostalCode, BillingCountry, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, 
                                         ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, 
                                         ShippingLongitude, ShippingGeocodeAccuracy, ContractTerm, OwnerId, Status, CompanySignedId, CompanySignedDate, 
                                         CustomerSignedId, CustomerSignedTitle, CustomerSignedDate, SpecialTerms, ActivatedById, ActivatedDate, StatusCode, 
                                         Description, IsDeleted, ContractNumber, LastApprovedDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, 
                                         SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, Opportunity__c, Total_Unit_Rate__c, Opportunity__r.Id 
                                         FROM Contract 
                                         WHERE Id =: contractId];
                
                // value sassign to variables
                enrollmentId =  enrollmentList[0].id;
                accId = enrollmentList[0].Account__c;
                conId = enrollmentList[0].Contract__c;
                contractOppId = contractList.Opportunity__r.Id;
                
                //assign the account id to variable
                if(!enrollmentList.isEmpty()){
                    enrollmentId =  enrollmentList[0].id;
                    
                    //query the Utility Account Enrollment Record
                    UAEList = [SELECT Id, Name, Bill_Type__c, Program_Code__c,Hold_Transaction__c, Hold_Reason_Code__c, Start_Date__c,SystemModstamp,Rate_Schedule_Name__c, Enrollment__c, Utility_Account__c, Status__c, Utility_Account__r.Commodity__c, Utility_Account__r.Name , Tax_Exempt__c, Tax_Exempt_Code__c, Effective_Date__c, Percentage__c, Tax_Exempt_Certificate_Number__c
                               FROM Utility_Account_Enrollment__c
                               WHERE Enrollment__c =: enrollmentId AND Id IN: selectedUAEs];
                    if(UAEList.isEmpty()){
                        Errors.add('Utility Account Enrollment');
                    }
                }
                else{
                    Errors.add('Enrollment');
                }
                system.debug('UAEList size '+UAEList.size());
                system.debug('UAEList===='+UAEList);
                //Query Account record
                list<Account> accList = [SELECT Id, Name, BillingCity, BillingState, BillingStreet, BillingPostalCode, BillingCountry   
                                         FROM Account
                                         WHERE Id =: accId];
                
                //assign the account id to variable
                Map<ID, Utility_Account_Enrollment__c> UAUAEMap = new Map<ID, Utility_Account_Enrollment__c>();
                if(!accList.isEmpty()){
                    accId =  accList[0].id;
                    
                    //query the opportunity Record 
                    oppList = [SELECT Id, AccountId, Name, StageName, Amount, Probability, CloseDate, Type, NextStep, LeadSource, IsClosed, IsWon, ForecastCategory,
                               ForecastCategoryName, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, LastModifiedDate, 
                               LastModifiedById, SystemModstamp, LastActivityDate, FiscalQuarter, FiscalYear, Fiscal, ContactId, LastViewedDate, LastReferencedDate, 
                               SyncedQuoteId, ContractId, HasOpenActivity, HasOverdueTask, Budget_Confirmed__c, Discovery_Completed__c, ROI_Analysis_Completed__c, 
                               Loss_Reason__c, Broker__c, Start_Date__c, Submit_for_Pricing__c, Urgent_Request__c, 
                               Bill_Type__c, Start_Month__c, Commodity__c, Swing_OLD__c, Send_HU_Email__c, Send_Email__c, Account_Name__c, Voluntary_Renewable_Energy__c, 
                               Tax_Exempt__c, Voluntary_Renewable_Energy_Product__c, Product_Count__c, Swing__c, Utility__c
                               FROM Opportunity 
                               WHERE AccountId =:accId AND Id = : contractOppId
                               LIMIT 1];
                    if(oppList.isEmpty()){
                        // Errors.add('Opportunity');
                    }
                    //oppId = oppList[0].id;
                    //query Utility Account Records
                    for(Utility_Account_Enrollment__c Uae : UAEList)
                    {
                        Uacc.add(Uae.Utility_Account__c);    
                        UAUAEMap.put(Uae.Utility_Account__c, Uae);
                    }
                    
                    utilityAccList = [Select Id, Name, Street__c, Label__c, Utility__r.Utility_Code__c, Commodity__c, City__c, State__c, Zip__c, Service_Address__c, Zone__c, Service_Class__c, Label_2__c, Country__c, Utility__c
                                      From Utility_Account__c 
                                      where Id =: Uacc ];
                    if(utilityAccList.isEmpty()){
                        Errors.add('Utility Account');
                    }
                    //Query the UtiltyAccountOpportunity Records
                    contactList = [SELECT Id, AccountId, LastName, FirstName, Salutation, MailingGeocodeAccuracy, MailingLongitude, Birthdate,
                                   MailingLatitude, MiddleName, Suffix, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, 
                                   MailingCountry, MailingAddress, Phone, Fax, MobilePhone, ReportsToId, Email, Title, Department, PhotoUrl, 
                                   Jigsaw, JigsawContactId, Primary_Contact__c FROM Contact
                                   WHERE AccountId  =:accId and Phone!=NULL];
                    
                    if(!contactList.isEmpty()){
                        if(contactList[0].Phone != '' || contactList[0].Phone != NULL){
                            strPhone = String.valueOf(contactList[0].Phone); 
                            system.debug('strPhone==='+strPhone);
                            if(strPhone != '' && strPhone != NULL){
                                string phoneWithoutFormatting = strPhone.replaceAll('\\D','');
                                if(phoneWithoutFormatting.length() == 10){
                                    strPhoneAreaCode = phoneWithoutFormatting.substring(0, 3);
                                    strPhone = phoneWithoutFormatting.substring(3, 10);
                                }
                                else
                                    strPhone = phoneWithoutFormatting;
                            }
                        }
                    }
                    else{
                        system.debug('Contact List is empty');
                        Errors.add('Contact');
                    }
                }
                else{
                    Errors.add('Account');
                }
                
                // Create String type data for passing into ServiceAddressList Wrapper Class
                List<string> strDatalst = new List<string>();
                
                // Create Boolean type data for passing into ServiceAddressList Wrapper Class
                List<Boolean> boolDatalst = new List<Boolean>();
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                boolDatalst.add(false);
                
                // Create Integer type data for passing into ServiceAddressList Wrapper Class
                List<integer> intDatalst = new List<integer>();     
                
                
                // DocumentUrl List for Contract Wrapper Class
                list<String> docUrl = new list<String>();
                // Deposit List for Customer Wrapper Class
                List<string> depLst = new List<String>();
                // Volume List for ContractDetailList Wrapper Class
                list<String> volList = new list<String>();
                // MeterList for ServiceAccountList Wrapper Class
                List<String> MeterList = new List<String>();
                // AuthorizedContactList List for ServiceAccountList Wrapper Class
                List<String> authConlst = new List<String>();
                
                // Create List of Wrapper Classes
                List<Wrapper_Znalytics_Enrollment.ContractSegmentDetailList> contrSegDataLst = new List<Wrapper_Znalytics_Enrollment.ContractSegmentDetailList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList> authConPhList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList> authConEmail = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList>();
                List<Wrapper_Znalytics_Enrollment.ContractRateSegmentList> contrRateSegLst = new List<Wrapper_Znalytics_Enrollment.ContractRateSegmentList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactList> authConList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactList>();
                List<Wrapper_Znalytics_Enrollment.ServiceAccountList> serAcclst = new List<Wrapper_Znalytics_Enrollment.ServiceAccountList>();
                List<Wrapper_Znalytics_Enrollment.BillingAccountList> billAcclist = new List<Wrapper_Znalytics_Enrollment.BillingAccountList>();
                List<Wrapper_Znalytics_Enrollment.Contract> contrLst = new List<Wrapper_Znalytics_Enrollment.Contract>();
                List<Wrapper_Znalytics_Enrollment.ContractDetailList> contrDetList = new List<Wrapper_Znalytics_Enrollment.ContractDetailList>();
                
                Map<String,Wrapper_Znalytics_Enrollment.tempTransaction> UATransMap = new Map<String,Wrapper_Znalytics_Enrollment.tempTransaction>();
                Map<String,Wrapper_Znalytics_Enrollment.taxExemption> UATaxExpt = new Map<String,Wrapper_Znalytics_Enrollment.taxExemption>();
                // Instantiate Constructor
                Wrapper_Znalytics_Enrollment.tempTransaction trans = new Wrapper_Znalytics_Enrollment.tempTransaction('','',False,'','','','',0,null);
                
                // Map for ServiceAddress
                Map<id, Wrapper_Znalytics_Enrollment.ServiceAddress> serviceAddressMap = new Map<id, Wrapper_Znalytics_Enrollment.ServiceAddress> ();
                for(Utility_Account__c UtilAcc : utilityAccList){
                    Wrapper_Znalytics_Enrollment.ServiceAddress servAddrNew= new Wrapper_Znalytics_Enrollment.ServiceAddress(UtilAcc.Street__c,UtilAcc.City__c,UtilAcc.Country__c,UtilAcc.State__c,UtilAcc.Zip__c);
                    serviceAddressMap.put(UtilAcc.Id,servAddrNew);
                }
                
                // Instantiate Constructor
                Wrapper_Znalytics_Enrollment.ServiceAddress servAddr= new Wrapper_Znalytics_Enrollment.ServiceAddress(utilityAccList[0].Street__c,utilityAccList[0].City__c,utilityAccList[0].Country__c,utilityAccList[0].State__c,utilityAccList[0].Zip__c);
                
                Wrapper_Znalytics_Enrollment.MailAddress mailAddr = new  Wrapper_Znalytics_Enrollment.MailAddress(accList[0].BillingStreet, accList[0].BillingCity,accList[0].BillingState,accList[0].BillingPostalCode,accList[0].BillingCountry); 
                
                Wrapper_Znalytics_Enrollment.LegalAddress legalAddr = new Wrapper_Znalytics_Enrollment.LegalAddress(contactList[0].ReportsToId,accList[0].BillingPostalCode ,accList[0].BillingState,accList[0].BillingCity,accList[0].BillingCountry,accList[0].BillingStreet);  
                
                Wrapper_Znalytics_Enrollment.CustomerIndividual custIndv = new Wrapper_Znalytics_Enrollment.CustomerIndividual( contactList[0].Birthdate,contactList[0].Suffix,contactList[0].LastName,contactList[0].FirstName,contactList[0].Salutation,'',true,true,0,true,'','');
                
                Wrapper_Znalytics_Enrollment.CustomerCommercial custComm = new Wrapper_Znalytics_Enrollment.CustomerCommercial(enrollmentList[0].Company_Name__c); 
                
                Wrapper_Znalytics_Enrollment.ContractSegmentDetailList contrSegData = new Wrapper_Znalytics_Enrollment.ContractSegmentDetailList(0,0);
                contrSegData.RateAmount = enrollmentList[0].Rate_Amount__c;
                contrSegDataLst.add(contrSegData);
                Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList authContEmail = new Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList();
                authConEmail.add(authContEmail);
                
                Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList authContPhLst = new Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList(strPhone, strPhoneAreaCode);
                authConPhList.add(authContPhLst);
                
                //contrSegDataLst.add(contrSegData);
                
                Wrapper_Znalytics_Enrollment.Contract contr = new Wrapper_Znalytics_Enrollment.Contract(contractList.Id ,contractList.ContractTerm,enrollmentList[0].Contract_Signed_Date__c,docUrl,contractList.EndDate,contractList.StartDate,contractList.Opportunity_Id__c);
                contrLst.add(contr);
                
                Wrapper_Znalytics_Enrollment.ContractDetailList contrDetLst;
                Map<Id, Wrapper_Znalytics_Enrollment.ContractRateSchedule> contrRateSchMap = new Map<Id, Wrapper_Znalytics_Enrollment.ContractRateSchedule>(); 
                Wrapper_Znalytics_Enrollment.ContractRateSegmentList contrRateSeg = new Wrapper_Znalytics_Enrollment.ContractRateSegmentList(contractList.ContractTerm, contractList.StartDate, contractList.EndDate, '', contrSegDataLst); 
                //    contrRateSegLst.add(contrRateSeg);
                
                Map<String,String> uaNamePricingGroupMap = new Map<String,String>();
                Map<String,String> uaNameRateScheduleMap = new Map<String,String>();
                for(Utility_Account_Enrollment__c uaelistTemp : UAEList){
                    uaNameRateScheduleMap.put(uaelistTemp.Utility_Account__r.Name,uaelistTemp.Rate_Schedule_Name__c);
                    if(uaelistTemp.Hold_Transaction__c == true){
                        Wrapper_Znalytics_Enrollment.tempTransaction transTopass = new Wrapper_Znalytics_Enrollment.tempTransaction(uaelistTemp.Hold_Reason_Code__c,'',uaelistTemp.Hold_Transaction__c,'','','','',0,(Datetime)uaelistTemp.Start_Date__c);
                        UATransMap.put(uaelistTemp.Utility_Account__r.Name,transTopass);
                    }
                    else{
                        Wrapper_Znalytics_Enrollment.tempTransaction transTopass = new Wrapper_Znalytics_Enrollment.tempTransaction('','',false,'','','','',0,null);
                        UATransMap.put(uaelistTemp.Utility_Account__r.Name,transTopass);
                    }
                    
                    
                    String Pricing_GroupToPass = null;
                    if(uaelistTemp.Program_Code__c!=null){
                        List<String> Pricing_Group = uaelistTemp.Program_Code__c.split('/');
                        
                        if(Pricing_Group[0]!=NULL){
                            Pricing_GroupToPass = Pricing_Group[0];
                            uaNamePricingGroupMap.put(uaelistTemp.Utility_Account__r.Name, Pricing_GroupToPass);
                        }
                    }
                    
                    Wrapper_Znalytics_Enrollment.ContractRateSchedule contrRateSch = new Wrapper_Znalytics_Enrollment.ContractRateSchedule(contractList.ContractTerm, contractList.StartDate, contractList.EndDate, uaelistTemp.Rate_Schedule_Name__c,contrRateSegLst);
                    contrRateSchMap.put(uaelistTemp.Utility_Account__r.Id,contrRateSch);    
                    //system.debug('contrRateSchMap======'+contrRateSchMap);
                    contrDetLst = new Wrapper_Znalytics_Enrollment.ContractDetailList(contractList.Opportunity_Id__c  ,contractList.StartDate,contractList.EndDate,enrollmentList[0].Contract_Type_Code__c,contrRateSchMap.get(uaelistTemp.Utility_Account__r.Id),volList,'','','','','',0,'',0,''); 
                    contrDetList.add(contrDetLst);
                }
                
                system.debug('contrRateSchMap======'+contrRateSchMap.size());
                
                Wrapper_Znalytics_Enrollment.AuthorizedContactList authContLst = new Wrapper_Znalytics_Enrollment.AuthorizedContactList( contactList[0].Birthdate,contactList[0].Primary_Contact__c,authConPhList,authConEmail,contactList[0].Salutation,contactList[0].FirstName,contactList[0].LastName,contactList[0].Suffix,'PRM','WRK' );        
                authConList.add(authContLst);
                
                //Wrapper_Znalytics_Enrollment.ServiceAccountList servAddrLst = new Wrapper_Znalytics_Enrollment.ServiceAccountList(trans,strDatalst,boolDatalst,intDatalst,authConlst,MeterList,contrDetList,servAddr);
                
                // Second Instance of AuthorizedContactList Wrapper Class
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList> authContaPhList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList> authContEmailList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList>();
                List<Wrapper_Znalytics_Enrollment.AuthorizedContactList> authContaList = new List<Wrapper_Znalytics_Enrollment.AuthorizedContactList>();
                
                Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList authContPhList = new Wrapper_Znalytics_Enrollment.AuthorizedContactPhoneList(strPhone, strPhoneAreaCode);
                authContaPhList.add(authContPhList);
                Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList authContEmailLst = new Wrapper_Znalytics_Enrollment.AuthorizedContactEmailList();
                authContEmailList.add(authContEmailLst);
                Wrapper_Znalytics_Enrollment.AuthorizedContactList authContList = new Wrapper_Znalytics_Enrollment.AuthorizedContactList(  contactList[0].Birthdate,contactList[0].Primary_Contact__c,authConPhList,authConEmail,contactList[0].Salutation,contactList[0].FirstName,contactList[0].LastName,contactList[0].Suffix,'PRM','WRK');        
                authContaList.add(authContList);
                List<Wrapper_Znalytics_Enrollment.ServiceAccountList> serviceAccountList = new List<Wrapper_Znalytics_Enrollment.ServiceAccountList>();
                List<Wrapper_Znalytics_Enrollment.ServiceAccountList> serviceAccountListfinal = new List<Wrapper_Znalytics_Enrollment.ServiceAccountList>();
                // Map for ServiceAccountList
                //new List<Wrapper_Znalytics_Enrollment.ContractDetailList>
                Map<Id, List<Wrapper_Znalytics_Enrollment.ContractDetailList>> ContractDetailListMap2 = new Map<id, List<Wrapper_Znalytics_Enrollment.ContractDetailList>>();
                Map<Id, List<Wrapper_Znalytics_Enrollment.ServiceAccountList>> ServiceAccountListMap = new Map<id, List<Wrapper_Znalytics_Enrollment.ServiceAccountList>> ();
                Map<Id, Wrapper_Znalytics_Enrollment.BillingAccountList> billAccountListMap = new Map<Id, Wrapper_Znalytics_Enrollment.BillingAccountList>(); 
                //for(Utility_Account__c UtilAcc : utilityAccList)
                List<Wrapper_Znalytics_Enrollment.ServiceAccountList> serAcclstTemp = new List<Wrapper_Znalytics_Enrollment.ServiceAccountList>();
                Integer inc = 10000;
                Wrapper_Znalytics_Enrollment.BillingAccountList billAddrLstNew;
                
                // SU:562 Pass UAE level TAX Exempt Fields to the API
                for(Utility_Account_Enrollment__c uaelistTemp : UAEList){
                    if(uaelistTemp.Tax_Exempt__c == true){
                        Wrapper_Znalytics_Enrollment.taxExemption taxExe = new Wrapper_Znalytics_Enrollment.taxExemption();
                        taxExe.effectiveDate = String.valueOf(uaelistTemp.Effective_Date__c);
                        taxExe.taxCertificateNumber = uaelistTemp.Tax_Exempt_Certificate_Number__c;
                        Wrapper_Znalytics_Enrollment.taxExemptionDetailList TEL = new Wrapper_Znalytics_Enrollment.taxExemptionDetailList();
                        TEL.taxExemptCode = uaelistTemp.Tax_Exempt_Code__c;
                        TEL.taxType = '';
                        TEL.taxExemptionAmount = uaelistTemp.Percentage__c;
                        List<Wrapper_Znalytics_Enrollment.taxExemptionDetailList> telList = new List<Wrapper_Znalytics_Enrollment.taxExemptionDetailList>();
                        telList.add(TEL);
                        taxExe.taxExemptionDetailList = telList;
                        UATaxExpt.put(uaelistTemp.Utility_Account__r.Name,taxExe);
                        system.debug('uaelistTemp.Utility_Account__r.Name==>'+uaelistTemp.Utility_Account__r.Name);
                        system.debug('taxExe==>'+taxExe);
                        system.debug('telList==>'+telList);
                    }
                    else{
                        Wrapper_Znalytics_Enrollment.taxExemption taxExe = new Wrapper_Znalytics_Enrollment.taxExemption();
                        system.debug('Tax Exmpt false');
                        taxExe = NULL;
                        UATaxExpt.put(uaelistTemp.Utility_Account__r.Name,taxExe);
                    }
                }
                for(Integer i = 0; i < utilityAccList.size(); i++){
                    serAcclst.clear();
                    strDatalst.clear();
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add(''); 
                    strDatalst.add(utilityAccList[i].Name );//2019109390
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    //strDatalst.add(enrollmentList[0].Utility_Code__c);
                    strDatalst.add(utilityAccList[i].Utility__r.Utility_Code__c);
                    //strDatalst.add('');
                    if(utilityAccList[i].Commodity__c == 'Electricity'){
                        strDatalst.add('E');
                    }else if(utilityAccList[i].Commodity__c == 'Gas'){
                        strDatalst.add('G');
                    }else{}
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    strDatalst.add('');
                    
                    inc++;
                    intDatalst.add(inc);
                    // contract rate schedule list
                    //contrRateSegLst[0].RateCode = 'Count'+i;
                    contrDetLst = new Wrapper_Znalytics_Enrollment.ContractDetailList(contractList.Opportunity_Id__c ,contractList.StartDate,contractList.EndDate,enrollmentList[0].Contract_Type_Code__c,contrRateSchMap.get(utilityAccList[i].Id),volList,'','','','','',0,'',0,''); 
                    ContractDetailListMap2.put(utilityAccList[i].Id, new List<Wrapper_Znalytics_Enrollment.ContractDetailList> {contrDetLst});
                    contrDetList.add(contrDetLst);
                    
                  //  system.debug('UATaxExpt.get(utilityAccList[i].Name)==>'+UATaxExpt.get(utilityAccList[i].Name)+'utilityAccList[i].Name'+utilityAccList[i].Name);
                    
                    Wrapper_Znalytics_Enrollment.ServiceAccountList servAccLstNew = new Wrapper_Znalytics_Enrollment.ServiceAccountList(UATransMap.get(utilityAccList[i].Name),strDatalst,utilityAccList[i].Service_Class__c, boolDatalst,intDatalst,authConlst,MeterList,ContractDetailListMap2.get(utilityAccList[i].Id),serviceAddressMap.get(utilityAccList[i].Id), UATaxExpt.get(utilityAccList[i].Name));
                    ServiceAccountListMap.put(utilityAccList[i].Id, new List<Wrapper_Znalytics_Enrollment.ServiceAccountList> {servAccLstNew});
                    serviceAccountList.add(servAccLstNew);
                    if(enrollmentList[0].Invoice_Billing_Type__c != 'Summary Billing'){
                        billAddrLstNew = new Wrapper_Znalytics_Enrollment.BillingAccountList(mailAddr,ServiceAccountListMap.get(utilityAccList[i].Id),enrollmentList[0].Sold_Date__c,authContaList,enrollmentList[0].Contract_Source_Code__c,enrollmentList[0].Bill_Format_Code__c,enrollmentList[0].Bill_Type__c,false,0,inc, '','',0,'',0,false,'','PRT','',0); 
                        billAccountListMap.put(utilityAccList[i].Id,billAddrLstNew);
                        billAccountListMap.get(utilityAccList[i].Id).BillTypeCode = UAUAEMap.get(utilityAccList[i].Id).Bill_Type__c;
                        billAcclist.add(billAccountListMap.get(utilityAccList[i].Id));
                    }
                }
                List<Wrapper_Znalytics_Enrollment.ContractDetailList> contrDetLstfinal = new List<Wrapper_Znalytics_Enrollment.ContractDetailList>();
                for(Wrapper_Znalytics_Enrollment.ServiceAccountList servAcc : serviceAccountList){
                    contrRateSegLst.clear();
                    
                    
                    Wrapper_Znalytics_Enrollment.ContractRateSegmentList contrRateSegnew = new Wrapper_Znalytics_Enrollment.ContractRateSegmentList(contractList.ContractTerm, contractList.StartDate, contractList.EndDate, uaNamePricingGroupMap.get(servAcc.UtilityAccountNumber), contrSegDataLst); 
                    
                    contrRateSegLst.add(contrRateSegnew);
                    
                    Wrapper_Znalytics_Enrollment.ContractRateSchedule contrRateSch = new Wrapper_Znalytics_Enrollment.ContractRateSchedule(contractList.ContractTerm, contractList.StartDate, contractList.EndDate, uaNameRateScheduleMap.get(servAcc.UtilityAccountNumber),new List<Wrapper_Znalytics_Enrollment.ContractRateSegmentList>{contrRateSegnew});
                    
                    Wrapper_Znalytics_Enrollment.ContractDetailList contrDetLstNew = new Wrapper_Znalytics_Enrollment.ContractDetailList(contractList.Opportunity_Id__c ,contractList.StartDate,contractList.EndDate,enrollmentList[0].Contract_Type_Code__c,contrRateSch,volList,'','','','','',0,'',0,''); 
                    
                    
                    
                    contrDetLstfinal.add(contrDetLstNew);
                    servAcc.ContractDetailList[0] = contrDetLstNew;
                    serviceAccountListfinal.add(servAcc);
                    
                }
                
                if(enrollmentList[0].Invoice_Billing_Type__c == 'Summary Billing'){
                    billAcclist.clear();
                    billAddrLstNew  = new Wrapper_Znalytics_Enrollment.BillingAccountList(mailAddr,serviceAccountList,enrollmentList[0].Sold_Date__c,authContaList,enrollmentList[0].Contract_Source_Code__c,enrollmentList[0].Bill_Format_Code__c,enrollmentList[0].Bill_Type__c,false,0,inc, '','',0,'',0,false,'','PRT','',0); 
                    billAddrLstNew.BillTypeCode = enrollmentList[0].Bill_Type__c;
                    billAcclist.add(billAddrLstNew);
                } 
                Wrapper_Znalytics_Enrollment.Customer Cust = new Wrapper_Znalytics_Enrollment.Customer(enrollmentList[0].Langauge_Code__c,
                                                                                                       authConList,
                                                                                                       billAcclist,
                                                                                                       custComm,
                                                                                                       legalAddr,
                                                                                                       custIndv,
                                                                                                       contrLst,
                                                                                                       enrollmentList[0].Account__r.EOS_CustomerNumber__c,
                                                                                                       enrollmentList[0].Customer_Type_Code__c,
                                                                                                       depLst);
                String method = 'POST';
                Boolean CreateParent = false;
                list<String> SaleDetails = new list<String>();
                String LinkToParentCustomerNumber = '';
                String CorrelationId = 'd82aaa15-7842-d55f-b1f6-46fc7c3c185b';//accList[0].id;  
                String ConfirmationNumber = 'ZN83302886';  
                String SourceSystemDetailCode  = 'ZNP';
                list<String> ActivityLog= new list<String>();
                String saleType;
                if(enrollmentList[0].Account__r.EOS_CustomerNumber__c != NULL)
                    saleType = 'ADD BILLING ACCOUNT';
                else
                    saleType = enrollmentList[0].Sale_Type__c;
                Wrapper_Znalytics_Enrollment wrapZnEnr = new Wrapper_Znalytics_Enrollment(saleType, enrollmentList[0].Source_System__c,CreateParent,Cust,SaleDetails,LinkToParentCustomerNumber,CorrelationId,ConfirmationNumber,SourceSystemDetailCode,ActivityLog);
                
                String serialized = JSON.serialize(wrapZnEnr, true);
                string stringBody = serialized.replace('tempTransaction','Transaction');   
                System.debug('stringBody'+stringBody);
                
                //call the httpclass
                HttpRequestClassZnalyticsApi newHttpReq = new HttpRequestClassZnalyticsApi();
                
                String responseData = newHttpReq.doPost(method,stringBody);
                system.debug('responseData-->'+responseData);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'admin@decima.one'];
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                system.debug('' + System.Label.Znalytics_Debug_Email_Address);
                message.toAddresses = new String[System.Label.Znalytics_Debug_Email_Address.split(',')];
                message.subject = 'Znalytics Request Body Initiaited By - ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
                message.setOrgWideEmailAddressId(owea[0].Id);
                message.plainTextBody = stringBody;
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
                Map<String, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(responseData);
                //Map<String, Object> statusMessage = (Map<String, Object>) mapResponse.get('messages');
                Code = String.valueOf(mapResponse.get('code'));
                Integer IntegrationLogCode = Integer.valueOf(mapResponse.get('code'));
                
                InsertIntegrationLog intog = new InsertIntegrationLog(responseData, IntegrationLogCode, enrollmentId, method, selectedUAEs); 
                System.enqueueJob(intog);
            }
            catch(Exception ex){
                //Errors.remove(null);
                
                //SU:539 changed return type to Display Error message when Required Objects fields are missing
                string allstring = string.join(Errors,',');
                return 'Required data objects missing : '+allstring+'.';
            }
        }
        
        return Code;
    }
    @auraEnabled
    public static List<UAEListWrapper> getUAEs(Id recordId){
        List<UAEListWrapper> uaeList = new List<UAEListWrapper>();
        List<Utility_Account_Enrollment__c> uaeRecords = [SELECT Id,Enrollment__r.Contract__r.StartDate,Utility_Account__r.Average_Meter_Read_Date__c, Utility_Account__r.Name, Program_Code__c, Utility_Account__r.Utility__r.Name, Rate_Schedule_Name__c, Status__c, Bill_Type__c, Utility_Account__r.Service_Address__c, Utility_Account__r.Service_Class__c,Start_Date__c,Hold_Reason_Code__c,Hold_Transaction__c,Enrollment__r.Bill_Type__c,Tax_Exempt__c, Tax_Exempt_Code__c, Effective_Date__c, Percentage__c, Tax_Exempt_Certificate_Number__c FROM Utility_Account_Enrollment__c WHERE Enrollment__c =: recordId];
        Date currentDate = Date.Today();
        boolean StartDateIsValid = false;
        boolean StartDateSet = false;
        Date ContractDate =  uaeRecords[0].Enrollment__r.Contract__r.StartDate;
        Integer monthDiff = currentDate.monthsBetween(ContractDate);
        if(monthDiff == 0 || monthDiff == 1){
            StartDateIsValid = true;
            StartDateSet = true;
            system.debug('--469--');
        }
        
        for(Utility_Account_Enrollment__c uae: uaeRecords){
            if(StartDateSet == false){
                if(uae.Hold_Transaction__c == true && uae.Hold_Reason_Code__c != NULL && uae.Start_Date__c != NULL ){
                    StartDateIsValid = true;
                }
                else{
                    system.debug('--477--');
                    StartDateIsValid = false;
                    break;
                }
            }
        }
        
        for(Utility_Account_Enrollment__c uae: uaeRecords){
            uaeList.add(new UAEListWrapper(false,false,false,false,uae,false,false,false,false,StartDateIsValid,false,false,false,false,false));
        }
        
        return uaeList;
    }
    /* wrapper class */  
    public class UAEListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public boolean editRSN {get;set;}
        @AuraEnabled public boolean editStatus {get;set;}
        @AuraEnabled public boolean editPC {get;set;}
        @AuraEnabled public boolean editHoldReasonCode {get;set;}
        @AuraEnabled public boolean editHoldTransaction {get;set;}
        @AuraEnabled public boolean editStartDate {get;set;}
        @AuraEnabled public boolean invalidDate {get;set;}
        @AuraEnabled public boolean StartDateIsValid {get;set;}
        @AuraEnabled public boolean editTEC {get;set;}
        @AuraEnabled public boolean editEffectiveDate {get;set;}
        @AuraEnabled public boolean editPercentage {get;set;}
        @AuraEnabled public boolean editTEC_Number {get;set;}
        @AuraEnabled public boolean editTax_Exempt {get;set;}
        @AuraEnabled public  Utility_Account_Enrollment__c objUAE{get;set;}
        public UAEListWrapper(boolean isChecked, boolean editRSN, boolean editStatus, boolean editPC, Utility_Account_Enrollment__c objUAE,boolean editHoldReasonCode,boolean editHoldTransaction,boolean editStartDate,boolean invalidDate,boolean StartDateIsValid, boolean editTEC,boolean editEffectiveDate,boolean editPercentage,boolean editTEC_Number,boolean editTax_Exempt){
            this.isChecked = isChecked;
            this.editRSN = editRSN;
            this.editStatus = editStatus;
            this.editPC = editPC;
            this.objUAE = objUAE;
            this.editHoldReasonCode = editHoldReasonCode;
            this.editHoldTransaction = editHoldTransaction;
            this.editStartDate = editStartDate;
            this.invalidDate = invalidDate;
            this.StartDateIsValid = StartDateIsValid;
            this.editTEC = editTEC;
            this.editEffectiveDate = editEffectiveDate;
            this.editPercentage = editPercentage;
            this.editTEC_Number = editTEC_Number;
            this.editTax_Exempt = editTax_Exempt;
        }
    }
    
    @auraEnabled
    public static String submitEnrollment(Id recordId, List<Utility_Account_Enrollment__c> objUAEs){
        //SU:539 changed return type to Display Error message when Required Objects fields are missing
        String code = SubmitEnrollment.callZnalyticsAPI(recordId, objUAEs);
        system.debug('code  ' + code);
        return code;
    }
    
    @auraEnabled
    public static String saveUAE(List<Utility_Account_Enrollment__c> objUAE){
        String response ='';
        if(Utility_Account_Enrollment__c.sObjectType.getDescribe().isUpdateable()){
            update objUAE;
            response = 'success';
        }
        else
            response = 'Insufficient Access!';
        return response;
    }
    @auraEnabled
    public static Map<Id,List<Program_Code__c>> getProgramCodes(Id enrollmentId, List<Id> UAs){
        Enrollment__c eRecord = [SELECT Id, Rate_Amount__c FROM Enrollment__c WHERE Id =: enrollmentId];
        List<Utility_Account__c> UAList = [SELECT Id, Zone__c, Commodity__c FROM Utility_Account__c WHERE Id IN : UAs];
        Map<Id,List<Program_Code__c>> UAPMap = new Map<Id,List<Program_Code__c>>();
        List<Program_Code__c> programCodes = [SELECT Id, Commodity__c, Program_Number__c, Pricing_Group__c, Effective_Date__c, Termination_Date__c, Rate__c, ISO_Zone__c FROM Program_Code__c];
        for(Utility_Account__c ua: UAList){
            for(Program_Code__c pc: programCodes){
                if(/*pc.ISO_Zone__c == ua.Zone__c && */pc.Rate__c == eRecord.Rate_Amount__c && pc.Termination_Date__c == NULL && ua.Commodity__c.startsWith(pc.Commodity__c)){
                    if(!UAPMap.containsKey(ua.Id)){
                        UAPMap.put(ua.Id, new List<Program_Code__c> {pc});
                    }
                    else{
                        UAPMap.get(ua.Id).add(pc);
                    }
                }
            }
        }
        system.debug('UAPMap ' + UAPMap.Values());
        return UAPMap;
    }
}