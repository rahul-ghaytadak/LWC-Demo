/* 
* @Purpose: This class contains wrapper classes for different objects
* with constructors as per the structure defined in the given JSON.
* @Author: Aress
* @CreatedDate: 11/12/2019
* @Related Code: 
* @Test Class:
* @LastModifiedDate:
* @LastModifiedBy:
*/

public class Wrapper_Znalytics_Enrollment {
    
    public String SaleType{get;set;}
    
    public String SourceSystem{get; set;}
    
    public Boolean CreateParent{get;set;}
    
    public Customer Customer{get;set;}
    
    public String CorrelationId{get;set;}
    
    public String LinkToParentCustomerNumber{get;set;}
    
    public String ConfirmationNumber{get;set;}
    
    public list<String> SaleDetails{get;set;}
    
    public String SourceSystemDetailCode{get;set;}
    
    public list<String> ActivityLog{get;set;}
    
    public class tempTransaction{
        public String HoldReasonCode{get;set;}
        public String MonthlyUsageTypeCode{get;set;}
        public Boolean IsTransactionHold{get;set;}
        public String TransactionRequestTypeCode{get;set;}
        public String AccessDescription{get;set;}
        public String HuRequestTypeCode{get;set;}
        public String RequestedEffectiveDate{get;set;}
        public Integer TransactionRequestTypeId{get;set;}
        public DateTime ScheduledTransactionReleaseDate{get;set;}
        
        public tempTransaction(String HoldReasonCode,String MonthlyUsageTypeCode,Boolean IsTransactionHold,String TransactionRequestTypeCode,String AccessDescription,String HuRequestTypeCode,String RequestedEffectiveDate,Integer TransactionRequestTypeId,DateTime ScheduledTransactionReleaseDate){
            this.HoldReasonCode = HoldReasonCode;
            this.MonthlyUsageTypeCode = MonthlyUsageTypeCode;
            this.IsTransactionHold = IsTransactionHold;
            this.TransactionRequestTypeCode = TransactionRequestTypeCode;
            this.AccessDescription = AccessDescription; 
            this.HuRequestTypeCode = HuRequestTypeCode; 
            this.RequestedEffectiveDate = RequestedEffectiveDate;
            this.TransactionRequestTypeId = TransactionRequestTypeId;
            this.ScheduledTransactionReleaseDate = ScheduledTransactionReleaseDate; 
        } 
    }
    
    public class ServiceAddress{
        public String CountryCode{get;set;}
        public String City{get;set;}
        public String County{get;set;}
        public String Address3{get;set;}
        public String State{get;set;}
        public String Address2{get;set;}
        public String Zip5{get;set;} 
        public String Address1{get;set;}
        public String Zip4{get;set;}
        public String AttentionTo{get;set;}
        
        public ServiceAddress(String Address1,String City,String County, String State, String Zip){
            this.CountryCode = CountryCode;
            this.City = City;
            this.County = County;
            this.Address3 = Address3;
            this.State = State; 
            this.Address2 = Address2; 
            this.Zip5 = Zip;
            this.Address1 = Address1;
            this.Zip4 = Zip4; 
            this.AttentionTo = AttentionTo;  
        }
    }
    
