public class TaxExemptionController {
    
    @auraEnabled
    public static List<UATEListWrapper> getUATEs(Id accountId){
        List<UATEListWrapper> returnList = new List<UATEListWrapper>();
        List<Utility_Account__c> UAUATE = [SELECT Id, Name, (SELECT Id, Utility_Account__c, Utility_Account__r.Name, Tax_Exemption__c, Valid_From__c, Valid_To__c, Exemption_Amount__c FROM Utility_Account_Tax_Exemptions__r ORDER BY Valid_From__c DESC LIMIT 1) FROM Utility_Account__c WHERE Account__c =: accountId];
        for(Utility_Account__c ua: UAUATE){
            if(ua.Utility_Account_Tax_Exemptions__r.isEmpty())
                returnList.add(new UATEListWrapper(false, ua, null, null, null));
            else
                returnList.add(new UATEListWrapper(false, ua, ua.Utility_Account_Tax_Exemptions__r[0], null, null));
        }
        return returnList;
    }
    /* wrapper class */  
    public class UATEListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Utility_Account__c UA{get;set;}
        @AuraEnabled public  Utility_Account_Tax_Exemption__c UATE{get;set;}
        @AuraEnabled public Date newValidFrom {get;set;}
        @AuraEnabled public Decimal newExemptionAmount {get;set;}
       
        
        public UATEListWrapper(boolean isChecked, Utility_Account__c UA, Utility_Account_Tax_Exemption__c UATE, Date newValidFrom, Decimal newExemptionAmount){
            this.isChecked = isChecked;
            this.UA = UA;
            this.UATE = UATE;
            this.newValidFrom = newValidFrom;
            this.newExemptionAmount = newExemptionAmount;
        }
        
        public UATEListWrapper(){
           
        }
    }
    
    @auraEnabled
    public static Id finishProcess(Id accountId, List<UATEListWrapper> selectedRows, String fileData, String fileName){
        system.debug('fileData ' + fileData);

        Tax_Exemption__c TE = new Tax_Exemption__c(Account__c = accountId);
        Insert TE;
        List<Utility_Account_Tax_Exemption__c> lstUATES = new List<Utility_Account_Tax_Exemption__c>();
        
        for(UATEListWrapper wrapper : selectedRows ){
            if(wrapper.UATE != NULL){
                lstUATES.add(wrapper.UATE);
            }
            lstUATES.add(new Utility_Account_Tax_Exemption__c(Utility_Account__c = wrapper.UA.Id, Exemption_Amount__c = wrapper.newExemptionAmount, Valid_From__c = wrapper.newValidFrom, Tax_Exemption__c = TE.Id));
        }
        
        Upsert lstUATES;
        fileData = EncodingUtil.urlDecode(fileData, 'UTF-8');
        if(fileData != 'null'){
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.ContentLocation = 'S'; // S = Stored in Salesforce
            contentVersion.PathOnClient = fileName;
            contentVersion.Title = fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(fileData);
            insert contentVersion;
            List<ContentDocument> cd = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE LatestPublishedVersionId =:  contentVersion.Id];
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
            contentDocumentLink.ContentDocumentId = cd[0].Id;
            contentDocumentLink.LinkedEntityId = TE.Id;
            contentDocumentLink.ShareType = 'I'; // Inferred permission
            contentDocumentLink.Visibility = 'AllUsers';
            Insert contentDocumentLink;
        }
        return TE.Id;
    }
    @AuraEnabled
    public static Id SaveFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment attach = new Attachment();
        attach.parentId = parentId;
        attach.Body = EncodingUtil.base64Decode(base64Data);
        attach.Name = fileName;
        attach.ContentType = contentType;
        Insert attach;
        return attach.Id;
    }
}