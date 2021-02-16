({
	 buildData : function(component, helper,uaoLst) {
      component.find("selectAll").set("v.value",false);
         if(component.get("v.pageSize") == 'All'){
             component.set("v.PaginationList", uaoLst);
             component.set("v.totalPages",1);
         }
         else{
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.totalPages", Math.ceil( component.get("v.uaoLst").length/component.get("v.pageSize")));
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.uaoLst");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.PaginationList", data);
        
        helper.generatePageList(component, pageNumber);
         }
    },
    
    /*
     * this function generate page list
     * */
    generatePageList : function(component, pageNumber){
        if(component.get("v.pageSize") == 'All'){
            component.set("v.totalPages",1);
        }
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
    
    CreateOpp : function(component, helper){
        component.set('v.showSpinner', true);
        component.set("v.showScreen2",false);
        component.set("v.showScreen3",true);
        component.set("v.showCheckbox",true);
        var UAOsTopass = [];
        var selectedUAOs = component.get("v.selectedContacts");
        for(var i=0;i<selectedUAOs.length;i++){
            UAOsTopass.push(selectedUAOs[i].UAO);
        }
        var action = component.get("c.createOpportunity");
        action.setParams({  
            'recordId' : component.get("v.recordId"),
            'customerAccountid' : component.get("v.selectedBrokerAccount").Id,
            'uaoLst' : UAOsTopass
         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var a = component.get('c.doInitTwo');
                $A.enqueueAction(a);
                component.set('v.showSpinner', false);
                component.set('v.NewOppId', response.getReturnValue());
                //var a = component.get('c.doInit');
                //$A.enqueueAction(a);
                
                
                component.set("v.showScreen2",false);
                component.set("v.showScreen3",false);
                var a = component.get('c.finishMethod');
                $A.enqueueAction(a);
                component.set("v.showScreen1",true);
                component.set('v.selectedUAs', 0);
            }
            else{
                component.set('v.showSpinner', false);
                var errors = response.getError();
                console.log('Errors->'+JSON.stringify(errors));
                component.set("v.errMsg",errors[0].pageErrors[0].message);
            }
        });
        $A.enqueueAction(action);
        
    },
})