({
    getLedgerSummaryHelper : function(component, event, helper, BAN) {
        var action = component.get("c.getLedgerSummary");
        action.setParams({  
            'EOS_BillingAccountNumber' : BAN
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.spinner", false);
            if (state === "SUCCESS" && response.getReturnValue().code != '400'){
                var response1 = response.getReturnValue();
                component.set("v.ledgerSummary", response.getReturnValue()); 
                component.set("v.billingAccountNumber",response1.model[0].billingAccountNumber);
                component.set("v.invoiceUAs", invoiceUAs);
            }
            else{
                //component.set("v.ledgerSummary", null);
                component.set("v.spinner", false);
                var em =  response.getReturnValue();
                component.set("v.errorMessage",em.message);
            }
            
        });
        $A.enqueueAction(action);  
        window.setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(component.find("Spinner"), "slds-hide");
                component.set("v.spinner", false);        
            }), 1000
        );
        
    }
})