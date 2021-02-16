({
    doInit: function(component, event, helper) {
       
        helper.addChangeRequestRecord(component, event);
        component.set("v.spinner", true);
		helper.fetchPickListValueBT(component, event);
        helper.fetchPickListValueIBT(component, event);
        var actionOne = component.get("c.GetUAOsandState");
        actionOne.setParams({  
            'recordId' :component.get("v.OppId")
            
        });
        actionOne.setCallback(this, function(a) {
            var result = a.getReturnValue();
            
            console.log('UAO-->'+JSON.stringify(result.UAO));
            helper.getProductFamily(component, event, helper,result.State);
            component.set("v.selectedContacts",result.UAO);
            component.set("v.State",result.State);
        });
        $A.enqueueAction(actionOne); 
        //Get SaleTypePicklist
        
        var action = component.get("c.SaleType");
        
        var opts=[];
        action.setCallback(this, function(a) {
            console.log(JSON.stringify(a.getReturnValue()));
            component.set("v.SaleType", a.getReturnValue());
            
        });
        $A.enqueueAction(action); 
        
        //Get ProductFamily Picklist
        var action2 = component.get("c.ProductFamily");
        
        var opts=[];
        action2.setCallback(this, function(a) {
            console.log(JSON.stringify(a.getReturnValue()));
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
        
    },
    showInvoiceBillingType: function(component, event, helper) {
        var DuplicateIndexes = [];
         var StorePRList = component.get("v.StorePRList");
        for(var i=0;i<StorePRList.length;i++){
            for(var j=0;j<StorePRList.length;j++){
                if(j!=i){
                    console.log('j->'+j+'->'+JSON.stringify(StorePRList[j]));
                    console.log('i->'+i+'->'+JSON.stringify(StorePRList[i]));
                    
                    if(JSON.stringify(StorePRList[j],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues"]) == JSON.stringify(StorePRList[i],["sobjectType","Product_Lookup__c","Bill_Type__c","Invoice_Billing_Type__c","picklistValues"])){
                   //     component.set("v.duplicateAvailable",true);
                        component.set("v.indexVal",j);
                        DuplicateIndexes.push(j);
                        console.log('DuplicateIndexes--> 62'+DuplicateIndexes);
                      //  StorePRList[j].duplicate = 'yes';
                    }
                }
                    else{
                        component.set("v.duplicateAvailable",false);
                        StorePRList[j].duplicate = 'no';
                    }
                
            }
        }
        for(var k=0;k<DuplicateIndexes.length;k++){
                console.log('DuplicateIndexes--> j'+DuplicateIndexes[k]);
                StorePRList[DuplicateIndexes[k]].duplicate = 'yes';
                component.set("v.duplicateAvailable",true);
            }
        component.set("v.StorePRList",StorePRList);
        component.set("v.indexVal",StorePRList.length);
    },
    CPRcheck: function(component, event, helper) {
        var CPR = component.find("CPR").get("v.value");
        if(CPR==true){
            component.set("v.CreatePricingRequest",false);    
        }
        
        
    },
    
    CreatePricingRequest : function(component, event, helper) {
        console.log('<------CreatePricingRequest------>');
        
        var CPR = component.get("v.CreatePricingRequest");
        var selectedFamily = '';
        var selectedProduct = '';
        var selectedBillType = '';
        var UrgentRequest = false;
        var selectedInvoiceBillingType = "Summary Billing";
        var Notes = '';
        // var StartDate =  new Date(2011,10,30);
        var DueDate =  new Date(2011,10,30);
        var DueDatecheck = component.find("dueDate").get("v.value");
        
        if(typeof DueDatecheck == 'undefined' || DueDatecheck == null || DueDatecheck == ''){
            component.set("v.Errmsg",'Required field missing.')
        }
        
        if(CPR==true){
            
            var UrgentRequest =  component.find("UrgentRequest").get("v.checked");
            var Notes = component.find("Notes").get("v.value");
            // var StartDate = component.find("startDate").get("v.value");
            var DueDate = component.find("dueDate").get("v.value");
            //console.log('StartDate->'+StartDate);
            console.log('DueDate->'+DueDate);
        }
        
        var PricingRequestList = component.get("v.StorePRList");
        /*for(var key in PricingRequestList){
            if(PricingRequestList[key].Bill_Type__c == ''){
                PricingRequestList[key].Bill_Type__c = 'POR';
            }   
        }*/
        //alert(JSON.stringify(PricingRequestList));
        var PricingRequest = {
            PricingRequestList:PricingRequestList,
            BrokerMargin : 0,
            UrgentRequest : UrgentRequest,
            Notes : Notes,
            //  StartDate : StartDate,
            DueDate : DueDate
        };
        console.log('PRequest'+JSON.stringify(PricingRequest));
        console.log('PRequest'+typeof PricingRequest);
        component.set("v.PRequest",PricingRequest);
        console.log('PRequest'+JSON.stringify(component.get("v.PRequest")));
        helper.CreateOpportunityAndPR(component, event, helper,PricingRequest);
        
    },
    
    onProductFamilyChange : function(component, event, helper) {
        //debugger;
        var selectedFamily = event.getSource().get("v.value");
        
        component.set("v.spinner", true);
        //var selectedFamily = component.find("ProductFamily").get("v.value");
        var action = component.get("c.GetProducts");
        var products = [];
        
        action.setParams({  
            'ProductFamily' : selectedFamily,
            'State' : component.get("v.State")
        });
        
        action.setCallback(this, function(a) {
            console.log(JSON.stringify(a.getReturnValue()));
            var DuplicateIndexes = [];
            products = a.getReturnValue();
            var listOfProd = [];
            for ( var key in products ) {
			listOfProd.push({value:products[key].Name, key:products[key].Id});
			}
            var listofPR = component.get("v.StorePRList");
            var index = event.getSource().get("v.name");
            
            if(!$A.util.isEmpty(products)){
                listofPR[index].Product_Lookup__c = listOfProd[0].key;
            }
            listofPR[index].picklistValues = listOfProd;
            component.set("v.StorePRList", listofPR);
            
            var a = component.get('c.showInvoiceBillingType');
            $A.enqueueAction(a);
            
           /* for(var i=0;i<listofPR.length;i++){
            for(var j=0;j<listofPR.length;j++){
                if(j!=i){
                    if(JSON.stringify(listofPR[j]) == JSON.stringify(listofPR[i])){
                       // component.set("v.duplicateAvailable",true);
                        component.set("v.indexVal",j);
                        console.log('167--> j'+j);
                        DuplicateIndexes.push(j);
                       // listofPR[j].duplicate = 'yes';
                    }
                    else{
                        component.set("v.duplicateAvailable",false);
                        listofPR[j].duplicate = 'no';
                    }
                }
            }
        }
            for(var k=0;k<DuplicateIndexes.length;k++){
                console.log('DuplicateIndexes--> j'+DuplicateIndexes[k]);
                listofPR[DuplicateIndexes[k]].duplicate = 'yes';
                component.set("v.duplicateAvailable",true);
            }
           
             component.set("v.StorePRList", listofPR);*/
             component.set("v.spinner", false);
            
        });
        $A.enqueueAction(action); 
        
    },
    handlePrevious:function(component,event,helper){
        var event = component.getEvent("cmpEvent"); 
        //set the response value inside eventResponse of componentEvent attribute   
        event.setParams({
            "eventResponse" : true
        }); 
        
        //fire the event    
        event.fire();
    },
    
    handleComponentEvent:function(component,event,helper){
        
        var response = event.getParam("recordByEvent");
        console.log('User ->'+JSON.stringify(response));
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
        // var StartDate =  new Date(2011,10,30);
        var DueDate =  new Date(2011,10,30);
        var selectedInvoiceBillingType = "Summary Billing";
        
        if(CPR==true){
            var UrgentRequest =  component.find("UrgentRequest").get("v.checked");
            var Notes = component.find("Notes").get("v.value");
            // var StartDate = component.find("startDate").get("v.value");
            var DueDate = component.find("dueDate").get("v.value");

        }
        
        
        
        var PricingRequestList = component.get("v.StorePRList");    
        /*for(var key in PricingRequestList){
            if(PricingRequestList[key].Bill_Type__c == ''){
                PricingRequestList[key].Bill_Type__c = 'POR';
            }   
        }*/
        //alert(JSON.stringify(PricingRequestList));
        var PricingRequest = {
            PricingRequestList :PricingRequestList,
            BrokerMargin : 0,
            UrgentRequest : UrgentRequest,
            Notes : Notes,
            //  StartDate : StartDate,
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
        console.log('collapse->'+collapse);
        if(collapse == true){
            component.set("v.collapse",false); 
            console.log('here false');
        }
        else{
            console.log('here true');
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
         /*var StorePRList1 = component.get("v.StorePRList");
        for(var i=0;i<StorePRList1.length;i++){
            for(var j=0;j<StorePRList1.length;j++){
                if(j!=i){
                    if(JSON.stringify(StorePRList1[j]) == JSON.stringify(StorePRList1[i])){
                        //component.set("v.duplicateAvailable",true);
                        component.set("v.indexVal",j);
                        DuplicateIndexes.push(j);
                        console.log('j->'+j);
                    }
                    else{
                        component.set("v.duplicateAvailable",false);
                        StorePRList1[j].duplicate = 'no';
                    }
                }
            }
        }
        for(var k=0;k<DuplicateIndexes.length;k++){
                console.log('DuplicateIndexes--> j'+DuplicateIndexes[k]);
                StorePRList1[DuplicateIndexes[k]].duplicate = 'yes';
                component.set("v.duplicateAvailable",true);
            }
        component.set("v.StorePRList",StorePRList1);*/
    },
    
})