    public class ServiceAccountList{
        public list<ContractDetailList> ContractDetailList{get;set;}
        public String MarketingInfo{get;set;}
        public ServiceAddress ServiceAddress{get;set;}
        public String SpecialNeedsAddress{get;set;}
        public tempTransaction tempTransaction{get;set;}
        public String UtilityBillingAccountNumber{get;set;}
        public String UtilityAccountNumber{get;set;}
        public String TaxDistrict{get;set;}
        public Boolean IsLowIncome{get;set;}
        public String ServiceDeliveryPoint{get;set;}
        public String IsSolar{get;set;}
        public String AggregationType{get;set;}
        public String AggregationCode{get;set;}
        public String NameKey{get;set;}
        public Boolean IsHumanNeeds{get;set;}
        public Boolean RescissionWaiver{get;set;}
        public String RateClass{get;set;}
        public Boolean NotificationWaiver{get;set;}
        public String UniversalServiceCode{get;set;}
        public String LastMeterRead{get;set;}
        public String PowerFactor{get;set;}
        public String MeterReadCycle{get;set;}
        public String FlatRateContract{get;set;}
        public String SupplierAccountNumber{get;set;}
        public list<String> AuthorizedContactList{get;set;}
        public list<String> MeterList{get;set;}
        //public String TaxExemption{get;set;}
        public Integer ServiceAccountReferenceId{get;set;}
        public Integer VoltageTypeId{get;set;}
        public Boolean IsTOU{get;set;}
        public Boolean IsUnmetered{get;set;}
        public Boolean IsAMS{get;set;}
        public String ClientCode{get;set;}
        public String AuthorizationTypeCode{get;set;}
        public String UtilityCode{get;set;}
        public String ServiceTypeCode{get;set;}
        public Integer BillTypeId{get;set;}
        public Integer BillFormatId{get;set;}
        public Boolean IsSupplierBill{get;set;}
        public String BillTypeCode{get;set;}
        public String BillFormatCode{get;set;}
        public String WheelingServiceCalculationTypeName{get;set;}
        public String MinPriceContractId{get;set;}
        public String PeakCapacityAllowanceId{get;set;}
        public String AmpereBreakerAvailabilityId{get;set;}
        public String AmpereSizeId{get;set;}
        public String WheelingServiceCalculationTypeId{get;set;}
        public String NextMeterReadDate{get;set;}
        public String BreakerKwCapacity{get;set;}
        public String BreakerKvaCapacity{get;set;}
        public String SupplyLineTypeId{get;set;}
        public String MaxAmpereBreakerCapacity{get;set;}
        public Boolean IsTermsAccepted{get;set;}
        public String DroppingRetailerCode{get;set;}
        public String DroppingRetailerCustomerNumber{get;set;}
        public String MemberName{get;set;}
        public String MemberNumber{get;set;}
        public taxExemption taxExemption{get;set;}
        //,tempTransaction tempTransaction
        public ServiceAccountList(tempTransaction tempTransaction,List<String> strData, String RateClass, List<Boolean> boolData, List<Integer> intData,list<String> AuthorizedContactList,list<String> MeterList,list<ContractDetailList> ContractDetailList,ServiceAddress ServiceAddress, taxExemption taxExemption){
            this.MarketingInfo = strData[0];
            this.SpecialNeedsAddress= strData[1];
            this.UtilityBillingAccountNumber= strData[2];
            this.UtilityAccountNumber= strData[3];
            this.TaxDistrict= strData[4];
            this.ServiceDeliveryPoint= strData[5];
            this.IsSolar= strData[6];
            this.AggregationType= strData[7];
            this.AggregationCode= strData[8];
            this.NameKey= strData[9];
            this.RateClass = RateClass;
            this.UniversalServiceCode = strData[11];
            this.LastMeterRead = strData[12];
            this.PowerFactor = strData[13];
            this.MeterReadCycle = strData[14];
            this.FlatRateContract = strData[15];
            this.SupplierAccountNumber = strData[16];
            //this.TaxExemption= strData[17];
            this.ClientCode = strData[18];
            this.AuthorizationTypeCode = strData[19];
            this.UtilityCode = strData[20];
            this.ServiceTypeCode = strData[21];
            this.BillTypeCode = strData[22];
            this.BillFormatCode = strData[23];
            this.WheelingServiceCalculationTypeName = strData[24];
            this.MinPriceContractId = strData[25];
            this.PeakCapacityAllowanceId = strData[26];
            this.AmpereBreakerAvailabilityId = strData[27];
            this.AmpereSizeId = strData[28];
            this.WheelingServiceCalculationTypeId = strData[29];
            this.NextMeterReadDate = strData[30];
            this.BreakerKwCapacity = strData[31];
            this.BreakerKvaCapacity = strData[32];
            this.SupplyLineTypeId = strData[33];
            this.MaxAmpereBreakerCapacity = strData[34];
            this.DroppingRetailerCode = strData[35];
            this.DroppingRetailerCustomerNumber = strData[36];
            this.MemberName = strData[37];
            this.MemberNumber   = strData[38];   
            this.IsLowIncome  = boolData[0];
            this.IsHumanNeeds  = boolData[1];
            this.RescissionWaiver  = boolData[2];
            this.NotificationWaiver  = boolData[3];
            this.IsTOU  = boolData[4];
            this.IsUnmetered  = boolData[5];
            this.IsAMS  = boolData[6];
            this.IsSupplierBill  = boolData[7];
            this.IsTermsAccepted  = boolData[8]; 
            system.debug('intData.size()'+intData.size());
            for(integer i=0; i<intData.size(); i++){
                this.ServiceAccountReferenceId  = intData[i];
                system.debug('ServiceAccountReferenceId: '+ServiceAccountReferenceId);
            }
            system.debug('intData: '+intData);
            //this.VoltageTypeId = intData[1];
            //this.BillTypeId = intData[2];
            //this.BillFormatId = intData[3];
            this.AuthorizedContactList = AuthorizedContactList;
            this.MeterList  =  MeterList;
            this.ContractDetailList =  ContractDetailList; 
            this.ServiceAddress   = ServiceAddress;
            this.tempTransaction  = tempTransaction;
            this.taxExemption = taxExemption;
        }
    }
    public class taxExemptionDetailList{
        public String taxExemptCode{get;set;}
        public Decimal taxExemptionAmount{get;set;}
        public String taxType{get;set;}
    }
    public class taxExemption{
        public String effectiveDate{get;set;}
        public list<taxExemptionDetailList> taxExemptionDetailList{get;set;}
        public String taxCertificateNumber{get;set;}
        public Integer serviceAccountReferenceId{get;set;}
    }
    public class MailAddress{
        public String AttentionTo{get;set;}
        public String Address1{get;set;}
        public String Address2{get;set;}
        public String Address3{get;set;}
        public String City{get;set;}
        public String County{get;set;}
        public String State{get;set;}
        public String Zip5{get;set;}
        public String Zip4{get;set;}
        public String CountryCode{get;set;}
        //String AttentionTo, String Address2, String Address3,String Zip4, String County 
        public MailAddress(String Address1,String City, String State,String Zip5,String CountryCode){
            this.AttentionTo = AttentionTo;  
            this.Address1 = Address1;
            this.Address2 = Address2; 
            this.Address3 = Address3;
            this.City = City;
            this.County = County;
            this.State = State; 
            this.Zip5 = Zip5;
            this.Zip4 = Zip4; 
            this.CountryCode = CountryCode;  
        }
    }
    
