({
	doInit : function(component, event, helper) {
    var usid = component.get('v.strRecordId'); 
	var action = component.get("c.viewdetails");
        action.setParams({ useid : usid });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('line-->8'+response.getReturnValue());
                component.set("v.obj", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                alert('incomplete');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log('line--14' +JSON.stringify(errors) );
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
    }	
})