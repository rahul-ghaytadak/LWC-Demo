({
    doInit: function(component, event, helper){
        if(component.get("v.billingAccountNumber") != null || component.get("v.billingAccountNumber") != undefined){
            $A.util.removeClass(component.find("Spinner"), "slds-hide");
            helper.getLedgerSummaryHelper(component, event, helper,component.get("v.billingAccountNumber"));
        }
    },
    refreshData:function(component, event, helper) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        if(component.get("v.billingAccountNumber") != null || component.get("v.billingAccountNumber") != undefined)
            helper.getLedgerSummaryHelper(component, event, helper, component.get("v.billingAccountNumber"));
        else
            helper.getLedgerSummaryHelper(component, event, helper, component.get("v.BANUA"));

        },
    turnOffSpinner: function(component, event, helper) {
        component.set("v.spinner", false);
    },
    toggle: function(component, event, helper) {
        var items = component.get("v.ledgerSummary"), index = event.getSource().get("v.value");
        items.model[index].expanded = !items.model[index].expanded;
        component.set("v.ledgerSummary", items);
        var cmpTarget = component.find('maintable');
        var expanded = false ;
    },
    invoiceToggle: function(component, event, helper) {
        var items = component.get("v.ledgerSummary").invoices, index = event.getSource().get("v.value");
        items[index].invoiceExpanded = !items[index].invoiceExpanded;
        component.set("v.ledgerSummary.invoices", items);
        var cmpTarget = component.find('innerTable');
        var expanded = false ;
    },
    invoiceUAToggle: function(component, event, helper) {
        debugger;
        var items = component.get("v.ledgerSummary").invoices;
        var index = event.getSource().get("v.value");
        var invoiceNumber = event.getSource().get("v.name");
        items[invoiceNumber].invoiceUtilityAccounts[index].UAExpanded = !items[invoiceNumber].invoiceUtilityAccounts[index].UAExpanded;
        component.set("v.ledgerSummary.invoices", items);
    },
    toggleExpandCollapse: function(component, event, helper) {
        debugger;
        var arTypes = component.get("v.ledgerSummary");
        var expandAll = component.get("v.expandedAll");
        if(expandAll)
            expandAll = false;
        else
            expandAll = true;
        for(var i=0;i<arTypes.model.length;i++){
            arTypes.model[i].expanded = expandAll;
        }
        component.set("v.ledgerSummary", arTypes);
        
        var items = component.get("v.ledgerSummary").invoices;
        for(var i=0;i<items.length;i++){
            for(var j=0; j<items[i].invoiceUtilityAccounts.length; j++)
                items[i].invoiceUtilityAccounts[j].UAExpanded = expandAll;
        }
        component.set("v.ledgerSummary.invoices", items);
        component.set("v.expandedAll",expandAll);
       
    },
})