({
    doInitHelper: function(component, event, helper){
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        component.set("v.errMsgRequireObjects", '');
        component.set('v.utility', $A.get("{!$Label.c.National_Grid_Utility_Id}"));
        var action = component.get("c.getUAEs");
        action.setParams({  
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.totalRecordsCount",response.getReturnValue().length);
                component.set("v.utilityAccountEnrollments", response.getReturnValue());
                var resp = response.getReturnValue();
                component.set("v.enrollmentBillType", resp[0].objUAE.Enrollment__r.Bill_Type__c);
                component.set("v.invalidDate", resp[0].invalidDate);
                component.set("v.StartDateIsValid", resp[0].StartDateIsValid);
                
                var NationalGrid = [];
                resp.forEach(function(res) {
                   
                    if(res.objUAE.Utility_Account__r.Utility__r.Name.includes('National Grid'))
                        NationalGrid.push(res.objUAE.Utility_Account__c);
                });
                if (!$A.util.isEmpty(NationalGrid)){
                    console.log('NationalGrid: ' + JSON.stringify(NationalGrid));
                    helper.getProgramCodes(component, helper, NationalGrid);
                }
                helper.buildData(component, helper);
            }
        });
        $A.enqueueAction(action);  
    },
    
    getProgramCodes: function(component, helper, uaccounts){
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var action = component.get("c.getProgramCodes");
        action.setParams({  
            "enrollmentId" : component.get("v.recordId"),
            "UAs" : uaccounts
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var codes = [];
                var pc = response.getReturnValue();
                for ( var key in pc ) {
                    codes.push({value:pc[key], key:key});
                }
                
                component.set("v.programCodes", codes);
                console.log('codes: ' + JSON.stringify(codes));
                $A.util.addClass(component.find("Spinner"), "slds-hide");
            }
        });
        $A.enqueueAction(action);  
    },
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.totalPages", Math.ceil( component.get("v.utilityAccountEnrollments").length/component.get("v.pageSize")));
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.utilityAccountEnrollments");
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
        $A.util.addClass(component.find("Spinner"), "slds-hide");
    },
    
})