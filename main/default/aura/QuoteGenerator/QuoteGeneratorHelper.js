({
	updateExcludedUAOs : function(component,event,helper, UAOList, incUAOList){
        var action = component.get("c.updateExcludedUAO");
        action.setParams({  
            'UAOList' : UAOList,
            'incUAOList' : incUAOList,
            'oppId' : component.get("v.recordId"),
            'ChangedPriceId' : component.get("v.selectedPriceId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
            }
        });
        $A.enqueueAction(action);  
    },
})