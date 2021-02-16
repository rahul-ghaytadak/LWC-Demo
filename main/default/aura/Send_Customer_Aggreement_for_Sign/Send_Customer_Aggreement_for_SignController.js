({
	doInit : function(component, event, helper) {

        component.set('v.spinner', true);
        var action1 = component.get("c.Acc_contractValidation");
        action1.setParams({  
            'OpptyId' : component.get("v.recordId"),
            'Optionselected' : 'option1'
        });
        action1.setCallback(this, function(response1) {
            var state = response1.getState();
            if (state === "SUCCESS"){
                
                var Opp = response1.getReturnValue();
                component.set("v.Opp",Opp);
                if(Opp.missingLstUA.length > 0){
                    console.log('16-->'+Opp.missingLstUA.toString());
                     component.set("v.missedFields",Opp.missingLstUA.toString());
                }
             
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action1);
	},
    
    handleNextScreen2: function(component, event, helper){
        
        var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/apex/echosign_dev1__AgreementTemplateProcess?masterId="+component.get("v.recordId")+"&templateId="+$A.get("{!$Label.c.PFC_Adobe_Template_Id}")
                            });
                            urlEvent.fire();
    },
    
    refresht : function(component, event, helper){  
        component.set('v.spinner', true);
        var Optionselected = 'option1';
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
    
    showToolTip : function(c, e, h) {
        c.set("v.tooltip" , true);
        
    },
    
    HideToolTip : function(c,e,h){
        c.set("v.tooltip" , false);
    },
    
    applyCSS: function(cmp, event) {
        event.target.style.color = 'blue';
    }
})