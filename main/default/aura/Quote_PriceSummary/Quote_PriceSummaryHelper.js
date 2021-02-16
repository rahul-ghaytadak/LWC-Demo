({
    /* doInitHelper funcation to fetch all records, and set attributes value on component load */
    doInitHelper : function(component,event,helper, fieldname){ 
        debugger;
        var sortDir = component.get("v.sort");
        if(sortDir == 'ASC'){
            sortDir = 'DESC';
            component.set("v.arrowDirection", 'arrowdown');
            component.set('v.sort', 'DESC');
        }
        else{
            sortDir = 'ASC';
            component.set("v.arrowDirection", 'arrowup');
            component.set('v.sort', 'ASC');
        }
        var action = component.get("c.getPSRecords");
        action.setParams({  
            'sortType' : sortDir,
            'sortField' : fieldname,
            'recordId' : component.get("v.recordId"),
            'selectedCount':component.get("v.selectedCount"),
            'changedPriceId' :component.get("v.selectedPriceId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                    component.set("v.listOfAllPS", oRes);
                var allRecords = component.get("v.listOfAllPS")
                if(allRecords.length > 0){
                    component.set("v.totalPages", Math.ceil(allRecords.length/component.get("v.pageSize")));
                    component.set("v.listOfAllPS", allRecords);
                    component.set("v.currentPageNumber",1);
                    component.set("v.totalRecordsCount", component.get("v.listOfAllPS").length);
                    helper.buildData(component, helper);
                    
                    
                }else{
                    // if there is no records then display message
                    component.set("v.bNoRecordsFound" , true);
                } 
            }
            else{
                alert('Error...');
            }
        });
        $A.enqueueAction(action);  
    },
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        component.set("v.totalPages", Math.ceil( component.get("v.listOfAllPS").length/component.get("v.pageSize")));
        var allData = component.get("v.listOfAllPS");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        for(var key in data){
            if(data[key].objAccount.Term_months__c == 12){
                
                component.set("v.selectedstoreVolumn", data[key].objAccount.Cumulative_Volume__c);
                //alert(data[key].objAccount.Cumulative_Volume__c);
               //alert(component.get("v.selectedstoreVolumn"));
            }
           /*else {
                component.set("v.selectedstoreVolumn", null);
            }*/
    
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
    // navigate to next pagination record set   
    next : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i = end + 1; i < end + pageSize + 1; i++){
            if(sObjectList.length > i){ 
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]);  
                }
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
   // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
        var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                if(component.find("selectAllId").get("v.value")){
                    Paginationlist.push(sObjectList[i]);
                }else{
                    Paginationlist.push(sObjectList[i]); 
                }
                counter ++;
            }else{
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.PaginationList', Paginationlist);
    },
   
    
})