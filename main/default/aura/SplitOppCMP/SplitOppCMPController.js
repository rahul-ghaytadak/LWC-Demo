({
    doInit : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get("c.getUAOList");
        
         action.setParams({  
            'recordId' : component.get("v.recordId")
         });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set('v.uaoLst', response.getReturnValue());
                component.set('v.showSpinner', false);
                console.log('14-->'+response.getReturnValue().length);
                
                if(response.getReturnValue().length > 0){
                    component.set("v.showScreen3",false);
                    component.set("v.showScreen1",true);
                    component.set("v.selectedContacts",response.getReturnValue());
                    component.set('v.selectedBrokerAccount',response.getReturnValue()[0].Acc);
                    
                  //  component.set('v.selectedUAs', response.getReturnValue().length);
                    
                    helper.buildData(component, helper,response.getReturnValue());
                   // component.find("selectAll").set("v.value",true);
                }
                else{
                     component.set('v.showSpinner', false);
                     component.set('v.selectedUAs', 0);
                }
            }
            else{
                component.set('v.showSpinner', false);
            }
            component.set('v.showSpinner', false);
            JSON.stringify(response.getReturnValue());
        });
        $A.enqueueAction(action); 
        
    },
    
    doInitTwo : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get("c.getUAOList");
        
         action.setParams({  
            'recordId' : component.get("v.recordId")
         });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set('v.uaoLst', response.getReturnValue());
                component.set('v.showSpinner', false);
                console.log('14-->'+response.getReturnValue().length);
                component.set('v.checkLength', response.getReturnValue().length);
                
                if(response.getReturnValue().length > 0){
                    component.set("v.showScreen3",false);
                    component.set("v.showScreen1",true);
                    var finlLst = [];
               //     component.set('v.selectedUAs', response.getReturnValue().length);
                    component.set("v.selectedContacts",finlLst);
                     component.set('v.PaginationList', response.getReturnValue());
                //    helper.buildData(component, helper,response.getReturnValue());
                  
                }
                else{
                     component.set('v.showSpinner', false);
                     component.set("v.showScreen1",false);
                     component.set('v.selectedUAs', 0);
                }
            }
            else{
                component.set('v.showSpinner', false);
            }
            component.set('v.showSpinner', false);
            JSON.stringify(response.getReturnValue());
        });
        $A.enqueueAction(action); 
        
    },
    
    CreateOppty : function(component, event, helper) {
        component.set("v.showScreen1",false);
        component.set("v.showScreen2",true);
    },
    
    InsertOppty : function(component, event, helper) {
        helper.CreateOpp(component, helper);
    },
    
    handleSelectAllContact: function(component, event, helper) {
        
        var getPreviousSelection = component.get("v.selectedContacts");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("checkContact"); 
        var UALst = [];
        var finalLst = [];
        var filteredArray = [];
        if(checkvalue == true){
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",true);
            }
            UALst = component.get("v.PaginationList");
            finalLst = getPreviousSelection.concat(UALst);
            var mySet = new Set(finalLst);
            filteredArray = Array.from(mySet)
         
            component.set("v.selectedContacts",filteredArray);
            
            component.set("v.selectedUAs",filteredArray.length);
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
            var getSelected = component.get("v.selectedContacts");
            var finlLst = [];
            for(var i=0 ;i<getSelected.length;i++){
                if(getSelected[i].isSelected == true){
                    finlLst.push(getSelected[i]);
                }
            }
            component.set("v.selectedUAs",finlLst.length);
            component.set("v.selectedContacts",finlLst);
        }
        
        
    },
    
    handleSelectedAccs : function(component, event, helper) {  
        
        var selectedContacts = [];
        var filteredArray = [];  
        var finalLst = [];
        selectedContacts = component.get("v.selectedContacts");
        var checkvalue = component.find("checkContact");
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                    selectedContacts.push(checkvalue.get("v.errors"));
                }
               
            
        }
        
        else{
            for (var i = 0; i < checkvalue.length; i++) {
                
                if (checkvalue[i].get("v.value") == true) {
                    selectedContacts.push(checkvalue[i].get("v.errors"));
                }

            }
        }
        
        var mySet = new Set(selectedContacts);
        filteredArray = Array.from(mySet)
        
        for(i=0;i<filteredArray.length;i++){	
            if(filteredArray[i].isSelected == true){	
                finalLst.push(filteredArray[i]);	
            }	
        }
        
        component.set("v.selectedUAs",finalLst.length);
        component.set("v.selectedContacts",finalLst);
        
    },
    
    OpenFilter: function(component, event, helper) {
        component.set("v.openFilterModal", true);
        var uaoLst = component.get("v.uaoLst");
        var filterOptions = [];
        
        for(var i=0;i<uaoLst.length;i++){
            filterOptions.push(uaoLst[i].UAO.Utility__c);
        }
        var mySet = new Set(filterOptions);
        var filteredArray = Array.from(mySet)
        
        component.set("v.utilityList",filteredArray);
        
        
    },
    
    handleDeSelected: function(component, event, helper) {
       var checkvalue = component.find("selectAllModal");
       var updatedFilteredLst = []; 
       if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                    updatedFilteredLst.push(checkvalue.get("v.errors"));
                }
               
            
        }
        
        else{
            for (var i = 0; i < checkvalue.length; i++) {
                
                if (checkvalue[i].get("v.value") == true) {
                    updatedFilteredLst.push(checkvalue[i].get("v.errors"));
                }

            }
        }
        console.log('Length->'+updatedFilteredLst.length);
        component.set("v.filteredutilityList",updatedFilteredLst);
    },
    
    ApplyFilter: function(component, event, helper) {
        
        var filterOptions = component.get("v.filteredutilityList");
        var uaoLst = component.get("v.uaoLst");
        var filteredUAOs = [];
        
        for(var i=0;i<uaoLst.length;i++){
            if(filterOptions.includes(uaoLst[i].UAO.Utility__c)){
                filteredUAOs.push(uaoLst[i]);
            }
        }
        console.log('filteredUAOs->'+JSON.stringify(filteredUAOs));
        component.set("v.PaginationList", filteredUAOs);
        component.set("v.selectedContacts",filteredUAOs);
        component.set("v.selectedUAs",filteredUAOs.length);
        component.set("v.openFilterModal", false);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.openFilterModal", false);
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
        
        if(component.get("v.pageSize") == 'All'){
            helper.buildData(component,helper,component.get('v.uaoLst'));
        }
        else{
            component.set("v.currentPageNumber", 1);
            helper.buildData(component,helper);
        }
    },
    
    sortByBatchID: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.PaginationList");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.UAO.Utility_Account__r.Name == b.UAO.Utility_Account__r.Name, t2 = a.UAO.Utility_Account__r.Name < b.UAO.Utility_Account__r.Name;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "CD");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        console.log('currentList'+currentList.length);
        component.set("v.PaginationList", currentList);
       // helper.buildData(component, helper);
    },
    sortBybyUtility: function(component, event, helper) {
        var currentOrder = component.get("v.sortAsc"),
            currentList = component.get("v.PaginationList");
        currentOrder = !currentOrder;
        currentList.sort(function(a,b) {
            var t1 = a.UAO.Utility__c == b.UAO.Utility__c, t2 = a.UAO.Utility__c < b.UAO.Utility__c;
            return t1? 0: (currentOrder?-1:1)*(t2?1:-1);
        });
        component.set("v.selectedTabsoft", "CD");
        if(currentOrder)
            component.set("v.arrowDirection", "arrowup");
        else
            component.set("v.arrowDirection", "arrowdown");
        component.set("v.sortAsc", currentOrder);
        console.log('currentList'+currentList.length);
        component.set("v.PaginationList", currentList);
       // helper.buildData(component, helper);
    },
    
    prevMethod: function(component, event, helper) {
        if(component.get("v.showScreen3")){
            component.set("v.showScreen2",true);
            component.set("v.showScreen3",false);
            component.set("v.showScreen1",false);
            component.set("v.showCheckbox",false);
        }
        else{
            component.set("v.showScreen1",true);
            component.set("v.showScreen2",false);
            component.set("v.showScreen3",false);
            component.set("v.showCheckbox",false);
            
        }
    },
    
    CPRcheck: function(component, event, helper) {
        var CPR = component.find("CPR").get("v.value");
        if(CPR==true){
            component.set("v.CreatePricingRequest",false);    
        }
        
        
    },
    
    CPRcheck1: function(component, event, helper) {
        var CPR = component.find("CPR1").get("v.value");
        if(CPR==true){
            component.set("v.CreatePricingRequest",false);    
        }
        
        
    },
    
    finishMethod: function(component, event, helper) {
        if(component.get("v.CreatePricingRequest")){
            if(component.get("v.errMsg") == 'noError'){
            component.set("v.showScreen4",true);
			component.set("v.showScreen3",false);
                
            }
        }
        else{
            component.set("v.showScreen3",true);
        }
        console.log('---finishMethod---');
        
        /*   else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "We hit a snag!",
                    "type" : "error",
                    "mode" : "sticky",
                    "message": component.get("v.errMsg")
                });
                toastEvent.fire();
            }
        }
        else{
            console.log('Error message - >'+component.get("v.errMsg"));
            if(component.get("v.errMsg") == 'noError'){
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'sticky',
                                type:'success',
                                title:'Congratulations',
                                message: 'This is a required message',
                                messageTemplate: '{1} {0} created!',
                                messageTemplateData: ['record', {
                                    url: '/'+component.get("v.NewOppId"),
                                    label: 'Opportunity',
                                }
                                                     ]
                            });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "We hit a snag!",
                    "type" : "error",
                    "message": component.get("v.errMsg")
                });
                toastEvent.fire();
            }
        }*/
    },
    
        finishMethodNew: function(component, event, helper) {
            console.log('Error message - >'+component.get("v.errMsg"));
            if(component.get("v.errMsg") == 'noError'){
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type:'success',
                                title:'Congratulations',
                                message: 'This is a required message',
                                messageTemplate: '{1} {0} created!',
                                messageTemplateData: ['record', {
                                    url: '/'+component.get("v.NewOppId"),
                                    label: 'Opportunity',
                                }
                                                     ]
                            });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "We hit a snag!",
                    "type" : "error",
                    "message": component.get("v.errMsg")
                });
                toastEvent.fire();
            }
        
    },
    
    exitMethod : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        if(typeof component.get("v.NewOppId") != 'undefined'){
        $A.get('e.force:refreshView').fire();
            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                type:'success',
                                title:'Congratulations',
                                message: 'This is a required message',
                                messageTemplate: '{1} {0} created!',
                                messageTemplateData: ['record', {
                                    url: '/'+component.get("v.NewOppId"),
                                    label: 'Opportunity',
                                }
                                                     ]
                            });
                toastEvent.fire();
            }
           
    },
})