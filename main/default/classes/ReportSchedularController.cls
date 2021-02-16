/*
* @Purpose: Controller of ReportScheduler component.
* @Author: Vishwanath Kodgire
* @CreatedDate: 
* @Related Code: ReportSchedularController, BrokerReportSenderBatch, BrokerReportSenderScheduler
* @Test Class: ReportSchedularController_Test
* @LastModifiedDate:
* @LastModifiedBy: Rahul Ghaytadak
*/

public class ReportSchedularController {
	
    // Method to Retrive broker report from custom setting record details
    @AuraEnabled 
    public static List<SchedReports> getReportSchedulars() {
        List<SchedReports> rules = new List<SchedReports>();
        // Retrive custom setting record details
        for(Report_Schedular__c RS: [SELECT Id, Name,Toggle1__c,Send_Internally__c,Number_of_days__c, Report_Name__c, Time__c, Days__c,Day_of_week__c, Date_of_month__c,Report_Scheduled__c FROM Report_Schedular__c ])
            rules.add(new SchedReports(RS, false));
        return rules;
    }
    // Wrapper class to strore custom setting 'Report Schedular' and boolean variable
     public class SchedReports {
        @AuraEnabled public Report_Schedular__c RS {get;set;}
        @AuraEnabled public  boolean editRow{get;set;}
        
        public SchedReports(Report_Schedular__c RS, boolean editRow){
            this.RS = RS;
            this.editRow = editRow;
        }
    }
    
    // Method to schedule broker report
    @AuraEnabled 
    public static void scheduleReport(Report_Schedular__c RS) {
        system.debug('report ' + RS);
        update RS; 
         List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name, StartTime, EndTime, NextFireTime, CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: RS.Name];
        if(!ct.isEmpty())
            system.abortJob(ct[0].Id);
        List<String> timeValues = RS.Time__c.split(':');
        Time updatedTimeValue = Time.newInstance(Integer.valueOf(timeValues[0]), Integer.valueOf(timeValues[1]),0, 0);
        Datetime newtime = Datetime.newInstance(system.today(), updatedTimeValue);
         List<CronTrigger>  ctUpdated = [SELECT Id, CronJobDetail.Name, StartTime, EndTime, NextFireTime, CronExpression FROM CronTrigger WHERE CronJobDetail.Name =:RS.Name];
        if(ctUpdated.isEmpty()){
            // Call BrokerReportSenderScheduler class to schedule broker report for sending.
            BrokerReportSenderScheduler sched = new BrokerReportSenderScheduler();
            sched.reportName = RS.Name;
            sched.numberOfDays = RS.Number_of_days__c;
            sched.batchRunType = 'Scheduler';
            String cronexpression = '';
            
            if(RS.Days__c == 'Weekly'){
                cronexpression = '0 '+ newtime.minute()+ ' ' + newtime.hour() + ' ? * '+ RS.Day_of_week__c +' *';
            }
            if(RS.Days__c == 'Monthly'){
                cronexpression = '0 '+ newtime.minute()+ ' ' + newtime.hour() + ' '+RS.Date_of_month__c+' 1/1 ? *';
            }
            if(RS.Days__c == 'Everyday'){
                 cronexpression = '0 '+ newtime.minute()+ ' ' + newtime.hour() + ' 1/1 * ? *';              
            }
            if(RS.Days__c == 'Weekdays'){
                  cronexpression = '0 '+ newtime.minute()+ ' ' + newtime.hour() + ' ? * MON-FRI *';
            }
           
           System.schedule(RS.Name, cronexpression,sched );
           
        }
    }
    
    // Method to update broker report (custom settings details) 
    @AuraEnabled 
    public static List<SchedReports> updateReport(Report_Schedular__c updatedReport) {
        Upsert updatedReport;
       
        List<SchedReports> rules = new List<SchedReports>();
        for(Report_Schedular__c RS: [SELECT Id, Name, Send_Internally__c,Toggle1__c,Number_of_days__c, Report_Name__c, Time__c, Days__c,Day_of_week__c, Date_of_month__c,Report_Scheduled__c FROM Report_Schedular__c ])
            rules.add(new SchedReports(RS, false));
        return rules;
    }
   
    // Method to delete broker report (custom settings details) 
    @AuraEnabled 
    public static List<SchedReports> deleteReportSched(Report_Schedular__c deletedReport) {
        Delete deletedReport;
        List<SchedReports> rules = new List<SchedReports>();
        for(Report_Schedular__c RS: [SELECT Id, Name, Report_Name__c,Toggle1__c, Number_of_days__c,Time__c, Days__c,Day_of_week__c, Date_of_month__c,Report_Scheduled__c FROM Report_Schedular__c ])
            rules.add(new SchedReports(RS, false));
        return rules;
    }
    
    @AuraEnabled 
    public static void toggleOff(String reportName) {
       Report_Schedular__c RS = [SELECT Id, Name,Toggle1__c, Report_Name__c,Number_of_days__c,Time__c, Days__c,Day_of_week__c, Date_of_month__c,Report_Scheduled__c FROM Report_Schedular__c where Name=:reportName];   
       RS.Time__c = '';
       RS.Days__c = '';
       RS.Day_of_week__c = '';
       RS.Date_of_month__c = '';
       RS.Report_Scheduled__c = false;
       RS.Toggle1__c = false;
       RS.Number_of_days__c = null;
            update RS; 
        }
    
    
     @AuraEnabled 
    public static void toggleOff2(String reportName) {
       Report_Schedular__c RS = [SELECT Id, Name,Toggle1__c, Report_Name__c,Number_of_days__c,Time__c, Days__c,Day_of_week__c, Date_of_month__c,Report_Scheduled__c FROM Report_Schedular__c where Name=:reportName];   
       
       RS.Toggle1__c = false;
       
       List<CronTrigger> ct = [SELECT Id, CronJobDetail.Name, StartTime, EndTime, NextFireTime, CronExpression FROM CronTrigger WHERE CronJobDetail.Name =: RS.Name];
        if(!ct.isEmpty()){
            system.abortJob(ct[0].Id);
            update RS; 
        }
    }
    
    // Method to send broker report immediately
    @AuraEnabled
    public static void runNowReport(Report_Schedular__c report){
        BrokerReportSenderBatch b = new BrokerReportSenderBatch(); 
        b.reportName = report.Name;
        b.batchRunType = 'Manual';
        b.numberOfDays = report.Number_of_days__c;
        database.executebatch(b, 1);
    }
    
    // Method to Retrive batch logs
    @auraEnabled
    public static List<Batch_Log__c> getData(){
        return [SELECT id, Run_Type__c,Owner.Name,Status__c,name,Start_Date__c,Recipient_Mode__c, Completed_Date__c, CreatedDate, Exception__c FROM Batch_Log__c ORDER BY Name DESC ];
    }
}