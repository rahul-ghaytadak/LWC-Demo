({
	doInit : function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
    
        var action = cmp.get("c.getData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                cmp.set('v.BatchData', response.getReturnValue());
                cmp.set("v.totalRecordsCount", response.getReturnValue().length);
                helper.buildData(cmp, helper);       
            }
        });
        $A.enqueueAction(action); 
        cmp.set('v.showSpinner', false);
    },
    
        sortByCD: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.BatchData");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Completed_Date__c == b.Completed_Date__c, t2 = a.Completed_Date__c < b.Completed_Date__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "CD");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.BatchData", currentList);
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
    
    sortByBatchID: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.BatchData");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Name == b.Name, t2 = a.Name < b.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "CD");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.BatchData", currentList);
        helper.buildData(component, helper);
    }
})