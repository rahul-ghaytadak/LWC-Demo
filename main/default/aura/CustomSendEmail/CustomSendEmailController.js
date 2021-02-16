({
    doInit : function(component, event, helper) {
        var listSelectedItems =  component.get("v.selectedToRecords");
        if(component.get("v.contact") != null || component.get("v.contact") != ''){
            var getSelectRecord = component.get("v.contact").Contact;
            listSelectedItems.push(getSelectRecord);
            component.set("v.selectedToRecords" , listSelectedItems); 
            var childCmp = component.find("toMulti")
            childCmp.defaultContact();
        }
        var action = component.get("c.getEmailTemplate");
        action.setParams({  
            'emailTemplateName' : component.get("v.emailTemplateName"),
            'recordId': component.get("v.recordId"),
            'noOfTerms' : component.get("v.CountofTerms")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var response = response.getReturnValue();
                component.set("v.subject",response.et.Subject );
                var emailBody = '';
                if(component.get("v.contact") != null && component.get("v.contact") != '' && component.get("v.contact") != undefined){
                    emailBody = response.et.HtmlValue.replace("{Broker Contact First Name}", component.get("v.contact").Contact.Name);
                }
                else
                    var emailBody = response.et.HtmlValue.replace("{Broker Contact First Name}", 'the broker');
                emailBody = emailBody.replace("{Customer Account Name}",  component.get("v.accountName"));
                if(component.get("v.customerContact") != null && component.get("v.customerContact") != '' && component.get("v.customerContact") != undefined){
                    emailBody = emailBody.replace("{Customer Contact Full Name}",  component.get("v.customerContact").Contact.FirstName);
                }
                else
                    emailBody = emailBody.replace("{Customer Contact Full Name}", 'the customer');
                emailBody = emailBody.replace("{insert Quote Line Item Term}",  component.get("v.term"));
                emailBody = emailBody.replace("{User first name}", response.userDetails.FirstName );
                component.set("v.body", emailBody);
                component.set("v.attachment", response.cdLst);
                //component.set("v.additionalFiles", response.cdLst);
                component.set("v.userInfo", response.userDetails);
            }
        });
        $A.enqueueAction(action);  
    },
    sendMail: function(component, event, helper) {
        // when user click on Send button 
        // First we get all 3 fields values 	
        component.set("v.errorMessage", null);
        var isValid = false;
        if(component.get("v.contact") != null && component.get("v.contact") != '' && component.get("v.contact") != undefined){
            var getEmail = component.get("v.contact").Contact.Email;
        }
        var getSubject = component.get("v.subject");
        var getbody = component.get("v.body");
        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        if (!$A.util.isEmpty(getEmail) && !getEmail.includes("@")) {
            component.set("v.errorMessage", 'Invalid Broker Email Address');
        }
        else
            isValid = true;
        if(isValid) {
            helper.sendHelper(component, getEmail, getSubject, getbody);
        }
    },
    
    handleUploadFinished: function (cmp, event) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        console.log("Files uploaded : " + JSON.stringify(uploadedFiles));
        cmp.set("v.additionalFiles", uploadedFiles);
    },
    openSingleFile: function(cmp, event, helper) {
        var attId = event.getSource().get("v.name");
        $A.get('e.lightning:openFiles').fire({
            recordIds: [attId]
        });
    }, 
    clearFile: function(cmp, event){
        event.preventDefault();
        var selectedPillName = event.getSource().get("v.name");
        var AllPillsList = cmp.get("v.additionalFiles"); 
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].documentId == selectedPillName){
                AllPillsList.splice(i, 1);
                cmp.set("v.additionalFiles", AllPillsList);
            }  
        }
    },
    clearAttachment: function(cmp, event){
        event.preventDefault();
        var selectedPillName = event.getSource().get("v.name");
        var AllPillsList = cmp.get("v.attachment"); 
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].ContentDocumentId == selectedPillName){
                AllPillsList.splice(i, 1);
                cmp.set("v.attachment", AllPillsList);
            }  
        }
        //cmp.set("v.attachment", null);
    }
})