    public class LegalAddress{
        public String AttentionTo{get;set;}
        public String Zip4{get;set;}
        public String Zip5{get;set;}
        public String CountryCode{get;set;}
        public String State{get;set;}
        public String Address3{get;set;}
        public String City{get;set;}
        public String Address2{get;set;}
        public String County{get;set;}
        public String Address1{get;set;}
        
        public LegalAddress(String AttentionTo,String CountryCode, String State, String City,String County,String Address1){
            this.AttentionTo = AttentionTo;  
            this.Zip4 = Zip4; 
            this.Zip5 = Zip5;
            this.CountryCode = CountryCode;  
            this.State = State; 
            this.Address3 = Address3;
            this.City = City;  
            this.Address2 = Address2; 
            this.County = County;
            this.Address1 = Address1; 
        }
    }
    
    public class CustomerIndividual{
        public String DriverLicenseStateProvince{get;set;}
        public Boolean IsEmployee{get;set;}
        public Boolean IsSenior{get;set;}
        public Integer Last4SSN{get;set;}
        public Boolean IsDomesticViolence{get;set;}
        public Date BirthDate{get;set;}
        public String Suffix{get;set;}
        public String DriverLicenseNumber{get;set;}
        public String LastName{get;set;}
        public String CustomerName{get;set;}
        public String FirstName{get;set;}
        public String CustomerNameKana{get;set;}
        public String Prefix{get;set;}
        //String DriverLicenseStateProvince,Boolean IsEmployee,Boolean IsSenior,Integer Last4SSN,Boolean IsDomesticViolence,String DriverLicenseNumber,String CustomerName,
        public CustomerIndividual(Date BirthDate,String Suffix,String LastName,String FirstName,String Prefix, String DriverLicenseStateProvince,Boolean IsEmployee,Boolean IsSenior,Integer Last4SSN,Boolean IsDomesticViolence,String DriverLicenseNumber,String CustomerName){
            this.DriverLicenseStateProvince = DriverLicenseStateProvince;  
            this.IsEmployee = IsEmployee; 
            this.IsSenior = IsSenior;
            this.Last4SSN = Last4SSN;  
            this.IsDomesticViolence = IsDomesticViolence; 
            this.DriverLicenseStateProvince = DriverLicenseStateProvince;
            this.BirthDate = BirthDate;
            this.Suffix = Suffix;  
            this.DriverLicenseNumber = DriverLicenseNumber; 
            this.LastName = LastName;
            this.CustomerName = CustomerName;  
            this.FirstName = FirstName; 
            this.CustomerNameKana = CustomerNameKana;
            this.Prefix = Prefix;
        }
    }
    
