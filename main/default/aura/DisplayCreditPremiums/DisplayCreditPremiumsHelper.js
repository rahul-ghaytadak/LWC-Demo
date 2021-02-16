({
    getPremiumsHelper : function(cmp, event) {
        var action = cmp.get("c.getPremiums1");
        action.setParams({
            "prId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var utilityPremiums = [];
                var resp = response.getReturnValue();

                cmp.set("v.utilityPremiums",  response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})