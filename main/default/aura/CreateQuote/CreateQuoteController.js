({
    doInit: function(component, event, helper) {
        component.set("v.spinner", true);
        var staticLabel = $A.get("$Label.c.Base_Price_Threshold");
        component.set("v.mylabel", staticLabel);
        helper.getPrices(component, helper);
        helper.doInitHelper(component, event,helper, 'Utility_Account__r.Name');
        
    },
    showUA : function(component, event, helper){
        component.set("v.PaginationList", null);
        component.set("v.selectedUACount", 0);
        component.set("v.spinner", true);
        component.set("v.showUA", true);
        component.set("v.startDate", null);
        var action = component.get("c.getUAs");
        action.setParams({  
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var allRecords = response.getReturnValue();
                for (var i = 0; i < allRecords.length; i++) {
                    allRecords[i].objAccount.Load_Factor__c = allRecords[i].objAccount.Load_Factor__c / 100;
                }
                component.set("v.utilityAccounts", allRecords);
                component.set("v.totalPages", Math.ceil(allRecords.length/component.get("v.pageSize")));
                component.set("v.currentPageNumber",1);
                component.set("v.totalRecordsCount", component.get("v.utilityAccounts").length);
                helper.buildData(component, helper);
            }
        });
        $A.enqueueAction(action);  
    },
    /* javaScript function for pagination */
    
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
    },
    onPriceChange : function(component, event, helper) {  
        component.set("v.spinner", true);
        var priceId = component.find("selectPrice").get("v.value");
        component.set("v.selectedPriceId", priceId);
        var prices = component.get("v.priceList");
        var action2 = component.get("c.updateUAOWithSelectedPrice");
        action2.setParams({  
            'priceId' : priceId,
            'oppId' : component.get("v.recordId")
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.isInit", false);
                helper.doInitHelper(component, event,helper, 'Utility_Account__r.Name');       
            }
        });
        $A.enqueueAction(action2);  
        for(var i=0; i< prices.length; i++){
            console.log('TwoDaysOld'+prices[i].TwoDaysOld);
            if(priceId == prices[i].priceId && prices[i].TwoDaysOld == true ){
                
                component.set("v.checkOldPrice", true);
                component.set("v.confirmation", false);
            }
            if(priceId == prices[i].priceId && prices[i].TwoDaysOld == false ){
                component.set("v.checkOldPrice", false);    
                component.set("v.confirmation", true);
            }
        }
        var action3 = component.get("c.SelectedPriceName");
        action3.setParams({  
            'priceId' : priceId,
            
        });
        action3.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS"){
                component.set("v.selectedProductName",response.getReturnValue());
                console.log('selectedProd'+JSON.stringify(component.get("v.selectedProductName")));
            }
        });
        $A.enqueueAction(action3);  
        
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
        helper.buildData(component,helper);
    },
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllAccounts = component.get("v.listOfAllAccounts");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        var counter = 0;
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true  ) {
                component.set("v.EarliestDateWarning",false);
                if( listOfAllAccounts[i].objAccount.Status__c !="Not Priced"){
                    listOfAllAccounts[i].isChecked = true;
                    counter++;
                    component.set("v.selectedCount", counter);
                    helper.calculateAveragePrice(component, event, helper);
                }
            } else {
                component.set("v.EarliestDateWarning",true);
                listOfAllAccounts[i].isChecked = false;
                component.set("v.selectedCount", 0);
                component.set("v.TwelveMonthAveragePrice", 0);
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                if(PaginationList[i].objAccount.Status__c != "Not Priced")
                    PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfAllAccounts", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
    
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var EarliestDate = component.get("v.EarliestDate");
         var checkvalue = component.find("checkContact");
        var selectedContacts = [];
        var CountOfDates = 0;
        for (var i = 0; i < checkvalue.length; i++) {
               if (checkvalue[i].get("v.value") == true) {
            selectedContacts.push(checkvalue[i].get("v.errors"));
               }
            
            }
        for(var i = 0; i < selectedContacts.length; i++){
            if(selectedContacts[i].objAccount.Start_Date__c == EarliestDate ){
                CountOfDates++;
            }
        }
        if(CountOfDates > 0){
            component.set("v.EarliestDateWarning",false);
        }
        else{
           component.set("v.EarliestDateWarning",true);
        }
       
       
        var selectedRec = event.getSource().get("v.value");
        console.log('selectedRec-->'+JSON.stringify(component.find("checkContact")));
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } 
        else{
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
        helper.calculateAveragePrice(component, event, helper);
    },
    
    getExcludedRecords: function(component, event, helper) {
        
        var allRecords = component.get("v.listOfAllAccounts");
        var excludedRecords = [];
        var includedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (!allRecords[i].isChecked) {
                excludedRecords.push(allRecords[i].objAccount);
            }
            if (allRecords[i].isChecked) {
                includedRecords.push(allRecords[i].objAccount);
            }
        }
        helper.updateExcludedUAOs(component, event, helper, excludedRecords );
    },
    sortByAUName: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'AUName');
        helper.doInitHelper(component, event, helper, 'Utility_Account__r.Name' );
    },
    sortByLF: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'LoadFactor');
        helper.doInitHelper(component, event, helper, 'Utility_Account__r.Load_Factor__c' );
    },
    sortByAnnualVol: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Avol');
        helper.doInitHelper(component, event, helper, 'Utility_Account__r.Annual_Usage_kWh__c' );
    },
    sortByUtility: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Utility');
        helper.doInitHelper(component, event, helper, 'Utility_Account__r.Utility__r.Name' );
    },
    
    sortByStartDate: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'StartDate');
        helper.doInitHelper(component, event, helper, 'Start_Date__c' );
    },
    
    
    sortBy12MBP: function(component, event, helper) {
         var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.listOfAllAccounts");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objAccount.Twelve_Month_Price__c == b.objAccount.Twelve_Month_Price__c, t2 = a.objAccount.Twelve_Month_Price__c < b.objAccount.Twelve_Month_Price__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "12MBP");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.listOfAllAccounts", currentList);
        helper.buildData(component, helper);
    },
    gotoRelatedList : function (component, event, helper) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Utility_Account_Opportunities__r",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
    },
    sortUtilityNumber: function(component, event, helper) {
        debugger;
        component.set("v.selectedTabsoft", 'UN');
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccounts");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objAccount.Name == b.objAccount.Name, t2 = a.objAccount.Name < b.objAccount.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccounts", currentList);
        helper.buildData(component, helper);
    },
    sortUtility: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'UAUtility');
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccounts");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objAccount.Utility__r.Name == b.objAccount.Utility__r.Name, t2 = a.objAccount.Utility__r.Name < b.objAccount.Utility__r.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccounts", currentList); 
        helper.buildData(component, helper);
    },
    sortByLoadFactorUA: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'LF');
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccounts");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objAccount.Load_Factor__c == b.objAccount.Load_Factor__c, t2 = a.objAccount.Load_Factor__c < b.objAccount.Load_Factor__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccounts", currentList); 
        helper.buildData(component, helper);
    },
    
    sortByAnnualVolUA: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'UAvol');
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.utilityAccounts");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objAccount.Annual_Usage_kWh__c == b.objAccount.Annual_Usage_kWh__c, t2 = a.objAccount.Annual_Usage_kWh__c < b.objAccount.Annual_Usage_kWh__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.utilityAccounts", currentList); 
        helper.buildData(component, helper);
    },
    checkboxSelectUA: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedUACount");
        if (selectedRec) {
            getSelectedNumber++;
        } 
        else {
            getSelectedNumber--;
            component.find("selectAllIdUA").set("v.value", false);
        }
        component.set("v.selectedUACount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllIdUA").set("v.value", true);
        }
        
       var UpdatedUALst = [];
        
        UpdatedUALst =  component.get("v.PaginationList");
        for(var i=0; i<UpdatedUALst.length; i++){
            
            if(UpdatedUALst[i].isChecked == true && (typeof UpdatedUALst[i].objAccount.Supply_Start_Date__c==='undefined' || UpdatedUALst[i].objAccount.Supply_Start_Date__c=='' || UpdatedUALst[i].objAccount.Supply_Start_Date__c==null)){
                component.set("v.StartDateSet",false);
                
                break; 
                
            }
            else{
                
                component.set("v.StartDateSet",true); 
            }
        }
        
    },
    selectAllCheckboxUA: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var utilityAccounts = component.get("v.utilityAccounts");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < utilityAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                utilityAccounts[i].isChecked = true;
                component.set("v.selectedUACount", utilityAccounts.length);
            } else {
                utilityAccounts[i].isChecked = false;
                component.set("v.selectedUACount", 0);
            }
            updatedAllRecords.push(utilityAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        var startDate = component.get("v.startDate");
        if(startDate != null && selectedHeaderCheck == true){
            component.set("v.StartDateSet",true);
        }
        component.set("v.utilityAccounts", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
    
    setAllUAStartDates: function(component, event, helper) {
        var selectedHeaderCheck = component.find("selectAllIdUA").get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var utilityAccounts = component.get("v.utilityAccounts");
        var PaginationList = component.get("v.PaginationList");
        var startDate = component.get("v.startDate");
        // play a for loop on all records list 
        for (var i = 0; i < utilityAccounts.length; i++) {
            
            if (startDate != null) {
                utilityAccounts[i].objAccount.Supply_Start_Date__c = startDate;
                if(utilityAccounts[i].isChecked == true){
                    component.set("v.StartDateSet",true);
                }
                
            } 
            updatedAllRecords.push(utilityAccounts[i]);
        }
        
        for (var i = 0; i < PaginationList.length; i++) {
            if (startDate != null) {
                PaginationList[i].objAccount.Supply_Start_Date__c = startDate;
            } 
            if(utilityAccounts[i].isChecked == true){
                component.set("v.StartDateSet",true);
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        
         if(startDate != null && selectedHeaderCheck == true){
            component.set("v.StartDateSet",true);
        }
        component.set("v.utilityAccounts", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
    
    
    addNewUA: function(component, event, helper) {
        component.set("v.spinner", true);
        var utilityAccounts = component.get("v.utilityAccounts");
        var newUAs = [];
        for (var i = 0; i < utilityAccounts.length; i++) {
            if( utilityAccounts[i].isChecked == true)
                newUAs.push(utilityAccounts[i].objAccount);
        }
        var action = component.get("c.saveUAs");
        action.setParams({  
            "recordId" : component.get("v.recordId"),
            "newUAs" : newUAs
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS"){
                component.set("v.StartDateSet", false);
                component.set("v.showUA", false);  
                helper.doInitHelper(component, event,helper, 'Utility_Account__r.Name');
                toastEvent.setParams({
                    "title": "Success!",
                    "type" : "success",
                    "message": "Utility Accounts have been added!"
                });
                toastEvent.fire();
                
            }
            else{
                component.set("v.showUA", false);   
                helper.buildData(component, helper);
                toastEvent.setParams({
                    "title": "Oh Snap!",
                    "type" : "error",
                    "message": "There was an error adding Utility Accounts!"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action); 
    },
    
    goBack :function(component, event, helper) {
        component.set("v.spinner", true);
        component.set("v.StartDateSet", false);
        component.set("v.showUA", false);
        helper.buildData(component, helper);
    },
    
    changeStartDates :function(component, event, helper) {
        
       component.set("v.editmode", false);
    },
    
    cancelEditMode :function(component, event, helper) {
        component.set("v.editmode", true);
    },
    
    UpdateStartDates :function(component, event, helper) {
      component.set("v.spinner", true); 
      var priceId = component.get("v.selectedPriceId"); 
        if(priceId == ''){
            priceId = component.get("v.selectedPriceIdOnLoad"); 
        }  
      var getLst = [];
      var pklst = component.find("selectAllId").get("v.value");  
      getLst = component.get("v.PaginationList");
        
      var action = component.get("c.updateStartDates");
        action.setParams({  
            "UAOLst" : getLst,
            "recordId" : component.get("v.recordId"),
            "priceId" : priceId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS"){
                var a = component.get('c.doInit');
                $A.enqueueAction(a);
                component.set("v.editmode", true);
                component.set("v.spinner", false);
                
            }
            else{
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    changestartDateSeperately: function(component, event, helper) {
        
        var checkFirst = component.get("v.StartDateSet");
        
        var UpdatedUALst = [];
        
        UpdatedUALst =  component.get("v.PaginationList");
        for(var i=0; i<UpdatedUALst.length; i++){
            
            if(UpdatedUALst[i].isChecked == true && (typeof UpdatedUALst[i].objAccount.Supply_Start_Date__c==='undefined' || UpdatedUALst[i].objAccount.Supply_Start_Date__c=='' || UpdatedUALst[i].objAccount.Supply_Start_Date__c==null)){
                component.set("v.StartDateSet",false);
                
                break; 
                
            }
            else{
                
                component.set("v.StartDateSet",true); 
            }
        }
        
        
        
        
    },
    closeModal:function(component,event,helper){    
        //$A.get('e.force:refreshView').fire();
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    openmodal: function(component,event,helper) {
      //  $A.get('e.force:refreshView').fire();
        component.set("v.showSpinnerFullScreen",true); 
        window.setTimeout(
    $A.getCallback(function() {
        component.set("v.showSpinnerFullScreen",false); 
    }), 1000
);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
    }
})