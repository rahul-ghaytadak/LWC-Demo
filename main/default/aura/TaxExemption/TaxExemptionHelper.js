({
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.totalPages", Math.ceil( component.get("v.listOfRecords").length/component.get("v.pageSize")));
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.listOfRecords");
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
        component.set('v.spinner', false);
    },
    
    finishHelper: function(component, event, selectedReocrds) {
        var self = this;
        var fileInput = component.find("file").get("v.files");
        if(fileInput != null){
            var file = fileInput[0];
            var objFileReader = new FileReader();
            objFileReader.onload = $A.getCallback(function() {
                var fileContents = objFileReader.result;
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
                
                fileContents = fileContents.substring(dataStart);
                self.uploadInChunk(component, file, fileContents, selectedReocrds);
            });
            
            objFileReader.readAsDataURL(file);
        }
        else
            self.uploadInChunk(component,null, null, selectedReocrds);
        
    },
    validityChecker: function(component) {
        var isValid = false; 
        var items = component.get("v.listOfRecords");
        for(var i=0; i< items.length; i++){
            if(items[i].isChecked){
                if((items[i].newExemptionAmount != "" && items[i].newExemptionAmount != undefined) && (items[i].newValidFrom != "" && items[i].newValidFrom != undefined )){
                    isValid = true;
                }
                else{
                    isValid = false;
                    break;
                }
            }
        }
        component.set("v.hasSelectedItem", isValid);
    },
    uploadInChunk: function(component, file, fileContents, selectedReocrds) {
        console.log('selectedReocrds ' + JSON.stringify(selectedReocrds));
        var action = component.get("c.finishProcess");
        action.setParams({
            "accountId" : component.get("v.recordId"),
            "selectedRows" : selectedReocrds,
            "fileData" : encodeURIComponent(fileContents),
            "fileName" : component.get("v.fileName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Tax Exemptions have been created!",
                    "type": 'success',
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire(); 
            }
            else if (state === "INCOMPLETE"){
                component.set("v.errMsg", 'Error Occured! Details: ' + JSON.stringify(response.getReturnValue()));
            } 
                else if (state === "ERROR"){
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.errMsg", 'Error Occured! Details: ' + errors[0].message);
                            console.log("Error message: " + JSON.stringify(errors));
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "We've hit a snag!",
                                "message": errors[0].message,
                                "type": 'error',
                            });
                            toastEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    }
})