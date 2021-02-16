({
    doInit: function(component, event, helper) {
       
        //$A.get('e.force:refreshView').fire();   
        component.set("v.spinner", true);
        helper.doInitHelper(component, event,helper, 'Base_Price__c');
        console.log('selectedCount->'+component.get("v.selectedCount"));
       // component.set("v.spinner", false);
        //$A.get('e.force:refreshView').fire();   
    },
    changePageSize: function(component, event, helper) {
        helper.buildData(component,helper);
    },
    
    /* javaScript function for pagination 
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllPS");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },*/
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
 
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllPS = component.get("v.listOfAllPS");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllPS.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllPS[i].isChecked = true;
                component.set("v.selectedCount", listOfAllPS.length);
            } else {
                listOfAllPS[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllPS[i]);
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
        component.set("v.listOfAllPS", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
 
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
        
    },
 
    getSelectedPS: function(component, event, helper) {
        var allRecords = component.get("v.listOfAllPS");
        var selectedPS = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedPS.push(allRecords[i]);
            }
        }
        component.set("v.selectedPS", selectedPS);  
    },
    sortByTerm: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Term');
        helper.doInitHelper(component, event, helper, 'Term_months__c' );
    },
    sortByPrice: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Price');
        helper.doInitHelper(component, event, helper, 'Base_Price__c' );
    },
    sortByVol: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Volume');
        helper.doInitHelper(component, event, helper, 'Cumulative_Volume__c' );
    },
    gotoRelatedList : function (component, event, helper) {
        var listOfAllPS = component.get("v.listOfAllPS");
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Price_Summaries__r",
            "parentRecordId": listOfAllPS[0].objAccount.Price__c
        });
        relatedListEvent.fire();
    },
})