({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
    },
    handlePrevious: function (component, event, helper) {
        helper.doInitHelper(component, event, helper);
        $A.get('e.force:refreshView').fire();
        component.set("v.showResults", false);
    },
    gotoRelatedList : function (component, event, helper) {
        var listOfAllPS = component.get("v.listOfAllPS");
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Utility_Account_Enrollments__r",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
    },
    editRSN: function (component, event, helper) {
        console.log('pageSize-',component.get("v.pageSize"));
        console.log('currentPageNumber-',component.get("v.currentPageNumber"));
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editRSN = !UAE[index].editRSN;
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    editPC: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editPC = !UAE[index].editPC;
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    saveRSN: function (component, event, helper) {
        var UAE1 = component.get("v.utilityAccountEnrollments");
        console.log('-->'+JSON.stringify(UAE1));
        /*console.log('-->'+JSON.stringify(UAE1));
        console.log('value-->'+component.find("abcc").get("v.value"));
        $A.util.removeClass(component.find("RSNSpinner"), "slds-hide");
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
      
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        console.log('->index'+index);
        var inputId = index+'RSN';
        var changedRSN = document.getElementById(inputId).value;
        var updatedUAE =[];
        var updatedRSN = component.get("v.updatedRSN"); 
        var UAE = component.get("v.utilityAccountEnrollments");
        console.log('-->'+JSON.stringify(UAE));
        UAE[index].editRSN = false;
        UAE[index].objUAE.Rate_Schedule_Name__c = changedRSN;
        updatedUAE.push(UAE[index].objUAE);*/
        var updatedUAE =[];
        for(var i=0;i<UAE1.length;i++){
            UAE1[i].editRSN = false;
            updatedUAE.push(UAE1[i].objUAE);
        }
        var action = component.get("c.saveUAE");
        action.setParams({  
            "objUAE" : updatedUAE
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                if(response.getReturnValue() != 'success')
                    component.set("v.errorMessage", response.getReturnValue());
                else{
                    component.set("v.utilityAccountEnrollments", UAE1);
                }
                helper.buildData(component, helper);
                $A.util.addClass(component.find("RSNSpinner"), "slds-hide");
                
                //SU-613 : Applied it for refresh issue
                component.set("v.ApplyDisable", true);
                helper.doInitHelper(component, event, helper);
            }
        });
        $A.enqueueAction(action); 
        
    },
    editStatus: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editStatus = !UAE[index].editStatus;
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    
    editHoldTransaction: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editHoldTransaction = false;
        component.set("v.changedCheckbox",false);
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    
    editHoldReasonCode: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editHoldReasonCode = !UAE[index].editHoldReasonCode;
        component.set("v.changedCheckbox",false);
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    
    editStartDates:function (component, event, helper){
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        if(UAE[index].editStartDate == true){
            UAE[index].editStartDate =false;
        }
        else{
            UAE[index].editStartDate =true;
        }
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    
    changedCheckbox: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editHoldTransaction = !UAE[index].editHoldTransaction;
        component.set("v.changedCheckbox",false);
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    
    saveStatus: function (component, event, helper) {
        $A.util.removeClass(component.find("RSNSpinner"), "slds-hide");
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var updatedUAE =[];
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editStatus = false;
        UAE[index].editPC = false;
        UAE[index].editTEC = false;
        UAE[index].editHoldReasonCode = false;
        UAE[index].editHoldTransaction = false;
        UAE[index].editEffectiveDate = false;
        UAE[index].editPercentage = false;
        UAE[index].editTEC_Number = false;
        UAE[index].editTax_Exempt = false;
        
        if(UAE[index].objUAE.Hold_Transaction__c){
            UAE[index].invalidDate = false;
        }
        if(UAE[index].objUAE.Hold_Reason_Code__c != null){
            UAE[index].invalidDate = false;
        }
      
        updatedUAE.push(UAE[index].objUAE);
        var action = component.get("c.saveUAE");
        action.setParams({  
            "objUAE" : updatedUAE
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.changedCheckbox",false);
                if(response.getReturnValue() != 'success')
                    component.set("v.errorMessage", response.getReturnValue());
                else{
                    component.set("v.utilityAccountEnrollments", UAE);
                }
                for(var i=0;i<UAE.length;i++){
                    if(UAE[i].objUAE.Hold_Transaction__c == true && UAE[i].objUAE.Start_Date__c != null && UAE[i].objUAE.Hold_Reason_Code__c != null ){
                        component.set("v.StartDateIsValid", true);
                    }
                    else{
                        component.set("v.StartDateIsValid", false);
                        break;
                    }
                }
                helper.buildData(component, helper);
                $A.util.addClass(component.find("RSNSpinner"), "slds-hide");
                
                //SU-613 : Applied it for refresh issue
                component.set("v.ApplyDisable", true);
                helper.doInitHelper(component, event, helper);
            }
        });
        $A.enqueueAction(action); 
        
    },
    
    saveStartdate: function (component, event, helper) {
        $A.util.removeClass(component.find("RSNSpinner"), "slds-hide");
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var updatedUAE =[];
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editStartDate = false;
        if(UAE[index].objUAE.Start_Date__c != null){
            UAE[index].invalidDate = false;
        }
        updatedUAE.push(UAE[index].objUAE);
        var action = component.get("c.saveUAE");
        action.setParams({  
            "objUAE" : updatedUAE
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.changedCheckbox",false);
                if(response.getReturnValue() != 'success')
                    component.set("v.errorMessage", response.getReturnValue());
                else{
                    component.set("v.utilityAccountEnrollments", UAE);
                }
                for(var i=0;i<UAE.length;i++){
                    if(UAE[i].objUAE.Hold_Transaction__c == true && UAE[i].objUAE.Start_Date__c != null && UAE[i].objUAE.Hold_Reason_Code__c != null ){
                        component.set("v.StartDateIsValid", true);
                    }
                    else{
                        component.set("v.StartDateIsValid", false);
                        break;
                    }
                }
                helper.buildData(component, helper);
                $A.util.addClass(component.find("RSNSpinner"), "slds-hide");
                
                //SU-613 : Applied it for refresh issue
                component.set("v.ApplyDisable", true);
                helper.doInitHelper(component, event, helper);
            }
        });
        $A.enqueueAction(action); 
        
    },
    
    changeRSN: function (component, event, helper) {
        $A.util.addClass(component.find("RSNSpinner"), "slds-hide");
        component.set("v.openModel", false);
        var changedRSN = component.find("RSN").get("v.value");
        var UAE = component.get("v.utilityAccountEnrollments");
        var updatedUAE =[];
        for(var i=0; i<UAE.length;i++){
            if(UAE[i].isChecked){
                UAE[i].objUAE.Rate_Schedule_Name__c = changedRSN;
                updatedUAE.push(UAE[i].objUAE);
            }
        }
        
        $A.util.removeClass(component.find("RSNSpinner"), "slds-hide");
        $A.util.addClass(component.find("RSNSpinner"), "slds-show");
        var action = component.get("c.saveUAE");
        action.setParams({  
            "objUAE" : updatedUAE
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                if(response.getReturnValue() != 'success')
                    component.set("v.errorMessage", response.getReturnValue());
                else
                    component.set("v.utilityAccountEnrollments", UAE);
                helper.buildData(component, helper);
                $A.util.addClass(component.find("RSNSpinner"), "slds-hide");
                $A.util.removeClass(component.find("RSNSpinner"), "slds-show");
                helper.buildData(component, helper);
            }
        });
        $A.enqueueAction(action); 
    },
    checkboxSelect: function(component, event, helper) {
        var selectedUAE = event.getSource().get("v.name");
        var UAEs = component.get("v.utilityAccountEnrollments");
        if(UAEs[selectedUAE].objUAE.Hold_Transaction__c || UAEs[selectedUAE].objUAE.Hold_Reason_Code__c != null || UAEs[selectedUAE].objUAE.Start_Date__c != null){
            console.log('In false');
            component.set("v.invalidDate", false);
        }
        else{
            component.set("v.invalidDate", true);
            console.log('In true');
        }
        var checker = false;
        for(var i=0; i<UAEs.length;i++){
            if(UAEs[i].isChecked)
                checker = true;
        }
        component.set("v.hasSelectedUAE",checker);
        component.set("v.ApplyDisable", false);
    },
    selectAllCheckbox: function(component, event, helper) {
        component.set("v.ApplyDisable", false);
        var selectedHeaderCheck = event.getSource().get("v.value");
        var UAEs = component.get("v.utilityAccountEnrollments");
        for(var i=0; i<UAEs.length;i++){
            if(UAEs[i].objUAE.Status__c != 'Enrollment Request Accepted')
                UAEs[i].isChecked = selectedHeaderCheck;
        }
        var checker = false;
        for(var i=0; i<UAEs.length;i++){
            if(UAEs[i].isChecked){
                checker = true;
            }
            if(UAEs[i].objUAE.Hold_Transaction__c || UAEs[i].objUAE.Hold_Reason_Code__c != null || UAEs[i].objUAE.Start_Date__c != null){
                
                component.set("v.invalidDate", false);
            }
        }
        component.set("v.hasSelectedUAE",checker);
        component.set("v.utilityAccountEnrollments",UAEs);
        helper.buildData(component, helper);
    },
    handleSubmit: function(component, event, helper) {
        //debugger;
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var UAE = component.get("v.utilityAccountEnrollments");
        var updatedUAE =[];
        var isInvalid = false;
        var utility = component.get("v.utility");
        var enrollmentBillType = component.get("v.enrollmentBillType");
        
        var errMsg = 'Service Class or Billing Code is missing for '
        for(var i=0; i<UAE.length;i++){
            if(UAE[i].isChecked){
                if(enrollmentBillType == "Dual"){
                    updatedUAE.push(UAE[i].objUAE);
                    isInvalid = false;
                }
                else{
                    if($A.util.isEmpty(UAE[i].objUAE.Utility_Account__r.Service_Class__c)){
                        isInvalid = true;
                        errMsg = errMsg + UAE[i].objUAE.Utility_Account__r.Name + ' ';
                    }
                    else if($A.util.isEmpty(UAE[i].objUAE.Program_Code__c) && UAE[i].objUAE.Utility_Account__r.Utility__c == utility){
                        isInvalid = true;
                        errMsg = errMsg + UAE[i].objUAE.Utility_Account__r.Name + ' ';
                    }
                        else{
                            updatedUAE.push(UAE[i].objUAE);
                        }
                }
            }
        }
        if(!isInvalid){
            console.log('UAE to be passed'+JSON.stringify(updatedUAE));
            component.set("v.errMsg", '');
            component.set("v.selectedUAEs", updatedUAE);
            var action = component.get("c.submitEnrollment");
            action.setParams({ 
                "recordId" : component.get("v.recordId"),
                "objUAEs" : updatedUAE
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    console.log(JSON.stringify(response.getReturnValue()));
                    
                    //SU:539 Display Error message when Required Objects fields are missing
                    
                    component.set("v.code", response.getReturnValue());
                    let word = component.get("v.code"), sequenceToCheck = 'Required data objects missing';
                    if (word.includes(sequenceToCheck)) {
                        console.log('sequence exist');
                        component.set("v.errMsgRequireObjects", component.get("v.code"));
                        $A.util.addClass(component.find("Spinner"), "slds-hide");
                    } else {
                        console.log('sequence does not exist');
                        component.set("v.errMsgRequireObjects", '');
                         component.set("v.showResults", true);
                        $A.get('e.force:refreshView').fire();
                        $A.util.addClass(component.find("Spinner"), "slds-hide");
                    }
                }
                else if(state === "ERROR"){
                    $A.util.addClass(component.find("Spinner"), "slds-hide");
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "type": 'error',
                    "message": response.getError()
                });
                toastEvent.fire();
                }
            });
            $A.enqueueAction(action); 
        }
        else{
            $A.util.addClass(component.find("Spinner"), "slds-hide");
            component.set("v.errMsg", errMsg);
        }
    },
    openCloseModel: function(cmp, event, helper) {
        var openmodel = cmp.get("v.openModel");
        openmodel = !openmodel;
        cmp.set("v.openModel", openmodel);
    },
    sortByUAN: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.Name == b.objUAE.Utility_Account__r.Name, t2 = a.objUAE.Utility_Account__r.Name < b.objUAE.Utility_Account__r.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "UAN");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByAMRD: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.Average_Meter_Read_Date__c	== b.objUAE.Utility_Account__r.Average_Meter_Read_Date__c, t2 = a.objUAE.Utility_Account__r.Average_Meter_Read_Date__c < b.objUAE.Utility_Account__r.Average_Meter_Read_Date__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "AMRD");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByUtility: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.Utility__r.Name == b.objUAE.Utility_Account__r.Utility__r.Name, t2 = a.objUAE.Utility_Account__r.Utility__r.Name < b.objUAE.Utility_Account__r.Utility__r.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "Utility");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByBillType : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Bill_Type__c == b.objUAE.Bill_Type__c, t2 = a.objUAE.Bill_Type__c < b.objUAE.Utility_Account__r.Bill_Type__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "BillType");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByRSN : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Rate_Schedule_Name__c == b.objUAE.Rate_Schedule_Name__c, t2 = a.objUAE.Rate_Schedule_Name__c < b.objUAE.Rate_Schedule_Name__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "RSN");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortByStatus  : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Status__c == b.objUAE.Status__c, t2 = a.objUAE.Status__c < b.objUAE.Status__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "Status");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortBySA : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.Service_Address__c == b.objUAE.Utility_Account__r.Service_Address__c, t2 = a.objUAE.Utility_Account__r.Service_Address__c < b.objUAE.Utility_Account__r.Service_Address__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "SA");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
    },
    sortBySC : function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccountEnrollments");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objUAE.Utility_Account__r.service_class__c  == b.objUAE.Utility_Account__r.service_class__c , t2 = a.objUAE.Utility_Account__r.service_class__c < b.objUAE.Utility_Account__rservice_class__c ;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "SC");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccountEnrollments", currentList);
        helper.buildData(component, helper);
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
    editTEC : function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editTEC = !UAE[index].editTEC;
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    editEffectiveDate :function (component, event, helper){
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        if(UAE[index].editEffectiveDate == true){
            UAE[index].editEffectiveDate =false;
        }
        else{
            UAE[index].editEffectiveDate =true;
        }
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    editPercentage : function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editPercentage = !UAE[index].editPercentage;
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    editTEC_Number : function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editTEC_Number = !UAE[index].editTEC_Number;
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    editTax_Exempt: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editTax_Exempt = false;
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
    changedTaxExampt: function (component, event, helper) {
        var index = event.getSource().get("v.name");
        
        var currPage = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        
        if(currPage > 1){
            index = (currPage - 1) * pageSize + index;
        }
        
        var UAE = component.get("v.utilityAccountEnrollments");
        UAE[index].editTax_Exempt = !UAE[index].editTax_Exempt;
        component.set("v.utilityAccountEnrollments", UAE);
        helper.buildData(component, helper);
    },
})