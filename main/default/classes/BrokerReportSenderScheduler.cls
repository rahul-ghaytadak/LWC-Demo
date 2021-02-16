/*
* @Purpose: Used to Schedule broker report.
* @Author: Saurabh Chauhan
* @CreatedDate: 
* @Related Code: BrokerReportSenderBatch
* @Test Class: ReportSchedularController_Test
* @LastModifiedDate:
* @LastModifiedBy: Saurabh Chauhan
*/
global class BrokerReportSenderScheduler implements Schedulable {
    global string reportName = '';
    global String batchRunType = '';
    global Decimal numberOfDays = 0;
    global void execute(SchedulableContext sc) {
        BrokerReportSenderBatch b = new BrokerReportSenderBatch(); 
        b.reportName = reportName;
        b.batchRunType = batchRunType;
        b.numberOfDays = numberOfDays;
        database.executebatch(b, 1);
    }
    
}