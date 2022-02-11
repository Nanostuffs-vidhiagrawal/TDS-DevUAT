({
    doInit : function(component, event, helper) {
        
        //var recId = component.get("v.recordId")
        var action = component.get("c.getDisputeItem");
        var recordId = component.get("v.recordId");
        
        action.setParams({
            recId: recordId
        });
        action.setCallback(this, function(a) {
            component.set("v.spinner",true);
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                let returnval = a.getReturnValue();
                component.set("v.MessageData",returnval);
                component.set("v.spinner",false);
                //alert(JSON.stringify(returnval))
                
            }else{
                component.set("v.spinner",false);
            }
            
        });
        $A.enqueueAction(action);
        
    },
    // function automatic called by aura:waiting event  
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