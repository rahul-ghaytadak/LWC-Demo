({
	init : function(component, event, helper) {
         window.setTimeout(
        $A.getCallback(function () {
            $A.get("e.force:closeQuickAction").fire();
        }), 500
    );
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Record Created Succsessfully...!',
            duration:' 5000',
            type: 'success'
        });
        toastEvent.fire(); 

	},
    doneRendering: function(cmp, event, helper) {
   $A.get("e.force:closeQuickAction").fire();

    }
})