    public class CustomerCommercial{
        public String CompanyName{get;set;}
        public String TaxId{get;set;}
        public String Dba{get;set;}
        //,String TaxId,String Dba
        public CustomerCommercial(String CompanyName){
            this.CompanyName = CompanyName;  
            this.TaxId = TaxId; 
            this.Dba = Dba;
        } 
    }
    
    public class Customer{
        public list<AuthorizedContactList> AuthorizedContactList{get;set;}
        public list<BillingAccountList> BillingAccountList{get;set;}
        public CustomerCommercial CustomerCommercial{get;set;}
        public String AccountManager{get;set;}
        public Boolean IsVIP{get;set;}
        public Integer CustomerProspectId{get;set;}
        public LegalAddress LegalAddress{get;set;}
        public String PassCode{get;set;}
        public CustomerIndividual CustomerIndividual{get;set;}
        public list<Contract> Contract{get;set;}
        public String LanguageCode{get;set;}
        public String LinkToCustomerNumber{get;set;}
        public String CustomerTypeCode{get;set;}
        public String CustomerSegmentCode{get;set;}
        public String MemberName{get;set;}
        public String MemberNumber{get;set;}
        public list<String> Deposit{get;set;}
        public Boolean IsDoNotEMail{get;set;}
        public Boolean IsDoNotMail{get;set;}
        public Boolean IsMember{get;set;}
        //String AccountManager,Boolean IsVIP,Integer CustomerProspectId, String PassCode,,Boolean IsDoNotEMail,Boolean IsDoNotMail,Boolean IsMembe 
        public Customer(String LanguageCode,
                        list<AuthorizedContactList> AuthorizedContactList,
                        list<BillingAccountList> BillingAccountList,
                        CustomerCommercial CustomerCommercial,
                        LegalAddress LegalAddress, 
                        CustomerIndividual CustomerIndividual,
                        list<Contract> Contract,
                        String LinkToCustomerNumber, 
                        String CustomerTypeCode,
                        list<String> Deposit) {
                            this.AuthorizedContactList = AuthorizedContactList;
                            this.BillingAccountList = BillingAccountList;
                            this.CustomerCommercial = CustomerCommercial;
                            this.AccountManager = AccountManager;
                            this.IsVIP = IsVIP;
                            this.CustomerProspectId = CustomerProspectId;
                            this.LegalAddress = LegalAddress;
                            this.PassCode = PassCode;
                            this.CustomerIndividual = CustomerIndividual;
                            this.Contract = Contract;
                            this.LanguageCode = LanguageCode;
                            this.LinkToCustomerNumber = LinkToCustomerNumber;
                            this.CustomerTypeCode = CustomerTypeCode;
                            this.CustomerSegmentCode = CustomerSegmentCode;
                            this.MemberName = MemberName;
                            this.MemberNumber = MemberNumber;
                            this.Deposit = Deposit;
                            this.IsDoNotEMail = IsDoNotEMail;
                            this.IsDoNotMail = IsDoNotMail;
                            this.IsMember = IsMember;
                        }
    }
    
