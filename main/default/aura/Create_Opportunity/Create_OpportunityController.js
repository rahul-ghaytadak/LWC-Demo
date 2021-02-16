({
   
    doInit : function(component, event, helper) { 
        var action = component.get("c.getStatePicklist");
        action.setParams({  
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var statePicklst = new Set(response.getReturnValue());
                var filteredArray = Array.from(statePicklst);
                component.set("v.spinner", true);
                if(filteredArray.length == 1){
                    
                    
                    component.set("v.StatePicklist",filteredArray);
                    component.set("v.State",filteredArray[0]);
                    component.set("v.stateSelected",true);
                    helper.doInitHelper(component, event, helper, 'Utility__r.Name',filteredArray[0] );
                    component.set("v.ShowTable",true);
                }
                else{
                    console.log('Add None',filteredArray.unshift("--None--"));
                    component.set("v.StatePicklist",filteredArray);
                    component.set("v.spinner", false);
                }
                
            }
        });
        $A.enqueueAction(action);
        var custAcc = component.get("v.CustomerAcc");
        if(custAcc.Broker__c != ''){
            component.set("v.brokerId",custAcc.Broker__c);
        }
        
    },
    openFilterModal: function(component, event, helper) {
        component.set("v.openFilterModal", true);
        
        
    },
    
    openStatusFilterModal: function(component, event, helper) {
        component.set("v.openStatusFilterModal", true);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.openFilterModal", false);
        component.set("v.openStatusFilterModal", false);
        
    },
    closeWarningModel: function(component, event, helper) {
        component.set("v.ShowWarning", false);
    },
    
    onStateChange : function(component, event, helper) {
        var emptyLst = [];
        
        component.set("v.selectedContacts",emptyLst);
        component.set("v.FilteredutilityStatusList",emptyLst);
        component.set("v.spinner", true);
        component.set("v.currentPageNumber", 1);
        component.set("v.totalPages", 1);
        component.set("v.pageSize", 'All');
        component.set("v.selectedCount",0);
        component.set("v.ShowTable",true);
        component.set("v.stateSelected",true);
        component.set("v.bNoRecordsFound",false);
        component.set("v.StopShowWarning",false);
        component.set("v.InitialutilityListSet",false);
        
        var selectedState = component.find("selectState").get("v.value");
        component.set("v.State",selectedState);
        
        if(selectedState=='--None--'){
            component.set("v.ShowTable",false);
        }
        
        
        helper.doInitHelper(component, event, helper, 'Utility__r.Name',selectedState );
        
    } ,
    
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
            for(i=0;i<filteredArray.length;i++){
                
                if(typeof filteredArray[i].UAcc.Requested_Start_Date__c==='undefined')
                {
                    component.set("v.StartDateSet",false);
                }
            }
            component.set("v.selectedContacts",filteredArray);
            
            component.set("v.selectedCount",filteredArray.length);
        }
        else{ 
            for(var i=0; i<checkContact.length; i++){
                checkContact[i].set("v.value",false);
            }
            var getSelected = component.get("v.selectedContacts");
            var finlLst = [];
            for(var i=0 ;i<getSelected.length;i++){
                if(getSelected[i].defaultCheckbox == true){
                    finlLst.push(getSelected[i]);
                }
            }
            component.set("v.selectedCount",finlLst.length);
            component.set("v.selectedContacts",finlLst);
        }
        
        
    },
    
    //Process the selected contacts
    handleSelectedContacts: function(component, event, helper) {
        console.log('handleSelectedContacts');
        var selectedContacts = [];
        var NewselectedContacts = [];
        selectedContacts = component.get("v.selectedContacts");
        var checkvalue = component.find("checkContact");
        var TotalLength = component.get("v.selectedCountOnLoad");
        if(!Array.isArray(checkvalue)){
            console.log('Array.isArray(checkvalue)');
            if (checkvalue.get("v.value") == true) {
                
                selectedContacts.push(checkvalue.get("v.errors"));
            }
            
            var flags = [], output = [], l = selectedContacts.length, i;
            for( i=0; i<l; i++) {
                if( flags[selectedContacts[i].Id]) continue;
                flags[selectedContacts[i].Id] = true;
                NewselectedContacts.push(selectedContacts[i]);
            }
        }
        else{
            
            for (var i = 0; i < checkvalue.length; i++) {
                
                if (checkvalue[i].get("v.value") == true) {
                    
                    selectedContacts.push(checkvalue[i].get("v.errors"));
                }
            }
            var flags = [], output = [], l = selectedContacts.length, i;
            for( i=0; i<l; i++) {
                if( flags[selectedContacts[i].Id]) continue;
                flags[selectedContacts[i].Id] = true;
                NewselectedContacts.push(selectedContacts[i]);
            }
        }
        var UpdatedUALst = [];
        for(i=0;i<NewselectedContacts.length;i++){	
            if(NewselectedContacts[i].defaultCheckbox == true){	
                UpdatedUALst.push(NewselectedContacts[i]);	
            }	
        }
        component.set("v.selectedCount",UpdatedUALst.length);
        component.set("v.selectedContacts",UpdatedUALst);
        
        var AllUAs = component.get("v.PaginationList");
        for(i=0;i<AllUAs.length;i++){
            
            if(AllUAs[i].defaultCheckbox == true){
                if(typeof AllUAs[i].UAcc.Requested_Start_Date__c==='undefined' || AllUAs[i].UAcc.Requested_Start_Date__c=='' || AllUAs[i].UAcc.Requested_Start_Date__c==null)
                {
                    
                    component.set("v.StartDateSet",false);
                    break;
                }else{
                    component.set("v.StartDateSet",true);
                }
                
                
            }
        }
        
        if(TotalLength!=UpdatedUALst.length){
            component.set("v.isSelectAll",false);
        }
        if(TotalLength==UpdatedUALst.length){
            component.set("v.isSelectAll",true);
        }
        
    },
    
    handleDeSelected: function(component, event, helper) {
        component.set("v.isSelectAllModal",false);
        var UAList = component.get("v.utilityList");
        var isSelectAll = component.get("v.isSelectAll");
        
        var selectedContacts = [];
        
        if(isSelectAll){
            selectedContacts = UAList;
        }
        else{
            var k = 0;
            for (var i=0; i<UAList.length; i++){
                var c = UAList[i];
                
                if(c.isSelected) {
                    selectedContacts[k] = c;
                    k++; 
                }     
            }
        }
        
        component.set("v.FilteredutilityList",selectedContacts)
        
    },
    
    handleDeSelectedStatus: function(component, event, helper) {
        component.set("v.isSelectAllModalStatus",false);
        var UAList = component.get("v.utilityStatusList");
        var isSelectAll = component.get("v.isSelectAll");
        
        var selectedContacts = [];
        
        if(isSelectAll){
            selectedContacts = UAList;
        }
        else{
            var k = 0;
            for (var i=0; i<UAList.length; i++){
                var c = UAList[i];
                
                if(c.isSelectedStatus) {
                    selectedContacts[k] = c;
                    k++; 
                }     
            }
        }
        
        component.set("v.FilteredutilityStatusList",selectedContacts)
        
    },
    
    
    CreateOppty: function(component, event, helper) {
        component.set("v.spinner",true);
        /*var lstToSend = component.get("v.PaginationList");
        var finalLst = [];
        for(var i=0;i<lstToSend.length;i++){
            if(lstToSend[i].defaultCheckbox == true){
                finalLst.push(lstToSend[i]);
            }
        }
        component.set("v.selectedContacts",finalLst);*/
        component.set("v.ShowFirstScreen",false);
        component.set("v.ShowSecondScreen",true);
        component.set("v.spinner",false);   
        
    },
    
    sortByAUName: function(component, event, helper) {
        var selectedState = component.find("selectState").get("v.value");
        component.set("v.selectedTabsoft", 'Utility');
        var UtilitiesSelected = component.get("v.PaginationList");
        
        helper.doInitHelper(component, event, helper, 'Utility__r.Name',selectedState,UtilitiesSelected );
        
    },
    sortByUANumber: function(component, event, helper) {
        var selectedState = component.find("selectState").get("v.value");
        component.set("v.selectedTabsoft", 'UANumber');
        var UtilitiesSelected = component.get("v.PaginationList");
        helper.doInitHelper(component, event, helper, 'Name',selectedState,UtilitiesSelected );
    },
    sortByUAState: function(component, event, helper) {
        var selectedState = component.find("selectState").get("v.value");
        component.set("v.selectedTabsoft", 'UAState');
        var UtilitiesSelected = component.get("v.PaginationList");
        helper.doInitHelper(component, event, helper, 'Status__c ',selectedState,UtilitiesSelected );
    },  
    changestartDate: function(component, event, helper) {
        
        var UALst = [];
        var UpdatedUALst = [];
        var nullLst = [];
        var CommonStartDate = component.get("v.startDate");
        
        UALst = component.get("v.PaginationList");
        for (var i = 0; i < UALst.length; i++) {
            UALst[i].UAcc.Requested_Start_Date__c = CommonStartDate; 
            UpdatedUALst.push(UALst[i]);   
        }
        
        component.set("v.TestList",UpdatedUALst);
        if(UpdatedUALst.length > 100){
            component.set("v.PaginationList",nullLst);    
            var a = component.get('c.doInitTwo');
            $A.enqueueAction(a);
        }
        else{
            component.set("v.PaginationList",UpdatedUALst);
            component.set("v.StartDateSet",true);
        }
        var setSelected = component.get('c.changestartDateSeperately');
            $A.enqueueAction(setSelected);
    },
    
    doInitTwo: function(component, event, helper) {
        component.set("v.spinner", true);
        var action = component.get("c.SetPgLst");
        action.setParams({  
            'UAList' : component.get("v.TestList")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.PaginationList",response.getReturnValue());
                component.set("v.StartDateSet",true);
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    changestartDateSeperately: function(component, event, helper) {
        
        var checkFirst = component.get("v.StartDateSet");
        
        var UpdatedUALst = [];
        
        UpdatedUALst =  component.get("v.selectedContacts");
        for(var i=0; i<UpdatedUALst.length; i++){
            
            if(UpdatedUALst[i].defaultCheckbox == true && (typeof UpdatedUALst[i].UAcc.Requested_Start_Date__c==='undefined' || UpdatedUALst[i].UAcc.Requested_Start_Date__c=='' || UpdatedUALst[i].UAcc.Requested_Start_Date__c==null)){
                component.set("v.StartDateSet",false);
                
                break; 
                
            }
            else{
                
                component.set("v.StartDateSet",true); 
            }
        }
      /*  var setSelected = component.get('c.handleSelectedContacts');
            $A.enqueueAction(setSelected);*/
        
        var datevar = event.getSource().get("v.value");
        console.log('datevar-->'+datevar);
        if(datevar == null){
            component.set("v.StartDateSet",false);
        }
        
    },
    ApplyFilter: function(component, event, helper) {
        
        helper.ApplyFilterHelper(component, event, helper)
        component.set("v.openStatusFilterModal", false);
    },
    
    ShowWarningModal: function(component, event, helper) {
        var stateSelectedFirstTime = component.get("v.stateSelectedFirstTime");
        var selectedState = component.find("selectState").get("v.value"); 
        var ShowWarning = component.get("v.ShowWarning"); 
        if(stateSelectedFirstTime==false && ShowWarning== false&& selectedState !='--None--'){
            component.set("v.stateSelectedFirstTime",true); 
            
            component.set("v.CheckState",selectedState);
        }
        
        
        if(stateSelectedFirstTime==true && selectedState !='--None--'){
            if(component.get("v.StopShowWarning")==false && component.get("v.selectedCount")!=0){
                component.set("v.ShowWarning",true); 
            }
        }
    },
    
    YescloseWarningModel: function(component, event, helper) {
        
        component.set("v.StopShowWarning",true);
        component.set("v.ShowWarning", false);
    },
    
    handleEvent : function(component, event, helper) 
    {
        var response = event.getParam("eventResponse"); 
        if(response == false){
            $A. get("e. force:closeQuickAction"). fire();
        }
        else{
            component.set("v.ShowFirstScreen",true);
            component.set("v.ShowSecondScreen",false);
        }
    },
    
    SelectAllUtilities : function(component, event, helper){
        var isSelectAllModal = component.get("v.isSelectAllModal");
        if(isSelectAllModal == true){
            var utilityList = component.get("v.utilityList");
            var updatedUtilityList = [];
            for(var i=0; i<utilityList.length; i++){
                utilityList[i].isSelected = true;
                updatedUtilityList.push(utilityList[i]);
            }
            
        }
        else{
            var utilityList = component.get("v.utilityList");
            var updatedUtilityList = [];
            for(var i=0; i<utilityList.length; i++){
                utilityList[i].isSelected = false;
                updatedUtilityList.push(utilityList[i]);
            }
        }
        
        component.set("v.utilityList",updatedUtilityList);
    },
    
    SelectAllStatusUtilities : function(component, event, helper){
        var isSelectAllModal = component.get("v.isSelectAllModalStatus");
        if(isSelectAllModal == true){
            var utilityList = component.get("v.utilityStatusList");
            var updatedUtilityList = [];
            for(var i=0; i<utilityList.length; i++){
                utilityList[i].isSelectedStatus = true;
                updatedUtilityList.push(utilityList[i]);
            }
            
        }
        else{
            var utilityList = component.get("v.utilityStatusList");
            var updatedUtilityList = [];
            for(var i=0; i<utilityList.length; i++){
                utilityList[i].isSelectedStatus = false;
                updatedUtilityList.push(utilityList[i]);
            }
        }
        
        component.set("v.utilityStatusList",updatedUtilityList);
        component.set("v.FilteredutilityStatusList",updatedUtilityList);
        
    },
    
    UpdateColor : function(component, event, helper){
        var img = component.find('imgOver');
        $A.util.addClass(abc,'orangeColor');
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
    }
})