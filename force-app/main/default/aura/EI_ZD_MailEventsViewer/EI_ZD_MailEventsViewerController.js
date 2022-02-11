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
            recId: recId
        });
        action.setCallback(this, function(a) {
            component.set("v.spinner",true);
            var state = a.getState();
            var errors = a.getError();
            if (state == "SUCCESS") {
                let returnval = a.getReturnValue();
                component.set("v.MessageData",returnval);
                component.set("v.spinner",false);
                
                
            }else{
                component.set("v.spinner",false);
            }
            
        });
        $A.enqueueAction(action);
        
    },
    handleSectionToggle: function (component, event) {
        var openSections = event.getParam('openSections');
        console.log(openSections.join(', '));
        var tempList = [];
        var openedCount = 0;
        component.set("v.openedCount",openedCount);
        component.set("v.EventList",tempList);
        
        if(openSections.join(', ')!=''){
            var action = component.get("c.getEventDetails");
            
            action.setParams({
                messageID: openSections.join(', '),
                recordId:component.get("v.recordId") 
            });
            action.setCallback(this, function(a) {
                component.set("v.spinner",true);
                var state = a.getState();
                var errors = a.getError();
                if (state == "SUCCESS") {
                    let returnval = a.getReturnValue();
                    component.set("v.EventList",returnval);
                    for (const element of returnval) {
                        if(element.EventType == 'opened'){
                            openedCount++;
                        }
                        component.set("v.openedCount",openedCount);
                        
                    }
					component.set("v.spinner",false);
                    
                }else{
                    component.set("v.spinner",false);
                }
                
            });
            $A.enqueueAction(action);
        }
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