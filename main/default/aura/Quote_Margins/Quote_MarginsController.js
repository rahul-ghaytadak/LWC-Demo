({
    doInit: function(component, event, helper) {
        console.log(component.get("v.selectedPriceId"));
        component.set("v.spinner", true);
        var staticLabel = $A.get("$Label.c.Base_Price_Threshold");
        component.set("v.mylabel", staticLabel);

        helper.doInitHelper(component, event,helper);
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.listOfAllPS");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objAccount.Term_months__c == b.objAccount.Term_months__c, t2 = a.objAccount.Term_months__c < b.objAccount.Term_months__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });

        var allRecords = component.get("v.listOfAllPS");
        var totalPriceToPass = [];
        for(var i=0;i<allRecords.length;i++){
            allRecords[i].totalPrice = parseFloat(allRecords[i].objAccount.Base_Price__c) + ( (parseFloat(allRecords[i].salesMargin) + parseFloat(allRecords[i].brokerMargin)) * (parseFloat(allRecords[i].objAccount.POR_Factor__c) + parseFloat(allRecords[i].objAccount.Tax_Factor__c) -1));
            totalPriceToPass.push(parseFloat(allRecords[i].totalPrice.toFixed(5)));
        }
        var action = component.get("c.TotalPriceValidation");
        action.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPriceToPass,'selectedPriceId' : component.get("v.selectedPriceId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.Validated", response.getReturnValue());           
                component.set("v.selectedTabsoft", "Term");
                var action1 = component.get("c.AllowNIMOValidation");
                action1.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPriceToPass,'selectedPriceId' : component.get("v.selectedPriceId")}); 
                action1.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log('47->'+response.getReturnValue());  
                        component.set("v.showOverRide", response.getReturnValue());
                        component.set("v.spinner", false);
                    }
                });
                $A.enqueueAction(action1);
                
            }
        });
        $A.enqueueAction(action);  
         
        console.log('24->here'+component.get("v.listOfAllPS")); 
        //component.set("v.selectedTabsoft", "Term");
        //component.set("v.spinner", false);
    },
    
    overRideNIMOValidation : function(component, event, helper) {
        var action1 = component.get("c.AllowNIMOValidation");
        action1.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPriceToPass,'selectedPriceId' : component.get("v.selectedPriceId")}); 
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('47->'+response.getReturnValue());  
                component.set("v.showOverRide", response.getReturnValue());           
            }
        });
        $A.enqueueAction(action1); 
    },
    
    allowNext : function(component, event, helper) {
        var allowGenQuote = component.find("CPR").get("v.checked");
        component.set("v.Validated",allowGenQuote);
        component.set("v.showOverRideNew",true);
        component.set("v.showOverRide",false);
    },
    
    allowNextNew : function(component, event, helper) {
        var allowGenQuote = component.find("CPRNew").get("v.checked");
        component.set("v.Validated",allowGenQuote);
        component.set("v.showOverRideNew",true);
        component.set("v.showOverRide",false);
    },
    
    handleClick: function(component, event, helper) {
        component.set("v.salesMarginVal",event.target.value);
    },
    changeSalesMargin: function(component, event, helper) {
        var salesMarginValue = parseFloat(event.target.value).toFixed(5);
        //var val = component.get("v.salesMargin");
        component.set("v.salesMargin", salesMarginValue);
        var val = component.get("v.salesMargin");
        var allRecords = component.get("v.listOfAllPS");
        var totalPriceToPass = [];
        
        for(var i=0;i<allRecords.length;i++){
            allRecords[i].salesMargin = val;
            allRecords[i].totalPrice = parseFloat(allRecords[i].objAccount.Base_Price__c) + ( (parseFloat(allRecords[i].salesMargin) + parseFloat(allRecords[i].brokerMargin)) * (parseFloat(allRecords[i].objAccount.POR_Factor__c) + parseFloat(allRecords[i].objAccount.Tax_Factor__c) -1));
            totalPriceToPass.push(parseFloat(allRecords[i].totalPrice.toFixed(5)));
            if(parseFloat(allRecords[i].salesMargin) < 0.001 ){
                component.set("v.checkSM", true);
                component.set("v.confirmation", false);
            }
            else{
                component.set("v.checkSM", false);
                component.set("v.confirmation", true);
            }
            allRecords[i].newSalesMargin = parseFloat(allRecords[i].objAccount.Cumulative_Volume__c) * parseFloat(allRecords[i].salesMargin);
        }
        var action = component.get("c.TotalPriceValidation");
        action.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' : totalPriceToPass,'selectedPriceId' : component.get("v.selectedPriceId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('65->'+response.getReturnValue());  
                component.set("v.Validated", response.getReturnValue());           
            }
        });
        $A.enqueueAction(action);
        component.set("v.listOfAllPS", allRecords);
    },
    changebrokerMargin: function(component, event, helper) {
        var brokerMarginValue = parseFloat(event.target.value).toFixed(5);
        component.set("v.brokerMargin",brokerMarginValue);
        var val = component.get("v.brokerMargin");
        var allRecords = component.get("v.listOfAllPS");
        var totalPriceToPass = [];
        for(var i=0;i<allRecords.length;i++){
            allRecords[i].brokerMargin = val;
            allRecords[i].totalPrice = parseFloat(allRecords[i].objAccount.Base_Price__c) + ( (parseFloat(allRecords[i].salesMargin) + parseFloat(allRecords[i].brokerMargin)) * (parseFloat(allRecords[i].objAccount.POR_Factor__c) + parseFloat(allRecords[i].objAccount.Tax_Factor__c) -1));
            totalPriceToPass.push(parseFloat(allRecords[i].totalPrice.toFixed(5)));
        }
        var action = component.get("c.TotalPriceValidation");
        action.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' : totalPriceToPass,'selectedPriceId' : component.get("v.selectedPriceId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('87->'+response.getReturnValue());  
                component.set("v.Validated", response.getReturnValue());            
            }
        });
        $A.enqueueAction(action);  
        
        component.set("v.listOfAllPS", allRecords);
        
    },
    
    confirmation: function(component, event, helper) {
        var checkCmp = component.find("checkbox");
        component.set("v.confirmation", checkCmp.get("v.value"));
    },
    calculateTotalPrice: function(component, event, helper) {
        var sm = parseFloat(event.target.value).toFixed(5);
        var allRecords = component.get("v.listOfAllPS");
        var index = event.target.id;
        allRecords[index].salesMargin = sm;
        var checker1;
        var checker2;
        var salesMargins = [];
        var totalPriceToPass = [];
        for(var i=0;i<allRecords.length;i++){
            allRecords[i].totalPrice = parseFloat(allRecords[i].objAccount.Base_Price__c) + ( (parseFloat(allRecords[i].salesMargin) + parseFloat(allRecords[i].brokerMargin)) * (parseFloat(allRecords[i].objAccount.POR_Factor__c) + parseFloat(allRecords[i].objAccount.Tax_Factor__c) -1));
            allRecords[i].newSalesMargin = parseFloat(allRecords[i].objAccount.Cumulative_Volume__c) * parseFloat(allRecords[i].salesMargin);
            salesMargins.push(parseFloat(allRecords[i].salesMargin));
            totalPriceToPass.push(parseFloat(allRecords[i].totalPrice.toFixed(5)));
        }
        var action = component.get("c.TotalPriceValidation");
        action.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' : totalPriceToPass,'selectedPriceId' : component.get("v.selectedPriceId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('90->'+response.getReturnValue());
                component.set("v.Validated", response.getReturnValue());               
            }
        });
        $A.enqueueAction(action); 
        
        var sm = Math.min.apply( Math, salesMargins);
        if(sm < 0.001 ){
            component.set("v.checkSM", true);
            component.set("v.confirmation", false);
        }
        else{
            component.set("v.checkSM", false);
            component.set("v.confirmation", true);
        }
        
        component.set("v.listOfAllPS", allRecords);
    },
    calculateTotalPriceBroker: function(component, event, helper) {
        var bm = parseFloat(event.target.value).toFixed(5);
        var allRecords = component.get("v.listOfAllPS");
        var index = event.target.id;
        allRecords[index].brokerMargin = bm;
        var totalPriceToPass = []; 
        for(var i=0;i<allRecords.length;i++){
            allRecords[i].totalPrice = parseFloat(allRecords[i].objAccount.Base_Price__c) + ( (parseFloat(allRecords[i].salesMargin) + parseFloat(allRecords[i].brokerMargin)) * (parseFloat(allRecords[i].objAccount.POR_Factor__c) + parseFloat(allRecords[i].objAccount.Tax_Factor__c) -1));
            totalPriceToPass.push(parseFloat(allRecords[i].totalPrice.toFixed(5)));
        }
        var action = component.get("c.TotalPriceValidation");
        action.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' : totalPriceToPass,'selectedPriceId' : component.get("v.selectedPriceId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('157->'+response.getReturnValue());
                component.set("v.Validated", response.getReturnValue());               
            }
        });
        $A.enqueueAction(action); 
        component.set("v.listOfAllPS", allRecords); 
    },
    
    sortByTerm: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.listOfAllPS");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.objAccount.Term_months__c == b.objAccount.Term_months__c, t2 = a.objAccount.Term_months__c < b.objAccount.Term_months__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "Term");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.listOfAllPS", currentList);
    },
    sortByTotalPrice: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.listOfAllPS");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.totalPrice == b.totalPrice, t2 = a.totalPrice < b.totalPrice;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "totalPrice");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        component.set("v.listOfAllPS", currentList);
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
        component.set("v.currentPageNumber", parseInt(event.target.name));
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
    generateQuote : function(component, event, helper) {   

        helper.generateQuoteHelper(component, helper);
    },
    
})