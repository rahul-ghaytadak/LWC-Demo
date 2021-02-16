({
    getPremiumsHelper : function(cmp, event) {
        var action = cmp.get("c.getPremiums");
        action.setParams({
            "ccId" : cmp.get("v.CCRecID")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var utilityPremiums = [];
                var resp = response.getReturnValue();
                for ( var key in resp ) {
                    utilityPremiums.push({value:resp[key], key:key});
                }
                cmp.set("v.utilityPremiums", utilityPremiums);
                console.log('utilityPremiums => ' + JSON.stringify(utilityPremiums));
            }
        });
        $A.enqueueAction(action);
    }
})