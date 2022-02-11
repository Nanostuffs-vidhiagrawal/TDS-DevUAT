({
	doInit : function(component, event, helper) {
        
		var recId = component.get("v.recordId")
        var action = component.get("c.updateChatFields");

        
        action.setParams({
            caseId: recId
        });
        action.setCallback(this, function(a) {
            component.set("v.spinner",true);
            var state = a.getState();
            var errors = a.getError();

            if (state == "SUCCESS") {
                
                let returnval = a.getReturnValue();

                component.set("v.chatList",returnval);
                component.set("v.spinner",false);
                
                
            }else{
                component.set("v.spinner",false);
            }
            
        });
        $A.enqueueAction(action);
        
	},
    closeChatBox : function (cmp, event, helper) {

        cmp.set('v.showChats',false);
        $A.get('e.force:refreshView').fire();
    },
	
})