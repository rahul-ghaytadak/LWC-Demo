({
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var ext;
        component.set('v.showSpinner', true);
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            ext = fileName.substring(fileName.length-3,fileName.length);
        }
        component.set("v.fileName", fileName);
        if(ext=='csv'){
            var fileInput = component.find("file").get("v.files");
            var file = fileInput[0];
            if (file) {
                var reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                reader.onload = function (evt) {
                    var csv = evt.target.result;
                    window.setTimeout($A.getCallback(function(){
                        helper.FetchData(component,csv);
                    }), 10);
                }
                reader.onerror = function (evt) {
                }
            }
        }
        else {
            component.set("v.errorMessage",'Kindly select a CSV file.');
            component.set('v.showSpinner', false);
            component.set("v.displayMessage" , false);
            
        }
    },
    
    showToolTip : function(component, event, helper) {
        var cmpTarget = component.find('ModalboxUA');
        var cmpBack = component.find('ModalbackdropUA');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        // $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
        
    },
    
    HideToolTip : function(component, event, helper){
        var cmpTarget = component.find('ModalboxUA');
        var cmpBack = component.find('ModalbackdropUA');
        //  $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    CreateUAWithUAO : function(component, event, helper){
        //alert(JSON.stringify(component.get("v.UtilityWillBeUpdated")));
        component.set('v.showSpinnerOnProceed', true);
        var UAOTodelete = component.get("v.UAOTodelete");
        var UARelatedUAOWillBeInseted = component.get("v.UARelatedUAOWillBeInseted");
        var UtilityWillBeInserted = component.get("v.UtilityWillBeInserted");
        var recId = component.get("v.AccRecId");
        var OppRecId = component.get("v.recordId");
        var action = component.get("c.insertUAandUAO");
        action.setParams({
            "UAOTodelete" : UAOTodelete,
            "UARelatedUAOWillBeInseted"  : UARelatedUAOWillBeInseted,
            "UtilityWillBeInserted"  : UtilityWillBeInserted,
            "recordId" : recId,
            "OppRecId" : OppRecId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var rtnValue = response.getReturnValue();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Data operation executed Successfully.',
                    duration:'5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                component.set('v.showSpinnerOnProceed', false);
                component.set('v.fileName', '');   
                component.set('v.clickExecute', false);
                component.set('v.screen2', false);
                component.set("v.displayMessage" , true);
                
               /* var cmpTarget = component.find('Modalbox');
                var cmpBack = component.find('Modalbackdrop');
                $A.util.removeClass(cmpBack,'slds-backdrop--open');
                $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); */
                
            }
            else if (state === "ERROR") {
                component.set('v.showSpinnerOnProceed', false);
                component.set("v.clickExecute" , false);
                component.set("v.displayExecute" , true);
                //alert(JSON.stringify(response.getError()));
                var errors = response.getError();
                if (errors) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'There were failures while data insert, please check related records.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    
                    component.set('v.showSpinner', false);
                    component.set('v.clickExecute', false);
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
    },
    OpenWarning : function(component, event, helper){
        component.set("v.clickExecute" , true);
        component.set("v.disabledDisplayExecute" , true);
        component.set("v.displayExecute" , false);
        component.set("v.displayMessage" , false);
        
    },
    HideExecutPopup: function(component, event, helper){
        component.set("v.clickExecute" , false);
        component.set("v.displayExecute" , true);
        component.set("v.displayMessage" , false);
        component.set("v.disabledDisplayExecute" , false);
    },
    applyCSS: function(component, event) {
        event.target.style.color = 'blue';
    },
    previous : function(component, event) {
        component.set('v.screen2', false);
        component.set("v.displayMessage" , false);
    },
    
    showToolTipForNoStateMatch: function(component, event, helper) {
        var cmpTarget = component.find('ModalNoStatematchUA');
        var cmpBack = component.find('ModalbackdropUA');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        
    },
    HideToolTipNoStateMatch : function(component, event, helper){
        var cmpTarget = component.find('ModalNoStatematchUA');
        var cmpBack = component.find('ModalbackdropUA');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
})