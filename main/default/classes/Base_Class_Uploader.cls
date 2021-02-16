/***************************************************************************************************************************
* Name:        Base_Class_Uploader 
* Description: This class is used for splitting incoming csv rows column by column, To upload logs and to check given value
*              is double.
* 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-11-04       Aress Dev  				To testing the functionality of class.   
* 2021-01-04	   Rahul Ghaytadak			To remove the commented code.
****************************************************************************************************************************/
public class Base_Class_Uploader { 
    
    // To split the row values column by column
    public static List<String> columns_Splitter(String str){ 
        List<String> lstFinal = new List<String>();
        Set<String> setQuotedText = new Set<String>();
        string s1 = str.trim();
        String[] strSplitted = s1.split('"');
        for (integer i = 1; i < strSplitted.size(); i += 2) 
        { 
            setQuotedText.add(strSplitted[i]);
        }
        for (integer i = 0; i < strSplitted.size(); i++ ) 
        { 
            String str1 = strSplitted[i];
            String s = str1.trim();
            String str2 = s.trim().removeEnd(',');
            String str3 = str2.removeStart(',');
            if(str3.length() > 0)
            {
                if(setQuotedText.contains(str3))
                {
                    lstFinal.add(str3);
                }
                else
                {
                    List<String> lst2 = new List<String>();
                    lst2 = str3.split(',');
                    for(String s2 : lst2){
                        lstFinal.add(s2);
                    }
                }
            }
        }
        return lstFinal;
    }
    
    // To check that the given data is decimal or not.
    
    public static Boolean isNumeric(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    
    // To check that the given date is valid or not.
    public static Boolean isDate(String s){
        Boolean ReturnValue;
        try{
            date.parse(s);
            system.debug(' date.parse(s);-->'+ date.parse(s));
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    
    // To insert success or error log in Price_Upload_log object
     
    public static void createUploadLog(Id recordId,List<String> errmsg,String objName){
        Upload_Log__c pul = new Upload_Log__c();
        if(objName == 'Account'){
            pul.Account__c  = recordId;
        }
        if(objName == 'Pricing Request'){
            pul.Pricing_Request__c  = recordId;
        }
        system.debug('errmsg ==> ' + errmsg);
        if(errmsg.size()==0){
            pul.Result__c  = 'Records Inserted Successfully.';
        } else {
            String error= '';
            for(integer e=0; e<errmsg.size(); e++){ 
                    error += '\n'+errmsg[e];
            }
            pul.Result__c  =error;
        }
        insert pul;
    }
}