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
                component.set("v.to", a.getReturnValue().cpList); 
                component.set("v.profile",a.getReturnValue().profile);
                if(a.getReturnValue().profile == 'Zero Deposit'){
                    component.set("v.from",'claims@zerodeposit.com');
                }
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
            mailBody : component.get('v.body'),
            subject : component.get('v.subject')
        });
        action.setCallback(this, function(a) {
            let state = a.getState();
            let errors = a.getError();            
            if (state == "SUCCESS") {
   			    component.set("v.message", true); 
                $A.get('e.force:refreshView').fire();
               // console.log('a.getReturnValue()'); 
            }
        });
        $A.enqueueAction(action);
	}
})