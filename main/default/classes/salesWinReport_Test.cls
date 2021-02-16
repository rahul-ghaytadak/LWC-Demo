@isTest
public class salesWinReport_Test {
  
    @isTest(SeeAllData=true)
    public static void TestMethod2(){
        ApexPages.StandardSetController controller;
        salesWinReport swin = new salesWinReport(controller);
        swin.saveNext();
        swin.savePrev();
    }
    
   
    
}