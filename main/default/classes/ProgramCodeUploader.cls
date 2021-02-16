public class ProgramCodeUploader {
    @AuraEnabled 
    public static List<Program_Code__c> insertData(Blob strfromlex, String FileName){
        
        List<Program_Code__c> returnList = new List<Program_Code__c>();
        try{
            String fileData = strfromlex.toString();
            List<String> csvFileLines = safeSplit(fileData, '\n');
            while(String.isBlank(csvFileLines[csvFileLines.size()-1])) { csvFileLines.remove(csvFileLines.size()-1); }

            
            List<Program_Code__c> newProgramCodes = new List<Program_Code__c>();
           
            for(Integer i=1; i<csvFileLines.size(); i++ ){
                String[] inputvalues = new String[]{};
                    inputvalues = Base_Class_Uploader.columns_Splitter(csvFileLines[i]);
                Program_Code__c PC = new Program_Code__c();
                PC.Commodity__c = inputvalues[0];
                PC.Program_Number__c = Integer.valueOf(inputvalues[1]);
                PC.Utility__c = System.Label.National_Grid_Utility_Id;
                PC.Pricing_Group__c = inputvalues[2];
                PC.Effective_Date__c = Date.valueOf(inputvalues[3]);
                PC.Termination_Date__c =inputvalues[4] != '' ? Date.parse(inputvalues[4]) : NULL;
                PC.Rate__c = Decimal.valueOf(inputvalues[5]);
                if(inputvalues.size()==7){
                  PC.ISO_Zone__c = inputvalues[6];
                }
                newProgramCodes.add(PC);
            }
            if(!newProgramCodes.isEmpty()){
                DELETE [SELECT Id FROM Program_Code__c];
                Insert newProgramCodes;
                returnList = [SELECT Id, Utility__r.Name, Utility__c, Commodity__c, Program_Number__c, Pricing_Group__c, Effective_Date__c, Termination_Date__c, Rate__c, ISO_Zone__c FROM Program_Code__c];
            }
        }
        catch(exception e){
            system.debug('exception ' + e.getLineNumber() +' - '+e.getMessage());
        }
        return returnList;
    }
    
    public static List<String> safeSplit(String inStr, String delim)
    {
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;
        
        List<String> output = new List<String>();
        
        Matcher m = Pattern.compile(delim).matcher(inStr);
        Integer lastEnd = 0;
        
        while(!m.hitEnd())
        {
            while(regexFindCount < regexFindLimit && !m.hitEnd())
            {
                if(m.find())
                {
                    output.add(inStr.substring(lastEnd, m.start()));  
                    lastEnd = m.end();
                }
                else
                {
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }
                
                regexFindCount++;
            }
            m.reset(inStr);        
            m.region(lastEnd, m.regionEnd());
            
            regexFindCount = 0;
        }
        
        return output;
    }
     @AuraEnabled 
    public static List<Program_Code__c> getData(){
        return [SELECT Id, Commodity__c, Utility__c, Utility__r.Name, Program_Number__c, Pricing_Group__c, Effective_Date__c, Termination_Date__c, Rate__c, ISO_Zone__c FROM Program_Code__c];
    }
}