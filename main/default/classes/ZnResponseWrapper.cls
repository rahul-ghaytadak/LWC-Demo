public class ZnResponseWrapper{
    public model model{get;set;}
    
    public class model{
        
        public list<enrollmentResultDetailList> enrollmentResultDetailList{get;set;}
    }
    public class enrollmentResultDetailList{
        public Integer serviceAccountId{get;set;}
        public String customerNumber{get;set;}
        public Integer customerId{get;set;} 
        public Integer billingAccountId{get;set;}
        public String utilityAccountNumber{get;set;}
		public String billingAccountNumber{get;set;}
    }
}