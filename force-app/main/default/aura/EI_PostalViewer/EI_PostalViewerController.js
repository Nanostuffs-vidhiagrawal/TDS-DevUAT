({
    doInit : function(component, event, helper) {
        /* component.set('v.columns', [
            {label: 'Status', fieldName: 'EventType', type: 'text'},
            {label: 'Time', fieldName: 'EventAt', type: 'text'},
            {label: 'Email', fieldName: 'Email', type: 'text'}
            
        ]);*/
        var recId = component.get("v.recordId")

        var action = component.get("c.getMailjetMessageDetails");
        var recordId = component.get("v.recordId");
        
        action.setParams({
            recId: recordId
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                let returnval = a.getReturnValue();
                component.set("v.MessageData",returnval);
                 
                
            }
            component.set("v.spinner", false);
            
            
        });
        $A.enqueueAction(action);
        
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        
        component.set("v.spinner", true); 
        
    },
    
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner  
        component.set("v.spinner", false); 
    },
})