    public class ContractSegmentDetailList{
        public Integer ContractSegmentDetailId{get;set;}
        public Decimal RateAmount{get;set;}
        
        public ContractSegmentDetailList(Integer ContractSegmentDetailId,Decimal RateAmount){
            this.ContractSegmentDetailId = ContractSegmentDetailId;  
            this.RateAmount = RateAmount; 
        }
    }
    
    public class ContractRateSegmentList{
        public Integer Term{get;set;}
        public Date ContractStartDate{get;set;}
        public Date ContractEndDate{get;set;}
        public String RateCode{get;set;}
        public list<ContractSegmentDetailList> ContractSegmentDetailList{get;set;}
        
        public ContractRateSegmentList(Integer Term,Date ContractStartDate,Date ContractEndDate,String RateCode, list<ContractSegmentDetailList> ContractSegmentDetailList) {
            this.Term = Term;
            this.ContractStartDate = ContractStartDate;
            this.ContractEndDate = ContractEndDate;
            this.RateCode = RateCode;
            this.ContractSegmentDetailList = ContractSegmentDetailList;
        }
    }
    
    public class ContractRateSchedule{
        public String RateScheduleName{get;set;}
        public Integer ContractTerm {get; set;}
        public Date ContractStartDate{get;set;}
        public Date ContractEndDate{get;set;}
        public Integer ETFAmount{get;set;}
        public list<ContractRateSegmentList> ContractRateSegmentList{get;set;}
        public String ETFCalculationTypeCode{get;set;}
        //, String ETFCalculationTypeCode, Integer ETFAmount,
        public ContractRateSchedule(Integer ContractTerm, Date ContractStartDate,Date ContractEndDate, String RateScheduleName,list<ContractRateSegmentList> ContractRateSegmentList){
            
            this.RateScheduleName = RateScheduleName;
            this.ETFAmount = ETFAmount;
            this.ContractRateSegmentList = ContractRateSegmentList;
            this.ETFCalculationTypeCode = ETFCalculationTypeCode;
        }
    }
    
    public class ContractDetailList{
        public String ContractNumber{get;set;}
        public Date ContractStartDate{get;set;}
        public Date ContractEndDate{get;set;}
        public String ChannelFee{get;set;}
        public Integer BrokerFee{get;set;}
        public String PromoCode{get;set;}
        public ContractRateSchedule ContractRateSchedule{get;set;}
        public String ContractTypeCode{get;set;}
        public String SalesAgencyCode{get;set;}
        public String SalesChannelCode{get;set;}
        public String SalesChannelPartnerCode{get;set;}
        public String CommissionTypeCode{get;set;}
        public String SalesAgentCode{get;set;}
        public Integer SalesAgentUserId{get;set;}
        public list<String> Volumes{get;set;}
        //String SalesAgencyCode,String SalesChannelCode,String SalesChannelPartnerCode,String CommissionTypeCode,String SalesAgentCode,Integer Sale  ,String ChannelFee,Integer BrokerFee,String PromoCode,      
        public ContractDetailList(String ContractNumber,Date ContractStartDate,Date ContractEndDate,String ContractTypeCode,ContractRateSchedule ContractRateSchedule,list<String> Volumes, String SalesAgencyCode,String SalesChannelCode,String SalesChannelPartnerCode,String CommissionTypeCode,String SalesAgentCode,Integer Sale  ,String ChannelFee,Integer BrokerFee,String PromoCode){
            this.ContractNumber = ContractNumber;
            this.ContractStartDate = ContractStartDate;
            this.ContractEndDate = ContractEndDate;
            this.ChannelFee = ChannelFee;
            this.BrokerFee = BrokerFee;
            this.PromoCode = PromoCode;
            this.ContractRateSchedule = ContractRateSchedule;
            this.ContractTypeCode = ContractTypeCode;
            this.SalesAgencyCode = SalesAgencyCode;
            this.SalesChannelCode = SalesChannelCode;
            this.SalesChannelPartnerCode = SalesChannelPartnerCode;
            this.CommissionTypeCode = CommissionTypeCode;
            this.SalesAgentCode = SalesAgentCode;
            this.SalesAgentUserId = SalesAgentUserId;
            this.Volumes = Volumes;  
        }
    }
    
