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
                component.set("v.isSelectAll",true);
                //component.set("v.UAList",response.getReturnValue());
              //  component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
               // component.set("v.totalRecordsCount", response.getReturnValue().length);
                
                component.set("v.PaginationList", response.getReturnValue());
                component.set("v.selectedContacts",response.getReturnValue());
                component.set("v.spinner", false);
                component.set("v.InitialutilityList2",response.getReturnValue());  
                if(component.get("v.InitialutilityListSet")==false){
                    component.set("v.InitialutilityList",response.getReturnValue());
                    
                    component.set("v.selectedCount",response.getReturnValue().length);
                    component.set("v.isSelectAll",true);
                    component.set("v.totalRecordsCount", response.getReturnValue().length);  
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
                component.set("v.isSelectAll",true);
                //helper.buildData(component, helper);
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
                 component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
                component.set("v.totalRecordsCount", response.getReturnValue().length);
                component.set("v.isSelectAll",true);
                helper.buildData(component, helper);
            }
            component.set("v.spinner", false);
        });
        $A.enqueueAction(action);
    },
    buildData : function(component, helper) {
        
        //component.find("selectAll").set("v.value",false);   
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        
        component.set("v.totalPages", Math.ceil( component.get("v.InitialutilityList2").length/component.get("v.pageSize")));
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.InitialutilityList2");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(allData[x]){
                allData[x].defaultCheckbox = true;
                data.push(allData[x]);
            }
        }
        console.log('pageSize'+component.get("v.totalRecordsCount"));
        console.log('pageSize'+data.length);
        component.set("v.PaginationList", data);
        if(pageSize == 'All'){
        component.set("v.selectedCount",pageSize);
        }
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
    },
    
    CreateOpportunityAndPR : function(component,event,helper,PricingRequest){
        
		
        var UAList = [];
        var CPMUser = component.get("v.selectedUserId");
        var selectedContacts = component.get("v.selectedContacts");
        console.log('user->'+JSON.stringify(PricingRequest));
             var result = component.get("v.selectedContacts");
        for(var i=0;i<result.length;i++){
            UAList.push(result[i].UAcc);
        }
        
       /*    var flags = [], output = [], l = selectedContacts.length, i;
            for( i=0; i<l; i++) {
                if( flags[selectedContacts[i].Id]) continue;
                flags[selectedContacts[i].Id] = true;
                UAList.push(selectedContacts[i].UAcc);
            }*/
        
       
      
        var action = component.get("c.CreatePR");
       // alert('PricingRequest=='+JSON.stringify(PricingRequest));
        action.setParams({  
            'UAList' : UAList,
            'PricingRequest' : PricingRequest,
            'Opp' : component.get("v.recordId"),
            'CPMUser':CPMUser,
            'checkRequestType' : component.get("v.RequestTypevalue"),
            'contractId': component.get("v.contractId")
        });
        action.setCallback(this, function(response) {
            //alert('PricingRequest=='+JSON.stringify(response.getError()));
            var state = response.getState();
            if (state === "SUCCESS"){
                $A.get('e.force:refreshView').fire();
               
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Congratulations!",
                        "type" : "success",
                        "message": "Pricing Request has been Created"
                    });
                    toastEvent.fire();
                 $A.get("e.force:closeQuickAction").fire();
            }
            else{
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "We hit a snag!",
                        "type" : "error",
                        "message": 'Required field missing'
                    });
                    toastEvent.fire();
                
            }
        });
        $A.enqueueAction(action);
	},
    getBillType : function(component, helper) {
    //Get Bill type
            var action3 = component.get("c.getBillType");
            action3.setParams({  
                'UAList' :component.get("v.selectedContacts"),
            });
            action3.setCallback(this, function(a) {
                console.log('FinalBillType'+JSON.stringify(a.getReturnValue()));
               component.set("v.BillType",a.getReturnValue());
                var BillTypeVal = a.getReturnValue();
                component.set("v.BillTypeVal",BillTypeVal[0]);
                component.set("v.NoBillTypeAvailable",false);
                window.setTimeout(
                $A.getCallback( function() {
               // component.find("selectBillType").set("v.value", BillTypeVal[0]);
                    }),0);
            });
            $A.enqueueAction(action3);
    }
})