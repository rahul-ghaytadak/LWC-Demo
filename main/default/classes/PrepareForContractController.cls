/*
* @Purpose: Controller Class for Quote Generator Component
* @Author: Vishwanath Kodgire
* @CreatedDate: 01/17/2020
* @Related Code: 
* @Test Class: PrepareForContractController_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/

public class PrepareForContractController {
    
    
    //To fetch and display QLI list on PFCScreen1 component
    @auraEnabled
    public static List<QLIListWrapper> getQLIs(Id quoteId, Boolean isUpdate){
        List<QLIListWrapper> qliList = new List<QLIListWrapper>();
        List<QuoteLineItem> qliRecords = [SELECT  Id,
                                          QuoteId,
                                          Product2.Name,
                                          Term_Months__c,
                                          Total_Usage__c,
                                          Base_Price__c,
                                          POR_Tax_Adjustment__c,
                                          Total_Unit_Price__c,
                                          Sales_Margin_per_unit__c,
                                          Broker_Margin_per_unit__c
                                          FROM QuoteLineItem
                                          WHERE QuoteId=: quoteId order by Term_Months__c];
        
        // Card SU-602 : Check credit check outcome is passed or not 
        Quote quo = [SELECT Id, Name, Price__c, Bill_Type__c FROM Quote Where Id =: quoteId];
        if(Quo.Bill_Type__c == 'Dual' || Quo.Bill_Type__c == 'UCB with Credit'){
            Price__c pr = [SELECT Id, Pricing_Request__c FROM Price__c Where Id =: Quo.Price__c ];
            Pricing_Request__c Preq = [SELECT Id, Credit_Details__r.Credit_Check_Outcome__c FROM Pricing_Request__c Where Id =: pr.Pricing_Request__c ];
            if(Preq.Credit_Details__r.Credit_Check_Outcome__c != null ){
                
                if(Preq.Credit_Details__r.Credit_Check_Outcome__c == 'Passed'){
                    for(QuoteLineItem qli: qliRecords)
                        qliList.add(new QLIListWrapper(false,qli,false));
                }else{
                    for(QuoteLineItem qli: qliRecords)
                        qliList.add(new QLIListWrapper(false,qli,true));
                }
            }else{
                for(QuoteLineItem qli: qliRecords)
                    qliList.add(new QLIListWrapper(false,qli,false));
            }
        }else{
            for(QuoteLineItem qli: qliRecords)
                qliList.add(new QLIListWrapper(false,qli,false));
        }
        
        
        if(isUpdate){
            Id oppId = [SELECT Id, OpportunityId FROM Quote WHERE Id=: quoteId].OpportunityId;
            Opportunity oppRecord = [SELECT Id, SyncedQuoteId, SyncedQuote.Name FROM Opportunity WHERE Id=: oppId];
            oppRecord.StageName = 'Quoting';
            oppRecord.SyncedQuoteId = quoteId;
            update oppRecord;
        }
        return qliList;
    }
    /* wrapper class */  
    public class QLIListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  QuoteLineItem objQLI{get;set;}
        @AuraEnabled public boolean ValidateCreditCheck {get;set;}
        public QLIListWrapper(boolean isChecked, QuoteLineItem objQLI, boolean ValidateCreditCheck){
            this.isChecked = isChecked;
            this.objQLI = objQLI;
            this.ValidateCreditCheck = ValidateCreditCheck;
        }
    }
    
    //To get other quote details like Quote Product,bill type,Name , IsSyncing.
    @auraEnabled
    public static List<quoteWrapper> getQuoteOptions(Id recordId){
        List<quoteWrapper> quoteOptions = new List<quoteWrapper>();
        List<quote> quoteRecords = [SELECT Id, Name, Bill_Type__c, isSyncing, Product__r.Name FROM Quote WHERE OpportunityId =: recordId ORDER BY QuoteNumber DESC];
        for(quote q:quoteRecords){
            quoteOptions.add( new quoteWrapper(q.IsSyncing, q.Id, q.Name,q.Product__r.Name, q.Bill_Type__c));
        }
        return quoteOptions;
    }
    
    //Wrapper class
    public class quoteWrapper {
        @AuraEnabled public boolean isSynced {get;set;}
        @AuraEnabled public Id quoteId{get;set;}
        @AuraEnabled public String quoteName{get;set;}
        @AuraEnabled public String productName{get;set;}
        @AuraEnabled public String BillType{get;set;}
        public quoteWrapper(boolean isSynced, String quoteId,String quoteName,String productName, String BillType){
            this.isSynced = isSynced;
            this.quoteId = quoteId;
            this.quoteName = quoteName;
            this.productName = productName;
            this.BillType = BillType;
        }
    }
    
    //To delete all the QuoteLineItems except the one which is selected from Screen 1 of PFC
    @auraEnabled
    public static List<OpportunityContactRole> updateQuote(List<quotelineItem> selectedLineItem){
        
        Trigger_Settings__c trgSetting = [SELECT Id,name,TriggerOn__c FROM Trigger_Settings__c WHERE Name = 'QuoteLineItem_Trigger'];   
        trgSetting.TriggerOn__c = false;
        update trgSetting;
        
        Set<Id> selectedLineItemIds = new Set<Id>();
        for(quotelineItem qli : selectedLineItem){
            selectedLineItemIds.add(qli.Id);
        }
        
        List<QuoteLineItem> qliToBeDeleted = [SELECT Id FROM QuoteLineItem WHERE QuoteId =: selectedLineItem[0].QuoteId AND Id NOT IN: selectedLineItemIds ];
        Delete qliToBeDeleted;
        Update selectedLineItem;
        
        Id oppId = [SELECT Id, OpportunityId FROM Quote WHERE Id=: selectedLineItem[0].QuoteId].OpportunityId;
        
        trgSetting.TriggerOn__c = true;
        update trgSetting;
        
        return [SELECT Id, Contact.Name, ContactId, Contact.Email, Contact.FirstName, Role, IsPrimary FROM OpportunityContactRole WHERE opportunityId =:oppId];
    }
    
    //To fetch customer contacts
    @auraEnabled
    public static List<Contact> getCustomerContacts(Id oppId){
        system.debug('here');
        Opportunity oppRecord = [SELECT Id, AccountId FROM Opportunity WHERE Id =: oppId];
        return [SELECT Id, Name, Email FROM Contact WHERE AccountId =: oppRecord.AccountId];
    }
    
    //To update the Opportunity stage and to Generate Customer Agreement by calling Conga Document Generator Api class
    @auraEnabled
    public static void secondScreenExit( Id oppId){
        System.debug('--Here--');
        List<OpportunityLineItem> oliLst = new List<OpportunityLineItem>([SELECT OpportunityId,PricebookEntryId, Product2Id, ProductCode, Name, Quantity, TotalPrice,ListPrice,Description, Base_Price__c, Term_Months__c, Volume_kWh__c, Name__c, Quote_Sales_Margin__c, Broker_Margin_per_unit__c, Sales_Margin_per_unit__c, Total_Unit_Price__c, Product_Name__c, If_Reset__c, Energy__c, Clean_Energy_RECs__c, Clean_Energy_ZECs__c, Unforced_Capacity__c, Ancillary_Services__c, Renewable_Energy_Voluntary__c, TOTS__c, NITS__c, ARRs__c, TECs__c, POR__c, GRT__c, PJM_Note_2__c, Output_Total_Unit_Price__c, Output_Broker_Margin__c, Product_Family__c FROM OpportunityLineItem where OpportunityId =: oppId]);
        Opportunity oppRecord = [SELECT Id, StageName, Account_Name__c, Name, SyncedQuoteId, Opportunity_Id__c, Account.Name, Customer_Agreement_Template__c FROM Opportunity WHERE Id=: oppId];
        
        for(OpportunityLineItem oli : oliLst){
            String fileName = oppRecord.Account_Name__c + ' - ' + oli.Term_Months__c + 'm - ' + oppRecord.Opportunity_ID__c + ' - ' + system.today().format();
            CongaDocumentGenerator.callCongaMultipleAgreements(oppId, oppRecord.Customer_Agreement_Template__c, System.Label.PFC_Conga_Query+oppRecord.SyncedQuoteId, fileName, NULL, NULL, FALSE, FALSE,integer.valueOf(oli.Term_Months__c));
        }
        oppRecord.StageName = 'Contracting';
        Update oppRecord;
    }
    
    //To Add and update opportunity contact roles
    @auraEnabled
    public static OpportunityContactRole updateContactRoles(Id contactId, OpportunityContactRole contactRole, Id oppId, String role){
        Id contactRoleId;
        if(contactRole != NULL){
            contactRole.contactId = ContactId;
            Update contactRole;
            contactRoleId = contactRole.Id;
        }
        else{
            OpportunityContactRole contactRoleNew = new OpportunityContactRole();
            contactRoleNew.ContactId = ContactId;
            contactRoleNew.OpportunityId = oppId;
            contactRoleNew.Role = role;
            Insert contactRoleNew;
            contactRoleId = contactRoleNew.Id;
        }
        
        return [SELECT Id, Contact.Name, ContactId, Contact.FirstName, Contact.Email, Role, IsPrimary FROM OpportunityContactRole WHERE Id =:contactRoleId];
    }
    
    //To fetch lookup values based on Object Name passed as a parameter along with the search key (lookup functionality)
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String accId, Boolean isInit,String BrokerType) {
        system.debug('ObjectName-->' + ObjectName);
        if(ObjectName == 'User' ){
            String searchKey = searchKeyWord + '%';
            
            List < sObject > returnList = new List < sObject > ();
            String sQuery = '';
            sQuery =  'select id, Name, Email, FirstName from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        }
        else if(ObjectName == 'Account' && (BrokerType != '' && BrokerType != null )){
            String searchKey = searchKeyWord + '%';
            
            List < sObject > returnList = new List < sObject > ();
            String sQuery = '';
            sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey AND Type =:BrokerType  order by createdDate DESC limit 5';
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        }
        else{
            String searchKey = searchKeyWord + '%';
            
            List < sObject > returnList = new List < sObject > ();
            
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
            String sQuery = '';
            if(isInit)
                sQuery =  'select id, Name, Email, FirstName from ' +ObjectName + ' where AccountId =: accId AND Name LIKE: searchKey order by createdDate DESC limit 5';
            else{
                String recordType = [SELECT Id, recordType.Name FROM Account WHERE Id =: accId].recordType.Name;
                sQuery =  'select id, Name, Email, FirstName from ' +ObjectName + ' where account.recordType.Name =: recordType AND Name LIKE: searchKey order by createdDate DESC limit 5';
            }
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        }
    }
    
    //To create record by clicking the '+New Contact' button on the Broker contact Lookup of the component.
    @AuraEnabled
    public static sObject getCreatedContact(String accId) {
        contact con;
        Datetime d = system.now();
        d = d.addSeconds(-5);
        List<Contact> c = [SELECT Id, Name, FirstName, Email FROM Contact WHERE AccountId =: accId AND CreatedDate >=: d ORDER BY CreatedDate DESC LIMIT 1];
        if(!c.isEmpty())
            con = c[0];
        else
            con = NULL;
        
        List<Account> acc = [SELECT Id, Name FROM Account WHERE CreatedDate >=: d ORDER BY CreatedDate DESC LIMIT 1];
        if(!Test.isRunningTest()){
            if(con == NULL){
                return acc[0];
            }
        }
        return con;
    }
    @AuraEnabled 
    public static void sendMailMethod(Id mMail, Id whatId, String mSubject ,String mbody, List<ContentDocumentLink> att, List<String> toAddresses, List<String> ccAddresses, List<Id> additionalFiles){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        String htmlbody =' <html> <div class="letterheadWrapper"> <style>p{margin-top:0px; margin-bottom:0px;}</style> <center> <table cellpadding="0" width="500" cellspacing="0" id="topTable" height="450"> <tbody> <tr valign="top"> <td style="background-color: rgb(255, 255, 255); vertical-align: top; height: 100px; text-align: center; width: 500px;"><img src="https://smartestenergyus--dev5--c.documentforce.com/servlet/servlet.ImageServer?id=015f0000000zAzm&oid=00Df0000001p4DG" /></td> </tr> <tr valign="top"> <td style=" background-color:#004D8F; bEditID:r2st1; bLabel:accent1; height:3px;"></td> </tr> <tr valign="top" height="400"><td teditid="c1r1" style=" background-color:#FFFFFF; bEditID:r3st1; color:#000000; bLabel:main; font-size:12pt; font-family:arial;" aeditid="c1r1" locked="0"><div style="color: rgb(0, 0, 0); font-family: arial; font-size: 12pt;">'+mBody+' </td></tr><tr valign="top"> <td style=" background-color:#004D8F; bEditID:r2st1; bLabel:accent1; height:3px;"></td> </tr> </tbody> </table> </center> </div></html> ';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(mMail);
        mail.setWhatId(whatId);
        mail.setSubject(mSubject);
        if(!ccAddresses.isEmpty()){
            mail.ccaddresses = ccAddresses;
        }
        if(!toAddresses.isEmpty()){
            mail.toaddresses = toAddresses;
        }
        mail.setHtmlBody(htmlbody);
        system.debug('att ' +att);
        List<String> docIds = new List<String>();
        if(att.size() != 0 || !additionalFiles.isEmpty()){
            Set<Id> AttIds = new Set<Id>();
            for(ContentDocumentLink cv : att){
                AttIds.add(cv.ContentDocumentId);
            }
            
            List<ContentVersion> cvs = [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN : additionalFiles OR ContentDocumentId IN : AttIds ];
            for(ContentVersion file: cvs)
                docIds.add(file.Id);
        }
        if(!docIds.isEmpty())
            mail.setEntityAttachments(docIds);
        mail.setSaveAsActivity(true);
        mail.setBccSender(true);
        mails.add(mail);
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);  
        system.debug('res ' + results);
    }   
    @AuraEnabled 
    public static EtAttWrapper getEmailTemplate(String emailTemplateName, Id recordId,integer noOfTerms){
        List<ContentDocumentLink> cdlToPass = new List<ContentDocumentLink>();
        Opportunity oppRecord = [SELECT Id, StageName, Account_Name__c, Name, SyncedQuoteId, Opportunity_Id__c, Account.Name, Customer_Agreement_Template__c FROM Opportunity WHERE Id=: recordId];
        EmailTemplate et = [SELECT Id, Subject,body, htmlValue FROM EmailTemplate WHERE developerName=: emailTemplateName LIMIT 1];
        system.debug('et: ' +et );
        et.Subject = et.Subject + ' ' + oppRecord.Account_Name__c + ' - ' + oppRecord.Opportunity_ID__c;
        Attachment att = [Select Id, Name,createdDate, Body From Attachment WHERE ParentId =:recordId ORDER BY CreatedDate DESC  LIMIT 1];
        List<ContentDocumentLink> cdl = [SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.Title,
                                         SystemModstamp FROM ContentDocumentLink where LinkedEntityId=: recordId ORDER BY SystemModstamp DESC ];
        for(integer i=0;i<noOfTerms;i++){
            cdlToPass.add(cdl[i]);
        }
        User userDetails = [SELECT Id, Name, FirstName, Email FROM User WHERE Id =: userInfo.getUserId()];
        return new EtAttWrapper(et, cdl[0], userDetails,cdlToPass);
    }
    public class EtAttWrapper {
        @AuraEnabled public emailTemplate et {get;set;}
        @AuraEnabled public  ContentDocumentLink cdl{get;set;}
        @AuraEnabled public  user userDetails{get;set;}
        @AuraEnabled public  List<ContentDocumentLink> cdLst{get;set;}
        
        public EtAttWrapper(emailTemplate et, ContentDocumentLink cdl, User userDetails, List<ContentDocumentLink> cdLst ){
            this.et = et;
            this.cdl = cdl;
            this.userDetails = userDetails;
            this.cdLst = cdLst;
        }
    }
    
    //Total Price Validation for NIMO.
    //1.Total Price should have '4' or '9' as 4th decimal.
    //2.Total Price should have '0' as the 5th decimal.
    @AuraEnabled
    public static boolean TotalPriceValidation(Id OpptyId,List<Decimal> TotalPriceLst, quotelineItem selectedLineItem){
        Boolean Validated = true;
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>([SELECT Id, Name,Start_Date__c,Status__c, Opportunity__c, Utility__c FROM Utility_Account_Opportunity__c where Opportunity__c=:OpptyId AND Utility__c LIKE 'National Grid%' AND Status__c = 'Priced']);
        Quote quote = [SELECT Id, Name,Bill_Type__c, OpportunityId,Price__r.Pricing_Request__r.Bill_Type__c,Price__r.Bill_Type__c, Price__c FROM Quote Where Id =: selectedLineItem.QuoteId ];
        List<Price__c> pr = [SELECT Id,Bill_Type__c,Pricing_Request__r.Bill_Type__c FROM Price__c Where Id =: quote.Price__c AND (Bill_Type__c = 'Dual' OR Pricing_Request__r.Bill_Type__c = 'Dual')];
        system.debug('pr'+pr);
        if(pr.size()>0 || quote.Bill_Type__c == 'Dual'){
            Validated = true;
        }
        else{
            if(UAOLst.size()>0 && TotalPriceLst.size()>0){
                for(Decimal TotalPrice : TotalPriceLst ){
                    System.debug('TotalPrice-->'+TotalPrice);
                    System.debug('9-->'+String.valueOf(TotalPrice.setscale(5)).left(6).right(1));
                    System.debug('0-->'+String.valueOf(TotalPrice.setscale(5)).left(7).right(1));
                    
                    if((String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '9' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0') || (String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '4' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0')){
                        if(Validated != false){ 
                            Validated = true;
                        }
                    }
                    else{
                        Validated = false;
                    }
                }
            }
        }
        system.debug('Validation->'+Validated);
        system.debug('TotalPriceLst->'+TotalPriceLst.size());
        return Validated;
    }
    
    @AuraEnabled
    public static boolean AllowNIMOValidation(Id OpptyId,List<Decimal> TotalPriceLst, quotelineItem selectedLineItem){
        Boolean Validated = true;
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>([SELECT Id, Name,Start_Date__c,Status__c, Opportunity__c, Utility__c FROM Utility_Account_Opportunity__c where Opportunity__c=:OpptyId AND Utility__c LIKE 'National Grid%' AND Status__c = 'Priced']);
        Quote quote = [SELECT Id, Name,Bill_Type__c, OpportunityId,Price__r.Pricing_Request__r.Bill_Type__c,Price__r.Bill_Type__c, Price__c FROM Quote Where Id =: selectedLineItem.QuoteId ];
        List<Price__c> pr = [SELECT Id,Bill_Type__c,Pricing_Request__r.Bill_Type__c FROM Price__c Where Id =: quote.Price__c AND (Bill_Type__c = 'Dual' OR Pricing_Request__r.Bill_Type__c = 'Dual')];
        system.debug('pr'+pr);
        if(pr.size()>0 || quote.Bill_Type__c == 'Dual'){
            Validated = true;
        }
        else{
            if(UAOLst.size()>0 && TotalPriceLst.size()>0){
                for(Decimal TotalPrice : TotalPriceLst ){
                    
                    if((String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '9' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0') || (String.valueOf(TotalPrice.setscale(5)).left(6).right(1) == '4' && String.valueOf(TotalPrice.setscale(5)).left(7).right(1) == '0')){
                        if(Validated != false){ 
                            Validated = true;
                        }
                    }
                    else{
                        Validated = false;
                    }
                }
            }
        }
        List<PermissionSetAssignment> PSA = [SELECT Id, PermissionSetId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'NIMO_Quote_Validation_Override' AND AssigneeId =: UserInfo.getUserId()];
        if(!PSA.isEmpty()){
            Validated = true;
        }
        return Validated;
    }
    
    public class OppWrapper {
        @AuraEnabled public boolean IsValid {get;set;}
        @AuraEnabled public boolean TaxExempt {get;set;}
        @AuraEnabled public Integer CountofTerms {get;set;}
        @AuraEnabled public  String Switching_type{get;set;}
        @AuraEnabled public  List<String> missedFieldsLstAcc = new List<String>();
        @AuraEnabled public  List<String> missedFieldsLstContact = new List<String>();
        @AuraEnabled public  List<String> missedFieldsLstOpp = new List<String>();
        @AuraEnabled public  List<Utility_Account_Opportunity__c> missedFieldsLstUA = new List<Utility_Account_Opportunity__c>();
        @AuraEnabled public  List<String> missingLstUA = new List<String>();
        @AuraEnabled public  String oppId{get;set;}
        @AuraEnabled public  String conId{get;set;}
        @AuraEnabled public  String accId{get;set;}
    }
    
    //In Progress....
    @AuraEnabled
    public static OppWrapper Acc_contractValidation(Id OpptyId,String Optionselected,boolean forcedValid){
        
        Set<Utility_Account_Opportunity__c> missedFieldsLstUAtoConvert = new Set<Utility_Account_Opportunity__c>();
        Set<String> setToconvert = new Set<String>();
        Opportunity opp = [SELECT Id,Option1__c,AccountId,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,Tax_Exempt__c,SyncedQuoteId,Switching_Type__c FROM Opportunity where Id=:OpptyId ];
        Contact con = new Contact();
        if(Optionselected== 'option1'){
            con = [SELECT id,FirstName,LastName,Phone FROM Contact WHERE AccountId =:opp.AccountId limit 1];
            opp.Option1__c = true;
        }
        else{
            opp.Option1__c = false;
        }
        update opp;
        OppWrapper OppWrapperObj = new OppWrapper();
        AggregateResult countofQli = [Select count(Id) from QuoteLineItem where QuoteId =: opp.SyncedQuoteId];  
        
        OppWrapperObj.CountofTerms = Integer.valueOf(countofQli.get('expr0'));
        OppWrapperObj.oppId = opp.Id;
        OppWrapperObj.accId = opp.AccountId;
        if(con.Id != null){
            OppWrapperObj.conId = con.Id;
        }
        
        if(opp.Account.BillingStreet == NULL || opp.Account.BillingStreet == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing Street');
        }
        
        if(opp.Account.BillingCity == NULL || opp.Account.BillingCity == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing City');
        }
        
        if(opp.Account.BillingState == NULL || opp.Account.BillingState == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing State');
        }
        
        if(opp.Account.BillingCountry == NULL || opp.Account.BillingCountry == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing Country');
        }
        
        if(opp.Account.BillingPostalCode == NULL || opp.Account.BillingPostalCode == ''){
            OppWrapperObj.missedFieldsLstAcc.add('Billing Zip');
        }
        
        if(con.FirstName == NULL || con.FirstName == ''){
            OppWrapperObj.missedFieldsLstContact.add('FirstName');
        }  
        if(con.LastName == NULL || con.LastName == ''){
            OppWrapperObj.missedFieldsLstContact.add('LastName');
        }
        if(con.Phone == NULL || con.Phone == ''){
            OppWrapperObj.missedFieldsLstContact.add('Phone');
        }
        
        if(Opp.Switching_Type__c == NULL || Opp.Switching_Type__c == ''){    
            OppWrapperObj.missedFieldsLstOpp.add('Switching Type');
        }
        
        List<Utility_Account_Opportunity__c> UAOLst = new List<Utility_Account_Opportunity__c>();
        UAOLst = [SELECT Id,Utility_Account__r.Commodity__c,Utility_Account__r.Service_Class__c ,Utility_Account__r.Name,Utility_Account__r.Zip__c,Utility_Account__r.State__c,Utility_Account__r.Street__c,Utility_Account__r.Country__c,Utility_Account__r.City__c FROM Utility_Account_Opportunity__c where Opportunity__c=:opp.Id AND Status__c='Priced'];
        
        for(Utility_Account_Opportunity__c uaObj : UAOLst){
            if(uaObj.Utility_Account__r.Street__c == NULL || uaObj.Utility_Account__r.Street__c == ''){
                setToconvert.add('Street');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            if(uaObj.Utility_Account__r.Commodity__c == NULL || uaObj.Utility_Account__r.Commodity__c == ''){
                setToconvert.add('Commodity');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            if(uaObj.Utility_Account__r.City__c == NULL || uaObj.Utility_Account__r.City__c == ''){
                setToconvert.add('City');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            if(uaObj.Utility_Account__r.State__c == NULL || uaObj.Utility_Account__r.State__c == ''){
                setToconvert.add('State');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            if(uaObj.Utility_Account__r.Country__c == NULL || uaObj.Utility_Account__r.Country__c == ''){
                setToconvert.add('Country');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
            
            if(uaObj.Utility_Account__r.Zip__c == NULL || uaObj.Utility_Account__r.Zip__c == ''){
                setToconvert.add('Zip');
                missedFieldsLstUAtoConvert.add(uaObj);
            }
        }
        List<String> lStrings = new List<String>(setToconvert);
        List<Utility_Account_Opportunity__c> lStringsUA = new List<Utility_Account_Opportunity__c>(missedFieldsLstUAtoConvert);
        OppWrapperObj.missingLstUA = lStrings;
        OppWrapperObj.missedFieldsLstUA = lStringsUA;
        if(OppWrapperObj.missedFieldsLstUA.size()>0 || OppWrapperObj.missedFieldsLstOpp.size()>0 || OppWrapperObj.missedFieldsLstContact.size()>0 || OppWrapperObj.missedFieldsLstAcc.size()>0 ||Integer.valueOf(countofQli.get('expr0')) > 1){
            OppWrapperObj.IsValid = true;
        }
        else{
            OppWrapperObj.IsValid = false;
        }
        System.debug('SelectedOption->'+Optionselected);
        if(Optionselected== 'option2' || Optionselected== 'option3'){
            OppWrapperObj.IsValid = false;
        }
        if(forcedValid == true){
            OppWrapperObj.IsValid = false;
        }
        OppWrapperObj.TaxExempt = opp.Tax_Exempt__c;
        OppWrapperObj.Switching_type = opp.Switching_Type__c;    
        
        return OppWrapperObj;
    }
}