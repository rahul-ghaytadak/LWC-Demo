({
    getQLIs : function(component, event, helper) {
        component.set("v.spinner", true);
        var quoteId = component.find("selectQuote").get("v.value");
        var action = component.get("c.getQLIs");
        action.setParams({  
            'quoteId' : quoteId,
            'isUpdate': true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var quoteLineItems = response.getReturnValue();
                for(var i=0; i< quoteLineItems.length; i++){
                    $A.get('e.force:refreshView').fire();
                    quoteLineItems[i].objQLI.Broker_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Broker_Margin_per_unit__c).toFixed(5);
                    quoteLineItems[i].objQLI.Sales_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Sales_Margin_per_unit__c).toFixed(5);
                }
                component.set("v.quoteLineItems", quoteLineItems); 
                component.set("v.spinner", false);
            }
            else{
                alert(JSON.stringify(response.getError()));
                component.set('v.spinner', false);
            }
            
        });
        $A.enqueueAction(action);
    },
    updateContactRoleHelper:function (component, selectedContactId, updatedContactRole, contactRoleName){
        var responseValue;
        var action = component.get("c.updateContactRoles");
        action.setParams({  
            'contactId' : selectedContactId,
            'contactRole' : updatedContactRole,
            'oppId': component.get('v.recordId'),
            'role': contactRoleName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                if(contactRoleName == 'Decision Maker'){
                    component.set("v.customerContactRole", response.getReturnValue());
                    component.get("v.selectedCustomerContact", null);
                    component.set('v.editDM', false);
                }
                else{
                    component.set("v.brokerContactRole", response.getReturnValue());
                    component.get("v.selectedBrokerContact", null);
                    component.set('v.editBroker', false);
                }
                
            }
            $A.util.addClass(component.find("Spinner"), "slds-hide");
            $A.util.removeClass(component.find("Spinner"), "slds-show");
        });
        $A.enqueueAction(action);  
    }
})