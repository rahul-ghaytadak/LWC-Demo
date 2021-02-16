({
	 doInit: function(component, event, helper) {
        component.set("v.spinner", true);
        helper.getPrices(component, helper);
        helper.doInitHelper(component, event,helper, 'Utility_Account__r.Name');
    },
    
    addUAs : function(component, event, helper){
        component.set("v.addUA", true);
    },
        /* javaScript function for pagination */
    
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
        helper.buildData(component,helper);
    },
    selectAllCheckbox: function(component, event, helper) {
         var selectedHeaderCheck = event.getSource().get("v.value");
    },
    
    getExcludedRecords: function(component, event, helper) {
    },
    sortByAUName: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'AUName');
        helper.doInitHelper(component, event, helper, 'Utility_Account__r.Name' );
    },
     sortByUtility: function(component, event, helper) {
        component.set("v.selectedTabsoft", 'Utility');
        helper.doInitHelper(component, event, helper, 'Utility_Account__r.Utility__r.Name' );
    },
})