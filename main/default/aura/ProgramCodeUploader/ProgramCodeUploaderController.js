({
    doInit : function(component, event, helper){
        component.set('v.showSpinner', true);
        var action = component.get("c.getData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.programCodes', response.getReturnValue());
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                helper.buildData(component, helper);
            }
        });
        $A.enqueueAction(action);    
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var ext;
        component.set('v.showSpinner', true);
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            ext = fileName.substring(fileName.length-3,fileName.length);
        }
        component.set("v.fileName", fileName);
        if(ext=='csv'){
            var fileInput = component.find("file").get("v.files");
            var file = fileInput[0];
            if (file) {
                var reader = new FileReader();
                reader.readAsText(file, "UTF-8");
                reader.onload = function (evt) {
                    var csv = evt.target.result;
                    window.setTimeout($A.getCallback(function(){
                        helper.FetchData(component,helper,csv);
                    }), 10);
                }
                reader.onerror = function (evt) {
                }
            }
        }
        else {
            component.set("v.errorMessage",'Kindly select a CSV file.');
            component.set('v.showSpinner', false);
        }
    },
    createPCRecord : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var LOOKUP = 'LOOKUP';         
        createRecordEvent.setParams({
            "entityApiName": "Program_Code__c",
            "panelOnDestroyCallback": function(event) {
                $A.get('e.force:refreshView').fire();
            },
            "navigationLocation":LOOKUP,
            
        });
        createRecordEvent.fire();
    },
    sortByUtility:  function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.programCodes");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Utility__r.Name == b.Utility__r.Name, t2 = a.Utility__r.Name < b.Utility__r.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "Utility");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.programCodes", currentList);
        helper.buildData(component, helper);
    },
    sortByCommodity: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.programCodes");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Commodity__c == b.Commodity__c, t2 = a.Commodity__c < b.Commodity__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "Commodity");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.programCodes", currentList);
        helper.buildData(component, helper);
    },
    sortByProgramNumber: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.programCodes");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Program_Number__c == b.Program_Number__c, t2 = a.Program_Number__c < b.Program_Number__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "ProgramNumber");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.programCodes", currentList);
        helper.buildData(component, helper);
    },
    
    sortByPricingGroup: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.programCodes");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Pricing_Group__c == b.Pricing_Group__c, t2 = a.Pricing_Group__c < b.Pricing_Group__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "PricingGroup");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.programCodes", currentList);
        helper.buildData(component, helper);
    },
    
    sortByEffectiveDate: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.programCodes");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Effective_Date__c == b.Effective_Date__c, t2 = a.Effective_Date__c < b.Effective_Date__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "EffectiveDate");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.programCodes", currentList);
        helper.buildData(component, helper);
    },
    
    sortByTerminationDate: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.programCodes");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Termination_Date__c == b.Termination_Date__c, t2 = a.Termination_Date__c < b.Termination_Date__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "TerminationDate");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.programCodes", currentList);
        helper.buildData(component, helper);
    },
    
    sortByRate: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.programCodes");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.Rate__c == b.Rate__c, t2 = a.Rate__c < b.Rate__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "Rate");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.programCodes", currentList);
        helper.buildData(component, helper);
    },
    
    sortByISOZone: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.programCodes");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.ISO_Zone__c  == b.ISO_Zone__c , t2 = a.ISO_Zone__c  < b.ISO_Zone__c ;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "ISOZone");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.programCodes", currentList);
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
    
})