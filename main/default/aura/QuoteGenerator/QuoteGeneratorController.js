({
	doInit: function(component, event, helper) {
    },
    
     gotoScreen2: function(component, event, helper) {
        // alert(component.get("v.selectedstoreVolumn"));
        var allRecords = component.get("v.listOfAllAccounts");
        var excludedRecords = [];
        var includedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (!allRecords[i].isChecked && allRecords[i].objAccount.Status__c != 'Not Priced') {
                excludedRecords.push(allRecords[i].objAccount);
            }
            if (allRecords[i].isChecked) {
                includedRecords.push(allRecords[i].objAccount);
            }
        }
        if(excludedRecords != null || includedRecords != null )
            helper.updateExcludedUAOs(component, event, helper, excludedRecords, includedRecords );
        component.set("v.screen1", false);
        component.set("v.screen3", false);
        component.set("v.screen2", true);
    },
     gotoScreen1: function(component, event, helper) {
        component.set("v.screen1", true);
        component.set("v.screen2", false);
        component.set("v.screen3", false);
    },
    gotoScreen3: function(component, event, helper) {
        var objCompB = component.find('compB');
        objCompB.getPS();
        
        component.set("v.screen1", false);
        component.set("v.screen2", false);
        component.set("v.screen3", true);
    },
     gotoScreen2From3: function(component, event, helper) {
        component.set("v.screen1", false);
        component.set("v.screen3", false);
        component.set("v.screen2", true);
    },
     confirmation: function(component, event, helper) {
        var checkCmp = component.find("checkbox");
        component.set("v.confirmation", checkCmp.get("v.value"));
    },
     
})