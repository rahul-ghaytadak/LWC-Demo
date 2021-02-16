({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event,helper, fieldname){ 
        var sortDir = component.get("v.sort");
        if(sortDir == 'ASC'){
            component.set("v.arrowDirection", 'arrowdown');
            sortDir = 'DESC';
            component.set('v.sort', 'DESC');
        }
        else{
            sortDir = 'ASC';
            component.set("v.arrowDirection", 'arrowup');
            component.set('v.sort', 'ASC');
        }
       
        var action = component.get("c.fetchAccountWrapper");
        action.setParams({  
            'oppId' : component.get("v.recordId"),
            'sortType' : sortDir,
            'sortField' : fieldname,
            'isInit' : component.get("v.isInit")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue().length > 0){
                component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
                component.set("v.listOfAllAccounts", response.getReturnValue());
                component.set("v.currentPageNumber",1);
                
                component.set("v.totalRecordsCount", component.get("v.listOfAllAccounts").length);
                helper.buildData(component, helper);
                var annualVolume = 0;
                var volPrice = 0;
                var allRecords = component.get("v.listOfAllAccounts");
                var selectedCount = 0;
                var loadFactor = 0;
                var avgLF;
                component.set("v.EarliestDate",allRecords[0].objAccount.Opportunity__r.Start_Date__c);
                for (var i = 0; i < allRecords.length; i++) {
                    allRecords[i].objAccount.Utility_Account__r.Load_Factor__c = allRecords[i].objAccount.Utility_Account__r.Load_Factor__c / 100;
                    if (allRecords[i].isChecked) {
                        selectedCount++;
                        annualVolume = annualVolume + allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c;
                        volPrice = volPrice + (parseFloat(allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c) * parseFloat(allRecords[i].objAccount.Twelve_Month_Price__c));
                        loadFactor = loadFactor + parseFloat(allRecords[i].objAccount.Utility_Account__r.Load_Factor__c);
                    }
                }
                component.set("v.selectedCount" , selectedCount);
                var TwelveMonthAveragePrice = 0;
                if(volPrice != 0 && annualVolume != 0)
                    TwelveMonthAveragePrice = volPrice/annualVolume;
                TwelveMonthAveragePrice = parseFloat(TwelveMonthAveragePrice.toFixed(5));
                component.set("v.TwelveMonthAveragePrice", TwelveMonthAveragePrice);      
                if(loadFactor != 0)
                    avgLF = loadFactor/parseFloat(component.get("v.selectedCount"));
                component.set("v.AverageLoadFactor", avgLF);
                console.log(component.get("v.AverageLoadFactor")+'expected'+avgLF);
                component.set("v.spinner", false);
                } 
            else{
                if(response.getReturnValue().length == 0){
                    component.set("v.spinner", false);
                }
                else{
                alert('Error...');
                }
            }
        });
        $A.enqueueAction(action);  
    },
    
    getPrices: function(component, helper){
        //alert(component.get("v.storeVolumn"));
        var action = component.get("c.getPrice");
        action.setParams({  
            'oppId' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var responseList = response.getReturnValue();
                if(responseList == ''){
                    component.set("v.confirmation", false);
                    component.set("v.priceList",null);
                }
                else{
                    component.set("v.priceList",responseList);
                    component.set("v.selectedPriceId", responseList[0].priceId);
                    if(responseList[0].priceId && responseList[0].TwoDaysOld == true ){
                        component.set("v.checkOldPrice", true);
                        component.set("v.confirmation", false);
                        
                    }
                    else{
                        component.set("v.checkOldPrice", false);    
                        component.set("v.confirmation", true);
                    }
                }
                component.set("v.selectedProductName", responseList[0]);
            }
        });
        $A.enqueueAction(action);  
        
    },
    // navigate to next pagination record set   
     buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
         if(component.get("v.showUA") == false){
             var allData = component.get("v.listOfAllAccounts");
             component.set("v.totalPages", Math.ceil( component.get("v.listOfAllAccounts").length/component.get("v.pageSize")));
         }
         if(component.get("v.showUA")){
             var allData = component.get("v.utilityAccounts");
             component.set("v.totalPages", Math.ceil( component.get("v.utilityAccounts").length/component.get("v.pageSize")));
         }
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
    calculateAveragePrice : function(component,event,helper){
        var annualVolume = 0;
        var volPrice = 0;
        var loadFactor = 0;
        var allRecords = component.get("v.listOfAllAccounts");
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                if ( allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c != undefined){
                    annualVolume = annualVolume + allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c;
                    volPrice = volPrice + (allRecords[i].objAccount.Utility_Account__r.Annual_Usage_kWh__c * allRecords[i].objAccount.Twelve_Month_Price__c);
                    loadFactor = loadFactor + parseFloat(allRecords[i].objAccount.Utility_Account__r.Load_Factor__c);
                }
            }
        }
        var TwelveMonthAveragePrice = 0;
        var avgLF = 0;
        if(volPrice != 0 && annualVolume != 0)
            TwelveMonthAveragePrice = volPrice/annualVolume;
        if(loadFactor != 0)
            avgLF = loadFactor/parseFloat(component.get("v.selectedCount"));
        
        TwelveMonthAveragePrice = parseFloat(TwelveMonthAveragePrice.toFixed(4));
        component.set("v.TwelveMonthAveragePrice", TwelveMonthAveragePrice);
        component.set("v.AverageLoadFactor", avgLF);
        
    }
})