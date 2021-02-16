({
    doInitHelper : function(component,event,helper, fieldname,selectedState,UtilitiesSelected){
        if(selectedState == ''){
            selectedState = component.get("v.State");
        }
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
        
        var action = component.get("c.getUAList");
        action.setParams({  
            'recordId' : component.get("v.recordId"),
            'sortType' : sortDir,
            'sortField' : fieldname,
            'State' : selectedState,
            'UtilitiesSelected' : UtilitiesSelected
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                //component.set("v.UAList",response.getReturnValue());
                component.set("v.PaginationList", response.getReturnValue());
                component.set("v.spinner", false);
                component.set("v.InitialutilityList2",response.getReturnValue());  
                if(component.get("v.InitialutilityListSet")==false){
                    component.set("v.InitialutilityList",response.getReturnValue());
                    component.set("v.totalRecordsCount", response.getReturnValue().length);  
                    component.set("v.selectedCountOnLoad", response.getReturnValue().length);
                    component.set("v.InitialutilityListSet",true);  
                }
                
                var uaWrapper = response.getReturnValue();
                var utilityList = [];
                var utilityStatusList = [];
                var flags = [], output = [], l = uaWrapper.length, i;
                for( i=0; i<l; i++) {
                    if( flags[uaWrapper[i].UtilityName]) continue;
                    flags[uaWrapper[i].UtilityName] = true;
                    utilityList.push(uaWrapper[i]);
                }
                
                if(component.get("v.bNoRecordsFound")==false){
                    var flags = [], output = [], l = uaWrapper.length, i;
                    for( i=0; i<l; i++) {
                        if( flags[uaWrapper[i].UAcc.Status__c]) continue;
                        flags[uaWrapper[i].UAcc.Status__c] = true;
                        utilityStatusList.push(uaWrapper[i]);
                    }  
                    component.set("v.utilityList",utilityList);
                    component.set("v.utilityStatusList",utilityStatusList);    
                    component.set("v.bNoRecordsFound",true);
                }
                if(response.getReturnValue().length <= 0){
                    
                    component.set("v.ShowTable",false);
                    //component.set("v.bNoRecordsFound",true);
                }
                
                var setSelected = component.get('c.handleSelectedContacts');
            $A.enqueueAction(setSelected);
                component.set("v.selectedContacts",response.getReturnValue());
                
                
            }
        });
        $A.enqueueAction(action);
    },
    
    ApplyFilterHelper: function(component,event,helper, fieldname,selectedState){
        component.set("v.spinner", true); 
        var UAList = component.get("v.InitialutilityList");
        var UtilitiesSelected = component.get("v.FilteredutilityList");
        var FilteredutilityStatusList = component.get("v.FilteredutilityStatusList");
        var utilityList = component.get("v.utilityList");
        
        if(FilteredutilityStatusList.length <=  0){
            FilteredutilityStatusList = component.get("v.utilityStatusList");
        }
        
        
        var action = component.get("c.CreateOpptywithUAOs");
        action.setParams({  
            'UAList' : UAList,
            'UtilitiesSelected' : utilityList,
            'UtilitiesWithStatusFilter' : FilteredutilityStatusList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.PaginationList",response.getReturnValue());
                component.set("v.UAList",response.getReturnValue());
                // utilityList
                var responseUALst = response.getReturnValue();
                var CountofUA = []; 
                for(var i=0 ; i< responseUALst.length; i++){
                    if(responseUALst[i].defaultCheckbox == true){
                        CountofUA.push(responseUALst[i]);
                    }
                }
                
                component.set("v.openFilterModal", false);
                component.set("v.selectedCount",CountofUA.length);
                component.set("v.FilteredutilityList",utilityList) 
                component.set("v.selectedContacts",CountofUA) ;
                component.set("v.InitialutilityList2",response.getReturnValue()) ;
                component.set("v.spinner", false);
                
                
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    buildData : function(component, helper) {
        component.find("selectAll").set("v.value",false);   
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        
        component.set("v.totalPages", Math.ceil( component.get("v.InitialutilityList2").length/component.get("v.pageSize")));
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.InitialutilityList2");
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
        component.set('v.showSpinner', false);
    }
})