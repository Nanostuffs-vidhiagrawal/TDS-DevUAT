({
    doInit: function (component, event, helper) {
        var action = component.get("c.displayLoggedInUserContactInfo");
        action.setParams({ });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userCon = response.getReturnValue();
               console.log("result :" + JSON.stringify(userCon));
                component.set("v.con", userCon);
            }
            else if (state === "INCOMPLETE") {
                alert('line 15');
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
        
    },
  handleClick: function (component, event) {
    var allValid = component.find('market').reduce(
                         function(validSoFar, inputCmp) 
            {
            inputCmp.showHelpMessageIfInvalid();

  return validSoFar && inputCmp.get('v.validity').valid;
         }, true);

         if (allValid) {
       var con = component.get("v.con");
      var action = component.get("c.updatemarkertingpreferences");
        action.setParams({
          con: con
        });
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log(`state=> ${state}`);
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
          console.log("result :" + JSON.stringify(result));
          window.location.reload();
        } else if (state === "ERROR") {
          var errors = response.getError();
          console.log("result :" + JSON.stringify(errors));
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log("Error message: " + errors[0].message);
            }
          } else {
            console.log("Unknown error");
          }
        }
      });
      $A.enqueueAction(action);
    }
  }    
    
});