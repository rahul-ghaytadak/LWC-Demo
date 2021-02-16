({
    doInit : function(cmp, event, helper) {
        var spinnerMain =  cmp.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
        
        var action = cmp.get("c.getReportSchedulars");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                cmp.set('v.schedReports', response.getReturnValue());
                console.log('Rules=> ' + JSON.stringify(response.getReturnValue()));
            }
        });
        $A.enqueueAction(action);
        $A.util.addClass(spinnerMain, "slds-hide");
        
    },  
    schedReport:function(cmp, event, helper) {
        
        var checkedvalue = event.getSource().get("v.checked");
        console.log('checked Value - >'+checkedvalue);
        if(checkedvalue == false){
        	      var spinnerMain =  cmp.find("Spinner");
            $A.util.removeClass(spinnerMain, "slds-hide");
            var action = cmp.get("c.toggleOff2");
            action.setParams({
                'reportName': event.getSource().get("v.name")
            });
            var toastEvent = $A.get("e.force:showToast");
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state=> ' + state);
                if (state === "SUCCESS"){
                    toastEvent.setParams({
                        "type" : "success",
                        "message": "Report Schedule turned off!",
                        "title": "Success!",
                    });
                    toastEvent.fire();
                }
                else{
                    toastEvent.setParams({
                        "type" : "error",
                        "title": "Error!",
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action); 
            $A.util.addClass(spinnerMain, "slds-hide");
            
        }
        else{
         var spinnerMain =  cmp.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
        var schedReports = cmp.get("v.schedReports");
        var index = event.getSource().get("v.value");
        var action = cmp.get("c.scheduleReport");
        action.setParams({
            'RS' : schedReports[index].RS,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS"){
                toastEvent.setParams({
                        "type" : "success",
                        "message": "Report has been Scheduled!",
                        "title": "Success!",
                    });
                    toastEvent.fire();

            }
            else{
                  toastEvent.setParams({
                        "type" : "error",
                        "message": "Report might be already Scheduled!",
                        "title": "Error!",
                    });
                    toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        $A.util.addClass(spinnerMain, "slds-hide");
        }
    },
    
    RunNow:function(cmp, event, helper) {
         var spinnerMain =  cmp.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
        var schedReports = cmp.get("v.schedReports");
        var index = event.getSource().get("v.value");
        var action = cmp.get("c.runNowReport");
        action.setParams({
            'report' : schedReports[index].RS,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS"){
                toastEvent.setParams({
                        "type" : "success",
                        "message": "Report run successful!",
                    });
                    toastEvent.fire();

            }
            else{
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.error(message);
                toastEvent.setParams({
                    "type" : "error",
                    "message": "Error Occured! " + message,
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    
    addRow: function(cmp, event, helper) {
        var schedReports = cmp.get("v.schedReports");
        var newRule = cmp.get("v.schedRulesRecord");
        var newNameCount = cmp.get("v.schedReportRecord").length+1;
        schedReports.push({'RS':newRule, 'editRow': true});
        console.log('New schedRules ' + JSON.stringify(cmp.get("v.schedReports")));
        cmp.set("v.schedReports", schedReports);
    },
     editRow: function(component, event, helper) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
        var items = component.get("v.schedReports"), index = event.getSource().get("v.value");
        items[index].editRow = !items[index].editRow;
         if(items[index].RS.Name === '' || items[index].RS.Name == undefined)
             items.splice(index,1);
        component.set("v.schedReports", items);
        $A.util.addClass(spinnerMain, "slds-hide");
    },
    deleteRow: function(component, event, helper) {
        var r = confirm("Are you sure you want to delete this Report Schedule?");
        if (r == true) {
        var spinnerMain =  component.find("Spinner");
		$A.util.removeClass(spinnerMain, "slds-hide");
            var items = component.get("v.schedReports"), index = event.getSource().get("v.value");
            var action = component.get("c.deleteReportSched");
            action.setParams({
                'deletedReport': items[index].RS
            });
            var toastEvent = $A.get("e.force:showToast");
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state=> ' + state);
                if (state === "SUCCESS"){
                    component.set('v.schedReports', response.getReturnValue());
                    toastEvent.setParams({
                        "type" : "success",
                        "message": "Schedule has been Deleted!",
                        "title": "Success!",
                    });
                    toastEvent.fire();
                }
                else{
                    toastEvent.setParams({
                        "type" : "error",
                        "message" : JOSN.stringify(response.getError()),
                        "title": "Error!",
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);  
        } else {
            
        }
		$A.util.addClass(spinnerMain, "slds-hide");
    },
    saveReport: function(component, event, helper) {
        var spinnerMain =  component.find("Spinner");
		$A.util.removeClass(spinnerMain, "slds-hide");
            var items = component.get("v.schedReports"), index = event.getSource().get("v.value");
            var action = component.get("c.updateReport");
            action.setParams({
                'updatedReport': items[index].RS
            });
            var toastEvent = $A.get("e.force:showToast");
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state=> ' + state);
                if (state === "SUCCESS"){
                    component.set('v.schedReports', response.getReturnValue());
                    toastEvent.setParams({
                        "type" : "success",
                        "message": "Row has been saved!",
                        "title": "Success!",
                    });
                    toastEvent.fire();
                }
                else{
                    toastEvent.setParams({
                        "type" : "error",
                        "title": "Error!",
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);  
		$A.util.addClass(spinnerMain, "slds-hide");
    },
    
    selectFrequency: function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        var frequency = event.getSource().get("v.value");
        if(frequency == 'Weekly'){
            component.set("v.showDayofWeek");
        }
    },
    
    getToggleButtonValue:function(cmp,event,helper){
        
       var reportName = event.getSource().get("v.value");
       var unchecked = event.getSource().get("v.checked"); 
        console.log('Name->'+reportName);
        console.log('unchecked'+unchecked);
        if(unchecked == false){
            var spinnerMain =  cmp.find("Spinner");
            $A.util.removeClass(spinnerMain, "slds-hide");
            var action = cmp.get("c.toggleOff");
            action.setParams({
                'reportName': reportName
            });
            var toastEvent = $A.get("e.force:showToast");
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state=> ' + state);
                if (state === "SUCCESS"){
                    toastEvent.setParams({
                        "type" : "success",
                        "message": "Report Schedule parameters reset done!",
                        "title": "Reset Successful!",
                    });
                    toastEvent.fire();
                }
                else{
                    toastEvent.setParams({
                        "type" : "error",
                        "title": "Error!",
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);    
            $A.util.addClass(spinnerMain, "slds-hide");
            
        }
   },
})