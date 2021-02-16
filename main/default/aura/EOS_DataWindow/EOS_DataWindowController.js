({
    doInit: function(component, event, helper) {
        if(component.get("v.sObjectName") == 'Account'){
            var action = component.get("c.getBilingAccounts");
            action.setParams({  
                'recordId' : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    component.set("v.billingAccounts", response.getReturnValue());        
                    console.log('billingAccounts:  ' + JSON.stringify(response.getReturnValue()));
                    component.set("v.spinner", false);
                }
            });
            $A.enqueueAction(action);  
        }
    },
    doInitUA: function(component, event, helper) {
        component.set("v.spinner", true);
        helper.getLedgerSummaryHelper(component, event, helper, component.get("v.UtilityAccount").EOS_BillingAccountNumber__c);
    },
    handleSectionToggle: function (cmp, event) {
        var openSections = event.getParam('openSections');
        var billingAccounts = cmp.get("v.billingAccounts");
        for(var i=0; i<billingAccounts.length; i++){
            if(openSections.includes(billingAccounts[i].billingAccountNumber))
                billingAccounts[i].isChecked = true;
        }
        cmp.set("v.billingAccounts", billingAccounts);
	    },
    getAPIData: function(component, event, helper) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var billingAccountNumber =  event.getSource().get("v.value");
        console.log('billingAccountNumber:  ' +billingAccountNumber);
        component.set("v.spinner", true);
        helper.getLedgerSummaryHelper(component, event, helper,billingAccountNumber);
    },
    
    
})