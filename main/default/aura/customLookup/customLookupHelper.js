({
	searchHelper : function(component,event,getInputkeyWord,isInit) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'accId' : component.get("v.accId"),
            'isInit' : isInit,
            'BrokerType':component.get("v.BrokerType")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    getContact : function(component,event, helper){
          $A.util.addClass(component.find("mySpinner"), "slds-show");
        var action = component.get("c.getCreatedContact");
        console.log('Accid->'+component.get("v.accId"));
        action.setParams({
            'accId' : component.get("v.accId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                console.log(JSON.stringify(response.getReturnValue()));
              //  component.set("v.selectedRecord",response.getReturnValue() );
                // get the selected record from list  
                var getSelectRecord = response.getReturnValue();
                // call the event   
                var compEvent = component.getEvent("oSelectedRecordEvent");
                // set the Selected sObject Record to the event attribute.  
                compEvent.setParams({"recordByEvent" : getSelectRecord });  
                // fire the event  
                compEvent.fire();
                $A.util.removeClass(component.find("mySpinner"), "slds-show");
            }
            
        });
        $A.enqueueAction(action);
    }
})