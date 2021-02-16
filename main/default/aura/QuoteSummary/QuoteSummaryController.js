({
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuoteSummaryData");
        action.setParams({ 'recordId' : component.get("v.recordId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('7-->'+JSON.stringify(response.getReturnValue()));  
                component.set("v.recordResponse", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})