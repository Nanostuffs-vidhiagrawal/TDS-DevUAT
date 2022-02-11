({
    onInit: function(component) {
        var action = component.get("c.fetchCP"); 
        action.setParams({
            caseId : component.get('v.recordId')
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();            
            if (state == "SUCCESS") {
                component.set("v.to", a.getReturnValue()); 
            }
        });
        $A.enqueueAction(action);
    },
	sendEmail : function(component, event, helper) {        
        var action = component.get("c.sendEmailFromActivityTab"); 
        action.setParams({
            caseId : component.get('v.recordId'),
            fromEmail : component.get('v.from'),
            to : component.get('v.selectedValue'),
            mailBody : component.get('v.body')
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();            
            if (state == "SUCCESS") {
   			    component.set("v.message", true); 
               // console.log('a.getReturnValue()'); 
            }
        });
        $A.enqueueAction(action);
	}
})