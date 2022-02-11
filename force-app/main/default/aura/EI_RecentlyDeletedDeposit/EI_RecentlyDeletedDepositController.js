({
	fetchdata : function(component, event, helper) {
        var action = component.get("c.getDeposits");
        action.setParams({  });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('line-->8'+response.getReturnValue());
                component.set("v.depositlist", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
              //  alert('incomplete');
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
    },
    Viewdeposit: function(component, event, helper) {
     var depositid = event.getSource().get("v.value");
      var address = "/depositsummarypage";
        var domain = window.location.origin;

        var urlEvent = $A.get("e.force:navigateToURL");
        console.log(urlEvent);
        urlEvent.setParams({
          url: address + "?id=" + depositid
        });
        urlEvent.fire(); 
        
        
        
    }
})