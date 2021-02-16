({
    CreateOpportunityAndPR : function(component,event,helper,PricingRequestList){
        component.set("v.spinner",true);
        var OpptyId = component.get("v.OppId");
        var accId = component.get("v.recordId");
        var UAList = component.get("v.selectedContacts");
        var CPMUser = component.get("v.selectedUserId");
        var EditStartDates = component.get("v.chkboxvalue");
        console.log('CPMUser->'+CPMUser);
        var action = component.get("c.CreatePR");
       // alert(JSON.stringify(PricingRequestList));
        action.setParams({  
            'UAList' : UAList,
            'PricingRequest' : PricingRequestList,
            'Opp' : component.get("v.OppId"),
            'CPMUser':CPMUser,

        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.spinner",false);
                //$A.get('e.force:refreshView').fire();
                //set the response value inside eventResponse of componentEvent attribute   
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    type:'success',
                    title:'Congratulations',
        message: 'This is a required message',
        messageTemplate: '{1} {0} created!',
        messageTemplateData: ['record', {
            url: '/'+OpptyId,
            label: 'Opportunity',
            }
        ]
    });
                   console.log('accId->'+accId);
                    toastEvent.fire();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": '/'+ accId
                });
                urlEvent.fire();
                
            }
            else{
                var ermsg = component.get("v.Errmsg");
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "We hit a snag!",
                    "type" : "error",
                    "message": ermsg
                });
                toastEvent.fire();
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getProductFamily:function(component,event,helper,State){
        var selectedFamily = component.find("ProductFamily").get("v.value");
        var action = component.get("c.GetProducts");
        var products = [];
        
        console.log('State->'+State);
        action.setParams({  
            'ProductFamily' : 'Fixed',
            'State' : State
        });
        
        action.setCallback(this, function(a) {
            console.log(JSON.stringify(a.getReturnValue()));
            products = a.getReturnValue();
            
            var listOfProd = [];
            for ( var key in products ) {
			listOfProd.push({value:products[key].Name, key:products[key].Id});
			}
            var listofPR = component.get("v.StorePRList");
            //var index = event.getSource().get("v.name");
            
            if(!$A.util.isEmpty(products)){
                listofPR[0].Product_Lookup__c = listOfProd[0].key;
            }
            listofPR[0].picklistValues = listOfProd;
            
            
            component.set("v.StorePRList", listofPR);
            
            
            
            console.log('Products-->'+a.getReturnValue());
           // component.set("v.Product", products);
            component.set("v.spinner", false);
           // component.find("selectProduct").set("v.value", products[0]);
        });
        $A.enqueueAction(action); 
        
        
    },
    
    
    toggleAction : function(component, event, secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
        
    },
    addChangeRequestRecord: function(component, event) {
        
        
        var StorePRList = component.get("v.StorePRList");
        console.log('PRlst->'+JSON.stringify(StorePRList));
        StorePRList.push({
            'sobjectType': 'Pricing_Request__c',
            //'Product_Lookup__r.Family': '',
            'Product_Lookup__c': component.get("v.DefaultProductLookup"),
            'Bill_Type__c':'POR',
            'Invoice_Billing_Type__c':'Summary Billing',
            'picklistValues': component.get("v.DefaultProduct"),
            'duplicate':'no'
        });
        console.log('PRlstNew->'+JSON.stringify(StorePRList));
        component.set("v.StorePRList", StorePRList);
        var a = component.get('c.showInvoiceBillingType');
            $A.enqueueAction(a);
        /*for(var i=0;i<StorePRList.length;i++){
            for(var j=1;j<StorePRList.length;j++){
                if(j!=i){
                    if(JSON.stringify(StorePRList[j]) == JSON.stringify(StorePRList[i])){
                        component.set("v.duplicateAvailable",true);
                        component.set("v.indexVal",j);
                        StorePRList[j].duplicate = 'yes';
                    }
                    else{
                        component.set("v.duplicateAvailable",false);
                    }
                }
            }
        }
        component.set("v.StorePRList",StorePRList);*/
    },
    getDefaultProducts : function(component, event){
       
        //retrive Products
        var action3 = component.get("c.GetProducts");
        var products = [];
        var selectedFamily = 'Fixed';
        action3.setParams({  
            'ProductFamily' : selectedFamily,
            'State' : 'OH'
        });
        
        action3.setCallback(this, function(a) {
            console.log(JSON.stringify(a.getReturnValue()));
            
            products = a.getReturnValue();
            
            
            var listOfProd = [];
            for ( var key in products ) {
			listOfProd.push({value:products[key].Name, key:products[key].Id});
			}
            component.set("v.DefaultProduct", listOfProd);
            var listofPR = component.get("v.StorePRList");
            //var index = event.getSource().get("v.name");
            
            if(!$A.util.isEmpty(products)){
                listofPR[0].Product_Lookup__c = listOfProd[0].key;
                component.set("v.DefaultProductLookup", listOfProd[0].key);
            }
            listofPR[0].picklistValues = listOfProd;
            
            
            component.set("v.StorePRList", listofPR);
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action3); 
        
    },
    fetchPickListValueBT: function(component) {	
        
         var actionAct = component.get("c.getselectOption");
          
        actionAct.setParams({
            "objectType": "Pricing_Request__c",
            "fieldName": "Bill_Type__c"
        });
         
        actionAct.setCallback(this, function(response) {
            
            var state = response.getState();
            var actsRelatedHOP = [];
            var list = response.getReturnValue();
            
            
            component.set("v.BillType", list);
            
        });
        
        $A.enqueueAction(actionAct);
    },
    fetchPickListValueIBT: function(component) {	
        
         var actionAct = component.get("c.getselectOption");
        actionAct.setParams({
            "objectType": "Pricing_Request__c",
            "fieldName": "Invoice_Billing_Type__c"
        });
         
        actionAct.setCallback(this, function(response) {
            
            var state = response.getState(); 
            var list = response.getReturnValue();

           // component.set("v.InvoiceBillingType", list);
            
        });
        
        $A.enqueueAction(actionAct);
    }
    
})