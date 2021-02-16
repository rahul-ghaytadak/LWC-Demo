({
    doInit : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Customer Account Deleted',
            message: 'Account and its related Utility Accounts Deleted Successfully',
            duration:' 5000',
            type: 'success'
        });
        toastEvent.fire();
    
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/001/o"
        });
        urlEvent.fire();	
    }
})