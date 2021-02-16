({
    getLedgerSummaryHelper : function(component, event, helper, EOS_BAN) {
        var action1 = component.get("c.getLedgerSummary");
        action1.setParams({  
            'EOS_BillingAccountNumber' : EOS_BAN
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue().code != '400'){
                var response1 = response.getReturnValue();
                component.set("v.ledgerSummary", response.getReturnValue()); 
                var invoiceUAs = [];
                var UANumbers = [];
                for(var i=0; i<response1.invoices.length;i++){
                    for(var j=0; j<response1.invoices[i].invoiceUtilityAccounts.length;j++){ 
                        if(!UANumbers.includes(response1.invoices[i].invoiceUtilityAccounts[j].utilityAccountNumber)){
                            invoiceUAs.push(response1.invoices[i].invoiceUtilityAccounts[j]);
                            UANumbers.push(response1.invoices[i].invoiceUtilityAccounts[j].utilityAccountNumber);
                        }
                    }
                }
                console.log('UANumbers length => '+ UANumbers);
                component.set("v.invoiceUAs", invoiceUAs);
                console.log('invoiceUAs length => '+ invoiceUAs.length);
                component.set("v.spinner", false);
            }
            else{
                var em =  response.getReturnValue();
                component.set("v.errorMessage",em.message);     
                component.set("v.spinner", false);
            }
            component.set("v.showApiData", true);
        });
        $A.enqueueAction(action1);  
        window.setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(component.find("Spinner"), "slds-hide");
            }), 1000
        );
    },
})