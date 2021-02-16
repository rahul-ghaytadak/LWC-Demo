({
    doInitHelper : function(component,event,helper, fieldname){ 
        var allRecords = component.get("v.listOfAllPS");
        if(allRecords.length > 0){
            for(var i=0;i<allRecords.length;i++){
                allRecords[i].totalPrice = parseFloat(allRecords[i].objAccount.Base_Price__c) + ( (parseFloat(allRecords[i].salesMargin) + parseFloat(allRecords[i].brokerMargin)) * (parseFloat(allRecords[i].objAccount.POR_Factor__c) + parseFloat(allRecords[i].objAccount.Tax_Factor__c) -1));
                allRecords[i].newSalesMargin = parseFloat(allRecords[i].objAccount.Cumulative_Volume__c) * parseFloat(allRecords[i].salesMargin);
                 allRecords[i].brokerMargin = parseFloat(allRecords[0].brokerMargin).toFixed(5);
                 allRecords[i].salesMargin = parseFloat(allRecords[i].salesMargin).toFixed(5);
            }
            component.set("v.brokerMargin",parseFloat(allRecords[0].brokerMargin).toFixed(5) );
            component.set("v.salesMargin",parseFloat(allRecords[0].salesMargin).toFixed(5) );
            //component.set("v.totalPrice",parseFloat(allRecords[0].salesMargin).toFixed(5) );
        }
        else{
            // if there is no records then display message
            component.set("v.bNoRecordsFound" , true);
        }
        component.set("v.listOfAllPS", allRecords);
    },
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.listOfAllPS");
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
        component.set("v.spinner", false);
    },
    generateQuoteHelper : function(component,helper){
        component.set("v.spinner", true);
        var psRecords = component.get("v.listOfAllPS");
        var salesMargin = component.get("v.salesMargin");
        var brokerMargin = component.get("v.brokerMargin");
        
        var AnnualVolume = component.get("v.selectedstoreVolumn");
        var AverageLoadFactor = component.get("v.AverageLoadFactor")*100;
        console.log('AverageLoadFactor'+AverageLoadFactor);
        var action = component.get("c.generateQuoteAndLineItems");
        action.setParams({  
            'psRecords' : psRecords,
            'recordId' : component.get("v.recordId"),
            'salesMargin' : salesMargin,
            'brokerMargin' : brokerMargin,
            'selectedPriceId' : component.get("v.selectedPriceId"),
            'StoreVolumnOfTerm' : AnnualVolume,
            'AverageLoadFactor' : AverageLoadFactor
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                if(response.getReturnValue() == "ValidationException"){
                    toastEvent.setParams({
                        "title": "National Grid Validation Failed!",
                        "type" : "error",
                        "message": "Total Price should have '4' or '9' as last digits"
                    });
                    toastEvent.fire();
                    component.set("v.spinner", false);
                } 
                
                if(response.getReturnValue() == "Exception"){
                    toastEvent.setParams({
                        "title": "We hit a Snag!",
                        "type" : "error",
                        "message": "There was an issue generating your quote! Contact System Administrator"
                    });
                    toastEvent.fire();
                    component.set("v.spinner", false);
                }
                else{
                    toastEvent.setParams({
                        "title": "Congratulations!",
                        "type" : "success",
                        "message": "Quote has been generated!"
                    });
                    toastEvent.fire();
                    
                    var quoteId = response.getReturnValue();
                    var eUrl= $A.get("e.force:navigateToURL");
                    eUrl.setParams({
                        "url": '/'+quoteId 
                    });
                    eUrl.fire();
                    component.set("v.spinner", false);
                }
            }
            else{
                toastEvent.setParams({
                    "title": "Oh Snap!",
                    "type" : "error",
                    "message": "There was an issue generating your quote!"
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(action);  
        
    }
})