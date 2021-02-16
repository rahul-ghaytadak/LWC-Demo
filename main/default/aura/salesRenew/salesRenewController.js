({
	doInit : function(component, event, helper) {
        
        var action = component.get("c.getUAs");
        action.setParams({  
            'recordId' : component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('selectedContacts-->'+JSON.stringify(response.getReturnValue()));
                component.set("v.selectedContacts",response.getReturnValue());
                component.set("v.brokerId",response.getReturnValue()[0].broker.Id);
                component.set("v.CustomerId",response.getReturnValue()[0].CustomerId);
                component.set("v.productId",response.getReturnValue()[0].productId);
                component.set("v.State",response.getReturnValue()[0].State);
                component.set("v.selectedBrokerContact",response.getReturnValue()[0].selectedCon);
                component.set("v.PricingListToPass",response.getReturnValue()[0].prToPass);
                component.set("v.BrokerMargin",response.getReturnValue()[0].selectedContract.Opportunity__r.Broker_Margin_per_unit__c);
                component.set("v.showScreen",true);
            }
        });
        $A.enqueueAction(action); 
		
	}
})