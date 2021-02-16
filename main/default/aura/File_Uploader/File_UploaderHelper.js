/***************************************************************************************************************************
* Name:        File_UploaderHelper
* Description: Helper for File_Uploader Component 
* 
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-11-04       Aress Dev               Pass the selected file data to the Apex class and returns the response. 
****************************************************************************************************************************/



({
    FetchData : function (component,jsonstr){
        var fname = component.get("v.fileName");
        var recId = component.get("v.recordId");
        var action = component.get("c.insertData");
        //var checkCmp = component.find("tglbtn").get("v.checked");
        action.setParams({
            "strfromlex" : jsonstr,
            "recordId"  : recId,
            "FileName"  : fname,
            "ToggleValue":component.get("v.chkboxvalue")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                
                var rtnValue = response.getReturnValue();
               
                 if(rtnValue.length !=''){
                    var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                    title : 'Error',
                    message: rtnValue,
                    duration:'5000',
                    key: 'info_alt',
                    type: 'error'
                });
                toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }//If there is no error in csv file simply show success message
                else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'File has been successfully added to batch for processing',
                    message: 'Please wait for notification of batch completion.',
                    duration:'5000',
                    key: 'info_alt',
                    type: 'success'
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
                    });
                    toastEvent.fire();
                    
                    component.set('v.showSpinner', false);
                    $A.get('e.force:refreshView').fire();
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