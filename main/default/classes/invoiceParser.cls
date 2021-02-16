public class invoiceParser {
    @auraEnabled public model model{get;set;}
    @auraEnabled public String messages{get;set;}
    @auraEnabled public Integer code{get;set;}
    public class utilityChargeDetails{
        @auraEnabled public Decimal quantity{get;set;}
        @auraEnabled public String chargeServicePeriodEnd{get;set;}
        @auraEnabled public String uom{get;set;}
        @auraEnabled public String chargeServicePeriodStart{get;set;}
        @auraEnabled public Decimal rate{get;set;}
        @auraEnabled public String chargeDescription{get;set;}
        @auraEnabled public Decimal amount{get;set;}
        @auraEnabled public String chargeType{get;set;}
        @auraEnabled public Integer defaultDecimalPrecision{get;set;}
        @auraEnabled public String uomDescription{get;set;}
    }
    public class model{
        @auraEnabled public list<invoices> invoices{get;set;}
        @auraEnabled public String emailAddress{get;set;}
        @auraEnabled public Boolean hasDeliveredInvoices{get;set;}
        @auraEnabled public Integer billingAccountId{get;set;}
    }
    public class invoiceUtilityAccounts{
        @AuraEnabled public Boolean UAExpanded{get;set;}
        @auraEnabled public Decimal totalAmount{get;set;}
        @auraEnabled public Decimal otherCharges{get;set;}
        @auraEnabled public Decimal utilityCharges{get;set;}
        @auraEnabled public Decimal taxCharges{get;set;}
        @auraEnabled public Decimal energyCharges{get;set;}
        @auraEnabled public list<utilityChargeDetails> utilityChargeDetails{get;set;}
        @auraEnabled public Decimal quantity{get;set;}
        @auraEnabled public Decimal utilityPreviousInvoice{get;set;}
        @auraEnabled public String utilityServicePeriodEndDate{get;set;}
        @auraEnabled public Decimal utilityPayments{get;set;}
        @auraEnabled public String utilityServicePeriodStartDate{get;set;}
        @auraEnabled public Decimal utilityAdjustments{get;set;}
        @auraEnabled public String serviceAddressLine1{get;set;}
        @auraEnabled public Decimal utilityLateFee{get;set;}
        @auraEnabled public Integer utilityAccountId{get;set;}
        @auraEnabled public Decimal utilityEarlyTerminationFee{get;set;}
        @auraEnabled public String utilityAccountNumber{get;set;}
        @auraEnabled public String uom{get;set;}
    }
    public class invoices{
        @AuraEnabled public Boolean invoiceExpanded{get;set;}
        @auraEnabled public Boolean enableReverseInvoice{get;set;}
        @auraEnabled public list<invoiceUtilityAccounts> invoiceUtilityAccounts{get;set;}
        @auraEnabled public Decimal amount{get;set;}
        @auraEnabled public Integer billTypeId{get;set;}
        @auraEnabled public String dueDate{get;set;}
        @auraEnabled public String billTypeName{get;set;}
        @auraEnabled public String servicePeriodEndDate{get;set;}
        @auraEnabled public String invoiceCreateDate{get;set;}
        @auraEnabled public String servicePeriodStartDate{get;set;}
        @auraEnabled public Integer transactionHeaderId{get;set;}
        @auraEnabled public Decimal quantity{get;set;}
        @auraEnabled public String documentId{get;set;}
        @auraEnabled public String taxTransactionId{get;set;}
        @auraEnabled public Boolean isPending{get;set;}
        @auraEnabled public String filePath{get;set;}
        @auraEnabled public String invoiceStatusName{get;set;}
        @auraEnabled public String shadowInvoiceStatus{get;set;}
        @auraEnabled public String parentInvoiceId{get;set;}
        @auraEnabled public String invoiceDeliveryStatus{get;set;}
        @auraEnabled public Integer communicationRequestId{get;set;}
        @auraEnabled public String deliveryType{get;set;}
        @auraEnabled public String reverseInvoiceId{get;set;}
        @auraEnabled public String invoiceType{get;set;}
        @auraEnabled public String status{get;set;}
        @auraEnabled public Integer invoiceNumber{get;set;}
        @auraEnabled public String uom{get;set;}
        @auraEnabled public String invoiceDate{get;set;}
        @auraEnabled public String invoiceTypeCode{get;set;}
        @auraEnabled public String postDate{get;set;}
    }
    
}