    public class Contract{
        public Integer ContractTerm{get;set;}
        public String ContractNumber{get;set;}
        public String ContractId {get; set;}
        public Boolean CoTerminousEndDate{get;set;}
        public Date ContractSignedDate{get;set;}
        public list<String> DocumentUrl{get;set;}
        public Date ContractEndDate{get;set;}
        public String ServiceTypeCode{get;set;}
        public Date ContractStartDate{get;set;}
        //String ServiceTypeCode, String ContractNumber,Boolean CoTerminousEndDate,
        public Contract(String ContractId, Integer ContractTerm,Date ContractSignedDate,list<String> DocumentUrl,Date ContractEndDate,Date ContractStartDate,String ContractNumber){
            this.ContractId = ContractId;
            this.ContractTerm = ContractTerm;
            this.ContractNumber = ContractNumber;
            this.CoTerminousEndDate = CoTerminousEndDate;
            this.ContractSignedDate = ContractSignedDate;
            this.DocumentUrl = DocumentUrl;
            this.ContractEndDate = ContractEndDate;
            this.ServiceTypeCode = ServiceTypeCode;
            this.ContractStartDate = ContractStartDate;
        }
    }
    
    public class BillingAccountList{
        public MailAddress MailAddress{get;set;}
        public String SecondaryNotificationAddress{get;set;}
        public list<ServiceAccountList> ServiceAccountList{get;set;}
        public String BillDate{get;set;}
        public Integer PaymentTermOverride{get;set;}
        public Date SoldDate{get;set;}
        public list<AuthorizedContactList> AuthorizedContactList{get;set;}
        public Integer BillingAccountReferenceId{get;set;}
        public String IsBillHold{get;set;}
        public String ContractSourceCode{get;set;}
        public Boolean ApplyLateFees{get;set;}
        public Integer LateFeeOverride{get;set;}
        public Integer LateFeePercentOverride{get;set;}
        public String BillFormatCode{get;set;}
        public String BillTypeCode{get;set;}
        public Boolean IsClonedBa{get;set;}
        public String LinkToBillingAccountNumber{get;set;}
        public String DeliveryTypeCode{get;set;}
        public String PaymentCategoryCode{get;set;}
        public Integer PaymentCategoryId{get;set;}
        public Date closeDate {get; set;}
        
        public BillingAccountList( MailAddress MailAddress, list<ServiceAccountList> ServiceAccountList,Date SoldDate,list<AuthorizedContactList> AuthorizedContactList, String ContractSourceCode,String BillFormatCode,String BillTypeCode, Boolean ApplyLateFees,Integer LateFeeOverride,Integer BillingAccountReferenceId, String IsBillHold, String BillDate,Integer PaymentTermOverride, String SecondaryNotificationAddress,Integer LateFeePercentOverride,Boolean IsClonedBa,String LinkToBillingAccountNumber, String DeliveryTypeCode,String PaymentCategoryCode  ,Integer PaymentCategoryId){
            this.closeDate = closeDate;
            this.MailAddress = MailAddress;
            this.SecondaryNotificationAddress = SecondaryNotificationAddress;
            this.ServiceAccountList = ServiceAccountList;
            this.BillDate = BillDate;
            this.PaymentTermOverride = PaymentTermOverride;
            this.SoldDate = SoldDate;
            this.AuthorizedContactList = AuthorizedContactList;
            this.BillingAccountReferenceId = BillingAccountReferenceId;
            this.IsBillHold = IsBillHold;
            this.ContractSourceCode = ContractSourceCode;
            this.ApplyLateFees = ApplyLateFees;
            this.LateFeeOverride = LateFeeOverride;
            this.LateFeePercentOverride = LateFeePercentOverride;
            this.BillFormatCode = BillFormatCode;
            this.BillTypeCode = BillTypeCode;
            this.IsClonedBa = IsClonedBa;
            this.LinkToBillingAccountNumber = LinkToBillingAccountNumber;
            this.DeliveryTypeCode = DeliveryTypeCode;
            this.PaymentCategoryCode = PaymentCategoryCode;
            this.PaymentCategoryId = PaymentCategoryId;
        }
    }
    
