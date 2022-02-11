({
	doInit : function(component, event, helper) {
        
	},
    
    grantExt : function(component, event, helper) {
        var partyGivenExt = document.getElementById("partyExtId").value;
        var action = component.get("c.updateExtenionForParties");
        action.setParams({
            recordId: component.get("v.recordId"),
            partyGivenExt: partyGivenExt,
            daysExtended: component.get("v.daysExtended"),
        });
        action.setCallback(this, function(a) { 
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.isModalOpen",true);
                if(a.getReturnValue().Days_Remaining__c <= 5)
                {  
                   document.getElementById("maindiv").style.backgroundColor = "#f54646e8";
                }
                
            } else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
        //window.setInterval(function(){ $A.enqueueAction(component.get("c.doInit")); }, 30000000);
    }, 
    
    closeModel : function(component, event, helper) {
        component.set("v.isModalOpen",false);
        component.set("v.defaultWindow",false);
    }
   
    
})