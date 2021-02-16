({
    onblur : function(component,event,helper){
        // on mouse leave clear the listOfSeachRecords & hide the search result component 
        component.set("v.listOfSearchRecords", null );
        component.set("v.SearchKeyWord", '');
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onfocus : function(component,event,helper){
        // show the spinner,show child search result component and call helper function
        $A.util.addClass(component.find("Spinner"), "slds-show");
        component.set("v.listOfSearchRecords", null ); 
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC 
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    
    keyPressController : function(component, event, helper) {
        $A.util.addClass(component.find("Spinner"), "slds-show");
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if(getInputkeyWord.length > 0){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords"); 
        
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Id == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.lstSelectedRecords", AllPillsList);
            }  
        }
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );      
    },
    clearAdd :function(component,event,heplper){
        var selectedPillName = event.getSource().get("v.name");
        var AllPillsList = component.get("v.AddressesList"); 
        
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i] == selectedPillName){
                AllPillsList.splice(i, 1);
                component.set("v.AddressesList", AllPillsList);
            }  
        }
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );      
    },
    
    handleComponentEvent : function(component, event, helper) {
        component.set("v.SearchKeyWord",null);
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var selectedRecordGetFromEvent = event.getParam("recordByEvent");
        listSelectedItems.push(selectedRecordGetFromEvent);
        component.set("v.lstSelectedRecords" , listSelectedItems); 
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open'); 
    },
    defaultContact : function(component, event, helper) {
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open'); 
    },
    keyPress: function( component, event, helper ){
        if(event.which == 13) {
            var listSearch = component.get("v.listOfSearchRecords");
            console.log('listSearch' + listSearch);
            if(!$A.util.isEmpty(listSearch)){
                var listSelectedItems = component.get("v.lstSelectedRecords");
                listSelectedItems.push(listSearch[0]);
                component.set("v.lstSelectedRecords" , listSelectedItems); 
                component.set("v.SearchKeyWord",null);
                component.set("v.listOfSearchRecords", null );    
            }
            else{
                var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                var getInputkeyWord = component.get("v.SearchKeyWord");
                if(!$A.util.isEmpty(getInputkeyWord) && getInputkeyWord.match(regExpEmailformat)){
                    var addList =  component.get("v.AddressesList");
                    addList.push(getInputkeyWord);
                    component.set("v.AddressesList", addList);
                    component.set("v.SearchKeyWord",null);
                    component.set("v.listOfSearchRecords", null );   
                }
            }
        }
    }
})