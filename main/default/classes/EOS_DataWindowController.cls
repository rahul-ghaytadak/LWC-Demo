public class EOS_DataWindowController {
    
    @auraEnabled
    public static List<BANWrapper> getBilingAccounts(Id recordId){
        List<BANWrapper> billingAccountNumberList = new List<BANWrapper>();
        List<AggregateResult> billingAccounts = [SELECT count(id), EOS_BillingAccountNumber__c FROM Utility_account__c WHERE EOS_BillingAccountNumber__c != NULL AND Account__c =: recordId GROUP BY EOS_BillingAccountNumber__c];
        for(AggregateResult a: billingAccounts ){
            string ban =  String.valueOf(a.get('EOS_BillingAccountNumber__c'));
            billingAccountNumberList.add(new BANWrapper(false, ban ));
        }
        return billingAccountNumberList;
    }
    public class BANWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  String billingAccountNumber{get;set;}
        public BANWrapper(boolean isChecked, String billingAccountNumber){
            this.isChecked = isChecked;
            this.billingAccountNumber = billingAccountNumber;
        }
    }
    @auraEnabled
    public static parseResponse getLedgerSummary(String EOS_BillingAccountNumber){
        parseResponse parsedResponse;
        try{
        HttpRequest req = new HttpRequest();
        req.setEndpoint(system.label.EOS_DataWindowEndpoint+'ar/ui/ledgersummary/'+ EOS_BillingAccountNumber);
        req.setMethod('GET');	
        req.setHeader('Ocp-Apim-Subscription-Key', system.label.EOS_DataWindowSubsciptionKey);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        string response = res.getBody();
        //string resp = '{ "model": [ { "ArType": "string", "RefNumber": 0, "PostDateTime": "2016-12-16T05:58:33.594Z", "TransactionDateTime": "2016-12-16T05:58:33.594Z", "Description": "string", "Amount": 0, "Balance": 0, "LedgerDetail": { "PaymentSource": "string", "PostedBy": "string", "PaymentComments": "string", "ApprovedBy": "string", "AdjustmentComments": "string", "DeliveryType": "string", "DeliveryStatus": "string", "InvoiceApprovedBy": "string", "EnergyCharges": "string", "UtilityCharges": "string", "OtherCharges": "string", "Taxes": "string" } } ], "code": "Continue", "messages": [ { "message": "string", "code": "string", "severity": "UnKnown" } ] }';
        parsedResponse = (parseResponse) JSON.deserialize(response, parseResponse.class);
        System.debug('response ' + parsedResponse);
        Boolean containsInvoice = false;
        List<Integer> invoiceIds = new List<Integer>();
        Integer billingAccountId;
            if(res.getStatusCode() == 200){
                for(model m: parsedResponse.model){
                    m.expanded = false;
                    if(m.arType == 'Invoice') {containsInvoice = true; invoiceIds.add(m.refNumber); billingAccountId = m.billingAccountId;}
                }
                if(containsInvoice){
                    List<invoiceParser.invoices> invoiceSummary = new List<invoiceParser.invoices>();
                    for(Integer invoice : invoiceIds){
                        HttpRequest invoiceReq = new HttpRequest();
                        invoiceReq.setEndpoint(system.label.EOS_DataWindowEndpoint+'invoice/billingAccount/'+ billingAccountId + '/utilityDetailsOfInvoiceSummary/'+invoice);
                        invoiceReq.setMethod('GET');	
                        invoiceReq.setHeader('Ocp-Apim-Subscription-Key', system.label.EOS_DataWindowSubsciptionKey);
                        Http invoiceHttp = new Http();
                        HTTPResponse invoiceRes = invoiceHttp.send(invoiceReq);
                        string invoiceResponse = invoiceRes.getBody();
                        invoiceParser parsedInvoiceResponse = (invoiceParser) JSON.deserialize(invoiceResponse, invoiceParser.class);
                        System.debug('parsedInvoiceResponse  ' + parsedInvoiceResponse);
                        for(invoiceParser.invoices m: parsedInvoiceResponse.model.invoices){
                            m.invoiceExpanded = false;
                            for(invoiceParser.invoiceUtilityAccounts i:m.invoiceUtilityAccounts)
                                i.UAExpanded = false;
                            invoiceSummary.add(m);
                        }
                    }
                    parsedResponse.invoices = invoiceSummary;
                }
            }
            else if(res.getStatusCode() == 400){
                system.debug('res.getBody()' + res.getBody());
                parsedResponse.message = 'There are no billing records for ' + EOS_BillingAccountNumber + ' Billing Account number.';
                parsedResponse.code = String.valueOf(res.getStatusCode());
            }
            else{
                throw new applicationException(res.getBody());
            }
        }
        catch(exception e){
            parsedResponse.message = 'An error has occured. your System Administrator has been notified!';
            List<ApexEmailNotification> apexEmailNotif = [SELECT Id, User.Email, Email FROM ApexEmailNotification];
            OrgWideEmailAddress orgWideEmail = [SELECT Id, displayName, Address FROM OrgWideEmailAddress LIMIT 1];
            List<String> toAdds = new List<String>();
            if(!apexEmailNotif.isEmpty()){
                for(ApexEmailNotification u: apexEmailNotif)
                    toAdds.add(u.User.Email);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toaddresses = toAdds;
                message.setSubject('EOS API Error');
                message.setOrgWideEmailAddressId(orgWideEmail.Id);
                message.setHtmlBody(e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
            }
        }
        return parsedResponse;
    }
    
    public class parseResponse{
        @AuraEnabled public list<model> model{get;set;}
        @AuraEnabled public list<messages> messages{get;set;}
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public list<invoiceParser.invoices> invoices{get;set;}
        
    }
    public class model{
        @AuraEnabled public list<String> arLedgerViewDetails{get;set;}
        @AuraEnabled public Integer glLedgerId{get;set;}
        @AuraEnabled public String ledgerDetail{get;set;}
        @AuraEnabled public Boolean isDocumentAvailable{get;set;}
        @AuraEnabled public Boolean expanded{get;set;}
        @AuraEnabled public Decimal balance{get;set;}
        @AuraEnabled public String documentName{get;set;}
        @AuraEnabled public Decimal amount{get;set;}
        @AuraEnabled public String ledgerDisplayDescription{get;set;}
        @AuraEnabled public String description{get;set;}
        @AuraEnabled public Integer billingAccountId{get;set;}
        @AuraEnabled public String transactionDateTime{get;set;}
        @AuraEnabled public String billingAccountNumber{get;set;}
        @AuraEnabled public String postDateTime{get;set;}
        @AuraEnabled public String arTypeCode{get;set;}
        @AuraEnabled public Integer refNumber{get;set;}
        @AuraEnabled public String arType{get;set;}
    }
    public class messages{
        @AuraEnabled public String message{get;set;}
        @AuraEnabled public String severity{get;set;}
        @AuraEnabled public String code{get;set;}
    }
    public class LedgerDetail{
        @AuraEnabled public String DeliveryStatus{get;set;}
        @AuraEnabled public String EnergyCharges{get;set;}
        @AuraEnabled public String InvoiceApprovedBy{get;set;}
        @AuraEnabled public String UtilityCharges{get;set;}
        @AuraEnabled public String DeliveryType{get;set;}
        @AuraEnabled public String OtherCharges{get;set;}
        @AuraEnabled public String AdjustmentComments{get;set;}
        @AuraEnabled public String Taxes{get;set;}
        @AuraEnabled public String ApprovedBy{get;set;}
        @AuraEnabled public String PostedBy{get;set;}
        @AuraEnabled public String PaymentComments{get;set;}
        @AuraEnabled public String PaymentSource{get;set;}
    }
    public class applicationException extends Exception {}
    
}