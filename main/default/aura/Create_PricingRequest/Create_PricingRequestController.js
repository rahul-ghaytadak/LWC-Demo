({
    doInit: function(component, event, helper) {
        if(typeof component.get("v.productId") == 'undefined'){
             helper.getExistingPR(component, event);
        helper.addChangeRequestRecord(component, event);
        component.set("v.spinner", true);
        //helper.fetchPickListValueBT(component, event);
        helper.fetchPickListValueIBT(component, event);
        var actionOne = component.get("c.GetUAOsandState");
        actionOne.setParams({  
            'recordId' :component.get("v.recordId")
            
        });
        actionOne.setCallback(this, function(a) {
            var result = a.getReturnValue();
            
            var disableAction = component.get('c.disableElements');
            $A.enqueueAction(disableAction);
            
            helper.getProductFamily(component, event, helper,result.State);
            component.set("v.selectedContacts",result.UAO);
            //alert(component.get("v.selectedContacts"));
            
            //Get Bill type
            var action3 = component.get("c.getBillType");
            action3.setParams({  
                'UAList' :component.get("v.selectedContacts"),
            });
            action3.setCallback(this, function(a) {
                console.log('FinalBillType'+JSON.stringify(a.getReturnValue()));
                component.set("v.BillType",a.getReturnValue());
                var BillTypeVal = a.getReturnValue();
                component.set("v.BillTypeVal",BillTypeVal[0])
                console.log('FinalBillType'+JSON.stringify(BillTypeVal[0]));
                window.setTimeout(
                    $A.getCallback( function() {
                        component.find("selectBillType").set("v.value", BillTypeVal[0]);
                    }),0);
                if(BillTypeVal == null || BillTypeVal == ''){
                    component.set("v.NoBillTypeAvailable",true);
                }
            });
            $A.enqueueAction(action3);
            //component.set("v.Treatment",result.Treatment);
            // component.set("v.VoluntaryRECs",result.RECS);
            component.set("v.State",result.State);
        });
        $A.enqueueAction(actionOne); 
        //Get SaleTypePicklist
        
        var action = component.get("c.SaleType");
        
        var opts=[];
        action.setCallback(this, function(a) {
            
            component.set("v.SaleType", a.getReturnValue());
            
        });
        $A.enqueueAction(action); 
        
        //Get ProductFamily Picklist
        var action2 = component.get("c.ProductFamily");
        
        var opts=[];
        action2.setCallback(this, function(a) {
            
            component.set("v.ProductFamily", a.getReturnValue());
            var ProductFamily = a.getReturnValue();
            window.setTimeout(
                $A.getCallback( function() {
                    // Now set our preferred value
                    component.find("ProductFamily").set("v.value", ProductFamily[0]);
                }),0);
        });
        $A.enqueueAction(action2); 
        
        helper.getDefaultProducts(component, event);
        var selectedProducta = '';
        console.log('productId-->',component.get("v.productId"));
        if(component.get("v.productId") != null){
            selectedProducta = component.get("v.productId");
            console.log('productId-->',component.get("v.productId"));
            
        }
        else{
         selectedProducta = $A.get("$Label.c.Default_Product");
        }
        component.set("v.productId",selectedProducta);
        var indexa = 0;    
        helper.setVoluntaryPicklists(component, event, helper,selectedProducta,indexa);
    }
        else{
            component.set("v.spinner", true);
            var actionOne1 = component.get("c.GetUAOsandState");
            actionOne1.setParams({  
                'recordId' :component.get("v.recordId")
                
            });
            actionOne1.setCallback(this, function(a) {
                var result = a.getReturnValue();
                component.set("v.selectedContacts",result.UAO);
                var action3 = component.get("c.getBillType");
            action3.setParams({  
                'UAList' :component.get("v.selectedContacts"),
            });
            action3.setCallback(this, function(a) {
                console.log('FinalBillType'+JSON.stringify(a.getReturnValue()));
                component.set("v.BillType",a.getReturnValue());
                var BillTypeVal = a.getReturnValue();
                component.set("v.BillTypeVal",BillTypeVal[0])
                console.log('FinalBillType'+JSON.stringify(BillTypeVal[0]));
                window.setTimeout(
                    $A.getCallback( function() {
                        component.find("selectBillType").set("v.value", BillTypeVal[0]);
                        component.set("v.spinner", false);
                    }),0);
                if(BillTypeVal == null || BillTypeVal == ''){
                    component.set("v.NoBillTypeAvailable",true);
                }
            });
            $A.enqueueAction(action3);
            });
            $A.enqueueAction(actionOne1);    
            
        var StorePRList = component.get("v.StorePRList");
             console.log('--Here-- 170');
                StorePRList.push({
                    'sobjectType': 'Pricing_Request__c',
                    'Product_Lookup__c': component.get("v.PricingListToPass").DefaultProductLookup,
                    'Bill_Type__c':component.get("v.PricingListToPass").BillTypeVal,
                    'Invoice_Billing_Type__c':'Summary Billing',
                    'picklistValues': component.get("v.PricingListToPass").DefaultProduct,
                    'RECSpicklist' : component.get("v.PricingListToPass").VoluntaryRECs,
                    'Treatmentpicklst' : component.get("v.PricingListToPass").Treatment,
                    'Voluntary_RECs_percent__c' :component.get("v.PricingListToPass").voluntaryPercent ,
                    'duplicate':'no'
                });
                component.set("v.ProductFamily",component.get("v.PricingListToPass").prodFamily);
                component.set("v.DefaultProductLookup",component.get("v.PricingListToPass").DefaultProductLookup);
                component.set("v.BillTypeVal",component.get("v.PricingListToPass").BillTypeVal);
                component.set("v.DefaultProduct",component.get("v.PricingListToPass").DefaultProduct);
				component.set("v.VoluntaryRECs",component.get("v.PricingListToPass").VoluntaryRECs);
                component.set("v.InitRECs",component.get("v.PricingListToPass").VoluntaryRECs);
        		component.set("v.Treatment",component.get("v.PricingListToPass").Treatment);
                console.log('--Here-- 182');
        component.set("v.StorePRList", StorePRList);
            
        }
    },
    showInvoiceBillingType: function(component, event, helper) {
        
        
        var DuplicateIndexes = [];
        var StorePRList = component.get("v.StorePRList");
        for(var i=0;i<StorePRList.length;i++){
            for(var j=0;j<StorePRList.length;j++){
                if(j!=i){
                    
                    console.log('90-->'+JSON.stringify(StorePRList[j]));
                    console.log('91-->'+JSON.stringify(StorePRList[i]));            
                    if(JSON.stringify(StorePRList[j],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues","Voluntary_RECs__c","Treatment__c","Voluntary_RECs_percent__c"]) == JSON.stringify(StorePRList[i],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues","Voluntary_RECs__c","Treatment__c","Voluntary_RECs_percent__c"])){
                        
                        component.set("v.indexVal",j);
                        DuplicateIndexes.push(j);
                        
                        
                    }
                }
                else{
                    component.set("v.duplicateAvailable",false);
                    StorePRList[j].duplicate = 'no';
                }
                
            }
        }
        for(var k=0;k<DuplicateIndexes.length;k++){
            
            StorePRList[DuplicateIndexes[k]].duplicate = 'yes';
            component.set("v.duplicateAvailable",true);
        }
        component.set("v.StorePRList",StorePRList);
        component.set("v.indexVal",StorePRList.length);
        var disableAction = component.get('c.disableElements');
        $A.enqueueAction(disableAction);
        var selectedProducta = event.getSource().get("v.value");
        var indexa = event.getSource().get("v.name");
        
        if(selectedProducta.startsWith("01t")){
            helper.setVoluntaryPicklists(component, event, helper,selectedProducta,indexa);
        }
        
    },
    
    
    
    CPRcheck: function(component, event, helper) {
        var CPR = component.find("CPR").get("v.value");
        if(CPR==true){
            component.set("v.CreatePricingRequest",false);    
        }
    },
    
    CreatePricingRequest : function(component, event, helper) {
        component.set("v.spinner", true);
        
        var CPR = component.get("v.CreatePricingRequest");
        var selectedFamily = '';
        var selectedProduct = '';
        var selectedBillType = '';
        var UrgentRequest = false;
        var selectedInvoiceBillingType = "Summary Billing";
        var Notes = '';
        
        var DueDate =  new Date(2011,10,30);
        var DueDatecheck = component.find("dueDate").get("v.value");
        
        if(typeof DueDatecheck == 'undefined' || DueDatecheck == null || DueDatecheck == ''){
            component.set("v.Errmsg",'Required field missing.')
        }
        
        if(CPR==true){
            
            var UrgentRequest =  component.find("UrgentRequest").get("v.checked");
            var Notes = component.find("Notes").get("v.value");
            
            var DueDate = component.find("dueDate").get("v.value");
            
            
        }
        var PricingRequestList = [];
        var RequestType = component.get("v.RequestTypevalue");
        if(RequestType == true){
            var getExistingPR = component.get("v.existingPRList");
            var newPRs = [];
            for (var i = 0; i < getExistingPR.length; i++) {
                if( getExistingPR[i].isChecked == true)
                    newPRs.push(getExistingPR[i]);
            }
            PricingRequestList = newPRs;
        }else{
            PricingRequestList = component.get("v.StorePRList");   
        }
        
        var PricingRequest = {
            PricingRequestList:PricingRequestList,
            BrokerMargin : 0,
            UrgentRequest : UrgentRequest,
            Notes : Notes,
            DueDate : DueDate
        };
        
        component.set("v.PRequest",PricingRequest);
        
        helper.CreateOpportunityAndPR(component, event, helper,PricingRequest);
        
    },
    
    onProductFamilyChange : function(component, event, helper) {
        
        var selectedFamily = event.getSource().get("v.value");
        
        component.set("v.spinner", true);
        
        var action = component.get("c.GetProducts");
        var products = [];
        
        action.setParams({  
            'ProductFamily' : selectedFamily,
            'State' : component.get("v.State")
        });
        
        action.setCallback(this, function(a) {
            
            var DuplicateIndexes = [];
            products = a.getReturnValue();
            var listOfProd = [];
            for ( var key in products ) {
                listOfProd.push(products[key]);
            }
            var listofPR = component.get("v.StorePRList");
            var index = event.getSource().get("v.name");
            
            if(!$A.util.isEmpty(products)){
                listofPR[index].Product_Lookup__c = listOfProd[0].Id;
            }
            listofPR[index].picklistValues = listOfProd;
            component.set("v.StorePRList", listofPR);
            
            var a = component.get('c.showInvoiceBillingType');
            $A.enqueueAction(a);
            
            var indexa = event.getSource().get("v.name");
            var selectedProducta = listofPR[indexa].Product_Lookup__c;
            
            helper.setVoluntaryPicklists(component, event, helper,selectedProducta,indexa);
            
            
        });
        $A.enqueueAction(action); 
        
    },
    handlePrevious:function(component,event,helper){
        var event = component.getEvent("cmpEvent"); 
        
        event.setParams({
            "eventResponse" : true
        }); 
        
        //fire the event    
        event.fire();
    },
    
    handleComponentEvent:function(component,event,helper){
        
        var response = event.getParam("recordByEvent");
        
        component.set("v.selectedUserId",response);
    },
    getToggleButtonValue:function(component,event,helper){
        var checkCmp = component.find("tglbtn").get("v.checked");
        component.set("v.chkboxvalue",checkCmp);
        var CPR = component.get("v.CreatePricingRequest");
        var selectedFamily = '';
        var selectedProduct = '';
        var selectedBillType = '';
        var UrgentRequest = false;
        var Notes = '';
        
        var DueDate =  new Date(2011,10,30);
        var selectedInvoiceBillingType = "Summary Billing";
        
        if(CPR==true){
            var UrgentRequest =  component.find("UrgentRequest").get("v.checked");
            var Notes = component.find("Notes").get("v.value");
            
            var DueDate = component.find("dueDate").get("v.value");
            
        }
        
        
        
        var PricingRequestList = [];
        var RequestType = component.get("v.RequestTypevalue");
        if(RequestType == true){
            var getExistingPR = component.get("v.existingPRList");
            var newPRs = [];
            for (var i = 0; i < getExistingPR.length; i++) {
                if( getExistingPR[i].isChecked == true)
                    newPRs.push(getExistingPR[i]);
            }
            PricingRequestList = newPRs;
        }else{
            PricingRequestList = component.get("v.StorePRList");   
        }   
        
        var PricingRequest = {
            PricingRequestList :PricingRequestList,
            BrokerMargin : 0,
            UrgentRequest : UrgentRequest,
            Notes : Notes,
            DueDate : DueDate
        };
        component.set("v.PRequest",PricingRequest);
        helper.toggleAction(component, event, 'panelOne');
    },
    
    changeDueDate:function(component,event,helper){
        var DueDatecheck = component.find("dueDate").get("v.value");
        if(typeof DueDatecheck == 'undefined' || DueDatecheck == null || DueDatecheck == ''){
            component.set("v.disabletoggle",true);
        }
        else{
            component.set("v.disabletoggle",false);
        }
        
    },
    
    panelOne : function(component, event, helper) {
        
        
        var collapse = component.get("v.collapse");
        
        if(collapse == true){
            component.set("v.collapse",false); 
            
        }
        else{
            
            component.set("v.collapse",true);
        }
        helper.toggleAction(component, event, 'panelOne');
    },
    addRow: function(component, event, helper) {
        helper.addChangeRequestRecord(component, event);
    },
    
    removeRow: function(component, event, helper) {
        var DuplicateIndexes = [];
        var StorePRList = component.get("v.StorePRList");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        StorePRList.splice(index, 1);
        component.set("v.StorePRList", StorePRList);
        
        var a = component.get('c.showInvoiceBillingType');
        $A.enqueueAction(a);
    },
    
    disableElements: function(component, event, helper) {
        var index = component.find("VoluntaryRECs").get("v.name");
        var selectedValue = component.find("VoluntaryRECs").get("v.value");
        var PRlst = component.get("v.StorePRList");
        
        if(selectedValue == 'NA'){
            PRlst[index].Voluntary_RECs_percent__c = null;
            //PRlst[index].Treatment__c = null;
        }
        else{
            PRlst[index].Voluntary_RECs_percent__c = "100";
            //  PRlst[index].Treatment__c = 'Fixed';
        }
        component.set("v.StorePRList",PRlst);
    },
    disableElementsA: function(component, event, helper) {
        
        var PRlst = component.get("v.StorePRList");
        var index = event.getSource().get("v.name");
        
        if(PRlst[index].Voluntary_RECs__c != 'NA'){
            PRlst[index].Voluntary_RECs_percent__c = "100";
        }
        
        
        component.set("v.StorePRList",PRlst);
        var a = component.get('c.showInvoiceBillingType');
        $A.enqueueAction(a);
    },
    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        console.log('selectedHeaderCheck-->'+selectedHeaderCheck);
        var existingPRList = component.get("v.existingPRList");
        console.log('existingPRList.length-->'+existingPRList.length);
        var counter = 0;
        for (var i = 0; i < existingPRList.length; i++) {
            if (selectedHeaderCheck == true  ) {
                existingPRList[i].isChecked = true;
                counter++;
                component.set("v.indexValExistPR", counter);
            }
            else {
                existingPRList[i].isChecked = false;
                component.set("v.indexValExistPR", 0);
            }
        }
        component.set("v.existingPRList",existingPRList);
        if(component.get("v.indexValExistPR") == 0){
            component.set("v.PRvalueLength", true);
        }else{
            component.set("v.PRvalueLength", false);
        }
    },
    checkboxSelect: function(component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        console.log('selectedRec-->'+JSON.stringify(selectedRec));
        var existingPRList = component.get("v.existingPRList");
        var getSelectedNumber = component.get("v.indexValExistPR");
        if (selectedRec == true) {
            getSelectedNumber++;
        } 
        else{
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.indexValExistPR", getSelectedNumber);
        
        // if all checkboxes are checked then set header checkbox with true   
        if (existingPRList.length == component.get("v.indexValExistPR")) {
            component.find("selectAllId").set("v.value", true);
        }else{
            component.find("selectAllId").set("v.value", false);
        }
        if(component.get("v.indexValExistPR") == 0){
            component.set("v.PRvalueLength", true);
        }else{
            component.set("v.PRvalueLength", false);
        }
        
    },
    getToggleRefreshButtonValue : function(component,event,helper){
        var checkCmp = component.find("tglrefresh").get("v.checked");
        component.set("v.RequestTypevalue",checkCmp);
        var existingPRList = component.get("v.existingPRList");
        // if all checkboxes are checked then set header checkbox with true   
        if (existingPRList.length == component.get("v.indexValExistPR")) {
            component.find("selectAllId").set("v.value", true);
        }else{
            component.find("selectAllId").set("v.value", false);
        }
        if(checkCmp == true && component.get("v.indexValExistPR") == 0){
            component.set("v.PRvalueLength", true);
        }else{
            component.set("v.PRvalueLength", false);
        }
    }
})