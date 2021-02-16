({
    doInit : function(component, event, helper) {
        component.set("v.spinner", true);
        var brokerId = component.get("v.recordId");
        component.set("v.brId",brokerId);    
        var action = component.get("c.initMethod");
        action.setParams({
            "Accid": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnResponse = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.accRec", returnResponse);
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    nextScreen : function(component, event, helper) {
        component.set("v.spinner", true);
        var accrec = component.get("v.accRec");
        
        var action = component.get("c.makeCallout");
        
        action.setParams({
            "accRec": component.get("v.accRec"),
            "geo":component.get("v.geo"),
            "comment":component.get("v.comment"),
            "txtId":component.get("v.txtId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var returnResponse = response.getReturnValue();
            //alert(JSON.stringify(returnResponse));
            component.set("v.resultList",returnResponse);
            if (state === "SUCCESS") {
                component.set("v.spinner", false);
                var msg = 'No Records found.';
                if(returnResponse.length > 0){
                    msg = 'Record found successfully.';
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": msg
                });
                toastEvent.fire();
            }else if (state === "INCOMPLETE") {
                component.set("v.spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "OFFLINE!",
                    "message": "You are in offline."
                });
                toastEvent.fire();
            }else if (state === "ERROR") {
                component.set("v.spinner", false);
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR!",
                    "type" : "error",
                    "message": "No Records found!"
                });
                toastEvent.fire();
            }else {
                component.set("v.spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "UNKOWN!",
                    "message": "Unknown error."
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);
        
        component.set("v.firstscreen", false);
    },
    
    CreateAccount1 : function(component, event, helper){
        component.set("v.spinner", true);
        console.log('here----');
        var checkvalue = component.find("checkContact");
        var selectedContacts = [];
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedContacts.push(checkvalue.get("v.errors"));
            }
        }
        else{
        for (var i = 0; i < checkvalue.length; i++) {
            if(checkvalue[i].get("v.value") == true){
                    selectedContacts.push(checkvalue[i].get("v.errors"));
            }
            }
        }
        console.log('selectedContacts-->'+selectedContacts);
        var action = component.get("c.CreateAccount");
        action.setParams({
            "AccResult":selectedContacts,
            "accRec": component.get("v.accRec"),
            "Acccid" : component.get("v.brId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Record has been inserted successfully."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    callCancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    checkboxSelect : function(component, event, helper){
        component.set("v.secondscreen",false);
        var index = event.getSource().get("v.text");
        var checkvalue = component.find("checkContact");
        console.log('index-->'+index);
        console.log('chek-->'+checkvalue[index].get("v.value"));
        
        if(Array.isArray(checkvalue)){
             for (var i = 0; i < checkvalue.length; i++) {
            if(checkvalue[i].get("v.value") == true){
                    checkvalue[i].set("v.value",false);
            }
            }
        }
        checkvalue[index].set("v.value",true);
    }
})