({
    FetchData : function (component,jsonstr){
        var fname = component.get("v.fileName");
        var recId = component.get("v.recordId");
         var AccRecId = component.get("v.AccRecId");
        var action = component.get("c.insertData");
        action.setParams({
            "strfromlex" : jsonstr,
            "recordId"  : recId,
            "FileName"  : fname,
            "AccRecId" :AccRecId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                
                var rtnValue = response.getReturnValue();
                //alert(JSON.stringify(rtnValue));
                component.set("v.UA_DisplayList",rtnValue);
                component.set("v.disabledDisplayExecute",false);
                component.set("v.UAOTodelete",rtnValue.UAOTodelete);
                component.set("v.UARelatedUAOWillBeInseted",rtnValue.UARelatedUAOWillBeInseted);
                component.set("v.UtilityWillBeInserted",rtnValue.UtilityWillBeInserted);
                component.set("v.displayExecute",true);
				component.set("v.displayMessage" , false);
                if(rtnValue.ResponseForUA.length >0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: rtnValue.ResponseForUA,
                        duration:'5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    component.set('v.showSpinner', false);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'File Uploaded Successfully.',
                        duration:'5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
					
                    component.set('v.screen2', true);
                //$A.get('e.force:refreshView').fire();
                component.set('v.showSpinner', false);
                
                }
            }
            else if (state === "ERROR") {
                alert(JSON.stringify(response.getError()));
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'There were failures while file upload, please check related records.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    component.set('v.screen2', false);
                    component.set('v.screen1', true);
                    component.set('v.showSpinner', false);
                    component.set("v.displayMessage" , false);
                    var json = JSON.stringify(errors); 
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action);    
    }
})