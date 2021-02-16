({
    FetchData : function (component,helper,jsonstr){
        var fname = component.get("v.fileName");
        var recId = component.get("v.recordId");
        var action = component.get("c.insertData");
        action.setParams({
            "strfromlex" : jsonstr,
            "FileName"  : fname
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var rtnValue = response.getReturnValue();
                if($A.util.isEmpty(rtnValue)){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Please check if you are importing valid csv.',
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
                        key: 'info_alt',
                        type: 'success',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                    component.set('v.programCodes', rtnValue);
                    helper.buildData(component, helper);
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
                        message:'There were failures while uploading file.',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'sticky'
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
        
    },
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.totalPages", Math.ceil( component.get("v.programCodes").length/component.get("v.pageSize")));
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.programCodes");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.PaginationList", data);
        
        helper.generatePageList(component, pageNumber);
    },
    
    /*
     * this function generate page list
     * */
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
        component.set('v.showSpinner', false);
    },
})