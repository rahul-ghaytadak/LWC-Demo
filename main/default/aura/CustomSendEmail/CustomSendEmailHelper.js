({
    
    sendHelper: function(component, getEmail, getSubject, getbody) {
        // call the server side controller method 	
		var docIds = [];
        var docs = component.get("v.additionalFiles");
        for(var i=0;i<docs.length;i++)
            docIds.push(docs[i].documentId);
        var selectedtoAdds = component.get("v.selectedToRecords");
        var toAddresses =  component.get("v.toAddressesList");  
        for(var i=0; i<selectedtoAdds.length; i++)
            toAddresses.push(selectedtoAdds[i].Email);
        
        var selectedccAdds = component.get("v.selectedCcRecords");
        var ccAddresses = component.get("v.ccAddressesList");  
        for(var i=0; i<selectedccAdds.length; i++)
           ccAddresses.push(selectedccAdds[i].Email);
        
        console.log('toAddresses' + toAddresses);
        var action = component.get("c.sendMailMethod");
        // set the 3 params to sendMailMethod method   
        action.setParams({
            'mMail': component.get("v.contact").ContactId,
            'whatId' : component.get("v.recordId"),
            'mSubject': getSubject,
            'mbody': getbody,
            'att': component.get("v.attachment"),
            'toAddresses' : toAddresses,
            'ccAddresses' : ccAddresses,
            'additionalFiles' : docIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
        console.log('resp' + JSON.stringify(response.getError()));
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'success',
                    message: 'Email has been sent!',
                });
                toastEvent.fire();
                component.set("v.mailStatus", true);
            }
            else
                component.set("v.errorMessage", response.getError()[0].message);
        });
        $A.enqueueAction(action);
    },
})