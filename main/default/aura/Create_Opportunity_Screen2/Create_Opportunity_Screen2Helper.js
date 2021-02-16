({
    CreateOpportunityAndPR : function(component,event,helper,PricingRequest){
        component.set("v.spinner",true);
        var UAList = component.get("v.selectedContacts");
        var CPMUser = component.get("v.selectedUserId");
        var CreatePricingReq = component.get("v.CreatePricingRequest");
        var AccId = component.get("v.selectedBrokerAccount").Id;
        var ContactId = component.get("v.selectedBrokerContact").Id;
        // alert('Acc'+JSON.stringify(CPMUser));
        if(AccId != null && ContactId != null){
            if(PricingRequest.DueDate != ''){
                var UAccLst = [];
                for(var i=0 ; i<UAList.length ; i++){
                    UAccLst.push(UAList[i].UAcc);
                }
                
                var action = component.get("c.CreateUAccs");
                action.setParams({  
                    'UAList' : UAccLst,
                    'PricingRequest' : PricingRequest,
                    'CreatePricingReq' : CreatePricingReq,
                    'CPMUser':CPMUser,
                    'AccId':AccId,
                    'ContactId':ContactId,
                    'contractId':component.get("v.contractId")
                });
                action.setCallback(this, function(response) {
                    // alert(JSON.stringify(response.getError()));
                    var state = response.getState();
                    var errMsg = '';
                    if (state === "SUCCESS"){
                        errMsg = response.getReturnValue().exceptionMsg;
                        if(errMsg!=''){
                            
                            component.set("v.spinner",false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "We hit a snag!",
                                "type" : "error",
                                "message": errMsg
                            });
                            toastEvent.fire();
                        }
                        else{
                            component.set("v.spinner",false);
                            component.set("v.ShowFirstScreen",false);
                            component.set("v.ShowSecondScreen",true);
                            var event = component.getEvent("cmpEvent"); 
                            var OpptyId = response.getReturnValue().OppId;
                            
                            console.log('errMsg-->'+errMsg);
                            component.set("v.OppId",OpptyId);
                            var accId = component.get("v.recordId");
                            //set the response value inside eventResponse of componentEvent attribute   
                            /*    event.setParams({
                    "eventResponse" : false
                }); 
                
                //fire the event    
                event.fire();*/
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
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
                            if(component.get("v.CreatePricingRequest") == false){
                                toastEvent.fire();
                                var urlEvent = $A.get("e.force:navigateToURL");
                                urlEvent.setParams({
                                    "url": '/'+ accId
                                });
                                urlEvent.fire();
                                // $A.get("e.force:closeQuickAction").fire();
                                //$A.get('e.force:refreshView').fire();
                                if(component.get("v.reloadPage"))
                                    window.location.reload();
                            }else{
                                component.set("v.ShowCreatePricingRequest",true);
                                component.set("v.spinner",false);
                            }
                        }
                    }
                    
                    
                });
                $A.enqueueAction(action);
            }
            else{
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Pricing Request Section",
                    "type" : "error",
                    "message": "Due Date should not be blank."
                });
                toastEvent.fire();
            }
        }
        else{
            component.set("v.spinner",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Broker Section is blank",
                "type" : "error",
                "message": "Broker Account and Broker Contact should not be blank."
            });
            toastEvent.fire();
        }
    }
})