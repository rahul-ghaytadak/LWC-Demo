public with sharing class googleAddressAutofill {
    
     /**
    * @description : Auto suggestion Web Service 
    * @param : input: SearchAddress , types: Results Types , langug : language for getting the      results
    * @return : string
    **/  
    @AuraEnabled
    public static string getSuggestions(String input) {
       String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
            + 'input=' + EncodingUtil.urlEncode(input, 'UTF-8')
            + getKey();   
      
        String response = getResponse(url); 
        system.debug('Response suggestions***'+response);
        return response;
    }
    
     /**
    * @description : Place Details Web Service 
    * @param : PlaceId: Unique Place Id , langug : language for getting the results
    * @return : string
    **/ 
    @AuraEnabled
    public static string getPlaceDetails(String placeId) {
        String url = 'https://maps.googleapis.com/maps/api/place/details/json?'
            + 'placeid=' + EncodingUtil.urlEncode(placeId, 'UTF-8')
            + getKey(); 
        String response = getResponse(url);
        system.debug('Response places****'+response);
        return response;
    }
    
      /**
    * @description : Common Utility method for making call out
    * @param : String
    * @return : string
    **/
    
    public static string getResponse(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req); 
        String responseBody = res.getBody(); 
        system.debug('responseBody---'+responseBody);
        return responseBody; 
    }
    
     /**
    * @description : To get the google Api key from custom label
    * @param : 
    * @return : string
    **/
    public static string getKey(){
        /*Enter your API key here*/
        string key = 'AIzaSyAECo89n914b6k38aU4UZU0z6v9PqksuYw';
        string output = '&key=' + key;   
        return output;
    }
    
    @AuraEnabled
    public static string getAddress(String dealId ,String street, String city , String state, String country,string zip){
    	
    	Opportunity opp = new Opportunity();
    	warpper wrap = new warpper();
    	if(dealId != null){
    		try{
    			/*opp = [select id,Property_State__c,Property_Country__c,Property_City__c,Property_Street__c,Property_Zip_Postal_Code__c from Opportunity where id=: dealId];
    			opp.Property_State__c = state;
    			opp.Property_Country__c = country;
    			opp.Property_City__c = city;
                opp.Property_Zip_Postal_Code__c = zip;
                opp.Property_Street__c = street;
    			update opp;*/
    			system.debug('*****Successfully updated the Deal');
    			
                wrap.isSuccess = true;
    		}catch(Exception e){
                wrap.isSuccess = false;
                wrap.errormessage = e.getMessage().substringAfter(',');
    			system.debug('Exception**'+e.getLinenumber());
    		}
    	}
    	return JSON.serialize(wrap);
    } 
    
    @AuraEnabled
    public static boolean getOppStage(String oppId){
    	List<Opportunity> opplist = new List<Opportunity>();
    	Boolean notstage ; 
    	if(oppId != null){
    		opplist = [select id , StageName from Opportunity where id=: oppId];
    		if(opplist[0].StageName == '06 - Mortgage Booked'){
    			notstage = true;
    		}else{
    			notstage = false;
    		}
    	}
    	return notstage;
    }
    
    public class warpper{
        @AuraEnabled
        public boolean isSuccess{get;set;}
        
        @AuraEnabled
        public String errormessage{get;set;}
    }
}