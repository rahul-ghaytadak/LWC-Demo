/***************************************************************************************************************************
* Name:        Account_File_UploaderHelper
* Description: Helper for Account_File_Uploader Component 
* 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-10-14       Aress Dev               Pass the selected file data to the Apex class and returns the response. 
****************************************************************************************************************************/

({
    FetchData : function (component,jsonstr){
        var fname = component.get("v.fileName");
        var recId = component.get("v.recordId");
        var action = component.get("c.insertData");
        action.setParams({
            "strfromlex" : jsonstr,
            "recordId"  : recId,
            "FileName"  : fname
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                
                var rtnValue = response.getReturnValue();
                
                if(rtnValue.length >0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: rtnValue,
                        duration:'5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }//If there is no error in csv file simply show success message
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'File Uploaded Successfully.',
                        duration:'5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
                $A.get('e.force:refreshView').fire();
                
                component.set('v.showSpinner', false);
            }
            else if (state === "ERROR") {
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
                    
                    component.set('v.showSpinner', false);
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