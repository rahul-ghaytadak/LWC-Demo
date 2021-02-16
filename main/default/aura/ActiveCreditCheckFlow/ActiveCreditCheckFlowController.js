({
    doInit : function(cmp, event, helper) {
        var spinnerMain =  cmp.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
        if(cmp.get("v.sObjectName") == 'Opportunity'){
            var action = cmp.get("c.getCcId");
            action.setParams({
                "oppId" : cmp.get("v.recordId")
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    cmp.set("v.CCRecID", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        else{
            helper.getPremiumsHelper(cmp, event);
        }
        $A.util.addClass(spinnerMain, "slds-hide");
        
    },  
})