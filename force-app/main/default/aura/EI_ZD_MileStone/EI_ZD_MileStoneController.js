({
	doInit : function(component, event, helper) {
        var action = component.get("c.getCaseDetails");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(a) { 
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                component.set("v.CaseRec",a.getReturnValue());
                if(a.getReturnValue().Days_Remaining__c <= 5)
                {  
                   document.getElementById("maindiv").style.backgroundColor = "#f54646e8";
                }
                
            }
            else {
                
            }
        });
        $A.enqueueAction(action);
        
        
        //window.setInterval(function(){ $A.enqueueAction(component.get("c.doInit")); }, 30000000);
	}
})