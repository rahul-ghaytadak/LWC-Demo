@isTest
public class ProgramCodeUploader_Test {
    @isTest
    public static void method1(){
        StaticResource sr1 = [select body from StaticResource where name='ProgramCodeCSVTest'];
        blob csvfile1 = sr1.body;
        test.startTest();
        ProgramCodeUploader.insertData(csvfile1, 'FileName');
        ProgramCodeUploader.getData();
        test.stopTest();
    }
}