({
    doInit : function(component, event, helper) {
        component.set('v.spinner', true);
        var action = component.get("c.getUATEs");
        action.setParams({
            "accountId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("test " );
                component.set('v.listOfRecords', response.getReturnValue());
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                helper.buildData(component, helper);
            }
        });
        //component.set('v.spinner', false);
        $A.enqueueAction(action); 
    },
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
    },
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.value));
        helper.buildData(component, helper);
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    },
    changePageSize: function(component, event, helper) {
        component.set("v.currentPageNumber", 1);
        helper.buildData(component,helper);
    },
    checkboxSelect: function(component, event, helper) {
        helper.validityChecker(component);
    },
    checkboxSelectAll: function(component, event, helper) {
        var value = event.getSource().get("v.value");
        var items = component.get("v.listOfRecords");
        var hasSelected = false;
        var isValid = false;
        for(var i=0; i< items.length; i++){
            items[i].isChecked = value;
            if(items[i].isChecked){
                if((items[i].newExemptionAmount != "" && items[i].newExemptionAmount != undefined) && (items[i].newValidFrom != "" && items[i].newValidFrom != undefined )){
                    isValid = true;
                }
                else{
                    isValid = false;
                    items[i].isChecked = false;
                    break;
                }
            }
        }
        component.set("v.hasSelectedItem", isValid);
        component.set("v.listOfRecords", items);
        helper.buildData(component, helper);
    },
    updateValidFromDate: function(component, event, helper) {
        component.find("vfDate").set("v.value", null);
        var value = event.getSource().get("v.value");
        var i = event.getSource().get("v.name");
        var newDate = new Date(value);
        var items = component.get("v.listOfRecords");
        items[i].newValidFrom = value;
        if(items[i].UATE != undefined){
            var temp = new Date(newDate);
            temp.setDate(newDate.getDate()-1);
            var monthNum = temp.getMonth()+1;
            var month = temp.getMonth() < 10 ? '0'+ monthNum : monthNum;
            var date = temp.getDate() < 10 ? '0'+ temp.getDate() : temp.getDate();
            if(items[i].UATE.Valid_To__c == undefined){
                items[i].UATE.Valid_To__c = temp.getFullYear()+'-'+month +'-'+date;
            }
            else{
                var existingDate = new Date(items[i].UATE.Valid_To__c); 
                if(existingDate.getTime() > newDate.getTime()){
                    items[i].UATE.Valid_To__c = temp.getFullYear()+'-'+month +'-'+date;
                }
            }
        }
        helper.validityChecker(component);
        component.set("v.listOfRecords", items);
        helper.buildData(component, helper);
    },
    updateExemptionAmount : function(component, event, helper){
        component.find("eAmount").set("v.value", null);
        helper.validityChecker(component);
    },
    sortByUANumber: function(component, event, helper) {
    var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.listOfRecords");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.UA.Name == b.UA.Name, t2 = a.UA.Name < b.UA.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "UANumber");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.listOfRecords", currentList);
        helper.buildData(component, helper);
    },
    updateAllValidFromDate: function(component, event, helper) {
        var value = event.getSource().get("v.value");
        if(value != null){
            var newDate = new Date(value);
            var items = component.get("v.listOfRecords");
            var isValid = false; 
            for(var i=0; i< items.length; i++){
                items[i].newValidFrom = value;
                if(items[i].UATE != undefined){
                    var temp = new Date(newDate);
                    temp.setDate(newDate.getDate()-1);
                    var monthNum = temp.getMonth()+1;
                    var month = temp.getMonth() < 10 ? '0'+ monthNum : monthNum;
                    var date = temp.getDate() < 10 ? '0'+ temp.getDate() : temp.getDate();
                    if(items[i].UATE.Valid_To__c == undefined){
                        items[i].UATE.Valid_To__c = temp.getFullYear()+'-'+month +'-'+date;
                    }
                    else{
                        var existingDate = new Date(items[i].UATE.Valid_To__c); 
                        if(existingDate.getTime() > newDate.getTime()){
                            items[i].UATE.Valid_To__c = temp.getFullYear()+'-'+month +'-'+date;
                        }
                    }
                }
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
            component.set("v.listOfRecords", items);
            helper.buildData(component, helper);
        }
    },
    updateAllExeAmount: function(component, event, helper) {
        var value = event.getSource().get("v.value");
        var items = component.get("v.listOfRecords");
        var isValid = false; 
        for(var i=0; i< items.length; i++){
            items[i].newExemptionAmount = value;
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
        component.set("v.listOfRecords", items);
        component.set("v.hasSelectedItem", isValid);
        helper.buildData(component, helper);
    },
     handleFilesChange: function(component, event, helper) {
        var fileName = '';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "File Uploaded Successfully!",
                "type": 'success',
            });
            toastEvent.fire();
        }
         component.set("v.fileName", fileName);
    },
    
    handleFinish: function(component, event, helper){
        var selectedItems = [];
        var doc = null;
        var fileName = '';
        var isValid = false;
        var items = component.get("v.listOfRecords");
        for(var i=0; i< items.length; i++){
            if(items[i].isChecked){
                items[i].newExemptionAmount = parseFloat(items[i].newExemptionAmount);
                selectedItems.push(items[i]);
            }
        }
        component.set("v.spinner", true);
        helper.finishHelper(component, event, selectedItems);

    },
     closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
})