({
    doInit : function(component, event, helper) {
        var totalPriceToPass = [];
        var quoteId = component.find("selectQuote").get("v.value");
        var action = component.get("c.getQLIs");
        action.setParams({  
            'quoteId' : component.get("v.oppRecord").SyncedQuoteId,
            'isUpdate': false
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS"){
                var quoteLineItems = response.getReturnValue();
                 
                for(var i=0; i< quoteLineItems.length; i++){
                    quoteLineItems[i].objQLI.Broker_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Broker_Margin_per_unit__c).toFixed(5);
                    quoteLineItems[i].objQLI.Sales_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Sales_Margin_per_unit__c).toFixed(5);
                    totalPriceToPass.push(quoteLineItems[i].objQLI.Total_Unit_Price__c);
                }
                component.set("v.ValidateCreditCheck", quoteLineItems[0].ValidateCreditCheck);
                component.set("v.quoteLineItems", quoteLineItems); 
            }
        });
        $A.enqueueAction(action);  
        var action1 = component.get("c.getQuoteOptions");
        action1.setParams({  
            'recordId' : component.get("v.recordId")
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.quoteOptions", response.getReturnValue()); 
                var resp = response.getReturnValue();
                resp.forEach(function(item){
                    if(item.isSynced){
                        component.set("v.billType", item.BillType);
                    }
                });
                component.set('v.spinner', false);
            }
            else
                component.set('v.spinner', false);
        });
        $A.enqueueAction(action1); 
        
       /* var action2 = component.get("c.TotalPriceValidation");
        action2.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPriceToPass, 'quoteId' :quoteId}); 
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.Validated", response.getReturnValue());           
                component.set("v.selectedTabsoft", "Term");
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action2);*/
        
        
    },
    
    overRideNIMOValidation : function(component, event, helper) {
        var action22 = component.get("c.AllowNIMOValidation");
        action22.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPrice.toFixed(5), 'selectedLineItem' :selectedLineItem}); 
        action22.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.showOverRide", response.getReturnValue());           
                
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action22);
    },
    
    onQuoteChange : function(component, event, helper) {  
        component.set("v.spinner", true);
        var quoteId = component.find("selectQuote").get("v.value");
        var quotes = component.get("v.quoteOptions");
        quotes.forEach(function(item){
            if(item.quoteId == quoteId){
                component.set("v.billType", item.BillType);
            }
        });
        var action = component.get("c.getQLIs");
        action.setParams({  
            'quoteId' : quoteId,
            'isUpdate': true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var quoteLineItems = response.getReturnValue();
                $A.get('e.force:refreshView').fire();
                
                for(var i=0; i< quoteLineItems.length; i++){
                    quoteLineItems[i].objQLI.Broker_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Broker_Margin_per_unit__c).toFixed(5);
                    quoteLineItems[i].objQLI.Sales_Margin_per_unit__c = parseFloat(quoteLineItems[i].objQLI.Sales_Margin_per_unit__c).toFixed(4);
                }
                component.set("v.ValidateCreditCheck", quoteLineItems[0].ValidateCreditCheck);
                component.set("v.quoteLineItems", quoteLineItems); 
                component.set("v.spinner", false);
            }
            else{
                alert(JSON.stringify(response.getError()));
                component.set('v.spinner', false);
            }
            
        });
        $A.enqueueAction(action); 
    },
    checkboxSelect: function(component, event, helper) {
        var quoteLineItems = component.get("v.quoteLineItems");
        var selectedQuoteLineItem = event.getSource().get("v.name");
        var totalPrice = 0;
        var totalPriceToPass = [];
        var selectedLineItem;
        for(var i=0; i< quoteLineItems.length; i++){
            if(quoteLineItems[i].isChecked){
                selectedLineItem = quoteLineItems[i].objQLI
            }
        }
        for(var i=0; i< quoteLineItems.length; i++){
            if(selectedQuoteLineItem == quoteLineItems[i].objQLI.Id ){
                totalPrice = quoteLineItems[i].objQLI.Total_Unit_Price__c;
                
            }
            if(quoteLineItems[i].isChecked){
                totalPrice = quoteLineItems[i].objQLI.Total_Unit_Price__c;
                totalPriceToPass.push(totalPrice.toFixed(5));
                }
        }
        
        console.log('totalPrice-->'+JSON.stringify(component.get("v.quoteLineItems")));
        
        console.log(' quoteLineItems[0]-->'+ totalPrice.toFixed(5));
        
        var action2 = component.get("c.TotalPriceValidation");
        action2.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPriceToPass, 'selectedLineItem' :selectedLineItem}); 
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.Validated", response.getReturnValue());           
                component.set("v.selectedTabsoft", "Term");
                var action22 = component.get("c.AllowNIMOValidation");
        action22.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPrice.toFixed(5), 'selectedLineItem' :selectedLineItem}); 
        action22.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.showOverRide", response.getReturnValue());           
                
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action22);
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action2);
        
        
        //var selectedQuoteLineItem = event.getSource().get("v.name");
        
        /*for(var i=0; i< quoteLineItems.length; i++){
            if(selectedQuoteLineItem != quoteLineItems[i].objQLI.Id ){
                quoteLineItems[i].isChecked = false;
            }
        }*/
        if(quoteLineItems.length > 0){
            component.set("v.hasSelectedQLI", true);
        }
        component.set("v.quoteLineItems", quoteLineItems);
    },
    calculateTotalPrice: function(component, event, helper) {
        console.log('--here--');
        var totalPrice = 0;
        var totalPriceToPass = [];
        var index = event.target.id;
        var margin = event.target.name;
        var quoteLineItems = component.get("v.quoteLineItems");
        var selectedLineItem;
        for(var i=0; i< quoteLineItems.length; i++){
            if(quoteLineItems[i].isChecked){
                selectedLineItem = quoteLineItems[i].objQLI
               // totalPriceToPass.push(parseFloat(quoteLineItems[i].objQLI.Base_Price__c) + ( (parseFloat(quoteLineItems[i].objQLI.Sales_Margin_per_unit__c) + parseFloat(quoteLineItems[i].objQLI.Broker_Margin_per_unit__c)) * parseFloat(quoteLineItems[i].objQLI.POR_Tax_Adjustment__c)))
            
            }
        }
        if(margin == 'brokerMargin')
            quoteLineItems[index].objQLI.Broker_Margin_per_unit__c = parseFloat(event.target.value).toFixed(5);
        if(margin == 'salesMargin')
            quoteLineItems[index].objQLI.Sales_Margin_per_unit__c = parseFloat(event.target.value).toFixed(5);
        quoteLineItems[index].objQLI.Total_Unit_Price__c = parseFloat(quoteLineItems[index].objQLI.Base_Price__c) + ( (parseFloat(quoteLineItems[index].objQLI.Sales_Margin_per_unit__c) + parseFloat(quoteLineItems[index].objQLI.Broker_Margin_per_unit__c)) * parseFloat(quoteLineItems[index].objQLI.POR_Tax_Adjustment__c));
        totalPrice = quoteLineItems[index].objQLI.Total_Unit_Price__c;
        
        
        for(var i=0;i<quoteLineItems.length;i++){
            if(quoteLineItems[i].isChecked){
                totalPriceToPass.push(parseFloat(quoteLineItems[i].objQLI.Base_Price__c) + ( (parseFloat(quoteLineItems[i].objQLI.Sales_Margin_per_unit__c) + parseFloat(quoteLineItems[i].objQLI.Broker_Margin_per_unit__c)) * parseFloat(quoteLineItems[i].objQLI.POR_Tax_Adjustment__c)))
            }
        }
        console.log('totalPrice-->'+totalPrice.toFixed(5));
        var action2 = component.get("c.TotalPriceValidation");
        action2.setParams({ 'OpptyId' : component.get("v.recordId"), 'TotalPriceLst' :totalPriceToPass, 'selectedLineItem' :selectedLineItem}); 
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('20->'+response.getReturnValue());  
                component.set("v.Validated", response.getReturnValue());           
                component.set("v.selectedTabsoft", "Term");
                component.set("v.spinner", false);
            }
        });
        $A.enqueueAction(action2);
        component.set("v.quoteLineItems", quoteLineItems);
    },
    handleNext : function(component, event, helper) {
        var selectedLineItem = [];
        var selectedterms = [];
        component.set('v.spinner', true);
        var quoteLineItems = component.get("v.quoteLineItems");
        for(var i=0; i< quoteLineItems.length; i++){
            if(quoteLineItems[i].isChecked){
                selectedLineItem.push(quoteLineItems[i].objQLI);
                selectedterms.push(quoteLineItems[i].objQLI.Term_Months__c)
            }
        }
        component.set('v.seletedTerm', selectedterms);
        console.log('--180--selectedLineItem-->'+JSON.stringify(selectedLineItem));
        /*component.set('v.accountName', component.get("v.oppRecord").Account_Name__c);
        component.set('v.customerName', component.get("v.customerContactrole").Contact.FirstName);*/
        var action1 = component.get("c.updateQuote");
        action1.setParams({  
            'selectedLineItem' : selectedLineItem
        });
        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('--190--');
                var contactRoles = response.getReturnValue(); 
                for(var i=0; i<contactRoles.length;i++){
                    if(contactRoles[i].Role == 'Decision Maker'){
                        component.set("v.editDM", false);
                        component.set("v.customerContactRole", contactRoles[i]);
                    }
                    if(contactRoles[i].Role == 'Evaluator'){
                        component.set("v.editBroker", false);
                        component.set("v.brokerContactRole", contactRoles[i]);
                    }
                }
                if(component.get("v.customerContactRole") == null || component.get("v.brokerContactRole") == null ){
                    var action = component.get("c.getCustomerContacts");
                    action.setParams({  
                        'oppId' : component.get("v.recordId")
                    });
                    action.setCallback(this, function(response1) {
                        var state = response1.getState();
                        if (state === "SUCCESS"){
                            component.set("v.customerContacts", response1.getReturnValue());
                        }
                    });
                    $A.enqueueAction(action);
                }
                component.set("v.showScreen1", false);
                component.set("v.contactRoles", response.getReturnValue()); 
                
                component.set('v.spinner', false);
            }
            else
                component.set('v.spinner', false);
        });
        $A.enqueueAction(action1);
    },
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire() 
    },
    
    goToValidationScreen : function(component, event, helper){  
        component.set('v.spinner', true);
        var Optionselected = '';
        Optionselected = component.find("agreementDelivery").get("v.value");
       
        var action1 = component.get("c.Acc_contractValidation");
        action1.setParams({  
            'OpptyId' : component.get("v.recordId"),
            'Optionselected' : Optionselected
        });
        action1.setCallback(this, function(response1) {
            var state = response1.getState();
            if (state === "SUCCESS"){
                
                var Opp = response1.getReturnValue();
                if(Opp.missingLstUA.length > 0){
                     component.set("v.missedFields",Opp.missingLstUA.toString());
                }
                component.set("v.optionSelected",component.find("agreementDelivery").get("v.value"));
                component.set("v.Opp",Opp);
                component.set("v.showValidationScreen",true);
                component.set("v.showScreen1",false);
                component.set("v.showScreen2", false);
                component.set("v.showScreen3", true);
                
            }
            else{
                component.set('v.spinner', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "We hit a Snag!",
                    "type" : "error",
                    "message": "There is no related contact on opportunity's Account."
                });
                toastEvent.fire();
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action1);
    },
    
    doRefresh : function(component, event, helper){  
        component.set('v.spinner', true);
        var Optionselected = '';
        Optionselected = component.get("v.optionSelected");
       
        var action1 = component.get("c.Acc_contractValidation");
        action1.setParams({  
            'OpptyId' : component.get("v.recordId"),
            'Optionselected' : Optionselected
        });
        action1.setCallback(this, function(response1) {
            var state = response1.getState();
            if (state === "SUCCESS"){
                
                var Opp = response1.getReturnValue();
                console.log('-->',component.get("v.optionSelected"));
                component.set("v.Opp",Opp);
                component.set("v.showValidationScreen",true);
                component.set("v.showScreen1",false);
                component.set("v.showScreen2", false);
                component.set("v.showScreen3", true);
                
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action1);
    },
    
    refresht : function(component, event, helper){  
        component.set('v.spinner', true);
        var Optionselected = '';
        Optionselected = component.get("v.optionSelected");
       
        var action1 = component.get("c.Acc_contractValidation");
        action1.setParams({  
            'OpptyId' : component.get("v.recordId"),
            'Optionselected' : Optionselected,
            'forcedValid' : true
        });
        action1.setCallback(this, function(response1) {
            var state = response1.getState();
            if (state === "SUCCESS"){
                
                var Opp = response1.getReturnValue();
                console.log('-->',component.get("v.optionSelected"));
                component.set("v.Opp",Opp);
                component.set("v.showValidationScreen",true);
                component.set("v.showScreen1",false);
                component.set("v.showScreen2", false);
                component.set("v.showScreen3", true);
                
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action1);
    },
    
    handleNextScreen2: function(component, event, helper){
        component.set('v.spinner', true);
        console.log('--329--');
        var action = component.get("c.secondScreenExit");
        action.setParams({  
            'oppId' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response->'+ response.getState());
            if (state === "SUCCESS"){
               component.set("v.showScreen3", false);
                if(component.get("v.optionSelected") == 'option1'){
                    window.setTimeout(
                        $A.getCallback(function() {
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/apex/echosign_dev1__AgreementTemplateProcess?masterId="+component.get("v.recordId")+"&templateId="+$A.get("{!$Label.c.PFC_Adobe_Template_Id}")
                            });
                            urlEvent.fire();
                        }), 30000
                    );
                }
                else if(component.get("v.optionSelected") == 'option2'){
                    window.setTimeout(
                        $A.getCallback(function() {
                            component.set("v.sendEmail", true);
                            //$A.get("e.force:closeQuickAction").fire();
                            component.set('v.spinner', false);
                        }), 30000
                    );
                }
                    else{
                        window.setTimeout(
                            $A.getCallback(function() {
                                $A.get("e.force:closeQuickAction").fire();
                            }), 30000
                        );
                    }     
             
            }
            else
                component.set("v.validationError",response.getError() );
            
        });
        
        $A.enqueueAction(action);  
    },
    
    editContactRole : function(component, event, helper) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        $A.util.addClass(component.find("Spinner"), "slds-show");
        var edit = component.get("v.editBroker");
        edit = !edit;
        if(edit == false){
            helper.updateContactRoleHelper(component,component.get("v.selectedBrokerContact").Id, component.get("v.brokerContactRole"), 'Evaluator' )
        }
        else
            component.set('v.editBroker', edit);
        
    },
    editContactRoleCustomer: function(component, event, helper) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        $A.util.addClass(component.find("Spinner"), "slds-show");
        var edit = component.get("v.editDM");
        edit = !edit;
        if(edit == false){
            helper.updateContactRoleHelper(component,component.get("v.selectedCustomerContact").Id, component.get("v.customerContactRole"), 'Decision Maker' )
        }
        else
            component.set('v.editDM', edit);
    },
    sendEmail: function(component, event, helper){
        var sendEmailCmp = component.find('sendEmailCmp');
        sendEmailCmp.sendEmail();
    },
    cancelEdit: function(component, event, helper){
        component.set("v.editDM", false);
    },
    cancelEditBroker: function(component, event, helper){
        component.set("v.editBroker", false);
    },
    
    showToolTip : function(c, e, h) {
        c.set("v.tooltip" , true);
        
    },
    
    HideToolTip : function(c,e,h){
        c.set("v.tooltip" , false);
    },
    
    applyCSS: function(cmp, event) {
        event.target.style.color = 'blue';
    },
    
    allowNext : function(component, event, helper) {
        var allowGenQuote = component.find("CPR").get("v.checked");
        component.set("v.Validated",allowGenQuote);
        component.set("v.showOverRideNew",true);
        component.set("v.showOverRide",false);
    },
    
    allowNextNew : function(component, event, helper) {
        var allowGenQuote = component.find("CPRNew").get("v.checked");
        component.set("v.Validated",allowGenQuote);
        component.set("v.showOverRideNew",true);
        component.set("v.showOverRide",false);
    },
})