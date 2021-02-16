({
	doInit : function(component, event, helper) {
        var action = component.get("c.splitOpptyDetails");
        action.setParams({ 'recordId' : component.get("v.recordId")}); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('10-->'+JSON.stringify(response.getReturnValue()));  
                
                component.set("v.parentOpptyList", response.getReturnValue().parentOppty);
                component.set("v.siblingOpptyList", response.getReturnValue().siblingOpptys);
                component.set("v.childOpptyList", response.getReturnValue().childOpptys);
                component.set("v.showSpinner",false);
            }else{
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    }
})