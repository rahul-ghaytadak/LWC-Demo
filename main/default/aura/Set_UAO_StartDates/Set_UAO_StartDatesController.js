({
    
    doInit : function(component, event, helper) {
        var allRecords = [];
        allRecords.push('a0tf0000001SgIpAAK','a0tf0000001SgIrAAK');
        var allUAOids = [];
        for(var i=0;i<allRecords.length;i++){
             allUAOids.push(allRecords[i].Id);
        }
     
		var action = component.get("c.fetchUAOList");
       /* var selectedUaos = [];
        selectedUaos.push('a0tf0000001SgIpAAK','a0tf0000001SgIrAAK');*/
        action.setParams({ 'oppId' : component.get("v.recordId"),'SelectedUAOs' : allUAOids}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('65->SUCCESS'+response.getReturnValue());  
                component.set("v.UAOLst",response.getReturnValue());
                        
            }
        });
        $A.enqueueAction(action);
	}
,
    OnDateChange : function(component, event, helper) {
    console.log('20->'+component.get("v.UAOLst"));

    },


    SaveSelectedDates : function(component, event, helper) {
        
        var action = component.get("c.SaveNewStartDates");
        action.setParams({ 'UAOlst' : component.get("v.UAOLst")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('65->SUCCESS');  
                var navigate = component.get("v.navigateFlow");
                navigate("NEXT");
            }
        });
        $A.enqueueAction(action);
        
    }
    
    
})