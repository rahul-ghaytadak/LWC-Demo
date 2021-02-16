({
    doInit : function(cmp, event, helper) {
        var spinnerMain =  cmp.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");

            var action = cmp.get("c.getCcheckId");
            action.setParams({
                "prId" : cmp.get("v.recordId")
            })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    cmp.set("v.CCRecID", response.getReturnValue());
                }
            });
            $A.enqueueAction(action);

            helper.getPremiumsHelper(cmp, event);

        $A.util.addClass(spinnerMain, "slds-hide");
        
    },  
})