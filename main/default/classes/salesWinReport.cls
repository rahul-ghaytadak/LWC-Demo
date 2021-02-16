public class salesWinReport {
    public String year{get;set;}
    public list<Opportunity> opplst{get;set;}
    public List<OppLstWrapper> OpplstToPass{get;set;}
    public List<Data> data{get;set;}
   
    public salesWinReport(ApexPages.StandardSetController controller)
    {
       savePrev();
    }
    
    public void saveNext()
    {
        Map<Integer,Integer> monthAndWonCountMap2020 = new Map<Integer,Integer>();
        Map<Integer,Integer> monthAndNewCountMap2020 = new Map<Integer,Integer>();
        
        List<AggregateResult> groupedWonResults2020 = [SELECT SUM(Annual_Volume_kWh__c),calendar_month(CreatedDate)
                                                   FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2020
                                                   GROUP BY calendar_month(CreatedDate) HAVING calendar_month(CreatedDate) >= 11];
        
        for (Integer i = 0; i< groupedWonResults2020.size(); i++)  {
            monthAndNewCountMap2020.put(Integer.valueOf(groupedWonResults2020[i].get('expr1')),Integer.valueOf(groupedWonResults2020[i].get('expr0')));
            
        }
        
        List<AggregateResult> groupedResults2020 = [SELECT SUM(Annual_Volume_kWh__c),calendar_month(CreatedDate)
                                                FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2020 AND StageName = 'Closed Won'
                                                GROUP BY calendar_month(CreatedDate) HAVING calendar_month(CreatedDate) >= 11];
        for (Integer i = 0; i< groupedResults2020.size(); i++)  {
            monthAndWonCountMap2020.put(Integer.valueOf(groupedResults2020[i].get('expr1')),Integer.valueOf(groupedResults2020[i].get('expr0')));
            
        }
       
        
        
        
        year = '2021';
        List<OppLstWrapper> OpplstN = new List<OppLstWrapper>();
        List<Data> datatoPass = new List<Data>();
        Set<Id> OppIds = new Set<Id>();
        Map<Integer,Integer> monthAndWonCountMap = new Map<Integer,Integer>();
        Map<Integer,Integer> monthAndNewCountMap = new Map<Integer,Integer>();
        Map<Integer,Decimal> monthAndMonthlyWinRate = new Map<Integer,Decimal>();
        
        List<AggregateResult> groupedWonResults = [SELECT SUM(Annual_Volume_kWh__c),calendar_month(CreatedDate)
                                                   FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2021
                                                   GROUP BY calendar_month(CreatedDate) HAVING calendar_month(CreatedDate) >= 1];
        
        for (Integer i = 0; i< groupedWonResults.size(); i++)  {
            monthAndNewCountMap.put(Integer.valueOf(groupedWonResults[i].get('expr1')),Integer.valueOf(groupedWonResults[i].get('expr0')));
            
        }
        
        List<AggregateResult> groupedResults = [SELECT SUM(Annual_Volume_kWh__c),calendar_month(CreatedDate)
                                                FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2021 AND StageName = 'Closed Won'
                                                GROUP BY calendar_month(CreatedDate) HAVING calendar_month(CreatedDate) >= 1];
        for (Integer i = 0; i< groupedResults.size(); i++)  {
            monthAndWonCountMap.put(Integer.valueOf(groupedResults[i].get('expr1')),Integer.valueOf(groupedResults[i].get('expr0')));
            Id opptyId = String.valueOf(groupedResults[i].get('Id'));
            OppIds.add(opptyId);
            
        }
        
        
        
        opplst = [SELECT Id,CreatedDate, Name FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2021 order by CreatedDate ];
        Integer currMonth = 0;
        Integer AllOppCount = 0;
        List<Integer> Monthchecked = new List<Integer>();
        for(integer i=0; i<opplst.size(); i++){
            OppLstWrapper oppObj = new OppLstWrapper();
            if(Integer.valueOf(opplst[i].CreatedDate.format('M')) != currMonth){
                currMonth = Integer.valueOf(opplst[i].CreatedDate.format('M'));
                if(monthAndWonCountMap.containskey(currMonth)){
                    AllOppCount = monthAndWonCountMap.get(currMonth);
                }
                else{
                    AllOppCount = 0;
                }
                if(monthAndNewCountMap.get(currMonth) != 0){
                    monthAndMonthlyWinRate.put(currMonth,((Decimal.valueOf(AllOppCount)/monthAndNewCountMap.get(currMonth))*100).setscale(2));
                }
                else{
                    monthAndMonthlyWinRate.put(currMonth,0);
                }
                
            }
            if(!Monthchecked.contains(currMonth)){
                Monthchecked.add(currMonth);
                oppObj.month = opplst[i].CreatedDate;
                oppObj.newOpptys = monthAndNewCountMap.get(currMonth);
                oppObj.wonOpptys = monthAndWonCountMap.get(currMonth);
                oppObj.monthlyWinRate = monthAndMonthlyWinRate.get(currMonth);
                if(currMonth == 1){
                    oppObj.threeMonthWinRate = 0;
                    Decimal currMonthWon = 0.0;
                    Decimal currMonthWon1 = 0.0;
                    Decimal currMonthWon2 = 0.0;
                   
                    if(monthAndWonCountMap.containskey(currMonth)){
                        currMonthWon = monthAndWonCountMap.get(currMonth);
                    }
                    if(monthAndWonCountMap2020.containskey(11)){
                        currMonthWon1 = monthAndWonCountMap2020.get(11);
                    }
                    if(monthAndWonCountMap2020.containskey(12)){
                        currMonthWon2 = monthAndWonCountMap2020.get(12);
                    }
                  
                    oppObj.threeMonthWinRate = (( (currMonthWon+ currMonthWon1+currMonthWon2) / (monthAndNewCountMap.get(currMonth)+ monthAndNewCountMap2020.get(11)+monthAndNewCountMap2020.get(12)))*100).setscale(2);    
                    datatoPass.add(new Data('Jan', monthAndMonthlyWinRate.get(currMonth), oppObj.threeMonthWinRate));
                }
                 if(currMonth == 2){
                  //   oppObj.threeMonthWinRate = 0;
                    Decimal currMonthWon = 0.0;
                    Decimal currMonthWon1 = 0.0;
                    Decimal currMonthWon2 = 0.0;
                   
                    if(monthAndWonCountMap.containskey(currMonth)){
                        currMonthWon = monthAndWonCountMap.get(currMonth);
                    }
                    if(monthAndWonCountMap.containskey(currMonth-1)){
                        currMonthWon1 = monthAndWonCountMap.get(currMonth-1);
                    }
                    if(monthAndWonCountMap2020.containskey(12)){
                        currMonthWon2 = monthAndWonCountMap2020.get(12);
                    }
                     oppObj.threeMonthWinRate = (( (currMonthWon+ currMonthWon1+currMonthWon2) / (monthAndNewCountMap.get(currMonth)+ monthAndNewCountMap.get(currMonth-1)+monthAndNewCountMap2020.get(12)))*100).setscale(2);    
                     datatoPass.add(new Data('Feb', monthAndMonthlyWinRate.get(currMonth), oppObj.threeMonthWinRate));
                }
               // oppObj.threeMonthWinRate = null;
                if(currMonth >= 3){
                    Decimal currMonthWon = 0.0;
                    Decimal currMonthWon1 = 0.0;
                    Decimal currMonthWon2 = 0.0;  
                    if(monthAndWonCountMap.containskey(currMonth)){
                        currMonthWon = monthAndWonCountMap.get(currMonth);
                    }
                    if(monthAndWonCountMap.containskey(currMonth-1)){
                        currMonthWon1 = monthAndWonCountMap.get(currMonth-1);
                    }
                    if(monthAndWonCountMap.containskey(currMonth-2)){
                        currMonthWon2 = monthAndWonCountMap.get(currMonth-2);
                    }
                    
                    
                    oppObj.threeMonthWinRate = (( (currMonthWon+ currMonthWon1+currMonthWon2) / (monthAndNewCountMap.get(currMonth)+ monthAndNewCountMap.get(currMonth-1)+monthAndNewCountMap.get(currMonth-2)))*100).setscale(2);    
                    
                    datatoPass.add(new Data(opplst[i].CreatedDate.format('MMM'), monthAndMonthlyWinRate.get(currMonth), oppObj.threeMonthWinRate));
                } 
                OpplstN.add(oppObj);
            }
        }
        OpplstToPass = OpplstN;
        if(datatoPass.size() == 1){
         datatoPass.add(new Data('Feb', 0, 0));
        }
        data = datatoPass;
    }
    
     public void savePrev()
    {
        Map<Integer,Integer> monthAndWonCountMap2020 = new Map<Integer,Integer>();
        Map<Integer,Integer> monthAndNewCountMap2020 = new Map<Integer,Integer>();
        
        List<AggregateResult> groupedWonResults2020 = [SELECT SUM(Annual_Volume_kWh__c),calendar_month(CreatedDate)
                                                   FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2019
                                                   GROUP BY calendar_month(CreatedDate) HAVING calendar_month(CreatedDate) >= 11];
        
        for (Integer i = 0; i< groupedWonResults2020.size(); i++)  {
            monthAndNewCountMap2020.put(Integer.valueOf(groupedWonResults2020[i].get('expr1')),Integer.valueOf(groupedWonResults2020[i].get('expr0')));
            
        }
        
        List<AggregateResult> groupedResults2020 = [SELECT SUM(Annual_Volume_kWh__c),calendar_month(CreatedDate)
                                                FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2019 AND StageName = 'Closed Won'
                                                GROUP BY calendar_month(CreatedDate) HAVING calendar_month(CreatedDate) >= 11];
        for (Integer i = 0; i< groupedResults2020.size(); i++)  {
            monthAndWonCountMap2020.put(Integer.valueOf(groupedResults2020[i].get('expr1')),Integer.valueOf(groupedResults2020[i].get('expr0')));
            
        }
       
        
        
        
        year = '2020';
        List<OppLstWrapper> OpplstN = new List<OppLstWrapper>();
        List<Data> datatoPass = new List<Data>();
        Set<Id> OppIds = new Set<Id>();
        Map<Integer,Integer> monthAndWonCountMap = new Map<Integer,Integer>();
        Map<Integer,Integer> monthAndNewCountMap = new Map<Integer,Integer>();
        Map<Integer,Decimal> monthAndMonthlyWinRate = new Map<Integer,Decimal>();
        
        List<AggregateResult> groupedWonResults = [SELECT SUM(Annual_Volume_kWh__c),calendar_month(CreatedDate)
                                                   FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2020
                                                   GROUP BY calendar_month(CreatedDate) HAVING calendar_month(CreatedDate) >= 1];
        
        for (Integer i = 0; i< groupedWonResults.size(); i++)  {
            monthAndNewCountMap.put(Integer.valueOf(groupedWonResults[i].get('expr1')),Integer.valueOf(groupedWonResults[i].get('expr0')));
            
        }
        
        List<AggregateResult> groupedResults = [SELECT SUM(Annual_Volume_kWh__c),calendar_month(CreatedDate)
                                                FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2020 AND StageName = 'Closed Won'
                                                GROUP BY calendar_month(CreatedDate) HAVING calendar_month(CreatedDate) >= 1];
        for (Integer i = 0; i< groupedResults.size(); i++)  {
            monthAndWonCountMap.put(Integer.valueOf(groupedResults[i].get('expr1')),Integer.valueOf(groupedResults[i].get('expr0')));
            Id opptyId = String.valueOf(groupedResults[i].get('Id'));
            OppIds.add(opptyId);
            
        }
        
        
        
        opplst = [SELECT Id,CreatedDate, Name FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) >= 2020 order by CreatedDate ];
        Integer currMonth = 0;
        Integer AllOppCount = 0;
        List<Integer> Monthchecked = new List<Integer>();
        for(integer i=0; i<opplst.size(); i++){
            OppLstWrapper oppObj = new OppLstWrapper();
            if(Integer.valueOf(opplst[i].CreatedDate.format('M')) != currMonth){
                currMonth = Integer.valueOf(opplst[i].CreatedDate.format('M'));
                if(monthAndWonCountMap.containskey(currMonth)){
                    AllOppCount = monthAndWonCountMap.get(currMonth);
                }
                else{
                    AllOppCount = 0;
                }
                if(monthAndNewCountMap.get(currMonth) != 0){
                    monthAndMonthlyWinRate.put(currMonth,((Decimal.valueOf(AllOppCount)/monthAndNewCountMap.get(currMonth))*100).setscale(2));
                }
                else{
                    monthAndMonthlyWinRate.put(currMonth,0);
                }
                
            }
            if(!Monthchecked.contains(currMonth)){
                Monthchecked.add(currMonth);
                oppObj.month = opplst[i].CreatedDate;
                oppObj.newOpptys = monthAndNewCountMap.get(currMonth);
                oppObj.wonOpptys = monthAndWonCountMap.get(currMonth);
                oppObj.monthlyWinRate = monthAndMonthlyWinRate.get(currMonth);
                if(currMonth == 1){
                    oppObj.threeMonthWinRate = 0;
                    Decimal currMonthWon = 0.0;
                    Decimal currMonthWon1 = 0.0;
                    Decimal currMonthWon2 = 0.0;
                   
                    if(monthAndWonCountMap.containskey(currMonth)){
                        currMonthWon = monthAndWonCountMap.get(currMonth);
                    }
                    if(monthAndWonCountMap2020.containskey(11)){
                        currMonthWon1 = monthAndWonCountMap2020.get(11);
                    }
                    if(monthAndWonCountMap2020.containskey(12)){
                        currMonthWon2 = monthAndWonCountMap2020.get(12);
                    }
                  
                    oppObj.threeMonthWinRate = (( (currMonthWon+ currMonthWon1+currMonthWon2) / (monthAndNewCountMap.get(currMonth)+ monthAndNewCountMap2020.get(11)+monthAndNewCountMap2020.get(12)))*100).setscale(2);    
                    datatoPass.add(new Data('Jan', monthAndMonthlyWinRate.get(currMonth), oppObj.threeMonthWinRate));
                }
                 if(currMonth == 2){
                  //   oppObj.threeMonthWinRate = 0;
                    Decimal currMonthWon = 0.0;
                    Decimal currMonthWon1 = 0.0;
                    Decimal currMonthWon2 = 0.0;
                   
                    if(monthAndWonCountMap.containskey(currMonth)){
                        currMonthWon = monthAndWonCountMap.get(currMonth);
                    }
                    if(monthAndWonCountMap.containskey(currMonth-1)){
                        currMonthWon1 = monthAndWonCountMap.get(currMonth-1);
                    }
                    if(monthAndWonCountMap2020.containskey(12)){
                        currMonthWon2 = monthAndWonCountMap2020.get(12);
                    }
                     oppObj.threeMonthWinRate = (( (currMonthWon+ currMonthWon1+currMonthWon2) / (monthAndNewCountMap.get(currMonth)+ monthAndNewCountMap.get(currMonth-1)+monthAndNewCountMap2020.get(12)))*100).setscale(2);    
                     datatoPass.add(new Data('Feb', monthAndMonthlyWinRate.get(currMonth), oppObj.threeMonthWinRate));
                }
               // oppObj.threeMonthWinRate = null;
                if(currMonth >= 3){
                    Decimal currMonthWon = 0.0;
                    Decimal currMonthWon1 = 0.0;
                    Decimal currMonthWon2 = 0.0;  
                    if(monthAndWonCountMap.containskey(currMonth)){
                        currMonthWon = monthAndWonCountMap.get(currMonth);
                    }
                    if(monthAndWonCountMap.containskey(currMonth-1)){
                        currMonthWon1 = monthAndWonCountMap.get(currMonth-1);
                    }
                    if(monthAndWonCountMap.containskey(currMonth-2)){
                        currMonthWon2 = monthAndWonCountMap.get(currMonth-2);
                    }
                    
                    
                    oppObj.threeMonthWinRate = (( (currMonthWon+ currMonthWon1+currMonthWon2) / (monthAndNewCountMap.get(currMonth)+ monthAndNewCountMap.get(currMonth-1)+monthAndNewCountMap.get(currMonth-2)))*100).setscale(2);    
                    
                    datatoPass.add(new Data(opplst[i].CreatedDate.format('MMM'), monthAndMonthlyWinRate.get(currMonth), oppObj.threeMonthWinRate));
                } 
                OpplstN.add(oppObj);
            }
        }
        OpplstToPass = OpplstN;
        if(datatoPass.size() == 1){
         datatoPass.add(new Data('Feb', 0, 0));
        }
        data = datatoPass;
    }
    
    public class OppLstWrapper {
        @AuraEnabled public DateTime month {get;set;}
        @AuraEnabled public Integer newOpptys {get;set;}
        @AuraEnabled public Integer wonOpptys {get;set;}
        @AuraEnabled public Decimal monthlyWinRate {get;set;}
        @AuraEnabled public Decimal threeMonthWinRate {get;set;}
        
    }
    

       

      

   

   // Wrapper class

   public class Data {

       public String name { get; set; }

       public Decimal data1 { get; set; }

       public Decimal data2 { get; set; }


       public Data(String name, Decimal data1, Decimal data2) {

           this.name = name;

           this.data1 = data1;

           this.data2 = data2;

          

       }
}
}