    public class AuthorizedContactPhoneList{
        public String PhoneCountryCode{get;set;}
        public String PhoneTypeId{get;set;}
        public String ContactPhone{get;set;}
        public String PhoneTypeCode{get;set;}
        public Boolean IsPrimary{get;set;}
        public Boolean IsDoNotCall{get;set;}
        public String PhoneAreaCode{get;set;}
        public Boolean IsSMSAllowed{get;set;}
        public String PhoneNumber{get;set;}
        public String PhoneExtension{get;set;}
        public String SubscriberNumber{get;set;}
        //string PhoneCountryCode,string PhoneTypeId,string ContactPhone,string PhoneTypeCode,Boolean IsPrimary,Boolean IsDoNotCall,String PhoneAreaCode,Boolean IsSMSAllowed,,String PhoneExtension,String SubscriberNumber
        public AuthorizedContactPhoneList(String PhoneNumber, String PhoneAreaCode){
            this.PhoneCountryCode = PhoneCountryCode;
            this.PhoneTypeId = PhoneTypeId;
            this.ContactPhone = ContactPhone;
            this.PhoneTypeCode = PhoneTypeCode;
            this.IsPrimary = IsPrimary;
            this.IsDoNotCall = IsDoNotCall;
            this.PhoneAreaCode = PhoneAreaCode;
            this.IsSMSAllowed = IsSMSAllowed;
            this.PhoneNumber = PhoneNumber;
            this.PhoneExtension = PhoneExtension;
            this.SubscriberNumber = SubscriberNumber;
        }
    }
    
    public class AuthorizedContactList{
        public Date BirthDate{get;set;}
        public Boolean IsPrimary{get;set;}
        public list<AuthorizedContactPhoneList> AuthorizedContactPhoneList{get;set;}
        public list<AuthorizedContactEmailList> AuthorizedContactEmailList{get;set;}
        public String ContactTypeCode{get;set;}
        public String PhoneTypeCode {get; set;}
        public String Prefix{get;set;}
        public String FirstName{get;set;}
        public String LastName{get;set;}
        public String Suffix{get;set;}
        public String JpContactName{get;set;}
        public String ContactNameKana{get;set;}
        //String ContactTypeCode,String JpContactName, String ContactNameKana
        public AuthorizedContactList(Date BirthDate,Boolean IsPrimary,list<AuthorizedContactPhoneList> AuthorizedContactPhoneList,list<AuthorizedContactEmailList> AuthorizedContactEmailList,String Prefix,String FirstName,String LastName,String Suffix,String ContactTypeCode,String PhoneTypeCode){
            this.BirthDate = BirthDate;
            this.IsPrimary = IsPrimary;
            this.AuthorizedContactPhoneList = AuthorizedContactPhoneList;
            this.AuthorizedContactEmailList = AuthorizedContactEmailList;
            this.ContactTypeCode = ContactTypeCode;
            this.PhoneTypeCode = PhoneTypeCode;
            this.Prefix = Prefix;
            this.FirstName = FirstName;
            this.LastName = LastName;
            this.Suffix = Suffix;
            this.JpContactName = JpContactName;
            this.ContactNameKana = ContactNameKana;
        }
    }
    
    public class AuthorizedContactEmailList{
        public Boolean IsPrimary{get;set;}
        public String ContactEmail{get;set;}
        public String EmailAddress{get;set;}
        public String EmailTypeCode{get;set;}
        //Boolean IsPrimary,string ContactEmail,string EmailTypeCode, string EmailAddress
        public AuthorizedContactEmailList(){
            this.IsPrimary = IsPrimary;
            this.ContactEmail = ContactEmail;
            this.EmailAddress = EmailAddress;
            this.EmailTypeCode = EmailTypeCode;
        }
    }
    
    public class Enrollment{
        
        public String Name{get;set;}
        public Boolean SystemModstamp{get;set;}
        public String LastViewedDate{get;set;}
        public String LastReferencedDate{get;set;}
        public String Contract{get;set;}
        public String SaleType{get;set;}
        public String SourceSystem{get;set;}
        public String LangaugeCode{get;set;}
        public String CustomerTypeCode{get;set;}
        public String CompanyName{get;set;}
        public String BillFormatCode{get;set;}
        public String BillTypeCode{get;set;}
        public String ContractSourceCode{get;set;}
        public Date SoldDate{get;set;}
        public String Account{get;set;}
        public Date ContractStart{get;set;}
        public String ContractTypeCode{get;set;}
        public Decimal ContractTerm{get;set;}
        public String RateScheduleName{get;set;}
        public Decimal RateAmount{get;set;}
        public Date ContractSignedDate{get;set;}
        
        public Enrollment(String Name, Boolean SystemModstap, String LastViewedDate, String LastReferencedDate, 
                          String Contract, String SaleType, String SourceSystem, String LangaugeCode, 
                          String CustomerTypeCode, String CompanyName, 
                          String BillFormatCode, String BillTypeCode, String ContractSourceCode, 
                          Date SoldDate, String Account, Date ContractStart, 
                          String ContractTypeCode, Decimal ContractTerm, String RateScheduleName, 
                          Decimal RateAmount, Date ContractSignedDate){
                              
                              this.Name = Name;
                              this.SystemModstamp = SystemModstamp;
                              this.LastViewedDate = LastViewedDate;
                              this.LastReferencedDate = LastReferencedDate;
                              this.Contract = Contract;
                              this.SaleType = SaleType; 
                              this.SourceSystem = SourceSystem; 
                              this.LangaugeCode = LangaugeCode; 
                              this.CustomerTypeCode = CustomerTypeCode;
                              this.CompanyName = CompanyName; 
                              this.BillFormatCode = BillFormatCode; 
                              this.BillTypeCode = BillTypeCode; 
                              this.ContractSourceCode =ContractSourceCode;
                              this.SoldDate = SoldDate; 
                              this.Account = Account; 
                              this.ContractStart = ContractStart; 
                              this.ContractTypeCode =ContractTypeCode; 
                              this.ContractTerm = ContractTerm;
                              this.RateScheduleName = RateScheduleName; 
                              this.RateAmount = RateAmount;
                              this.ContractSignedDate = ContractSignedDate;
                              
                          }
        
    }
    
    public class UtilityAccountEnrollment{
        
        public String Name{get;set;}
        public String Enrollment{get;set;}
        public String UtilityAccount{get;set;}
        public String Status{get;set;}
        public String Contract{get;set;}
        
        public UtilityAccountEnrollment(String Name, String Enrollment, String UtilityAccount,String Status){
            this.Name =Name;
            this.Enrollment =Enrollment;
            this.UtilityAccount = UtilityAccount;
            this.Status =Status;
            this.Contract =Contract;
        }
        
    }
    
    public Wrapper_Znalytics_Enrollment(String SaleType, String SourceSystem, Boolean CreateParent,Customer Customer,list<String> SaleDetails,String LinkToParentCustomerNumber,String CorrelationId,String ConfirmationNumber,String SourceSystemDetailCode,list<String> ActivityLog){
        this.SaleType = SaleType;
        this.SourceSystem = SourceSystem;
        this.CreateParent= CreateParent;
        this.Customer = Customer;
        this.SaleDetails = SaleDetails;
        this.LinkToParentCustomerNumber = LinkToParentCustomerNumber;
        this.CorrelationId = CorrelationId;
        this.ConfirmationNumber = ConfirmationNumber;
        this.SourceSystemDetailCode= SourceSystemDetailCode;
        this.ActivityLog = ActivityLog;
    }
}